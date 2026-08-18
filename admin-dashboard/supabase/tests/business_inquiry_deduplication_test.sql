begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(13);

select ok(
  has_function_privilege('service_role', 'public.submit_business_inquiry(jsonb,text)', 'EXECUTE')
    and not has_function_privilege('anon', 'public.submit_business_inquiry(jsonb,text)', 'EXECUTE')
    and not has_function_privilege('authenticated', 'public.submit_business_inquiry(jsonb,text)', 'EXECUTE'),
  'only service_role can execute the inquiry RPC'
);

set local role service_role;

create temporary table dedupe_payload (payload jsonb not null) on commit drop;
insert into dedupe_payload values (
  '{
    "companyName":"Dedupe pgTAP BV",
    "contactPerson":"Test Owner",
    "contactRole":"Global Mobility Lead",
    "offerInterest":"onboarding_pilot",
    "email":"dedupe-pgtap@example.invalid",
    "phone":"+31 20 555 0101",
    "website":"https://example.invalid",
    "inquiryType":"partnership",
    "organizationType":"commercial-business",
    "kvkNumber":"12345678",
    "city":"Amsterdam",
    "province":"Noord-Holland",
    "targetAudience":["expat","worker"],
    "requestedPlacements":["content-partnership"],
    "campaignGoal":"Validate retry idempotency without storing a PII hash.",
    "budgetRange":"request-discussion",
    "campaignStart":"",
    "campaignEnd":"",
    "description":"This exact valid submission should receive one stable safe receipt.",
    "consentToPrivacy":true,
    "confirmAccuracy":true,
    "websiteConfirmation":"",
    "sourcePage":"/partners/apply/",
    "utmSource":"pgtap",
    "utmMedium":"qa",
    "utmCampaign":"dedupe",
    "utmContent":"",
    "utmTerm":""
  }'::jsonb
);

create temporary table dedupe_receipts (
  label text primary key,
  id uuid not null,
  confirmation_code text not null,
  created_at timestamptz not null
) on commit drop;

select lives_ok(
  $$
    insert into dedupe_receipts
    select 'first', result.*
    from public.submit_business_inquiry(
      (select payload from dedupe_payload), repeat('a', 64)
    ) as result
  $$,
  'the first valid submission returns a receipt'
);
select lives_ok(
  $$
    insert into dedupe_receipts
    select 'retry', result.*
    from public.submit_business_inquiry(
      (select payload from dedupe_payload), repeat('b', 64)
    ) as result
  $$,
  'an exact retry is accepted across a different network rate key'
);
select ok(
  (
    select first.id = retry.id
      and first.confirmation_code = retry.confirmation_code
      and first.created_at = retry.created_at
    from dedupe_receipts as first
    cross join dedupe_receipts as retry
    where first.label = 'first' and retry.label = 'retry'
  ),
  'an exact retry returns the original receipt'
);
select is(
  (
    select count(*)
    from public.business_inquiries
    where email = 'dedupe-pgtap@example.invalid'
      and contact_role = 'Global Mobility Lead'
      and offer_interest = 'onboarding_pilot'
  ),
  1::bigint,
  'an exact retry creates one correctly classified pilot inquiry row'
);
reset role;
select ok(
  (
    select count(*) filter (where action = 'business_inquiry_created') = 1
      and count(*) filter (where action = 'business_inquiry_duplicate_suppressed') = 1
    from public.audit_logs
    where entity_type = 'business_inquiry'
      and entity_id = (select id::text from dedupe_receipts where label = 'first')
  )
  and not exists (
      select 1
      from public.audit_logs
      where action = 'business_inquiry_duplicate_suppressed'
        and entity_id = (select id::text from dedupe_receipts where label = 'first')
        and (
          new_value ?| array['email', 'company', 'contact', 'message', 'payload']
          or new_value::text like '%dedupe-pgtap@example.invalid%'
        )
    ),
  'the duplicate audit is separate from creation and contains no submitted PII'
);
set local role service_role;
select lives_ok(
  $$
    insert into dedupe_receipts
    select 'changed', result.*
    from public.submit_business_inquiry(
      jsonb_set(
        (select payload from dedupe_payload),
        '{description}',
        '"This materially different request must create its own safe receipt."'::jsonb
      ),
      repeat('c', 64)
    ) as result
  $$,
  'a material payload change creates a new inquiry'
);
select ok(
  (
    select first.id <> changed.id
    from dedupe_receipts as first
    cross join dedupe_receipts as changed
    where first.label = 'first' and changed.label = 'changed'
  ),
  'the materially changed submission receives a different receipt'
);

update public.business_inquiries
set created_at = statement_timestamp() - interval '16 minutes'
where id = (select id from dedupe_receipts where label = 'first');

select lives_ok(
  $$
    insert into dedupe_receipts
    select 'expired', result.*
    from public.submit_business_inquiry(
      (select payload from dedupe_payload), repeat('d', 64)
    ) as result
  $$,
  'an expired dedupe window creates a new receipt'
);
select ok(
  (
    select first.id <> expired.id
    from dedupe_receipts as first
    cross join dedupe_receipts as expired
    where first.label = 'first' and expired.label = 'expired'
  ),
  'the expired retry is not attached to the old inquiry'
);
select throws_ok(
  $$
    select *
    from public.submit_business_inquiry(
      (select payload from dedupe_payload) || '{"consentToPrivacy":false}'::jsonb,
      repeat('e', 64)
    )
  $$,
  '22023',
  'consent_required',
  'invalid consent cannot recover an existing receipt'
);
select throws_ok(
  $$
    do $rate_limit$
    declare
      v_attempt integer;
      v_payload jsonb := (select payload from dedupe_payload)
        || '{"email":"dedupe-rate-limit@example.invalid"}'::jsonb;
    begin
      for v_attempt in 1..6 loop
        perform *
        from public.submit_business_inquiry(v_payload, repeat('f', 64));
      end loop;
    end
    $rate_limit$
  $$,
  'P0001',
  'rate_limited',
  'duplicate retries still consume the rate limit'
);
select ok(
  not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'business_inquiries'
      and column_name in ('fingerprint', 'dedupe_hash', 'email_hash')
  ),
  'dedupe adds no stored PII fingerprint column'
);

reset role;
select * from finish();
rollback;
