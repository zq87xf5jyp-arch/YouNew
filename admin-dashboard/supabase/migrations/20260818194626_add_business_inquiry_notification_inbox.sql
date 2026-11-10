-- Internal notification inbox for newly stored business inquiries.
-- The notification deliberately contains no submitted contact, company,
-- message, location or attribution data. External email/webhook delivery is
-- outside this migration and remains blocked until an approved channel exists.

create table public.business_inquiry_notifications (
  id uuid primary key default gen_random_uuid(),
  inquiry_id uuid not null references public.business_inquiries(id) on delete cascade,
  reference_code text not null check (reference_code ~ '^YNI-[A-F0-9]{12}$'),
  notification_kind text not null default 'business_inquiry_created'
    check (notification_kind = 'business_inquiry_created'),
  status text not null default 'unread',
  created_at timestamptz not null default statement_timestamp(),
  read_at timestamptz,
  read_by uuid references public.profiles(id) on delete set null,
  constraint business_inquiry_notifications_inquiry_key unique (inquiry_id),
  constraint business_inquiry_notifications_status_check check (
    status in ('unread', 'read', 'archived')
  ),
  constraint business_inquiry_notifications_read_state_check check (
    (status = 'unread' and read_at is null and read_by is null)
    or
    (status in ('read', 'archived') and read_at is not null)
  )
);

comment on table public.business_inquiry_notifications is
  'PII-minimised internal Admin inbox. One safe receipt notification per newly inserted business inquiry; no external delivery.';
comment on column public.business_inquiry_notifications.reference_code is
  'Safe inquiry receipt code only; never a contact, company or message field.';

create index business_inquiry_notifications_status_created_at_idx
  on public.business_inquiry_notifications (status, created_at desc);

alter table public.business_inquiry_notifications enable row level security;
revoke all on table public.business_inquiry_notifications from public, anon, authenticated;
grant select on table public.business_inquiry_notifications to authenticated;
grant update (status) on table public.business_inquiry_notifications to authenticated;
grant all on table public.business_inquiry_notifications to service_role;

create policy "approved admins read business inquiry notifications"
on public.business_inquiry_notifications
for select
to authenticated
using ((select private.is_approved_admin()));

create policy "owners and admins update business inquiry notifications"
on public.business_inquiry_notifications
for update
to authenticated
using (
  (select private.current_admin_role()) in (
    'owner'::public.admin_role,
    'admin'::public.admin_role
  )
)
with check (
  (select private.current_admin_role()) in (
    'owner'::public.admin_role,
    'admin'::public.admin_role
  )
);

create or replace function private.create_business_inquiry_notification()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $function$
begin
  insert into public.business_inquiry_notifications (
    inquiry_id,
    reference_code
  ) values (
    new.id,
    new.reference_code
  );
  return new;
end
$function$;

revoke all on function private.create_business_inquiry_notification()
  from public, anon, authenticated;

drop trigger if exists create_business_inquiry_notification on public.business_inquiries;
create trigger create_business_inquiry_notification
  after insert on public.business_inquiries
  for each row execute function private.create_business_inquiry_notification();

create or replace function private.set_business_inquiry_notification_read_state()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $function$
begin
  if old.id is distinct from new.id
    or old.inquiry_id is distinct from new.inquiry_id
    or old.reference_code is distinct from new.reference_code
    or old.notification_kind is distinct from new.notification_kind
    or old.created_at is distinct from new.created_at then
    raise exception 'notification_identity_is_immutable' using errcode = '22023';
  end if;

  if new.status = 'unread' then
    new.read_at := null;
    new.read_by := null;
  elsif new.status is distinct from old.status then
    new.read_at := coalesce(old.read_at, statement_timestamp());
    new.read_by := coalesce(old.read_by, new.read_by, auth.uid());
  end if;

  return new;
end
$function$;

revoke all on function private.set_business_inquiry_notification_read_state()
  from public, anon, authenticated;

create trigger set_business_inquiry_notification_read_state
  before update on public.business_inquiry_notifications
  for each row execute function private.set_business_inquiry_notification_read_state();

comment on trigger create_business_inquiry_notification on public.business_inquiries is
  'Creates one internal Admin receipt notification only when a new inquiry row is inserted; exact RPC retries do not fire it.';
