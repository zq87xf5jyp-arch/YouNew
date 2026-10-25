-- Restore and verify managed application boundaries from THIS backup's companion.
-- Never recreate historical hardcoded policies or buckets over a current dump;
-- only the digest-bound snapshot captured beside the encrypted archive is used.
-- Supply the exact UTF-8 metadata companion JSON and its backup-manifest SHA256.
-- Connection locality is enforced by restore-postgres.sh before any mutation.
-- Do not infer client locality from inet_server_addr(): Docker loopback port
-- forwarding reaches a non-loopback address inside the disposable container.
-- This verifier rechecks the exact wrapper marker, including for local TCP.
-- The companion has {"metadata":{"buckets":[],"storage_policies":[],
-- "auth_user_triggers":[],"cron_jobs":[]}}. Owners/ACLs require the full
-- managed schema dump.
\getenv expected_restore_target_marker RESTORE_TARGET_MARKER
\if :{?expected_restore_target_marker}
\else
  \echo 'Restore requires the exact disposable target marker.'
  select 'missing disposable target marker'::boolean;
\endif
\getenv expected_managed_boundaries_json RESTORE_EXPECTED_MANAGED_BOUNDARIES_JSON
\getenv expected_managed_boundaries_sha256 RESTORE_EXPECTED_MANAGED_BOUNDARIES_SHA256
\if :{?expected_managed_boundaries_json}
\else
  \echo 'Restore requires the backup-bound managed-boundaries JSON companion.'
  select 'missing managed-boundaries companion'::boolean;
\endif
\if :{?expected_managed_boundaries_sha256}
\else
  \echo 'Restore requires the managed companion SHA256 from its backup manifest.'
  select 'missing managed-boundaries companion digest'::boolean;
\endif

begin;
create temporary table younew_expected_managed_boundaries (
  raw_json text not null,
  expected_sha256 text not null,
  target_marker text not null
) on commit drop;
insert into younew_expected_managed_boundaries values (
  :'expected_managed_boundaries_json', :'expected_managed_boundaries_sha256',
  :'expected_restore_target_marker'
);

do $restore_managed$
declare
  expected jsonb;
  item jsonb;
  existing_policy record;
  existing_trigger record;
  role_list text;
  statement text;
begin
  select raw_json::jsonb -> 'metadata' into expected
  from younew_expected_managed_boundaries;

  -- Bucket rows are data in Supabase-managed tables. Upsert their reviewed
  -- configuration because provider logical dumps can omit managed DDL.
  for item in select value from jsonb_array_elements(expected->'buckets') loop
    insert into storage.buckets (
      id, name, public, file_size_limit, allowed_mime_types
    ) values (
      item->>'id', item->>'name', (item->>'public')::boolean,
      nullif(item->>'file_size_limit', '')::bigint,
      case when jsonb_typeof(item->'allowed_mime_types') = 'array'
        then array(select jsonb_array_elements_text(item->'allowed_mime_types'))
        else null end
    )
    on conflict (id) do update set
      name = excluded.name,
      public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;
  end loop;

  -- Policies on storage.objects are managed-schema DDL and are intentionally
  -- absent from the logical schema dump. Rebuild the exact reviewed snapshot.
  for existing_policy in
    select policyname from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
  loop
    execute format('drop policy %I on storage.objects', existing_policy.policyname);
  end loop;

  for item in select value from jsonb_array_elements(expected->'storage_policies') loop
    if item->>'permissive' not in ('PERMISSIVE', 'RESTRICTIVE')
       or item->>'command' not in ('ALL', 'SELECT', 'INSERT', 'UPDATE', 'DELETE') then
      raise exception 'Managed companion contains an unsupported Storage policy shape';
    end if;
    select string_agg(format('%I', value), ', ' order by value)
      into role_list
      from jsonb_array_elements_text(item->'roles');
    if role_list is null then
      raise exception 'Managed companion Storage policy has no roles';
    end if;
    statement := format(
      'create policy %I on storage.objects as %s for %s to %s',
      item->>'name', item->>'permissive', item->>'command', role_list
    );
    if item->>'using' is not null then
      statement := statement || ' using (' || (item->>'using') || ')';
    end if;
    if item->>'withCheck' is not null then
      statement := statement || ' with check (' || (item->>'withCheck') || ')';
    end if;
    execute statement;
  end loop;

  -- auth.users application triggers are also outside the normal schema dump.
  for existing_trigger in
    select tgname from pg_trigger
    where tgrelid = 'auth.users'::regclass and not tgisinternal
  loop
    execute format('drop trigger %I on auth.users', existing_trigger.tgname);
  end loop;
  for item in select value from jsonb_array_elements(expected->'auth_user_triggers') loop
    execute item->>'definition';
  end loop;

  -- pg_cron is provider-managed and its job table is not part of the logical
  -- schema dump. Restore only namespaced YouNew schedules from the signed
  -- companion; unrelated platform jobs are left untouched.
  for item in
    select jsonb_build_object('jobid', jobid)
    from cron.job where jobname like 'younew-%'
  loop
    perform cron.unschedule((item->>'jobid')::bigint);
  end loop;
  for item in select value from jsonb_array_elements(expected->'cron_jobs') loop
    perform cron.schedule(item->>'name', item->>'schedule', item->>'command');
  end loop;
end;
$restore_managed$;

do $verify$
declare
  expected jsonb;
  actual jsonb;
  raw_text text;
  expected_digest text;
  expected_marker text;
begin
  select target_marker into expected_marker from younew_expected_managed_boundaries;
  if expected_marker !~ '^[a-zA-Z0-9._:-]+$'
     or to_regclass('younew_restore_guard.target_marker') is null then
    raise exception 'Managed restore verification requires the guarded disposable target';
  end if;
  if not exists (select 1 from younew_restore_guard.target_marker
                 where singleton is true and marker = expected_marker) then
    raise exception 'Disposable target marker is missing or does not match';
  end if;
  select raw_json, expected_sha256 into raw_text, expected_digest
  from younew_expected_managed_boundaries;
  if expected_digest !~ '^[0-9a-f]{64}$'
     or encode(extensions.digest(convert_to(raw_text, 'UTF8'), 'sha256'), 'hex') <> expected_digest then
    raise exception 'Managed companion digest does not match backup manifest';
  end if;
  expected := raw_text::jsonb -> 'metadata';
  if expected is null
     or jsonb_typeof(expected->'buckets') is distinct from 'array'
     or jsonb_typeof(expected->'storage_policies') is distinct from 'array'
     or jsonb_typeof(expected->'auth_user_triggers') is distinct from 'array'
     or jsonb_typeof(expected->'cron_jobs') is distinct from 'array' then
    raise exception 'Managed companion is missing required metadata arrays';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'id', id, 'name', name, 'public', public,
    'file_size_limit', file_size_limit, 'allowed_mime_types', allowed_mime_types
  ) order by id), '[]'::jsonb) into actual from storage.buckets;
  if actual <> expected->'buckets' then
    raise exception 'Restored bucket configuration differs from backup companion';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'name', policyname, 'permissive', permissive, 'roles', roles,
    'command', cmd,
    -- PostgreSQL may omit auth. from auth.uid() after rebuilding the exact
    -- expression. Normalize that deparser-only difference before comparison.
    'using', replace(qual, '(( SELECT uid() AS uid)', '(( SELECT auth.uid() AS uid)'),
    'withCheck', replace(with_check, '(( SELECT uid() AS uid)', '(( SELECT auth.uid() AS uid)')
  ) order by policyname), '[]'::jsonb) into actual
  from pg_policies where schemaname='storage' and tablename='objects';
  if actual <> expected->'storage_policies' then
    raise exception 'Restored Storage policies differ from backup companion'
      using detail = jsonb_pretty(jsonb_build_object(
        'expected', expected->'storage_policies',
        'actual', actual
      ));
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'name', tgname, 'definition', pg_get_triggerdef(oid)
  ) order by tgname), '[]'::jsonb) into actual
  from pg_trigger where tgrelid='auth.users'::regclass and not tgisinternal;
  if actual <> expected->'auth_user_triggers' then
    raise exception 'Restored auth user triggers differ from backup companion';
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'name', jobname, 'schedule', schedule, 'command', command
  ) order by jobname), '[]'::jsonb) into actual
  from cron.job where jobname like 'younew-%';
  if actual <> expected->'cron_jobs' then
    raise exception 'Restored YouNew cron schedules differ from backup companion';
  end if;
end;
$verify$;
commit;
