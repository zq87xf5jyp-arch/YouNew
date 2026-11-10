begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(7);

select ok(
  (select pg_get_constraintdef(oid)
   from pg_constraint
   where conrelid = 'public.business_inquiries'::regclass
     and conname = 'business_inquiries_source_page_check')
    like all (array['%/for-business/local/apply/%', '%/nl/voor-bedrijven/aanmelden/%']),
  'the storage constraint accepts both reviewed local-business routes'
);

select ok(
  pg_get_functiondef('public.submit_business_inquiry(jsonb,text)'::regprocedure)
    like all (array['%/for-business/local/apply/%', '%/nl/voor-bedrijven/aanmelden/%']),
  'the submission RPC accepts the same reviewed local-business routes'
);

set local role service_role;

create temporary table local_route_payload (payload jsonb not null) on commit drop;
insert into local_route_payload values (
  '{
    "companyName":"Local Route pgTAP BV",
    "contactPerson":"Synthetic Reviewer",
    "contactRole":"",
    "offerInterest":"founding_partner_page",
    "email":"local-route-pgtap@example.invalid",
    "phone":"",
    "website":"https://example.invalid",
    "inquiryType":"partnership",
    "organizationType":"commercial-business",
    "kvkNumber":"12345678",
    "city":"Amsterdam",
    "province":"Noord-Holland",
    "targetAudience":["expat","resident"],
    "requestedPlacements":["verified-organization-profile"],
    "campaignGoal":"Request to add a new business profile.",
    "budgetRange":"request-discussion",
    "campaignStart":"",
    "campaignEnd":"",
    "description":"Synthetic local-route persistence test and not a real application.",
    "consentToPrivacy":true,
    "confirmAccuracy":true,
    "websiteConfirmation":"",
    "sourcePage":"/for-business/local/apply/",
    "utmSource":"pgtap",
    "utmMedium":"qa",
    "utmCampaign":"local-routes",
    "utmContent":"",
    "utmTerm":""
  }'::jsonb
);

create temporary table local_route_receipts (
  route text primary key,
  id uuid not null,
  confirmation_code text not null,
  created_at timestamptz not null
) on commit drop;

select lives_ok(
  $$
    insert into local_route_receipts
    select '/for-business/local/apply/', result.*
    from public.submit_business_inquiry(
      (select payload from local_route_payload), repeat('7', 64)
    ) as result
  $$,
  'the reviewed English local-business application persists'
);

select lives_ok(
  $$
    insert into local_route_receipts
    select '/nl/voor-bedrijven/aanmelden/', result.*
    from public.submit_business_inquiry(
      jsonb_set(
        jsonb_set(
          jsonb_set((select payload from local_route_payload), '{sourcePage}', '"/nl/voor-bedrijven/aanmelden/"'),
          '{offerInterest}', '"other"'
        ),
        '{campaignGoal}', '"Request to add a new business profile. Non-binding future Business/Premium interest: profile-insights."'
      ),
      repeat('8', 64)
    ) as result
  $$,
  'the reviewed Dutch local-business interest application persists'
);

select is(
  (select count(*) from public.business_inquiries where email = 'local-route-pgtap@example.invalid'),
  2::bigint,
  'both distinct local-business submissions are stored'
);

select is(
  (select count(*) from public.business_inquiry_notifications
   where inquiry_id in (select id from local_route_receipts)),
  2::bigint,
  'each stored local-business inquiry creates one privacy-safe notification'
);

select throws_ok(
  $$
    select * from public.submit_business_inquiry(
      jsonb_set((select payload from local_route_payload), '{sourcePage}', '"/unreviewed-route/"'),
      repeat('9', 64)
    )
  $$,
  '22023',
  'validation_failed',
  'an unreviewed source route remains rejected'
);

reset role;
select * from finish();
rollback;
