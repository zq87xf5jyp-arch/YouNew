-- Manual activation bridge from approved Admin candidates to the public site.
-- The public feed contains only the already-sanitized artifact and never exposes
-- editor identity, drafts, review rows, or operational tables.

create table if not exists public.public_content_feed (
  feed_key text primary key default 'active' check (feed_key = 'active'),
  artifact_id uuid not null unique references public.published_content_artifacts(id),
  source_version text not null,
  artifact jsonb not null check (
    artifact ->> 'source' = 'supabase-operational'
    and artifact ->> 'schemaVersion' = '1'
    and artifact ->> 'sourceVersion' = source_version
    and jsonb_typeof(artifact -> 'records') = 'array'
    and jsonb_array_length(artifact -> 'records') = record_count
  ),
  artifact_fingerprint text not null check (artifact_fingerprint ~ '^[a-f0-9]{64}$'),
  record_count integer not null check (record_count > 0),
  activated_at timestamptz not null
);

alter table public.public_content_feed enable row level security;
revoke all on table public.public_content_feed from public, anon, authenticated;
grant select on table public.public_content_feed to anon, authenticated;
grant all on table public.public_content_feed to service_role;

drop policy if exists "public reads active content feed" on public.public_content_feed;
create policy "public reads active content feed"
on public.public_content_feed for select
to anon, authenticated
using (feed_key = 'active');

create or replace function public.activate_content_artifact(p_artifact_id uuid)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_candidate public.published_content_artifacts%rowtype;
  v_previous_active_id uuid;
begin
  if coalesce(private.current_admin_role()::text, '') not in ('owner', 'admin') then
    raise exception using errcode = '42501', message = 'sync_activation_role_required';
  end if;

  lock table public.published_content_artifacts in share row exclusive mode;

  select *
    into v_candidate
  from public.published_content_artifacts
  where id = p_artifact_id
  for update;

  if not found then
    raise exception using errcode = 'P0002', message = 'content_artifact_not_found';
  end if;
  if v_candidate.status <> 'candidate' then
    raise exception using errcode = '23514', message = 'content_artifact_not_candidate';
  end if;
  if v_candidate.record_count <= 0 then
    raise exception using errcode = '23514', message = 'empty_content_artifact_not_activatable';
  end if;
  if jsonb_typeof(v_candidate.artifact -> 'records') <> 'array'
     or jsonb_array_length(v_candidate.artifact -> 'records') <> v_candidate.record_count
     or v_candidate.artifact ->> 'source' <> 'supabase-operational'
     or v_candidate.artifact ->> 'schemaVersion' <> '1'
     or v_candidate.artifact ->> 'sourceVersion' <> v_candidate.source_version
     or (v_candidate.artifact ->> 'recordCount')::integer <> v_candidate.record_count then
    raise exception using errcode = '23514', message = 'content_artifact_record_count_mismatch';
  end if;

  select id
    into v_previous_active_id
  from public.published_content_artifacts
  where status = 'active'
  limit 1
  for update;

  update public.published_content_artifacts
  set status = 'superseded'
  where status = 'active';

  update public.published_content_artifacts
  set status = 'active',
      activated_at = now()
  where id = v_candidate.id;

  insert into public.public_content_feed (
    feed_key,
    artifact_id,
    source_version,
    artifact,
    artifact_fingerprint,
    record_count,
    activated_at
  )
  select
    'active',
    id,
    source_version,
    artifact,
    artifact_fingerprint,
    record_count,
    activated_at
  from public.published_content_artifacts
  where id = v_candidate.id
  on conflict (feed_key) do update
  set artifact_id = excluded.artifact_id,
      source_version = excluded.source_version,
      artifact = excluded.artifact,
      artifact_fingerprint = excluded.artifact_fingerprint,
      record_count = excluded.record_count,
      activated_at = excluded.activated_at;

  insert into public.audit_logs (
    user_id,
    action,
    entity_type,
    entity_id,
    previous_value,
    new_value
  )
  values (
    auth.uid(),
    'content_artifact_activated',
    'published_content_artifact',
    v_candidate.id::text,
    jsonb_build_object('active_artifact_id', v_previous_active_id),
    jsonb_build_object(
      'active_artifact_id', v_candidate.id,
      'artifact_fingerprint', v_candidate.artifact_fingerprint,
      'record_count', v_candidate.record_count
    )
  );

  return v_candidate.id;
end;
$$;

revoke all on function public.activate_content_artifact(uuid) from public, anon;
grant execute on function public.activate_content_artifact(uuid) to authenticated, service_role;

insert into public.public_content_feed (
  feed_key,
  artifact_id,
  source_version,
  artifact,
  artifact_fingerprint,
  record_count,
  activated_at
)
select
  'active',
  id,
  source_version,
  artifact,
  artifact_fingerprint,
  record_count,
  activated_at
from public.published_content_artifacts
where status = 'active'
  and record_count > 0
  and activated_at is not null
on conflict (feed_key) do nothing;
