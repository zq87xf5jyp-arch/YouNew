\set ON_ERROR_STOP on

begin;
set local role service_role;

select jsonb_pretty(jsonb_build_object(
  'map', jsonb_build_object(
    'legacy_rows', (select count(*) from public.legacy_map_points_read_only),
    'legacy_mutation_grant', has_table_privilege('authenticated', 'public.map_points', 'INSERT,UPDATE,DELETE')
  ),
  'official_links', jsonb_build_object(
    'legacy_active_rows', (select count(*) from public.legacy_official_links_active),
    'registry_rows', (select count(*) from public.official_link_registry_entries),
    'alias_rows', (select count(*) from public.official_link_aliases),
    'check_rows', (select count(*) from public.official_link_check_results),
    'duplicate_groups_dry_run', (select count(*) from public.preview_legacy_official_link_duplicates())
  ),
  'review_queue', jsonb_build_object(
    'total', (select count(*) from public.content_review_tasks),
    'unowned', (select count(*) from public.content_review_tasks where owner_id is null),
    'by_state', coalesce((
      select jsonb_object_agg(state::text, total)
      from (
        select state, count(*) as total
        from public.content_review_tasks
        group by state
      ) grouped
    ), '{}'::jsonb)
  ),
  'sync_reconciler_dry_run', coalesce((
    select jsonb_agg(jsonb_build_object(
      'reason', reason,
      'eligible_count', eligible_count,
      'changed_count', changed_count
    ) order by reason)
    from private.reconcile_stale_sync_jobs(true)
  ), '[]'::jsonb),
  'feedback', jsonb_build_object(
    'total', (select count(*) from public.feedback),
    'by_origin', coalesce((
      select jsonb_object_agg(record_origin, total)
      from (
        select record_origin, count(*) as total
        from public.feedback
        group by record_origin
      ) grouped
    ), '{}'::jsonb)
  )
)) as admin_operational_dry_run;

rollback;
