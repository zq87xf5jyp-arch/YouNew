begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(19);

select ok(
  (select relrowsecurity from pg_class where oid = 'public.business_inquiries'::regclass),
  'business inquiries keeps RLS enabled'
);
select ok(
  (
    select pg_get_constraintdef(oid)
    from pg_constraint
    where conrelid = 'public.business_inquiries'::regclass
      and conname = 'business_inquiries_status_check'
  ) like all (array[
    '%new%', '%qualified%', '%discovery%', '%proposal%', '%won%', '%lost%', '%archived%'
  ])
  and (
    select pg_get_constraintdef(oid)
    from pg_constraint
    where conrelid = 'public.business_inquiries'::regclass
      and conname = 'business_inquiries_status_check'
  ) not like '%reviewing%',
  'status constraint exposes only the canonical commercial lifecycle'
);
select is(
  (
    select count(*)
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'business_inquiries'
      and column_name in (
        'contact_role', 'offer_interest', 'lost_reason', 'lost_reason_detail',
        'won_evidence_type', 'won_evidence_at', 'status_changed_at'
      )
  ),
  7::bigint,
  'all pipeline qualification and outcome columns exist'
);
select ok(
  has_column_privilege('authenticated', 'public.business_inquiries', 'lost_reason', 'UPDATE'),
  'authenticated admins can update the controlled lost reason column'
);
select ok(
  not has_column_privilege('authenticated', 'public.business_inquiries', 'message', 'UPDATE'),
  'authenticated admins cannot overwrite the submitted message'
);
select ok(
  not has_function_privilege('authenticated', 'public.set_business_inquiry_pipeline_metadata()', 'EXECUTE'),
  'the metadata trigger function is not directly executable by authenticated clients'
);

set local role service_role;

select lives_ok(
  $$
    insert into public.business_inquiries (
      id, company_name, contact_person, email, website, inquiry_type,
      organization_type, city, province, target_audience,
      requested_placements, campaign_goal, budget_range, message,
      consent_to_privacy, confirm_accuracy, consent_at
    ) values (
      '00000000-0000-4000-8000-000000000031',
      'Pipeline pgTAP BV', 'Test Owner', 'pipeline-test@example.invalid',
      'https://example.invalid', 'partnership', 'commercial-business',
      'Amsterdam', 'Noord-Holland', array['international-employees'],
      array['content-partnership'], 'Validate the commercial pipeline safely',
      'request-discussion',
      'This transaction-only fixture validates the commercial pipeline.',
      true, true, statement_timestamp()
    )
  $$,
  'service role can create a valid new inquiry fixture'
);
select throws_ok(
  $$
    update public.business_inquiries
    set status = 'reviewing'
    where id = '00000000-0000-4000-8000-000000000031'
  $$,
  '23514',
  null,
  'retired workflow states are rejected'
);
select throws_ok(
  $$
    update public.business_inquiries
    set status = 'lost'
    where id = '00000000-0000-4000-8000-000000000031'
  $$,
  '23514',
  null,
  'lost cannot be stored without a controlled reason'
);
select throws_ok(
  $$
    update public.business_inquiries
    set status = 'lost', lost_reason = 'other_explicit'
    where id = '00000000-0000-4000-8000-000000000031'
  $$,
  '23514',
  null,
  'other_explicit requires a factual detail'
);
select lives_ok(
  $$
    update public.business_inquiries
    set status = 'lost',
        lost_reason = 'other_explicit',
        lost_reason_detail = 'Buyer named a different explicit constraint.'
    where id = '00000000-0000-4000-8000-000000000031'
  $$,
  'lost with a controlled reason and required detail is valid'
);
select ok(
  not exists (
    select 1
    from public.audit_logs
    where entity_type = 'business_inquiry'
      and entity_id = '00000000-0000-4000-8000-000000000031'
      and (
        previous_value ? 'lost_reason_detail'
        or new_value ? 'lost_reason_detail'
        or previous_value::text like '%different explicit constraint%'
        or new_value::text like '%different explicit constraint%'
      )
  ),
  'free-form lost detail is excluded from audit JSON'
);
select lives_ok(
  $$
    update public.business_inquiries
    set status = 'archived'
    where id = '00000000-0000-4000-8000-000000000031'
  $$,
  'a lost inquiry can be archived'
);
select ok(
  (
    select lost_reason is null and lost_reason_detail is null
    from public.business_inquiries
    where id = '00000000-0000-4000-8000-000000000031'
  ),
  'leaving lost clears stale loss metadata'
);
select throws_ok(
  $$
    update public.business_inquiries
    set status = 'won'
    where id = '00000000-0000-4000-8000-000000000031'
  $$,
  '23514',
  null,
  'won cannot be stored without evidence type and date'
);
select throws_ok(
  $$
    update public.business_inquiries
    set status = 'won',
        won_evidence_type = 'paid_pilot',
        won_evidence_at = statement_timestamp() + interval '1 day'
    where id = '00000000-0000-4000-8000-000000000031'
  $$,
  '23514',
  'won_evidence_cannot_be_future',
  'future won evidence is rejected'
);
select lives_ok(
  $$
    update public.business_inquiries
    set status_changed_at = '2000-01-01T00:00:00Z',
        status = 'won',
        won_evidence_type = 'paid_pilot',
        won_evidence_at = statement_timestamp()
    where id = '00000000-0000-4000-8000-000000000031'
  $$,
  'won is valid only with a controlled evidence type and non-future date'
);
select is(
  (
    select status
    from public.business_inquiries
    where id = '00000000-0000-4000-8000-000000000031'
  ),
  'won',
  'the evidence-backed terminal stage is stored'
);
select ok(
  (
    select status_changed_at > '2000-01-01T00:00:00Z'::timestamptz
    from public.business_inquiries
    where id = '00000000-0000-4000-8000-000000000031'
  ),
  'stage changes receive a database-controlled timestamp'
);

reset role;
set local role authenticated;
select is(
  (
    select count(*)
    from public.business_inquiries
    where id = '00000000-0000-4000-8000-000000000031'
  ),
  0::bigint,
  'an authenticated session without an approved profile sees no inquiry rows'
);

reset role;
select * from finish();
rollback;
