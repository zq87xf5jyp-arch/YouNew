-- Operational persistence for the packaged canonical map and official-link
-- registries. The generated packaged artifacts remain publication authority;
-- these tables retain Admin-only checks, aliases and notes without letting a
-- mutable database row silently redefine public content.

create or replace function private.canonicalize_official_link_url(p_url text)
returns text
language plpgsql
immutable
strict
set search_path = ''
as $function$
declare
  v_clean text := btrim(regexp_replace(p_url, '#.*$', ''));
  v_parts text[];
  v_scheme text;
  v_authority text;
  v_suffix text;
  v_path text;
begin
  if octet_length(v_clean) <> char_length(v_clean)
     or v_clean ~ '[[:space:][:cntrl:]]' then
    raise exception 'official_link_url_non_ascii_or_whitespace' using errcode = '22023';
  end if;
  v_parts := regexp_match(v_clean, '^([a-z][a-z0-9+.-]*)://([^/?#]+)([^#]*)$', 'i');
  if v_parts is null or lower(v_parts[1]) not in ('http', 'https') then
    raise exception 'official_link_url_must_be_http' using errcode = '22023';
  end if;
  v_scheme := lower(v_parts[1]);
  v_authority := lower(v_parts[2]);
  if position('@' in v_authority) > 0 then
    raise exception 'official_link_url_credentials_forbidden' using errcode = '22023';
  end if;
  if (v_scheme = 'https' and v_authority ~ ':443$')
    or (v_scheme = 'http' and v_authority ~ ':80$') then
    v_authority := regexp_replace(v_authority, ':(443|80)$', '');
  end if;
  v_suffix := coalesce(nullif(v_parts[3], ''), '/');
  v_path := split_part(v_suffix, '?', 1);
  if v_path ~* '(^|/)(\.|%2e|\.%2e|%2e\.|%2e%2e)(/|$)' then
    raise exception 'official_link_url_dot_segment_forbidden' using errcode = '22023';
  end if;
  if left(v_suffix, 1) = '?' then
    v_suffix := '/' || v_suffix;
  end if;
  return v_scheme || '://' || v_authority || v_suffix;
end
$function$;

revoke all on function private.canonicalize_official_link_url(text)
  from public, anon;
grant execute on function private.canonicalize_official_link_url(text)
  to authenticated, service_role;

create or replace function private.try_canonicalize_official_link_url(p_url text)
returns text
language plpgsql
immutable
set search_path = ''
as $function$
begin
  return private.canonicalize_official_link_url(p_url);
exception when others then
  return null;
end
$function$;

revoke all on function private.try_canonicalize_official_link_url(text)
  from public, anon;
grant execute on function private.try_canonicalize_official_link_url(text)
  to authenticated, service_role;

create table public.official_link_registry_entries (
  source_key text primary key
    check (source_key ~ '^source\.[a-f0-9]{24}$'),
  canonical_url text not null unique
    check (canonical_url = private.canonicalize_official_link_url(canonical_url)),
  title text not null check (char_length(btrim(title)) between 1 and 300),
  publisher text not null check (char_length(btrim(publisher)) between 1 and 300),
  source_type text not null
    check (source_type in ('government', 'municipality', 'transport', 'healthcare', 'education', 'other')),
  registry_fingerprint text not null check (registry_fingerprint ~ '^[a-f0-9]{64}$'),
  lifecycle_status text not null default 'active'
    check (lifecycle_status in ('active', 'superseded')),
  superseded_by_source_key text references public.official_link_registry_entries(source_key),
  admin_notes text check (admin_notes is null or char_length(admin_notes) <= 4000),
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default statement_timestamp(),
  updated_at timestamptz not null default statement_timestamp(),
  constraint official_link_registry_supersede_state check (
    (lifecycle_status = 'active' and superseded_by_source_key is null)
    or
    (lifecycle_status = 'superseded' and superseded_by_source_key is not null and superseded_by_source_key <> source_key)
  )
);

create table public.official_link_aliases (
  id uuid primary key default gen_random_uuid(),
  source_key text not null references public.official_link_registry_entries(source_key) on delete restrict,
  alias_url text not null,
  normalized_alias_url text generated always as (private.canonicalize_official_link_url(alias_url)) stored,
  alias_kind text not null default 'legacy'
    check (alias_kind in ('legacy', 'redirect', 'editorial')),
  notes text check (notes is null or char_length(notes) <= 2000),
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default statement_timestamp(),
  unique (normalized_alias_url)
);

create table public.official_link_check_results (
  id uuid primary key default gen_random_uuid(),
  source_key text not null references public.official_link_registry_entries(source_key) on delete restrict,
  checked_url text not null
    check (checked_url = private.canonicalize_official_link_url(checked_url)),
  result text not null
    check (result in ('reachable', 'redirected', 'broken', 'unknown')),
  http_status integer check (http_status between 100 and 599),
  final_url text check (final_url is null or final_url = private.canonicalize_official_link_url(final_url)),
  response_time_ms integer check (response_time_ms is null or response_time_ms between 0 and 120000),
  error_code text check (error_code is null or error_code ~ '^[a-z0-9_.-]{1,80}$'),
  notes text check (notes is null or char_length(notes) <= 2000),
  checked_at timestamptz not null,
  checked_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default statement_timestamp()
);

create index official_link_registry_lifecycle_idx
  on public.official_link_registry_entries (lifecycle_status, updated_at desc);
create index official_link_aliases_source_idx
  on public.official_link_aliases (source_key);
create index official_link_checks_latest_idx
  on public.official_link_check_results (source_key, checked_at desc, id desc);

alter table public.official_link_registry_entries enable row level security;
alter table public.official_link_aliases enable row level security;
alter table public.official_link_check_results enable row level security;

revoke all on table
  public.official_link_registry_entries,
  public.official_link_aliases,
  public.official_link_check_results
from public, anon, authenticated;

grant select, insert, update on table
  public.official_link_registry_entries,
  public.official_link_aliases
to authenticated;
grant select, insert on table public.official_link_check_results to authenticated;
grant all on table
  public.official_link_registry_entries,
  public.official_link_aliases,
  public.official_link_check_results
to service_role;

create policy "approved admins read official link registry"
on public.official_link_registry_entries for select to authenticated
using ((select private.is_approved_admin()));
create policy "owners and admins insert official link registry"
on public.official_link_registry_entries for insert to authenticated
with check ((select private.current_admin_role()) in ('owner'::public.admin_role, 'admin'::public.admin_role));
create policy "owners and admins update official link registry"
on public.official_link_registry_entries for update to authenticated
using ((select private.current_admin_role()) in ('owner'::public.admin_role, 'admin'::public.admin_role))
with check ((select private.current_admin_role()) in ('owner'::public.admin_role, 'admin'::public.admin_role));

create policy "approved admins read official link aliases"
on public.official_link_aliases for select to authenticated
using ((select private.is_approved_admin()));
create policy "owners and admins insert official link aliases"
on public.official_link_aliases for insert to authenticated
with check ((select private.current_admin_role()) in ('owner'::public.admin_role, 'admin'::public.admin_role));
create policy "owners and admins update official link aliases"
on public.official_link_aliases for update to authenticated
using ((select private.current_admin_role()) in ('owner'::public.admin_role, 'admin'::public.admin_role))
with check ((select private.current_admin_role()) in ('owner'::public.admin_role, 'admin'::public.admin_role));

create policy "approved admins read official link checks"
on public.official_link_check_results for select to authenticated
using ((select private.is_approved_admin()));
create policy "owners and admins append official link checks"
on public.official_link_check_results for insert to authenticated
with check (
  (select private.current_admin_role()) in ('owner'::public.admin_role, 'admin'::public.admin_role)
  and (checked_by is null or checked_by = (select auth.uid()))
);

create or replace view public.official_link_operational_latest
with (security_invoker = true)
as
select
  registry.source_key,
  registry.canonical_url,
  registry.title,
  registry.publisher,
  registry.source_type,
  registry.registry_fingerprint,
  registry.lifecycle_status,
  registry.superseded_by_source_key,
  registry.admin_notes,
  aliases.alias_urls,
  latest.result as link_health_state,
  latest.http_status,
  latest.final_url,
  latest.response_time_ms,
  latest.error_code,
  latest.notes as check_notes,
  latest.checked_at,
  registry.updated_at
from public.official_link_registry_entries as registry
left join lateral (
  select array_agg(alias.normalized_alias_url order by alias.normalized_alias_url) as alias_urls
  from public.official_link_aliases as alias
  where alias.source_key = registry.source_key
) as aliases on true
left join lateral (
  select check_result.*
  from public.official_link_check_results as check_result
  where check_result.source_key = registry.source_key
  order by check_result.checked_at desc, check_result.id desc
  limit 1
) as latest on true;

revoke all on table public.official_link_operational_latest from public, anon, authenticated;
grant select on table public.official_link_operational_latest to authenticated, service_role;

comment on view public.official_link_operational_latest is
  'Admin-only operational projection. Missing check_result means unknown, never healthy.';

-- Retain the legacy official_links rows and make duplicate cleanup reversible.
alter table public.official_links
  add column superseded_at timestamptz,
  add column superseded_by uuid references public.official_links(id) on delete restrict,
  add column supersede_reason text,
  add constraint official_links_soft_supersede_state check (
    (superseded_at is null and superseded_by is null and supersede_reason is null)
    or
    (superseded_at is not null and superseded_by is not null and superseded_by <> id
      and char_length(btrim(supersede_reason)) between 1 and 1000)
  );

create index official_links_active_compatibility_idx
  on public.official_links (updated_at desc)
  where superseded_at is null;

drop policy if exists "admins manage official links" on public.official_links;
drop policy if exists "approved admins read legacy official links" on public.official_links;
create policy "approved admins read legacy official links"
on public.official_links for select to authenticated
using ((select private.is_approved_admin()));

revoke insert, update, delete on table public.official_links from authenticated;
grant select on table public.official_links to authenticated;

create or replace function public.preview_legacy_official_link_duplicates()
returns table (
  canonical_url text,
  survivor_id uuid,
  duplicate_ids uuid[],
  duplicate_count bigint
)
language sql
stable
set search_path = ''
as $function$
  with normalized as (
    select
      link.id,
      link.created_at,
      private.try_canonicalize_official_link_url(link.url) as canonical_url
    from public.official_links as link
    where link.superseded_at is null
  )
  select
    normalized.canonical_url,
    (array_agg(normalized.id order by normalized.created_at, normalized.id))[1] as survivor_id,
    (array_agg(normalized.id order by normalized.created_at, normalized.id))[2:] as duplicate_ids,
    count(*) as duplicate_count
  from normalized
  where normalized.canonical_url is not null
  group by normalized.canonical_url
  having count(*) > 1
  order by normalized.canonical_url
$function$;

create or replace function public.soft_supersede_legacy_official_link(
  p_duplicate_id uuid,
  p_survivor_id uuid,
  p_reason text
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_duplicate_url text;
  v_survivor_url text;
begin
  if coalesce(private.current_admin_role()::text, '') not in ('owner', 'admin') then
    raise exception 'admin_role_required' using errcode = '42501';
  end if;
  if p_duplicate_id = p_survivor_id or char_length(btrim(coalesce(p_reason, ''))) not between 1 and 1000 then
    raise exception 'invalid_soft_supersede_request' using errcode = '22023';
  end if;

  perform 1
  from public.official_links
  where id in (p_duplicate_id, p_survivor_id)
  order by id
  for update;
  select private.canonicalize_official_link_url(url)
    into v_duplicate_url
    from public.official_links
    where id = p_duplicate_id and superseded_at is null;
  select private.canonicalize_official_link_url(url)
    into v_survivor_url
    from public.official_links
    where id = p_survivor_id and superseded_at is null;
  if v_duplicate_url is null or v_survivor_url is null or v_duplicate_url <> v_survivor_url then
    raise exception 'links_are_not_active_canonical_duplicates' using errcode = '22023';
  end if;

  update public.official_links
  set superseded_at = statement_timestamp(),
      superseded_by = p_survivor_id,
      supersede_reason = btrim(p_reason),
      updated_at = statement_timestamp()
  where id = p_duplicate_id;

  insert into public.audit_logs (user_id, action, entity_type, entity_id, new_value)
  values (
    (select auth.uid()),
    'official_link_soft_superseded',
    'official_link',
    p_duplicate_id::text,
    jsonb_build_object('survivor_id', p_survivor_id, 'history_deleted', false)
  );
  return true;
end
$function$;

revoke all on function public.preview_legacy_official_link_duplicates() from public, anon, authenticated;
revoke all on function public.soft_supersede_legacy_official_link(uuid,uuid,text) from public, anon, authenticated;
grant execute on function public.preview_legacy_official_link_duplicates() to authenticated, service_role;
grant execute on function public.soft_supersede_legacy_official_link(uuid,uuid,text) to authenticated;

create or replace view public.legacy_official_links_active
with (security_invoker = true)
as
select *
from public.official_links
where superseded_at is null;
revoke all on table public.legacy_official_links_active from public, anon, authenticated;
grant select on table public.legacy_official_links_active to authenticated, service_role;

-- One-release compatibility: the public API now reads the packaged canonical
-- registry. The legacy map table remains readable but is no longer mutable.
drop policy if exists "content admins insert map points" on public.map_points;
drop policy if exists "content admins update map points" on public.map_points;
drop policy if exists "content admins delete map points" on public.map_points;
revoke insert, update, delete on table public.map_points from authenticated;

create or replace view public.legacy_map_points_read_only
with (security_invoker = true)
as
select map_point.*, 'one_release'::text as compatibility_window
from public.map_points as map_point;
revoke all on table public.legacy_map_points_read_only from public, anon, authenticated;
grant select on table public.legacy_map_points_read_only to anon, authenticated, service_role;

comment on table public.map_points is
  'Deprecated read-only compatibility storage for one release. Public map authority is the packaged canonical registry.';
comment on view public.legacy_map_points_read_only is
  'Read-only one-release adapter; remove only through an explicitly reviewed later migration.';
