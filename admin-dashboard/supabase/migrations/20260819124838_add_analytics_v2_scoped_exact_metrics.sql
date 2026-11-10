-- Additive analytics v2 aggregates. The existing views remain available so the
-- current Admin bundle can be rolled back independently from this migration.
-- Every public view is SECURITY INVOKER and therefore keeps the approved-admin
-- RLS policies on app_events and app_sessions authoritative.

begin;

create index if not exists app_events_environment_platform_occurred_at_idx
  on public.app_events (environment, platform, occurred_at desc);

create view public.analytics_v2_daily_metrics
with (security_invoker = true)
as
with scoped_events as (
  select
    (event.occurred_at at time zone 'UTC')::date as metric_date,
    scope.platform_scope,
    event.app_instance_id,
    event.session_id,
    event.event_name,
    event.occurred_at,
    event.created_at
  from public.app_events event
  cross join lateral (
    values (event.platform), ('All'::text)
  ) as scope(platform_scope)
  where event.environment = 'production'
    and event.platform in ('Web', 'iOS')
    and event.occurred_at < now()
)
select
  metric_date,
  platform_scope,
  count(*)::bigint as event_count,
  count(distinct app_instance_id)::bigint as active_instances,
  count(distinct session_id) filter (where session_id is not null)::bigint as session_count,
  count(*) filter (
    where event_name in (
      'official_source_click',
      'official_source_opened',
      'search_result_opened',
      'item_saved',
      'guide_step_completed',
      'business_mailto_prepared',
      'app_cta_click'
    )
  )::bigint as key_action_count,
  count(*) filter (where event_name in ('app_error', 'sync_failed'))::bigint as error_event_count,
  max(occurred_at) as last_event_at,
  max(created_at) as last_ingested_at
from scoped_events
group by metric_date, platform_scope;

create view public.analytics_v2_overview_periods
with (security_invoker = true)
as
with period_bounds as (
  select
    period_days,
    (
      date_trunc('day', now() at time zone 'UTC') at time zone 'UTC'
      - ((period_days - 1) * interval '1 day')
    ) as period_start_at,
    now() as period_end_at
  from (values (7), (30), (90)) as period(period_days)
), scoped_events as (
  select
    bounds.period_days,
    bounds.period_start_at,
    bounds.period_end_at,
    scope.platform_scope,
    event.app_instance_id,
    event.session_id,
    event.event_name,
    event.properties,
    event.occurred_at,
    event.created_at
  from period_bounds bounds
  join public.app_events event
    on event.occurred_at >= bounds.period_start_at
   and event.occurred_at < bounds.period_end_at
  cross join lateral (
    values (event.platform), ('All'::text)
  ) as scope(platform_scope)
  where event.environment = 'production'
    and event.platform in ('Web', 'iOS')
)
select
  period_days,
  platform_scope,
  period_start_at,
  period_end_at,
  count(*)::bigint as event_count,
  count(distinct app_instance_id)::bigint as active_instances,
  count(distinct session_id) filter (where session_id is not null)::bigint as session_count,
  count(*) filter (where event_name in ('page_view', 'screen_view'))::bigint as page_screen_views,
  count(*) filter (where event_name in ('search', 'search_submitted'))::bigint as search_events,
  count(*) filter (
    where event_name in ('official_source_click', 'official_source_opened')
  )::bigint as source_open_events,
  count(*) filter (
    where event_name in (
      'official_source_click',
      'official_source_opened',
      'search_result_opened',
      'item_saved',
      'guide_step_completed',
      'business_mailto_prepared',
      'app_cta_click'
    )
  )::bigint as key_action_events,
  count(*) filter (where event_name in ('app_error', 'sync_failed'))::bigint as error_events,
  count(*) filter (where event_name = 'explicit_city_detected')::bigint as explicit_city_detected_events,
  count(*) filter (where event_name = 'city_filter_applied')::bigint as city_filter_applied_events,
  count(*) filter (where event_name = 'city_filter_corrected')::bigint as city_filter_corrected_events,
  count(*) filter (where event_name = 'local_result_available')::bigint as local_result_available_events,
  count(*) filter (where event_name = 'national_fallback_shown')::bigint as national_fallback_shown_events,
  count(*) filter (where event_name = 'wrong_geo_result_reported')::bigint as wrong_geo_result_reported_events,
  count(*) filter (where event_name = 'action_panel_cta_clicked')::bigint as action_panel_cta_events,
  count(distinct session_id) filter (
    where event_name = 'action_panel_cta_clicked' and session_id is not null
  )::bigint as action_panel_cta_sessions,
  count(*) filter (
    where event_name = 'search_result_opened'
      and case
        when jsonb_typeof(properties -> 'position') = 'number'
          then (properties ->> 'position')::numeric
        else null
      end = 1
  )::bigint as first_result_open_events,
  round((
    percentile_cont(0.5) within group (
      order by case
        when event_name = 'time_to_first_action'
          and jsonb_typeof(properties -> 'duration_ms') = 'number'
          then (properties ->> 'duration_ms')::numeric
        else null
      end
    )
  )::numeric, 1) as median_time_to_first_action_ms,
  max(occurred_at) as last_event_at,
  max(created_at) as last_ingested_at
from scoped_events
group by period_days, platform_scope, period_start_at, period_end_at;

create view public.analytics_v2_event_metrics_periods
with (security_invoker = true)
as
with period_bounds as (
  select
    period_days,
    (
      date_trunc('day', now() at time zone 'UTC') at time zone 'UTC'
      - ((period_days - 1) * interval '1 day')
    ) as period_start_at,
    now() as period_end_at
  from (values (7), (30), (90)) as period(period_days)
), scoped_events as (
  select
    bounds.period_days,
    scope.platform_scope,
    event.event_name,
    event.app_instance_id,
    event.session_id,
    event.occurred_at,
    event.created_at
  from period_bounds bounds
  join public.app_events event
    on event.occurred_at >= bounds.period_start_at
   and event.occurred_at < bounds.period_end_at
  cross join lateral (
    values (event.platform), ('All'::text)
  ) as scope(platform_scope)
  where event.environment = 'production'
    and event.platform in ('Web', 'iOS')
)
select
  period_days,
  platform_scope,
  event_name,
  count(*)::bigint as event_count,
  count(distinct app_instance_id)::bigint as active_instances,
  count(distinct session_id) filter (where session_id is not null)::bigint as session_count,
  max(occurred_at) as last_event_at,
  max(created_at) as last_ingested_at
from scoped_events
group by period_days, platform_scope, event_name;

create view public.analytics_v2_session_quality_periods
with (security_invoker = true)
as
with period_bounds as (
  select
    period_days,
    (
      date_trunc('day', now() at time zone 'UTC') at time zone 'UTC'
      - ((period_days - 1) * interval '1 day')
    ) as period_start_at,
    now() as period_end_at
  from (values (7), (30), (90)) as period(period_days)
), scoped_event_sessions as (
  select distinct
    bounds.period_days,
    scope.platform_scope,
    event.session_id
  from period_bounds bounds
  join public.app_events event
    on event.occurred_at >= bounds.period_start_at
   and event.occurred_at < bounds.period_end_at
  cross join lateral (
    values (event.platform), ('All'::text)
  ) as scope(platform_scope)
  where event.environment = 'production'
    and event.platform in ('Web', 'iOS')
    and event.session_id is not null
), matched_sessions as (
  select
    observed.period_days,
    observed.platform_scope,
    observed.session_id,
    session.session_id is not null as is_matched,
    session.platform as stored_platform,
    session.duration_seconds,
    session.last_seen_at
  from scoped_event_sessions observed
  left join public.app_sessions session
    on session.session_id = observed.session_id
   and session.environment = 'production'
)
select
  period_days,
  platform_scope,
  count(*)::bigint as session_count,
  count(*) filter (where is_matched)::bigint as matched_session_count,
  count(*) filter (where not is_matched)::bigint as missing_session_count,
  count(*) filter (
    where is_matched
      and platform_scope <> 'All'
      and stored_platform is distinct from platform_scope
  )::bigint as platform_mismatch_count,
  count(*) filter (
    where is_matched
      and (platform_scope = 'All' or stored_platform = platform_scope)
      and coalesce(duration_seconds, 0) >= 10
  )::bigint as engaged_session_count,
  round(
    avg(least(greatest(coalesce(duration_seconds, 0), 0), 1800))
      filter (
        where is_matched
          and (platform_scope = 'All' or stored_platform = platform_scope)
      ),
    1
  ) as average_duration_seconds_capped,
  round((
    percentile_cont(0.5) within group (
      order by greatest(coalesce(duration_seconds, 0), 0)
    ) filter (
      where is_matched
        and (platform_scope = 'All' or stored_platform = platform_scope)
    )
  )::numeric, 1) as median_duration_seconds,
  max(last_seen_at) filter (where is_matched) as last_seen_at
from matched_sessions
group by period_days, platform_scope;

create view public.analytics_v2_funnel_periods
with (security_invoker = true)
as
with period_bounds as (
  select
    period_days,
    (
      date_trunc('day', now() at time zone 'UTC') at time zone 'UTC'
      - ((period_days - 1) * interval '1 day')
    ) as period_start_at,
    now() as period_end_at
  from (values (7), (30), (90)) as period(period_days)
), scoped_events as (
  select
    bounds.period_days,
    scope.platform_scope,
    event.session_id,
    event.occurred_at,
    case
      when event.event_name in ('page_view', 'screen_view') then 'visit'
      when event.event_name in ('search', 'search_submitted') then 'search'
      when event.event_name = 'search_result_opened' then 'result_open'
      when event.event_name in ('official_source_click', 'official_source_opened') then 'source_open'
      when event.event_name = 'item_saved' then 'save'
      when event.event_name = 'app_cta_click' then 'app_store_intent'
      when event.event_name = 'business_mailto_prepared' then 'business_intent'
    end as funnel_step
  from period_bounds bounds
  join public.app_events event
    on event.occurred_at >= bounds.period_start_at
   and event.occurred_at < bounds.period_end_at
  cross join lateral (
    values (event.platform), ('All'::text)
  ) as scope(platform_scope)
  where event.environment = 'production'
    and event.platform in ('Web', 'iOS')
    and event.event_name in (
      'page_view',
      'screen_view',
      'search',
      'search_submitted',
      'search_result_opened',
      'official_source_click',
      'official_source_opened',
      'item_saved',
      'app_cta_click',
      'business_mailto_prepared'
    )
)
select
  period_days,
  platform_scope,
  funnel_step,
  count(*)::bigint as events,
  count(distinct session_id) filter (where session_id is not null)::bigint as sessions,
  max(occurred_at) as last_event_at
from scoped_events
group by period_days, platform_scope, funnel_step;

create view public.analytics_v2_complete_week_comparison
with (security_invoker = true)
as
with bounds as (
  select
    date_trunc('day', now() at time zone 'UTC') at time zone 'UTC' as current_end_at
), scoped_events as (
  select
    scope.platform_scope,
    event.session_id,
    event.event_name,
    event.occurred_at
  from bounds
  join public.app_events event
    on event.occurred_at >= bounds.current_end_at - interval '14 days'
   and event.occurred_at < bounds.current_end_at
  cross join lateral (
    values (event.platform), ('All'::text)
  ) as scope(platform_scope)
  where event.environment = 'production'
    and event.platform in ('Web', 'iOS')
)
select
  platform_scope,
  bounds.current_end_at - interval '7 days' as current_start_at,
  bounds.current_end_at as current_end_at,
  bounds.current_end_at - interval '14 days' as previous_start_at,
  bounds.current_end_at - interval '7 days' as previous_end_at,
  count(*) filter (
    where event.occurred_at >= bounds.current_end_at - interval '7 days'
  )::bigint as current_events,
  count(*) filter (
    where event.occurred_at < bounds.current_end_at - interval '7 days'
  )::bigint as previous_events,
  count(distinct event.session_id) filter (
    where event.session_id is not null
      and event.occurred_at >= bounds.current_end_at - interval '7 days'
  )::bigint as current_sessions,
  count(distinct event.session_id) filter (
    where event.session_id is not null
      and event.occurred_at < bounds.current_end_at - interval '7 days'
  )::bigint as previous_sessions,
  count(*) filter (
    where event.occurred_at >= bounds.current_end_at - interval '7 days'
      and event.event_name in (
        'official_source_click',
        'official_source_opened',
        'search_result_opened',
        'item_saved',
        'guide_step_completed',
        'business_mailto_prepared',
        'app_cta_click'
      )
  )::bigint as current_key_actions,
  count(*) filter (
    where event.occurred_at < bounds.current_end_at - interval '7 days'
      and event.event_name in (
        'official_source_click',
        'official_source_opened',
        'search_result_opened',
        'item_saved',
        'guide_step_completed',
        'business_mailto_prepared',
        'app_cta_click'
      )
  )::bigint as previous_key_actions
from scoped_events event
cross join bounds
group by platform_scope, bounds.current_end_at;

revoke all on table public.analytics_v2_daily_metrics from public, anon, authenticated;
revoke all on table public.analytics_v2_overview_periods from public, anon, authenticated;
revoke all on table public.analytics_v2_event_metrics_periods from public, anon, authenticated;
revoke all on table public.analytics_v2_session_quality_periods from public, anon, authenticated;
revoke all on table public.analytics_v2_funnel_periods from public, anon, authenticated;
revoke all on table public.analytics_v2_complete_week_comparison from public, anon, authenticated;

grant select on table public.analytics_v2_daily_metrics to authenticated;
grant select on table public.analytics_v2_overview_periods to authenticated;
grant select on table public.analytics_v2_event_metrics_periods to authenticated;
grant select on table public.analytics_v2_session_quality_periods to authenticated;
grant select on table public.analytics_v2_funnel_periods to authenticated;
grant select on table public.analytics_v2_complete_week_comparison to authenticated;

comment on view public.analytics_v2_daily_metrics is
  'Approved-admin daily Web, iOS and exact All telemetry aggregates on explicit UTC dates.';
comment on view public.analytics_v2_overview_periods is
  'Approved-admin exact 7, 30 and 90-day platform-scoped totals and aggregate geo relevance signals. Action Panel context is excluded from canonical key actions.';
comment on view public.analytics_v2_event_metrics_periods is
  'Approved-admin exact period event totals by Web, iOS and All scope; exposes no identifiers or event properties.';
comment on view public.analytics_v2_session_quality_periods is
  'Approved-admin event-period session denominator reconciled to optional app_sessions quality rows.';
comment on view public.analytics_v2_funnel_periods is
  'Approved-admin platform-scoped action funnel. search/search_submitted share one alias and Action Panel context is not double-counted.';
comment on view public.analytics_v2_complete_week_comparison is
  'Approved-admin comparison of the last seven complete UTC days with the preceding seven complete UTC days.';

commit;
