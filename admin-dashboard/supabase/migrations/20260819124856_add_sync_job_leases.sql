-- Lease-based sync execution. A queued job does not pretend to have started,
-- and a worker can finalize only the lease it atomically claimed.

drop policy if exists "approved admins insert sync jobs" on public.sync_jobs;
revoke insert on table public.sync_jobs from authenticated;

alter table public.sync_jobs
  add column if not exists queued_at timestamptz,
  add column if not exists heartbeat_at timestamptz,
  add column if not exists lease_expires_at timestamptz,
  add column if not exists lease_token uuid,
  add column if not exists attempt_count integer not null default 0,
  add column if not exists timed_out_at timestamptz;

update public.sync_jobs
set queued_at = coalesce(queued_at, created_at),
    started_at = case when status = 'queued' then null else coalesce(started_at, created_at) end,
    heartbeat_at = case
      when status = 'running' then coalesce(heartbeat_at, started_at, created_at)
      else heartbeat_at
    end,
    lease_expires_at = case
      when status = 'running' then coalesce(
        lease_expires_at,
        coalesce(heartbeat_at, started_at, created_at) + interval '15 minutes'
      )
      else lease_expires_at
    end,
    lease_token = case
      when status = 'running' then coalesce(lease_token, gen_random_uuid())
      else lease_token
    end,
    attempt_count = case
      when status = 'running' then greatest(attempt_count, 1)
      else attempt_count
    end,
    details = case
      when status = 'running' then coalesce(details, '{}'::jsonb) || '{"lease_migration":"legacy_backfill"}'::jsonb
      else details
    end;

alter table public.sync_jobs
  alter column queued_at set default now(),
  alter column queued_at set not null,
  alter column started_at drop default,
  alter column started_at drop not null,
  drop constraint if exists sync_jobs_status_check,
  add constraint sync_jobs_status_check
    check (status in ('queued', 'running', 'succeeded', 'failed', 'cancelled', 'timed_out')),
  drop constraint if exists sync_jobs_attempt_count_check,
  add constraint sync_jobs_attempt_count_check check (attempt_count >= 0),
  drop constraint if exists sync_jobs_lease_shape_check,
  add constraint sync_jobs_lease_shape_check check (
    (status = 'running' and started_at is not null and heartbeat_at is not null
      and lease_expires_at is not null and lease_token is not null)
    or status <> 'running'
  );

create index if not exists sync_jobs_queued_claim_idx
  on public.sync_jobs (queued_at, id)
  where status = 'queued';

create index if not exists sync_jobs_running_lease_idx
  on public.sync_jobs (lease_expires_at, id)
  where status = 'running';

create or replace function public.claim_sync_job(p_job_id uuid)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_token uuid := gen_random_uuid();
  v_claimed uuid;
begin
  update public.sync_jobs
  set status = 'running',
      started_at = statement_timestamp(),
      heartbeat_at = statement_timestamp(),
      lease_expires_at = statement_timestamp() + interval '15 minutes',
      lease_token = v_token,
      attempt_count = attempt_count + 1,
      completed_at = null,
      timed_out_at = null,
      error_summary = null
  where id = p_job_id
    and status = 'queued'
  returning lease_token into v_claimed;

  return v_claimed;
end;
$$;

create or replace function public.heartbeat_sync_job(
  p_job_id uuid,
  p_lease_token uuid
)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_updated integer;
begin
  update public.sync_jobs
  set heartbeat_at = statement_timestamp(),
      lease_expires_at = statement_timestamp() + interval '15 minutes'
  where id = p_job_id
    and status = 'running'
    and lease_token = p_lease_token
    and lease_expires_at > statement_timestamp();
  get diagnostics v_updated = row_count;
  return v_updated = 1;
end;
$$;

create or replace function public.finalize_sync_job(
  p_job_id uuid,
  p_lease_token uuid,
  p_status text,
  p_result jsonb default '{}'::jsonb
)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_updated integer;
  v_completed_at timestamptz := statement_timestamp();
  v_fingerprint text := nullif(p_result ->> 'artifact_fingerprint', '');
begin
  if p_status not in ('succeeded', 'failed') or jsonb_typeof(p_result) <> 'object' then
    raise exception using errcode = '22023', message = 'invalid_sync_finalization';
  end if;
  if v_fingerprint is not null and v_fingerprint !~ '^[a-f0-9]{64}$' then
    raise exception using errcode = '22023', message = 'invalid_artifact_fingerprint';
  end if;

  update public.sync_jobs
  set status = p_status,
      completed_at = v_completed_at,
      heartbeat_at = v_completed_at,
      lease_expires_at = null,
      lease_token = null,
      target_version = nullif(p_result ->> 'target_version', ''),
      records_processed = greatest(0, coalesce((p_result ->> 'records_processed')::integer, 0)),
      records_failed = greatest(0, coalesce((p_result ->> 'records_failed')::integer, 0)),
      artifact_fingerprint = v_fingerprint,
      duration_ms = greatest(0, coalesce((p_result ->> 'duration_ms')::integer, 0)),
      error_summary = case
        when p_status = 'failed' then left(coalesce(nullif(p_result ->> 'error_summary', ''), 'sync_failed'), 180)
        else null
      end,
      details = coalesce(p_result -> 'details', '{}'::jsonb)
  where id = p_job_id
    and status = 'running'
    and lease_token = p_lease_token
    and lease_expires_at > v_completed_at;
  get diagnostics v_updated = row_count;
  return v_updated = 1;
end;
$$;

revoke all on function public.claim_sync_job(uuid) from public, anon, authenticated;
revoke all on function public.heartbeat_sync_job(uuid, uuid) from public, anon, authenticated;
revoke all on function public.finalize_sync_job(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.claim_sync_job(uuid) to service_role;
grant execute on function public.heartbeat_sync_job(uuid, uuid) to service_role;
grant execute on function public.finalize_sync_job(uuid, uuid, text, jsonb) to service_role;

create or replace function private.reconcile_stale_sync_jobs(
  p_dry_run boolean default true,
  p_reference_at timestamptz default statement_timestamp()
)
returns table (reason text, eligible_count bigint, changed_count bigint)
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_queued bigint;
  v_running bigint;
  v_changed bigint;
begin
  select count(*) into v_queued
  from public.sync_jobs
  where status = 'queued'
    and queued_at < p_reference_at - interval '10 minutes';

  if p_dry_run then
    reason := 'queued_timeout'; eligible_count := v_queued; changed_count := 0; return next;
  else
    with timed_out as (
      update public.sync_jobs
      set status = 'timed_out',
          timed_out_at = p_reference_at,
          completed_at = p_reference_at,
          error_summary = 'queued_lease_timeout',
          lease_expires_at = null,
          lease_token = null
      where status = 'queued'
        and queued_at < p_reference_at - interval '10 minutes'
      returning id, type
    )
    insert into public.audit_logs (user_id, action, entity_type, entity_id, new_value)
    select null, 'sync_job_timed_out', 'sync_job', id::text,
      jsonb_build_object('reason', 'queued_timeout', 'type', type)
    from timed_out;
    get diagnostics v_changed = row_count;
    reason := 'queued_timeout'; eligible_count := v_queued; changed_count := v_changed; return next;
  end if;

  select count(*) into v_running
  from public.sync_jobs
  where status = 'running'
    and (
      lease_expires_at < p_reference_at
      or coalesce(heartbeat_at, started_at, queued_at) < p_reference_at - interval '15 minutes'
    );

  if p_dry_run then
    reason := 'running_lease_expired'; eligible_count := v_running; changed_count := 0; return next;
  else
    with timed_out as (
      update public.sync_jobs
      set status = 'timed_out',
          timed_out_at = p_reference_at,
          completed_at = p_reference_at,
          error_summary = 'running_lease_expired',
          lease_expires_at = null,
          lease_token = null
      where status = 'running'
        and (
          lease_expires_at < p_reference_at
          or coalesce(heartbeat_at, started_at, queued_at) < p_reference_at - interval '15 minutes'
        )
      returning id, type
    )
    insert into public.audit_logs (user_id, action, entity_type, entity_id, new_value)
    select null, 'sync_job_timed_out', 'sync_job', id::text,
      jsonb_build_object('reason', 'running_lease_expired', 'type', type)
    from timed_out;
    get diagnostics v_changed = row_count;
    reason := 'running_lease_expired'; eligible_count := v_running; changed_count := v_changed; return next;
  end if;
end;
$$;

revoke all on function private.reconcile_stale_sync_jobs(boolean, timestamptz)
  from public, anon, authenticated;
grant execute on function private.reconcile_stale_sync_jobs(boolean, timestamptz) to service_role;

create or replace function public.request_content_sync()
returns uuid
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_job_id uuid := gen_random_uuid();
begin
  if coalesce(private.current_admin_role()::text, '') not in ('owner', 'admin') then
    raise exception using errcode = '42501', message = 'sync_role_required';
  end if;

  insert into public.sync_jobs (
    id, job, type, target, status, queued_at, initiator,
    source_version, idempotency_key, details
  )
  values (
    v_job_id,
    'content_artifact_candidate',
    'content_artifact_candidate',
    'github-canonical-handoff',
    'queued',
    statement_timestamp(),
    auth.uid(),
    'supabase-operational',
    'content-sync:' || v_job_id::text,
    jsonb_build_object('activation', 'manual', 'production_replacement_allowed', false)
  );
  return v_job_id;
end;
$$;

revoke all on function public.request_content_sync() from public, anon;
grant execute on function public.request_content_sync() to authenticated, service_role;

create or replace function public.enqueue_article_publication()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_fingerprint text;
  v_key text;
begin
  if new.status = 'published'
     and (tg_op = 'INSERT' or old.status is distinct from new.status or old.updated_at is distinct from new.updated_at) then
    v_fingerprint := encode(extensions.digest(convert_to(to_jsonb(new)::text, 'UTF8'), 'sha256'), 'hex');
    v_key := 'article:' || new.id::text || ':' || v_fingerprint;
    insert into public.sync_jobs (
      job, type, target, status, queued_at, initiator, source_version,
      target_version, artifact_fingerprint, idempotency_key, details
    )
    values (
      'content_publication', 'content_publication', 'canonical-content', 'queued',
      statement_timestamp(), auth.uid(), coalesce(old.updated_at::text, 'new'),
      new.updated_at::text, v_fingerprint, v_key,
      jsonb_build_object('article_id', new.id, 'article_slug', new.slug)
    )
    on conflict (idempotency_key) do nothing;
  end if;
  return new;
end;
$$;

revoke all on function public.enqueue_article_publication() from public, anon, authenticated;

do $schedule$
declare
  existing_job bigint;
begin
  select jobid into existing_job
  from cron.job
  where jobname = 'younew-sync-job-lease-reconciliation';
  if existing_job is not null then
    perform cron.unschedule(existing_job);
  end if;
  perform cron.schedule(
    'younew-sync-job-lease-reconciliation',
    '*/5 * * * *',
    'select * from private.reconcile_stale_sync_jobs(true);'
  );
end;
$schedule$;

comment on function private.reconcile_stale_sync_jobs(boolean, timestamptz) is
  'Idempotent lease reconciliation. The initial schedule is dry-run-only; activation requires a separately approved forward migration.';
