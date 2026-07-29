-- Complete role enforcement, private content storage and automatic audit trail.
insert into storage.buckets (id, name, public)
values ('content', 'content', false)
on conflict (id) do update set public = false;

drop policy if exists "admins read private files" on storage.objects;
create policy "admins read private files" on storage.objects for select to authenticated
using (bucket_id in ('content', 'screenshots') and public.is_approved_admin());

drop policy if exists "editors manage content files" on storage.objects;
create policy "editors manage content files" on storage.objects for all to authenticated
using (bucket_id = 'content' and public.current_admin_role() in ('owner', 'admin', 'editor'))
with check (bucket_id = 'content' and public.current_admin_role() in ('owner', 'admin', 'editor'));

drop policy if exists "qa manages screenshots" on storage.objects;
create policy "qa manages screenshots" on storage.objects for all to authenticated
using (bucket_id = 'screenshots' and public.current_admin_role() in ('owner', 'admin', 'qa'))
with check (bucket_id = 'screenshots' and public.current_admin_role() in ('owner', 'admin', 'qa'));

create or replace function public.write_audit_log()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.audit_logs (user_id, action, entity_type, entity_id, previous_value, new_value)
  values (
    auth.uid(), lower(tg_op), tg_table_name,
    coalesce((to_jsonb(new) ->> 'id'), (to_jsonb(old) ->> 'id'), (to_jsonb(new) ->> 'key'), (to_jsonb(old) ->> 'key')),
    case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) else null end,
    case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) else null end
  );
  return coalesce(new, old);
end;
$$;

do $$
declare table_name text;
begin
  foreach table_name in array array[
    'categories', 'articles', 'cities', 'map_points', 'resources', 'faq_items',
    'ai_knowledge_items', 'bugs', 'releases', 'official_links', 'app_settings'
  ] loop
    execute format('drop trigger if exists audit_changes on public.%I', table_name);
    execute format('create trigger audit_changes after insert or update or delete on public.%I for each row execute function public.write_audit_log()', table_name);
  end loop;
end;
$$;
