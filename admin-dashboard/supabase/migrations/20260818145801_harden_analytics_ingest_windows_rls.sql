begin;

do $preflight$
begin
  if to_regclass('private.analytics_ingest_windows') is null then
    raise exception using
      errcode = '42P01',
      message = 'private.analytics_ingest_windows is required before RLS hardening';
  end if;

  if to_regprocedure('public.ingest_analytics_batch(jsonb)') is null then
    raise exception using
      errcode = '42883',
      message = 'public.ingest_analytics_batch(jsonb) is required before RLS hardening';
  end if;

  if to_regclass('public.feedback_rate_limits') is null
     or to_regclass('public.governance_action_receipts') is null then
    raise exception using
      errcode = '42P01',
      message = 'the classified deny-by-default tables are required before policy hardening';
  end if;
end
$preflight$;

alter table private.analytics_ingest_windows enable row level security;

drop policy if exists "reject direct analytics ingest window access"
  on private.analytics_ingest_windows;
create policy "reject direct analytics ingest window access"
on private.analytics_ingest_windows
as restrictive
for all
to anon, authenticated
using (false)
with check (false);

alter table public.feedback_rate_limits enable row level security;
drop policy if exists "reject direct feedback rate limit access"
  on public.feedback_rate_limits;
create policy "reject direct feedback rate limit access"
on public.feedback_rate_limits
as restrictive
for all
to anon, authenticated
using (false)
with check (false);

alter table public.governance_action_receipts enable row level security;
drop policy if exists "reject direct governance receipt access"
  on public.governance_action_receipts;
create policy "reject direct governance receipt access"
on public.governance_action_receipts
as restrictive
for all
to anon, authenticated
using (false)
with check (false);

revoke all on table private.analytics_ingest_windows from public, anon, authenticated;
grant select, insert, update, delete on table private.analytics_ingest_windows to service_role;

revoke all on function public.ingest_analytics_batch(jsonb) from public, anon, authenticated;
grant execute on function public.ingest_analytics_batch(jsonb) to service_role;

do $verify$
declare
  v_table oid := 'private.analytics_ingest_windows'::regclass;
  v_function oid := 'public.ingest_analytics_batch(jsonb)'::regprocedure;
begin
  if not (select relrowsecurity from pg_class where oid = v_table) then
    raise exception 'analytics_ingest_windows RLS verification failed';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'private'
      and tablename = 'analytics_ingest_windows'
      and policyname = 'reject direct analytics ingest window access'
      and cmd = 'ALL'
      and 'anon' = any (roles)
      and 'authenticated' = any (roles)
      and qual = 'false'
      and with_check = 'false'
  ) then
    raise exception 'analytics_ingest_windows client rejection policy verification failed';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'feedback_rate_limits'
      and policyname = 'reject direct feedback rate limit access'
      and cmd = 'ALL'
      and 'anon' = any (roles)
      and 'authenticated' = any (roles)
      and qual = 'false'
      and with_check = 'false'
  ) or not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'governance_action_receipts'
      and policyname = 'reject direct governance receipt access'
      and cmd = 'ALL'
      and 'anon' = any (roles)
      and 'authenticated' = any (roles)
      and qual = 'false'
      and with_check = 'false'
  ) then
    raise exception 'classified deny-by-default policy verification failed';
  end if;

  if has_table_privilege('anon', v_table, 'SELECT')
     or has_table_privilege('anon', v_table, 'INSERT')
     or has_table_privilege('anon', v_table, 'UPDATE')
     or has_table_privilege('anon', v_table, 'DELETE')
     or has_table_privilege('authenticated', v_table, 'SELECT')
     or has_table_privilege('authenticated', v_table, 'INSERT')
     or has_table_privilege('authenticated', v_table, 'UPDATE')
     or has_table_privilege('authenticated', v_table, 'DELETE') then
    raise exception 'analytics_ingest_windows client grants verification failed';
  end if;

  if not has_table_privilege('service_role', v_table, 'SELECT')
     or not has_table_privilege('service_role', v_table, 'INSERT')
     or not has_table_privilege('service_role', v_table, 'UPDATE')
     or not has_table_privilege('service_role', v_table, 'DELETE') then
    raise exception 'analytics_ingest_windows service_role grants verification failed';
  end if;

  if has_function_privilege('anon', v_function, 'EXECUTE')
     or has_function_privilege('authenticated', v_function, 'EXECUTE')
     or not has_function_privilege('service_role', v_function, 'EXECUTE') then
    raise exception 'ingest_analytics_batch execute grants verification failed';
  end if;

  if not exists (
    select 1
    from pg_proc
    where oid = v_function
      and prosecdef
      and coalesce(proconfig, '{}'::text[]) @> array['search_path=""']::text[]
  ) then
    raise exception 'ingest_analytics_batch SECURITY DEFINER boundary verification failed';
  end if;
end
$verify$;

commit;
