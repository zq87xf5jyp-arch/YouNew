begin;

-- Keep the existing production aggregates authoritative while counting the
-- App Store CTA as a key action. A CTA click is an acquisition intent signal;
-- it is never labelled as an App Store download.
create or replace view public.analytics_daily_metrics
with (security_invoker = true)
as
select
  date_trunc('day', occurred_at)::date as metric_date,
  platform,
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
  count(*) filter (
    where event_name in ('app_error', 'sync_failed')
  )::bigint as error_event_count,
  max(created_at) as last_ingested_at
from public.app_events
where environment = 'production'
group by date_trunc('day', occurred_at)::date, platform;

create or replace view public.analytics_page_metrics_daily
with (security_invoker = true)
as
select
  date_trunc('day', occurred_at)::date as metric_date,
  platform,
  screen,
  count(*) filter (where event_name in ('page_view', 'screen_view'))::bigint as page_views,
  count(distinct session_id) filter (where session_id is not null)::bigint as sessions,
  count(distinct app_instance_id)::bigint as active_instances,
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
  )::bigint as key_actions,
  max(occurred_at) as last_event_at
from public.app_events
where environment = 'production'
  and screen is not null
  and char_length(screen) between 1 and 160
group by date_trunc('day', occurred_at)::date, platform, screen;

create or replace view public.analytics_audience_metrics_daily
with (security_invoker = true)
as
select
  date_trunc('day', occurred_at)::date as metric_date,
  'platform'::text as dimension,
  platform as value,
  count(*)::bigint as events,
  count(distinct session_id) filter (where session_id is not null)::bigint as sessions,
  count(distinct app_instance_id)::bigint as active_instances,
  max(occurred_at) as last_event_at
from public.app_events
where environment = 'production'
group by date_trunc('day', occurred_at)::date, platform
union all
select
  date_trunc('day', occurred_at)::date,
  'language'::text,
  language,
  count(*)::bigint,
  count(distinct session_id) filter (where session_id is not null)::bigint,
  count(distinct app_instance_id)::bigint,
  max(occurred_at)
from public.app_events
where environment = 'production'
  and language is not null
  and char_length(language) between 2 and 12
group by date_trunc('day', occurred_at)::date, language
union all
select
  date_trunc('day', occurred_at)::date,
  'city'::text,
  city,
  count(*)::bigint,
  count(distinct session_id) filter (where session_id is not null)::bigint,
  count(distinct app_instance_id)::bigint,
  max(occurred_at)
from public.app_events
where environment = 'production'
  and city is not null
  and char_length(city) between 1 and 80
group by date_trunc('day', occurred_at)::date, city
union all
select
  date_trunc('day', occurred_at)::date,
  'app_version'::text,
  app_version,
  count(*)::bigint,
  count(distinct session_id) filter (where session_id is not null)::bigint,
  count(distinct app_instance_id)::bigint,
  max(occurred_at)
from public.app_events
where environment = 'production'
  and app_version is not null
  and char_length(app_version) between 1 and 40
group by date_trunc('day', occurred_at)::date, app_version;

create or replace view public.analytics_session_quality_daily
with (security_invoker = true)
as
select
  date_trunc('day', started_at)::date as metric_date,
  platform,
  count(*)::bigint as sessions,
  count(*) filter (where coalesce(duration_seconds, 0) >= 10)::bigint as engaged_sessions,
  round(avg(least(greatest(coalesce(duration_seconds, 0), 0), 1800))::numeric, 1) as average_duration_seconds_capped,
  round((percentile_cont(0.5) within group (
    order by greatest(coalesce(duration_seconds, 0), 0)
  ))::numeric, 1) as median_duration_seconds,
  max(last_seen_at) as last_seen_at
from public.app_sessions
where environment = 'production'
group by date_trunc('day', started_at)::date, platform;

create or replace view public.analytics_conversion_funnel_daily
with (security_invoker = true)
as
select
  date_trunc('day', occurred_at)::date as metric_date,
  platform,
  case event_name
    when 'page_view' then 'visit'
    when 'screen_view' then 'visit'
    when 'search' then 'search'
    when 'search_result_opened' then 'result_open'
    when 'official_source_click' then 'source_open'
    when 'official_source_opened' then 'source_open'
    when 'item_saved' then 'save'
    when 'app_cta_click' then 'app_store_intent'
    when 'business_mailto_prepared' then 'business_intent'
  end as funnel_step,
  count(*)::bigint as events,
  count(distinct session_id) filter (where session_id is not null)::bigint as sessions,
  max(occurred_at) as last_event_at
from public.app_events
where environment = 'production'
  and event_name in (
    'page_view',
    'screen_view',
    'search',
    'search_result_opened',
    'official_source_click',
    'official_source_opened',
    'item_saved',
    'app_cta_click',
    'business_mailto_prepared'
  )
group by
  date_trunc('day', occurred_at)::date,
  platform,
  case event_name
    when 'page_view' then 'visit'
    when 'screen_view' then 'visit'
    when 'search' then 'search'
    when 'search_result_opened' then 'result_open'
    when 'official_source_click' then 'source_open'
    when 'official_source_opened' then 'source_open'
    when 'item_saved' then 'save'
    when 'app_cta_click' then 'app_store_intent'
    when 'business_mailto_prepared' then 'business_intent'
  end;

create or replace view public.analytics_page_metrics_periods
with (security_invoker = true)
as
with periods(period_days) as (
  values (7), (30), (90)
)
select
  periods.period_days,
  app_events.platform,
  app_events.screen,
  count(*) filter (where app_events.event_name in ('page_view', 'screen_view'))::bigint as page_views,
  count(distinct app_events.session_id) filter (where app_events.session_id is not null)::bigint as sessions,
  count(distinct app_events.app_instance_id)::bigint as active_instances,
  count(*) filter (
    where app_events.event_name in (
      'official_source_click',
      'official_source_opened',
      'search_result_opened',
      'item_saved',
      'guide_step_completed',
      'business_mailto_prepared',
      'app_cta_click'
    )
  )::bigint as key_actions,
  max(app_events.occurred_at) as last_event_at
from periods
join public.app_events
  on app_events.occurred_at >= current_date - ((periods.period_days - 1) * interval '1 day')
where app_events.environment = 'production'
  and app_events.screen is not null
  and char_length(app_events.screen) between 1 and 160
group by periods.period_days, app_events.platform, app_events.screen;

create or replace view public.analytics_audience_metrics_periods
with (security_invoker = true)
as
with periods(period_days) as (
  values (7), (30), (90)
), dimensions as (
  select
    periods.period_days,
    app_events.platform,
    'language'::text as dimension,
    app_events.language as value,
    app_events.session_id,
    app_events.app_instance_id,
    app_events.occurred_at
  from periods
  join public.app_events
    on app_events.occurred_at >= current_date - ((periods.period_days - 1) * interval '1 day')
  where app_events.environment = 'production'
    and app_events.language is not null
    and char_length(app_events.language) between 2 and 12
  union all
  select
    periods.period_days,
    app_events.platform,
    'city'::text,
    app_events.city,
    app_events.session_id,
    app_events.app_instance_id,
    app_events.occurred_at
  from periods
  join public.app_events
    on app_events.occurred_at >= current_date - ((periods.period_days - 1) * interval '1 day')
  where app_events.environment = 'production'
    and app_events.city is not null
    and char_length(app_events.city) between 1 and 80
  union all
  select
    periods.period_days,
    app_events.platform,
    'app_version'::text,
    app_events.app_version,
    app_events.session_id,
    app_events.app_instance_id,
    app_events.occurred_at
  from periods
  join public.app_events
    on app_events.occurred_at >= current_date - ((periods.period_days - 1) * interval '1 day')
  where app_events.environment = 'production'
    and app_events.app_version is not null
    and char_length(app_events.app_version) between 1 and 40
)
select
  period_days,
  platform,
  dimension,
  value,
  count(*)::bigint as events,
  count(distinct session_id) filter (where session_id is not null)::bigint as sessions,
  count(distinct app_instance_id)::bigint as active_instances,
  max(occurred_at) as last_event_at
from dimensions
group by period_days, platform, dimension, value;

create or replace view public.analytics_session_quality_periods
with (security_invoker = true)
as
with periods(period_days) as (
  values (7), (30), (90)
)
select
  periods.period_days,
  app_sessions.platform,
  count(*)::bigint as sessions,
  count(*) filter (where coalesce(app_sessions.duration_seconds, 0) >= 10)::bigint as engaged_sessions,
  round(avg(least(greatest(coalesce(app_sessions.duration_seconds, 0), 0), 1800))::numeric, 1) as average_duration_seconds_capped,
  round((percentile_cont(0.5) within group (
    order by greatest(coalesce(app_sessions.duration_seconds, 0), 0)
  ))::numeric, 1) as median_duration_seconds,
  max(app_sessions.last_seen_at) as last_seen_at
from periods
join public.app_sessions
  on app_sessions.started_at >= current_date - ((periods.period_days - 1) * interval '1 day')
where app_sessions.environment = 'production'
group by periods.period_days, app_sessions.platform;

create or replace view public.analytics_conversion_funnel_periods
with (security_invoker = true)
as
with periods(period_days) as (
  values (7), (30), (90)
)
select
  periods.period_days,
  app_events.platform,
  case app_events.event_name
    when 'page_view' then 'visit'
    when 'screen_view' then 'visit'
    when 'search' then 'search'
    when 'search_result_opened' then 'result_open'
    when 'official_source_click' then 'source_open'
    when 'official_source_opened' then 'source_open'
    when 'item_saved' then 'save'
    when 'app_cta_click' then 'app_store_intent'
    when 'business_mailto_prepared' then 'business_intent'
  end as funnel_step,
  count(*)::bigint as events,
  count(distinct app_events.session_id) filter (where app_events.session_id is not null)::bigint as sessions,
  max(app_events.occurred_at) as last_event_at
from periods
join public.app_events
  on app_events.occurred_at >= current_date - ((periods.period_days - 1) * interval '1 day')
where app_events.environment = 'production'
  and app_events.event_name in (
    'page_view',
    'screen_view',
    'search',
    'search_result_opened',
    'official_source_click',
    'official_source_opened',
    'item_saved',
    'app_cta_click',
    'business_mailto_prepared'
  )
group by
  periods.period_days,
  app_events.platform,
  case app_events.event_name
    when 'page_view' then 'visit'
    when 'screen_view' then 'visit'
    when 'search' then 'search'
    when 'search_result_opened' then 'result_open'
    when 'official_source_click' then 'source_open'
    when 'official_source_opened' then 'source_open'
    when 'item_saved' then 'save'
    when 'app_cta_click' then 'app_store_intent'
    when 'business_mailto_prepared' then 'business_intent'
  end;

-- App Store Connect is a separate source of truth. Rows contain only daily,
-- country-level aggregates imported server-side; no customer identifiers are
-- accepted or stored.
create table if not exists public.app_store_metrics_daily (
  metric_date date not null,
  territory text not null,
  first_time_downloads integer,
  redownloads integer,
  updates integer,
  impressions integer,
  product_page_views integer,
  installations integer,
  app_sessions integer,
  crashes integer,
  source text not null default 'app_store_connect',
  source_report_version text,
  synced_at timestamptz not null default now(),
  primary key (metric_date, territory),
  constraint app_store_metrics_territory_format check (territory ~ '^[A-Z]{2}$'),
  constraint app_store_metrics_nonnegative check (
    coalesce(first_time_downloads, 0) >= 0
    and coalesce(redownloads, 0) >= 0
    and coalesce(updates, 0) >= 0
    and coalesce(impressions, 0) >= 0
    and coalesce(product_page_views, 0) >= 0
    and coalesce(installations, 0) >= 0
    and coalesce(app_sessions, 0) >= 0
    and coalesce(crashes, 0) >= 0
  )
);

create table if not exists public.analytics_source_sync_state (
  source text primary key,
  status text not null,
  last_attempt_at timestamptz not null,
  last_success_at timestamptz,
  latest_data_at timestamptz,
  detail text not null default '',
  constraint analytics_source_sync_name check (source ~ '^[a-z0-9_]{2,60}$'),
  constraint analytics_source_sync_status check (status in ('success', 'empty', 'error')),
  constraint analytics_source_sync_detail_bounds check (char_length(detail) <= 500)
);

alter table public.app_store_metrics_daily enable row level security;
alter table public.analytics_source_sync_state enable row level security;

drop policy if exists "approved admins read App Store metrics"
  on public.app_store_metrics_daily;
create policy "approved admins read App Store metrics"
on public.app_store_metrics_daily
for select
to authenticated
using (public.is_approved_admin());

drop policy if exists "approved admins read analytics source state"
  on public.analytics_source_sync_state;
create policy "approved admins read analytics source state"
on public.analytics_source_sync_state
for select
to authenticated
using (public.is_approved_admin());

revoke all on table public.analytics_page_metrics_daily from public, anon;
revoke all on table public.analytics_audience_metrics_daily from public, anon;
revoke all on table public.analytics_session_quality_daily from public, anon;
revoke all on table public.analytics_conversion_funnel_daily from public, anon;
revoke all on table public.analytics_page_metrics_periods from public, anon;
revoke all on table public.analytics_audience_metrics_periods from public, anon;
revoke all on table public.analytics_session_quality_periods from public, anon;
revoke all on table public.analytics_conversion_funnel_periods from public, anon;
revoke all on table public.app_store_metrics_daily from public, anon, authenticated;
revoke all on table public.analytics_source_sync_state from public, anon, authenticated;

grant select on table public.analytics_page_metrics_daily to authenticated;
grant select on table public.analytics_audience_metrics_daily to authenticated;
grant select on table public.analytics_session_quality_daily to authenticated;
grant select on table public.analytics_conversion_funnel_daily to authenticated;
grant select on table public.analytics_page_metrics_periods to authenticated;
grant select on table public.analytics_audience_metrics_periods to authenticated;
grant select on table public.analytics_session_quality_periods to authenticated;
grant select on table public.analytics_conversion_funnel_periods to authenticated;
grant select on table public.app_store_metrics_daily to authenticated;
grant select on table public.analytics_source_sync_state to authenticated;
grant all on table public.app_store_metrics_daily to service_role;
grant all on table public.analytics_source_sync_state to service_role;

comment on view public.analytics_page_metrics_daily is
  'Admin-only daily page and screen aggregates. Paths are query-free, bounded values accepted by the analytics ingest contract.';
comment on view public.analytics_audience_metrics_daily is
  'Admin-only daily platform, language, city, and app-version aggregates. Dashboard consumers suppress groups below the privacy threshold.';
comment on view public.analytics_session_quality_daily is
  'Admin-only daily session quality aggregates. Average duration is capped at 30 minutes per session; median is the primary duration statistic.';
comment on view public.analytics_conversion_funnel_daily is
  'Admin-only daily conversion steps. App Store intent is a CTA click and must not be presented as a download.';
comment on view public.analytics_page_metrics_periods is
  'Admin-only exact 7, 30, and 90-day page aggregates with distinct sessions.';
comment on view public.analytics_audience_metrics_periods is
  'Admin-only exact 7, 30, and 90-day audience aggregates; consumers suppress groups below the privacy threshold.';
comment on view public.analytics_session_quality_periods is
  'Admin-only exact 7, 30, and 90-day session aggregates with capped average and median duration.';
comment on view public.analytics_conversion_funnel_periods is
  'Admin-only exact 7, 30, and 90-day funnel aggregates by platform.';
comment on table public.app_store_metrics_daily is
  'Daily country-level App Store Connect aggregates imported server-side. No user or device identifiers.';
comment on table public.analytics_source_sync_state is
  'Server-written freshness and outcome state for private analytics sources; never stores credentials or user identifiers.';

commit;
