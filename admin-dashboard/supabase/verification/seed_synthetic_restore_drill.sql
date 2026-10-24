\set ON_ERROR_STOP on

begin;

do $guard$
begin
  if current_database() <> 'postgres'
    or current_setting('is_superuser') <> 'on'
    or current_setting('application_name') <> 'younew-disposable-restore-drill' then
    raise exception 'Synthetic restore drill requires the disposable local database';
  end if;
end
$guard$;

insert into public.business_inquiries (
  id, reference_code, company_name, contact_person, email, website,
  inquiry_type, organization_type, kvk_number, city, province,
  target_audience, requested_placements, campaign_goal, budget_range,
  message, consent_to_privacy, confirm_accuracy, consent_at, source_page,
  status, lost_reason, status_changed_at, retention_class, created_at, updated_at
) values
  (
    '91000000-0000-4000-8000-000000000001', 'YNI-910000000001',
    'Synthetic Restore One BV', 'Synthetic Contact One',
    'restore-one@example.invalid', 'https://example.invalid',
    'partnership', 'commercial-business', '91000001', 'Amsterdam',
    'Noord-Holland', array['worker'], array['content-partnership'],
    'Synthetic backup and restore verification', 'request-discussion',
    'Disposable synthetic data. Never a real lead.', true, true,
    '2026-08-18 12:00:00+00', '/partners/apply/', 'new', null,
    '2026-08-18 12:00:00+00', 'active',
    '2026-08-18 12:00:00+00', '2026-08-18 12:00:00+00'
  ),
  (
    '91000000-0000-4000-8000-000000000002', 'YNI-910000000002',
    'Synthetic Restore Two BV', 'Synthetic Contact Two',
    'restore-two@example.invalid', 'https://example.invalid',
    'partnership', 'commercial-business', '91000002', 'Utrecht',
    'Utrecht', array['expat'], array['content-partnership'],
    'Synthetic backup and restore verification', 'request-discussion',
    'Disposable synthetic data. Never a real lead.', true, true,
    '2026-08-18 12:05:00+00', '/partners/apply/', 'lost', 'no_budget',
    '2026-08-18 12:05:00+00', 'active',
    '2026-08-18 12:05:00+00', '2026-08-18 12:05:00+00'
  );

insert into public.app_sessions (
  id, session_id, app_instance_id, platform, language, city,
  started_at, ended_at, duration_seconds, created_at, consent_version,
  environment, last_seen_at
) values (
  '92000000-0000-4000-8000-000000000001', 'synthetic-restore-session',
  'synthetic-restore-instance', 'Web', 'en', 'Amsterdam',
  '2026-08-18 11:00:00+00', '2026-08-18 11:10:00+00', 600,
  '2026-08-18 11:00:00+00', 'pilot-v1', 'test',
  '2026-08-18 11:10:00+00'
);

insert into public.app_events (
  id, client_event_id, app_instance_id, session_id, event_name, screen,
  platform, language, city, properties, occurred_at, created_at,
  consent_version, schema_version, environment
)
select
  ('93000000-0000-4000-8000-' || lpad(event_number::text, 12, '0'))::uuid,
  ('93100000-0000-4000-8000-' || lpad(event_number::text, 12, '0'))::uuid,
  'synthetic-restore-instance', 'synthetic-restore-session',
  'page_view', '/for-business/pilot', 'Web', 'en', 'Amsterdam', '{}'::jsonb,
  '2026-08-18 11:00:00+00'::timestamptz + make_interval(secs => event_number),
  '2026-08-18 11:00:00+00'::timestamptz + make_interval(secs => event_number),
  'pilot-v1', 1, 'test'
from generate_series(1, 5) as event_number;

insert into private.pilot_usage_events (
  id, client_scope_id, subject_token_hash, event_name, occurred_at,
  consent_version, consent_granted, is_sample, created_at
)
select
  ('94000000-0000-4000-8000-' || lpad(subject_number::text, 12, '0'))::uuid,
  '94100000-0000-4000-8000-000000000001',
  encode(digest('synthetic-restore-subject-' || subject_number::text, 'sha256'), 'hex'),
  'route_opened',
  '2026-08-18 11:30:00+00'::timestamptz + make_interval(secs => subject_number),
  'pilot-v1', true, true,
  '2026-08-18 11:30:00+00'::timestamptz + make_interval(secs => subject_number)
from generate_series(1, 6) as subject_number;

insert into private.retention_legal_holds (
  resource_type, resource_id, reason_code, hold_until, created_at
) values (
  'business_inquiry',
  '91000000-0000-4000-8000-000000000002', 'contractual',
  '2026-09-19 00:00:00+00', '2026-08-19 00:00:00+00'
);

commit;

select jsonb_build_object(
  'fixture', 'synthetic-only',
  'business_inquiries', (select count(*) from public.business_inquiries),
  'business_inquiry_notifications', (select count(*) from public.business_inquiry_notifications),
  'sync_jobs', (select count(*) from public.sync_jobs),
  'app_sessions', (select count(*) from public.app_sessions),
  'app_events', (select count(*) from public.app_events),
  'pilot_usage_events', (select count(*) from private.pilot_usage_events),
  'retention_legal_holds', (select count(*) from private.retention_legal_holds)
);
