\set ON_ERROR_STOP on

set search_path = public, private;
set role service_role;

create temporary table phase3_receipt as
select result.*
from public.submit_business_inquiry(
  '{
    "companyName":"Phase 3 Synthetic Business BV",
    "contactPerson":"Synthetic Reviewer",
    "contactRole":"",
    "offerInterest":"other",
    "email":"phase3-roundtrip@example.invalid",
    "phone":"",
    "website":"https://example.invalid",
    "inquiryType":"partnership",
    "organizationType":"commercial-business",
    "kvkNumber":"12345678",
    "city":"Amsterdam",
    "province":"Noord-Holland",
    "targetAudience":["expat","resident"],
    "requestedPlacements":["verified-organization-profile"],
    "campaignGoal":"Request to add a new business profile. Non-binding future Business/Premium interest: profile-insights.",
    "budgetRange":"request-discussion",
    "campaignStart":"",
    "campaignEnd":"",
    "description":"Synthetic Phase 3 round-trip test; this is not a real company application.",
    "consentToPrivacy":true,
    "confirmAccuracy":true,
    "websiteConfirmation":"",
    "sourcePage":"/nl/voor-bedrijven/aanmelden/",
    "utmSource":"phase3-local-staging",
    "utmMedium":"qa",
    "utmCampaign":"business-interest-roundtrip",
    "utmContent":"",
    "utmTerm":""
  }'::jsonb,
  repeat('3', 64)
) as result;

do $verify$
begin
  if (select count(*) from phase3_receipt) <> 1 then
    raise exception 'receipt_not_returned';
  end if;
  if not exists (
    select 1
    from public.business_inquiries as inquiry
    join phase3_receipt as receipt on receipt.id = inquiry.id
    where inquiry.email = 'phase3-roundtrip@example.invalid'
      and inquiry.offer_interest = 'other'
      and inquiry.source_page = '/nl/voor-bedrijven/aanmelden/'
      and inquiry.consent_to_privacy
      and inquiry.confirm_accuracy
      and inquiry.reference_code = receipt.confirmation_code
  ) then
    raise exception 'stored_inquiry_readback_failed';
  end if;
  if not exists (
    select 1
    from public.business_inquiry_notifications as notification
    join phase3_receipt as receipt on receipt.id = notification.inquiry_id
    where notification.reference_code = receipt.confirmation_code
      and notification.status = 'unread'
  ) then
    raise exception 'privacy_safe_notification_missing';
  end if;
end
$verify$;

select
  'PASS' as result,
  confirmation_code,
  created_at,
  (select count(*) from public.business_inquiries where email = 'phase3-roundtrip@example.invalid') as stored_rows,
  (select count(*) from public.business_inquiry_notifications as notification join phase3_receipt as receipt on receipt.id = notification.inquiry_id) as notification_rows
from phase3_receipt;

reset role;
