-- Replace the legacy advertising-review states with the commercial lifecycle
-- required by the monetization contract. This migration is intentionally
-- forward-only and conservative: no legacy state is promoted to won.

alter table public.business_inquiries
  add column if not exists contact_role text,
  add column if not exists offer_interest text not null default 'not_specified',
  add column if not exists legacy_status text,
  add column if not exists lost_reason text,
  add column if not exists lost_reason_detail text,
  add column if not exists won_evidence_type text,
  add column if not exists won_evidence_at timestamptz,
  add column if not exists status_changed_at timestamptz not null default now();

-- Preserve the legacy endpoint while making the owner-approved pilot route the
-- canonical public source. A worker redirect keeps old browser links working.
alter table public.business_inquiries
  drop constraint if exists business_inquiries_source_page_check,
  add constraint business_inquiries_source_page_check check (
    source_page in ('/business/apply/', '/partners/apply/')
  );

-- Preserve the exact retired value, then map without inventing qualification,
-- discovery, proposal, revenue, or a rejection reason. Declined/test records
-- are archived because their original semantics are not sufficient to satisfy
-- the new mandatory lost-reason contract.
update public.business_inquiries
set legacy_status = status,
    status = case
      when status in ('declined', 'test', 'archived') then 'archived'
      else 'new'
    end,
    status_changed_at = statement_timestamp()
where status in ('reviewing', 'responded', 'accepted', 'declined', 'test');

alter table public.business_inquiries
  drop constraint if exists business_inquiries_status_check,
  drop constraint if exists business_inquiries_contact_role_check,
  drop constraint if exists business_inquiries_offer_interest_check,
  drop constraint if exists business_inquiries_legacy_status_check,
  drop constraint if exists business_inquiries_lost_reason_check,
  drop constraint if exists business_inquiries_lost_reason_detail_check,
  drop constraint if exists business_inquiries_won_evidence_type_check,
  drop constraint if exists business_inquiries_pipeline_outcome_check,
  drop constraint if exists business_inquiries_other_lost_reason_detail_check,
  add constraint business_inquiries_status_check check (
    status in ('new', 'qualified', 'discovery', 'proposal', 'won', 'lost', 'archived')
  ),
  add constraint business_inquiries_contact_role_check check (
    contact_role is null or char_length(btrim(contact_role)) between 2 and 120
  ),
  add constraint business_inquiries_offer_interest_check check (
    offer_interest in (
      'not_specified', 'onboarding_pilot', 'founding_partner_page',
      'sponsored_practical_guide', 'other'
    )
  ),
  add constraint business_inquiries_legacy_status_check check (
    legacy_status is null or legacy_status in (
      'reviewing', 'responded', 'accepted', 'declined', 'test'
    )
  ),
  add constraint business_inquiries_lost_reason_check check (
    lost_reason is null or lost_reason in (
      'no_observed_problem', 'existing_solution_sufficient', 'wrong_owner',
      'no_budget', 'timing', 'insufficient_proof', 'security_privacy',
      'content_trust', 'price_value', 'scope_delivery',
      'no_response_after_sequence', 'other_explicit'
    )
  ),
  add constraint business_inquiries_lost_reason_detail_check check (
    lost_reason_detail is null
    or char_length(btrim(lost_reason_detail)) between 5 and 500
  ),
  add constraint business_inquiries_won_evidence_type_check check (
    won_evidence_type is null or won_evidence_type in (
      'paid_pilot', 'paid_founding_partner_page', 'signed_paid_trial'
    )
  ),
  add constraint business_inquiries_pipeline_outcome_check check (
    (
      status = 'lost'
      and lost_reason is not null
      and won_evidence_type is null
      and won_evidence_at is null
    )
    or (
      status = 'won'
      and lost_reason is null
      and lost_reason_detail is null
      and won_evidence_type is not null
      and won_evidence_at is not null
    )
    or (
      status not in ('lost', 'won')
      and lost_reason is null
      and lost_reason_detail is null
      and won_evidence_type is null
      and won_evidence_at is null
    )
  ),
  add constraint business_inquiries_other_lost_reason_detail_check check (
    lost_reason is distinct from 'other_explicit'
    or lost_reason_detail is not null
  );

create or replace function public.set_business_inquiry_pipeline_metadata()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  if old.status is distinct from new.status then
    new.status_changed_at = statement_timestamp();
  end if;

  if new.status <> 'lost' then
    new.lost_reason = null;
    new.lost_reason_detail = null;
  end if;

  if new.status <> 'won' then
    new.won_evidence_type = null;
    new.won_evidence_at = null;
  elsif new.won_evidence_at is not null
        and new.won_evidence_at > statement_timestamp() then
    raise exception using errcode = '23514', message = 'won_evidence_cannot_be_future';
  end if;

  return new;
end;
$$;

drop trigger if exists set_business_inquiry_pipeline_metadata on public.business_inquiries;
create trigger set_business_inquiry_pipeline_metadata
  before update on public.business_inquiries
  for each row execute function public.set_business_inquiry_pipeline_metadata();

-- Extend the existing PII-minimised audit record with commercial outcome
-- metadata only. Contact details, free-form loss detail, and admin notes are
-- deliberately excluded from audit JSON.
create or replace function public.audit_business_inquiry_change()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $$
begin
  if old.status is distinct from new.status
     or old.offer_interest is distinct from new.offer_interest
     or old.lost_reason is distinct from new.lost_reason
     or old.won_evidence_type is distinct from new.won_evidence_type
     or old.admin_notes is distinct from new.admin_notes
     or old.handled_by is distinct from new.handled_by then
    insert into public.audit_logs (user_id, action, entity_type, entity_id, previous_value, new_value)
    values (
      auth.uid(),
      'business_inquiry_updated',
      'business_inquiry',
      new.id::text,
      jsonb_build_object(
        'status', old.status,
        'offer_interest', old.offer_interest,
        'lost_reason', old.lost_reason,
        'won_evidence_type', old.won_evidence_type,
        'had_admin_notes', old.admin_notes is not null
      ),
      jsonb_build_object(
        'status', new.status,
        'offer_interest', new.offer_interest,
        'lost_reason', new.lost_reason,
        'won_evidence_type', new.won_evidence_type,
        'has_admin_notes', new.admin_notes is not null
      )
    );
  end if;
  return new;
end;
$$;

revoke update on table public.business_inquiries from authenticated;
grant update (
  status,
  contact_role,
  offer_interest,
  lost_reason,
  lost_reason_detail,
  won_evidence_type,
  won_evidence_at,
  admin_notes,
  handled_by
) on table public.business_inquiries to authenticated;

revoke all on function public.set_business_inquiry_pipeline_metadata() from public, anon, authenticated;
revoke all on function public.audit_business_inquiry_change() from public, anon, authenticated;

create index if not exists business_inquiries_status_changed_at_idx
  on public.business_inquiries (status, status_changed_at desc);

comment on column public.business_inquiries.offer_interest is
  'Commercial offer selected by the approved public form or an approved admin; not_specified is retained for the legacy form.';
comment on column public.business_inquiries.legacy_status is
  'Exact retired workflow state retained during conservative Phase 3 migration.';
comment on column public.business_inquiries.lost_reason is
  'Mandatory controlled rejection reason when status is lost; never inferred from premature silence.';
comment on column public.business_inquiries.won_evidence_type is
  'Required controlled evidence class when status is won; prevents an accepted legacy lead from becoming invented revenue.';
