create temporary table younew_synthetic_restore_checks (
  name text primary key,
  passed boolean not null,
  evidence text not null
);

insert into younew_synthetic_restore_checks (name, passed, evidence)
values
  (
    'synthetic operational counts',
    (select count(*) = 2 from public.business_inquiries)
      and (select count(*) = 2 from public.business_inquiry_notifications)
      and (select count(*) = 0 from public.sync_jobs)
      and (select count(*) = 1 from public.app_sessions)
      and (select count(*) = 5 from public.app_events)
      and (select count(*) = 6 from private.pilot_usage_events)
      and (select count(*) = 1 from private.retention_legal_holds)
      and (select count(*) = 8 from private.retention_policies),
    'Expected only the deterministic synthetic restore fixture counts'
  ),
  (
    'public and private RLS',
    not exists (
      select 1
      from pg_class relation
      join pg_namespace schema on schema.oid = relation.relnamespace
      where relation.relkind in ('r', 'p')
        and schema.nspname in ('public', 'private')
        and not relation.relrowsecurity
    ),
    'Expected RLS on every application table in public and private'
  ),
  (
    'private browser grants',
    not exists (
      select 1
      from information_schema.table_privileges
      where table_schema = 'private'
        and table_name in (
          'retention_policies', 'retention_legal_holds',
          'retention_cleanup_runs', 'retention_cleanup_audit',
          'pilot_usage_events', 'pilot_usage_reports',
          'pilot_usage_report_segments'
        )
        and grantee in ('PUBLIC', 'anon', 'authenticated')
    ),
    'Expected no browser role grant on private monetization tables'
  ),
  (
    'required indexes',
    not exists (
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
    ),
    'Expected the six lead, notification, usage, hold and report indexes'
  ),
  (
    'full post-migration manifest',
    (
      select count(*) = :'expected_migration_count'::integer
      from supabase_migrations.schema_migrations
    ),
    'Expected the exact managed plus pending migration versions repaired from the manifest'
  ),
  (
    'scheduled operational jobs',
    (
      select count(*) = 1
      from cron.job
      where jobname = 'younew-monetization-retention-cleanup'
        and schedule = '17 3 * * *'
        and command = 'select * from private.run_retention_cleanup(false);'
    ) and (
      select count(*) = 1
      from cron.job
      where jobname = 'younew-sync-job-lease-reconciliation'
        and schedule = '*/5 * * * *'
        and command = 'select * from private.reconcile_stale_sync_jobs(true);'
    ),
    'Expected retention mutation and deliberately dry-run sync reconciliation schedules'
  ),
  (
    'managed storage buckets and content image boundary',
    (
      select count(*) = 1
      from storage.buckets
      where id = 'content' and name = 'content' and public is false
    ) and (
      select count(*) = 1
      from storage.buckets
      where id = 'screenshots' and name = 'screenshots' and public is false
    ) and (
      select count(*) = 1
      from storage.buckets
      where id = 'content-images'
        and name = 'content-images'
        and public is true
        and file_size_limit = 8388608
        and allowed_mime_types = array['image/avif', 'image/jpeg', 'image/png', 'image/webp']
    ) and not exists (
      select 1
      from pg_policies
      where schemaname = 'storage'
        and tablename = 'objects'
        and cmd in ('ALL', 'DELETE')
        and coalesce(qual, '') like '%content-images%'
    ) and exists (
      select 1
      from pg_policies
      where schemaname = 'storage'
        and tablename = 'objects'
        and policyname = 'approved roles update content images'
        and cmd = 'UPDATE'
        and coalesce(qual, '') like '%content_image_is_published%'
        and coalesce(with_check, '') like '%content_image_is_published%'
    ),
    'Expected canonical buckets, no browser content-image DELETE and published-image update protection'
  );

select name, passed, evidence
from younew_synthetic_restore_checks
order by name;

do $verification$
begin
  if exists (select 1 from younew_synthetic_restore_checks where not passed) then
    raise exception 'One or more synthetic restore verification checks failed'
      using detail = (
        select jsonb_pretty(jsonb_build_object(
          'counts', jsonb_build_object(
            'business_inquiries', (select count(*) from public.business_inquiries),
            'business_inquiry_notifications', (select count(*) from public.business_inquiry_notifications),
            'sync_jobs', (select count(*) from public.sync_jobs),
            'app_sessions', (select count(*) from public.app_sessions),
            'app_events', (select count(*) from public.app_events),
            'pilot_usage_events', (select count(*) from private.pilot_usage_events),
            'retention_legal_holds', (select count(*) from private.retention_legal_holds),
            'retention_policies', (select count(*) from private.retention_policies)
          ),
          'cron_jobs', coalesce((
            select jsonb_agg(jsonb_build_object(
              'name', jobname, 'schedule', schedule, 'command', command
            ) order by jobname)
            from cron.job where jobname like 'younew-%'
          ), '[]'::jsonb)
        ))
      );
  end if;
end
$verification$;
