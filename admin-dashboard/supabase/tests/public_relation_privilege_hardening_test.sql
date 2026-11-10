begin;

create extension if not exists pgtap with schema extensions;

select plan(10);

select ok(
  not exists (
    select 1
    from information_schema.table_privileges
    where table_schema = 'public'
      and grantee in ('PUBLIC', 'anon', 'authenticated')
      and privilege_type in ('TRUNCATE', 'REFERENCES', 'TRIGGER', 'MAINTAIN')
  ),
  'no public relation exposes owner-level privileges to browser roles'
);

select ok(
  not exists (
    select 1 from information_schema.table_privileges
    where table_schema = 'public' and grantee = 'anon'
      and privilege_type in ('TRUNCATE', 'REFERENCES', 'TRIGGER', 'MAINTAIN')
  ),
  'anon has no owner-level public relation privilege'
);

select ok(
  not exists (
    select 1 from information_schema.table_privileges
    where table_schema = 'public' and grantee = 'authenticated'
      and privilege_type in ('TRUNCATE', 'REFERENCES', 'TRIGGER', 'MAINTAIN')
  ),
  'authenticated has no owner-level public relation privilege'
);

select ok(
  not exists (
    select 1 from information_schema.table_privileges
    where table_schema = 'public' and grantee = 'PUBLIC'
      and privilege_type in ('TRUNCATE', 'REFERENCES', 'TRIGGER', 'MAINTAIN')
  ),
  'PUBLIC has no owner-level public relation privilege'
);

select ok(
  not exists (
    select 1
    from pg_default_acl default_acl
    left join pg_namespace namespace on namespace.oid = default_acl.defaclnamespace
    cross join lateral aclexplode(default_acl.defaclacl) expanded
    where pg_get_userbyid(default_acl.defaclrole) = 'postgres'
      and namespace.nspname = 'public'
      and default_acl.defaclobjtype = 'r'
      and (
        expanded.grantee = 0
        or pg_get_userbyid(expanded.grantee) in ('anon', 'authenticated')
      )
  ),
  'postgres future public relations have no implicit browser grant'
);

select ok(
  not exists (
    select 1
    from pg_default_acl default_acl
    left join pg_namespace namespace on namespace.oid = default_acl.defaclnamespace
    cross join lateral aclexplode(default_acl.defaclacl) expanded
    where pg_get_userbyid(default_acl.defaclrole) = 'supabase_admin'
      and namespace.nspname = 'public'
      and default_acl.defaclobjtype = 'r'
      and (
        expanded.grantee = 0
        or pg_get_userbyid(expanded.grantee) in ('anon', 'authenticated')
      )
  ),
  'supabase_admin future public relations have no implicit browser grant'
);

select ok(
  has_table_privilege('anon', 'public.public_content_feed', 'SELECT'),
  'anon keeps explicit public content feed SELECT'
);

select ok(
  has_table_privilege('authenticated', 'public.public_content_feed', 'SELECT'),
  'authenticated keeps explicit public content feed SELECT'
);

select ok(
  has_table_privilege('authenticated', 'public.content_governance_effective', 'SELECT'),
  'authenticated keeps explicit governance view SELECT'
);

select ok(
  has_table_privilege('anon', 'public.legacy_map_points_read_only', 'SELECT'),
  'anon keeps the explicit one-release legacy map SELECT'
);

select * from finish();

rollback;
