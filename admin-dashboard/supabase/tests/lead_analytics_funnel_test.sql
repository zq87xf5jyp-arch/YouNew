begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(12);

select ok(
  has_function_privilege('service_role', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE')
    and not has_function_privilege('anon', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE')
    and not has_function_privilege('authenticated', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'),
  'only service_role can execute analytics ingest'
);
select ok(
  coalesce(
    (select reloptions @> array['security_invoker=true']
     from pg_class
     where oid = 'public.analytics_lead_funnel_periods'::regclass),
    false
  ),
  'lead funnel aggregate uses invoker security'
);
select ok(
  has_table_privilege('authenticated', 'public.analytics_lead_funnel_periods', 'SELECT')
    and not has_table_privilege('anon', 'public.analytics_lead_funnel_periods', 'SELECT'),
  'only authenticated Admin sessions can select the lead aggregate'
);

set local role service_role;

select is(
  public.ingest_analytics_batch(
    jsonb_build_array(
      jsonb_build_object(
        'client_event_id', '00000000-0000-4000-8000-000000000041',
        'app_instance_id', '00000000-0000-4000-8000-000000000042',
        'session_id', '00000000-0000-4000-8000-000000000043',
        'event_name', 'lead_start',
        'screen', '/business/apply/',
        'platform', 'Web',
        'app_version', 'pgtap',
        'language', 'en',
        'properties', '{}'::jsonb,
        'occurred_at', statement_timestamp(),
        'consent_version', '2026-07-28',
        'schema_version', 1,
        'environment', 'production'
      ),
      jsonb_build_object(
        'client_event_id', '00000000-0000-4000-8000-000000000044',
        'app_instance_id', '00000000-0000-4000-8000-000000000042',
        'session_id', '00000000-0000-4000-8000-000000000043',
        'event_name', 'lead_submit',
        'screen', '/business/apply/',
        'platform', 'Web',
        'app_version', 'pgtap',
        'language', 'en',
        'properties', '{}'::jsonb,
        'occurred_at', statement_timestamp(),
        'consent_version', '2026-07-28',
        'schema_version', 1,
        'environment', 'production'
      ),
      jsonb_build_object(
        'client_event_id', '00000000-0000-4000-8000-000000000046',
        'app_instance_id', '00000000-0000-4000-8000-000000000042',
        'session_id', '00000000-0000-4000-8000-000000000043',
        'event_name', 'pilot_request',
        'screen', '/partners/apply/',
        'platform', 'Web',
        'app_version', 'pgtap',
        'language', 'en',
        'properties', '{}'::jsonb,
        'occurred_at', statement_timestamp(),
        'consent_version', '2026-07-28',
        'schema_version', 1,
        'environment', 'production'
      )
    )
  ),
  3,
  'the three approved lead events are accepted together'
);
select is(
  (select properties from public.app_events where client_event_id = '00000000-0000-4000-8000-000000000041'),
  '{}'::jsonb,
  'lead_start stores an empty properties object'
);
select is(
  (select properties from public.app_events where client_event_id = '00000000-0000-4000-8000-000000000044'),
  '{}'::jsonb,
  'lead_submit stores an empty properties object'
);
select throws_ok(
  $$
    select public.ingest_analytics_batch(
      jsonb_build_array(jsonb_build_object(
        'client_event_id', '00000000-0000-4000-8000-000000000045',
        'app_instance_id', '00000000-0000-4000-8000-000000000042',
        'session_id', '00000000-0000-4000-8000-000000000043',
        'event_name', 'lead_start',
        'screen', '/business/apply/',
        'platform', 'Web',
        'app_version', 'pgtap',
        'language', 'en',
        'properties', jsonb_build_object('location', 'form'),
        'occurred_at', statement_timestamp(),
        'consent_version', '2026-07-28',
        'schema_version', 1,
        'environment', 'production'
      ))
    )
  $$,
  '22023',
  'lead events do not accept properties',
  'lead events reject every submitted property'
);
select is(
  (select properties from public.app_events where client_event_id = '00000000-0000-4000-8000-000000000046'),
  '{}'::jsonb,
  'pilot_request is accepted without properties'
);
select is(
  (
    select count(distinct funnel_step)
    from public.analytics_lead_funnel_periods
    where period_days = 7 and platform = 'Web'
      and funnel_step in ('lead_start', 'lead_submit', 'pilot_request')
  ),
  3::bigint,
  'lead funnel aggregate exposes all three approved steps'
);
select is(
  (
    select sum(events)
    from public.analytics_lead_funnel_periods
    where period_days = 7 and platform = 'Web'
      and funnel_step in ('lead_start', 'lead_submit', 'pilot_request')
  ),
  3::numeric,
  'the aggregate counts the three stored receipt-funnel events'
);
select ok(
  not exists (
    select 1
    from public.app_events
    where client_event_id in (
      '00000000-0000-4000-8000-000000000041',
      '00000000-0000-4000-8000-000000000044',
      '00000000-0000-4000-8000-000000000046'
    )
      and properties <> '{}'::jsonb
  ),
  'stored lead events contain no form or receipt properties'
);
select is(
  (
    select count(*)
    from public.app_events
    where client_event_id in (
      '00000000-0000-4000-8000-000000000045'
    )
  ),
  0::bigint,
  'the rejected property-bearing event is not stored'
);

reset role;
select * from finish();
rollback;
