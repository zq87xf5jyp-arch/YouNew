begin;

drop policy if exists "server inserts app events" on public.app_events;
drop policy if exists "server inserts app sessions" on public.app_sessions;

revoke insert on table public.app_events from anon;
revoke insert on table public.app_events from authenticated;
revoke insert on table public.app_sessions from anon;
revoke insert on table public.app_sessions from authenticated;

grant insert on table public.app_events to service_role;
grant insert on table public.app_sessions to service_role;

commit;
