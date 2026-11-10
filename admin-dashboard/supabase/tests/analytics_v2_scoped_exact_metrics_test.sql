begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(43);

create temporary table analytics_v2_views (view_name text primary key) on commit drop;
insert into analytics_v2_views (view_name) values
  ('analytics_v2_daily_metrics'),
  ('analytics_v2_overview_periods'),
  ('analytics_v2_event_metrics_periods'),
  ('analytics_v2_session_quality_periods'),
  ('analytics_v2_funnel_periods'),
  ('analytics_v2_complete_week_comparison');

select is(
  (
    select count(*)
    from pg_class relation
    join pg_namespace namespace on namespace.oid = relation.relnamespace
    join analytics_v2_views expected on expected.view_name = relation.relname
    where namespace.nspname = 'public'
      and relation.relkind = 'v'
  ),
  6::bigint,
  'all six additive analytics v2 views exist'
);
select ok(
  not exists (
    select 1
    from analytics_v2_views expected
    join pg_class relation on relation.relname = expected.view_name
    join pg_namespace namespace on namespace.oid = relation.relnamespace
    where namespace.nspname = 'public'
      and not coalesce(relation.reloptions, '{}'::text[]) @> array['security_invoker=true']::text[]
  ),
  'every analytics v2 view is SECURITY INVOKER'
);
select ok(
  not exists (
    select 1 from analytics_v2_views expected
    where not has_table_privilege(
      'authenticated',
      format('public.%I', expected.view_name),
      'SELECT'
    )
  ),
  'authenticated receives explicit read capability on every analytics v2 view'
);
select ok(
  not exists (
    select 1 from analytics_v2_views expected
    where has_table_privilege('anon', format('public.%I', expected.view_name), 'SELECT')
  ),
  'anon cannot select any analytics v2 view'
);
select ok(
  not exists (
    select 1 from analytics_v2_views expected
    where has_table_privilege('authenticated', format('public.%I', expected.view_name), 'INSERT')
      or has_table_privilege('authenticated', format('public.%I', expected.view_name), 'UPDATE')
      or has_table_privilege('authenticated', format('public.%I', expected.view_name), 'DELETE')
  ),
  'authenticated has no mutable analytics v2 privilege'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.app_events'::regclass)
    and (select relrowsecurity from pg_class where oid = 'public.app_sessions'::regclass),
  'security-invoker views retain the RLS boundary of both analytics base tables'
);
select has_index(
  'public',
  'app_events',
  'app_events_environment_platform_occurred_at_idx',
  'period and platform analytics queries have a bounded source index'
);
select ok(
  not exists (
    select 1
    from information_schema.columns column_definition
    join analytics_v2_views expected
      on expected.view_name = column_definition.table_name
    where column_definition.table_schema = 'public'
      and column_definition.column_name in (
        'id', 'client_event_id', 'app_instance_id', 'session_id', 'properties',
        'email', 'phone', 'ip_address', 'user_id', 'address', 'query',
        'latitude', 'longitude', 'message'
      )
  ),
  'analytics v2 output contains aggregates and no identifier, property or PII columns'
);

insert into public.app_sessions (
  session_id, app_instance_id, platform, app_version, language,
  started_at, ended_at, duration_seconds, consent_version,
  environment, last_seen_at
) values
  (
    '92000000-0000-4000-8000-000000000001',
    '93000000-0000-4000-8000-000000000001',
    'Web', 'web-pgtap-v2', 'en', now() - interval '1 day', now(), 20,
    '2026-07-28', 'production', now()
  ),
  (
    '92000000-0000-4000-8000-000000000002',
    '93000000-0000-4000-8000-000000000002',
    'Web', 'web-pgtap-v2', 'en', now() - interval '20 minutes', now(), 5,
    '2026-07-28', 'production', now()
  ),
  (
    '92000000-0000-4000-8000-000000000003',
    '93000000-0000-4000-8000-000000000003',
    'iOS', 'ios-pgtap-v2', 'en', now() - interval '1 day', now(), 30,
    '2026-07-28', 'production', now()
  ),
  (
    '92000000-0000-4000-8000-000000000005',
    '93000000-0000-4000-8000-000000000005',
    'Web', 'web-pgtap-v2', 'en', now() - interval '8 days', now() - interval '8 days', 15,
    '2026-07-28', 'production', now() - interval '8 days'
  );

insert into public.app_events (
  client_event_id, app_instance_id, session_id, event_name, screen,
  platform, app_version, language, properties, occurred_at, created_at,
  consent_version, schema_version, environment
) values
  (
    '94000000-0000-4000-8000-000000000001',
    '93000000-0000-4000-8000-000000000001',
    '92000000-0000-4000-8000-000000000001',
    'page_view', '/', 'Web', 'web-pgtap-v2', 'en', '{}'::jsonb,
    date_trunc('day', now() at time zone 'UTC') at time zone 'UTC' - interval '1 day' + interval '1 hour',
    now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000002',
    '93000000-0000-4000-8000-000000000001',
    '92000000-0000-4000-8000-000000000001',
    'page_view', '/', 'Web', 'web-pgtap-v2', 'en', '{}'::jsonb,
    now() - interval '14 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000003',
    '93000000-0000-4000-8000-000000000001',
    '92000000-0000-4000-8000-000000000001',
    'official_source_click', '/guide/', 'Web', 'web-pgtap-v2', 'en', '{}'::jsonb,
    now() - interval '13 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000004',
    '93000000-0000-4000-8000-000000000001',
    '92000000-0000-4000-8000-000000000001',
    'action_panel_cta_clicked', '/guide/', 'Web', 'web-pgtap-v2', 'en',
    '{"city":"leiden","content_id":"national.healthcare"}'::jsonb,
    now() - interval '12 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000005',
    '93000000-0000-4000-8000-000000000002',
    '92000000-0000-4000-8000-000000000002',
    'search_result_opened', '/search/', 'Web', 'web-pgtap-v2', 'en',
    '{"position":1}'::jsonb,
    now() - interval '11 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000006',
    '93000000-0000-4000-8000-000000000002',
    '92000000-0000-4000-8000-000000000002',
    'time_to_first_action', '/search/', 'Web', 'web-pgtap-v2', 'en',
    '{"city":"leiden","intent_id":"healthcare","duration_ms":750}'::jsonb,
    now() - interval '10 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000007',
    '93000000-0000-4000-8000-000000000002',
    '92000000-0000-4000-8000-000000000002',
    'explicit_city_detected', '/search/', 'Web', 'web-pgtap-v2', 'en',
    '{"city":"leiden","intent_id":"healthcare"}'::jsonb,
    now() - interval '9 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000008',
    '93000000-0000-4000-8000-000000000002',
    '92000000-0000-4000-8000-000000000002',
    'city_filter_applied', '/search/', 'Web', 'web-pgtap-v2', 'en',
    '{"city":"leiden","source":"query"}'::jsonb,
    now() - interval '8 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000009',
    '93000000-0000-4000-8000-000000000002',
    '92000000-0000-4000-8000-000000000002',
    'city_filter_corrected', '/search/', 'Web', 'web-pgtap-v2', 'en',
    '{"city":"leiden","source":"filter"}'::jsonb,
    now() - interval '7 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000010',
    '93000000-0000-4000-8000-000000000002',
    '92000000-0000-4000-8000-000000000002',
    'local_result_available', '/search/', 'Web', 'web-pgtap-v2', 'en',
    '{"city":"leiden","intent_id":"healthcare"}'::jsonb,
    now() - interval '6 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000011',
    '93000000-0000-4000-8000-000000000002',
    '92000000-0000-4000-8000-000000000002',
    'national_fallback_shown', '/search/', 'Web', 'web-pgtap-v2', 'en',
    '{"city":"leiden","intent_id":"legal-help"}'::jsonb,
    now() - interval '5 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000012',
    '93000000-0000-4000-8000-000000000002',
    '92000000-0000-4000-8000-000000000002',
    'wrong_geo_result_reported', '/search/', 'Web', 'web-pgtap-v2', 'en',
    '{"city":"leiden","intent_id":"healthcare"}'::jsonb,
    now() - interval '4 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000013',
    '93000000-0000-4000-8000-000000000001',
    '92000000-0000-4000-8000-000000000001',
    'search', '/search/', 'Web', 'web-pgtap-v2', 'en', '{}'::jsonb,
    now() - interval '3 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000014',
    '93000000-0000-4000-8000-000000000004',
    '92000000-0000-4000-8000-000000000004',
    'search', '/search/', 'Web', 'web-pgtap-v2', 'en', '{}'::jsonb,
    now() - interval '2 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000015',
    '93000000-0000-4000-8000-000000000003',
    '92000000-0000-4000-8000-000000000003',
    'screen_view', '/home', 'iOS', 'ios-pgtap-v2', 'en', '{}'::jsonb,
    date_trunc('day', now() at time zone 'UTC') at time zone 'UTC' - interval '1 day' + interval '2 hours',
    now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000016',
    '93000000-0000-4000-8000-000000000003',
    '92000000-0000-4000-8000-000000000003',
    'search_submitted', '/search', 'iOS', 'ios-pgtap-v2', 'en', '{}'::jsonb,
    now() - interval '3 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000017',
    '93000000-0000-4000-8000-000000000003',
    '92000000-0000-4000-8000-000000000003',
    'official_source_opened', '/guide', 'iOS', 'ios-pgtap-v2', 'en', '{}'::jsonb,
    now() - interval '2 minutes', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000018',
    '93000000-0000-4000-8000-000000000001',
    '92000000-0000-4000-8000-000000000001',
    'screen_view', '/home', 'iOS', 'ios-pgtap-v2', 'en', '{}'::jsonb,
    now() - interval '1 minute', now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000019',
    '93000000-0000-4000-8000-000000000005',
    '92000000-0000-4000-8000-000000000005',
    'official_source_click', '/guide/', 'Web', 'web-pgtap-v2', 'en', '{}'::jsonb,
    date_trunc('day', now() at time zone 'UTC') at time zone 'UTC' - interval '8 days' + interval '1 hour',
    now(), '2026-07-28', 1, 'production'
  ),
  (
    '94000000-0000-4000-8000-000000000020',
    '93000000-0000-4000-8000-000000000006',
    '92000000-0000-4000-8000-000000000006',
    'page_view', '/', 'Web', 'web-pgtap-v2', 'en', '{}'::jsonb,
    now() - interval '1 minute', now(), '2026-07-28', 1, 'staging'
  ),
  (
    '94000000-0000-4000-8000-000000000021',
    '93000000-0000-4000-8000-000000000007',
    '92000000-0000-4000-8000-000000000007',
    'page_view', '/', 'Web', 'web-pgtap-v2', 'en', '{}'::jsonb,
    now() + interval '1 minute', now(), '2026-07-28', 1, 'production'
  );

select set_config('request.jwt.claim.sub', '91000000-0000-4000-8000-000000000099', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"91000000-0000-4000-8000-000000000099","role":"authenticated"}',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.analytics_v2_overview_periods),
  0::bigint,
  'an unapproved authenticated user cannot read event aggregates through a security-invoker view'
);
select is(
  (select count(*) from public.analytics_v2_session_quality_periods),
  0::bigint,
  'an unapproved authenticated user cannot read session aggregates through a security-invoker view'
);
reset role;

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values (
  '00000000-0000-0000-0000-000000000000',
  '91000000-0000-4000-8000-000000000001',
  'authenticated', 'authenticated', 'analytics-v2-admin@example.invalid', '', now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
);
update public.profiles
set role = 'admin'::public.admin_role,
    is_approved = true
where id = '91000000-0000-4000-8000-000000000001';

select set_config('request.jwt.claim.sub', '91000000-0000-4000-8000-000000000001', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"91000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
set local role authenticated;

select is(
  (select count(*) from public.analytics_v2_overview_periods where period_days = 7),
  3::bigint,
  'approved Admin receives Web, iOS and explicit All period scopes'
);
select is((select event_count from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'Web'), 14::bigint, 'Web period event total excludes staging, future and previous-period fixtures');
select is((select event_count from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'iOS'), 4::bigint, 'iOS period event total is independently scoped');
select is((select event_count from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'All'), 18::bigint, 'explicit All period event total combines only eligible platforms');
select is((select session_count from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'Web'), 3::bigint, 'Web headline sessions are exact distinct period sessions');
select is((select session_count from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'iOS'), 2::bigint, 'iOS headline sessions are exact distinct period sessions');
select is((select session_count from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'All'), 4::bigint, 'All scope deduplicates a session observed on both platforms');
select is((select active_instances from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'Web'), 3::bigint, 'Web active instances stay platform scoped');
select is((select active_instances from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'All'), 4::bigint, 'All active instances are distinct across the combined scope');
select is(
  (
    select sum(session_count)::bigint
    from public.analytics_v2_daily_metrics
    where platform_scope = 'Web'
      and metric_date >= (date_trunc('day', now() at time zone 'UTC')::date - 6)
  ),
  4::bigint,
  'daily trend sessions can exceed and therefore never replace the exact period headline'
);
select is(
  (
    select sum(event_count)::bigint
    from public.analytics_v2_daily_metrics
    where platform_scope = 'Web'
      and metric_date >= (date_trunc('day', now() at time zone 'UTC')::date - 6)
  ),
  14::bigint,
  'daily Web event totals reconcile to the current period fixture'
);
select is((select key_action_events from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'Web'), 2::bigint, 'Action Panel context does not double-count Web canonical key actions');
select is((select key_action_events from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'All'), 3::bigint, 'All canonical key actions remain platform-consistent');
select is((select source_open_events from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'Web'), 1::bigint, 'Action Panel context does not double-count Web source opens');
select is((select source_open_events from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'All'), 2::bigint, 'All source opens include only canonical destination events');
select is((select action_panel_cta_events from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'Web'), 1::bigint, 'Action Panel remains available as a separate contextual counter');
select ok(
  (
    select explicit_city_detected_events = 1
      and city_filter_applied_events = 1
      and city_filter_corrected_events = 1
      and local_result_available_events = 1
      and national_fallback_shown_events = 1
      and wrong_geo_result_reported_events = 1
    from public.analytics_v2_overview_periods
    where period_days = 7 and platform_scope = 'Web'
  ),
  'all six geo relevance outcomes have separate aggregate counters'
);
select is((select first_result_open_events from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'Web'), 1::bigint, 'first-result clicks use the bounded numeric position property');
select is((select median_time_to_first_action_ms from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'Web'), 750.0::numeric, 'time-to-first-action exposes only the aggregate median');
select is((select search_events from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'All'), 3::bigint, 'Web search and iOS search_submitted share one search KPI');
select is((select page_screen_views from public.analytics_v2_overview_periods where period_days = 7 and platform_scope = 'All'), 4::bigint, 'page_view and screen_view share one explicitly scoped view KPI');
select is((select event_count from public.analytics_v2_event_metrics_periods where period_days = 7 and platform_scope = 'Web' and event_name = 'action_panel_cta_clicked'), 1::bigint, 'event distribution keeps Action Panel telemetry visible');
select is((select sum(event_count)::bigint from public.analytics_v2_event_metrics_periods where period_days = 7 and platform_scope = 'All'), 18::bigint, 'event distribution fully reconciles to the All headline');
select is(
  (
    select jsonb_build_array(
      session_count, matched_session_count, missing_session_count,
      platform_mismatch_count, engaged_session_count,
      average_duration_seconds_capped, median_duration_seconds
    )
    from public.analytics_v2_session_quality_periods
    where period_days = 7 and platform_scope = 'Web'
  ),
  '[3,2,1,0,1,12.5,12.5]'::jsonb,
  'Web session quality starts with the exact event-period denominator'
);
select is(
  (
    select jsonb_build_array(
      session_count, matched_session_count, missing_session_count,
      platform_mismatch_count, engaged_session_count,
      average_duration_seconds_capped, median_duration_seconds
    )
    from public.analytics_v2_session_quality_periods
    where period_days = 7 and platform_scope = 'iOS'
  ),
  '[2,2,0,1,1,30.0,30.0]'::jsonb,
  'iOS session quality identifies a stored-platform mismatch without substituting Web totals'
);
select is(
  (
    select jsonb_build_array(
      session_count, matched_session_count, missing_session_count,
      platform_mismatch_count, engaged_session_count
    )
    from public.analytics_v2_session_quality_periods
    where period_days = 7 and platform_scope = 'All'
  ),
  '[4,3,1,0,2]'::jsonb,
  'All session quality deduplicates cross-platform session identifiers'
);
select is(
  (
    select jsonb_build_array(average_duration_seconds_capped, median_duration_seconds)
    from public.analytics_v2_session_quality_periods
    where period_days = 7 and platform_scope = 'All'
  ),
  '[18.3,20.0]'::jsonb,
  'duration diagnostics use matched rows only and preserve capped average and median'
);
select is(
  (
    select jsonb_build_array(events, sessions)
    from public.analytics_v2_funnel_periods
    where period_days = 7 and platform_scope = 'Web' and funnel_step = 'search'
  ),
  '[2,2]'::jsonb,
  'Web search funnel has its own event and distinct-session counts'
);
select is(
  (
    select jsonb_build_array(events, sessions)
    from public.analytics_v2_funnel_periods
    where period_days = 7 and platform_scope = 'All' and funnel_step = 'visit'
  ),
  '[4,2]'::jsonb,
  'All visit funnel combines page/screen events and deduplicates sessions'
);
select is(
  (
    select jsonb_build_array(events, sessions)
    from public.analytics_v2_funnel_periods
    where period_days = 7 and platform_scope = 'Web' and funnel_step = 'source_open'
  ),
  '[1,1]'::jsonb,
  'source funnel counts only canonical source-open events'
);
select is(
  (
    select count(*)
    from public.analytics_v2_funnel_periods
    where period_days = 7
      and funnel_step = 'action_panel_cta_clicked'
  ),
  0::bigint,
  'Action Panel context is not introduced as a second funnel conversion step'
);
select is(
  (
    select jsonb_build_array(current_events, previous_events)
    from public.analytics_v2_complete_week_comparison
    where platform_scope = 'All'
  ),
  '[2,1]'::jsonb,
  'complete-week comparison excludes the partial current UTC day'
);
select is(
  (
    select jsonb_build_array(current_sessions, previous_sessions, current_key_actions, previous_key_actions)
    from public.analytics_v2_complete_week_comparison
    where platform_scope = 'All'
  ),
  '[2,1,0,1]'::jsonb,
  'complete-week session and canonical-action comparisons use matching full windows'
);

reset role;
select * from finish();
rollback;
