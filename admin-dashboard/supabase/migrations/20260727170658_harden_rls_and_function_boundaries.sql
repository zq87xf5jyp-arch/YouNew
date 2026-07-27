-- REVIEW PACKAGE ONLY.
-- Generated with Supabase CLI 2.109.1.
-- Do not apply to production without a backup, branch verification, reviewed
-- advisor output, and separate explicit confirmation.

do $migration_guard$
declare
  policy_snapshot_md5 text;
  trigger_snapshot_md5 text;
begin
  if to_regprocedure('public.current_admin_role()') is null
    or to_regprocedure('public.is_approved_admin()') is null
    or to_regprocedure('public.handle_new_admin_user()') is null then
    raise exception 'Reviewed public helper functions are missing or already moved';
  end if;

  if exists (
    select 1
    from (
      values
        (
          'public.current_admin_role()',
          'cf784db7e5fbf5248c6091face6d81b4'
        ),
        (
          'public.handle_new_admin_user()',
          '8569cd72a12d1d0ddb653d8e87adf5d3'
        ),
        (
          'public.is_approved_admin()',
          '9d829102101e6419e445af564072339a'
        )
    ) as expected_function(signature, definition_md5)
    left join pg_proc function_definition
      on function_definition.oid =
        to_regprocedure(expected_function.signature)
    where function_definition.oid is null
      or pg_get_userbyid(function_definition.proowner) <> 'postgres'
      or not function_definition.prosecdef
      or md5(pg_get_functiondef(function_definition.oid)) <>
        expected_function.definition_md5
  ) then
    raise exception
      'Reviewed helper definition, ownership, or security mode has drifted';
  end if;

  select md5(
    string_agg(
      concat_ws(
        E'\n',
        policy_definition.schemaname,
        policy_definition.tablename,
        policy_definition.policyname,
        policy_definition.permissive,
        array_to_string(policy_definition.roles, ','),
        policy_definition.cmd,
        coalesce(policy_definition.qual, '<null>'),
        coalesce(policy_definition.with_check, '<null>')
      ),
      E'\n---\n'
      order by
        policy_definition.tablename,
        policy_definition.policyname
    )
  )
  into policy_snapshot_md5
  from pg_policies policy_definition
  where policy_definition.schemaname = 'public'
    and policy_definition.tablename in (
      'ai_knowledge_items',
      'app_events',
      'app_sessions',
      'app_settings',
      'articles',
      'audit_logs',
      'bugs',
      'categories',
      'cities',
      'content_sync_state',
      'faq_items',
      'feedback',
      'map_points',
      'official_links',
      'profiles',
      'release_checklist_items',
      'releases',
      'resources',
      'screenshots',
      'sync_jobs'
    );

  if policy_snapshot_md5 is distinct from
    'bfb94bd1d1b2812c75c676e7d21cbbde' then
    raise exception 'Reviewed RLS policy snapshot has drifted';
  end if;

  if to_regnamespace('private') is not null then
    raise exception 'The private schema already exists and requires review';
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'app_events'
      and policyname = 'server inserts app events'
      and cmd = 'INSERT'
      and with_check = 'true'
  ) or not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'app_sessions'
      and policyname = 'server inserts app sessions'
      and cmd = 'INSERT'
      and with_check = 'true'
  ) then
    raise exception 'Analytics INSERT policies differ from the reviewed snapshot';
  end if;

  select md5(
    string_agg(
      pg_get_triggerdef(trigger_definition.oid, false),
      E'\n---\n'
      order by pg_get_triggerdef(trigger_definition.oid, false)
    )
  )
  into trigger_snapshot_md5
  from pg_trigger trigger_definition
  where not trigger_definition.tgisinternal
    and trigger_definition.tgname = 'on_auth_user_created'
    and trigger_definition.tgrelid = 'auth.users'::regclass;

  if trigger_snapshot_md5 is distinct from
    'e7291ae6178510cb0f6bc2945428d139' then
    raise exception 'auth.users trigger snapshot has drifted';
  end if;

  if not exists (
    select 1
    from pg_trigger trigger_definition
    join pg_proc function_definition
      on function_definition.oid = trigger_definition.tgfoid
    join pg_namespace function_schema
      on function_schema.oid = function_definition.pronamespace
    where not trigger_definition.tgisinternal
      and trigger_definition.tgname = 'on_auth_user_created'
      and trigger_definition.tgrelid = 'auth.users'::regclass
      and function_schema.nspname = 'public'
      and function_definition.proname = 'handle_new_admin_user'
  ) then
    raise exception 'auth.users trigger dependency differs from the reviewed snapshot';
  end if;

  if not exists (
    select 1 from pg_roles where rolname = 'supabase_auth_admin'
  ) then
    raise exception 'Required Supabase Auth database role is unavailable';
  end if;
end
$migration_guard$;

create schema private authorization postgres;
comment on schema private is
  'Non-exposed security helpers for YouNew database policies and auth triggers.';

revoke all privileges on schema private from public;

alter function public.current_admin_role() set schema private;
alter function public.is_approved_admin() set schema private;
alter function public.handle_new_admin_user() set schema private;

alter function private.current_admin_role() set search_path to pg_catalog;
alter function private.is_approved_admin() set search_path to pg_catalog;
alter function private.handle_new_admin_user() set search_path to pg_catalog;

revoke all privileges
  on function private.current_admin_role()
  from public, anon, authenticated, service_role;
revoke all privileges
  on function private.is_approved_admin()
  from public, anon, authenticated, service_role;
revoke all privileges
  on function private.handle_new_admin_user()
  from public, anon, authenticated, service_role;

grant usage on schema private to authenticated;
grant execute on function private.current_admin_role() to authenticated;
grant execute on function private.is_approved_admin() to authenticated;
grant execute on function private.handle_new_admin_user() to supabase_auth_admin;

alter default privileges for role postgres in schema public
  revoke execute on functions from public;
alter default privileges for role postgres in schema private
  revoke execute on functions from public;

-- Analytics is disabled in the reviewed iOS and website sources. Retain only
-- approved-admin reads; future ingestion must use a versioned server boundary.

alter table public.app_events enable row level security;
alter table public.app_sessions enable row level security;

drop policy "server inserts app events" on public.app_events;
drop policy "server inserts app sessions" on public.app_sessions;
drop policy "approved admins read app events" on public.app_events;
drop policy "approved admins read app sessions" on public.app_sessions;

create policy "approved admins read app events"
on public.app_events
for select
to authenticated
using ((select private.is_approved_admin()));

create policy "approved admins read app sessions"
on public.app_sessions
for select
to authenticated
using ((select private.is_approved_admin()));

-- Public settings: one SELECT policy per API role and command-scoped writes.

alter table public.app_settings enable row level security;
drop policy "owners and admins manage settings" on public.app_settings;
drop policy "published settings are public" on public.app_settings;

create policy "published settings are public"
on public.app_settings
for select
to anon
using (status = 'published'::public.publication_status);

create policy "published settings and approved admins can read"
on public.app_settings
for select
to authenticated
using (
  status = 'published'::public.publication_status
  or (select private.is_approved_admin())
);

create policy "owners and admins insert settings"
on public.app_settings
for insert
to authenticated
with check (
  (select private.current_admin_role()) = any (
    array['owner'::public.admin_role, 'admin'::public.admin_role]
  )
);

create policy "owners and admins update settings"
on public.app_settings
for update
to authenticated
using (
  (select private.current_admin_role()) = any (
    array['owner'::public.admin_role, 'admin'::public.admin_role]
  )
)
with check (
  (select private.current_admin_role()) = any (
    array['owner'::public.admin_role, 'admin'::public.admin_role]
  )
);

create policy "owners and admins delete settings"
on public.app_settings
for delete
to authenticated
using (
  (select private.current_admin_role()) = any (
    array['owner'::public.admin_role, 'admin'::public.admin_role]
  )
);

-- Articles.

alter table public.articles enable row level security;
drop policy "content admins manage articles" on public.articles;
drop policy "published articles are public" on public.articles;

create policy "published articles are public"
on public.articles
for select
to anon
using (status = 'published'::public.publication_status);

create policy "published articles and approved admins can read"
on public.articles
for select
to authenticated
using (
  status = 'published'::public.publication_status
  or (select private.is_approved_admin())
);

create policy "content admins insert articles"
on public.articles
for insert
to authenticated
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins update articles"
on public.articles
for update
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
)
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins delete articles"
on public.articles
for delete
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

-- Categories.

alter table public.categories enable row level security;
drop policy "content admins manage categories" on public.categories;
drop policy "published content is public" on public.categories;

create policy "published content is public"
on public.categories
for select
to anon
using (status = 'published'::public.publication_status);

create policy "published categories and approved admins can read"
on public.categories
for select
to authenticated
using (
  status = 'published'::public.publication_status
  or (select private.is_approved_admin())
);

create policy "content admins insert categories"
on public.categories
for insert
to authenticated
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins update categories"
on public.categories
for update
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
)
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins delete categories"
on public.categories
for delete
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

-- Cities.

alter table public.cities enable row level security;
drop policy "content admins manage cities" on public.cities;
drop policy "published cities are public" on public.cities;

create policy "published cities are public"
on public.cities
for select
to anon
using (status = 'published'::public.publication_status);

create policy "published cities and approved admins can read"
on public.cities
for select
to authenticated
using (
  status = 'published'::public.publication_status
  or (select private.is_approved_admin())
);

create policy "content admins insert cities"
on public.cities
for insert
to authenticated
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins update cities"
on public.cities
for update
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
)
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins delete cities"
on public.cities
for delete
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

-- FAQ.

alter table public.faq_items enable row level security;
drop policy "content admins manage faq" on public.faq_items;
drop policy "published faq is public" on public.faq_items;

create policy "published faq is public"
on public.faq_items
for select
to anon
using (status = 'published'::public.publication_status);

create policy "published faq and approved admins can read"
on public.faq_items
for select
to authenticated
using (
  status = 'published'::public.publication_status
  or (select private.is_approved_admin())
);

create policy "content admins insert faq"
on public.faq_items
for insert
to authenticated
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins update faq"
on public.faq_items
for update
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
)
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins delete faq"
on public.faq_items
for delete
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

-- Map points.

alter table public.map_points enable row level security;
drop policy "content admins manage map points" on public.map_points;
drop policy "published map points are public" on public.map_points;

create policy "published map points are public"
on public.map_points
for select
to anon
using (status = 'published'::public.publication_status);

create policy "published map points and approved admins can read"
on public.map_points
for select
to authenticated
using (
  status = 'published'::public.publication_status
  or (select private.is_approved_admin())
);

create policy "content admins insert map points"
on public.map_points
for insert
to authenticated
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins update map points"
on public.map_points
for update
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
)
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins delete map points"
on public.map_points
for delete
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

-- Resources.

alter table public.resources enable row level security;
drop policy "content admins manage resources" on public.resources;
drop policy "published resources are public" on public.resources;

create policy "published resources are public"
on public.resources
for select
to anon
using (status = 'published'::public.publication_status);

create policy "published resources and approved admins can read"
on public.resources
for select
to authenticated
using (
  status = 'published'::public.publication_status
  or (select private.is_approved_admin())
);

create policy "content admins insert resources"
on public.resources
for insert
to authenticated
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins update resources"
on public.resources
for update
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
)
with check (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

create policy "content admins delete resources"
on public.resources
for delete
to authenticated
using (
  (select private.current_admin_role()) = any (
    array[
      'owner'::public.admin_role,
      'admin'::public.admin_role,
      'editor'::public.admin_role
    ]
  )
);

-- Profiles.

alter table public.profiles enable row level security;
drop policy "approved admins can read profiles" on public.profiles;
drop policy "owners can manage profiles" on public.profiles;

create policy "approved admins can read profiles"
on public.profiles
for select
to authenticated
using ((select private.is_approved_admin()));

create policy "owners can insert profiles"
on public.profiles
for insert
to authenticated
with check (
  (select private.current_admin_role()) = 'owner'::public.admin_role
);

create policy "owners can update profiles"
on public.profiles
for update
to authenticated
using (
  (select private.current_admin_role()) = 'owner'::public.admin_role
)
with check (
  (select private.current_admin_role()) = 'owner'::public.admin_role
);

create policy "owners can delete profiles"
on public.profiles
for delete
to authenticated
using (
  (select private.current_admin_role()) = 'owner'::public.admin_role
);

-- Explicit table grants match the RLS contract. RLS does not protect
-- TRUNCATE, REFERENCES, or TRIGGER, so every reviewed client grant is reset
-- before the minimum Data API privileges are restored. None of these tables
-- uses a sequence-backed identity column.

revoke all privileges
  on table
    public.ai_knowledge_items,
    public.app_events,
    public.app_sessions,
    public.app_settings,
    public.articles,
    public.audit_logs,
    public.bugs,
    public.categories,
    public.cities,
    public.content_sync_state,
    public.faq_items,
    public.feedback,
    public.map_points,
    public.official_links,
    public.profiles,
    public.release_checklist_items,
    public.releases,
    public.resources,
    public.screenshots,
    public.sync_jobs
  from anon, authenticated;

grant select
  on table
    public.app_settings,
    public.articles,
    public.categories,
    public.cities,
    public.faq_items,
    public.map_points,
    public.resources
  to anon;

grant select
  on table
    public.app_events,
    public.app_sessions
  to authenticated;

grant select, insert, update, delete
  on table
    public.ai_knowledge_items,
    public.app_settings,
    public.articles,
    public.bugs,
    public.categories,
    public.cities,
    public.content_sync_state,
    public.faq_items,
    public.feedback,
    public.map_points,
    public.official_links,
    public.profiles,
    public.release_checklist_items,
    public.releases,
    public.resources,
    public.screenshots
  to authenticated;

grant select, insert
  on table
    public.audit_logs,
    public.sync_jobs
  to authenticated;

-- Remaining helper-backed policies are admin-only. Narrow them from PUBLIC so
-- anonymous requests never need access to the private helper schema.

alter policy "content admins manage ai knowledge"
  on public.ai_knowledge_items to authenticated;
alter policy "approved admins insert audit logs"
  on public.audit_logs to authenticated;
alter policy "approved admins read audit logs"
  on public.audit_logs to authenticated;
alter policy "qa admins manage bugs"
  on public.bugs to authenticated;
alter policy "approved admins manage sync state"
  on public.content_sync_state to authenticated;
alter policy "admins manage feedback"
  on public.feedback to authenticated;
alter policy "admins manage official links"
  on public.official_links to authenticated;
alter policy "qa admins manage release checklist"
  on public.release_checklist_items to authenticated;
alter policy "qa admins manage releases"
  on public.releases to authenticated;
alter policy "qa admins manage screenshots"
  on public.screenshots to authenticated;
alter policy "approved admins insert sync jobs"
  on public.sync_jobs to authenticated;
alter policy "approved admins read sync jobs"
  on public.sync_jobs to authenticated;

do $migration_postcondition$
begin
  if to_regprocedure('public.current_admin_role()') is not null
    or to_regprocedure('public.is_approved_admin()') is not null
    or to_regprocedure('public.handle_new_admin_user()') is not null then
    raise exception 'A reviewed SECURITY DEFINER function remains in public';
  end if;

  if exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename in ('app_events', 'app_sessions')
      and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
      and (coalesce(qual, '') = 'true' or coalesce(with_check, '') = 'true')
  ) then
    raise exception 'An unrestricted analytics write policy remains';
  end if;

  if has_table_privilege('anon', 'public.app_events', 'INSERT')
    or has_table_privilege('authenticated', 'public.app_events', 'INSERT')
    or has_table_privilege('anon', 'public.app_sessions', 'INSERT')
    or has_table_privilege('authenticated', 'public.app_sessions', 'INSERT') then
    raise exception 'A client role still has direct analytics INSERT privilege';
  end if;

  if exists (
    select 1
    from (
      values
        ('ai_knowledge_items'),
        ('app_events'),
        ('app_sessions'),
        ('app_settings'),
        ('articles'),
        ('audit_logs'),
        ('bugs'),
        ('categories'),
        ('cities'),
        ('content_sync_state'),
        ('faq_items'),
        ('feedback'),
        ('map_points'),
        ('official_links'),
        ('profiles'),
        ('release_checklist_items'),
        ('releases'),
        ('resources'),
        ('screenshots'),
        ('sync_jobs')
    ) as reviewed_table(name)
    cross join (
      values ('anon'), ('authenticated')
    ) as client_role(name)
    cross join (
      values ('TRUNCATE'), ('REFERENCES'), ('TRIGGER')
    ) as high_risk_privilege(name)
    where has_table_privilege(
      client_role.name,
      format('public.%I', reviewed_table.name),
      high_risk_privilege.name
    )
  ) then
    raise exception
      'A client role retains TRUNCATE, REFERENCES, or TRIGGER privilege';
  end if;
end
$migration_postcondition$;
