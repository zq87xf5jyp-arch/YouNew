create extension if not exists "pgcrypto";

do $$ begin
  create type admin_role as enum ('owner', 'admin', 'editor', 'qa', 'viewer');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type publication_status as enum ('draft', 'review', 'published', 'archived');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type visual_status as enum ('good', 'needs review', 'broken', 'fixed');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type bug_status as enum ('open', 'in progress', 'fixed', 'verified', 'closed');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type release_status as enum ('planned', 'testing', 'ready', 'released');
exception when duplicate_object then null;
end $$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  full_name text,
  role admin_role not null default 'viewer',
  is_approved boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  short_description text,
  icon text,
  color text,
  status publication_status not null default 'draft',
  priority int not null default 0,
  tags text[] not null default '{}',
  author_id uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  published_at timestamptz
);

create table public.articles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  short_description text,
  full_content text,
  category_id uuid references public.categories(id),
  city text,
  province text,
  language text not null default 'en',
  status publication_status not null default 'draft',
  priority int not null default 0,
  source_url text,
  official_source boolean not null default false,
  tags text[] not null default '{}',
  author_id uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  published_at timestamptz
);

create table public.cities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  province text not null,
  description text,
  emergency_contacts jsonb not null default '[]',
  municipality_link text,
  transport_notes text,
  useful_official_links jsonb not null default '[]',
  lat numeric(9,6),
  lng numeric(9,6),
  cover_image_path text,
  status publication_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  published_at timestamptz
);

create table public.map_points (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  type text not null check (type in ('city','municipality','hospital','transport','government','education','custom')),
  latitude numeric(9,6) not null,
  longitude numeric(9,6) not null,
  city text,
  province text,
  description text,
  source_url text,
  status publication_status not null default 'draft',
  icon text,
  color text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.resources (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  short_description text,
  full_content text,
  category_id uuid references public.categories(id),
  language text not null default 'en',
  status publication_status not null default 'draft',
  priority int not null default 0,
  source_url text,
  official_source boolean not null default true,
  tags text[] not null default '{}',
  author_id uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  published_at timestamptz
);

create table public.faq_items (
  id uuid primary key default gen_random_uuid(),
  question text not null,
  answer text not null,
  category_id uuid references public.categories(id),
  language text not null default 'en',
  status publication_status not null default 'draft',
  source_url text,
  official_source boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  published_at timestamptz
);

create table public.ai_knowledge_items (
  id uuid primary key default gen_random_uuid(),
  question text not null,
  answer text not null,
  category_id uuid references public.categories(id),
  city text,
  province text,
  source_url text,
  official_source boolean not null default false,
  language text not null default 'en',
  status publication_status not null default 'draft',
  last_reviewed_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.screenshots (
  id uuid primary key default gen_random_uuid(),
  file_path text not null,
  expected_file_path text,
  screen_type text not null,
  platform text not null check (platform in ('iOS','Android','Web')),
  device text not null check (device in ('iPhone','Android','Tablet','Desktop')),
  notes text,
  visual_status visual_status not null default 'needs review',
  markers jsonb not null default '[]',
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.bugs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  severity text not null check (severity in ('low','medium','high','critical')),
  priority text not null check (priority in ('low','medium','high','urgent')),
  status bug_status not null default 'open',
  platform text not null check (platform in ('iOS','Android','Web','Backend','Admin')),
  app_screen text,
  linked_screenshot_id uuid references public.screenshots(id),
  steps_to_reproduce text,
  expected_result text,
  actual_result text,
  assigned_to uuid references public.profiles(id),
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.releases (
  id uuid primary key default gen_random_uuid(),
  version text not null,
  platform text not null check (platform in ('iOS','Android','Web')),
  release_notes text,
  status release_status not null default 'planned',
  created_at timestamptz not null default now(),
  release_date date
);

create table public.release_checklist_items (
  id uuid primary key default gen_random_uuid(),
  release_id uuid references public.releases(id) on delete cascade,
  title text not null,
  is_done boolean not null default false,
  linked_bug_id uuid references public.bugs(id),
  created_at timestamptz not null default now()
);

create table public.official_links (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  url text not null,
  source_type text not null check (source_type in ('government','municipality','transport','healthcare','education','other')),
  status text not null default 'needs review' check (status in ('active','broken','needs review')),
  last_checked_date date,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.feedback (
  id uuid primary key default gen_random_uuid(),
  user_email text,
  message text not null,
  app_screen text,
  platform text,
  status text not null default 'new' check (status in ('new','reviewed','planned','rejected','resolved')),
  created_at timestamptz not null default now()
);

create table public.app_settings (
  key text primary key,
  value jsonb not null,
  status publication_status not null default 'published',
  updated_at timestamptz not null default now()
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id),
  action text not null,
  entity_type text not null,
  entity_id text,
  previous_value jsonb,
  new_value jsonb,
  created_at timestamptz not null default now()
);

create table public.app_events (
  id uuid primary key default gen_random_uuid(),
  app_instance_id text not null,
  session_id text,
  event_name text not null,
  screen text,
  platform text not null default 'iOS' check (platform in ('iOS','Android','Web')),
  app_version text,
  language text,
  city text,
  properties jsonb not null default '{}',
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table public.app_sessions (
  id uuid primary key default gen_random_uuid(),
  session_id text not null unique,
  app_instance_id text not null,
  platform text not null default 'iOS' check (platform in ('iOS','Android','Web')),
  app_version text,
  language text,
  city text,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  duration_seconds int,
  created_at timestamptz not null default now()
);

create table public.content_sync_state (
  dataset text primary key,
  version int not null default 1,
  records int not null default 0,
  checksum text,
  last_sync timestamptz,
  status text not null default 'synced' check (status in ('synced','needs review','failed')),
  updated_at timestamptz not null default now()
);

create table public.sync_jobs (
  id uuid primary key default gen_random_uuid(),
  job text not null,
  target text not null,
  status text not null default 'success' check (status in ('success','warning','failed')),
  duration_ms int,
  details jsonb not null default '{}',
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create or replace function public.is_approved_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
      and is_approved = true
      and role in ('owner','admin','editor','qa','viewer')
  );
$$;

create or replace function public.current_admin_role()
returns admin_role
language sql
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid() and is_approved = true;
$$;

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.articles enable row level security;
alter table public.cities enable row level security;
alter table public.map_points enable row level security;
alter table public.resources enable row level security;
alter table public.faq_items enable row level security;
alter table public.ai_knowledge_items enable row level security;
alter table public.screenshots enable row level security;
alter table public.bugs enable row level security;
alter table public.releases enable row level security;
alter table public.release_checklist_items enable row level security;
alter table public.official_links enable row level security;
alter table public.feedback enable row level security;
alter table public.app_settings enable row level security;
alter table public.audit_logs enable row level security;
alter table public.app_events enable row level security;
alter table public.app_sessions enable row level security;
alter table public.content_sync_state enable row level security;
alter table public.sync_jobs enable row level security;

create policy "approved admins can read profiles" on public.profiles for select using (public.is_approved_admin());
create policy "owners can manage profiles" on public.profiles for all using (public.current_admin_role() = 'owner') with check (public.current_admin_role() = 'owner');

create policy "published content is public" on public.categories for select using (status = 'published' or public.is_approved_admin());
create policy "published articles are public" on public.articles for select using (status = 'published' or public.is_approved_admin());
create policy "published cities are public" on public.cities for select using (status = 'published' or public.is_approved_admin());
create policy "published map points are public" on public.map_points for select using (status = 'published' or public.is_approved_admin());
create policy "published resources are public" on public.resources for select using (status = 'published' or public.is_approved_admin());
create policy "published faq is public" on public.faq_items for select using (status = 'published' or public.is_approved_admin());
create policy "published settings are public" on public.app_settings for select using (status = 'published' or public.is_approved_admin());

create policy "content admins manage categories" on public.categories for all using (public.current_admin_role() in ('owner','admin','editor')) with check (public.current_admin_role() in ('owner','admin','editor'));
create policy "content admins manage articles" on public.articles for all using (public.current_admin_role() in ('owner','admin','editor')) with check (public.current_admin_role() in ('owner','admin','editor'));
create policy "content admins manage cities" on public.cities for all using (public.current_admin_role() in ('owner','admin','editor')) with check (public.current_admin_role() in ('owner','admin','editor'));
create policy "content admins manage map points" on public.map_points for all using (public.current_admin_role() in ('owner','admin','editor')) with check (public.current_admin_role() in ('owner','admin','editor'));
create policy "content admins manage resources" on public.resources for all using (public.current_admin_role() in ('owner','admin','editor')) with check (public.current_admin_role() in ('owner','admin','editor'));
create policy "content admins manage faq" on public.faq_items for all using (public.current_admin_role() in ('owner','admin','editor')) with check (public.current_admin_role() in ('owner','admin','editor'));
create policy "content admins manage ai knowledge" on public.ai_knowledge_items for all using (public.current_admin_role() in ('owner','admin','editor')) with check (public.current_admin_role() in ('owner','admin','editor'));
create policy "qa admins manage screenshots" on public.screenshots for all using (public.current_admin_role() in ('owner','admin','qa')) with check (public.current_admin_role() in ('owner','admin','qa'));
create policy "qa admins manage bugs" on public.bugs for all using (public.current_admin_role() in ('owner','admin','qa')) with check (public.current_admin_role() in ('owner','admin','qa'));
create policy "qa admins manage releases" on public.releases for all using (public.current_admin_role() in ('owner','admin','qa')) with check (public.current_admin_role() in ('owner','admin','qa'));
create policy "qa admins manage release checklist" on public.release_checklist_items for all using (public.current_admin_role() in ('owner','admin','qa')) with check (public.current_admin_role() in ('owner','admin','qa'));
create policy "admins manage official links" on public.official_links for all using (public.current_admin_role() in ('owner','admin','editor')) with check (public.current_admin_role() in ('owner','admin','editor'));
create policy "admins manage feedback" on public.feedback for all using (public.current_admin_role() in ('owner','admin','qa')) with check (public.current_admin_role() in ('owner','admin','qa'));
create policy "owners and admins manage settings" on public.app_settings for all using (public.current_admin_role() in ('owner','admin')) with check (public.current_admin_role() in ('owner','admin'));
create policy "approved admins read audit logs" on public.audit_logs for select using (public.is_approved_admin());
create policy "approved admins insert audit logs" on public.audit_logs for insert with check (public.is_approved_admin());
create policy "approved admins read app events" on public.app_events for select using (public.is_approved_admin());
create policy "server inserts app events" on public.app_events for insert with check (true);
create policy "approved admins read app sessions" on public.app_sessions for select using (public.is_approved_admin());
create policy "server inserts app sessions" on public.app_sessions for insert with check (true);
create policy "approved admins manage sync state" on public.content_sync_state for all using (public.current_admin_role() in ('owner','admin')) with check (public.current_admin_role() in ('owner','admin'));
create policy "approved admins read sync jobs" on public.sync_jobs for select using (public.is_approved_admin());
create policy "approved admins insert sync jobs" on public.sync_jobs for insert with check (public.current_admin_role() in ('owner','admin'));

create index app_events_name_time_idx on public.app_events (event_name, occurred_at desc);
create index app_events_instance_time_idx on public.app_events (app_instance_id, occurred_at desc);
create index app_events_screen_time_idx on public.app_events (screen, occurred_at desc);
create index app_sessions_started_idx on public.app_sessions (started_at desc);

insert into storage.buckets (id, name, public)
values ('screenshots', 'screenshots', false)
on conflict (id) do nothing;
