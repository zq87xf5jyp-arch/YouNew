\set ON_ERROR_STOP on

-- Stable identities plus definition/security fingerprints. This catches a
-- same-named policy, function, view, index or constraint that was weakened.
select object_kind, identity, definition_md5
from (
  select
    'relation'::text as object_kind,
    format('%I.%I:%s', namespace.nspname, relation.relname, relation.relkind) as identity,
    md5(concat_ws('|',
      'owner=' || pg_get_userbyid(relation.relowner),
      'rls=' || relation.relrowsecurity::text,
      'force_rls=' || relation.relforcerowsecurity::text,
      'options=' || coalesce(array_to_string(relation.reloptions, ','), ''),
      'view=' || case when relation.relkind in ('v', 'm') then pg_get_viewdef(relation.oid, true) else '' end
    )) as definition_md5
  from pg_class relation
  join pg_namespace namespace on namespace.oid = relation.relnamespace
  where namespace.nspname in ('public', 'private', 'storage')
    and relation.relkind in ('r', 'p', 'v', 'm', 'S')

  union all

  select
    'column',
    format('%I.%I.%I', table_schema, table_name, column_name),
    md5(concat_ws('|',
      'position=' || ordinal_position::text,
      'type=' || data_type,
      'udt=' || udt_schema || '.' || udt_name,
      'nullable=' || is_nullable,
      'default=' || coalesce(column_default, ''),
      'identity=' || is_identity || ':' || coalesce(identity_generation, ''),
      'generated=' || is_generated || ':' || coalesce(generation_expression, ''),
      'collation=' || coalesce(collation_schema || '.' || collation_name, '')
    ))
  from information_schema.columns
  where table_schema in ('public', 'private', 'storage')

  union all

  select
    'function',
    format('%I.%I(%s)', namespace.nspname, routine.proname, pg_get_function_identity_arguments(routine.oid)),
    md5(concat_ws('|',
      pg_get_functiondef(routine.oid),
      'owner=' || pg_get_userbyid(routine.proowner),
      'security_definer=' || routine.prosecdef::text,
      'config=' || coalesce(array_to_string(routine.proconfig, ','), '')
    ))
  from pg_proc routine
  join pg_namespace namespace on namespace.oid = routine.pronamespace
  where namespace.nspname in ('public', 'private', 'storage')

  union all

  select
    'policy',
    format('%I.%I.%s', schemaname, tablename, policyname),
    md5(concat_ws('|',
      'permissive=' || permissive,
      'cmd=' || cmd,
      'roles=' || array_to_string(roles, ','),
      'using=' || coalesce(qual, ''),
      'check=' || coalesce(with_check, '')
    ))
  from pg_policies
  where schemaname in ('public', 'private', 'storage')

  union all

  select 'index', format('%I.%I', schemaname, indexname), md5(indexdef)
  from pg_indexes
  where schemaname in ('public', 'private', 'storage')

  union all

  select
    'constraint',
    format('%I.%I.%s', namespace.nspname, relation.relname, constraint_record.conname),
    md5(concat_ws('|',
      'type=' || constraint_record.contype::text,
      'deferrable=' || constraint_record.condeferrable::text,
      'deferred=' || constraint_record.condeferred::text,
      'validated=' || constraint_record.convalidated::text,
      pg_get_constraintdef(constraint_record.oid, true)
    ))
  from pg_constraint constraint_record
  join pg_class relation on relation.oid = constraint_record.conrelid
  join pg_namespace namespace on namespace.oid = relation.relnamespace
  where namespace.nspname in ('public', 'private', 'storage')

  union all

  select
    'trigger',
    format('%I.%I.%s', namespace.nspname, relation.relname, trigger_record.tgname),
    md5(concat_ws('|', 'enabled=' || trigger_record.tgenabled::text, pg_get_triggerdef(trigger_record.oid, true)))
  from pg_trigger trigger_record
  join pg_class relation on relation.oid = trigger_record.tgrelid
  join pg_namespace namespace on namespace.oid = relation.relnamespace
  where namespace.nspname in ('public', 'private', 'storage')
    and not trigger_record.tgisinternal

  union all

  select
    'table_grant',
    format('%I.%I:%s:%s', table_schema, table_name, grantee, privilege_type),
    md5('grantable=' || is_grantable)
  from information_schema.table_privileges
  where table_schema in ('public', 'private', 'storage')
    and grantee in ('PUBLIC', 'anon', 'authenticated', 'service_role')

  union all

  select
    'column_grant',
    format('%I.%I.%I:%s:%s', table_schema, table_name, column_name, grantee, privilege_type),
    md5('grantable=' || is_grantable)
  from information_schema.column_privileges
  where table_schema in ('public', 'private', 'storage')
    and grantee in ('PUBLIC', 'anon', 'authenticated', 'service_role')

  union all

  select
    'routine_grant',
    format('%I.%I(%s):%s:%s', namespace.nspname, routine.proname,
      pg_get_function_identity_arguments(routine.oid), routine_grant.grantee, routine_grant.privilege_type),
    md5('grantable=' || routine_grant.is_grantable)
  from information_schema.routine_privileges routine_grant
  join pg_proc routine on routine_grant.specific_name = routine.proname || '_' || routine.oid::text
  join pg_namespace namespace on namespace.oid = routine.pronamespace
  where namespace.nspname in ('public', 'private', 'storage')
    and routine_grant.grantee in ('PUBLIC', 'anon', 'authenticated', 'service_role')

  union all

  select
    'schema_grant',
    format('%I:%s:%s', namespace.nspname,
      case when expanded.grantee = 0 then 'PUBLIC' else pg_get_userbyid(expanded.grantee) end,
      expanded.privilege_type),
    md5('grantable=' || expanded.is_grantable::text)
  from pg_namespace namespace
  cross join lateral aclexplode(coalesce(namespace.nspacl, acldefault('n', namespace.nspowner))) expanded
  where namespace.nspname in ('public', 'private', 'storage')
    and (expanded.grantee = 0 or pg_get_userbyid(expanded.grantee) in ('anon', 'authenticated', 'service_role'))

  union all

  select
    'default_acl',
    format('%s:%s:%s:%s:%s',
      pg_get_userbyid(default_acl.defaclrole),
      coalesce(namespace.nspname, '*'),
      default_acl.defaclobjtype,
      case when expanded.grantee = 0 then 'PUBLIC' else pg_get_userbyid(expanded.grantee) end,
      expanded.privilege_type),
    md5('grantable=' || expanded.is_grantable::text)
  from pg_default_acl default_acl
  left join pg_namespace namespace on namespace.oid = default_acl.defaclnamespace
  cross join lateral aclexplode(default_acl.defaclacl) expanded
  where (namespace.nspname in ('public', 'private', 'storage') or default_acl.defaclnamespace = 0)
    and (expanded.grantee = 0 or pg_get_userbyid(expanded.grantee) in ('anon', 'authenticated', 'service_role'))
) inventory
order by object_kind, identity;
