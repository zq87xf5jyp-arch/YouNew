select jsonb_pretty(jsonb_build_object(
  'fixture', 'synthetic-only',
  'postgres_version', current_setting('server_version'),
  'database_bytes', pg_database_size(current_database()),
  'schema', jsonb_build_object(
    'public_tables', (select count(*) from pg_tables where schemaname = 'public'),
    'private_tables', (select count(*) from pg_tables where schemaname = 'private'),
    'public_private_functions', (
      select count(*)
      from pg_proc procedure
      join pg_namespace schema on schema.oid = procedure.pronamespace
      where schema.nspname in ('public', 'private')
    ),
    'migration_records', (
      select count(*) from supabase_migrations.schema_migrations
    )
  ),
  'security', jsonb_build_object(
    'rls_disabled_tables', coalesce((
      select jsonb_agg(format('%I.%I', schema.nspname, relation.relname) order by schema.nspname, relation.relname)
      from pg_class relation
      join pg_namespace schema on schema.oid = relation.relnamespace
      where relation.relkind in ('r', 'p')
        and schema.nspname in ('public', 'private')
        and not relation.relrowsecurity
    ), '[]'::jsonb),
    'browser_grants_on_private_monetization_tables', (
      select count(*)
      from information_schema.table_privileges
      where table_schema = 'private'
        and table_name in (
          'retention_policies', 'retention_legal_holds',
          'retention_cleanup_runs', 'retention_cleanup_audit',
          'pilot_usage_events', 'pilot_usage_reports',
          'pilot_usage_report_segments'
        )
        and grantee in ('PUBLIC', 'anon', 'authenticated')
    )
  ),
  'indexes', jsonb_build_object(
    'public_private_count', (
      select count(*)
      from pg_indexes
      where schemaname in ('public', 'private')
    ),
    'required_present', not exists (
      select 1
      from (values
        ('public', 'business_inquiries', 'business_inquiries_status_created_at_idx'),
        ('public', 'business_inquiry_notifications', 'business_inquiry_notifications_status_created_at_idx'),
        ('public', 'app_events', 'app_events_created_at_idx'),
        ('private', 'retention_legal_holds', 'retention_legal_holds_pkey'),
        ('private', 'pilot_usage_events', 'pilot_usage_events_scope_period_idx'),
        ('private', 'pilot_usage_reports', 'pilot_usage_reports_expiry_idx')
      ) as required_index(schema_name, table_name, index_name)
      where not exists (
        select 1
        from pg_indexes observed
        where observed.schemaname = required_index.schema_name
          and observed.tablename = required_index.table_name
          and observed.indexname = required_index.index_name
      )
    )
  ),
  'scheduled_jobs', coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'jobname', jobname,
        'schedule', schedule,
        'command', command
      ) order by jobname
    )
    from cron.job
    where jobname in (
      'younew-monetization-retention-cleanup',
      'younew-sync-job-lease-reconciliation'
    )
  ), '[]'::jsonb),
  'counts', jsonb_build_object(
    'business_inquiries', (select count(*) from public.business_inquiries),
    'business_inquiry_notifications', (select count(*) from public.business_inquiry_notifications),
    'sync_jobs', (select count(*) from public.sync_jobs),
    'audit_logs', (select count(*) from public.audit_logs),
    'app_sessions', (select count(*) from public.app_sessions),
    'app_events', (select count(*) from public.app_events),
    'pilot_usage_events', (select count(*) from private.pilot_usage_events),
    'retention_legal_holds', (select count(*) from private.retention_legal_holds),
    'retention_policies', (select count(*) from private.retention_policies)
  )
));
