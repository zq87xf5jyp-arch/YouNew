begin;

update public.app_events
set environment = 'test'
where consent_version = 'legacy-test';

update public.app_sessions
set environment = 'test'
where consent_version = 'legacy-test';

create index if not exists app_events_created_at_idx
  on public.app_events (created_at);
create index if not exists app_sessions_created_at_idx
  on public.app_sessions (created_at);

create or replace function private.prune_analytics_retention()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
  delete from public.app_events
  where created_at < now() - interval '90 days';

  delete from public.app_sessions
  where created_at < now() - interval '90 days';

  return null;
end
$function$;

revoke all on function private.prune_analytics_retention()
  from public, anon, authenticated;

drop trigger if exists prune_analytics_retention_before_insert
  on public.app_events;

create trigger prune_analytics_retention_before_insert
before insert on public.app_events
for each statement
execute function private.prune_analytics_retention();

create or replace view public.analytics_daily_metrics
with (security_invoker = true)
as
select
  date_trunc('day', occurred_at)::date as metric_date,
  platform,
  count(*)::bigint as event_count,
  count(distinct app_instance_id)::bigint as active_instances,
  count(distinct session_id)
    filter (where session_id is not null)::bigint as session_count,
  count(*) filter (
    where event_name in (
      'official_source_click',
      'official_source_opened',
      'search_result_opened',
      'item_saved',
      'guide_step_completed',
      'business_mailto_prepared'
    )
  )::bigint as key_action_count,
  count(*) filter (
    where event_name in ('app_error', 'sync_failed')
  )::bigint as error_event_count,
  max(created_at) as last_ingested_at
from public.app_events
where environment = 'production'
group by date_trunc('day', occurred_at)::date, platform;

create or replace view public.analytics_event_funnel_daily
with (security_invoker = true)
as
select
  date_trunc('day', occurred_at)::date as metric_date,
  platform,
  event_name,
  count(*)::bigint as event_count,
  count(distinct app_instance_id)::bigint as active_instances,
  count(distinct session_id)
    filter (where session_id is not null)::bigint as session_count,
  max(created_at) as last_ingested_at
from public.app_events
where environment = 'production'
group by
  date_trunc('day', occurred_at)::date,
  platform,
  event_name;

create or replace view public.analytics_source_health
with (security_invoker = true)
as
select
  platform,
  count(*)::bigint as total_events,
  count(distinct app_instance_id)::bigint as active_instances,
  count(distinct session_id)
    filter (where session_id is not null)::bigint as sessions,
  min(occurred_at) as first_event_at,
  max(occurred_at) as last_event_at,
  max(created_at) as last_ingested_at,
  count(*) filter (
    where created_at - occurred_at > interval '15 minutes'
  )::bigint as delayed_events,
  count(*) filter (
    where event_name in ('app_error', 'sync_failed')
  )::bigint as error_events
from public.app_events
where environment = 'production'
group by platform;

comment on trigger prune_analytics_retention_before_insert
  on public.app_events is
  'Enforces the 90-day raw analytics retention boundary before each ingest statement.';

commit;
