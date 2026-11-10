begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(19);

select ok(
  (select relrowsecurity from pg_class where oid = 'private.analytics_ingest_windows'::regclass),
  'analytics ingest windows has RLS enabled'
);
select is(
  (
    select count(*)
    from pg_policies
    where schemaname = 'private' and tablename = 'analytics_ingest_windows'
  ),
  1::bigint,
  'analytics ingest windows has one explicit client rejection policy'
);
select ok(
  exists (
    select 1
    from pg_policies
    where schemaname = 'private'
      and tablename = 'analytics_ingest_windows'
      and cmd = 'ALL'
      and roles @> array['anon', 'authenticated']::name[]
      and qual = 'false'
      and with_check = 'false'
  ),
  'the client policy denies every operation to anon and authenticated'
);
select ok(
  not has_table_privilege('anon', 'private.analytics_ingest_windows', 'SELECT')
    and not has_table_privilege('anon', 'private.analytics_ingest_windows', 'INSERT')
    and not has_table_privilege('anon', 'private.analytics_ingest_windows', 'UPDATE')
    and not has_table_privilege('anon', 'private.analytics_ingest_windows', 'DELETE'),
  'anon has no direct table privileges'
);
select ok(
  not has_table_privilege('authenticated', 'private.analytics_ingest_windows', 'SELECT')
    and not has_table_privilege('authenticated', 'private.analytics_ingest_windows', 'INSERT')
    and not has_table_privilege('authenticated', 'private.analytics_ingest_windows', 'UPDATE')
    and not has_table_privilege('authenticated', 'private.analytics_ingest_windows', 'DELETE'),
  'authenticated has no direct table privileges'
);
select ok(
  has_table_privilege('service_role', 'private.analytics_ingest_windows', 'SELECT'),
  'service_role can select ingest windows'
);
select ok(
  has_table_privilege('service_role', 'private.analytics_ingest_windows', 'INSERT'),
  'service_role can insert ingest windows'
);
select ok(
  has_table_privilege('service_role', 'private.analytics_ingest_windows', 'UPDATE'),
  'service_role can update ingest windows'
);
select ok(
  has_table_privilege('service_role', 'private.analytics_ingest_windows', 'DELETE'),
  'service_role can delete ingest windows'
);
select ok(
  not has_function_privilege('anon', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'),
  'anon cannot execute the ingest RPC'
);
select ok(
  not has_function_privilege('authenticated', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'),
  'authenticated cannot execute the ingest RPC'
);
select ok(
  has_function_privilege('service_role', 'public.ingest_analytics_batch(jsonb)', 'EXECUTE'),
  'service_role can execute the ingest RPC'
);

set local role service_role;
select lives_ok(
  $$
    insert into private.analytics_ingest_windows (
      app_instance_id, window_start, event_count
    ) values (
      'pgtap-service-role', date_trunc('minute', now()), 1
    )
  $$,
  'service_role can insert a rate-limit window through its bypass role'
);
select lives_ok(
  $$
    update private.analytics_ingest_windows
    set event_count = 2
    where app_instance_id = 'pgtap-service-role'
  $$,
  'service_role can update a rate-limit window through its bypass role'
);
select lives_ok(
  $$
    delete from private.analytics_ingest_windows
    where app_instance_id = 'pgtap-service-role'
  $$,
  'service_role can delete a rate-limit window through its bypass role'
);
reset role;

grant usage on schema private to anon, authenticated;
grant select, insert, update, delete on private.analytics_ingest_windows to anon, authenticated;

set local role anon;
select is(
  (select count(*) from private.analytics_ingest_windows),
  0::bigint,
  'RLS still hides ingest windows from anon if table privileges are accidentally granted'
);
select throws_ok(
  $$
    insert into private.analytics_ingest_windows (
      app_instance_id, window_start, event_count
    ) values (
      'pgtap-anon', date_trunc('minute', now()), 1
    )
  $$,
  '42501',
  null,
  'the explicit RLS policy rejects anon writes'
);
reset role;

set local role authenticated;
select is(
  (select count(*) from private.analytics_ingest_windows),
  0::bigint,
  'RLS still hides ingest windows from authenticated if table privileges are accidentally granted'
);
select throws_ok(
  $$
    insert into private.analytics_ingest_windows (
      app_instance_id, window_start, event_count
    ) values (
      'pgtap-authenticated', date_trunc('minute', now()), 1
    )
  $$,
  '42501',
  null,
  'the explicit RLS policy rejects authenticated writes'
);
reset role;

select * from finish();
rollback;
