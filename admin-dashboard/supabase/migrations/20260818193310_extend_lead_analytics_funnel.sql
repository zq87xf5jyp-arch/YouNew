-- Extend the existing privacy-safe analytics RPC without editing its applied
-- migration. Lead events carry no properties: form data, offer choices, receipt
-- IDs, and contact identifiers remain outside analytics.

create or replace function public.ingest_analytics_batch(p_events jsonb)
returns integer
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_event jsonb;
  v_properties jsonb;
  v_normalized jsonb := '[]'::jsonb;
  v_count integer;
  v_inserted integer := 0;
  v_instance text;
  v_session text;
  v_name text;
  v_platform text;
  v_screen text;
  v_version text;
  v_language text;
  v_city text;
  v_consent text;
  v_environment text;
  v_client_event_id text;
  v_occurred_at timestamptz;
  v_window timestamptz := date_trunc('minute', now());
  v_window_count integer;
  v_allowed_names constant text[] := array[
    'page_view',
    'search',
    'official_source_click',
    'partner_click',
    'app_cta_click',
    'profile_selected',
    'business_mailto_prepared',
    'lead_start',
    'lead_submit',
    'pilot_request',
    'analytics_consent_granted',
    'analytics_consent_revoked',
    'app_opened',
    'screen_view',
    'search_submitted',
    'search_result_opened',
    'category_opened',
    'official_source_opened',
    'item_saved',
    'item_unsaved',
    'guide_step_completed',
    'map_opened',
    'ai_question_sent',
    'sync_started',
    'sync_succeeded',
    'sync_failed',
    'app_error'
  ]::text[];
  v_allowed_property_keys constant text[] := array[
    'result_count',
    'has_results',
    'content_id',
    'location',
    'profile',
    'organization_type',
    'outcome',
    'error_code',
    'duration_ms'
  ]::text[];
begin
  if jsonb_typeof(p_events) <> 'array' then
    raise exception 'events must be a JSON array' using errcode = '22023';
  end if;

  v_count := jsonb_array_length(p_events);
  if v_count < 1 or v_count > 50 then
    raise exception 'events batch must contain between 1 and 50 items' using errcode = '22023';
  end if;

  for v_event in select value from jsonb_array_elements(p_events)
  loop
    if jsonb_typeof(v_event) <> 'object' then
      raise exception 'each event must be an object' using errcode = '22023';
    end if;

    if exists (
      select 1
      from jsonb_object_keys(v_event) as key_name
      where key_name <> all (array[
        'client_event_id',
        'app_instance_id',
        'session_id',
        'event_name',
        'screen',
        'platform',
        'app_version',
        'language',
        'city',
        'properties',
        'occurred_at',
        'consent_version',
        'schema_version',
        'environment'
      ]::text[])
    ) then
      raise exception 'event contains unsupported fields' using errcode = '22023';
    end if;

    v_client_event_id := v_event ->> 'client_event_id';
    v_instance := v_event ->> 'app_instance_id';
    v_session := nullif(v_event ->> 'session_id', '');
    v_name := v_event ->> 'event_name';
    v_platform := coalesce(nullif(v_event ->> 'platform', ''), 'iOS');
    v_screen := nullif(v_event ->> 'screen', '');
    v_version := nullif(v_event ->> 'app_version', '');
    v_language := nullif(v_event ->> 'language', '');
    v_city := nullif(v_event ->> 'city', '');
    v_consent := v_event ->> 'consent_version';
    v_environment := coalesce(nullif(v_event ->> 'environment', ''), 'production');
    v_properties := coalesce(v_event -> 'properties', '{}'::jsonb);

    if v_client_event_id is null
      or v_client_event_id !~* '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
      or v_instance is null
      or v_instance !~* '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
      or (v_session is not null and v_session !~* '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$') then
      raise exception 'event identifiers must be UUID v4 values' using errcode = '22023';
    end if;

    if v_name is null or not (v_name = any (v_allowed_names)) then
      raise exception 'event name is not allowlisted' using errcode = '22023';
    end if;

    if v_platform not in ('iOS', 'Web') then
      raise exception 'platform is not supported' using errcode = '22023';
    end if;

    if v_consent <> '2026-07-28' then
      raise exception 'analytics consent version is missing or unsupported' using errcode = '22023';
    end if;

    if coalesce((v_event ->> 'schema_version')::integer, 1) <> 1 then
      raise exception 'analytics schema version is unsupported' using errcode = '22023';
    end if;

    if v_environment not in ('production', 'staging', 'test') then
      raise exception 'environment is not supported' using errcode = '22023';
    end if;

    if v_screen is not null and (
      char_length(v_screen) > 160
      or v_screen ~ '[?#@]'
      or v_screen ~* 'https?://'
      or v_screen !~ '^[A-Za-z0-9_./:-]+$'
    ) then
      raise exception 'screen contains unsupported data' using errcode = '22023';
    end if;

    if v_version is not null and (char_length(v_version) > 40 or v_version !~ '^[A-Za-z0-9_.+-]+$') then
      raise exception 'app version is invalid' using errcode = '22023';
    end if;

    if v_language is not null and (char_length(v_language) > 12 or v_language !~ '^[a-z]{2}(-[A-Z]{2})?$') then
      raise exception 'language is invalid' using errcode = '22023';
    end if;

    if v_city is not null and (char_length(v_city) > 80 or v_city !~ '^[A-Za-zÀ-ÖØ-öø-ÿ .-]+$') then
      raise exception 'city is invalid' using errcode = '22023';
    end if;

    if jsonb_typeof(v_properties) <> 'object'
      or pg_column_size(v_properties) > 2048
      or (select count(*) from jsonb_object_keys(v_properties)) > 12 then
      raise exception 'event properties are invalid' using errcode = '22023';
    end if;

    if exists (
      select 1
      from jsonb_each(v_properties) as property
      where property.key <> all (v_allowed_property_keys)
        or jsonb_typeof(property.value) not in ('string', 'number', 'boolean', 'null')
        or (jsonb_typeof(property.value) = 'string' and char_length(property.value #>> '{}') > 160)
    ) then
      raise exception 'event properties contain unsupported data' using errcode = '22023';
    end if;

    if v_name in ('lead_start', 'lead_submit', 'pilot_request') and v_properties <> '{}'::jsonb then
      raise exception 'lead events do not accept properties' using errcode = '22023';
    end if;

    begin
      v_occurred_at := coalesce((v_event ->> 'occurred_at')::timestamptz, now());
    exception when others then
      raise exception 'event timestamp is invalid' using errcode = '22023';
    end;

    if v_occurred_at < now() - interval '7 days' or v_occurred_at > now() + interval '5 minutes' then
      raise exception 'event timestamp is outside the accepted window' using errcode = '22023';
    end if;

    v_normalized := v_normalized || jsonb_build_array(
      jsonb_build_object(
        'client_event_id', v_client_event_id,
        'app_instance_id', v_instance,
        'session_id', v_session,
        'event_name', v_name,
        'screen', v_screen,
        'platform', v_platform,
        'app_version', v_version,
        'language', v_language,
        'city', v_city,
        'properties', v_properties,
        'occurred_at', v_occurred_at,
        'consent_version', v_consent,
        'schema_version', 1,
        'environment', v_environment
      )
    );
  end loop;

  select min(item ->> 'app_instance_id'), count(distinct item ->> 'app_instance_id')
  into v_instance, v_window_count
  from jsonb_array_elements(v_normalized) as item;

  if v_window_count <> 1 then
    raise exception 'a batch must contain one app instance' using errcode = '22023';
  end if;

  insert into private.analytics_ingest_windows (app_instance_id, window_start, event_count, updated_at)
  values (v_instance, v_window, 0, now())
  on conflict (app_instance_id, window_start) do nothing;

  update private.analytics_ingest_windows
  set event_count = event_count + v_count,
      updated_at = now()
  where app_instance_id = v_instance
    and window_start = v_window
    and event_count + v_count <= 120
  returning event_count into v_window_count;

  if v_window_count is null then
    return -1;
  end if;

  delete from private.analytics_ingest_windows
  where window_start < now() - interval '1 day';

  insert into public.app_events (
    client_event_id,
    app_instance_id,
    session_id,
    event_name,
    screen,
    platform,
    app_version,
    language,
    city,
    properties,
    occurred_at,
    consent_version,
    schema_version,
    environment
  )
  select
    (item ->> 'client_event_id')::uuid,
    item ->> 'app_instance_id',
    nullif(item ->> 'session_id', ''),
    item ->> 'event_name',
    nullif(item ->> 'screen', ''),
    item ->> 'platform',
    nullif(item ->> 'app_version', ''),
    nullif(item ->> 'language', ''),
    nullif(item ->> 'city', ''),
    item -> 'properties',
    (item ->> 'occurred_at')::timestamptz,
    item ->> 'consent_version',
    (item ->> 'schema_version')::smallint,
    item ->> 'environment'
  from jsonb_array_elements(v_normalized) as item
  on conflict (client_event_id) do nothing;

  get diagnostics v_inserted = row_count;

  insert into public.app_sessions (
    session_id,
    app_instance_id,
    platform,
    app_version,
    language,
    city,
    started_at,
    ended_at,
    duration_seconds,
    consent_version,
    environment,
    last_seen_at
  )
  select
    item ->> 'session_id',
    min(item ->> 'app_instance_id'),
    min(item ->> 'platform'),
    max(nullif(item ->> 'app_version', '')),
    max(nullif(item ->> 'language', '')),
    max(nullif(item ->> 'city', '')),
    min((item ->> 'occurred_at')::timestamptz),
    max((item ->> 'occurred_at')::timestamptz),
    greatest(0, extract(epoch from (
      max((item ->> 'occurred_at')::timestamptz)
      - min((item ->> 'occurred_at')::timestamptz)
    ))::integer),
    min(item ->> 'consent_version'),
    min(item ->> 'environment'),
    max((item ->> 'occurred_at')::timestamptz)
  from jsonb_array_elements(v_normalized) as item
  where nullif(item ->> 'session_id', '') is not null
  group by item ->> 'session_id'
  on conflict (session_id) do update
  set ended_at = greatest(public.app_sessions.ended_at, excluded.ended_at),
      last_seen_at = greatest(public.app_sessions.last_seen_at, excluded.last_seen_at),
      duration_seconds = greatest(
        0,
        extract(epoch from (
          greatest(public.app_sessions.last_seen_at, excluded.last_seen_at)
          - least(public.app_sessions.started_at, excluded.started_at)
        ))::integer
      ),
      app_version = coalesce(excluded.app_version, public.app_sessions.app_version),
      language = coalesce(excluded.language, public.app_sessions.language),
      city = coalesce(excluded.city, public.app_sessions.city),
      consent_version = excluded.consent_version,
      environment = excluded.environment;

  return v_inserted;
end
$function$;

revoke all on function public.ingest_analytics_batch(jsonb) from public, anon, authenticated;
grant execute on function public.ingest_analytics_batch(jsonb) to service_role;

create or replace view public.analytics_lead_funnel_periods
with (security_invoker = true)
as
with periods(period_days) as (
  values (7), (30), (90)
)
select
  periods.period_days,
  app_events.platform,
  app_events.event_name as funnel_step,
  count(*)::bigint as events,
  count(distinct app_events.session_id) filter (
    where app_events.session_id is not null
  )::bigint as sessions,
  max(app_events.occurred_at) as last_event_at
from periods
join public.app_events
  on app_events.occurred_at >= current_date - ((periods.period_days - 1) * interval '1 day')
where app_events.environment = 'production'
  and app_events.event_name in ('lead_start', 'lead_submit', 'pilot_request')
group by periods.period_days, app_events.platform, app_events.event_name;

revoke all on table public.analytics_lead_funnel_periods from public, anon, authenticated;
grant select on table public.analytics_lead_funnel_periods to authenticated;

comment on view public.analytics_lead_funnel_periods is
  'Admin-only consented lead start and receipt-return aggregates. lead_submit and pilot_request count safe stored receipts returned, not unique leads or payments.';
