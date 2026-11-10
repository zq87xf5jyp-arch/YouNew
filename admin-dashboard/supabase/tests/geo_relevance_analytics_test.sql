begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(43);

create function pg_temp.geo_analytics_event(
  p_client_event_id text,
  p_event_name text,
  p_properties jsonb,
  p_top_level_city text default null
)
returns jsonb
language sql
set search_path = ''
as $function$
  select jsonb_strip_nulls(jsonb_build_object(
    'client_event_id', p_client_event_id,
    'app_instance_id', '10000000-0000-4000-8000-000000000201',
    'session_id', '10000000-0000-4000-8000-000000000202',
    'event_name', p_event_name,
    'screen', '/search/',
    'platform', 'Web',
    'app_version', 'web-pgtap-geo-v1',
    'language', 'en',
    'city', p_top_level_city,
    'properties', p_properties,
    'occurred_at', statement_timestamp(),
    'consent_version', '2026-07-28',
    'schema_version', 1,
    'environment', 'test'
  ));
$function$;

-- Schema, RLS, grants, indexes and the privileged RPC remain unchanged.
select ok(
  (select relrowsecurity from pg_class where oid = 'public.app_events'::regclass),
  'app_events keeps RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.app_sessions'::regclass),
  'app_sessions keeps RLS enabled'
);
select ok(
  exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'app_events'
      and cmd = 'SELECT'
      and roles = array['authenticated']::name[]
      and coalesce(qual, '') like '%is_approved_admin%'
  )
  and not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'app_events'
      and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
  ),
  'app_events keeps approved-admin reads and no direct client write policy'
);
select ok(
  not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'app_events'
      and column_name ~* '(email|phone|ip|address|query|latitude|longitude|message)'
  ),
  'app_events has no direct PII, query, coordinate or free-message column'
);
select ok(
  not exists (
    select 1
    from (
      values
        ('app_events_name_time_idx'),
        ('app_events_instance_time_idx'),
        ('app_events_platform_time_idx'),
        ('app_events_session_time_idx')
    ) as required(index_name)
    where not exists (
      select 1
      from pg_class index_class
      join pg_index index_definition on index_definition.indexrelid = index_class.oid
      where index_class.relname = required.index_name
        and index_definition.indrelid = 'public.app_events'::regclass
        and index_definition.indisvalid
        and index_definition.indisready
    )
  ),
  'analytics lookup and retention indexes remain valid and ready'
);
select ok(
  exists (
    select 1
    from pg_constraint
    where conrelid = 'public.app_events'::regclass
      and conname = 'app_events_payload_bounds'
      and convalidated
  ),
  'the existing app_events payload bound remains validated'
);
select ok(
  exists (
    select 1
    from pg_proc
    where oid = 'public.ingest_analytics_batch(jsonb)'::regprocedure
      and prosecdef
      and coalesce(proconfig, '{}'::text[]) @> array['search_path=""']::text[]
  ),
  'ingest RPC keeps its SECURITY DEFINER and empty search_path boundary'
);
select ok(
  has_function_privilege('service_role', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE')
    and not has_function_privilege('anon', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE')
    and not has_function_privilege('authenticated', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'),
  'only service_role can execute the ingest RPC'
);
select ok(
  not has_table_privilege('anon', 'public.app_events', 'SELECT')
    and not has_table_privilege('anon', 'public.app_events', 'INSERT')
    and not has_table_privilege('anon', 'public.app_events', 'UPDATE')
    and not has_table_privilege('anon', 'public.app_events', 'DELETE'),
  'anon has no direct app_events privilege'
);
select ok(
  has_table_privilege('authenticated', 'public.app_events', 'SELECT')
    and not has_table_privilege('authenticated', 'public.app_events', 'INSERT')
    and not has_table_privilege('authenticated', 'public.app_events', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.app_events', 'DELETE'),
  'authenticated receives read capability only, filtered by the Admin RLS policy'
);
select ok(
  not has_table_privilege('anon', 'public.app_sessions', 'SELECT')
    and has_table_privilege('authenticated', 'public.app_sessions', 'SELECT')
    and not has_table_privilege('authenticated', 'public.app_sessions', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.app_sessions', 'DELETE'),
  'session grants retain the same anonymous and Admin-only read boundary'
);

-- Every new event is accepted with its exact canonical property contract.
set local role service_role;
select is(
  public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000101',
      'explicit_city_detected',
      jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare')
    ),
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000102',
      'city_filter_applied',
      jsonb_build_object('city', 'leiden', 'source', 'query')
    ),
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000103',
      'city_filter_corrected',
      jsonb_build_object('city', 'leiden', 'source', 'filter')
    ),
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000104',
      'local_result_available',
      jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare')
    ),
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000105',
      'national_fallback_shown',
      jsonb_build_object('city', 'leiden', 'intent_id', 'legal-help')
    ),
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000106',
      'wrong_geo_result_reported',
      jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare')
    ),
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000107',
      'action_panel_cta_clicked',
      jsonb_build_object(
        'city', 'leiden',
        'content_id', 'national.healthcare.municipality.leiden'
      )
    ),
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000108',
      'time_to_first_action',
      jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare', 'duration_ms', 750)
    )
  )),
  8,
  'all eight geo relevance events are accepted with canonical properties'
);
reset role;

select is(
  (
    select count(*)
    from public.app_events
    where client_event_id between
      '10000000-0000-4000-8000-000000000101'::uuid
      and '10000000-0000-4000-8000-000000000108'::uuid
  ),
  8::bigint,
  'the eight accepted geo events are stored exactly once'
);
select ok(
  not exists (
    select 1
    from public.app_events event
    cross join lateral jsonb_object_keys(event.properties) property(key)
    where event.client_event_id between
        '10000000-0000-4000-8000-000000000101'::uuid
        and '10000000-0000-4000-8000-000000000108'::uuid
      and property.key not in ('city', 'intent_id', 'source', 'content_id', 'duration_ms')
  ),
  'stored geo properties contain only the canonical bounded keys'
);
select ok(
  not exists (
    select 1
    from public.app_events
    where client_event_id between
        '10000000-0000-4000-8000-000000000101'::uuid
        and '10000000-0000-4000-8000-000000000108'::uuid
      and city is not null
  ),
  'geo events never duplicate or accept the legacy top-level city field'
);
select ok(
  not exists (
    select 1
    from public.app_events event
    cross join lateral jsonb_object_keys(event.properties) property(key)
    where event.client_event_id between
        '10000000-0000-4000-8000-000000000101'::uuid
        and '10000000-0000-4000-8000-000000000108'::uuid
      and (
        property.key ~* '(email|phone|ip|address|query|message|latitude|longitude)'
        or event.properties ->> property.key ~ '[@\r\n]'
      )
  ),
  'stored geo properties contain no query, PII, coordinate or free-message key/value'
);

-- The pre-existing first-result, source and generic events remain compatible.
set local role service_role;
select is(
  public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000111',
      'page_view',
      '{}'::jsonb
    ),
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000112',
      'search_result_opened',
      jsonb_build_object(
        'content_id', 'national.healthcare',
        'position', 1,
        'normalized_query_safe', 'healthcare leiden'
      )
    ),
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000113',
      'official_source_click',
      jsonb_build_object('content_id', 'national.healthcare')
    ),
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000114',
      'item_saved',
      jsonb_build_object('content_id', 'national.healthcare')
    )
  )),
  4,
  'existing page, first-result, official-source and saved-item events stay compatible'
);
reset role;

select is(
  (
    select count(*)
    from public.app_events
    where client_event_id between
      '10000000-0000-4000-8000-000000000111'::uuid
      and '10000000-0000-4000-8000-000000000114'::uuid
  ),
  4::bigint,
  'all four compatibility fixtures are stored'
);
select is(
  (
    select properties ->> 'position'
    from public.app_events
    where client_event_id = '10000000-0000-4000-8000-000000000112'
  ),
  '1',
  'the existing first-result click preserves its bounded position'
);
select is(
  (
    select properties ->> 'content_id'
    from public.app_events
    where client_event_id = '10000000-0000-4000-8000-000000000113'
  ),
  'national.healthcare',
  'the existing official-source click preserves its canonical content identifier'
);

-- Fail closed on queries, PII, free text, invalid scope sources and unknown events.
set local role service_role;
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000121',
      'explicit_city_detected',
      jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare', 'raw_query', 'my private query')
    )
  ))$$,
  '22023',
  'event properties contain unsupported data',
  'raw query keys are rejected'
);
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000122',
      'explicit_city_detected',
      jsonb_build_object(
        'city', 'leiden',
        'intent_id', 'healthcare',
        'normalized_query_safe', 'my private query'
      )
    )
  ))$$,
  '22023',
  'geo outcome event properties are invalid',
  'an old allowlisted search field cannot smuggle a query into a geo event'
);
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000123',
      'explicit_city_detected',
      jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare')
    ) || jsonb_build_object('email', 'private@example.invalid')
  ))$$,
  '22023',
  'event contains unsupported fields',
  'top-level PII fields are rejected'
);
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000124',
      'explicit_city_detected',
      jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare', 'email', 'private@example.invalid')
    )
  ))$$,
  '22023',
  'event properties contain unsupported data',
  'PII property keys are rejected'
);
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000125',
      'explicit_city_detected',
      jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare'),
      'Jane Doe'
    )
  ))$$,
  '22023',
  'geo events do not accept top-level city',
  'a person name cannot be smuggled through the legacy top-level city field'
);
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000126',
      'action_panel_cta_clicked',
      jsonb_build_object('city', 'leiden', 'content_id', 'private@example.invalid')
    )
  ))$$,
  '22023',
  'action panel event properties are invalid',
  'Action Panel content identifiers reject email and free text'
);
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000127',
      'city_filter_corrected',
      jsonb_build_object('city', 'leiden', 'source', 'profile')
    )
  ))$$,
  '22023',
  'city filter event properties are invalid',
  'city correction source is limited to query or filter'
);
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000128',
      'geo_free_text',
      '{}'::jsonb
    )
  ))$$,
  '22023',
  'event name is not allowlisted',
  'unknown event names are rejected'
);
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000129',
      'time_to_first_action',
      jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare', 'duration_ms', 3600001)
    )
  ))$$,
  '22023',
  'time-to-action event properties are invalid',
  'time-to-first-action remains bounded to one hour'
);
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    pg_temp.geo_analytics_event(
      '10000000-0000-4000-8000-000000000130',
      'explicit_city_detected',
      jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare')
    ) - 'consent_version'
  ))$$,
  '22023',
  'analytics consent version is missing or unsupported',
  'an event without the approved analytics consent version is rejected'
);
select throws_ok(
  $$select public.ingest_analytics_batch(jsonb_build_array(
    jsonb_set(
      pg_temp.geo_analytics_event(
        '10000000-0000-4000-8000-000000000131',
        'explicit_city_detected',
        jsonb_build_object('city', 'leiden', 'intent_id', 'healthcare')
      ),
      '{consent_version}',
      '"revoked"'::jsonb
    )
  ))$$,
  '22023',
  'analytics consent version is missing or unsupported',
  'an unsupported or revoked consent marker is rejected'
);
reset role;

-- Defense in depth: even accidental grants do not expose or mutate analytics rows.
grant select, insert, update, delete on public.app_events to anon, authenticated;

set local role anon;
select is(
  (
    select count(*)
    from public.app_events
    where client_event_id = '10000000-0000-4000-8000-000000000101'
  ),
  0::bigint,
  'anon cannot read an analytics event even if SELECT is accidentally granted'
);
with affected as (
  update public.app_events
  set event_name = 'page_view'
  where client_event_id = '10000000-0000-4000-8000-000000000101'
  returning 1
)
select is(
  (select count(*) from affected),
  0::bigint,
  'anon cannot update analytics even if UPDATE is accidentally granted'
);
with affected as (
  delete from public.app_events
  where client_event_id = '10000000-0000-4000-8000-000000000101'
  returning 1
)
select is(
  (select count(*) from affected),
  0::bigint,
  'anon cannot delete analytics even if DELETE is accidentally granted'
);
select throws_ok(
  $$insert into public.app_events (
    client_event_id, app_instance_id, event_name, platform, properties,
    consent_version, schema_version, environment
  ) values (
    '10000000-0000-4000-8000-000000000141',
    '10000000-0000-4000-8000-000000000201',
    'page_view', 'Web', '{}'::jsonb, '2026-07-28', 1, 'test'
  )$$,
  '42501',
  null,
  'anon cannot insert analytics even if INSERT is accidentally granted'
);
reset role;

set local role authenticated;
select is(
  (
    select count(*)
    from public.app_events
    where client_event_id = '10000000-0000-4000-8000-000000000101'
  ),
  0::bigint,
  'an unapproved authenticated user cannot read analytics'
);
with affected as (
  update public.app_events
  set event_name = 'page_view'
  where client_event_id = '10000000-0000-4000-8000-000000000101'
  returning 1
)
select is(
  (select count(*) from affected),
  0::bigint,
  'an unapproved authenticated user cannot update analytics'
);
with affected as (
  delete from public.app_events
  where client_event_id = '10000000-0000-4000-8000-000000000101'
  returning 1
)
select is(
  (select count(*) from affected),
  0::bigint,
  'an unapproved authenticated user cannot delete analytics'
);
select throws_ok(
  $$insert into public.app_events (
    client_event_id, app_instance_id, event_name, platform, properties,
    consent_version, schema_version, environment
  ) values (
    '10000000-0000-4000-8000-000000000142',
    '10000000-0000-4000-8000-000000000201',
    'page_view', 'Web', '{}'::jsonb, '2026-07-28', 1, 'test'
  )$$,
  '42501',
  null,
  'an unapproved authenticated user cannot insert analytics'
);
reset role;

select is(
  (
    select count(*)
    from public.app_events
    where client_event_id between
      '10000000-0000-4000-8000-000000000101'::uuid
      and '10000000-0000-4000-8000-000000000114'::uuid
  ),
  12::bigint,
  'unauthorized read and mutation attempts leave every accepted fixture intact'
);
select ok(
  obj_description('public.ingest_analytics_batch(jsonb)'::regprocedure, 'pg_proc')
    like '%executable only by service_role%',
  'the function comment documents its service-role-only boundary'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'private.analytics_ingest_windows'::regclass)
    and not has_table_privilege('anon', 'private.analytics_ingest_windows', 'SELECT')
    and not has_table_privilege('authenticated', 'private.analytics_ingest_windows', 'SELECT'),
  'the private rate-limit window stays protected by RLS and minimal grants'
);
select ok(
  pg_get_functiondef('public.ingest_analytics_batch(jsonb)'::regprocedure)
    like '%event_count + v_count <= 120%'
    and pg_get_functiondef('public.ingest_analytics_batch(jsonb)'::regprocedure)
      like '%private.analytics_ingest_windows%',
  'the patched ingest RPC retains the existing per-instance abuse limit'
);

select * from finish();
rollback;
