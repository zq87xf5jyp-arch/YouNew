begin;

-- Preserve the established consent, rate-limit and validation implementation,
-- while extending only its explicit property allowlist. This fails closed if
-- the previous production function no longer has the reviewed shape.
do $migration$
declare
  v_definition text;
  v_needle text := $needle$    'duration_ms'
  ]::text[];$needle$;
  v_replacement text := $replacement$    'duration_ms',
    'normalized_query_safe',
    'intent_ids',
    'filter_type',
    'filter_city',
    'filter_province',
    'filter_category',
    'filter_profile',
    'zero_result',
    'fallback_tier',
    'position'
  ]::text[];$replacement$;
begin
  select pg_get_functiondef('public.ingest_analytics_batch(jsonb)'::regprocedure)
  into v_definition;

  if position('normalized_query_safe' in v_definition) = 0 then
    if position(v_needle in v_definition) = 0 then
      raise exception 'ingest_analytics_batch allowlist shape changed; refusing an unsafe patch';
    end if;
    execute replace(v_definition, v_needle, v_replacement);
  end if;
end
$migration$;

create table if not exists public.search_improvement_tasks (
  id uuid primary key default gen_random_uuid(),
  gap_key text not null unique,
  normalized_query_safe text not null check (char_length(normalized_query_safe) between 1 and 80),
  intent_ids text not null default '',
  filter_type text not null default '',
  filter_city text not null default '',
  filter_province text not null default '',
  filter_category text not null default '',
  filter_profile text not null default '',
  occurrence_count integer not null default 1 check (occurrence_count > 0),
  status text not null default 'observed' check (status in ('observed', 'open', 'in_progress', 'resolved', 'dismissed')),
  priority text not null default 'normal' check (priority in ('normal', 'high', 'critical')),
  first_seen_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  resolved_at timestamptz,
  resolution_note text check (resolution_note is null or char_length(resolution_note) <= 500)
);

create index if not exists search_improvement_tasks_queue_idx
  on public.search_improvement_tasks (status, priority, occurrence_count desc, last_seen_at desc);

alter table public.search_improvement_tasks enable row level security;

drop policy if exists "approved admins read search improvement tasks" on public.search_improvement_tasks;
create policy "approved admins read search improvement tasks"
on public.search_improvement_tasks for select to authenticated
using ((select private.is_approved_admin()));

drop policy if exists "approved admins update search improvement tasks" on public.search_improvement_tasks;
create policy "approved admins update search improvement tasks"
on public.search_improvement_tasks for update to authenticated
using ((select private.is_approved_admin()))
with check ((select private.is_approved_admin()));

revoke all on table public.search_improvement_tasks from public, anon, authenticated;
grant select, update on table public.search_improvement_tasks to authenticated;
grant all on table public.search_improvement_tasks to service_role;

create or replace function private.record_search_improvement_task()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_query text := nullif(new.properties ->> 'normalized_query_safe', '');
  v_gap_key text;
begin
  if new.environment <> 'production'
    or new.event_name <> 'search'
    or coalesce((new.properties ->> 'zero_result')::boolean, false) is not true
    or v_query is null
    or v_query in ('[redacted]', '[unmapped]') then
    return new;
  end if;

  v_gap_key := md5(concat_ws('|',
    v_query,
    coalesce(new.properties ->> 'intent_ids', ''),
    coalesce(new.properties ->> 'filter_type', ''),
    coalesce(new.properties ->> 'filter_city', ''),
    coalesce(new.properties ->> 'filter_province', ''),
    coalesce(new.properties ->> 'filter_category', ''),
    coalesce(new.properties ->> 'filter_profile', '')
  ));

  insert into public.search_improvement_tasks (
    gap_key,
    normalized_query_safe,
    intent_ids,
    filter_type,
    filter_city,
    filter_province,
    filter_category,
    filter_profile,
    first_seen_at,
    last_seen_at
  ) values (
    v_gap_key,
    v_query,
    coalesce(new.properties ->> 'intent_ids', ''),
    coalesce(new.properties ->> 'filter_type', ''),
    coalesce(new.properties ->> 'filter_city', ''),
    coalesce(new.properties ->> 'filter_province', ''),
    coalesce(new.properties ->> 'filter_category', ''),
    coalesce(new.properties ->> 'filter_profile', ''),
    new.occurred_at,
    new.occurred_at
  )
  on conflict (gap_key) do update
  set occurrence_count = public.search_improvement_tasks.occurrence_count + 1,
      last_seen_at = greatest(public.search_improvement_tasks.last_seen_at, excluded.last_seen_at),
      status = case
        when public.search_improvement_tasks.status in ('resolved', 'dismissed') then public.search_improvement_tasks.status
        when public.search_improvement_tasks.occurrence_count + 1 >= 3 then 'open'
        else public.search_improvement_tasks.status
      end,
      priority = case
        when public.search_improvement_tasks.occurrence_count + 1 >= 10 then 'critical'
        when public.search_improvement_tasks.occurrence_count + 1 >= 3 then 'high'
        else public.search_improvement_tasks.priority
      end;

  return new;
end
$function$;

revoke all on function private.record_search_improvement_task() from public, anon, authenticated;

drop trigger if exists record_search_improvement_task_after_insert on public.app_events;
create trigger record_search_improvement_task_after_insert
after insert on public.app_events
for each row execute function private.record_search_improvement_task();

create or replace view public.analytics_search_gaps
with (security_invoker = true)
as
with searches as (
  select
    properties ->> 'normalized_query_safe' as normalized_query_safe,
    properties ->> 'intent_ids' as intent_ids,
    properties ->> 'filter_type' as filter_type,
    properties ->> 'filter_city' as filter_city,
    properties ->> 'filter_province' as filter_province,
    properties ->> 'filter_category' as filter_category,
    properties ->> 'filter_profile' as filter_profile,
    count(*)::bigint as search_count,
    count(*) filter (where coalesce((properties ->> 'zero_result')::boolean, false))::bigint as zero_result_count,
    avg(coalesce((properties ->> 'result_count')::integer, 0))::numeric(10,2) as average_result_count,
    max(occurred_at) as last_searched_at
  from public.app_events
  where environment = 'production'
    and event_name = 'search'
    and occurred_at >= now() - interval '30 days'
    and coalesce(properties ->> 'normalized_query_safe', '') not in ('', '[redacted]', '[unmapped]')
  group by 1, 2, 3, 4, 5, 6, 7
), opens as (
  select
    properties ->> 'normalized_query_safe' as normalized_query_safe,
    count(*)::bigint as result_open_count
  from public.app_events
  where environment = 'production'
    and event_name = 'search_result_opened'
    and occurred_at >= now() - interval '30 days'
  group by 1
)
select
  searches.*,
  coalesce(opens.result_open_count, 0)::bigint as result_open_count,
  case when searches.search_count > 0
    then round(coalesce(opens.result_open_count, 0)::numeric / searches.search_count, 4)
    else 0::numeric
  end as result_open_rate
from searches
left join opens using (normalized_query_safe);

revoke all on table public.analytics_search_gaps from public, anon, authenticated;
grant select on table public.analytics_search_gaps to authenticated;

comment on table public.search_improvement_tasks is
  'Privacy-safe search gaps. Repeated production zero-result signals become open Admin tasks after three occurrences.';
comment on view public.analytics_search_gaps is
  'Thirty-day production search quality aggregates without raw free-form or direct identifiers.';

commit;
