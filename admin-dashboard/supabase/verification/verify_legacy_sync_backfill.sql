\set ON_ERROR_STOP on

do $verification$
begin
  if not exists (
    select 1
    from public.sync_jobs
    where id = '74000000-0000-4000-8000-000000000001'
      and status = 'running'
      and queued_at is not null
      and started_at is not null
      and heartbeat_at is not null
      and lease_expires_at is not null
      and lease_token is not null
      and attempt_count >= 1
      and lease_expires_at = started_at + interval '15 minutes'
      and details ->> 'lease_migration' = 'legacy_backfill'
  ) then
    raise exception 'legacy running sync job was not normalized before lease validation';
  end if;
end
$verification$;

select jsonb_build_object(
  'result', 'PASS',
  'fixture', 'synthetic_legacy_running_sync_job',
  'status', status,
  'queued_at_present', queued_at is not null,
  'heartbeat_present', heartbeat_at is not null,
  'lease_present', lease_expires_at is not null and lease_token is not null,
  'attempt_count', attempt_count,
  'backfill_marker', details ->> 'lease_migration'
) as legacy_sync_backfill_evidence
from public.sync_jobs
where id = '74000000-0000-4000-8000-000000000001';

delete from public.sync_jobs
where id = '74000000-0000-4000-8000-000000000001';

select case
  when count(*) = 0 then 'PASS synthetic legacy sync fixture removed'
  else 'FAIL synthetic legacy sync fixture remains'
end as cleanup_result
from public.sync_jobs
where id = '74000000-0000-4000-8000-000000000001';
