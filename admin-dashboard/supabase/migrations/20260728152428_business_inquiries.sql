create table public.business_inquiries (
  id uuid primary key default gen_random_uuid(),
  reference_code text not null default (
    'YN-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12))
  ),
  company_name text not null check (char_length(company_name) between 2 and 120),
  contact_person text not null check (char_length(contact_person) between 2 and 120),
  email text not null check (char_length(email) between 3 and 254),
  phone text check (phone is null or char_length(phone) between 6 and 40),
  website text not null check (
    char_length(website) <= 300
    and website ~* '^https?://'
  ),
  organization_type text not null check (
    organization_type = any (
      array[
        'commercial-business',
        'sole-trader',
        'advertising-agency',
        'non-profit',
        'public-organization',
        'education',
        'healthcare',
        'other'
      ]
    )
  ),
  kvk_number text check (kvk_number is null or kvk_number ~ '^[0-9]{8}$'),
  city text not null check (char_length(city) between 2 and 100),
  province text not null check (char_length(province) between 2 and 100),
  target_audience text[] not null check (
    cardinality(target_audience) between 1 and 6
    and target_audience <@ array['tourist', 'student', 'expat', 'refugee', 'worker', 'resident']::text[]
  ),
  requested_placements text[] not null check (
    cardinality(requested_placements) between 1 and 10
    and requested_placements <@ array[
      'featured-local-partner',
      'sponsored-listing',
      'sponsored-city-placement',
      'sponsored-category-placement',
      'featured-offer',
      'verified-organization-profile',
      'local-deal',
      'campaign-banner',
      'content-partnership',
      'referral-affiliate'
    ]::text[]
  ),
  campaign_goal text not null check (char_length(campaign_goal) between 10 and 240),
  budget_range text not null check (
    budget_range = any (
      array[
        'under-1000',
        '1000-3000',
        '3000-10000',
        'over-10000',
        'request-discussion'
      ]
    )
  ),
  campaign_start date,
  campaign_end date,
  message text not null check (char_length(message) between 30 and 600),
  consent_to_privacy boolean not null check (consent_to_privacy),
  confirm_accuracy boolean not null check (confirm_accuracy),
  source_page text not null default '/business/apply/' check (
    source_page = '/business/apply/'
  ),
  status text not null default 'new' check (
    status = any (array['new', 'reviewing', 'responded', 'accepted', 'declined', 'test', 'archived'])
  ),
  admin_notes text check (admin_notes is null or char_length(admin_notes) <= 2000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint business_inquiries_reference_code_key unique (reference_code),
  constraint business_inquiries_campaign_dates_check check (
    (campaign_start is null and campaign_end is null)
    or (
      campaign_start is not null
      and campaign_end is not null
      and campaign_end >= campaign_start
    )
  ),
  constraint business_inquiries_commercial_kvk_check check (
    organization_type not in ('commercial-business', 'sole-trader', 'advertising-agency')
    or coalesce(kvk_number ~ '^[0-9]{8}$', false)
  )
);

comment on table public.business_inquiries is
  'Business inquiries submitted through the validated YouNew Edge Function. Personal contact details are admin-only.';

create index business_inquiries_created_at_idx
  on public.business_inquiries (created_at desc);

create index business_inquiries_status_created_at_idx
  on public.business_inquiries (status, created_at desc);

alter table public.business_inquiries enable row level security;
revoke all on table public.business_inquiries from public, anon, authenticated;
grant select on table public.business_inquiries to authenticated;
grant update (status, admin_notes) on table public.business_inquiries to authenticated;
grant all on table public.business_inquiries to service_role;

create policy "approved admins read business inquiries"
on public.business_inquiries
for select
to authenticated
using ((select private.is_approved_admin()));

create policy "owners and admins update business inquiries"
on public.business_inquiries
for update
to authenticated
using (
  (select private.current_admin_role()) = any (
    array['owner'::public.admin_role, 'admin'::public.admin_role]
  )
)
with check (
  (select private.current_admin_role()) = any (
    array['owner'::public.admin_role, 'admin'::public.admin_role]
  )
);

create table private.business_inquiry_rate_limits (
  key_hash text not null,
  window_started_at timestamptz not null,
  request_count integer not null default 1 check (request_count > 0),
  last_seen_at timestamptz not null default now(),
  primary key (key_hash, window_started_at)
);

comment on table private.business_inquiry_rate_limits is
  'Pseudonymous hourly counters used only by the business inquiry submission function.';

alter table private.business_inquiry_rate_limits enable row level security;
revoke all on table private.business_inquiry_rate_limits from public, anon, authenticated;

create or replace function private.set_business_inquiry_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

revoke all on function private.set_business_inquiry_updated_at() from public, anon, authenticated;

create trigger set_business_inquiry_updated_at
before update on public.business_inquiries
for each row execute function private.set_business_inquiry_updated_at();

create or replace function private.audit_business_inquiry_status_change()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if old.status is distinct from new.status
    or old.admin_notes is distinct from new.admin_notes then
    insert into public.audit_logs (
      user_id,
      action,
      entity_type,
      entity_id,
      previous_value,
      new_value
    )
    values (
      auth.uid(),
      'business_inquiry_status_updated',
      'business_inquiry',
      new.id::text,
      jsonb_build_object('status', old.status, 'admin_notes', old.admin_notes),
      jsonb_build_object('status', new.status, 'admin_notes', new.admin_notes)
    );
  end if;
  return new;
end;
$$;

revoke all on function private.audit_business_inquiry_status_change() from public, anon, authenticated;

create trigger audit_business_inquiry_status_change
after update on public.business_inquiries
for each row execute function private.audit_business_inquiry_status_change();

create or replace function public.submit_business_inquiry(
  submission jsonb,
  fingerprint_hash text
)
returns table (reference_code text)
language plpgsql
security definer
set search_path = pg_catalog, public, private
as $$
declare
  rate_count integer;
  normalized_window timestamptz := date_trunc('hour', now());
begin
  if submission is null or jsonb_typeof(submission) <> 'object' then
    raise exception using errcode = '22023', message = 'invalid_submission';
  end if;

  if fingerprint_hash is null or fingerprint_hash !~ '^[0-9a-f]{64}$' then
    raise exception using errcode = '22023', message = 'invalid_fingerprint';
  end if;

  insert into private.business_inquiry_rate_limits (
    key_hash,
    window_started_at,
    request_count,
    last_seen_at
  )
  values (fingerprint_hash, normalized_window, 1, now())
  on conflict (key_hash, window_started_at)
  do update set
    request_count = private.business_inquiry_rate_limits.request_count + 1,
    last_seen_at = now()
  returning request_count into rate_count;

  if rate_count > 5 then
    raise exception using errcode = 'P0001', message = 'rate_limit';
  end if;

  delete from private.business_inquiry_rate_limits
  where window_started_at < now() - interval '24 hours';

  return query
  insert into public.business_inquiries (
    company_name,
    contact_person,
    email,
    phone,
    website,
    organization_type,
    kvk_number,
    city,
    province,
    target_audience,
    requested_placements,
    campaign_goal,
    budget_range,
    campaign_start,
    campaign_end,
    message,
    consent_to_privacy,
    confirm_accuracy,
    source_page
  )
  values (
    trim(submission->>'companyName'),
    trim(submission->>'contactPerson'),
    lower(trim(submission->>'email')),
    nullif(trim(submission->>'phone'), ''),
    trim(submission->>'website'),
    trim(submission->>'organizationType'),
    nullif(regexp_replace(submission->>'kvkNumber', '[^0-9]', '', 'g'), ''),
    trim(submission->>'city'),
    trim(submission->>'province'),
    array(select jsonb_array_elements_text(submission->'targetAudience')),
    array(select jsonb_array_elements_text(submission->'requestedPlacements')),
    trim(submission->>'campaignGoal'),
    trim(submission->>'budgetRange'),
    nullif(submission->>'campaignStart', '')::date,
    nullif(submission->>'campaignEnd', '')::date,
    trim(submission->>'description'),
    coalesce((submission->>'consentToPrivacy')::boolean, false),
    coalesce((submission->>'confirmAccuracy')::boolean, false),
    '/business/apply/'
  )
  returning business_inquiries.reference_code;
end;
$$;

comment on function public.submit_business_inquiry(jsonb, text) is
  'Server-only insertion boundary for validated business inquiries with an atomic hourly rate limit.';

revoke all on function public.submit_business_inquiry(jsonb, text) from public, anon, authenticated;
grant execute on function public.submit_business_inquiry(jsonb, text) to service_role;
