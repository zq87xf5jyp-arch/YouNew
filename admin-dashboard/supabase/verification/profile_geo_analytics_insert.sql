\set ON_ERROR_STOP on

begin;
set local role service_role;

explain (analyze, buffers, wal, format json)
select public.ingest_analytics_batch(
  jsonb_agg(jsonb_build_object(
    'client_event_id',
      ('50000000-0000-4000-8000-' || lpad(sequence::text, 12, '0')),
    'app_instance_id', '50000000-0000-4000-8000-000000000100',
    'session_id', '50000000-0000-4000-8000-000000000200',
    'event_name', 'explicit_city_detected',
    'screen', '/search/',
    'platform', 'Web',
    'app_version', 'geo-ranking-v1',
    'language', 'en',
    'properties', jsonb_build_object(
      'city', 'leiden',
      'intent_id', 'healthcare'
    ),
    'occurred_at', statement_timestamp(),
    'consent_version', '2026-07-28',
    'schema_version', 1,
    'environment', 'test'
  ) order by sequence)
)
from generate_series(1, 50) as sequence;

reset role;

select jsonb_pretty(jsonb_build_object(
  'fixture', 'synthetic-only',
  'batch_size', 50,
  'stored_before_rollback', (
    select count(*)
    from public.app_events
    where app_instance_id = '50000000-0000-4000-8000-000000000100'
  ),
  'rate_window_rows_before_rollback', (
    select count(*)
    from private.analytics_ingest_windows
    where app_instance_id = '50000000-0000-4000-8000-000000000100'
  )
));

rollback;
