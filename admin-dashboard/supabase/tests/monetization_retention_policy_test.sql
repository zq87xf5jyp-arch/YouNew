begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(35);

select is(
  (select count(*) from private.retention_policies),
  8::bigint,
  'all eight owner-approved retention policies are configured'
);
select is(
  (
    select jsonb_object_agg(policy_key, retention_days order by policy_key)
    from private.retention_policies
  ),
  '{
    "admin_notifications": 90,
    "anonymized_aggregate_reports": 730,
    "lost_archived_leads": 365,
    "raw_usage_events": 90,
    "technical_logs_no_pii": 30,
    "temporary_csv_exports": 30,
    "unconfirmed_spam_leads": 90,
    "unfinished_applications": 30
  }'::jsonb,
  'retention defaults match the owner decision'
);
select is(
  (select storage_scope from private.retention_policies where policy_key = 'temporary_csv_exports'),
  'not_persisted',
  'temporary CSV responses are not persisted by the application'
);
select is(
  (select storage_scope from private.retention_policies where policy_key = 'technical_logs_no_pii'),
  'external_provider',
  'technical-log retention remains an explicit provider control'
);
select ok(
  not exists (
    select 1
    from pg_class relation
    join pg_namespace schema on schema.oid = relation.relnamespace
    where schema.nspname = 'private'
      and relation.relname in (
        'retention_policies',
        'retention_legal_holds',
        'retention_cleanup_runs',
        'retention_cleanup_audit',
        'pilot_usage_events',
        'pilot_usage_reports',
        'pilot_usage_report_segments'
      )
      and not relation.relrowsecurity
  ),
  'every new private table has RLS enabled as defense in depth'
);
select ok(
  not has_table_privilege('anon', 'private.retention_policies', 'SELECT')
    and not has_table_privilege('authenticated', 'private.retention_policies', 'SELECT')
    and not has_table_privilege('anon', 'private.retention_legal_holds', 'INSERT')
    and not has_table_privilege('authenticated', 'private.retention_legal_holds', 'INSERT')
    and not has_table_privilege('anon', 'private.retention_cleanup_audit', 'SELECT')
    and not has_table_privilege('authenticated', 'private.retention_cleanup_audit', 'SELECT'),
  'public clients have no retention or legal-hold table privileges'
);
select ok(
  has_function_privilege(
    'service_role',
    'private.run_retention_cleanup(boolean,timestamp with time zone)',
    'EXECUTE'
  )
    and not has_function_privilege(
      'anon',
      'private.run_retention_cleanup(boolean,timestamp with time zone)',
      'EXECUTE'
    )
    and not has_function_privilege(
      'authenticated',
      'private.run_retention_cleanup(boolean,timestamp with time zone)',
      'EXECUTE'
    ),
  'only the service boundary can invoke retention cleanup'
);
select ok(
  exists (
    select 1
    from cron.job
    where jobname = 'younew-monetization-retention-cleanup'
      and schedule = '17 3 * * *'
      and command = 'select * from private.run_retention_cleanup(false);'
  ),
  'daily scheduled cleanup invokes the non-dry-run function'
);
select ok(
  not exists (
    select 1 from pg_trigger
    where tgrelid = 'public.app_events'::regclass
      and tgname = 'prune_analytics_retention_before_insert'
      and not tgisinternal
  ),
  'the unaudited insert-time retention trigger is retired'
);
select ok(
  (
    select pg_get_constraintdef(oid)
    from pg_constraint
    where conrelid = 'public.business_inquiries'::regclass
      and conname = 'business_inquiries_retention_class_check'
  ) like all (array['%unfinished%', '%unconfirmed%', '%spam%', '%contract_record%']),
  'lead retention classification is constrained'
);
select ok(
  not exists (
    select 1 from private.retention_policies
    where policy_key ~ '(contract|invoice|account)'
  ),
  'contracts, invoices and accounting documents are outside automated cleanup'
);

set local role service_role;

insert into public.business_inquiries (
  id, reference_code, company_name, contact_person, email, website,
  inquiry_type, organization_type, kvk_number, city, province,
  target_audience, requested_placements, campaign_goal, budget_range,
  message, consent_to_privacy, confirm_accuracy, consent_at, source_page,
  status, lost_reason, won_evidence_type, won_evidence_at,
  status_changed_at, retention_class, created_at, updated_at
)
select
  fixture.id,
  fixture.reference_code,
  'Synthetic Retention BV',
  'Synthetic Owner',
  fixture.email,
  'https://example.invalid',
  'partnership',
  'commercial-business',
  '12345678',
  'Amsterdam',
  'Noord-Holland',
  array['expat', 'worker'],
  array['content-partnership'],
  'Synthetic retention boundary verification only',
  'request-discussion',
  'Synthetic disposable data for retention policy boundary verification.',
  true,
  true,
  fixture.created_at,
  '/partners/apply/',
  fixture.status,
  fixture.lost_reason,
  fixture.won_evidence_type,
  fixture.won_evidence_at,
  fixture.status_changed_at,
  fixture.retention_class,
  fixture.created_at,
  fixture.created_at
from (values
  ('10000000-0000-4000-8000-000000000101'::uuid, 'YNI-000000000101', 'unfinished-old@example.invalid', 'new', null, null, null, 'unfinished', '2026-07-19 00:00:00+00'::timestamptz, '2026-07-19 00:00:00+00'::timestamptz),
  ('10000000-0000-4000-8000-000000000102'::uuid, 'YNI-000000000102', 'unfinished-boundary@example.invalid', 'new', null, null, null, 'unfinished', '2026-07-20 00:00:00+00'::timestamptz, '2026-07-20 00:00:00+00'::timestamptz),
  ('10000000-0000-4000-8000-000000000103'::uuid, 'YNI-000000000103', 'spam-old@example.invalid', 'new', null, null, null, 'spam', '2026-05-01 00:00:00+00'::timestamptz, '2026-05-01 00:00:00+00'::timestamptz),
  ('10000000-0000-4000-8000-000000000104'::uuid, 'YNI-000000000104', 'lost-old@example.invalid', 'lost', 'no_budget', null, null, 'active', '2025-07-01 00:00:00+00'::timestamptz, '2025-07-01 00:00:00+00'::timestamptz),
  ('10000000-0000-4000-8000-000000000105'::uuid, 'YNI-000000000105', 'held-archived@example.invalid', 'archived', null, null, null, 'active', '2025-07-01 00:00:00+00'::timestamptz, '2025-07-01 00:00:00+00'::timestamptz),
  ('10000000-0000-4000-8000-000000000106'::uuid, 'YNI-000000000106', 'won-contract@example.invalid', 'won', null, 'paid_pilot', '2026-01-15 00:00:00+00'::timestamptz, 'contract_record', '2025-01-01 00:00:00+00'::timestamptz, '2025-01-01 00:00:00+00'::timestamptz),
  ('10000000-0000-4000-8000-000000000107'::uuid, 'YNI-000000000107', 'old-notification@example.invalid', 'new', null, null, null, 'active', '2026-05-01 00:00:00+00'::timestamptz, '2026-08-18 00:00:00+00'::timestamptz),
  ('10000000-0000-4000-8000-000000000108'::uuid, 'YNI-000000000108', 'held-notification@example.invalid', 'new', null, null, null, 'active', '2026-05-01 00:00:00+00'::timestamptz, '2026-08-18 00:00:00+00'::timestamptz)
) as fixture(
  id, reference_code, email, status, lost_reason, won_evidence_type,
  won_evidence_at, retention_class, status_changed_at, created_at
);

delete from public.business_inquiry_notifications
where inquiry_id in (
  '10000000-0000-4000-8000-000000000107'::uuid,
  '10000000-0000-4000-8000-000000000108'::uuid
);
insert into public.business_inquiry_notifications (
  id, inquiry_id, reference_code, created_at
) values
  ('20000000-0000-4000-8000-000000000107', '10000000-0000-4000-8000-000000000107', 'YNI-000000000107', '2026-05-01 00:00:00+00'),
  ('20000000-0000-4000-8000-000000000108', '10000000-0000-4000-8000-000000000108', 'YNI-000000000108', '2026-05-01 00:00:00+00');

reset role;

insert into public.audit_logs (action, entity_type, entity_id, new_value, created_at)
values (
  'business_inquiry_created',
  'business_inquiry',
  '10000000-0000-4000-8000-000000000103',
  '{"status":"new"}'::jsonb,
  '2026-05-01 00:00:00+00'
);

insert into public.app_events (
  id, client_event_id, app_instance_id, event_name, platform, properties,
  occurred_at, created_at, consent_version, schema_version, environment
) values
  ('30000000-0000-4000-8000-000000000101', '30000000-0000-4000-8000-000000000111', 'synthetic-retention-delete', 'page_view', 'Web', '{}', '2026-05-01 00:00:00+00', '2026-05-01 00:00:00+00', '2026-07-28', 1, 'test'),
  ('30000000-0000-4000-8000-000000000102', '30000000-0000-4000-8000-000000000112', 'synthetic-retention-hold', 'page_view', 'Web', '{}', '2026-05-01 00:00:00+00', '2026-05-01 00:00:00+00', '2026-07-28', 1, 'test');

insert into private.pilot_usage_events (
  id, client_scope_id, subject_token_hash, event_name, occurred_at,
  consent_version, consent_granted, is_sample, created_at
) values
  ('40000000-0000-4000-8000-000000000101', '40000000-0000-4000-8000-000000000001', repeat('a', 64), 'route_opened', '2026-05-01 00:00:00+00', 'pilot-v1', true, true, '2026-05-01 00:00:00+00');

insert into private.retention_legal_holds (
  resource_type, resource_id, reason_code, hold_until
) values
  ('business_inquiry', '10000000-0000-4000-8000-000000000105', 'contractual', '2027-08-19 00:00:00+00'),
  ('business_inquiry_notification', '20000000-0000-4000-8000-000000000108', 'regulatory', '2027-08-19 00:00:00+00'),
  ('app_event', '30000000-0000-4000-8000-000000000102', 'security_incident', '2027-08-19 00:00:00+00');

set local role service_role;

create temporary table dry_run_results on commit drop as
select * from private.run_retention_cleanup(true, '2026-08-19 00:00:00+00');

select is((select count(*) from dry_run_results), 8::bigint, 'dry-run reports every policy');
select is((select sum(deleted_count) from dry_run_results), 0::numeric, 'dry-run deletes nothing');
select is((select count(*) from public.business_inquiries where id::text like '10000000-%'), 8::bigint, 'dry-run preserves all synthetic leads');
select is((select count(*) from private.retention_cleanup_audit where deleted_count = 0), 8::bigint, 'dry-run records eight count-only audit rows');
select ok(
  not exists (
    select 1 from information_schema.columns
    where table_schema = 'private'
      and table_name = 'retention_cleanup_audit'
      and column_name in ('resource_id', 'entity_id', 'email', 'phone', 'name', 'message', 'payload')
  ),
  'cleanup audit has no deleted row identifier or PII column'
);

create temporary table cleanup_results on commit drop as
select * from private.run_retention_cleanup(false, '2026-08-19 00:00:00+00');

reset role;

select is((select deleted_count from cleanup_results where retention_key = 'unfinished_applications'), 1::bigint, 'unfinished leads older than 30 days are deleted');
select ok(exists (select 1 from public.business_inquiries where id = '10000000-0000-4000-8000-000000000102'), 'the exact 30-day boundary is preserved');
select is((select deleted_count from cleanup_results where retention_key = 'unconfirmed_spam_leads'), 1::bigint, 'spam and unconfirmed leads use the 90-day policy');
select is((select deleted_count from cleanup_results where retention_key = 'lost_archived_leads'), 1::bigint, 'lost and archived leads use the 12-month policy');
select ok(exists (select 1 from public.business_inquiries where id = '10000000-0000-4000-8000-000000000105'), 'an active legal hold preserves an otherwise expired lead');
select ok(exists (select 1 from public.business_inquiries where id = '10000000-0000-4000-8000-000000000106'), 'won contract records are never deleted by lead retention');
select ok(not exists (select 1 from public.business_inquiry_notifications where id = '20000000-0000-4000-8000-000000000107'), 'expired Admin notification is deleted');
select ok(exists (select 1 from public.business_inquiry_notifications where id = '20000000-0000-4000-8000-000000000108'), 'notification legal hold overrides deletion');
select ok(not exists (select 1 from public.app_events where id = '30000000-0000-4000-8000-000000000101'), 'expired raw usage event is deleted');
select ok(exists (select 1 from public.app_events where id = '30000000-0000-4000-8000-000000000102'), 'raw usage event legal hold overrides deletion');
select ok(not exists (select 1 from private.pilot_usage_events where id = '40000000-0000-4000-8000-000000000101'), 'expired pilot usage event is deleted');
select ok(
  not exists (
    select 1 from public.audit_logs
    where entity_type = 'business_inquiry'
      and entity_id = '10000000-0000-4000-8000-000000000103'
  ),
  'lead deletion removes the old entity-linked audit row'
);
select is((select count(*) from private.retention_cleanup_audit), 16::bigint, 'dry-run and cleanup each record all eight policies');
select is((select count(*) from private.retention_cleanup_runs where status = 'completed'), 2::bigint, 'both cleanup runs complete with measured evidence');
select is((select sum(deleted_count) from cleanup_results), 6::numeric, 'cleanup count reconciles all deleted synthetic rows');

set local role service_role;

select lives_ok($$select private.set_retention_days('unfinished_applications', 31)$$, 'retention defaults are configurable through the controlled function');
select is((select retention_days from private.retention_policies where policy_key = 'unfinished_applications'), 31, 'the controlled configuration change is stored');
select throws_ok(
  $$select private.set_retention_days('unfinished_applications', 365)$$,
  '23514',
  null,
  'out-of-range retention configuration fails closed'
);
select lives_ok($$select private.set_retention_days('unfinished_applications', 30)$$, 'the approved default can be restored');

reset role;

select * from finish();
rollback;
