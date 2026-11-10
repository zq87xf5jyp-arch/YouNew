begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(18);

select ok(
  (select relrowsecurity from pg_class where oid = 'public.business_inquiry_notifications'::regclass),
  'business inquiry notifications has RLS enabled'
);
select is(
  (
    select count(*)
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'business_inquiry_notifications'
  ),
  8::bigint,
  'notification storage has only the reviewed eight columns'
);
select is(
  (
    select count(*)
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'business_inquiry_notifications'
      and column_name in (
        'company_name', 'contact_person', 'email', 'phone', 'website', 'message',
        'source_page', 'utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term'
      )
  ),
  0::bigint,
  'notification storage has no submitted PII columns'
);
select ok(
  (
    select pg_get_constraintdef(oid)
    from pg_constraint
    where conrelid = 'public.business_inquiry_notifications'::regclass
      and conname = 'business_inquiry_notifications_status_check'
  ) like all (array['%unread%', '%read%', '%archived%']),
  'notification status is constrained to the reviewed inbox lifecycle'
);
select ok(
  not has_table_privilege('anon', 'public.business_inquiry_notifications', 'SELECT')
    and not has_table_privilege('anon', 'public.business_inquiry_notifications', 'INSERT')
    and not has_table_privilege('anon', 'public.business_inquiry_notifications', 'UPDATE')
    and not has_table_privilege('anon', 'public.business_inquiry_notifications', 'DELETE'),
  'anon has no notification table privileges'
);
select ok(
  has_table_privilege('authenticated', 'public.business_inquiry_notifications', 'SELECT')
    and has_column_privilege('authenticated', 'public.business_inquiry_notifications', 'status', 'UPDATE')
    and not has_column_privilege('authenticated', 'public.business_inquiry_notifications', 'reference_code', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.business_inquiry_notifications', 'INSERT')
    and not has_table_privilege('authenticated', 'public.business_inquiry_notifications', 'DELETE'),
  'authenticated Admin clients receive only select and status-update grants'
);
select ok(
  has_table_privilege('service_role', 'public.business_inquiry_notifications', 'SELECT')
    and has_table_privilege('service_role', 'public.business_inquiry_notifications', 'INSERT')
    and has_table_privilege('service_role', 'public.business_inquiry_notifications', 'UPDATE')
    and has_table_privilege('service_role', 'public.business_inquiry_notifications', 'DELETE'),
  'service_role can maintain the notification table server-side'
);
select ok(
  exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'business_inquiry_notifications'
      and cmd = 'SELECT'
      and roles @> array['authenticated']::name[]
      and qual like '%is_approved_admin%'
  ),
  'notification reads require an approved Admin profile'
);
select ok(
  exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'business_inquiry_notifications'
      and cmd = 'UPDATE'
      and roles @> array['authenticated']::name[]
      and qual like '%current_admin_role%'
      and with_check like '%current_admin_role%'
  ),
  'notification updates require owner or admin authorization'
);
select ok(
  exists (
    select 1
    from pg_trigger
    where tgrelid = 'public.business_inquiries'::regclass
      and tgname = 'create_business_inquiry_notification'
      and not tgisinternal
  ),
  'business inquiries have an after-insert notification trigger'
);
select ok(
  not has_function_privilege('anon', 'private.create_business_inquiry_notification()', 'EXECUTE')
    and not has_function_privilege('authenticated', 'private.create_business_inquiry_notification()', 'EXECUTE'),
  'clients cannot invoke the notification trigger function directly'
);

set local role service_role;

create temporary table notification_payload (payload jsonb not null) on commit drop;
insert into notification_payload values (
  '{
    "companyName":"Notification pgTAP BV",
    "contactPerson":"Test Owner",
    "contactRole":"People Operations Lead",
    "offerInterest":"onboarding_pilot",
    "email":"notification-pgtap@example.invalid",
    "phone":"+31 20 555 0102",
    "website":"https://example.invalid",
    "inquiryType":"partnership",
    "organizationType":"commercial-business",
    "kvkNumber":"12345678",
    "city":"Amsterdam",
    "province":"Noord-Holland",
    "targetAudience":["expat","worker"],
    "requestedPlacements":["content-partnership"],
    "campaignGoal":"Validate the privacy-safe internal Admin notification inbox.",
    "budgetRange":"request-discussion",
    "campaignStart":"",
    "campaignEnd":"",
    "description":"This valid fixture must create one minimal internal notification.",
    "consentToPrivacy":true,
    "confirmAccuracy":true,
    "websiteConfirmation":"",
    "sourcePage":"/partners/apply/",
    "utmSource":"pgtap",
    "utmMedium":"qa",
    "utmCampaign":"notification",
    "utmContent":"",
    "utmTerm":""
  }'::jsonb
);

create temporary table notification_receipts (
  label text primary key,
  id uuid not null,
  confirmation_code text not null,
  created_at timestamptz not null
) on commit drop;

select lives_ok(
  $$
    insert into notification_receipts
    select 'first', result.*
    from public.submit_business_inquiry(
      (select payload from notification_payload), repeat('1', 64)
    ) as result
  $$,
  'a valid new inquiry returns its safe receipt'
);
select lives_ok(
  $$
    insert into notification_receipts
    select 'retry', result.*
    from public.submit_business_inquiry(
      (select payload from notification_payload), repeat('2', 64)
    ) as result
  $$,
  'an exact valid retry returns safely'
);
select ok(
  (
    select first.id = retry.id
    from notification_receipts as first
    cross join notification_receipts as retry
    where first.label = 'first' and retry.label = 'retry'
  ),
  'the exact retry resolves to the original inquiry'
);
select is(
  (
    select count(*)
    from public.business_inquiry_notifications
    where inquiry_id = (select id from notification_receipts where label = 'first')
  ),
  1::bigint,
  'an exact retry creates no second notification'
);
select ok(
  (
    select notification.reference_code = receipt.confirmation_code
      and notification.notification_kind = 'business_inquiry_created'
      and notification.status = 'unread'
      and notification.read_at is null
      and notification.read_by is null
    from public.business_inquiry_notifications as notification
    join notification_receipts as receipt
      on receipt.id = notification.inquiry_id and receipt.label = 'first'
  ),
  'the unread notification contains only its safe receipt metadata'
);
select throws_ok(
  $$
    update public.business_inquiry_notifications
    set reference_code = 'YNI-IMMUTABLE00'
    where inquiry_id = (select id from notification_receipts where label = 'first')
  $$,
  '22023',
  'notification_identity_is_immutable',
  'notification identity cannot be rewritten even by a privileged maintenance role'
);

reset role;
set local role authenticated;
select is(
  (select count(*) from public.business_inquiry_notifications),
  0::bigint,
  'an authenticated session without an approved profile sees no notifications'
);
reset role;

select * from finish();
rollback;
