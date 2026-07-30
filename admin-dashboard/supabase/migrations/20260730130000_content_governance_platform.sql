-- YouNew governed knowledge operational projection.
-- Additive only: no canonical DataProject content is published or overwritten.
-- Rollback is performed by disabling consumers/RPC feature flags while keeping
-- the append-only evidence and audit history.

do $$ begin
  create type public.governance_verification_status as enum (
    'unverified', 'verified', 'review_due_soon', 'overdue',
    'source_unavailable', 'disputed', 'archived'
  );
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.governance_publication_status as enum (
    'draft', 'qa', 'published', 'archived'
  );
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.governance_review_state as enum (
    'needs_review', 'assigned', 'in_review', 'approved',
    'monitoring', 'expired', 'closed'
  );
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.governance_content_origin as enum (
    'imported', 'manually_created', 'municipality_release',
    'government_publication', 'ai_generated_draft', 'migrated'
  );
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.governance_criticality as enum ('standard', 'critical');
exception when duplicate_object then null;
end $$;

create table if not exists public.content_governance_state (
  id uuid primary key default gen_random_uuid(),
  record_key text not null unique check (char_length(record_key) between 3 and 240),
  content_id text not null check (char_length(content_id) between 1 and 200),
  article_id uuid unique references public.articles(id) on delete set null,
  title text not null check (char_length(title) between 1 and 300),
  content_type text not null check (char_length(content_type) between 1 and 80),
  jurisdiction jsonb not null,
  official_source_url text check (official_source_url is null or official_source_url ~ '^https://'),
  source_title text check (source_title is null or char_length(source_title) <= 300),
  source_publisher text check (source_publisher is null or char_length(source_publisher) <= 200),
  source_is_official boolean not null default false,
  source_opened_at timestamptz,
  last_verified_at timestamptz,
  next_review_at timestamptz,
  review_interval_days integer not null default 90 check (review_interval_days between 1 and 730),
  content_owner_id uuid references public.profiles(id),
  reviewed_by uuid references public.profiles(id),
  second_reviewed_by uuid references public.profiles(id),
  verification_status public.governance_verification_status not null default 'unverified',
  publication_status public.governance_publication_status not null default 'draft',
  review_state public.governance_review_state not null default 'needs_review',
  criticality public.governance_criticality not null default 'standard',
  confidence_level text not null default 'low' check (confidence_level in ('low', 'medium', 'high')),
  confidence_score integer not null default 0 check (confidence_score between 0 and 100),
  confidence_score_version integer not null default 1 check (confidence_score_version = 1),
  confidence_breakdown jsonb not null default
    '{"officialSource":0,"humanReviewer":0,"independentReview":0,"freshness":0,"jurisdictionApplicability":0}'::jsonb,
  validity_start timestamptz,
  validity_end timestamptz,
  change_notes text check (change_notes is null or char_length(change_notes) <= 2000),
  content_origin public.governance_content_origin not null,
  origin_reference text check (origin_reference is null or char_length(origin_reference) <= 1000),
  origin_captured_at timestamptz,
  origin_artifact_digest text check (
    origin_artifact_digest is null
    or origin_artifact_digest ~ '^sha256:[a-f0-9]{64}$'
  ),
  version integer not null default 1 check (version > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint content_governance_jurisdiction_object_check check (
    jsonb_typeof(jurisdiction) = 'object'
    and jurisdiction ?& array[
      'countryCode', 'level', 'municipalityDependent', 'applicabilityVerified',
      'provinceCode', 'provinceName', 'municipalityCode', 'municipalityName'
    ]
    and jurisdiction ->> 'countryCode' = 'NL'
    and jurisdiction ->> 'level' in ('national', 'provincial', 'municipal', 'mixed')
    and jsonb_typeof(jurisdiction -> 'municipalityDependent') = 'boolean'
    and jsonb_typeof(jurisdiction -> 'applicabilityVerified') = 'boolean'
  ),
  constraint content_governance_independent_reviewer_check check (
    second_reviewed_by is null or second_reviewed_by is distinct from reviewed_by
  ),
  constraint content_governance_validity_check check (
    validity_end is null or validity_start is null or validity_end >= validity_start
  ),
  constraint content_governance_review_dates_check check (
    next_review_at is null or last_verified_at is null or next_review_at > last_verified_at
  ),
  constraint content_governance_breakdown_check check (
    jsonb_typeof(confidence_breakdown) = 'object'
    and confidence_breakdown ?& array[
      'officialSource', 'humanReviewer', 'independentReview',
      'freshness', 'jurisdictionApplicability'
    ]
  )
);

create table if not exists public.content_governance_versions (
  id uuid primary key default gen_random_uuid(),
  governance_state_id uuid not null references public.content_governance_state(id),
  version integer not null check (version > 0),
  parent_version integer check (parent_version is null or parent_version > 0),
  actor_id uuid references public.profiles(id),
  actor_type text not null check (actor_type in ('human', 'service', 'system', 'ai')),
  transformation_identifier text not null check (char_length(transformation_identifier) between 1 and 200),
  artifact_digest text check (
    artifact_digest is null or artifact_digest ~ '^sha256:[a-f0-9]{64}$'
  ),
  snapshot jsonb not null check (jsonb_typeof(snapshot) = 'object'),
  created_at timestamptz not null default now(),
  unique (governance_state_id, version)
);

create table if not exists public.content_review_tasks (
  id uuid primary key default gen_random_uuid(),
  governance_state_id uuid not null references public.content_governance_state(id),
  owner_id uuid references public.profiles(id),
  reason text not null check (reason in (
    'verification_due', 'source_issue', 'possible_duplicate', 'dispute',
    'jurisdiction_gap', 'manual_review', 'expired'
  )),
  severity text not null check (severity in ('low', 'medium', 'high', 'critical')),
  state public.governance_review_state not null default 'needs_review',
  sla_due_at timestamptz not null,
  triggering_governance_version integer not null check (triggering_governance_version > 0),
  source_issue_id uuid,
  created_at timestamptz not null default now(),
  assigned_at timestamptz,
  started_at timestamptz,
  resolved_at timestamptz,
  resolution text check (resolution is null or char_length(resolution) <= 1000),
  updated_at timestamptz not null default now()
);

create unique index if not exists content_review_tasks_open_reason_unique
  on public.content_review_tasks (governance_state_id, reason)
  where resolved_at is null;
create index if not exists content_review_tasks_queue_idx
  on public.content_review_tasks (state, severity, sla_due_at);

create table if not exists public.content_review_events (
  id uuid primary key default gen_random_uuid(),
  governance_state_id uuid not null references public.content_governance_state(id),
  task_id uuid references public.content_review_tasks(id),
  event_type text not null check (event_type in (
    'task_created', 'assigned', 'review_started', 'review_approved',
    'verification_approved', 'second_verification_approved',
    'publication_approved', 'monitoring_started', 'expired',
    'needs_review', 'closed', 'disputed', 'source_unavailable', 'archived'
  )),
  from_state public.governance_review_state,
  to_state public.governance_review_state,
  actor_id uuid references public.profiles(id),
  actor_type text not null check (actor_type in ('human', 'system')),
  triggering_governance_version integer not null check (triggering_governance_version > 0),
  idempotency_key text check (idempotency_key is null or char_length(idempotency_key) between 8 and 200),
  reason text not null check (char_length(reason) between 2 and 1000),
  evidence jsonb not null default '{}'::jsonb check (jsonb_typeof(evidence) = 'object'),
  created_at timestamptz not null default now(),
  unique (actor_id, event_type, idempotency_key)
);

create table if not exists public.source_check_attempts (
  id uuid primary key default gen_random_uuid(),
  governance_state_id uuid not null references public.content_governance_state(id),
  checked_url text not null check (checked_url ~ '^https://'),
  outcome text not null check (outcome in (
    'reachable', 'redirected', 'restricted', 'transient_failure',
    'hard_failure', 'invalid_tls'
  )),
  http_status integer check (http_status is null or http_status between 100 and 599),
  error_class text check (error_class is null or char_length(error_class) <= 120),
  latency_ms integer check (latency_ms is null or latency_ms >= 0),
  checker_version text not null check (char_length(checker_version) between 1 and 120),
  artifact_digest text check (
    artifact_digest is null or artifact_digest ~ '^sha256:[a-f0-9]{64}$'
  ),
  checked_at timestamptz not null,
  created_at timestamptz not null default now()
);

alter table public.content_review_tasks
  drop constraint if exists content_review_tasks_source_issue_id_fkey,
  add constraint content_review_tasks_source_issue_id_fkey
    foreign key (source_issue_id) references public.source_check_attempts(id);

create index if not exists source_check_attempts_state_time_idx
  on public.source_check_attempts (governance_state_id, checked_at desc);

create table if not exists public.governance_action_receipts (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid not null references public.profiles(id),
  action text not null check (char_length(action) between 2 and 120),
  idempotency_key text not null check (char_length(idempotency_key) between 8 and 200),
  governance_state_id uuid not null references public.content_governance_state(id),
  result_version integer not null check (result_version > 0),
  created_at timestamptz not null default now(),
  unique (actor_id, action, idempotency_key)
);

create table if not exists public.governance_feature_flags (
  key text primary key check (key in (
    'governance_consumers', 'scheduled_writeback', 'research_ingestion'
  )),
  enabled boolean not null default false,
  changed_by uuid references public.profiles(id),
  changed_at timestamptz not null default now(),
  notes text not null check (char_length(notes) between 2 and 500)
);

insert into public.governance_feature_flags (key, enabled, notes)
values
  ('governance_consumers', false, 'Enable only after compatibility and RLS validation.'),
  ('scheduled_writeback', false, 'DataProject publication requires separate approval.'),
  ('research_ingestion', false, 'Requires privacy review and approved research protocol.')
on conflict (key) do nothing;

create table if not exists public.research_consents (
  id uuid primary key default gen_random_uuid(),
  research_session_id uuid not null unique,
  protocol_version text not null check (char_length(protocol_version) between 1 and 80),
  consented_at timestamptz not null,
  revoked_at timestamptz,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  constraint research_consent_dates_check check (
    revoked_at is null or revoked_at >= consented_at
  )
);

create table if not exists public.research_observations (
  id uuid primary key default gen_random_uuid(),
  research_session_id uuid not null references public.research_consents(research_session_id),
  journey text not null check (journey in (
    'brp', 'digid', 'huisarts', 'zorgtoeslag', 'employment'
  )),
  completed boolean not null,
  source_opened boolean not null,
  wrong_turns integer not null check (wrong_turns between 0 and 100),
  external_searches integer not null check (external_searches between 0 and 100),
  human_help boolean not null,
  critical_error boolean not null,
  duration_seconds integer not null check (duration_seconds between 0 and 7200),
  safety_stop boolean not null default false,
  observed_at timestamptz not null,
  recorded_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '90 days'),
  constraint research_observation_retention_check check (
    expires_at <= created_at + interval '90 days'
    and expires_at > created_at
  )
);

create or replace function public.governance_review_due_lead_days(p_interval_days integer)
returns integer
language sql
immutable
set search_path = pg_catalog
as $$
  select greatest(1, least(14, floor(greatest(1, coalesce(p_interval_days, 90)) * 0.25)::integer));
$$;

create or replace function public.governance_effective_status(
  p_verification public.governance_verification_status,
  p_publication public.governance_publication_status,
  p_source_url text,
  p_last_verified_at timestamptz,
  p_next_review_at timestamptz,
  p_validity_start timestamptz,
  p_validity_end timestamptz,
  p_review_interval_days integer,
  p_now timestamptz default now()
)
returns public.governance_verification_status
language sql
stable
set search_path = pg_catalog, public
as $$
  select case
    when p_publication = 'archived' or p_verification = 'archived' then 'archived'
    when p_verification = 'disputed' then 'disputed'
    when p_verification = 'source_unavailable' then 'source_unavailable'
    when p_verification = 'unverified'
      or p_source_url is null or p_source_url !~ '^https://'
      or p_last_verified_at is null
      or (p_validity_start is not null and p_now < p_validity_start)
      then 'unverified'
    when p_verification = 'overdue'
      or (p_validity_end is not null and p_now > p_validity_end)
      or (p_next_review_at is not null and p_now > p_next_review_at)
      then 'overdue'
    when p_verification = 'review_due_soon'
      or (
        p_next_review_at is not null
        and p_now >= p_next_review_at
          - make_interval(days => public.governance_review_due_lead_days(p_review_interval_days))
      )
      then 'review_due_soon'
    else 'verified'
  end::public.governance_verification_status;
$$;

create or replace function public.governance_confidence_breakdown(
  p_source_is_official boolean,
  p_source_opened_at timestamptz,
  p_reviewed_by uuid,
  p_second_reviewed_by uuid,
  p_status public.governance_verification_status,
  p_jurisdiction jsonb
)
returns jsonb
language sql
immutable
set search_path = pg_catalog
as $$
  select jsonb_build_object(
    'officialSource', case when p_source_is_official and p_source_opened_at is not null then 40 else 0 end,
    'humanReviewer', case when p_reviewed_by is not null then 20 else 0 end,
    'independentReview', case
      when p_second_reviewed_by is not null and p_second_reviewed_by is distinct from p_reviewed_by then 15
      else 0
    end,
    'freshness', case when p_status in ('verified', 'review_due_soon') then 10 else 0 end,
    'jurisdictionApplicability', case
      when p_jurisdiction ->> 'applicabilityVerified' = 'true' then 15
      else 0
    end
  );
$$;

create or replace function public.governance_confidence_score(p_breakdown jsonb)
returns integer
language sql
immutable
set search_path = pg_catalog
as $$
  select coalesce((p_breakdown ->> 'officialSource')::integer, 0)
    + coalesce((p_breakdown ->> 'humanReviewer')::integer, 0)
    + coalesce((p_breakdown ->> 'independentReview')::integer, 0)
    + coalesce((p_breakdown ->> 'freshness')::integer, 0)
    + coalesce((p_breakdown ->> 'jurisdictionApplicability')::integer, 0);
$$;

create or replace function public.enforce_content_governance_state()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  v_event_id uuid;
  v_effective public.governance_verification_status;
  v_breakdown jsonb;
  v_protected_changed boolean := false;
begin
  if tg_op = 'INSERT' then
    if new.publication_status <> 'draft' or new.verification_status <> 'unverified'
       or new.reviewed_by is not null or new.second_reviewed_by is not null then
      raise exception using errcode = '23514', message = 'initial_governance_must_be_draft_unverified';
    end if;
    if new.content_origin in ('ai_generated_draft', 'migrated')
       and (new.publication_status <> 'draft' or new.verification_status <> 'unverified') then
      raise exception using errcode = '23514', message = 'ai_or_migrated_publication_denied';
    end if;
    new.version := 1;
  else
    if new.content_origin is distinct from old.content_origin
       or new.origin_reference is distinct from old.origin_reference
       or new.origin_captured_at is distinct from old.origin_captured_at
       or new.origin_artifact_digest is distinct from old.origin_artifact_digest then
      raise exception using errcode = '23514', message = 'content_origin_is_immutable';
    end if;
    v_protected_changed :=
      new.verification_status is distinct from old.verification_status
      or new.publication_status is distinct from old.publication_status
      or new.review_state is distinct from old.review_state
      or new.reviewed_by is distinct from old.reviewed_by
      or new.second_reviewed_by is distinct from old.second_reviewed_by
      or new.last_verified_at is distinct from old.last_verified_at
      or new.next_review_at is distinct from old.next_review_at;
    if v_protected_changed then
      begin
        v_event_id := nullif(current_setting('younew.human_review_event_id', true), '')::uuid;
      exception when invalid_text_representation then
        v_event_id := null;
      end;
      if v_event_id is null or not exists (
        select 1
        from public.content_review_events event
        where event.id = v_event_id
          and event.governance_state_id = new.id
          and (
            (event.actor_type = 'human' and event.actor_id = auth.uid())
            or (
              event.actor_type = 'system'
              and event.actor_id is null
              and event.event_type = 'source_unavailable'
            )
          )
      ) then
        raise exception using errcode = '42501', message = 'review_event_required';
      end if;
    end if;
    new.version := old.version + 1;
  end if;

  v_effective := public.governance_effective_status(
    new.verification_status, new.publication_status, new.official_source_url,
    new.last_verified_at, new.next_review_at, new.validity_start,
    new.validity_end, new.review_interval_days, now()
  );
  v_breakdown := public.governance_confidence_breakdown(
    new.source_is_official, new.source_opened_at, new.reviewed_by,
    new.second_reviewed_by, v_effective, new.jurisdiction
  );
  new.confidence_breakdown := v_breakdown;
  new.confidence_score := public.governance_confidence_score(v_breakdown);
  new.confidence_level := case
    when new.confidence_score >= 80 then 'high'
    when new.confidence_score >= 50 then 'medium'
    else 'low'
  end;
  new.confidence_score_version := 1;
  new.updated_at := now();
  return new;
end;
$$;

create or replace function public.append_content_governance_version()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_transformation text;
  v_actor_type text;
begin
  v_transformation := coalesce(
    nullif(current_setting('younew.transformation_identifier', true), ''),
    'database_write'
  );
  v_actor_type := case
    when new.content_origin = 'ai_generated_draft' then 'ai'
    when auth.uid() is null then 'service'
    else 'human'
  end;
  insert into public.content_governance_versions (
    governance_state_id, version, parent_version, actor_id, actor_type,
    transformation_identifier, artifact_digest, snapshot
  ) values (
    new.id,
    new.version,
    case when tg_op = 'UPDATE' then old.version else null end,
    auth.uid(),
    v_actor_type,
    v_transformation,
    new.origin_artifact_digest,
    to_jsonb(new)
  );
  return new;
end;
$$;

create or replace function public.enforce_content_review_event()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
declare
  v_role text := coalesce(public.current_admin_role()::text, '');
begin
  if new.actor_type = 'human' then
    if auth.uid() is null or new.actor_id is distinct from auth.uid() then
      raise exception using errcode = '42501', message = 'human_actor_identity_required';
    end if;
    if new.event_type in ('review_approved', 'verification_approved', 'second_verification_approved')
       and v_role not in ('owner', 'admin', 'qa') then
      raise exception using errcode = '42501', message = 'verification_role_required';
    end if;
    if new.event_type = 'publication_approved'
       and v_role not in ('owner', 'admin') then
      raise exception using errcode = '42501', message = 'publication_role_required';
    end if;
  elsif new.actor_type = 'system' then
    if new.actor_id is not null or new.event_type <> 'source_unavailable' then
      raise exception using errcode = '42501', message = 'unsupported_system_review_event';
    end if;
  end if;
  return new;
end;
$$;

create or replace function public.reject_immutable_governance_change()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  raise exception using errcode = '42501', message = 'append_only_governance_history';
end;
$$;

drop trigger if exists enforce_content_governance_state on public.content_governance_state;
create trigger enforce_content_governance_state
  before insert or update on public.content_governance_state
  for each row execute function public.enforce_content_governance_state();

drop trigger if exists append_content_governance_version on public.content_governance_state;
create trigger append_content_governance_version
  after insert or update on public.content_governance_state
  for each row execute function public.append_content_governance_version();

drop trigger if exists enforce_content_review_event on public.content_review_events;
create trigger enforce_content_review_event
  before insert on public.content_review_events
  for each row execute function public.enforce_content_review_event();

drop trigger if exists immutable_content_governance_versions on public.content_governance_versions;
create trigger immutable_content_governance_versions
  before update or delete on public.content_governance_versions
  for each row execute function public.reject_immutable_governance_change();

drop trigger if exists immutable_content_review_events on public.content_review_events;
create trigger immutable_content_review_events
  before update or delete on public.content_review_events
  for each row execute function public.reject_immutable_governance_change();

create or replace function public.verify_content_now(
  p_record_key text,
  p_expected_version integer,
  p_idempotency_key text,
  p_change_notes text
)
returns public.content_governance_state
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_role text := coalesce(public.current_admin_role()::text, '');
  v_state public.content_governance_state;
  v_event_id uuid := gen_random_uuid();
  v_event_type text;
  v_task_id uuid;
begin
  if v_actor is null or v_role not in ('owner', 'admin', 'qa') then
    raise exception using errcode = '42501', message = 'verification_role_required';
  end if;
  if char_length(coalesce(p_idempotency_key, '')) < 8 then
    raise exception using errcode = '22023', message = 'idempotency_key_required';
  end if;

  select state.* into v_state
  from public.content_governance_state state
  where state.record_key = p_record_key
  for update;
  if not found then
    raise exception using errcode = 'P0002', message = 'governance_record_not_found';
  end if;

  if exists (
    select 1 from public.governance_action_receipts receipt
    where receipt.actor_id = v_actor
      and receipt.action = 'verify_content_now'
      and receipt.idempotency_key = p_idempotency_key
      and receipt.governance_state_id = v_state.id
  ) then
    return v_state;
  end if;
  if v_state.version <> p_expected_version then
    raise exception using errcode = '40001', message = 'optimistic_version_conflict';
  end if;
  if not v_state.source_is_official
     or v_state.official_source_url is null
     or v_state.source_opened_at is null
     or v_state.source_opened_at < now() - interval '7 days' then
    raise exception using errcode = '23514', message = 'recent_official_source_evidence_required';
  end if;
  if not exists (
    select 1 from public.profiles reviewer
    where reviewer.id = v_actor
      and reviewer.is_approved = true
      and reviewer.role in ('owner', 'admin', 'qa')
  ) then
    raise exception using errcode = '42501', message = 'active_human_reviewer_required';
  end if;

  v_event_type := case
    when v_state.reviewed_by is not null and v_state.reviewed_by is distinct from v_actor
      then 'second_verification_approved'
    else 'verification_approved'
  end;
  select task.id into v_task_id
  from public.content_review_tasks task
  where task.governance_state_id = v_state.id
    and task.resolved_at is null
    and task.state in ('assigned', 'in_review', 'needs_review')
  order by task.created_at
  limit 1;
  insert into public.content_review_events (
    id, governance_state_id, task_id, event_type, from_state, to_state, actor_id,
    actor_type, triggering_governance_version, idempotency_key, reason, evidence
  ) values (
    v_event_id, v_state.id, v_task_id, v_event_type, v_state.review_state, 'approved',
    v_actor, 'human', v_state.version, p_idempotency_key,
    coalesce(nullif(btrim(p_change_notes), ''), 'Human verification completed.'),
    jsonb_build_object(
      'sourceOpenedAt', v_state.source_opened_at,
      'sourceURL', v_state.official_source_url,
      'sourceIsOfficial', v_state.source_is_official
    )
  );

  perform set_config('younew.human_review_event_id', v_event_id::text, true);
  perform set_config('younew.transformation_identifier', 'verify_content_now:v1', true);
  update public.content_governance_state state
  set verification_status = 'verified',
      review_state = 'approved',
      last_verified_at = now(),
      next_review_at = now() + make_interval(days => state.review_interval_days),
      reviewed_by = case
        when state.reviewed_by is null or state.reviewed_by = v_actor then v_actor
        else state.reviewed_by
      end,
      second_reviewed_by = case
        when state.reviewed_by is not null and state.reviewed_by is distinct from v_actor then v_actor
        else state.second_reviewed_by
      end,
      change_notes = p_change_notes
  where state.id = v_state.id
  returning state.* into v_state;

  if v_task_id is not null then
    update public.content_review_tasks
    set state = 'approved',
        started_at = coalesce(started_at, now()),
        updated_at = now()
    where id = v_task_id;
  end if;

  insert into public.governance_action_receipts (
    actor_id, action, idempotency_key, governance_state_id, result_version
  ) values (
    v_actor, 'verify_content_now', p_idempotency_key, v_state.id, v_state.version
  );
  return v_state;
end;
$$;

create or replace function public.approve_content_publication(
  p_record_key text,
  p_expected_version integer,
  p_idempotency_key text,
  p_reason text
)
returns public.content_governance_state
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_role text := coalesce(public.current_admin_role()::text, '');
  v_state public.content_governance_state;
  v_event_id uuid := gen_random_uuid();
  v_task_id uuid;
begin
  if v_actor is null or v_role not in ('owner', 'admin') then
    raise exception using errcode = '42501', message = 'publication_role_required';
  end if;
  if char_length(coalesce(p_idempotency_key, '')) < 8 then
    raise exception using errcode = '22023', message = 'idempotency_key_required';
  end if;
  select state.* into v_state
  from public.content_governance_state state
  where state.record_key = p_record_key
  for update;
  if not found then
    raise exception using errcode = 'P0002', message = 'governance_record_not_found';
  end if;
  if exists (
    select 1 from public.governance_action_receipts receipt
    where receipt.actor_id = v_actor
      and receipt.action = 'approve_content_publication'
      and receipt.idempotency_key = p_idempotency_key
      and receipt.governance_state_id = v_state.id
  ) then
    return v_state;
  end if;
  if v_state.version <> p_expected_version then
    raise exception using errcode = '40001', message = 'optimistic_version_conflict';
  end if;
  if public.governance_effective_status(
    v_state.verification_status, v_state.publication_status,
    v_state.official_source_url, v_state.last_verified_at, v_state.next_review_at,
    v_state.validity_start, v_state.validity_end, v_state.review_interval_days, now()
  ) not in ('verified', 'review_due_soon') or v_state.review_state <> 'approved' then
    raise exception using errcode = '23514', message = 'verified_human_approval_required';
  end if;
  if not exists (
    select 1 from public.content_review_events event
    where event.governance_state_id = v_state.id
      and event.event_type in ('verification_approved', 'second_verification_approved')
      and event.actor_type = 'human'
      and event.actor_id is not null
  ) then
    raise exception using errcode = '23514', message = 'human_review_event_required';
  end if;

  select task.id into v_task_id
  from public.content_review_tasks task
  where task.governance_state_id = v_state.id
    and task.state = 'approved'
    and task.resolved_at is null
  order by task.created_at
  limit 1;
  insert into public.content_review_events (
    id, governance_state_id, task_id, event_type, from_state, to_state, actor_id,
    actor_type, triggering_governance_version, idempotency_key, reason
  ) values (
    v_event_id, v_state.id, v_task_id, 'publication_approved', v_state.review_state,
    'monitoring', v_actor, 'human', v_state.version, p_idempotency_key,
    coalesce(nullif(btrim(p_reason), ''), 'Human publication approval.')
  );
  perform set_config('younew.human_review_event_id', v_event_id::text, true);
  perform set_config('younew.transformation_identifier', 'approve_content_publication:v1', true);
  update public.content_governance_state state
  set publication_status = 'published',
      review_state = 'monitoring',
      change_notes = p_reason
  where state.id = v_state.id
  returning state.* into v_state;

  if v_task_id is not null then
    update public.content_review_tasks
    set state = 'closed',
        resolved_at = now(),
        resolution = coalesce(nullif(btrim(p_reason), ''), 'Published after human approval.'),
        updated_at = now()
    where id = v_task_id;
  end if;

  insert into public.governance_action_receipts (
    actor_id, action, idempotency_key, governance_state_id, result_version
  ) values (
    v_actor, 'approve_content_publication', p_idempotency_key,
    v_state.id, v_state.version
  );
  return v_state;
end;
$$;

create or replace function public.record_source_check_attempt(
  p_record_key text,
  p_checked_url text,
  p_outcome text,
  p_http_status integer,
  p_error_class text,
  p_latency_ms integer,
  p_checker_version text,
  p_artifact_digest text,
  p_checked_at timestamptz
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_state public.content_governance_state;
  v_attempt_id uuid := gen_random_uuid();
  v_recent text[];
  v_hard_count integer;
  v_hard_min timestamptz;
  v_hard_max timestamptz;
  v_event_id uuid;
begin
  select state.* into v_state
  from public.content_governance_state state
  where state.record_key = p_record_key
  for update;
  if not found then
    raise exception using errcode = 'P0002', message = 'governance_record_not_found';
  end if;
  if p_checked_url is distinct from v_state.official_source_url then
    raise exception using errcode = '22023', message = 'source_url_mismatch';
  end if;

  insert into public.source_check_attempts (
    id, governance_state_id, checked_url, outcome, http_status, error_class,
    latency_ms, checker_version, artifact_digest, checked_at
  ) values (
    v_attempt_id, v_state.id, p_checked_url, p_outcome, p_http_status,
    p_error_class, p_latency_ms, p_checker_version, p_artifact_digest, p_checked_at
  );

  if p_outcome in ('reachable', 'redirected') then
    perform set_config('younew.transformation_identifier', 'source_check_success:v1', true);
    update public.content_governance_state
    set source_opened_at = p_checked_at
    where id = v_state.id;
    return v_attempt_id;
  end if;

  select array_agg(attempt.outcome order by attempt.checked_at desc)
  into v_recent
  from (
    select outcome, checked_at
    from public.source_check_attempts
    where governance_state_id = v_state.id
    order by checked_at desc
    limit 2
  ) attempt;
  if cardinality(v_recent) = 2
     and not ('reachable' = any(v_recent) or 'redirected' = any(v_recent)) then
    insert into public.content_review_tasks (
      governance_state_id, reason, severity, state, sla_due_at,
      triggering_governance_version, source_issue_id
    ) values (
      v_state.id,
      'source_issue',
      case when v_state.criticality = 'critical' then 'critical' else 'high' end,
      'needs_review',
      now() + case
        when v_state.criticality = 'critical' then interval '1 day'
        else interval '3 days'
      end,
      v_state.version,
      v_attempt_id
    )
    on conflict (governance_state_id, reason) where resolved_at is null do nothing;
  end if;

  select count(*), min(attempt.checked_at), max(attempt.checked_at)
  into v_hard_count, v_hard_min, v_hard_max
  from (
    select outcome, checked_at
    from public.source_check_attempts
    where governance_state_id = v_state.id
    order by checked_at desc
    limit 3
  ) attempt
  where attempt.outcome in ('hard_failure', 'invalid_tls');

  if v_hard_count = 3 and v_hard_max - v_hard_min >= interval '24 hours'
     and v_state.verification_status <> 'source_unavailable' then
    v_event_id := gen_random_uuid();
    insert into public.content_review_events (
      id, governance_state_id, event_type, from_state, to_state, actor_id,
      actor_type, triggering_governance_version, reason, evidence
    ) values (
      v_event_id, v_state.id, 'source_unavailable', v_state.review_state,
      'needs_review', null, 'system', v_state.version,
      'Three consecutive hard failures spanning at least 24 hours.',
      jsonb_build_object('latestAttemptId', v_attempt_id)
    );
    perform set_config('younew.human_review_event_id', v_event_id::text, true);
    perform set_config('younew.transformation_identifier', 'source_unavailable_threshold:v1', true);
    update public.content_governance_state
    set verification_status = 'source_unavailable',
        review_state = 'needs_review'
    where id = v_state.id;
  end if;
  return v_attempt_id;
end;
$$;

create or replace function public.set_governance_owner_and_interval(
  p_record_keys text[],
  p_owner_id uuid,
  p_review_interval_days integer,
  p_reason text
)
returns integer
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_role text := coalesce(public.current_admin_role()::text, '');
  v_count integer;
begin
  if auth.uid() is null or v_role not in ('owner', 'admin') then
    raise exception using errcode = '42501', message = 'policy_override_role_required';
  end if;
  if p_review_interval_days not between 1 and 730 then
    raise exception using errcode = '22023', message = 'invalid_review_interval';
  end if;
  if p_owner_id is not null and not exists (
    select 1 from public.profiles
    where id = p_owner_id and is_approved = true
  ) then
    raise exception using errcode = '22023', message = 'active_owner_required';
  end if;
  perform set_config('younew.transformation_identifier', 'bulk_owner_interval:v1', true);
  update public.content_governance_state
  set content_owner_id = p_owner_id,
      review_interval_days = p_review_interval_days,
      change_notes = p_reason
  where record_key = any(p_record_keys);
  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

create or replace function public.transition_content_review_task(
  p_task_id uuid,
  p_expected_state public.governance_review_state,
  p_to_state public.governance_review_state,
  p_owner_id uuid,
  p_idempotency_key text,
  p_reason text
)
returns public.content_review_tasks
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_role text := coalesce(public.current_admin_role()::text, '');
  v_task public.content_review_tasks;
  v_state public.content_governance_state;
  v_event_id uuid := gen_random_uuid();
  v_event_type text;
begin
  if v_actor is null or v_role not in ('owner', 'admin', 'editor', 'qa') then
    raise exception using errcode = '42501', message = 'review_role_required';
  end if;
  if char_length(coalesce(p_idempotency_key, '')) < 8 then
    raise exception using errcode = '22023', message = 'idempotency_key_required';
  end if;
  if p_to_state in ('approved', 'closed') and v_role not in ('owner', 'admin', 'qa') then
    raise exception using errcode = '42501', message = 'review_approval_role_required';
  end if;
  if not (
    (p_expected_state = 'needs_review' and p_to_state = 'assigned')
    or (p_expected_state = 'assigned' and p_to_state = 'in_review')
    or (p_expected_state = 'in_review' and p_to_state = 'approved')
    or (p_expected_state = 'approved' and p_to_state = 'closed')
    or (p_expected_state = 'monitoring' and p_to_state = 'expired')
    or (p_expected_state = 'expired' and p_to_state = 'needs_review')
  ) then
    raise exception using errcode = '22023', message = 'invalid_review_transition';
  end if;

  select task.* into v_task
  from public.content_review_tasks task
  where task.id = p_task_id
  for update;
  if not found then
    raise exception using errcode = 'P0002', message = 'review_task_not_found';
  end if;
  if exists (
    select 1 from public.content_review_events event
    where event.task_id = v_task.id
      and event.actor_id = v_actor
      and event.idempotency_key = p_idempotency_key
  ) then
    return v_task;
  end if;
  if v_task.state <> p_expected_state then
    raise exception using errcode = '40001', message = 'review_state_conflict';
  end if;
  if p_to_state = 'assigned' and p_owner_id is null then
    raise exception using errcode = '22023', message = 'review_owner_required';
  end if;
  if p_owner_id is not null and not exists (
    select 1 from public.profiles reviewer
    where reviewer.id = p_owner_id
      and reviewer.is_approved = true
      and reviewer.role in ('owner', 'admin', 'editor', 'qa')
  ) then
    raise exception using errcode = '22023', message = 'active_review_owner_required';
  end if;

  select state.* into v_state
  from public.content_governance_state state
  where state.id = v_task.governance_state_id
  for update;
  v_event_type := case p_to_state
    when 'assigned' then 'assigned'
    when 'in_review' then 'review_started'
    when 'approved' then 'review_approved'
    when 'monitoring' then 'monitoring_started'
    when 'expired' then 'expired'
    when 'needs_review' then 'needs_review'
    when 'closed' then 'closed'
  end;

  insert into public.content_review_events (
    id, governance_state_id, task_id, event_type, from_state, to_state,
    actor_id, actor_type, triggering_governance_version, idempotency_key, reason
  ) values (
    v_event_id, v_state.id, v_task.id, v_event_type, p_expected_state,
    p_to_state, v_actor, 'human', v_state.version, p_idempotency_key,
    coalesce(nullif(btrim(p_reason), ''), 'Review workflow transition.')
  );

  update public.content_review_tasks task
  set state = p_to_state,
      owner_id = coalesce(p_owner_id, task.owner_id),
      assigned_at = case when p_to_state = 'assigned' then now() else task.assigned_at end,
      started_at = case when p_to_state = 'in_review' then now() else task.started_at end,
      resolved_at = case when p_to_state = 'closed' then now() else task.resolved_at end,
      resolution = case when p_to_state = 'closed' then p_reason else task.resolution end,
      updated_at = now()
  where task.id = v_task.id
  returning task.* into v_task;

  perform set_config('younew.human_review_event_id', v_event_id::text, true);
  perform set_config('younew.transformation_identifier', 'transition_review_task:v1', true);
  update public.content_governance_state
  set review_state = p_to_state
  where id = v_state.id;
  return v_task;
end;
$$;

create or replace function public.record_research_observation(
  p_research_session_id uuid,
  p_journey text,
  p_completed boolean,
  p_source_opened boolean,
  p_wrong_turns integer,
  p_external_searches integer,
  p_human_help boolean,
  p_critical_error boolean,
  p_duration_seconds integer,
  p_safety_stop boolean,
  p_observed_at timestamptz
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_role text := coalesce(public.current_admin_role()::text, '');
  v_id uuid := gen_random_uuid();
begin
  if v_actor is null or v_role not in ('owner', 'admin', 'qa') then
    raise exception using errcode = '42501', message = 'researcher_role_required';
  end if;
  if not coalesce((
    select enabled from public.governance_feature_flags where key = 'research_ingestion'
  ), false) then
    raise exception using errcode = '55000', message = 'research_ingestion_disabled';
  end if;
  if not exists (
    select 1 from public.research_consents
    where research_session_id = p_research_session_id
      and revoked_at is null
      and consented_at <= p_observed_at
  ) then
    raise exception using errcode = '23514', message = 'active_research_consent_required';
  end if;
  insert into public.research_observations (
    id, research_session_id, journey, completed, source_opened, wrong_turns,
    external_searches, human_help, critical_error, duration_seconds,
    safety_stop, observed_at, recorded_by
  ) values (
    v_id, p_research_session_id, p_journey, p_completed, p_source_opened,
    p_wrong_turns, p_external_searches, p_human_help, p_critical_error,
    p_duration_seconds, p_safety_stop, p_observed_at, v_actor
  );
  return v_id;
end;
$$;

create or replace function public.purge_expired_research_observations()
returns integer
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_count integer;
begin
  if auth.uid() is not null
     and coalesce(public.current_admin_role()::text, '') <> 'owner' then
    raise exception using errcode = '42501', message = 'research_purge_role_required';
  end if;
  delete from public.research_observations where expires_at <= now();
  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

create or replace view public.content_governance_effective
with (security_invoker = true)
as
select
  state.*,
  effective.status as effective_verification_status,
  dynamic_confidence.breakdown as effective_confidence_breakdown,
  public.governance_confidence_score(dynamic_confidence.breakdown) as effective_confidence_score,
  case
    when effective.status in ('archived', 'disputed', 'source_unavailable', 'unverified') then 'excluded'
    when effective.status = 'overdue' then 'secondary_only'
    else 'primary'
  end as ai_eligibility
from public.content_governance_state state
cross join lateral (
  select public.governance_effective_status(
    state.verification_status, state.publication_status,
    state.official_source_url, state.last_verified_at, state.next_review_at,
    state.validity_start, state.validity_end, state.review_interval_days, now()
  ) as status
) effective
cross join lateral (
  select public.governance_confidence_breakdown(
    state.source_is_official, state.source_opened_at, state.reviewed_by,
    state.second_reviewed_by, effective.status, state.jurisdiction
  ) as breakdown
) dynamic_confidence;

create or replace view public.content_governance_health_summary
with (security_invoker = true)
as
select
  1 as formula_version,
  now() as generated_at,
  count(*) as denominator,
  count(*) filter (where effective_verification_status = 'verified') as verified,
  count(*) filter (where effective_verification_status = 'review_due_soon') as review_due_soon,
  count(*) filter (where effective_verification_status = 'overdue') as overdue,
  count(*) filter (where effective_verification_status = 'disputed') as disputed,
  count(*) filter (where effective_verification_status = 'source_unavailable') as source_unavailable,
  count(*) filter (where publication_status = 'published') as published,
  round(avg(effective_confidence_score), 2) as average_confidence,
  percentile_cont(0.5) within group (order by effective_confidence_score) as median_confidence,
  round(avg(extract(epoch from (now() - last_verified_at)) / 86400.0)
    filter (where last_verified_at is not null), 2) as average_freshness_age_days,
  (
    select count(*) from public.content_review_tasks task
    where task.resolved_at is null
  ) as review_queue,
  (
    select count(*) from public.content_review_tasks task
    where task.resolved_at is null and task.sla_due_at < now()
  ) as review_sla_breaches
from public.content_governance_effective;

create or replace view public.content_governance_top_risks
with (security_invoker = true)
as
select *
from (
  select
    state.record_key,
    state.title,
    case
      when state.criticality = 'critical'
        and state.effective_verification_status in ('disputed', 'source_unavailable') then 1
      when state.criticality = 'critical'
        and state.effective_verification_status = 'overdue' then 2
      when state.criticality = 'critical'
        and state.jurisdiction ->> 'applicabilityVerified' <> 'true' then 3
      when exists (
        select 1 from public.content_review_tasks task
        where task.governance_state_id = state.id
          and task.resolved_at is null and task.sla_due_at < now()
      ) then 4
      when (
        select count(*) from public.source_check_attempts attempt
        where attempt.governance_state_id = state.id
          and attempt.outcome in ('hard_failure', 'invalid_tls')
      ) >= 2 then 5
      when exists (
        select 1 from public.content_review_tasks task
        where task.governance_state_id = state.id
          and task.reason = 'possible_duplicate' and task.resolved_at is null
      ) then 6
      else null
    end as risk_priority,
    state.effective_verification_status,
    state.criticality,
    state.version
  from public.content_governance_effective state
) ranked
where risk_priority is not null
order by risk_priority, record_key;

-- Legacy rows are deliberately backfilled as migrated/draft/unverified.
-- Existing article fields are retained as provenance but are not promoted to
-- verification evidence without a new human review event.
insert into public.content_governance_state (
  record_key, content_id, article_id, title, content_type, jurisdiction,
  official_source_url, source_title, source_is_official,
  review_interval_days, content_owner_id, verification_status,
  publication_status, review_state, criticality, content_origin,
  origin_reference, origin_captured_at, origin_artifact_digest, change_notes
)
select
  'article:' || article.id::text,
  article.slug,
  article.id,
  article.title,
  'article',
  jsonb_build_object(
    'countryCode', 'NL',
    'level', case when article.city is null then 'mixed' else 'municipal' end,
    'municipalityDependent', true,
    'applicabilityVerified', false,
    'provinceCode', null,
    'provinceName', article.province,
    'municipalityCode', null,
    'municipalityName', article.city
  ),
  case when article.source_url ~ '^https://' then article.source_url else null end,
  null,
  article.official_source,
  90,
  article.author_id,
  'unverified',
  'draft',
  'needs_review',
  'standard',
  'migrated',
  'supabase:articles/' || article.id::text,
  article.created_at,
  'sha256:' || encode(digest(convert_to(jsonb_build_object(
    'id', article.id,
    'slug', article.slug,
    'title', article.title,
    'source_url', article.source_url,
    'created_at', article.created_at
  )::text, 'UTF8'), 'sha256'), 'hex'),
  'Legacy backfill: verification evidence intentionally not inferred.'
from public.articles article
on conflict (record_key) do nothing;

alter table public.content_governance_state enable row level security;
alter table public.content_governance_versions enable row level security;
alter table public.source_check_attempts enable row level security;
alter table public.content_review_tasks enable row level security;
alter table public.content_review_events enable row level security;
alter table public.governance_action_receipts enable row level security;
alter table public.governance_feature_flags enable row level security;
alter table public.research_consents enable row level security;
alter table public.research_observations enable row level security;

create policy "approved admins read governance state"
on public.content_governance_state for select to authenticated
using (public.is_approved_admin());
create policy "approved admins read governance versions"
on public.content_governance_versions for select to authenticated
using (public.is_approved_admin());
create policy "approved admins read source checks"
on public.source_check_attempts for select to authenticated
using (public.is_approved_admin());
create policy "approved admins read review tasks"
on public.content_review_tasks for select to authenticated
using (public.is_approved_admin());
create policy "approved admins read review events"
on public.content_review_events for select to authenticated
using (public.is_approved_admin());
create policy "owners and admins manage governance flags"
on public.governance_feature_flags for all to authenticated
using (public.current_admin_role() in ('owner', 'admin'))
with check (public.current_admin_role() in ('owner', 'admin'));
create policy "approved admins read governance flags"
on public.governance_feature_flags for select to authenticated
using (public.is_approved_admin());
create policy "approved researchers read research consent"
on public.research_consents for select to authenticated
using (public.current_admin_role() in ('owner', 'admin', 'qa'));
create policy "approved researchers manage research consent"
on public.research_consents for insert to authenticated
with check (
  public.current_admin_role() in ('owner', 'admin', 'qa')
  and created_by = auth.uid()
);
create policy "approved researchers read observations"
on public.research_observations for select to authenticated
using (public.current_admin_role() in ('owner', 'admin', 'qa'));

revoke all on table public.content_governance_state from public, anon, authenticated;
revoke all on table public.content_governance_versions from public, anon, authenticated;
revoke all on table public.source_check_attempts from public, anon, authenticated;
revoke all on table public.content_review_tasks from public, anon, authenticated;
revoke all on table public.content_review_events from public, anon, authenticated;
revoke all on table public.governance_action_receipts from public, anon, authenticated;
revoke all on table public.governance_feature_flags from public, anon, authenticated;
revoke all on table public.research_consents from public, anon, authenticated;
revoke all on table public.research_observations from public, anon, authenticated;

grant select on table public.content_governance_state to authenticated;
grant select on table public.content_governance_versions to authenticated;
grant select on table public.source_check_attempts to authenticated;
grant select on table public.content_review_tasks to authenticated;
grant select on table public.content_review_events to authenticated;
grant select on table public.governance_feature_flags to authenticated;
grant select, insert on table public.research_consents to authenticated;
grant select on table public.research_observations to authenticated;

grant all on table public.content_governance_state to service_role;
grant all on table public.content_governance_versions to service_role;
grant all on table public.source_check_attempts to service_role;
grant all on table public.content_review_tasks to service_role;
grant all on table public.content_review_events to service_role;
grant all on table public.governance_action_receipts to service_role;
grant all on table public.governance_feature_flags to service_role;
grant all on table public.research_consents to service_role;
grant all on table public.research_observations to service_role;

revoke all on function public.enforce_content_governance_state() from public, anon, authenticated;
revoke all on function public.append_content_governance_version() from public, anon, authenticated;
revoke all on function public.enforce_content_review_event() from public, anon, authenticated;
revoke all on function public.reject_immutable_governance_change() from public, anon, authenticated;
revoke all on function public.verify_content_now(text, integer, text, text) from public, anon, authenticated, service_role;
revoke all on function public.approve_content_publication(text, integer, text, text) from public, anon, authenticated, service_role;
revoke all on function public.record_source_check_attempt(text, text, text, integer, text, integer, text, text, timestamptz) from public, anon, authenticated, service_role;
revoke all on function public.set_governance_owner_and_interval(text[], uuid, integer, text) from public, anon, authenticated, service_role;
revoke all on function public.transition_content_review_task(uuid, public.governance_review_state, public.governance_review_state, uuid, text, text) from public, anon, authenticated, service_role;
revoke all on function public.record_research_observation(uuid, text, boolean, boolean, integer, integer, boolean, boolean, integer, boolean, timestamptz) from public, anon, authenticated, service_role;
revoke all on function public.purge_expired_research_observations() from public, anon, authenticated;

grant execute on function public.governance_review_due_lead_days(integer) to authenticated, service_role;
grant execute on function public.governance_effective_status(public.governance_verification_status, public.governance_publication_status, text, timestamptz, timestamptz, timestamptz, timestamptz, integer, timestamptz) to authenticated, service_role;
grant execute on function public.governance_confidence_breakdown(boolean, timestamptz, uuid, uuid, public.governance_verification_status, jsonb) to authenticated, service_role;
grant execute on function public.governance_confidence_score(jsonb) to authenticated, service_role;
grant execute on function public.verify_content_now(text, integer, text, text) to authenticated;
grant execute on function public.approve_content_publication(text, integer, text, text) to authenticated;
grant execute on function public.record_source_check_attempt(text, text, text, integer, text, integer, text, text, timestamptz) to service_role;
grant execute on function public.set_governance_owner_and_interval(text[], uuid, integer, text) to authenticated;
grant execute on function public.transition_content_review_task(uuid, public.governance_review_state, public.governance_review_state, uuid, text, text) to authenticated;
grant execute on function public.record_research_observation(uuid, text, boolean, boolean, integer, integer, boolean, boolean, integer, boolean, timestamptz) to authenticated;
grant execute on function public.purge_expired_research_observations() to service_role;

grant select on table public.content_governance_effective to authenticated;
grant select on table public.content_governance_health_summary to authenticated;
grant select on table public.content_governance_top_risks to authenticated;
grant insert, update, delete on table public.governance_feature_flags to authenticated;

comment on table public.content_governance_state is
  'Operational projection only. DataProject remains the canonical content source.';
comment on column public.content_governance_state.confidence_score is
  'Versioned evidence coverage index; never a probability of truth.';
comment on table public.content_governance_versions is
  'Append-only state history. Updates and deletes are rejected.';
comment on table public.content_review_events is
  'Append-only human/system transition evidence. AI is not an allowed actor type.';
comment on table public.research_observations is
  'Purpose-limited, consented research metrics with no BSN, contact, form text, IP or user-agent fields.';
