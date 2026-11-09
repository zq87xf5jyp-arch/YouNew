\set ON_ERROR_STOP on

do $verification$
begin
  -- The disposable 20260819124857 migration asserts every backfilled lease
  -- field and removes the synthetic row immediately, before later migrations.
  -- A failed assertion prevents its migration ledger entry from committing.
  if (select count(*) from supabase_migrations.schema_migrations
      where version in ('20260819124855', '20260819124856', '20260819124857')) <> 3 then
    raise exception 'legacy sync seed, backfill and assertion/cleanup migrations did not all complete';
  end if;
  if exists (
    select 1 from public.sync_jobs
    where id = '74000000-0000-4000-8000-000000000001'
  ) then
    raise exception 'verified legacy sync fixture was not removed before later migrations';
  end if;
end
$verification$;

select jsonb_build_object(
  'result', 'PASS',
  'fixture', 'synthetic_legacy_running_sync_job',
  'assertion_migration', '20260819124857',
  'fixture_removed_before_later_migrations', true
) as legacy_sync_backfill_evidence;

select case
  when count(*) = 0 then 'PASS synthetic legacy sync fixture removed'
  else 'FAIL synthetic legacy sync fixture remains'
end as cleanup_result
from public.sync_jobs
where id = '74000000-0000-4000-8000-000000000001';
