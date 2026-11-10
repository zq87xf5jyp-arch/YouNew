begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(44);

select has_table('public', 'official_link_registry_entries', 'canonical operational link registry exists');
select has_table('public', 'official_link_aliases', 'official link aliases are persisted');
select has_table('public', 'official_link_check_results', 'append-only link checks are persisted');
select ok((select relrowsecurity from pg_class where oid = 'public.official_link_registry_entries'::regclass), 'registry RLS is enabled');
select ok((select relrowsecurity from pg_class where oid = 'public.official_link_aliases'::regclass), 'alias RLS is enabled');
select ok((select relrowsecurity from pg_class where oid = 'public.official_link_check_results'::regclass), 'check-result RLS is enabled');

select ok(
  not has_table_privilege('anon', 'public.official_link_registry_entries', 'SELECT')
    and not has_table_privilege('anon', 'public.official_link_registry_entries', 'INSERT'),
  'anonymous clients cannot access registry operations'
);
select ok(
  not has_table_privilege('anon', 'public.official_link_aliases', 'SELECT')
    and not has_table_privilege('anon', 'public.official_link_aliases', 'INSERT'),
  'anonymous clients cannot access aliases'
);
select ok(
  not has_table_privilege('anon', 'public.official_link_check_results', 'SELECT')
    and not has_table_privilege('anon', 'public.official_link_check_results', 'INSERT'),
  'anonymous clients cannot access link-check history'
);
select ok(
  has_table_privilege('authenticated', 'public.official_link_registry_entries', 'SELECT')
    and has_table_privilege('authenticated', 'public.official_link_registry_entries', 'INSERT')
    and has_table_privilege('authenticated', 'public.official_link_registry_entries', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.official_link_registry_entries', 'DELETE'),
  'authenticated capability is RLS-filtered and cannot delete registry history'
);
select ok(
  has_table_privilege('authenticated', 'public.official_link_aliases', 'SELECT')
    and has_table_privilege('authenticated', 'public.official_link_aliases', 'INSERT')
    and has_table_privilege('authenticated', 'public.official_link_aliases', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.official_link_aliases', 'DELETE'),
  'alias history cannot be deleted by browser sessions'
);
select ok(
  has_table_privilege('authenticated', 'public.official_link_check_results', 'SELECT')
    and has_table_privilege('authenticated', 'public.official_link_check_results', 'INSERT')
    and not has_table_privilege('authenticated', 'public.official_link_check_results', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.official_link_check_results', 'DELETE'),
  'link-check history is append-only for Admin sessions'
);
select ok(
  has_table_privilege('authenticated', 'public.map_points', 'SELECT')
    and not has_table_privilege('authenticated', 'public.map_points', 'INSERT')
    and not has_table_privilege('authenticated', 'public.map_points', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.map_points', 'DELETE'),
  'legacy map_points is read-only for authenticated users'
);
select ok(has_table_privilege('anon', 'public.map_points', 'SELECT'), 'legacy published map rows remain readable for one release');

select ok(to_regclass('public.official_link_operational_latest') is not null, 'latest link-health projection exists');
select ok(to_regclass('public.legacy_official_links_active') is not null, 'active legacy-link projection exists');
select ok(to_regclass('public.legacy_map_points_read_only') is not null, 'legacy map compatibility projection exists');
select ok(
  (select reloptions @> array['security_invoker=true'] from pg_class where oid = 'public.official_link_operational_latest'::regclass),
  'latest link-health view invokes underlying RLS'
);
select ok(
  (select reloptions @> array['security_invoker=true'] from pg_class where oid = 'public.legacy_official_links_active'::regclass),
  'legacy link view invokes underlying RLS'
);
select ok(
  (select reloptions @> array['security_invoker=true'] from pg_class where oid = 'public.legacy_map_points_read_only'::regclass),
  'legacy map view invokes underlying RLS'
);

select has_function('private', 'canonicalize_official_link_url', array['text'], 'canonical URL helper exists');
select is(
  private.canonicalize_official_link_url('HTTPS://Example.INVALID:443?b=2&a=1#fragment'),
  'https://example.invalid/?b=2&a=1',
  'SQL canonicalization matches WHATWG root-query slash, host, port and fragment behavior'
);
select throws_ok(
  $$ select private.canonicalize_official_link_url('https://user:secret@example.invalid/path') $$,
  '22023', 'official_link_url_credentials_forbidden',
  'credential-bearing URLs are rejected by the shared canonical contract'
);
select throws_ok(
  $$ select private.canonicalize_official_link_url('https://example.invalid/a/%2e%2e/b') $$,
  '22023', 'official_link_url_dot_segment_forbidden',
  'encoded and literal dot segments are rejected instead of normalized differently across runtimes'
);
select throws_ok(
  $$ select private.canonicalize_official_link_url('https://bücher.invalid/path') $$,
  '22023', 'official_link_url_non_ascii_or_whitespace',
  'Unicode and implicit IDN transformations are rejected unless upstream supplies ASCII punycode'
);
select ok(
  not (select prosecdef from pg_proc where oid = 'private.canonicalize_official_link_url(text)'::regprocedure),
  'canonical URL helper is not security definer'
);
select ok(
  not has_function_privilege('anon', 'private.canonicalize_official_link_url(text)', 'EXECUTE')
    and has_function_privilege('authenticated', 'private.canonicalize_official_link_url(text)', 'EXECUTE'),
  'canonical helper is available only to the Admin data boundary'
);
select ok(
  has_function_privilege('authenticated', 'public.preview_legacy_official_link_duplicates()', 'EXECUTE')
    and not has_function_privilege('anon', 'public.preview_legacy_official_link_duplicates()', 'EXECUTE'),
  'duplicate preview is Admin-only'
);
select ok(
  has_function_privilege('authenticated', 'public.soft_supersede_legacy_official_link(uuid,uuid,text)', 'EXECUTE')
    and not has_function_privilege('anon', 'public.soft_supersede_legacy_official_link(uuid,uuid,text)', 'EXECUTE'),
  'soft-supersede RPC is Admin-only'
);
select ok(
  pg_get_functiondef('public.soft_supersede_legacy_official_link(uuid,uuid,text)'::regprocedure) not like '%delete from public.official_links%',
  'soft-supersede never deletes legacy history'
);
select ok(
  has_table_privilege('authenticated', 'public.official_links', 'SELECT')
    and not has_table_privilege('authenticated', 'public.official_links', 'INSERT')
    and not has_table_privilege('authenticated', 'public.official_links', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.official_links', 'DELETE')
    and not has_column_privilege('authenticated', 'public.official_links', 'superseded_at', 'UPDATE')
    and (select prosecdef from pg_proc where oid = 'public.soft_supersede_legacy_official_link(uuid,uuid,text)'::regprocedure),
  'legacy official links are read-only and supersede metadata changes only through the role-checked RPC'
);
select is(
  (select count(*) from information_schema.columns where table_schema = 'public' and table_name = 'official_links'
    and column_name in ('superseded_at', 'superseded_by', 'supersede_reason')),
  3::bigint,
  'legacy links have reversible supersede metadata'
);
select ok(
  exists (select 1 from pg_constraint where conrelid = 'public.official_links'::regclass and conname = 'official_links_soft_supersede_state'),
  'legacy supersede metadata is internally consistent'
);
select ok(
  to_regclass('public.official_link_registry_lifecycle_idx') is not null
    and to_regclass('public.official_link_aliases_source_idx') is not null
    and to_regclass('public.official_link_checks_latest_idx') is not null,
  'registry, alias and latest-check access paths are indexed'
);

set local role service_role;

select lives_ok(
  $$
    insert into public.official_link_registry_entries (
      source_key, canonical_url, title, publisher, source_type, registry_fingerprint
    ) values (
      'source.aaaaaaaaaaaaaaaaaaaaaaaa',
      'https://example.invalid/canonical',
      'Synthetic canonical source',
      'Example Authority',
      'government',
      repeat('a', 64)
    )
  $$,
  'synthetic canonical registry entry can be imported'
);
select lives_ok(
  $$
    insert into public.official_link_aliases (source_key, alias_url, alias_kind, notes)
    values ('source.aaaaaaaaaaaaaaaaaaaaaaaa', 'https://EXAMPLE.invalid/legacy', 'legacy', 'Synthetic alias');
    insert into public.official_link_check_results (
      source_key, checked_url, result, http_status, final_url, response_time_ms, checked_at, notes
    ) values (
      'source.aaaaaaaaaaaaaaaaaaaaaaaa',
      'https://example.invalid/canonical',
      'reachable',
      200,
      'https://example.invalid/canonical',
      12,
      '2026-08-19 12:00:00+00',
      'Synthetic disposable check'
    );
  $$,
  'aliases and immutable check history can be retained'
);
select is(
  (select link_health_state from public.official_link_operational_latest where source_key = 'source.aaaaaaaaaaaaaaaaaaaaaaaa'),
  'reachable',
  'latest operational view exposes the measured check rather than inventing health'
);
select is(
  (select alias_urls[1] from public.official_link_operational_latest where source_key = 'source.aaaaaaaaaaaaaaaaaaaaaaaa'),
  'https://example.invalid/legacy',
  'canonical alias normalization preserves path case and normalizes host case'
);

insert into public.official_links (id, title, url, source_type, status, created_at)
values
  ('91000000-0000-4000-8000-000000000001', 'Synthetic legacy source A', 'https://Example.invalid/duplicate', 'other', 'active', '2026-08-19 10:00:00+00'),
  ('91000000-0000-4000-8000-000000000002', 'Synthetic legacy source B', 'https://example.invalid/duplicate#fragment', 'other', 'needs review', '2026-08-19 11:00:00+00');
select is(
  (select duplicate_count from public.preview_legacy_official_link_duplicates() where canonical_url = 'https://example.invalid/duplicate'),
  2::bigint,
  'duplicate dry-run finds canonical matches without mutating them'
);
select is(
  (select count(*) from public.official_links where id in (
    '91000000-0000-4000-8000-000000000001',
    '91000000-0000-4000-8000-000000000002'
  )),
  2::bigint,
  'duplicate preview keeps every legacy history row'
);

reset role;
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values (
  '00000000-0000-0000-0000-000000000000',
  '91000000-0000-4000-8000-000000000010',
  'authenticated', 'authenticated', 'legacy-link-owner@example.invalid', '', now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
);
update public.profiles
set role = 'owner'::public.admin_role, is_approved = true
where id = '91000000-0000-4000-8000-000000000010';
select set_config('request.jwt.claim.sub', '91000000-0000-4000-8000-000000000010', true);
select set_config('request.jwt.claims', '{"sub":"91000000-0000-4000-8000-000000000010","role":"authenticated"}', true);
set local role authenticated;

select throws_ok(
  $$ update public.official_links set notes = 'Direct mutation must fail' where id = '91000000-0000-4000-8000-000000000002' $$,
  '42501', null,
  'even an Owner cannot update the legacy table directly'
);
select is(
  public.soft_supersede_legacy_official_link(
    '91000000-0000-4000-8000-000000000002',
    '91000000-0000-4000-8000-000000000001',
    'Synthetic disposable duplicate resolution'
  ),
  true,
  'Owner can use the audited soft-supersede RPC'
);

reset role;
set local role service_role;
select is(
  (select count(*) from public.official_links where id in (
    '91000000-0000-4000-8000-000000000001',
    '91000000-0000-4000-8000-000000000002'
  )),
  2::bigint,
  'soft supersede preserves both legacy history rows'
);
select ok(
  (select superseded_by = '91000000-0000-4000-8000-000000000001'::uuid
     and superseded_at is not null
     and supersede_reason = 'Synthetic disposable duplicate resolution'
   from public.official_links where id = '91000000-0000-4000-8000-000000000002')
  and exists (
    select 1 from public.audit_logs
    where entity_id = '91000000-0000-4000-8000-000000000002'
      and action = 'official_link_soft_superseded'
  ),
  'soft supersede records reversible metadata and an audit event'
);

reset role;
select * from finish();
rollback;
