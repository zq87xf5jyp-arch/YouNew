-- Read-only post-migration verification.
-- Run with a privileged SQL reviewer after both proposed migrations.

create temporary table younew_verification_results as
with checks(name, passed, evidence) as (
  values
    (
      'security definer functions left exposed in public',
      not exists (
        select 1
        from pg_proc function_definition
        join pg_namespace function_schema
          on function_schema.oid = function_definition.pronamespace
        where function_schema.nspname = 'public'
          and function_definition.proname in (
            'current_admin_role',
            'is_approved_admin',
            'handle_new_admin_user'
          )
      ),
      'Expected zero reviewed helper functions in public'
    ),
    (
      'private helper definitions',
      (
        select count(*) = 3
        from pg_proc function_definition
        join pg_namespace function_schema
          on function_schema.oid = function_definition.pronamespace
        where function_schema.nspname = 'private'
          and function_definition.proname in (
            'current_admin_role',
            'is_approved_admin',
            'handle_new_admin_user'
          )
          and function_definition.prosecdef
          and (
            function_definition.proconfig @> array['search_path=pg_catalog']
            or function_definition.proconfig @> array['search_path=""']
          )
      ),
      'Expected three SECURITY DEFINER functions with a fixed empty or pg_catalog search_path'
    ),
    (
      'anonymous helper execution',
      not has_function_privilege(
        'anon',
        'private.current_admin_role()',
        'EXECUTE'
      )
      and not has_function_privilege(
        'anon',
        'private.is_approved_admin()',
        'EXECUTE'
      )
      and not has_function_privilege(
        'anon',
        'private.handle_new_admin_user()',
        'EXECUTE'
      ),
      'Expected no anonymous EXECUTE privilege'
    ),
    (
      'authenticated helper execution boundary',
      has_function_privilege(
        'authenticated',
        'private.current_admin_role()',
        'EXECUTE'
      )
      and has_function_privilege(
        'authenticated',
        'private.is_approved_admin()',
        'EXECUTE'
      )
      and not has_function_privilege(
        'authenticated',
        'private.handle_new_admin_user()',
        'EXECUTE'
      ),
      'Authenticated may evaluate RLS helpers but may not invoke the auth trigger function'
    ),
    (
      'auth.users trigger preserved',
      exists (
        select 1
        from pg_trigger trigger_definition
        join pg_proc function_definition
          on function_definition.oid = trigger_definition.tgfoid
        join pg_namespace function_schema
          on function_schema.oid = function_definition.pronamespace
        where not trigger_definition.tgisinternal
          and trigger_definition.tgname = 'on_auth_user_created'
          and trigger_definition.tgrelid = 'auth.users'::regclass
          and function_schema.nspname = 'private'
          and function_definition.proname = 'handle_new_admin_user'
      ),
      'Expected auth.users trigger to reference private.handle_new_admin_user'
    ),
    (
      'unrestricted analytics write policies',
      not exists (
        select 1
        from pg_policies
        where schemaname = 'public'
          and tablename in ('app_events', 'app_sessions')
          and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
          and (
            coalesce(qual, '') = 'true'
            or coalesce(with_check, '') = 'true'
          )
      ),
      'Expected no always-true client write policy'
    ),
    (
      'analytics table privileges',
      not has_table_privilege('anon', 'public.app_events', 'INSERT')
      and not has_table_privilege('authenticated', 'public.app_events', 'INSERT')
      and not has_table_privilege('anon', 'public.app_sessions', 'INSERT')
      and not has_table_privilege('authenticated', 'public.app_sessions', 'INSERT')
      and has_table_privilege('authenticated', 'public.app_events', 'SELECT')
      and has_table_privilege('authenticated', 'public.app_sessions', 'SELECT'),
      'Expected authenticated admin reads and no direct client writes'
    ),
    (
      'high-risk client table privileges',
      not exists (
        select 1
        from (
          values
            ('ai_knowledge_items'),
            ('app_events'),
            ('app_sessions'),
            ('app_settings'),
            ('articles'),
            ('audit_logs'),
            ('bugs'),
            ('categories'),
            ('cities'),
            ('content_sync_state'),
            ('faq_items'),
            ('feedback'),
            ('map_points'),
            ('official_links'),
            ('profiles'),
            ('release_checklist_items'),
            ('releases'),
            ('resources'),
            ('screenshots'),
            ('sync_jobs')
        ) as reviewed_table(name)
        cross join (
          values ('anon'), ('authenticated')
        ) as client_role(name)
        cross join (
          values ('TRUNCATE'), ('REFERENCES'), ('TRIGGER')
        ) as high_risk_privilege(name)
        where has_table_privilege(
          client_role.name,
          format('public.%I', reviewed_table.name),
          high_risk_privilege.name
        )
      ),
      'Expected no client TRUNCATE, REFERENCES, or TRIGGER privilege'
    ),
    (
      'multiple permissive policies',
      not exists (
        select 1
        from (
          select
            policy_table.schemaname,
            policy_table.tablename,
            policy_role.role_name,
            policy_table.cmd,
            count(*) as policy_count
          from pg_policies policy_table
          cross join lateral unnest(policy_table.roles) as policy_role(role_name)
          where policy_table.permissive = 'PERMISSIVE'
          group by
            policy_table.schemaname,
            policy_table.tablename,
            policy_role.role_name,
            policy_table.cmd
          having count(*) > 1
        ) duplicate_policy
        where duplicate_policy.schemaname = 'public'
          and duplicate_policy.tablename in (
            'app_settings',
            'articles',
            'categories',
            'cities',
            'faq_items',
            'map_points',
            'profiles',
            'resources'
          )
      ),
      'Expected one permissive policy per affected role and command'
    ),
    (
      'foreign-key indexes',
      not exists (
        select 1
        from (
          values
            (
              'ai_knowledge_items',
              'ai_knowledge_items_category_id_idx',
              'category_id'
            ),
            ('audit_logs', 'audit_logs_user_id_idx', 'user_id'),
            ('bugs', 'bugs_assigned_to_idx', 'assigned_to'),
            ('bugs', 'bugs_created_by_idx', 'created_by'),
            (
              'bugs',
              'bugs_linked_screenshot_id_idx',
              'linked_screenshot_id'
            ),
            ('categories', 'categories_author_id_idx', 'author_id'),
            ('faq_items', 'faq_items_category_id_idx', 'category_id'),
            (
              'release_checklist_items',
              'release_checklist_items_linked_bug_id_idx',
              'linked_bug_id'
            ),
            (
              'release_checklist_items',
              'release_checklist_items_release_id_idx',
              'release_id'
            ),
            ('resources', 'resources_author_id_idx', 'author_id'),
            ('resources', 'resources_category_id_idx', 'category_id'),
            ('screenshots', 'screenshots_created_by_idx', 'created_by'),
            ('sync_jobs', 'sync_jobs_created_by_idx', 'created_by')
        ) as required_index(table_name, index_name, column_name)
        where not exists (
          select 1
          from pg_class table_definition
          join pg_namespace table_schema
            on table_schema.oid = table_definition.relnamespace
          join pg_attribute indexed_column
            on indexed_column.attrelid = table_definition.oid
            and indexed_column.attname = required_index.column_name
          join pg_index index_definition
            on index_definition.indrelid = table_definition.oid
          join pg_class index_relation
            on index_relation.oid = index_definition.indexrelid
          where table_schema.nspname = 'public'
            and table_definition.relname = required_index.table_name
            and index_relation.relname = required_index.index_name
            and index_definition.indisvalid
            and index_definition.indisready
            and index_definition.indnkeyatts = 1
            and index_definition.indnatts = 1
            and (index_definition.indkey::smallint[])[0] =
              indexed_column.attnum
        )
      ),
      'Expected all 13 valid advisor-requested single-column indexes'
    )
)
select name, passed, evidence
from checks
order by name;

select name, passed, evidence
from younew_verification_results
order by name;

do $verification$
begin
  if exists (
    select 1 from younew_verification_results where not passed
  ) then
    raise exception 'One or more YouNew database verification checks failed';
  end if;
end
$verification$;

-- Anonymous API visibility smoke counts. RLS must expose only published rows.
begin;
set local role anon;

select 'app_settings' as table_name, count(*) as visible_rows
from public.app_settings
union all
select 'articles', count(*) from public.articles
union all
select 'categories', count(*) from public.categories
union all
select 'cities', count(*) from public.cities
union all
select 'faq_items', count(*) from public.faq_items
union all
select 'map_points', count(*) from public.map_points
union all
select 'resources', count(*) from public.resources
order by table_name;

rollback;
