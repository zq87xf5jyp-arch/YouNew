begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, extensions;

select plan(12);

select is(
  public.governance_review_due_lead_days(2),
  1,
  'review_due_soon has a minimum one-day lead'
);
select is(
  public.governance_review_due_lead_days(90),
  14,
  'review_due_soon is capped at fourteen days'
);
select is(
  public.governance_effective_status(
    'verified', 'archived', 'https://example.nl/source',
    now(), now() + interval '90 days', null, null, 90, now()
  )::text,
  'archived',
  'archived publication status has highest precedence'
);
select is(
  public.governance_effective_status(
    'verified', 'published', null,
    now(), now() + interval '90 days', null, null, 90, now()
  )::text,
  'unverified',
  'missing official source fails closed'
);
select is(
  public.governance_confidence_score(
    '{"officialSource":40,"humanReviewer":20,"independentReview":15,"freshness":10,"jurisdictionApplicability":15}'::jsonb
  ),
  100,
  'confidence evidence coverage formula v1 is reproducible'
);

set local role service_role;

select lives_ok(
  $$
    insert into public.content_governance_state (
      record_key, content_id, title, content_type, jurisdiction,
      official_source_url, source_is_official, source_opened_at,
      content_origin, origin_reference, origin_captured_at, origin_artifact_digest
    ) values (
      'pgtap:ai-draft', 'pgtap-ai-draft', 'AI draft fixture', 'article',
      '{"countryCode":"NL","level":"national","municipalityDependent":false,"applicabilityVerified":false,"provinceCode":null,"provinceName":null,"municipalityCode":null,"municipalityName":null}'::jsonb,
      'https://example.nl/source', true, now(),
      'ai_generated_draft', 'pgtap', now(), 'sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
    )
  $$,
  'service can create only the initial draft projection'
);
select is(
  (
    select actor_type
    from public.content_governance_versions
    where governance_state_id = (
      select id from public.content_governance_state where record_key = 'pgtap:ai-draft'
    )
      and version = 1
  ),
  'ai',
  'AI origin is preserved in append-only version provenance'
);
select throws_ok(
  $$
    insert into public.content_governance_state (
      record_key, content_id, title, content_type, jurisdiction,
      verification_status, publication_status, content_origin
    ) values (
      'pgtap:unsafe-insert', 'pgtap-unsafe-insert', 'Unsafe fixture', 'article',
      '{"countryCode":"NL","level":"national","municipalityDependent":false,"applicabilityVerified":false,"provinceCode":null,"provinceName":null,"municipalityCode":null,"municipalityName":null}'::jsonb,
      'verified', 'published', 'ai_generated_draft'
    )
  $$,
  '23514',
  'initial_governance_must_be_draft_unverified',
  'AI/service insert cannot create a published or verified record'
);
select throws_ok(
  $$
    update public.content_governance_state
    set reviewed_by = gen_random_uuid(), verification_status = 'verified'
    where record_key = 'pgtap:ai-draft'
  $$,
  '42501',
  'review_event_required',
  'direct verification mutation is denied without a matching review event'
);
select throws_ok(
  $$
    delete from public.content_governance_versions
    where governance_state_id = (
      select id from public.content_governance_state where record_key = 'pgtap:ai-draft'
    )
  $$,
  '42501',
  'append_only_governance_history',
  'governance history cannot be deleted'
);

reset role;
set local role authenticated;

select is(
  (select count(*) from public.content_governance_state where record_key = 'pgtap:ai-draft'),
  0::bigint,
  'an unauthenticated authenticated-role session sees no governance rows through RLS'
);
select throws_ok(
  $$
    insert into public.content_governance_state (
      record_key, content_id, title, content_type, jurisdiction, content_origin
    ) values (
      'pgtap:editor-direct', 'pgtap-editor-direct', 'Editor direct fixture', 'article',
      '{"countryCode":"NL","level":"national","municipalityDependent":false,"applicabilityVerified":false,"provinceCode":null,"provinceName":null,"municipalityCode":null,"municipalityName":null}'::jsonb,
      'manually_created'
    )
  $$,
  '42501',
  null,
  'authenticated clients have no direct governance-table write privilege'
);

reset role;
select * from finish();
rollback;
