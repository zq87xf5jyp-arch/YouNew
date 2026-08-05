begin;

create table if not exists public.search_analytics_events (
  client_event_id uuid primary key references public.app_events(client_event_id) on delete cascade,
  search_id uuid not null,
  event_kind text not null check (event_kind in ('search', 'search_result_opened')),
  occurred_at timestamptz not null,
  environment text not null check (environment in ('production', 'staging', 'test')),
  language text not null default 'und' check (language ~ '^[a-z]{2}$' or language = 'und'),
  intent_id text,
  result_count integer check (result_count between 0 and 10000),
  result_bucket text check (result_bucket in ('0', '1', '2-5', '6-10', '11-20', '21-50', '51+')),
  has_results boolean,
  query_token_bucket text check (query_token_bucket in ('1', '2-3', '4-7', '8+')),
  type_filter text,
  city_id text,
  province_id text,
  category_id text,
  profile_id text,
  location_scope text check (location_scope in ('national', 'province', 'municipality')),
  content_id text,
  result_rank smallint check (result_rank between 1 and 200),
  created_at timestamptz not null default now(),
  check (
    (event_kind = 'search'
      and intent_id is not null
      and result_count is not null
      and result_bucket is not null
      and has_results is not null
      and query_token_bucket is not null
      and location_scope is not null
      and content_id is null
      and result_rank is null)
    or
    (event_kind = 'search_result_opened'
      and content_id is not null
      and result_rank is not null
      and intent_id is null
      and result_count is null
      and result_bucket is null
      and has_results is null
      and query_token_bucket is null)
  )
);

comment on table public.search_analytics_events is
  'Privacy-safe search telemetry. It stores canonical intent, bounded buckets and filters only; raw or normalized query text is prohibited.';

create index if not exists search_analytics_events_search_time_idx
  on public.search_analytics_events (search_id, occurred_at desc);
create index if not exists search_analytics_events_intent_time_idx
  on public.search_analytics_events (intent_id, language, occurred_at desc)
  where event_kind = 'search';
create index if not exists search_analytics_events_zero_time_idx
  on public.search_analytics_events (occurred_at desc, intent_id, language)
  where event_kind = 'search' and has_results = false;

create table if not exists public.search_improvement_tasks (
  id uuid primary key default gen_random_uuid(),
  gap_signature text not null unique,
  intent_id text not null,
  language text not null,
  type_filter text,
  city_id text,
  province_id text,
  category_id text,
  profile_id text,
  location_scope text not null check (location_scope in ('national', 'province', 'municipality')),
  zero_event_count integer not null check (zero_event_count >= 3),
  first_observed_at timestamptz not null,
  last_observed_at timestamptz not null,
  status text not null default 'open' check (status in ('open', 'in_progress', 'resolved', 'dismissed')),
  resolution_note text check (resolution_note is null or char_length(resolution_note) <= 500),
  resolved_at timestamptz,
  resolved_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.search_improvement_tasks is
  'Automatically created only after at least three equivalent privacy-safe zero-result events in a rolling seven-day window.';

create index if not exists search_improvement_tasks_status_idx
  on public.search_improvement_tasks (status, last_observed_at desc);

create or replace function private.search_gap_signature(
  p_intent_id text,
  p_language text,
  p_type_filter text,
  p_city_id text,
  p_province_id text,
  p_category_id text,
  p_profile_id text,
  p_location_scope text
)
returns text
language sql
immutable
set search_path = ''
as $function$
  select concat_ws('|',
    coalesce(p_intent_id, '*'),
    coalesce(p_language, '*'),
    coalesce(p_type_filter, '*'),
    coalesce(p_city_id, '*'),
    coalesce(p_province_id, '*'),
    coalesce(p_category_id, '*'),
    coalesce(p_profile_id, '*'),
    coalesce(p_location_scope, '*')
  );
$function$;

revoke all on function private.search_gap_signature(text, text, text, text, text, text, text, text)
  from public, anon, authenticated;

create or replace function public.ingest_analytics_batch_v2(p_events jsonb)
returns integer
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_event jsonb;
  v_properties jsonb;
  v_base_events jsonb := '[]'::jsonb;
  v_event_name text;
  v_search_id text;
  v_intent text;
  v_result_bucket text;
  v_query_bucket text;
  v_location_scope text;
  v_profile text;
  v_type_filter text;
  v_content_id text;
  v_result_rank integer;
  v_result_count integer;
  v_inserted integer;
  v_extended_keys constant text[] := array[
    'search_id',
    'search_intent',
    'result_bucket',
    'query_token_bucket',
    'type_filter',
    'city_id',
    'province_id',
    'category_id',
    'profile',
    'location_scope',
    'result_rank'
  ]::text[];
begin
  if jsonb_typeof(p_events) <> 'array'
    or jsonb_array_length(p_events) < 1
    or jsonb_array_length(p_events) > 50 then
    raise exception 'events batch must contain between 1 and 50 items' using errcode = '22023';
  end if;

  for v_event in select value from jsonb_array_elements(p_events)
  loop
    if jsonb_typeof(v_event) <> 'object' then
      raise exception 'each event must be an object' using errcode = '22023';
    end if;
    v_event_name := v_event ->> 'event_name';
    v_properties := coalesce(v_event -> 'properties', '{}'::jsonb);
    if jsonb_typeof(v_properties) <> 'object' then
      raise exception 'event properties are invalid' using errcode = '22023';
    end if;

    if v_event_name = 'search' then
      v_search_id := v_properties ->> 'search_id';
      v_intent := v_properties ->> 'search_intent';
      v_result_bucket := v_properties ->> 'result_bucket';
      v_query_bucket := v_properties ->> 'query_token_bucket';
      v_location_scope := v_properties ->> 'location_scope';
      v_profile := nullif(v_properties ->> 'profile', '');
      v_type_filter := nullif(v_properties ->> 'type_filter', '');

      if v_search_id is null
        or v_search_id !~* '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
        or v_intent is null
        or v_intent !~ '^[a-z0-9][a-z0-9-]{1,47}$'
        or v_result_bucket not in ('0', '1', '2-5', '6-10', '11-20', '21-50', '51+')
        or v_query_bucket not in ('1', '2-3', '4-7', '8+')
        or v_location_scope not in ('national', 'province', 'municipality')
        or (v_profile is not null and v_profile not in ('tourist', 'student', 'expat', 'refugee', 'worker', 'resident'))
        or (v_type_filter is not null and v_type_filter not in ('guide', 'city', 'municipality', 'province', 'organization', 'place', 'category', 'page'))
        or jsonb_typeof(v_properties -> 'result_count') <> 'number'
        or jsonb_typeof(v_properties -> 'has_results') <> 'boolean' then
        raise exception 'search event contains invalid privacy-safe metadata' using errcode = '22023';
      end if;

      begin
        v_result_count := (v_properties ->> 'result_count')::integer;
      exception when others then
        raise exception 'search result count is invalid' using errcode = '22023';
      end;
      if v_result_count < 0 or v_result_count > 10000
        or ((v_properties ->> 'has_results')::boolean <> (v_result_count > 0))
        or (v_result_bucket = '0') <> (v_result_count = 0) then
        raise exception 'search result metadata is inconsistent' using errcode = '22023';
      end if;

      if exists (
        select 1
        from unnest(array[
          nullif(v_properties ->> 'city_id', ''),
          nullif(v_properties ->> 'province_id', ''),
          nullif(v_properties ->> 'category_id', '')
        ]) as bounded_slug(value)
        where value is not null and (char_length(value) > 80 or value !~ '^[a-z0-9][a-z0-9-]*$')
      ) then
        raise exception 'search filter metadata is invalid' using errcode = '22023';
      end if;
    elsif v_event_name = 'search_result_opened' then
      v_search_id := v_properties ->> 'search_id';
      v_content_id := v_properties ->> 'content_id';
      begin
        v_result_rank := (v_properties ->> 'result_rank')::integer;
      exception when others then
        raise exception 'search result rank is invalid' using errcode = '22023';
      end;
      if v_search_id is null
        or v_search_id !~* '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
        or v_content_id is null
        or char_length(v_content_id) > 160
        or v_content_id !~ '^[A-Za-z0-9_./: -]+$'
        or v_result_rank < 1
        or v_result_rank > 200 then
        raise exception 'search result open contains invalid privacy-safe metadata' using errcode = '22023';
      end if;
      if exists (
        select 1 from jsonb_object_keys(v_properties) as key_name
        where key_name = any (v_extended_keys)
          and key_name not in ('search_id', 'result_rank')
      ) then
        raise exception 'search result open contains unsupported metadata' using errcode = '22023';
      end if;
    elsif exists (
      select 1 from jsonb_object_keys(v_properties) as key_name
      where key_name = any (v_extended_keys)
    ) then
      raise exception 'extended search metadata is only accepted for search events' using errcode = '22023';
    end if;

    v_base_events := v_base_events || jsonb_build_array(
      jsonb_set(v_event, '{properties}', v_properties - v_extended_keys, true)
    );
  end loop;

  v_inserted := public.ingest_analytics_batch(v_base_events);
  if v_inserted = -1 then return -1; end if;

  insert into public.search_analytics_events (
    client_event_id,
    search_id,
    event_kind,
    occurred_at,
    environment,
    language,
    intent_id,
    result_count,
    result_bucket,
    has_results,
    query_token_bucket,
    type_filter,
    city_id,
    province_id,
    category_id,
    profile_id,
    location_scope,
    content_id,
    result_rank
  )
  select
    stored.client_event_id,
    (event -> 'properties' ->> 'search_id')::uuid,
    stored.event_name,
    stored.occurred_at,
    stored.environment,
    coalesce(lower(split_part(stored.language, '-', 1)), 'und'),
    case when stored.event_name = 'search' then event -> 'properties' ->> 'search_intent' end,
    case when stored.event_name = 'search' then (event -> 'properties' ->> 'result_count')::integer end,
    case when stored.event_name = 'search' then event -> 'properties' ->> 'result_bucket' end,
    case when stored.event_name = 'search' then (event -> 'properties' ->> 'has_results')::boolean end,
    case when stored.event_name = 'search' then event -> 'properties' ->> 'query_token_bucket' end,
    nullif(event -> 'properties' ->> 'type_filter', ''),
    nullif(event -> 'properties' ->> 'city_id', ''),
    nullif(event -> 'properties' ->> 'province_id', ''),
    nullif(event -> 'properties' ->> 'category_id', ''),
    nullif(event -> 'properties' ->> 'profile', ''),
    case when stored.event_name = 'search' then event -> 'properties' ->> 'location_scope' end,
    case when stored.event_name = 'search_result_opened' then event -> 'properties' ->> 'content_id' end,
    case when stored.event_name = 'search_result_opened' then (event -> 'properties' ->> 'result_rank')::smallint end
  from jsonb_array_elements(p_events) as event
  join public.app_events as stored
    on stored.client_event_id = (event ->> 'client_event_id')::uuid
  where stored.event_name in ('search', 'search_result_opened')
  on conflict (client_event_id) do nothing;

  return v_inserted;
end
$function$;

revoke all on function public.ingest_analytics_batch_v2(jsonb) from public, anon, authenticated;
grant execute on function public.ingest_analytics_batch_v2(jsonb) to service_role;

create or replace function private.sync_search_improvement_task()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_signature text;
  v_count integer;
  v_first timestamptz;
  v_last timestamptz;
begin
  if new.event_kind <> 'search' or new.has_results or new.environment <> 'production' then
    return new;
  end if;

  v_signature := private.search_gap_signature(
    new.intent_id,
    new.language,
    new.type_filter,
    new.city_id,
    new.province_id,
    new.category_id,
    new.profile_id,
    new.location_scope
  );

  select count(*)::integer, min(occurred_at), max(occurred_at)
  into v_count, v_first, v_last
  from public.search_analytics_events
  where event_kind = 'search'
    and has_results = false
    and environment = 'production'
    and occurred_at >= now() - interval '7 days'
    and intent_id is not distinct from new.intent_id
    and language is not distinct from new.language
    and type_filter is not distinct from new.type_filter
    and city_id is not distinct from new.city_id
    and province_id is not distinct from new.province_id
    and category_id is not distinct from new.category_id
    and profile_id is not distinct from new.profile_id
    and location_scope is not distinct from new.location_scope;

  if v_count < 3 then return new; end if;

  insert into public.search_improvement_tasks (
    gap_signature,
    intent_id,
    language,
    type_filter,
    city_id,
    province_id,
    category_id,
    profile_id,
    location_scope,
    zero_event_count,
    first_observed_at,
    last_observed_at
  ) values (
    v_signature,
    new.intent_id,
    new.language,
    new.type_filter,
    new.city_id,
    new.province_id,
    new.category_id,
    new.profile_id,
    new.location_scope,
    v_count,
    v_first,
    v_last
  )
  on conflict (gap_signature) do update
  set zero_event_count = excluded.zero_event_count,
      first_observed_at = excluded.first_observed_at,
      last_observed_at = excluded.last_observed_at,
      status = case
        when public.search_improvement_tasks.status in ('resolved', 'dismissed') then 'open'
        else public.search_improvement_tasks.status
      end,
      resolved_at = null,
      resolved_by = null,
      updated_at = now();

  return new;
end
$function$;

revoke all on function private.sync_search_improvement_task() from public, anon, authenticated;

drop trigger if exists create_search_improvement_task_after_zero on public.search_analytics_events;
create trigger create_search_improvement_task_after_zero
after insert on public.search_analytics_events
for each row execute function private.sync_search_improvement_task();

create or replace view public.analytics_search_intent_daily
with (security_invoker = true)
as
with submissions as (
  select *
  from public.search_analytics_events
  where event_kind = 'search' and environment = 'production'
), opens as (
  select distinct search_id
  from public.search_analytics_events
  where event_kind = 'search_result_opened' and environment = 'production'
)
select
  date_trunc('day', submissions.occurred_at)::date as metric_date,
  submissions.language,
  submissions.intent_id,
  count(*)::bigint as search_count,
  count(*) filter (where not submissions.has_results)::bigint as zero_result_count,
  count(opens.search_id)::bigint as opened_result_count,
  max(submissions.occurred_at) as last_search_at
from submissions
left join opens on opens.search_id = submissions.search_id
group by date_trunc('day', submissions.occurred_at)::date, submissions.language, submissions.intent_id;

create or replace view public.analytics_search_zero_filters
with (security_invoker = true)
as
select
  language,
  intent_id,
  type_filter,
  city_id,
  province_id,
  category_id,
  profile_id,
  location_scope,
  count(*)::bigint as zero_result_count,
  max(occurred_at) as last_zero_at
from public.search_analytics_events
where event_kind = 'search'
  and environment = 'production'
  and has_results = false
  and occurred_at >= now() - interval '30 days'
group by language, intent_id, type_filter, city_id, province_id, category_id, profile_id, location_scope
having count(*) >= 3;

create or replace view public.analytics_search_low_click_intents
with (security_invoker = true)
as
with submissions as (
  select search_id, language, intent_id
  from public.search_analytics_events
  where event_kind = 'search'
    and environment = 'production'
    and occurred_at >= now() - interval '30 days'
    and has_results = true
), opens as (
  select distinct search_id
  from public.search_analytics_events
  where event_kind = 'search_result_opened'
    and environment = 'production'
    and occurred_at >= now() - interval '30 days'
)
select
  submissions.language,
  submissions.intent_id,
  count(*)::bigint as search_count,
  count(opens.search_id)::bigint as opened_result_count,
  round((count(opens.search_id)::numeric / nullif(count(*), 0)) * 100, 1) as open_rate_percent
from submissions
left join opens on opens.search_id = submissions.search_id
group by submissions.language, submissions.intent_id
having count(*) >= 3
order by open_rate_percent asc, search_count desc;

alter table public.search_analytics_events enable row level security;
alter table public.search_improvement_tasks enable row level security;

revoke all on table public.search_analytics_events from public, anon, authenticated;
revoke all on table public.search_improvement_tasks from public, anon, authenticated;
revoke all on table public.analytics_search_intent_daily from public, anon;
revoke all on table public.analytics_search_zero_filters from public, anon;
revoke all on table public.analytics_search_low_click_intents from public, anon;

grant select, insert, update, delete on table public.search_analytics_events to service_role;
grant select, insert, update, delete on table public.search_improvement_tasks to service_role;
grant select on table public.search_analytics_events to authenticated;
grant select on table public.search_improvement_tasks to authenticated;
grant update (status, resolution_note, resolved_at, resolved_by, updated_at)
  on table public.search_improvement_tasks to authenticated;
grant select on table public.analytics_search_intent_daily to authenticated;
grant select on table public.analytics_search_zero_filters to authenticated;
grant select on table public.analytics_search_low_click_intents to authenticated;

drop policy if exists "approved admins read search analytics" on public.search_analytics_events;
create policy "approved admins read search analytics"
on public.search_analytics_events for select to authenticated
using ((select private.current_admin_role()) in ('owner', 'admin', 'qa'));

drop policy if exists "approved admins read search improvement tasks" on public.search_improvement_tasks;
create policy "approved admins read search improvement tasks"
on public.search_improvement_tasks for select to authenticated
using ((select private.current_admin_role()) in ('owner', 'admin', 'qa'));

drop policy if exists "owners and admins update search improvement tasks" on public.search_improvement_tasks;
create policy "owners and admins update search improvement tasks"
on public.search_improvement_tasks for update to authenticated
using ((select private.current_admin_role()) in ('owner', 'admin'))
with check ((select private.current_admin_role()) in ('owner', 'admin'));

commit;
