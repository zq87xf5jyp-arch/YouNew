-- Production operational layer for business inquiries, publication gates,
-- synchronization, service status and least-privilege function access.

create extension if not exists citext;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create or replace function private.is_approved_admin()
returns boolean
language sql
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and is_approved = true
      and role in ('owner', 'admin', 'editor', 'qa', 'viewer')
  );
$$;

create or replace function private.current_admin_role()
returns public.admin_role
language sql
security definer
set search_path = ''
as $$
  select role
  from public.profiles
  where id = auth.uid() and is_approved = true;
$$;

revoke all on function private.is_approved_admin() from public, anon;
revoke all on function private.current_admin_role() from public, anon;
grant execute on function private.is_approved_admin() to authenticated, service_role;
grant execute on function private.current_admin_role() to authenticated, service_role;

alter type public.publication_status add value if not exists 'research' after 'draft';
alter type public.publication_status add value if not exists 'qa' after 'review';
alter type public.publication_status add value if not exists 'needs_review' after 'published';

alter table public.articles
  add column if not exists verified_date date,
  add column if not exists reviewer_id uuid references public.profiles(id),
  add column if not exists reviewed_at timestamptz,
  add column if not exists requires_media boolean not null default false,
  add column if not exists source_mapping jsonb not null default '[]'::jsonb,
  add column if not exists publication_evidence jsonb not null default '{}'::jsonb,
  add column if not exists validation_passed boolean not null default false,
  add column if not exists validation_errors text[] not null default '{}'::text[];

alter table public.articles
  drop constraint if exists articles_source_mapping_array_check,
  add constraint articles_source_mapping_array_check
    check (jsonb_typeof(source_mapping) = 'array'),
  drop constraint if exists articles_publication_evidence_object_check,
  add constraint articles_publication_evidence_object_check
    check (jsonb_typeof(publication_evidence) = 'object'),
  drop constraint if exists articles_verified_date_not_future_check,
  add constraint articles_verified_date_not_future_check
    check (verified_date is null or verified_date <= current_date);

create or replace function public.enforce_article_publication_gate()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
declare
  missing_fields text[] := '{}'::text[];
begin
  if new.status <> 'published' then
    return new;
  end if;

  if current_user <> 'service_role'
     and coalesce(private.current_admin_role()::text, '') not in ('owner', 'admin') then
    raise exception using
      errcode = '42501',
      message = 'publication_role_required';
  end if;

  if nullif(btrim(new.title), '') is null then missing_fields := array_append(missing_fields, 'title'); end if;
  if nullif(btrim(new.short_description), '') is null then missing_fields := array_append(missing_fields, 'short_description'); end if;
  if nullif(btrim(new.full_content), '') is null then missing_fields := array_append(missing_fields, 'full_content'); end if;
  if new.category_id is null then missing_fields := array_append(missing_fields, 'public_category'); end if;
  if new.official_source is not true then missing_fields := array_append(missing_fields, 'official_source'); end if;
  if new.source_url is null or new.source_url !~ '^https://' then missing_fields := array_append(missing_fields, 'source_url'); end if;
  if new.verified_date is null then missing_fields := array_append(missing_fields, 'verified_date'); end if;
  if new.reviewer_id is null then missing_fields := array_append(missing_fields, 'reviewer'); end if;
  if new.reviewer_id is not null and not exists (
    select 1
    from public.profiles reviewer
    where reviewer.id = new.reviewer_id
      and reviewer.is_approved = true
      and reviewer.role in ('owner', 'admin', 'qa')
  ) then
    missing_fields := array_append(missing_fields, 'approved_reviewer');
  end if;
  if new.reviewed_at is null then missing_fields := array_append(missing_fields, 'reviewed_at'); end if;
  if new.validation_passed is not true then missing_fields := array_append(missing_fields, 'validation'); end if;
  if cardinality(new.validation_errors) > 0 then missing_fields := array_append(missing_fields, 'validation_errors'); end if;
  if jsonb_array_length(new.source_mapping) = 0 then missing_fields := array_append(missing_fields, 'source_mapping'); end if;
  if coalesce(new.publication_evidence ->> 'validation_status', '') <> 'passed' then
    missing_fields := array_append(missing_fields, 'publication_evidence');
  end if;
  if new.requires_media and jsonb_array_length(new.images) = 0 then
    missing_fields := array_append(missing_fields, 'required_media');
  end if;

  if cardinality(missing_fields) > 0 then
    raise exception using
      errcode = '23514',
      message = 'publication_gate_failed',
      detail = array_to_string(missing_fields, ',');
  end if;

  new.published_at := coalesce(new.published_at, now());
  return new;
end;
$$;

drop trigger if exists enforce_article_publication_gate on public.articles;
create trigger enforce_article_publication_gate
  before insert or update on public.articles
  for each row execute function public.enforce_article_publication_gate();

-- Existing rows are not assigned invented reviewers or verification evidence.
-- They return to review until a human completes the publication gate.
update public.articles
set status = 'review',
    published_at = null
where status = 'published'
  and (
    official_source is not true
    or source_url is null
    or source_url !~ '^https://'
    or verified_date is null
    or reviewer_id is null
    or reviewed_at is null
    or validation_passed is not true
    or cardinality(validation_errors) > 0
    or jsonb_array_length(source_mapping) = 0
    or coalesce(publication_evidence ->> 'validation_status', '') <> 'passed'
    or (requires_media and jsonb_array_length(images) = 0)
  );

create table if not exists public.business_inquiries (
  id uuid primary key default gen_random_uuid(),
  reference_code text not null unique default (
    'YN-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12))
  ),
  company_name text not null check (char_length(company_name) between 2 and 120),
  contact_person text not null check (char_length(contact_person) between 2 and 120),
  email text not null check (char_length(email) between 3 and 254),
  phone text check (phone is null or char_length(phone) between 6 and 40),
  website text not null check (char_length(website) <= 300 and website ~ '^https?://'),
  inquiry_type text not null check (inquiry_type in ('advertising', 'partnership', 'media', 'public-interest', 'other')),
  organization_type text not null check (organization_type in (
    'commercial-business', 'sole-trader', 'advertising-agency', 'non-profit',
    'public-organization', 'education', 'healthcare', 'other'
  )),
  kvk_number text check (kvk_number is null or kvk_number ~ '^[0-9]{8}$'),
  city text not null check (char_length(city) between 2 and 100),
  province text not null check (char_length(province) between 2 and 100),
  target_audience text[] not null check (cardinality(target_audience) between 1 and 6),
  requested_placements text[] not null check (cardinality(requested_placements) between 1 and 10),
  campaign_goal text not null check (char_length(campaign_goal) between 10 and 240),
  budget_range text not null check (budget_range in (
    'under-1000', '1000-3000', '3000-10000', 'over-10000', 'request-discussion'
  )),
  campaign_start date,
  campaign_end date,
  message text not null check (char_length(message) between 30 and 600),
  consent_to_privacy boolean not null check (consent_to_privacy),
  confirm_accuracy boolean not null check (confirm_accuracy),
  consent_at timestamptz not null,
  source_page text not null default '/business/apply/' check (source_page = '/business/apply/'),
  utm_source text check (utm_source is null or char_length(utm_source) <= 120),
  utm_medium text check (utm_medium is null or char_length(utm_medium) <= 120),
  utm_campaign text check (utm_campaign is null or char_length(utm_campaign) <= 160),
  utm_content text check (utm_content is null or char_length(utm_content) <= 160),
  utm_term text check (utm_term is null or char_length(utm_term) <= 160),
  status text not null default 'new' check (status in ('new', 'reviewing', 'responded', 'accepted', 'declined', 'test', 'archived')),
  admin_notes text check (admin_notes is null or char_length(admin_notes) <= 2000),
  handled_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint business_inquiries_campaign_dates_check check (
    (campaign_start is null and campaign_end is null)
    or (campaign_start is not null and campaign_end is not null and campaign_end >= campaign_start)
  )
);

-- Production can already contain the earlier business-inquiry contract.
-- Extend it in place instead of creating a competing table or duplicating PII.
alter table public.business_inquiries
  add column if not exists inquiry_type text,
  add column if not exists consent_at timestamptz,
  add column if not exists utm_source text,
  add column if not exists utm_medium text,
  add column if not exists utm_campaign text,
  add column if not exists utm_content text,
  add column if not exists utm_term text,
  add column if not exists handled_by uuid references public.profiles(id);

update public.business_inquiries
set inquiry_type = coalesce(inquiry_type, 'other'),
    consent_at = coalesce(consent_at, created_at)
where inquiry_type is null or consent_at is null;

alter table public.business_inquiries
  alter column inquiry_type set not null,
  alter column consent_at set not null;

alter table public.business_inquiries
  drop constraint if exists business_inquiries_inquiry_type_check,
  add constraint business_inquiries_inquiry_type_check check (
    inquiry_type in ('advertising', 'partnership', 'media', 'public-interest', 'other')
  ),
  drop constraint if exists business_inquiries_utm_source_check,
  add constraint business_inquiries_utm_source_check check (
    utm_source is null or char_length(utm_source) <= 120
  ),
  drop constraint if exists business_inquiries_utm_medium_check,
  add constraint business_inquiries_utm_medium_check check (
    utm_medium is null or char_length(utm_medium) <= 120
  ),
  drop constraint if exists business_inquiries_utm_campaign_check,
  add constraint business_inquiries_utm_campaign_check check (
    utm_campaign is null or char_length(utm_campaign) <= 160
  ),
  drop constraint if exists business_inquiries_utm_content_check,
  add constraint business_inquiries_utm_content_check check (
    utm_content is null or char_length(utm_content) <= 160
  ),
  drop constraint if exists business_inquiries_utm_term_check,
  add constraint business_inquiries_utm_term_check check (
    utm_term is null or char_length(utm_term) <= 160
  );

create index if not exists business_inquiries_status_created_at_idx
  on public.business_inquiries (status, created_at desc);
create index if not exists business_inquiries_email_created_at_idx
  on public.business_inquiries (email, created_at desc);

create table if not exists private.business_inquiry_rate_limits (
  key_hash text not null check (key_hash ~ '^[a-f0-9]{64}$'),
  window_started_at timestamptz not null,
  request_count integer not null default 1 check (request_count > 0),
  last_seen_at timestamptz not null default now(),
  primary key (key_hash, window_started_at)
);

alter table public.business_inquiries enable row level security;
alter table private.business_inquiry_rate_limits enable row level security;

revoke all on table public.business_inquiries from public, anon, authenticated;
revoke all on table private.business_inquiry_rate_limits from public, anon, authenticated;
grant select on table public.business_inquiries to authenticated;
grant update (status, admin_notes, handled_by) on table public.business_inquiries to authenticated;
grant all on table public.business_inquiries to service_role;
grant all on table private.business_inquiry_rate_limits to service_role;

drop policy if exists "approved admins read business inquiries" on public.business_inquiries;
create policy "approved admins read business inquiries"
on public.business_inquiries for select to authenticated
using (private.is_approved_admin());

drop policy if exists "owners and admins update business inquiries" on public.business_inquiries;
create policy "owners and admins update business inquiries"
on public.business_inquiries for update to authenticated
using (private.current_admin_role() in ('owner', 'admin'))
with check (private.current_admin_role() in ('owner', 'admin'));

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
  v_now timestamptz := now();
  v_count integer;
  v_window timestamptz := date_trunc('hour', now());
  v_id uuid := gen_random_uuid();
  v_code text := 'YNI-' || upper(substr(replace(v_id::text, '-', ''), 1, 12));
  v_company text := nullif(btrim(p_payload ->> 'companyName'), '');
  v_contact text := nullif(btrim(p_payload ->> 'contactPerson'), '');
  v_email text := lower(nullif(btrim(p_payload ->> 'email'), ''));
  v_website text := nullif(btrim(p_payload ->> 'website'), '');
  v_inquiry_type text := nullif(btrim(p_payload ->> 'inquiryType'), '');
  v_organization_type text := nullif(btrim(p_payload ->> 'organizationType'), '');
  v_city text := nullif(btrim(p_payload ->> 'city'), '');
  v_province text := nullif(btrim(p_payload ->> 'province'), '');
  v_goal text := nullif(btrim(p_payload ->> 'campaignGoal'), '');
  v_budget text := nullif(btrim(p_payload ->> 'budgetRange'), '');
  v_message text := nullif(btrim(p_payload ->> 'description'), '');
  v_source_page text := nullif(btrim(p_payload ->> 'sourcePage'), '');
  v_audience text[];
  v_placements text[];
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

  if p_payload ->> 'websiteConfirmation' <> '' then
    raise exception using errcode = '22023', message = 'bot_rejected';
  end if;
  if coalesce((p_payload ->> 'consentToPrivacy')::boolean, false) is not true
     or coalesce((p_payload ->> 'confirmAccuracy')::boolean, false) is not true then
    raise exception using errcode = '22023', message = 'consent_required';
  end if;
  if v_company is null or char_length(v_company) not between 2 and 120
     or v_contact is null or char_length(v_contact) not between 2 and 120
     or v_email is null or v_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
     or v_website is null or v_website !~ '^https?://'
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
     or v_source_page <> '/business/apply/' then
    raise exception using errcode = '22023', message = 'validation_failed';
  end if;

  if v_organization_type in ('commercial-business', 'sole-trader', 'advertising-agency')
     and coalesce(p_payload ->> 'kvkNumber', '') !~ '^[0-9]{8}$' then
    raise exception using errcode = '22023', message = 'kvk_required';
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

  insert into public.business_inquiries (
    id, reference_code, contact_person, company_name, email, phone, website,
    inquiry_type, organization_type, kvk_number, city, province, target_audience,
    requested_placements, campaign_goal, budget_range, campaign_start, campaign_end,
    message, consent_to_privacy, confirm_accuracy, consent_at, source_page,
    utm_source, utm_medium, utm_campaign, utm_content, utm_term
  )
  values (
    v_id, v_code, v_contact, v_company, v_email,
    nullif(btrim(p_payload ->> 'phone'), ''), v_website, v_inquiry_type,
    v_organization_type, nullif(btrim(p_payload ->> 'kvkNumber'), ''),
    v_city, v_province, v_audience, v_placements, v_goal, v_budget,
    nullif(p_payload ->> 'campaignStart', '')::date,
    nullif(p_payload ->> 'campaignEnd', '')::date,
    v_message, true, true, v_now, v_source_page,
    nullif(btrim(p_payload ->> 'utmSource'), ''),
    nullif(btrim(p_payload ->> 'utmMedium'), ''),
    nullif(btrim(p_payload ->> 'utmCampaign'), ''),
    nullif(btrim(p_payload ->> 'utmContent'), ''),
    nullif(btrim(p_payload ->> 'utmTerm'), '')
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
  select v_id, v_code, v_now;
end;
$$;

revoke all on function public.submit_business_inquiry(jsonb, text) from public, anon, authenticated;
grant execute on function public.submit_business_inquiry(jsonb, text) to service_role;

create or replace function public.audit_business_inquiry_change()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $$
begin
  if old.status is distinct from new.status
     or old.admin_notes is distinct from new.admin_notes
     or old.handled_by is distinct from new.handled_by then
    insert into public.audit_logs (user_id, action, entity_type, entity_id, previous_value, new_value)
    values (
      auth.uid(),
      'business_inquiry_updated',
      'business_inquiry',
      new.id::text,
      jsonb_build_object('status', old.status, 'had_admin_notes', old.admin_notes is not null),
      jsonb_build_object('status', new.status, 'has_admin_notes', new.admin_notes is not null)
    );
  end if;
  return new;
end;
$$;

drop trigger if exists audit_business_inquiry_status_change on public.business_inquiries;
drop trigger if exists audit_business_inquiry_change on public.business_inquiries;
create trigger audit_business_inquiry_change
  after update on public.business_inquiries
  for each row execute function public.audit_business_inquiry_change();

drop trigger if exists set_business_inquiry_updated_at on public.business_inquiries;
drop trigger if exists set_updated_at on public.business_inquiries;
create trigger set_updated_at
  before update on public.business_inquiries
  for each row execute function public.set_updated_at();

alter table public.feedback
  add column if not exists confirmation_code text,
  add column if not exists page_reference text,
  add column if not exists feedback_type text,
  add column if not exists consent_at timestamptz,
  add column if not exists resolution_note text,
  add column if not exists resolved_by uuid references public.profiles(id),
  add column if not exists updated_at timestamptz not null default now();

alter table public.feedback
  drop constraint if exists feedback_type_check,
  add constraint feedback_type_check check (
    feedback_type is null or feedback_type in (
      'incorrect-information', 'product-problem', 'accessibility', 'privacy', 'suggestion', 'other'
    )
  ),
  drop constraint if exists feedback_page_reference_check,
  add constraint feedback_page_reference_check check (
    page_reference is null or (page_reference ~ '^/' and char_length(page_reference) <= 300)
  );

revoke all on table public.feedback from public, anon, authenticated;
grant select, update on table public.feedback to authenticated;
grant all on table public.feedback to service_role;

create unique index if not exists feedback_confirmation_code_idx
  on public.feedback (confirmation_code)
  where confirmation_code is not null;

create table public.feedback_rate_limits (
  rate_key text primary key check (rate_key ~ '^[a-f0-9]{64}$'),
  window_started_at timestamptz not null default now(),
  request_count integer not null default 1 check (request_count > 0),
  updated_at timestamptz not null default now()
);

alter table public.feedback_rate_limits enable row level security;
revoke all on table public.feedback_rate_limits from public, anon, authenticated;
grant all on table public.feedback_rate_limits to service_role;

create or replace function public.submit_public_feedback(
  p_payload jsonb,
  p_rate_key text
)
returns table (id uuid, confirmation_code text, created_at timestamptz)
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_now timestamptz := now();
  v_count integer;
  v_id uuid := gen_random_uuid();
  v_code text := 'YNF-' || upper(substr(replace(v_id::text, '-', ''), 1, 12));
  v_email text := lower(nullif(btrim(p_payload ->> 'email'), ''));
  v_message text := nullif(btrim(p_payload ->> 'message'), '');
  v_page text := nullif(btrim(p_payload ->> 'pageReference'), '');
  v_type text := nullif(btrim(p_payload ->> 'feedbackType'), '');
begin
  if p_payload is null or jsonb_typeof(p_payload) <> 'object'
     or p_rate_key is null or p_rate_key !~ '^[a-f0-9]{64}$' then
    raise exception using errcode = '22023', message = 'invalid_request';
  end if;

  delete from public.feedback_rate_limits
  where updated_at < v_now - interval '2 days';

  insert into public.feedback_rate_limits (rate_key, window_started_at, request_count, updated_at)
  values (p_rate_key, v_now, 1, v_now)
  on conflict (rate_key) do update
  set window_started_at = case
        when public.feedback_rate_limits.window_started_at <= v_now - interval '15 minutes' then v_now
        else public.feedback_rate_limits.window_started_at
      end,
      request_count = case
        when public.feedback_rate_limits.window_started_at <= v_now - interval '15 minutes' then 1
        else public.feedback_rate_limits.request_count + 1
      end,
      updated_at = v_now
  returning request_count into v_count;

  if v_count > 5 then
    raise exception using errcode = 'P0001', message = 'rate_limited';
  end if;

  if coalesce(p_payload ->> 'websiteConfirmation', '') <> ''
     or coalesce((p_payload ->> 'consentToPrivacy')::boolean, false) is not true then
    raise exception using errcode = '22023', message = 'invalid_submission';
  end if;

  if (v_email is not null and (char_length(v_email) > 254 or v_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'))
     or v_message is null or char_length(v_message) not between 20 and 2000
     or v_page is null or v_page !~ '^/' or char_length(v_page) > 300
     or v_type not in (
       'incorrect-information', 'product-problem', 'accessibility', 'privacy', 'suggestion', 'other'
     ) then
    raise exception using errcode = '22023', message = 'validation_failed';
  end if;

  insert into public.feedback (
    id, confirmation_code, user_email, message, app_screen, platform, status,
    page_reference, feedback_type, consent_at
  )
  values (
    v_id, v_code, v_email, v_message, v_page, 'Web', 'new',
    v_page, v_type, v_now
  );

  insert into public.audit_logs (user_id, action, entity_type, entity_id, new_value)
  values (
    null,
    'public_feedback_created',
    'feedback',
    v_id::text,
    jsonb_build_object('status', 'new', 'feedback_type', v_type, 'page_reference', v_page)
  );

  return query select v_id, v_code, v_now;
end;
$$;

revoke all on function public.submit_public_feedback(jsonb, text) from public, anon, authenticated;
grant execute on function public.submit_public_feedback(jsonb, text) to service_role;

drop trigger if exists set_updated_at on public.feedback;
create trigger set_updated_at
  before update on public.feedback
  for each row execute function public.set_updated_at();

create table public.service_registry (
  id text primary key check (id ~ '^[a-z0-9_-]+$'),
  display_name text not null,
  owner text not null,
  purpose text not null,
  is_public boolean not null default false,
  public_name text,
  health_check_type text not null check (health_check_type in ('http', 'database', 'manual', 'integration')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.service_status (
  id uuid primary key default gen_random_uuid(),
  service_id text not null references public.service_registry(id) on delete cascade,
  status text not null check (status in ('operational', 'degraded', 'outage', 'unknown')),
  checked_at timestamptz not null,
  source text not null,
  public_message text,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index service_status_service_checked_idx
  on public.service_status (service_id, checked_at desc);

create table public.deployment_status (
  id uuid primary key default gen_random_uuid(),
  service_id text not null references public.service_registry(id),
  environment text not null check (environment in ('preview', 'staging', 'production')),
  status text not null check (status in ('queued', 'running', 'succeeded', 'failed', 'rolled_back')),
  commit_sha text,
  artifact_fingerprint text,
  error_summary text,
  deployed_at timestamptz,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

alter table public.service_registry enable row level security;
alter table public.service_status enable row level security;
alter table public.deployment_status enable row level security;

revoke all on table public.service_registry, public.service_status, public.deployment_status
  from public, anon, authenticated;
grant select, insert, update on table public.service_registry, public.service_status, public.deployment_status
  to authenticated;
grant all on table public.service_registry, public.service_status, public.deployment_status
  to service_role;

create policy "approved admins read service registry"
on public.service_registry for select to authenticated using (private.is_approved_admin());
create policy "owners and admins manage service registry"
on public.service_registry for all to authenticated
using (private.current_admin_role() in ('owner', 'admin'))
with check (private.current_admin_role() in ('owner', 'admin'));

create policy "approved admins read service status"
on public.service_status for select to authenticated using (private.is_approved_admin());
create policy "owners and admins manage service status"
on public.service_status for all to authenticated
using (private.current_admin_role() in ('owner', 'admin'))
with check (private.current_admin_role() in ('owner', 'admin'));

create policy "approved admins read deployment status"
on public.deployment_status for select to authenticated using (private.is_approved_admin());
create policy "owners and admins manage deployment status"
on public.deployment_status for all to authenticated
using (private.current_admin_role() in ('owner', 'admin'))
with check (private.current_admin_role() in ('owner', 'admin'));

drop trigger if exists set_updated_at on public.service_registry;
create trigger set_updated_at
  before update on public.service_registry
  for each row execute function public.set_updated_at();

alter table public.sync_jobs
  add column if not exists type text,
  add column if not exists started_at timestamptz,
  add column if not exists completed_at timestamptz,
  add column if not exists initiator uuid references public.profiles(id),
  add column if not exists source_version text,
  add column if not exists target_version text,
  add column if not exists records_processed integer not null default 0,
  add column if not exists records_failed integer not null default 0,
  add column if not exists error_summary text,
  add column if not exists artifact_fingerprint text,
  add column if not exists idempotency_key text;

alter table public.sync_jobs drop constraint if exists sync_jobs_status_check;
update public.sync_jobs
set status = case status
  when 'success' then 'succeeded'
  when 'warning' then 'failed'
  else status
end,
type = coalesce(type, job),
started_at = coalesce(started_at, created_at),
completed_at = coalesce(
  completed_at,
  case when status in ('success', 'warning', 'failed') then created_at else null end
),
initiator = coalesce(initiator, created_by),
error_summary = coalesce(
  error_summary,
  case when status = 'warning' then 'Legacy warning requires manual review.' else null end
),
idempotency_key = coalesce(idempotency_key, 'legacy:' || id::text);

alter table public.sync_jobs
  alter column status set default 'queued',
  alter column type set not null,
  alter column started_at set default now(),
  alter column started_at set not null,
  alter column idempotency_key set not null,
  add constraint sync_jobs_status_check
    check (status in ('queued', 'running', 'succeeded', 'failed', 'cancelled')),
  add constraint sync_jobs_record_counts_check
    check (records_processed >= 0 and records_failed >= 0),
  add constraint sync_jobs_idempotency_key_unique unique (idempotency_key);

create table public.published_content_artifacts (
  id uuid primary key default gen_random_uuid(),
  source_version text not null,
  artifact jsonb not null,
  artifact_fingerprint text not null unique check (artifact_fingerprint ~ '^[a-f0-9]{64}$'),
  record_count integer not null check (record_count >= 0),
  status text not null default 'candidate' check (status in ('candidate', 'active', 'superseded', 'rejected')),
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  activated_at timestamptz
);

create unique index one_active_published_content_artifact_idx
  on public.published_content_artifacts ((status))
  where status = 'active';

alter table public.published_content_artifacts enable row level security;
revoke all on table public.published_content_artifacts from public, anon, authenticated;
grant select, insert, update on table public.published_content_artifacts to authenticated;
grant all on table public.published_content_artifacts to service_role;

create policy "approved admins read content artifacts"
on public.published_content_artifacts for select to authenticated
using (private.is_approved_admin());
create policy "owners and admins manage content artifacts"
on public.published_content_artifacts for all to authenticated
using (private.current_admin_role() in ('owner', 'admin'))
with check (private.current_admin_role() in ('owner', 'admin'));

create or replace function public.request_content_sync()
returns uuid
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_job_id uuid := gen_random_uuid();
begin
  if coalesce(private.current_admin_role()::text, '') not in ('owner', 'admin') then
    raise exception using errcode = '42501', message = 'sync_role_required';
  end if;

  insert into public.sync_jobs (
    id, job, type, target, status, started_at, initiator,
    source_version, idempotency_key, details
  )
  values (
    v_job_id,
    'content_artifact_candidate',
    'content_artifact_candidate',
    'github-canonical-handoff',
    'queued',
    now(),
    auth.uid(),
    'supabase-operational',
    'content-sync:' || v_job_id::text,
    jsonb_build_object(
      'activation', 'manual',
      'production_replacement_allowed', false
    )
  );

  return v_job_id;
end;
$$;

revoke all on function public.request_content_sync() from public, anon;
grant execute on function public.request_content_sync() to authenticated, service_role;

create or replace function public.enqueue_article_publication()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_fingerprint text;
  v_key text;
begin
  if new.status = 'published' and (tg_op = 'INSERT' or old.status is distinct from new.status or old.updated_at is distinct from new.updated_at) then
    v_fingerprint := encode(extensions.digest(convert_to(to_jsonb(new)::text, 'UTF8'), 'sha256'), 'hex');
    v_key := 'article:' || new.id::text || ':' || v_fingerprint;

    insert into public.sync_jobs (
      job, type, target, status, started_at, initiator, source_version,
      target_version, artifact_fingerprint, idempotency_key, details
    )
    values (
      'content_publication',
      'content_publication',
      'canonical-content',
      'queued',
      now(),
      auth.uid(),
      coalesce(old.updated_at::text, 'new'),
      new.updated_at::text,
      v_fingerprint,
      v_key,
      jsonb_build_object('article_id', new.id, 'article_slug', new.slug)
    )
    on conflict (idempotency_key) do nothing;
  end if;
  return new;
end;
$$;

drop trigger if exists enqueue_article_publication on public.articles;
create trigger enqueue_article_publication
  after insert or update on public.articles
  for each row execute function public.enqueue_article_publication();

-- Security-definer and trigger functions must not remain callable through the
-- Data API unless a role explicitly needs them.
alter function public.set_updated_at() set search_path = '';

revoke all on function public.set_updated_at() from public, anon, authenticated;
revoke all on function public.audit_business_inquiry_change() from public, anon, authenticated;
revoke all on function public.enforce_article_publication_gate() from public, anon, authenticated;
revoke all on function public.enqueue_article_publication() from public, anon, authenticated;
revoke all on function public.request_content_sync() from public, anon;

grant execute on function public.request_content_sync() to authenticated, service_role;

-- Older environments used public authorization helpers; current production
-- already moved them to private. Harden the legacy helpers only when present.
do $$
begin
  if to_regprocedure('public.current_admin_role()') is not null then
    execute 'alter function public.current_admin_role() set search_path = ''''';
    execute 'revoke all on function public.current_admin_role() from public, anon';
    execute 'grant execute on function public.current_admin_role() to authenticated, service_role';
  end if;
  if to_regprocedure('public.is_approved_admin()') is not null then
    execute 'alter function public.is_approved_admin() set search_path = ''''';
    execute 'revoke all on function public.is_approved_admin() from public, anon';
    execute 'grant execute on function public.is_approved_admin() to authenticated, service_role';
  end if;
  if to_regprocedure('public.handle_new_admin_user()') is not null then
    execute 'alter function public.handle_new_admin_user() set search_path = ''''';
    execute 'revoke all on function public.handle_new_admin_user() from public, anon, authenticated';
  end if;
  if to_regprocedure('public.write_audit_log()') is not null then
    execute 'alter function public.write_audit_log() set search_path = ''''';
    execute 'revoke all on function public.write_audit_log() from public, anon, authenticated';
  end if;
end
$$;

alter default privileges for role postgres in schema public
  revoke execute on functions from public;
alter default privileges for role postgres in schema public
  revoke execute on functions from anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  revoke select, insert, update, delete on tables from anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  revoke usage, select on sequences from anon, authenticated, service_role;
