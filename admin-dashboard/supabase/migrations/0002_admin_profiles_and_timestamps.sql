-- YouNew admin profiles and automatic timestamps migration
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.handle_new_admin_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data ->> 'full_name', new.email))
  on conflict (id) do update set email = excluded.email, updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert or update of email on auth.users
  for each row execute procedure public.handle_new_admin_user();

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'profiles', 'categories', 'articles', 'cities', 'map_points', 'resources',
    'faq_items', 'ai_knowledge_items', 'screenshots', 'bugs', 'official_links',
    'feedback', 'app_settings', 'content_sync_state'
  ]
  loop
    execute format('drop trigger if exists set_updated_at on public.%I', table_name);
    execute format(
      'create trigger set_updated_at before update on public.%I for each row execute procedure public.set_updated_at()',
      table_name
    );
  end loop;
end;
$$;

create index if not exists articles_status_updated_at_idx
  on public.articles (status, updated_at desc);
create index if not exists articles_category_updated_at_idx
  on public.articles (category_id, updated_at desc);
create index if not exists articles_author_id_idx
  on public.articles (author_id);
