-- REVIEW PACKAGE ONLY.
-- Generated with Supabase CLI 2.109.1.
-- These indexes address the 13 unindexed-foreign-key findings confirmed on
-- 2026-07-27. Re-run the advisor if production schema drift is detected.

set lock_timeout = '5s';
set statement_timeout = '120s';

do $index_guard$
declare
  actual_unindexed_constraints text[];
  expected_unindexed_constraints constant text[] := array[
    'ai_knowledge_items_category_id_fkey',
    'audit_logs_user_id_fkey',
    'bugs_assigned_to_fkey',
    'bugs_created_by_fkey',
    'bugs_linked_screenshot_id_fkey',
    'categories_author_id_fkey',
    'faq_items_category_id_fkey',
    'release_checklist_items_linked_bug_id_fkey',
    'release_checklist_items_release_id_fkey',
    'resources_author_id_fkey',
    'resources_category_id_fkey',
    'screenshots_created_by_fkey',
    'sync_jobs_created_by_fkey'
  ];
begin
  select array_agg(
    constraint_definition.conname
    order by constraint_definition.conname
  )
  into actual_unindexed_constraints
  from pg_constraint constraint_definition
  join pg_class table_definition
    on table_definition.oid = constraint_definition.conrelid
  join pg_namespace table_schema
    on table_schema.oid = table_definition.relnamespace
  where constraint_definition.contype = 'f'
    and table_schema.nspname = 'public'
    and not exists (
      select 1
      from pg_index index_definition
      where index_definition.indrelid = constraint_definition.conrelid
        and index_definition.indisvalid
        and index_definition.indisready
        and (index_definition.indkey::smallint[])[
          0:cardinality(constraint_definition.conkey) - 1
        ] = constraint_definition.conkey
    );

  if actual_unindexed_constraints is distinct from
    expected_unindexed_constraints then
    raise exception
      'Unindexed foreign-key snapshot has drifted: expected %, found %',
      expected_unindexed_constraints,
      actual_unindexed_constraints;
  end if;
end
$index_guard$;

create index ai_knowledge_items_category_id_idx
  on public.ai_knowledge_items (category_id);
create index audit_logs_user_id_idx
  on public.audit_logs (user_id);
create index bugs_assigned_to_idx
  on public.bugs (assigned_to);
create index bugs_created_by_idx
  on public.bugs (created_by);
create index bugs_linked_screenshot_id_idx
  on public.bugs (linked_screenshot_id);
create index categories_author_id_idx
  on public.categories (author_id);
create index faq_items_category_id_idx
  on public.faq_items (category_id);
create index release_checklist_items_linked_bug_id_idx
  on public.release_checklist_items (linked_bug_id);
create index release_checklist_items_release_id_idx
  on public.release_checklist_items (release_id);
create index resources_author_id_idx
  on public.resources (author_id);
create index resources_category_id_idx
  on public.resources (category_id);
create index screenshots_created_by_idx
  on public.screenshots (created_by);
create index sync_jobs_created_by_idx
  on public.sync_jobs (created_by);

do $index_postcondition$
declare
  invalid_indexes text[];
begin
  select array_agg(
    required_index.index_name
    order by required_index.index_name
  )
  into invalid_indexes
  from (
    values
      ('ai_knowledge_items', 'ai_knowledge_items_category_id_idx', 'category_id'),
      ('audit_logs', 'audit_logs_user_id_idx', 'user_id'),
      ('bugs', 'bugs_assigned_to_idx', 'assigned_to'),
      ('bugs', 'bugs_created_by_idx', 'created_by'),
      ('bugs', 'bugs_linked_screenshot_id_idx', 'linked_screenshot_id'),
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
      and (index_definition.indkey::smallint[])[0] = indexed_column.attnum
  );

  if invalid_indexes is not null then
    raise exception
      'Required foreign-key indexes are absent or invalid: %',
      invalid_indexes;
  end if;
end
$index_postcondition$;

reset statement_timeout;
reset lock_timeout;
