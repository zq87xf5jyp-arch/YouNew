-- Configurable retention and privacy-safe B2B usage reporting.
-- This migration never touches contracts, invoices, accounting records or
-- other legally retained documents. Those remain outside this mechanism.

create extension if not exists pg_cron;

create table private.retention_policies (
  policy_key text primary key,
  retention_days integer not null,
  minimum_days integer not null,
  maximum_days integer not null,
  storage_scope text not null,
  description text not null,
  updated_at timestamptz not null default statement_timestamp(),
  constraint retention_policies_key_check check (
    policy_key in (
      'unfinished_applications',
      'unconfirmed_spam_leads',
      'lost_archived_leads',
      'admin_notifications',
      'raw_usage_events',
      'anonymized_aggregate_reports',
      'temporary_csv_exports',
      'technical_logs_no_pii'
    )
  ),
  constraint retention_policies_days_check check (
    minimum_days > 0
    and maximum_days >= minimum_days
    and retention_days between minimum_days and maximum_days
  ),
  constraint retention_policies_scope_check check (
    storage_scope in ('database', 'not_persisted', 'external_provider')
  )
);

insert into private.retention_policies (
  policy_key,
  retention_days,
  minimum_days,
  maximum_days,
  storage_scope,
  description
) values
  ('unfinished_applications', 30, 7, 90, 'database',
    'Submitted lead rows explicitly classified as unfinished; browser drafts are not persisted.'),
  ('unconfirmed_spam_leads', 90, 30, 365, 'database',
    'Submitted lead rows explicitly classified as unconfirmed or spam.'),
  ('lost_archived_leads', 365, 90, 2555, 'database',
    'Lost or archived leads that are not contract or accounting records.'),
  ('admin_notifications', 90, 30, 365, 'database',
    'PII-minimised internal lead notifications.'),
  ('raw_usage_events', 90, 30, 180, 'database',
    'Consent-gated raw application and pilot usage events and sessions.'),
  ('anonymized_aggregate_reports', 730, 365, 2555, 'database',
    'Persisted aggregate pilot report snapshots with no individual identifiers.'),
  ('temporary_csv_exports', 30, 1, 90, 'not_persisted',
    'Admin CSV responses are streamed and not retained by the application.'),
  ('technical_logs_no_pii', 30, 7, 90, 'external_provider',
    'Infrastructure logs must remain PII-free and use the provider retention control.');

create table private.retention_legal_holds (
  resource_type text not null,
  resource_id uuid not null,
  reason_code text not null,
  hold_until timestamptz not null,
  released_at timestamptz,
  created_at timestamptz not null default statement_timestamp(),
  primary key (resource_type, resource_id),
  constraint retention_legal_holds_type_check check (
    resource_type in (
      'business_inquiry',
      'business_inquiry_notification',
      'app_event',
      'app_session',
      'pilot_usage_event',
      'pilot_usage_report'
    )
  ),
  constraint retention_legal_holds_reason_check check (
    reason_code in (
      'litigation',
      'regulatory',
      'security_incident',
      'data_subject_request',
      'contractual'
    )
  ),
  constraint retention_legal_holds_dates_check check (
    hold_until > created_at
    and (released_at is null or released_at >= created_at)
  )
);

create table private.retention_cleanup_runs (
  id uuid primary key default gen_random_uuid(),
  dry_run boolean not null,
  reference_at timestamptz not null,
  status text not null default 'running' check (status in ('running', 'completed')),
  started_at timestamptz not null default statement_timestamp(),
  completed_at timestamptz,
  constraint retention_cleanup_runs_completion_check check (
    (status = 'running' and completed_at is null)
    or (status = 'completed' and completed_at is not null)
  )
);

create table private.retention_cleanup_audit (
  id bigint generated always as identity primary key,
  run_id uuid not null references private.retention_cleanup_runs(id) on delete cascade,
  policy_key text not null references private.retention_policies(policy_key),
  cutoff_at timestamptz not null,
  eligible_count bigint not null check (eligible_count >= 0),
  deleted_count bigint not null check (deleted_count >= 0),
  created_at timestamptz not null default statement_timestamp(),
  constraint retention_cleanup_audit_does_not_identify_rows unique (run_id, policy_key)
);

comment on table private.retention_cleanup_audit is
  'Deletion evidence stores policy, cutoff and counts only. It never stores deleted row IDs, contact details, messages or other submitted PII.';

alter table public.business_inquiries
  add column retention_class text not null default 'active',
  add constraint business_inquiries_retention_class_check check (
    retention_class in (
      'active', 'unfinished', 'unconfirmed', 'spam', 'contract_record'
    )
  ),
  add constraint business_inquiries_contract_retention_check check (
    status <> 'won' or retention_class in ('active', 'contract_record')
  );

comment on column public.business_inquiries.retention_class is
  'Operational classification for the configurable cleanup policy. contract_record and won rows are never deleted by retention cleanup.';

create table private.pilot_usage_events (
  id uuid primary key default gen_random_uuid(),
  client_scope_id uuid not null,
  subject_token_hash text not null check (subject_token_hash ~ '^[a-f0-9]{64}$'),
  event_name text not null check (
    event_name in (
      'route_opened',
      'step_completed',
      'official_source_opened',
      'search_used'
    )
  ),
  occurred_at timestamptz not null,
  consent_version text not null check (char_length(consent_version) between 1 and 40),
  consent_granted boolean not null check (consent_granted),
  is_sample boolean not null default false,
  created_at timestamptz not null default statement_timestamp()
);

comment on table private.pilot_usage_events is
  'Service-only consented pilot telemetry. No email, name, phone, IP, user ID, free text, partner status or sponsor status is accepted.';

create index pilot_usage_events_scope_period_idx
  on private.pilot_usage_events (client_scope_id, is_sample, occurred_at, event_name);
create index pilot_usage_events_created_at_idx
  on private.pilot_usage_events (created_at);

create table private.pilot_usage_reports (
  id uuid primary key default gen_random_uuid(),
  client_scope_id uuid not null,
  period_start date not null,
  period_end date not null,
  data_label text not null check (data_label in ('aggregate data', 'sample data')),
  minimum_cohort integer not null default 5 check (minimum_cohort = 5),
  suppressed_segment_count bigint not null default 0 check (suppressed_segment_count >= 0),
  generated_at timestamptz not null default statement_timestamp(),
  expires_at timestamptz not null,
  constraint pilot_usage_reports_period_check check (
    period_end >= period_start and period_end - period_start <= 92
  )
);

create table private.pilot_usage_report_segments (
  report_id uuid not null references private.pilot_usage_reports(id) on delete cascade,
  metric_date date not null,
  event_name text not null check (
    event_name in (
      'route_opened',
      'step_completed',
      'official_source_opened',
      'search_used'
    )
  ),
  event_count bigint not null check (event_count >= 5),
  participant_count bigint not null check (participant_count >= 5),
  primary key (report_id, metric_date, event_name)
);

comment on table private.pilot_usage_reports is
  'One client-scoped aggregate report header. client_scope_id is never included in the exported report payload.';
comment on table private.pilot_usage_report_segments is
  'Aggregate-only report segments. Small cohorts are omitted and only their total number is recorded.';

create index pilot_usage_reports_expiry_idx
  on private.pilot_usage_reports (expires_at);

alter table private.retention_policies enable row level security;
alter table private.retention_legal_holds enable row level security;
alter table private.retention_cleanup_runs enable row level security;
alter table private.retention_cleanup_audit enable row level security;
alter table private.pilot_usage_events enable row level security;
alter table private.pilot_usage_reports enable row level security;
alter table private.pilot_usage_report_segments enable row level security;

revoke all on table private.retention_policies from public, anon, authenticated;
revoke all on table private.retention_legal_holds from public, anon, authenticated;
revoke all on table private.retention_cleanup_runs from public, anon, authenticated;
revoke all on table private.retention_cleanup_audit from public, anon, authenticated;
revoke all on table private.pilot_usage_events from public, anon, authenticated;
revoke all on table private.pilot_usage_reports from public, anon, authenticated;
revoke all on table private.pilot_usage_report_segments from public, anon, authenticated;

grant usage on schema private to service_role;
grant select on table private.retention_policies to service_role;
grant all on table private.retention_legal_holds to service_role;
grant select on table private.retention_cleanup_runs to service_role;
grant select on table private.retention_cleanup_audit to service_role;
grant all on table private.pilot_usage_events to service_role;
grant all on table private.pilot_usage_reports to service_role;
grant all on table private.pilot_usage_report_segments to service_role;
grant usage, select on sequence private.retention_cleanup_audit_id_seq to service_role;

create or replace function private.retention_hold_active(
  p_resource_type text,
  p_resource_id uuid,
  p_reference_at timestamptz
)
returns boolean
language sql
stable
security invoker
set search_path = ''
as $function$
  select exists (
    select 1
    from private.retention_legal_holds
    where resource_type = p_resource_type
      and resource_id = p_resource_id
      and released_at is null
      and hold_until > p_reference_at
  )
$function$;

create or replace function private.set_retention_days(
  p_policy_key text,
  p_retention_days integer
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
begin
  update private.retention_policies
  set retention_days = p_retention_days,
      updated_at = statement_timestamp()
  where policy_key = p_policy_key;

  if not found then
    raise exception 'unknown_retention_policy' using errcode = '22023';
  end if;
end
$function$;

create or replace function public.generate_pilot_usage_report(
  p_client_scope_id uuid,
  p_period_start date,
  p_period_end date,
  p_sample_data boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_report_id uuid := gen_random_uuid();
  v_retention_days integer;
  v_suppressed bigint;
begin
  if p_client_scope_id is null
    or p_period_start is null
    or p_period_end is null
    or p_period_end < p_period_start
    or p_period_end - p_period_start > 92 then
    raise exception 'invalid_report_scope' using errcode = '22023';
  end if;

  select retention_days
  into strict v_retention_days
  from private.retention_policies
  where policy_key = 'anonymized_aggregate_reports';

  insert into private.pilot_usage_reports (
    id,
    client_scope_id,
    period_start,
    period_end,
    data_label,
    expires_at
  ) values (
    v_report_id,
    p_client_scope_id,
    p_period_start,
    p_period_end,
    case when p_sample_data then 'sample data' else 'aggregate data' end,
    statement_timestamp() + make_interval(days => v_retention_days)
  );

  insert into private.pilot_usage_report_segments (
    report_id,
    metric_date,
    event_name,
    event_count,
    participant_count
  )
  select
    v_report_id,
    occurred_at::date,
    event_name,
    count(*)::bigint,
    count(distinct subject_token_hash)::bigint
  from private.pilot_usage_events
  where client_scope_id = p_client_scope_id
    and consent_granted
    and is_sample = p_sample_data
    and occurred_at >= p_period_start::timestamptz
    and occurred_at < (p_period_end + 1)::timestamptz
  group by occurred_at::date, event_name
  having count(*) >= 5
    and count(distinct subject_token_hash) >= 5;

  select count(*)
  into v_suppressed
  from (
    select occurred_at::date, event_name
    from private.pilot_usage_events
    where client_scope_id = p_client_scope_id
      and consent_granted
      and is_sample = p_sample_data
      and occurred_at >= p_period_start::timestamptz
      and occurred_at < (p_period_end + 1)::timestamptz
    group by occurred_at::date, event_name
    having count(*) < 5
      or count(distinct subject_token_hash) < 5
  ) as suppressed;

  update private.pilot_usage_reports
  set suppressed_segment_count = v_suppressed
  where id = v_report_id;

  return v_report_id;
end
$function$;

create or replace function public.export_pilot_usage_report(p_report_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_payload jsonb;
begin
  select jsonb_build_object(
    'schemaVersion', 1,
    'dataLabel', report.data_label,
    'sampleData', report.data_label = 'sample data',
    'periodStart', report.period_start,
    'periodEnd', report.period_end,
    'minimumCohort', report.minimum_cohort,
    'smallCohortsSuppressed', true,
    'suppressedSegmentCount', report.suppressed_segment_count,
    'generatedAt', report.generated_at,
    'segments', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'metricDate', segment.metric_date,
          'eventName', segment.event_name,
          'eventCount', segment.event_count,
          'participantCount', segment.participant_count
        )
        order by segment.metric_date, segment.event_name
      )
      from private.pilot_usage_report_segments as segment
      where segment.report_id = report.id
    ), '[]'::jsonb)
  )
  into v_payload
  from private.pilot_usage_reports as report
  where report.id = p_report_id
    and report.expires_at > statement_timestamp();

  if v_payload is null then
    raise exception 'report_not_available' using errcode = '22023';
  end if;

  return v_payload;
end
$function$;

revoke all on function private.retention_hold_active(text, uuid, timestamptz)
  from public, anon, authenticated;
revoke all on function private.set_retention_days(text, integer)
  from public, anon, authenticated;
revoke all on function public.generate_pilot_usage_report(uuid, date, date, boolean)
  from public, anon, authenticated;
revoke all on function public.export_pilot_usage_report(uuid)
  from public, anon, authenticated;

grant execute on function private.retention_hold_active(text, uuid, timestamptz)
  to service_role;
grant execute on function private.set_retention_days(text, integer)
  to service_role;
grant execute on function public.generate_pilot_usage_report(uuid, date, date, boolean)
  to service_role;
grant execute on function public.export_pilot_usage_report(uuid)
  to service_role;

drop trigger if exists prune_analytics_retention_before_insert on public.app_events;

create or replace function private.run_retention_cleanup(
  p_dry_run boolean default true,
  p_reference_at timestamptz default statement_timestamp()
)
returns table (
  retention_key text,
  cutoff_at timestamptz,
  eligible_count bigint,
  deleted_count bigint
)
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_run_id uuid := gen_random_uuid();
  v_days integer;
  v_cutoff timestamptz;
  v_eligible bigint;
  v_deleted bigint;
  v_candidate_ids uuid[];
begin
  if p_reference_at is null then
    raise exception 'reference_time_required' using errcode = '22023';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('younew.retention_cleanup', 0)
  );

  insert into private.retention_cleanup_runs (
    id, dry_run, reference_at
  ) values (
    v_run_id, p_dry_run, p_reference_at
  );

  -- Submitted rows explicitly classified as unfinished. Browser drafts are
  -- never persisted, so they cannot enter this table.
  select retention_days into strict v_days
  from private.retention_policies where policy_key = 'unfinished_applications';
  v_cutoff := p_reference_at - make_interval(days => v_days);
  select coalesce(pg_catalog.array_agg(inquiry.id), '{}'::uuid[])
  into v_candidate_ids
  from public.business_inquiries as inquiry
  where inquiry.retention_class = 'unfinished'
    and inquiry.status <> 'won'
    and inquiry.created_at < v_cutoff
    and not private.retention_hold_active('business_inquiry', inquiry.id, p_reference_at)
    and not exists (
      select 1 from public.business_inquiry_notifications as notification
      where notification.inquiry_id = inquiry.id
        and private.retention_hold_active(
          'business_inquiry_notification', notification.id, p_reference_at
        )
    );
  v_eligible := pg_catalog.cardinality(v_candidate_ids);
  v_deleted := 0;
  if not p_dry_run then
    delete from public.audit_logs
    where entity_type = 'business_inquiry'
      and entity_id in (
        select candidate.id::text
        from pg_catalog.unnest(v_candidate_ids) as candidate(id)
      );
    delete from public.business_inquiries
    where id = any(v_candidate_ids);
    get diagnostics v_deleted = row_count;
  end if;
  insert into private.retention_cleanup_audit
    (run_id, policy_key, cutoff_at, eligible_count, deleted_count)
  values (v_run_id, 'unfinished_applications', v_cutoff, v_eligible, v_deleted);
  retention_key := 'unfinished_applications'; cutoff_at := v_cutoff;
  eligible_count := v_eligible; deleted_count := v_deleted; return next;

  select retention_days into strict v_days
  from private.retention_policies where policy_key = 'unconfirmed_spam_leads';
  v_cutoff := p_reference_at - make_interval(days => v_days);
  select coalesce(pg_catalog.array_agg(inquiry.id), '{}'::uuid[])
  into v_candidate_ids
  from public.business_inquiries as inquiry
  where inquiry.retention_class in ('unconfirmed', 'spam')
    and inquiry.status <> 'won'
    and inquiry.created_at < v_cutoff
    and not private.retention_hold_active('business_inquiry', inquiry.id, p_reference_at)
    and not exists (
      select 1 from public.business_inquiry_notifications as notification
      where notification.inquiry_id = inquiry.id
        and private.retention_hold_active(
          'business_inquiry_notification', notification.id, p_reference_at
        )
    );
  v_eligible := pg_catalog.cardinality(v_candidate_ids);
  v_deleted := 0;
  if not p_dry_run then
    delete from public.audit_logs
    where entity_type = 'business_inquiry'
      and entity_id in (
        select candidate.id::text
        from pg_catalog.unnest(v_candidate_ids) as candidate(id)
      );
    delete from public.business_inquiries
    where id = any(v_candidate_ids);
    get diagnostics v_deleted = row_count;
  end if;
  insert into private.retention_cleanup_audit
    (run_id, policy_key, cutoff_at, eligible_count, deleted_count)
  values (v_run_id, 'unconfirmed_spam_leads', v_cutoff, v_eligible, v_deleted);
  retention_key := 'unconfirmed_spam_leads'; cutoff_at := v_cutoff;
  eligible_count := v_eligible; deleted_count := v_deleted; return next;

  select retention_days into strict v_days
  from private.retention_policies where policy_key = 'lost_archived_leads';
  v_cutoff := p_reference_at - make_interval(days => v_days);
  select coalesce(pg_catalog.array_agg(inquiry.id), '{}'::uuid[])
  into v_candidate_ids
  from public.business_inquiries as inquiry
  where inquiry.status in ('lost', 'archived')
    and inquiry.retention_class not in ('unfinished', 'unconfirmed', 'spam', 'contract_record')
    and inquiry.status_changed_at < v_cutoff
    and not private.retention_hold_active('business_inquiry', inquiry.id, p_reference_at)
    and not exists (
      select 1 from public.business_inquiry_notifications as notification
      where notification.inquiry_id = inquiry.id
        and private.retention_hold_active(
          'business_inquiry_notification', notification.id, p_reference_at
        )
    );
  v_eligible := pg_catalog.cardinality(v_candidate_ids);
  v_deleted := 0;
  if not p_dry_run then
    delete from public.audit_logs
    where entity_type = 'business_inquiry'
      and entity_id in (
        select candidate.id::text
        from pg_catalog.unnest(v_candidate_ids) as candidate(id)
      );
    delete from public.business_inquiries
    where id = any(v_candidate_ids);
    get diagnostics v_deleted = row_count;
  end if;
  insert into private.retention_cleanup_audit
    (run_id, policy_key, cutoff_at, eligible_count, deleted_count)
  values (v_run_id, 'lost_archived_leads', v_cutoff, v_eligible, v_deleted);
  retention_key := 'lost_archived_leads'; cutoff_at := v_cutoff;
  eligible_count := v_eligible; deleted_count := v_deleted; return next;

  select retention_days into strict v_days
  from private.retention_policies where policy_key = 'admin_notifications';
  v_cutoff := p_reference_at - make_interval(days => v_days);
  select count(*) into v_eligible
  from public.business_inquiry_notifications as notification
  where notification.created_at < v_cutoff
    and not private.retention_hold_active(
      'business_inquiry_notification', notification.id, p_reference_at
    )
    and not private.retention_hold_active(
      'business_inquiry', notification.inquiry_id, p_reference_at
    );
  v_deleted := 0;
  if not p_dry_run then
    delete from public.business_inquiry_notifications as notification
    where notification.created_at < v_cutoff
      and not private.retention_hold_active(
        'business_inquiry_notification', notification.id, p_reference_at
      )
      and not private.retention_hold_active(
        'business_inquiry', notification.inquiry_id, p_reference_at
      );
    get diagnostics v_deleted = row_count;
  end if;
  insert into private.retention_cleanup_audit
    (run_id, policy_key, cutoff_at, eligible_count, deleted_count)
  values (v_run_id, 'admin_notifications', v_cutoff, v_eligible, v_deleted);
  retention_key := 'admin_notifications'; cutoff_at := v_cutoff;
  eligible_count := v_eligible; deleted_count := v_deleted; return next;

  select retention_days into strict v_days
  from private.retention_policies where policy_key = 'raw_usage_events';
  v_cutoff := p_reference_at - make_interval(days => v_days);
  select
    (select count(*) from public.app_events as event
      where event.created_at < v_cutoff
        and not private.retention_hold_active('app_event', event.id, p_reference_at))
    +
    (select count(*) from public.app_sessions as session
      where session.created_at < v_cutoff
        and not private.retention_hold_active('app_session', session.id, p_reference_at))
    +
    (select count(*) from private.pilot_usage_events as event
      where event.created_at < v_cutoff
        and not private.retention_hold_active('pilot_usage_event', event.id, p_reference_at))
  into v_eligible;
  v_deleted := 0;
  if not p_dry_run then
    delete from public.app_events as event
    where event.created_at < v_cutoff
      and not private.retention_hold_active('app_event', event.id, p_reference_at);
    get diagnostics v_deleted = row_count;
    delete from public.app_sessions as session
    where session.created_at < v_cutoff
      and not private.retention_hold_active('app_session', session.id, p_reference_at);
    get diagnostics v_days = row_count;
    v_deleted := v_deleted + v_days;
    delete from private.pilot_usage_events as event
    where event.created_at < v_cutoff
      and not private.retention_hold_active('pilot_usage_event', event.id, p_reference_at);
    get diagnostics v_days = row_count;
    v_deleted := v_deleted + v_days;
  end if;
  insert into private.retention_cleanup_audit
    (run_id, policy_key, cutoff_at, eligible_count, deleted_count)
  values (v_run_id, 'raw_usage_events', v_cutoff, v_eligible, v_deleted);
  retention_key := 'raw_usage_events'; cutoff_at := v_cutoff;
  eligible_count := v_eligible; deleted_count := v_deleted; return next;

  select retention_days into strict v_days
  from private.retention_policies where policy_key = 'anonymized_aggregate_reports';
  v_cutoff := p_reference_at - make_interval(days => v_days);
  select count(*) into v_eligible
  from private.pilot_usage_reports as report
  where report.generated_at < v_cutoff
    and not private.retention_hold_active('pilot_usage_report', report.id, p_reference_at);
  v_deleted := 0;
  if not p_dry_run then
    delete from private.pilot_usage_reports as report
    where report.generated_at < v_cutoff
      and not private.retention_hold_active('pilot_usage_report', report.id, p_reference_at);
    get diagnostics v_deleted = row_count;
  end if;
  insert into private.retention_cleanup_audit
    (run_id, policy_key, cutoff_at, eligible_count, deleted_count)
  values (v_run_id, 'anonymized_aggregate_reports', v_cutoff, v_eligible, v_deleted);
  retention_key := 'anonymized_aggregate_reports'; cutoff_at := v_cutoff;
  eligible_count := v_eligible; deleted_count := v_deleted; return next;

  -- CSV responses are streamed, not stored; technical logs are managed at the
  -- provider. Record zero-count evidence so every configured policy is present
  -- in each run without pretending the database controls external retention.
  foreach retention_key in array array['temporary_csv_exports', 'technical_logs_no_pii']
  loop
    select retention_days into strict v_days
    from private.retention_policies where policy_key = retention_key;
    v_cutoff := p_reference_at - make_interval(days => v_days);
    insert into private.retention_cleanup_audit
      (run_id, policy_key, cutoff_at, eligible_count, deleted_count)
    values (v_run_id, retention_key, v_cutoff, 0, 0);
    cutoff_at := v_cutoff; eligible_count := 0; deleted_count := 0; return next;
  end loop;

  update private.retention_cleanup_runs
  set status = 'completed',
      completed_at = statement_timestamp()
  where id = v_run_id;
end
$function$;

revoke all on function private.run_retention_cleanup(boolean, timestamptz)
  from public, anon, authenticated;
grant execute on function private.run_retention_cleanup(boolean, timestamptz)
  to service_role;

do $schedule$
declare
  existing_job bigint;
begin
  select jobid into existing_job
  from cron.job
  where jobname = 'younew-monetization-retention-cleanup';

  if existing_job is not null then
    perform cron.unschedule(existing_job);
  end if;

  perform cron.schedule(
    'younew-monetization-retention-cleanup',
    '17 3 * * *',
    'select * from private.run_retention_cleanup(false);'
  );
end
$schedule$;

comment on function private.run_retention_cleanup(boolean, timestamptz) is
  'Scheduled configurable retention cleanup. Dry-run emits the same policy/count evidence without deleting rows. Legal holds always override deletion.';
comment on function public.export_pilot_usage_report(uuid) is
  'Service-only JSON export containing aggregate segments with at least five distinct subjects and five events. No client, person, IP, free text, partner or sponsor identifiers are returned.';
