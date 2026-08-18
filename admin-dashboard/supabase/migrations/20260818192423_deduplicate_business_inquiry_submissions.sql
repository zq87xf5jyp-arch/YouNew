-- Make exact browser retries idempotent for fifteen minutes. The transaction
-- lock uses an in-memory hash of normalized submission material; no additional
-- PII fingerprint is stored. A retry receives the original safe receipt.

create or replace function public.submit_business_inquiry(
  p_payload jsonb,
  p_rate_key text
)
returns table (id uuid, confirmation_code text, created_at timestamptz)
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_now timestamptz := statement_timestamp();
  v_count integer;
  v_window timestamptz := date_trunc('hour', statement_timestamp());
  v_id uuid := gen_random_uuid();
  v_code text := 'YNI-' || upper(substr(replace(v_id::text, '-', ''), 1, 12));
  v_company text := nullif(btrim(p_payload ->> 'companyName'), '');
  v_contact text := nullif(btrim(p_payload ->> 'contactPerson'), '');
  v_contact_role text := nullif(btrim(p_payload ->> 'contactRole'), '');
  v_offer_interest text := nullif(btrim(p_payload ->> 'offerInterest'), '');
  v_email text := lower(nullif(btrim(p_payload ->> 'email'), ''));
  v_phone text := nullif(btrim(p_payload ->> 'phone'), '');
  v_website text := nullif(btrim(p_payload ->> 'website'), '');
  v_inquiry_type text := nullif(btrim(p_payload ->> 'inquiryType'), '');
  v_organization_type text := nullif(btrim(p_payload ->> 'organizationType'), '');
  v_kvk text := nullif(btrim(p_payload ->> 'kvkNumber'), '');
  v_city text := nullif(btrim(p_payload ->> 'city'), '');
  v_province text := nullif(btrim(p_payload ->> 'province'), '');
  v_goal text := nullif(btrim(p_payload ->> 'campaignGoal'), '');
  v_budget text := nullif(btrim(p_payload ->> 'budgetRange'), '');
  v_message text := nullif(btrim(p_payload ->> 'description'), '');
  v_source_page text := nullif(btrim(p_payload ->> 'sourcePage'), '');
  v_utm_source text := nullif(btrim(p_payload ->> 'utmSource'), '');
  v_utm_medium text := nullif(btrim(p_payload ->> 'utmMedium'), '');
  v_utm_campaign text := nullif(btrim(p_payload ->> 'utmCampaign'), '');
  v_utm_content text := nullif(btrim(p_payload ->> 'utmContent'), '');
  v_utm_term text := nullif(btrim(p_payload ->> 'utmTerm'), '');
  v_campaign_start date;
  v_campaign_end date;
  v_audience text[];
  v_placements text[];
  v_existing_id uuid;
  v_existing_code text;
  v_existing_created_at timestamptz;
  v_existing_status text;
begin
  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception using errcode = '22023', message = 'invalid_payload';
  end if;
  if p_rate_key is null or p_rate_key !~ '^[a-f0-9]{64}$' then
    raise exception using errcode = '22023', message = 'invalid_rate_key';
  end if;

  delete from private.business_inquiry_rate_limits
  where window_started_at < v_now - interval '24 hours';

  insert into private.business_inquiry_rate_limits (
    key_hash, window_started_at, request_count, last_seen_at
  )
  values (p_rate_key, v_window, 1, v_now)
  on conflict (key_hash, window_started_at) do update
  set request_count = private.business_inquiry_rate_limits.request_count + 1,
      last_seen_at = v_now
  returning request_count into v_count;

  if v_count > 5 then
    raise exception using errcode = 'P0001', message = 'rate_limited';
  end if;

  if coalesce(p_payload ->> 'websiteConfirmation', '') <> '' then
    raise exception using errcode = '22023', message = 'bot_rejected';
  end if;
  if p_payload ->> 'consentToPrivacy' is distinct from 'true'
     or p_payload ->> 'confirmAccuracy' is distinct from 'true' then
    raise exception using errcode = '22023', message = 'consent_required';
  end if;
  if v_company is null or char_length(v_company) not between 2 and 120
     or v_contact is null or char_length(v_contact) not between 2 and 120
     or (v_contact_role is not null and char_length(v_contact_role) not between 2 and 120)
     or (v_offer_interest = 'onboarding_pilot' and v_contact_role is null)
     or v_offer_interest not in (
       'not_specified', 'onboarding_pilot', 'founding_partner_page',
       'sponsored_practical_guide', 'other'
     )
     or v_email is null or char_length(v_email) > 254
     or v_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
     or (v_phone is not null and char_length(v_phone) not between 6 and 40)
     or v_website is null or char_length(v_website) > 300
     or v_website !~ '^https?://'
     or v_inquiry_type not in ('advertising', 'partnership', 'media', 'public-interest', 'other')
     or v_organization_type not in (
       'commercial-business', 'sole-trader', 'advertising-agency', 'non-profit',
       'public-organization', 'education', 'healthcare', 'other'
     )
     or v_city is null or char_length(v_city) not between 2 and 100
     or v_province is null or char_length(v_province) not between 2 and 100
     or v_goal is null or char_length(v_goal) not between 10 and 240
     or v_budget not in ('under-1000', '1000-3000', '3000-10000', 'over-10000', 'request-discussion')
     or v_message is null or char_length(v_message) not between 30 and 600
     or v_source_page not in ('/business/apply/', '/partners/apply/')
     or (v_utm_source is not null and char_length(v_utm_source) > 120)
     or (v_utm_medium is not null and char_length(v_utm_medium) > 120)
     or (v_utm_campaign is not null and char_length(v_utm_campaign) > 160)
     or (v_utm_content is not null and char_length(v_utm_content) > 160)
     or (v_utm_term is not null and char_length(v_utm_term) > 160) then
    raise exception using errcode = '22023', message = 'validation_failed';
  end if;

  if v_organization_type in ('commercial-business', 'sole-trader', 'advertising-agency')
     and coalesce(v_kvk, '') !~ '^[0-9]{8}$' then
    raise exception using errcode = '22023', message = 'kvk_required';
  end if;
  if v_kvk is not null and v_kvk !~ '^[0-9]{8}$' then
    raise exception using errcode = '22023', message = 'validation_failed';
  end if;

  if jsonb_typeof(p_payload -> 'targetAudience') <> 'array'
     or jsonb_typeof(p_payload -> 'requestedPlacements') <> 'array' then
    raise exception using errcode = '22023', message = 'invalid_selections';
  end if;

  select array_agg(value order by value)
  into v_audience
  from jsonb_array_elements_text(p_payload -> 'targetAudience') as selected(value)
  where value in ('tourist', 'student', 'expat', 'refugee', 'worker', 'resident');

  select array_agg(value order by value)
  into v_placements
  from jsonb_array_elements_text(p_payload -> 'requestedPlacements') as selected(value)
  where value in (
    'featured-local-partner', 'sponsored-listing', 'sponsored-city-placement',
    'sponsored-category-placement', 'featured-offer', 'verified-organization-profile',
    'local-deal', 'campaign-banner', 'content-partnership', 'referral-affiliate'
  );

  if cardinality(v_audience) < 1
     or cardinality(v_audience) <> jsonb_array_length(p_payload -> 'targetAudience')
     or cardinality(v_placements) < 1
     or cardinality(v_placements) <> jsonb_array_length(p_payload -> 'requestedPlacements') then
    raise exception using errcode = '22023', message = 'invalid_selections';
  end if;

  if (nullif(p_payload ->> 'campaignStart', '') is null)
     <> (nullif(p_payload ->> 'campaignEnd', '') is null) then
    raise exception using errcode = '22023', message = 'validation_failed';
  end if;
  if nullif(p_payload ->> 'campaignStart', '') is not null then
    begin
      v_campaign_start := (p_payload ->> 'campaignStart')::date;
      v_campaign_end := (p_payload ->> 'campaignEnd')::date;
    exception when others then
      raise exception using errcode = '22023', message = 'validation_failed';
    end;
    if v_campaign_end < v_campaign_start then
      raise exception using errcode = '22023', message = 'validation_failed';
    end if;
  end if;

  -- Serialize identical submissions across networks without persisting the
  -- normalized material or its hash. A collision only over-serializes work.
  perform pg_advisory_xact_lock(hashtextextended(
    concat_ws(chr(31), lower(v_company), lower(v_contact), v_email, v_offer_interest, v_message, v_source_page),
    0
  ));

  select bi.id, bi.reference_code, bi.created_at, bi.status
  into v_existing_id, v_existing_code, v_existing_created_at, v_existing_status
  from public.business_inquiries as bi
  where bi.created_at >= v_now - interval '15 minutes'
    and bi.company_name = v_company
    and bi.contact_person = v_contact
    and bi.contact_role is not distinct from v_contact_role
    and bi.offer_interest = v_offer_interest
    and bi.email = v_email
    and bi.phone is not distinct from v_phone
    and bi.website = v_website
    and bi.inquiry_type = v_inquiry_type
    and bi.organization_type = v_organization_type
    and bi.kvk_number is not distinct from v_kvk
    and bi.city = v_city
    and bi.province = v_province
    and bi.target_audience = v_audience
    and bi.requested_placements = v_placements
    and bi.campaign_goal = v_goal
    and bi.budget_range = v_budget
    and bi.campaign_start is not distinct from v_campaign_start
    and bi.campaign_end is not distinct from v_campaign_end
    and bi.message = v_message
    and bi.source_page = v_source_page
    and bi.utm_source is not distinct from v_utm_source
    and bi.utm_medium is not distinct from v_utm_medium
    and bi.utm_campaign is not distinct from v_utm_campaign
    and bi.utm_content is not distinct from v_utm_content
    and bi.utm_term is not distinct from v_utm_term
  order by bi.created_at desc, bi.id
  limit 1;

  if found then
    insert into public.audit_logs (user_id, action, entity_type, entity_id, new_value)
    values (
      null,
      'business_inquiry_duplicate_suppressed',
      'business_inquiry',
      v_existing_id::text,
      jsonb_build_object('status', v_existing_status, 'source_page', v_source_page, 'window_minutes', 15)
    );

    return query
    select v_existing_id, v_existing_code, v_existing_created_at;
    return;
  end if;

  insert into public.business_inquiries (
    id, reference_code, contact_person, contact_role, offer_interest, company_name, email, phone, website,
    inquiry_type, organization_type, kvk_number, city, province, target_audience,
    requested_placements, campaign_goal, budget_range, campaign_start, campaign_end,
    message, consent_to_privacy, confirm_accuracy, consent_at, source_page,
    utm_source, utm_medium, utm_campaign, utm_content, utm_term
  )
  values (
    v_id, v_code, v_contact, v_contact_role, v_offer_interest, v_company, v_email, v_phone, v_website,
    v_inquiry_type, v_organization_type, v_kvk, v_city, v_province,
    v_audience, v_placements, v_goal, v_budget, v_campaign_start, v_campaign_end,
    v_message, true, true, v_now, v_source_page,
    v_utm_source, v_utm_medium, v_utm_campaign, v_utm_content, v_utm_term
  );

  insert into public.audit_logs (user_id, action, entity_type, entity_id, new_value)
  values (
    null,
    'business_inquiry_created',
    'business_inquiry',
    v_id::text,
    jsonb_build_object('status', 'new', 'source_page', v_source_page)
  );

  return query
  select bi.id, bi.reference_code, bi.created_at
  from public.business_inquiries as bi
  where bi.id = v_id;
end;
$$;

revoke all on function public.submit_business_inquiry(jsonb, text) from public, anon, authenticated;
grant execute on function public.submit_business_inquiry(jsonb, text) to service_role;
