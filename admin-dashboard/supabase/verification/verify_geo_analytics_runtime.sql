\set ON_ERROR_STOP on

begin;

do $verification$
declare
  v_definition text := pg_get_functiondef(
    'public.ingest_analytics_batch(jsonb)'::regprocedure
  );
begin
  if not (
    select relrowsecurity
    from pg_class
    where oid = 'public.app_events'::regclass
  ) then
    raise exception 'public.app_events RLS is disabled';
  end if;

  if not (
    select relrowsecurity
    from pg_class
    where oid = 'public.app_sessions'::regclass
  ) then
    raise exception 'public.app_sessions RLS is disabled';
  end if;

  if not (
    select relrowsecurity
    from pg_class
    where oid = 'private.analytics_ingest_windows'::regclass
  ) then
    raise exception 'private.analytics_ingest_windows RLS is disabled';
  end if;

  if has_function_privilege(
      'anon', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'
    )
    or has_function_privilege(
      'authenticated', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'
    )
    or not has_function_privilege(
      'service_role', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'
    ) then
    raise exception 'analytics RPC grants do not match the service-only boundary';
  end if;

  if has_table_privilege('anon', 'public.app_events', 'SELECT')
    or has_table_privilege('anon', 'public.app_events', 'INSERT')
    or has_table_privilege('authenticated', 'public.app_events', 'INSERT')
    or has_table_privilege('authenticated', 'public.app_events', 'UPDATE')
    or has_table_privilege('authenticated', 'public.app_events', 'DELETE') then
    raise exception 'browser analytics grants exceed the reviewed boundary';
  end if;

  if not (
    v_definition like '%if v_consent is distinct from ''2026-07-28'' then%'
    and v_definition like '%geo events do not accept top-level city%'
    and v_definition like '%event_count + v_count <= 120%'
  ) then
    raise exception 'analytics RPC privacy or abuse guards are missing';
  end if;

  if (
    select count(*)
    from pg_indexes
    where schemaname = 'public'
      and indexname in (
        'app_events_name_time_idx',
        'app_events_instance_time_idx',
        'app_events_platform_time_idx',
        'app_events_session_time_idx'
      )
  ) <> 4 then
    raise exception 'one or more required analytics indexes are missing';
  end if;
end
$verification$;

select jsonb_pretty(jsonb_build_object(
  'database', current_database(),
  'fixture', 'synthetic-only',
  'rls', jsonb_build_object(
    'app_events', (
      select relrowsecurity from pg_class where oid = 'public.app_events'::regclass
    ),
    'app_sessions', (
      select relrowsecurity from pg_class where oid = 'public.app_sessions'::regclass
    ),
    'analytics_ingest_windows', (
      select relrowsecurity
      from pg_class
      where oid = 'private.analytics_ingest_windows'::regclass
    )
  ),
  'rpc_execute', jsonb_build_object(
    'anon', has_function_privilege(
      'anon', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'
    ),
    'authenticated', has_function_privilege(
      'authenticated', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'
    ),
    'service_role', has_function_privilege(
      'service_role', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'
    )
  ),
  'required_indexes', (
    select jsonb_agg(indexname order by indexname)
    from pg_indexes
    where schemaname = 'public'
      and indexname in (
        'app_events_name_time_idx',
        'app_events_instance_time_idx',
        'app_events_platform_time_idx',
        'app_events_session_time_idx'
      )
  ),
  'consent_missing_fails_closed',
    pg_get_functiondef('public.ingest_analytics_batch(jsonb)'::regprocedure)
      like '%if v_consent is distinct from ''2026-07-28'' then%',
  'rate_limit_retained',
    pg_get_functiondef('public.ingest_analytics_batch(jsonb)'::regprocedure)
      like '%event_count + v_count <= 120%'
));

rollback;
