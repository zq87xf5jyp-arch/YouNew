begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(37);

select ok(
  (select relrowsecurity from pg_class where oid = 'public.articles'::regclass),
  'articles keeps RLS enabled'
);
select ok(
  (select qual from pg_policies where schemaname = 'public' and tablename = 'articles' and policyname = 'content admins update articles')
    like all (array['%draft%', '%review%', '%qa%'])
  and (select qual from pg_policies where schemaname = 'public' and tablename = 'articles' and policyname = 'content admins update articles')
    not like all (array['%research%', '%needs_review%', '%archived%', '%published%']),
  'article UPDATE permits editors only for stored draft, review and QA rows'
);
select ok(
  (select with_check from pg_policies where schemaname = 'public' and tablename = 'articles' and policyname = 'content admins update articles')
    like all (array['%draft%', '%review%', '%qa%'])
  and (select with_check from pg_policies where schemaname = 'public' and tablename = 'articles' and policyname = 'content admins update articles')
    not like all (array['%research%', '%needs_review%', '%archived%', '%published%']),
  'article UPDATE permits editors to produce only draft, review and QA rows'
);
select ok(
  (select qual from pg_policies where schemaname = 'public' and tablename = 'articles' and policyname = 'content admins delete articles')
    like all (array['%draft%', '%review%', '%qa%'])
  and (select qual from pg_policies where schemaname = 'public' and tablename = 'articles' and policyname = 'content admins delete articles')
    not like all (array['%research%', '%needs_review%', '%archived%', '%published%']),
  'article DELETE permits editors only for draft, review and QA rows'
);
select ok(
  (select with_check from pg_policies where schemaname = 'public' and tablename = 'articles' and policyname = 'content admins insert articles')
    like all (array['%draft%', '%review%', '%qa%'])
  and (select with_check from pg_policies where schemaname = 'public' and tablename = 'articles' and policyname = 'content admins insert articles')
    not like all (array['%research%', '%needs_review%', '%archived%', '%published%']),
  'article INSERT permits editors only for draft, review and QA rows'
);
select is(
  (
    select count(*)
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and cmd in ('DELETE', 'ALL')
      and roles::text like '%authenticated%'
      and coalesce(qual, '') like '%content-images%'
  ),
  0::bigint,
  'authenticated browser sessions have no content-images DELETE policy'
);
select ok(
  (select qual from pg_policies where schemaname = 'storage' and tablename = 'objects' and policyname = 'approved roles update content images')
    like '%content_image_is_published%',
  'Storage UPDATE protects images attached to published articles'
);
select ok(
  not (select prosecdef from pg_proc where oid = 'public.content_image_paths_in_use(text[])'::regprocedure),
  'server reference lookup is security invoker'
);
select ok(
  not has_function_privilege('authenticated', 'public.content_image_paths_in_use(text[])', 'EXECUTE'),
  'authenticated clients cannot call the server reference lookup'
);
select ok(
  has_function_privilege('service_role', 'public.content_image_paths_in_use(text[])', 'EXECUTE'),
  'service role can call the server reference lookup'
);
select ok(
  (select prosecdef from pg_proc where oid = 'private.content_image_is_published(text)'::regprocedure),
  'published-image lookup is an internal security-definer policy helper'
);
select ok(
  pg_get_functiondef(
    'public.transition_content_review_task(uuid,public.governance_review_state,public.governance_review_state,uuid,text,text)'::regprocedure
  ) not like '%p_expected_state = ''approved'' and p_to_state = ''closed''%',
  'generic review transition no longer permits approved to closed'
);
select ok(
  pg_get_functiondef(
    'public.transition_content_review_task(uuid,public.governance_review_state,public.governance_review_state,uuid,text,text)'::regprocedure
  ) not like '%resolved_at = case when p_to_state = ''closed''%',
  'generic review transition cannot set task resolution timestamps'
);
select ok(
  pg_get_functiondef('public.approve_content_publication(text,integer,text,text)'::regprocedure)
    like '%set state = ''closed''%',
  'explicit publication approval remains the task-closing path'
);

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '81000000-0000-4000-8000-000000000001',
    'authenticated', 'authenticated', 'content-editor@example.invalid', '', now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '81000000-0000-4000-8000-000000000002',
    'authenticated', 'authenticated', 'content-admin@example.invalid', '', now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '81000000-0000-4000-8000-000000000003',
    'authenticated', 'authenticated', 'content-owner@example.invalid', '', now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()
  );

update public.profiles
set role = case id
    when '81000000-0000-4000-8000-000000000001'::uuid then 'editor'::public.admin_role
    when '81000000-0000-4000-8000-000000000002'::uuid then 'admin'::public.admin_role
    else 'owner'::public.admin_role
  end,
  is_approved = true
where id in (
  '81000000-0000-4000-8000-000000000001'::uuid,
  '81000000-0000-4000-8000-000000000002'::uuid,
  '81000000-0000-4000-8000-000000000003'::uuid
);

select set_config('request.jwt.claim.sub', '81000000-0000-4000-8000-000000000003', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"81000000-0000-4000-8000-000000000003","role":"authenticated"}',
  true
);
set local role service_role;

insert into public.categories (id, title, slug, status, priority)
values (
  '82000000-0000-4000-8000-000000000001',
  'Synthetic content security',
  'pgtap-content-security',
  'draft',
  999
);

insert into public.articles (
  id, title, canonical_title, slug, short_description, full_content,
  category_id, language, status, priority, source_url, official_source,
  author_id, images, verified_date, reviewer_id, reviewed_at,
  source_mapping, publication_evidence, validation_passed, validation_errors,
  search_intents, search_synonyms, search_keywords, supported_languages,
  country_scope, scope_level, national_fallback, applicable_profiles,
  source_urls, content_quality_score, search_indexed
) values
  (
    '83000000-0000-4000-8000-000000000001',
    'Editor draft fixture', 'Editor draft fixture', 'pgtap-editor-draft',
    'Synthetic draft for RLS validation.', 'Synthetic draft for RLS validation.',
    '82000000-0000-4000-8000-000000000001', 'en', 'draft', 1,
    'https://example.invalid/draft', true,
    '81000000-0000-4000-8000-000000000001', '[]'::jsonb,
    current_date, '81000000-0000-4000-8000-000000000002', now(),
    '[{"url":"https://example.invalid/draft","type":"official"}]'::jsonb,
    '{"validation_status":"passed","sample":true}'::jsonb,
    true, '{}'::text[],
    array['content.draft'], array['draft'], array['draft'], array['en'],
    'NL', 'national', true, array['expat'],
    array['https://example.invalid/draft'], 100, true
  ),
  (
    '83000000-0000-4000-8000-000000000002',
    'Editor delete fixture', 'Editor delete fixture', 'pgtap-editor-delete',
    'Synthetic draft for DELETE validation.', 'Synthetic draft for DELETE validation.',
    '82000000-0000-4000-8000-000000000001', 'en', 'review', 2,
    'https://example.invalid/delete', true,
    '81000000-0000-4000-8000-000000000001', '[]'::jsonb,
    null, null, null, '[]'::jsonb, '{}'::jsonb, false, '{}'::text[],
    array['content.delete'], array['delete'], array['delete'], array['en'],
    'NL', 'national', true, array['expat'],
    array['https://example.invalid/delete'], 50, false
  ),
  (
    '83000000-0000-4000-8000-000000000003',
    'Published security fixture', 'Published security fixture', 'pgtap-published-security',
    'Synthetic published row for RLS validation.', 'Synthetic published row for RLS validation.',
    '82000000-0000-4000-8000-000000000001', 'en', 'published', 3,
    'https://example.invalid/published', true,
    '81000000-0000-4000-8000-000000000003',
    '[{"path":"articles/pgtap/published.webp"}]'::jsonb,
    current_date, '81000000-0000-4000-8000-000000000002', now(),
    '[{"url":"https://example.invalid/published","type":"official"}]'::jsonb,
    '{"validation_status":"passed","sample":true}'::jsonb,
    true, '{}'::text[],
    array['content.published'], array['published'], array['published'], array['en'],
    'NL', 'national', true, array['expat'],
    array['https://example.invalid/published'], 100, true
  );

insert into storage.objects (bucket_id, name, metadata)
values
  ('content-images', 'articles/pgtap/published.webp', '{}'::jsonb),
  ('content-images', 'articles/pgtap/unreferenced.webp', '{}'::jsonb);

insert into public.articles (
  id, title, canonical_title, slug, short_description, full_content,
  category_id, language, status, priority, author_id, images
) values
  ('83000000-0000-4000-8000-000000000004', 'Editor QA fixture', 'Editor QA fixture', 'pgtap-editor-qa', 'Synthetic QA row.', 'Synthetic QA row.', '82000000-0000-4000-8000-000000000001', 'en', 'qa', 4, '81000000-0000-4000-8000-000000000001', '[]'::jsonb),
  ('83000000-0000-4000-8000-000000000005', 'Editor research denied fixture', 'Editor research denied fixture', 'pgtap-editor-research', 'Synthetic research row.', 'Synthetic research row.', '82000000-0000-4000-8000-000000000001', 'en', 'research', 5, '81000000-0000-4000-8000-000000000001', '[]'::jsonb),
  ('83000000-0000-4000-8000-000000000006', 'Editor needs review denied fixture', 'Editor needs review denied fixture', 'pgtap-editor-needs-review', 'Synthetic needs-review row.', 'Synthetic needs-review row.', '82000000-0000-4000-8000-000000000001', 'en', 'needs_review', 6, '81000000-0000-4000-8000-000000000001', '[]'::jsonb),
  ('83000000-0000-4000-8000-000000000007', 'Editor archived denied fixture', 'Editor archived denied fixture', 'pgtap-editor-archived', 'Synthetic archived row.', 'Synthetic archived row.', '82000000-0000-4000-8000-000000000001', 'en', 'archived', 7, '81000000-0000-4000-8000-000000000001', '[]'::jsonb);

reset role;
select set_config('request.jwt.claim.sub', '81000000-0000-4000-8000-000000000001', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"81000000-0000-4000-8000-000000000001","role":"authenticated"}',
  true
);
set local role authenticated;

select lives_ok(
  $$
    insert into public.articles (
      id, title, canonical_title, slug, short_description, full_content,
      category_id, language, status, priority, author_id, images
    ) values (
      '83000000-0000-4000-8000-000000000008', 'Editor inserted QA fixture', 'Editor inserted QA fixture',
      'pgtap-editor-insert-qa', 'Synthetic QA insert.', 'Synthetic QA insert.',
      '82000000-0000-4000-8000-000000000001', 'en', 'qa', 8,
      '81000000-0000-4000-8000-000000000001', '[]'::jsonb
    )
  $$,
  'editor can insert an allowed QA article'
);
select throws_ok(
  $$ insert into public.articles (title, canonical_title, slug, category_id, language, status) values ('Denied research', 'Denied research', 'pgtap-denied-research', '82000000-0000-4000-8000-000000000001', 'en', 'research') $$,
  '42501', null, 'editor cannot insert a research article'
);
select throws_ok(
  $$ insert into public.articles (title, canonical_title, slug, category_id, language, status) values ('Denied needs review', 'Denied needs review', 'pgtap-denied-needs-review', '82000000-0000-4000-8000-000000000001', 'en', 'needs_review') $$,
  '42501', null, 'editor cannot insert a needs-review article'
);
select throws_ok(
  $$ insert into public.articles (title, canonical_title, slug, category_id, language, status) values ('Denied archived', 'Denied archived', 'pgtap-denied-archived', '82000000-0000-4000-8000-000000000001', 'en', 'archived') $$,
  '42501', null, 'editor cannot insert an archived article'
);

select results_eq(
  $$with changed as (
      update public.articles set title = 'Editor updated draft'
      where id = '83000000-0000-4000-8000-000000000001' returning id
    ) select count(*)::bigint from changed$$,
  $$values (1::bigint)$$,
  'editor can update a non-published article'
);
select results_eq(
  $$with changed as (
      update public.articles set title = 'Editor attempted published change'
      where id = '83000000-0000-4000-8000-000000000003' returning id
    ) select count(*)::bigint from changed$$,
  $$values (0::bigint)$$,
  'editor cannot update a published article'
);
select results_eq(
  $$with removed as (
      delete from public.articles where id = '83000000-0000-4000-8000-000000000003' returning id
    ) select count(*)::bigint from removed$$,
  $$values (0::bigint)$$,
  'editor cannot delete a published article'
);
select results_eq(
  $$with changed as (update public.articles set title = 'Denied research update' where id = '83000000-0000-4000-8000-000000000005' returning id) select count(*)::bigint from changed$$,
  $$values (0::bigint)$$,
  'editor cannot update a research article'
);
select results_eq(
  $$with changed as (update public.articles set title = 'Denied needs-review update' where id = '83000000-0000-4000-8000-000000000006' returning id) select count(*)::bigint from changed$$,
  $$values (0::bigint)$$,
  'editor cannot update a needs-review article'
);
select results_eq(
  $$with changed as (update public.articles set title = 'Denied archived update' where id = '83000000-0000-4000-8000-000000000007' returning id) select count(*)::bigint from changed$$,
  $$values (0::bigint)$$,
  'editor cannot update an archived article'
);
select results_eq(
  $$with removed as (delete from public.articles where id = '83000000-0000-4000-8000-000000000005' returning id) select count(*)::bigint from removed$$,
  $$values (0::bigint)$$,
  'editor cannot delete a research article'
);
select results_eq(
  $$with removed as (delete from public.articles where id = '83000000-0000-4000-8000-000000000006' returning id) select count(*)::bigint from removed$$,
  $$values (0::bigint)$$,
  'editor cannot delete a needs-review article'
);
select results_eq(
  $$with removed as (delete from public.articles where id = '83000000-0000-4000-8000-000000000007' returning id) select count(*)::bigint from removed$$,
  $$values (0::bigint)$$,
  'editor cannot delete an archived article'
);
select throws_ok(
  $$
    update public.articles
    set status = 'published'
    where id = '83000000-0000-4000-8000-000000000001'
  $$,
  '42501',
  null,
  'editor cannot promote a draft directly to published'
);
select results_eq(
  $$with removed as (
      delete from public.articles where id = '83000000-0000-4000-8000-000000000002' returning id
    ) select count(*)::bigint from removed$$,
  $$values (1::bigint)$$,
  'editor can delete a non-published article'
);
select throws_ok(
  $$with removed as (
      delete from storage.objects
      where bucket_id = 'content-images' and name = 'articles/pgtap/unreferenced.webp'
      returning id
    ) select count(*)::bigint from removed$$,
  '42501',
  null,
  'editor cannot directly delete a Storage object'
);
select throws_ok(
  $$ select * from public.content_image_paths_in_use(array['articles/pgtap/published.webp']) $$,
  '42501',
  null,
  'editor cannot invoke the server-only reference guard'
);
select throws_ok(
  $$
    select public.transition_content_review_task(
      '84000000-0000-4000-8000-000000000001',
      'in_review', 'approved', null,
      'pgtap-editor-approve', 'Synthetic editor approval attempt.'
    )
  $$,
  '42501',
  null,
  'editor cannot approve a review'
);

reset role;
set local role service_role;
select results_eq(
  $$ select path from public.content_image_paths_in_use(array['articles/pgtap/published.webp', 'articles/pgtap/unreferenced.webp']) order by path $$,
  $$ values ('articles/pgtap/published.webp'::text) $$,
  'server reference guard returns only paths still used by articles'
);
select throws_ok(
  $$with removed as (
      delete from storage.objects
      where bucket_id = 'content-images' and name = 'articles/pgtap/unreferenced.webp'
      returning id
    ) select count(*)::bigint from removed$$,
  '42501',
  null,
  'service role cannot bypass Storage API deletion protection with direct SQL'
);

reset role;
select set_config('request.jwt.claim.sub', '81000000-0000-4000-8000-000000000002', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"81000000-0000-4000-8000-000000000002","role":"authenticated"}',
  true
);
set local role authenticated;
select results_eq(
  $$with changed as (
      update public.articles set title = 'Admin updated published row'
      where id = '83000000-0000-4000-8000-000000000003' returning id
    ) select count(*)::bigint from changed$$,
  $$values (1::bigint)$$,
  'admin can update a published article'
);
select throws_ok(
  $$
    select public.transition_content_review_task(
      '84000000-0000-4000-8000-000000000001',
      'approved', 'closed', null,
      'pgtap-generic-close', 'Synthetic generic close attempt.'
    )
  $$,
  '42501',
  null,
  'admin cannot close an approved task through the generic transition'
);

reset role;
select set_config('request.jwt.claim.sub', '81000000-0000-4000-8000-000000000003', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"81000000-0000-4000-8000-000000000003","role":"authenticated"}',
  true
);
set local role authenticated;
select results_eq(
  $$with removed as (
      delete from public.articles where id = '83000000-0000-4000-8000-000000000003' returning id
    ) select count(*)::bigint from removed$$,
  $$values (1::bigint)$$,
  'owner can delete a published article'
);

reset role;
select * from finish();
rollback;
