\set ON_ERROR_STOP on

begin;
set local role service_role;

insert into public.app_sessions (
  session_id, app_instance_id, platform, app_version, language,
  started_at, ended_at, duration_seconds, consent_version,
  environment, last_seen_at
)
select
  'perf-session-' || lpad(series::text, 4, '0'),
  'perf-instance-' || lpad(((series - 1) % 120 + 1)::text, 3, '0'),
  case when series % 4 = 0 then 'iOS' else 'Web' end,
  'synthetic-perf-v1',
  'en',
  statement_timestamp() - ((series % 89)::text || ' days')::interval,
  statement_timestamp() - ((series % 89)::text || ' days')::interval + interval '30 seconds',
  30,
  'synthetic-perf',
  'production',
  statement_timestamp() - ((series % 89)::text || ' days')::interval + interval '30 seconds'
from generate_series(1, 600) as fixture(series);

insert into public.app_events (
  client_event_id, app_instance_id, session_id, event_name, screen,
  platform, app_version, language, properties, occurred_at, created_at,
  consent_version, schema_version, environment
)
select
  gen_random_uuid(),
  'perf-instance-' || lpad(((series - 1) % 120 + 1)::text, 3, '0'),
  'perf-session-' || lpad(((series - 1) % 600 + 1)::text, 4, '0'),
  (array[
    'page_view',
    'official_source_click',
    'action_panel_cta_clicked',
    'search_result_opened',
    'explicit_city_detected',
    'city_filter_corrected',
    'national_fallback_shown',
    'local_result_available'
  ])[((series - 1) % 8) + 1],
  '/synthetic/performance',
  case when series % 4 = 0 then 'iOS' else 'Web' end,
  'synthetic-perf-v1',
  'en',
  case when series % 8 = 4 then '{"position":1}'::jsonb else '{}'::jsonb end,
  statement_timestamp()
    - ((series % 89)::text || ' days')::interval
    - ((series % 86400)::text || ' seconds')::interval,
  statement_timestamp()
    - ((series % 89)::text || ' days')::interval
    - ((series % 86400)::text || ' seconds')::interval,
  'synthetic-perf',
  1,
  'production'
from generate_series(1, 6000) as fixture(series);

analyze public.app_events;
analyze public.app_sessions;

select 'PROFILE analytics_v2_overview_periods Web 7 days' as profile;
explain (analyze, buffers, verbose)
select * from public.analytics_v2_overview_periods
where period_days = 7 and platform_scope = 'Web';

select 'PROFILE analytics_v2_overview_periods Web 30 days' as profile;
explain (analyze, buffers, verbose)
select * from public.analytics_v2_overview_periods
where period_days = 30 and platform_scope = 'Web';

select 'PROFILE analytics_v2_overview_periods Web 90 days' as profile;
explain (analyze, buffers, verbose)
select * from public.analytics_v2_overview_periods
where period_days = 90 and platform_scope = 'Web';

select 'PROFILE analytics_v2_event_metrics_periods top events + Other source' as profile;
explain (analyze, buffers, verbose)
select * from public.analytics_v2_event_metrics_periods
where period_days = 30 and platform_scope = 'Web'
order by event_count desc, event_name
limit 13;

select 'PROFILE analytics_v2_session_quality_periods exact sessions' as profile;
explain (analyze, buffers, verbose)
select * from public.analytics_v2_session_quality_periods
where period_days = 30 and platform_scope = 'All';

select 'PROFILE analytics_v2_funnel_periods' as profile;
explain (analyze, buffers, verbose)
select * from public.analytics_v2_funnel_periods
where period_days = 30 and platform_scope = 'Web';

select 'PROFILE analytics_v2_complete_week_comparison' as profile;
explain (analyze, buffers, verbose)
select * from public.analytics_v2_complete_week_comparison
where platform_scope = 'Web';

rollback;
