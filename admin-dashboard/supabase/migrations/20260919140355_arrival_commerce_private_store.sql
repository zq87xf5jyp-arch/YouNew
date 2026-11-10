-- Local candidate only. No products, prices, secrets, schedules or live sales are activated.
-- One isolated store, sealed to one account/environment and one immutable artifact.
begin;
create schema arrival_commerce_private;
revoke all on schema arrival_commerce_private from public, anon, authenticated;
grant usage on schema arrival_commerce_private to service_role;

create table arrival_commerce_private.policy (
  singleton boolean primary key default true check (singleton), value jsonb not null
);
create table arrival_commerce_private.orders (
  id uuid primary key default gen_random_uuid(), subject_id uuid not null,
  product_id text not null check(product_id='arrival_planner_v1'), request_key uuid not null,
  amount_minor integer not null check(amount_minor=1499), currency text not null check(currency='eur'),
  status text not null check(status in ('creating','pending','paid','refunded','expired')),
  session_id text unique, payment_intent_id text unique, checkout_url text,
  created_at timestamptz not null default clock_timestamp(), paid_at timestamptz, checked_at timestamptz,
  refund_minor integer not null default 0 check(refund_minor between 0 and 1499),
  uncertain boolean not null default false, generation bigint not null default 0,
  lease_token uuid, lease_until timestamptz, unique(subject_id,request_key)
);
create unique index arrival_one_active_purchase on arrival_commerce_private.orders(subject_id,product_id)
  where status in ('creating','pending','paid');
create index arrival_orders_reconcile on arrival_commerce_private.orders(checked_at,created_at)
  where status in ('pending','paid');
create table arrival_commerce_private.inbox (
  id text primary key, digest text not null check(digest ~ '^[a-f0-9]{64}$'),
  reference_kind text not null check(reference_kind in ('session','payment')), reference_id text not null,
  status text not null check(status in ('queued','processing','retry','processed','dead_letter')),
  attempts integer not null default 0 check(attempts between 0 and 5),
  next_at timestamptz not null default clock_timestamp(), received_at timestamptz not null default clock_timestamp(),
  lease_token uuid, lease_until timestamptz, error_code text
);
create index arrival_inbox_due on arrival_commerce_private.inbox(next_at,received_at)
  where status in ('queued','retry','processing');
create index arrival_inbox_reference on arrival_commerce_private.inbox(reference_kind,reference_id)
  where status <> 'processed';
create table arrival_commerce_private.grants (
  order_id uuid primary key references arrival_commerce_private.orders(id), subject_id uuid not null,
  product_id text not null, artifact_sha256 text not null check(artifact_sha256 ~ '^[a-f0-9]{64}$'),
  granted_at timestamptz not null default clock_timestamp(), revoked_at timestamptz
);
create table arrival_commerce_private.outbox (
  id text primary key, subject_id uuid not null, order_id uuid not null references arrival_commerce_private.orders(id),
  kind text not null check(kind in ('purchase_ready','purchase_refunded')),
  status text not null default 'queued' check(status in ('queued','retry','delivered','dead_letter')),
  attempts integer not null default 0 check(attempts between 0 and 5), next_at timestamptz not null default clock_timestamp(), error_code text
);
create index arrival_outbox_due on arrival_commerce_private.outbox(next_at) where status in ('queued','retry');
create table arrival_commerce_private.notifications (
  id text primary key, subject_id uuid not null, order_id uuid not null references arrival_commerce_private.orders(id),
  kind text not null, created_at timestamptz not null default clock_timestamp()
);
create index arrival_notification_owner on arrival_commerce_private.notifications(subject_id,created_at desc);
create table arrival_commerce_private.exceptions (
  id text primary key, order_id uuid references arrival_commerce_private.orders(id), code text not null,
  created_at timestamptz not null default clock_timestamp(), resolved_at timestamptz
);

-- No client policies: all direct client access is denied even if grants drift.
do $block$
declare t text;
begin
  foreach t in array array['policy','orders','inbox','grants','outbox','notifications','exceptions'] loop
    execute format('alter table arrival_commerce_private.%I enable row level security',t);
    execute format('alter table arrival_commerce_private.%I force row level security',t);
    execute format('revoke all on arrival_commerce_private.%I from public, anon, authenticated, service_role',t);
  end loop;
end $block$;

-- Service-only transactional commands. The Edge handler supplies subject_id only
-- after Supabase Auth getUser(token), never from client body/email/user_metadata.
-- No remote call occurs inside a transaction. Claimed work uses leases + fences.
create function arrival_commerce_private.command(p_action text,p_input jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path = pg_catalog
set statement_timeout = '5s' set lock_timeout = '3s'
as $function$
declare
  cfg jsonb; prod jsonb; o arrival_commerce_private.orders%rowtype;
  j arrival_commerce_private.inbox%rowtype; n arrival_commerce_private.outbox%rowtype;
  subject uuid; token uuid; stamp timestamptz := clock_timestamp(); result jsonb;
  snapshot jsonb; desired text; pi text; refunded integer; hold boolean; existing_grant boolean;
  code text; terminal text; count_rows integer;
begin
  if jsonb_typeof(p_input) is distinct from 'object' or octet_length(p_input::text)>16384 then
    raise exception 'invalid_command';
  end if;
  if p_action='bind_policy' then
    cfg:=p_input->'policy'; prod:=cfg->'product';
    if not (cfg ?& array['mode','accountId','product']) or not (prod ?& array['id','currency','amountMinor','sha256','priceId','stripeProductId']) or cfg->>'mode' is null or cfg->>'accountId' is null or prod->>'sha256' is null or prod->>'priceId' is null or prod->>'stripeProductId' is null or cfg->>'mode' not in ('test','live') or not (cfg->>'accountId' ~ '^acct_[A-Za-z0-9_]{1,220}$')
      or prod->>'id' is distinct from 'arrival_planner_v1' or prod->>'currency' is distinct from 'eur'
      or (prod->>'amountMinor')::integer is distinct from 1499
      or not (prod->>'sha256' ~ '^[a-f0-9]{64}$')
      or not (prod->>'priceId' ~ '^price_[A-Za-z0-9_]{1,220}$')
      or not (prod->>'stripeProductId' ~ '^prod_[A-Za-z0-9_]{1,220}$')
      or cfg is null then raise exception 'invalid_policy'; end if;
    insert into arrival_commerce_private.policy(value) values(cfg) on conflict do nothing;
    select value into result from arrival_commerce_private.policy where singleton;
    if result is distinct from cfg then raise exception 'database_scope_or_catalog_changed'; end if;
    return jsonb_build_object('bound',true);
  end if;
  select value into cfg from arrival_commerce_private.policy where singleton;
  if cfg is null then raise exception 'policy_not_bound'; end if;
  prod:=cfg->'product';

  if p_action in ('checkout_claim','orders','notifications','download') then
    subject:=(p_input->>'subject')::uuid;
    if subject is null or not exists(select 1 from auth.users where id=subject) then raise exception 'not_authenticated'; end if;
  end if;

  if p_action='checkout_claim' then
    if p_input->>'productId' is distinct from prod->>'id' or p_input->>'requestKey' is null then raise exception 'invalid_checkout_request'; end if;
    -- Serializes all devices/keys for this account. Partial UNIQUE is a second guard.
    perform pg_advisory_xact_lock(hashtextextended(subject::text,0));
    select * into o from arrival_commerce_private.orders where subject_id=subject and request_key=(p_input->>'requestKey')::uuid for update;
    if not found then
      select * into o from arrival_commerce_private.orders where subject_id=subject and product_id=prod->>'id'
        and status in ('creating','pending','paid') for update;
    elsif o.product_id is distinct from p_input->>'productId' then raise exception 'idempotency_conflict';
    end if;
    if o.id is null then
      insert into arrival_commerce_private.orders(subject_id,product_id,request_key,amount_minor,currency,status)
        values(subject,prod->>'id',(p_input->>'requestKey')::uuid,(prod->>'amountMinor')::integer,prod->>'currency','creating') returning * into o;
    end if;
    if o.status='creating' and coalesce(o.lease_until,'-infinity')<=stamp then
      if o.created_at<stamp-interval '23 hours' then
        insert into arrival_commerce_private.exceptions(id,order_id,code) values('checkout:'||o.id,o.id,'checkout_creation_uncertain') on conflict do nothing;
        -- Return an error sentinel so the diagnostic commits. Edge throws afterward.
        return jsonb_build_object('error','checkout_requires_review');
      end if;
      token:=gen_random_uuid();
      update arrival_commerce_private.orders set lease_token=token,lease_until=stamp+interval '30 seconds' where id=o.id;
    end if;
    return jsonb_build_object('orderId',o.id,'status',o.status,'checkoutUrl',case when o.status='pending' then o.checkout_url end,'token',token);
  elsif p_action='checkout_finish' then
    select * into o from arrival_commerce_private.orders where id=(p_input->>'orderId')::uuid for update;
    if o.id is null or o.status<>'creating' or o.lease_token is distinct from (p_input->>'token')::uuid or coalesce(o.lease_until,'-infinity')<=stamp then raise exception 'checkout_lease_lost'; end if;
    if p_input->>'sessionId' is null or p_input->>'checkoutUrl' is null or not (p_input->>'sessionId' ~ '^cs_[A-Za-z0-9_]{1,220}$') or not (p_input->>'checkoutUrl' ~ '^https://checkout[.]stripe[.]com/c/pay/[^[:space:]]+$') then raise exception 'invalid_checkout_response'; end if;
    update arrival_commerce_private.orders set status='pending',session_id=p_input->>'sessionId',checkout_url=p_input->>'checkoutUrl',lease_token=null,lease_until=null where id=o.id;
    return jsonb_build_object('orderId',o.id,'status','pending','checkoutUrl',p_input->>'checkoutUrl');
  elsif p_action='checkout_release' then
    update arrival_commerce_private.orders set lease_token=null,lease_until=null where id=(p_input->>'orderId')::uuid and lease_token=(p_input->>'token')::uuid;
    return '{}'::jsonb;
  elsif p_action='receive' then
    if not (p_input->>'id' ~ '^evt_[A-Za-z0-9_]{1,220}$') or not (p_input->>'digest' ~ '^[a-f0-9]{64}$')
      or p_input->>'referenceKind' not in ('session','payment')
      or not (p_input->>'referenceId' ~ case when p_input->>'referenceKind'='session' then '^cs_[A-Za-z0-9_]{1,220}$' else '^pi_[A-Za-z0-9_]{1,220}$' end)
      or not (p_input ?& array['id','digest','referenceKind','referenceId']) then raise exception 'invalid_verified_event'; end if;
    insert into arrival_commerce_private.inbox(id,digest,reference_kind,reference_id,status)
      values(p_input->>'id',p_input->>'digest',p_input->>'referenceKind',p_input->>'referenceId','queued') on conflict do nothing;
    get diagnostics count_rows=row_count;
    if count_rows=0 then
      if (select digest from arrival_commerce_private.inbox where id=p_input->>'id') is distinct from p_input->>'digest' then raise exception 'event_identity_conflict'; end if;
      return jsonb_build_object('accepted',true,'duplicate',true,'durable',true);
    end if;
    update arrival_commerce_private.orders set generation=generation+1,uncertain=true
      where case when p_input->>'referenceKind'='session' then session_id else payment_intent_id end =p_input->>'referenceId';
    return jsonb_build_object('accepted',true,'duplicate',false,'durable',true);
  elsif p_action='claim' then
    select q.* into j from arrival_commerce_private.inbox q
      left join arrival_commerce_private.orders a on (q.reference_kind='session' and a.session_id=q.reference_id) or (q.reference_kind='payment' and a.payment_intent_id=q.reference_id)
      where ((q.status in ('queued','retry') and q.next_at<=stamp) or (q.status='processing' and q.lease_until<=stamp))
      and coalesce(a.lease_until,'-infinity')<=stamp
      order by q.received_at,q.id limit 1 for update of q skip locked;
    if j.id is null then return 'null'::jsonb; end if;
    select * into o from arrival_commerce_private.orders
      where case when j.reference_kind='session' then session_id else payment_intent_id end=j.reference_id for update;
    if coalesce(o.lease_until,'-infinity')>stamp then return 'null'::jsonb; end if;
    if j.attempts>=5 then
      update arrival_commerce_private.inbox set status='dead_letter',error_code='attempt_limit',lease_token=null,lease_until=null where id=j.id;
      insert into arrival_commerce_private.exceptions(id,order_id,code) values('event:'||j.id,o.id,'attempt_limit') on conflict do nothing;
      return 'null'::jsonb;
    end if;
    token:=gen_random_uuid();
    update arrival_commerce_private.inbox set status='processing',attempts=attempts+1,lease_token=token,lease_until=stamp+interval '30 seconds' where id=j.id;
    if o.id is not null then update arrival_commerce_private.orders set lease_token=token,lease_until=stamp+interval '30 seconds' where id=o.id; end if;
    return jsonb_build_object('id',j.id,'token',token,'attempts',j.attempts+1,'order',case when o.id is not null then to_jsonb(o) end);
  elsif p_action='finish' then
    select * into j from arrival_commerce_private.inbox where id=p_input->>'id' for update;
    select * into o from arrival_commerce_private.orders where id=(p_input->>'orderId')::uuid for update;
    token:=(p_input->>'token')::uuid;
    if j.id is null or o.id is null or token is null or j.lease_token is distinct from token or j.status<>'processing'
      or o.lease_token is distinct from token or coalesce(o.lease_until,'-infinity')<=stamp
      or o.generation is distinct from (p_input->>'generation')::bigint then raise exception 'stale_reconciliation'; end if;
    snapshot:=p_input->'snapshot'; desired:=snapshot->>'status'; pi:=snapshot->>'paymentIntentId'; refunded:=(snapshot->>'refundMinor')::integer;
    if desired not in ('pending','paid','refunded','expired') or desired is null or refunded is null or refunded<0 or refunded>o.amount_minor
      or (desired in ('paid','refunded') and (pi is null or not (pi ~ '^pi_[A-Za-z0-9_]{1,220}$')))
      or (desired='paid' and refunded>=o.amount_minor) or (desired='refunded' and refunded<>o.amount_minor) then raise exception 'invalid_payment_snapshot'; end if;
    if o.payment_intent_id is not null and o.payment_intent_id is distinct from pi then raise exception 'payment_identity_changed'; end if;
    if o.status='refunded' and desired<>'refunded' then raise exception 'refund_reversal_requires_review'; end if;
    if o.status='paid' and desired in ('pending','expired') then raise exception 'paid_state_regression'; end if;
    select exists(select 1 from arrival_commerce_private.grants where order_id=o.id and revoked_at is null) into existing_grant;
    hold:=exists(select 1 from arrival_commerce_private.inbox where reference_kind='payment' and reference_id=pi and id<>j.id and status<>'processed')
      or (coalesce((snapshot->>'reviewRequired')::boolean,false) and not existing_grant);
    update arrival_commerce_private.orders set status=desired,payment_intent_id=coalesce(pi,payment_intent_id),refund_minor=refunded,
      paid_at=case when desired='paid' then coalesce(paid_at,stamp) else paid_at end,checked_at=stamp,uncertain=hold,lease_token=null,lease_until=null where id=o.id;
    if desired='paid' and not hold then
      insert into arrival_commerce_private.grants(order_id,subject_id,product_id,artifact_sha256) values(o.id,o.subject_id,o.product_id,prod->>'sha256') on conflict do nothing;
      insert into arrival_commerce_private.outbox(id,subject_id,order_id,kind) values(o.id||':purchase_ready',o.subject_id,o.id,'purchase_ready') on conflict do nothing;
    elsif desired='refunded' then
      update arrival_commerce_private.grants set revoked_at=coalesce(revoked_at,stamp) where order_id=o.id;
      insert into arrival_commerce_private.outbox(id,subject_id,order_id,kind) values(o.id||':purchase_refunded',o.subject_id,o.id,'purchase_refunded') on conflict do nothing;
    end if;
    if coalesce((snapshot->>'reviewRequired')::boolean,false) then
      insert into arrival_commerce_private.exceptions(id,order_id,code) values('payment:'||o.id,o.id,'refund_or_dispute_review') on conflict do nothing;
    end if;
    update arrival_commerce_private.inbox set status='processed',error_code=null,lease_token=null,lease_until=null where id=j.id;
    return jsonb_build_object('status','processed','orderId',o.id);
  elsif p_action='fail' then
    select * into j from arrival_commerce_private.inbox where id=p_input->>'id' for update;
    if j.id is null or j.status<>'processing' or p_input->>'token' is null or j.lease_token is distinct from (p_input->>'token')::uuid then return jsonb_build_object('status','lost_lease'); end if;
    code:=p_input->>'code'; if code is null or not(code ~ '^[a-z_]{1,80}$') then code:='provider_unavailable'; end if;
    terminal:=case when j.attempts>=5 then 'dead_letter' else 'retry' end;
    update arrival_commerce_private.inbox set status=terminal,next_at=stamp+make_interval(secs=>power(2,greatest(0,j.attempts-1))::integer),error_code=code,lease_token=null,lease_until=null where id=j.id;
    update arrival_commerce_private.orders set lease_token=null,lease_until=null where lease_token=j.lease_token returning id into o.id;
    if terminal='dead_letter' then insert into arrival_commerce_private.exceptions(id,order_id,code) values('event:'||j.id,o.id,code) on conflict do nothing; end if;
    return jsonb_build_object('status',terminal,'errorCode',code);
  elsif p_action='notify' then
    select * into n from arrival_commerce_private.outbox where status in ('queued','retry') and next_at<=stamp order by next_at,id limit 1 for update skip locked;
    if n.id is null then return 'null'::jsonb; end if;
    begin
      insert into arrival_commerce_private.notifications(id,subject_id,order_id,kind) values(n.id,n.subject_id,n.order_id,n.kind) on conflict do nothing;
      update arrival_commerce_private.outbox set status='delivered',attempts=attempts+1 where id=n.id;
      return jsonb_build_object('status','delivered');
    exception when others then
      terminal:=case when n.attempts+1>=5 then 'dead_letter' else 'retry' end;
      update arrival_commerce_private.outbox set status=terminal,attempts=attempts+1,next_at=stamp+make_interval(secs=>power(2,n.attempts)::integer),error_code='notification_failed' where id=n.id;
      if terminal='dead_letter' then insert into arrival_commerce_private.exceptions(id,order_id,code) values('notice:'||n.id,n.order_id,'notification_failed') on conflict do nothing; end if;
      return jsonb_build_object('status',terminal);
    end;
  elsif p_action='queue_reconciliation' then
    insert into arrival_commerce_private.inbox(id,digest,reference_kind,reference_id,status)
      select 'reconcile:'||id||':'||to_char(stamp at time zone 'UTC','YYYY-MM-DD'),repeat('0',64),'session',session_id,'queued'
      from arrival_commerce_private.orders where session_id is not null and status in ('paid','pending') and coalesce(checked_at,created_at)<stamp-interval '1 day'
      and not exists(select 1 from arrival_commerce_private.inbox q where q.id='reconcile:'||orders.id||':'||to_char(stamp at time zone 'UTC','YYYY-MM-DD'))
      order by coalesce(checked_at,created_at) limit 100 on conflict do nothing;
    get diagnostics count_rows=row_count; return jsonb_build_object('queued',count_rows);
  elsif p_action='orders' then
    select coalesce(jsonb_agg(v order by created_at desc),'[]') into result from (
      select a.created_at,jsonb_build_object('id',a.id,'productId',a.product_id,'status',a.status,'amountMinor',a.amount_minor,'currency',a.currency,
        'paidAt',floor(extract(epoch from a.paid_at)*1000),'renewal','none',
        'downloadAvailable',a.status='paid' and not a.uncertain and g.order_id is not null and g.revoked_at is null) v
      from arrival_commerce_private.orders a left join arrival_commerce_private.grants g on g.order_id=a.id where a.subject_id=subject order by a.created_at desc limit 100
    ) rows; return jsonb_build_object('orders',result);
  elsif p_action='notifications' then
    select coalesce(jsonb_agg(v order by created_at desc),'[]') into result from (
      select created_at,jsonb_build_object('id',id,'orderId',order_id,'kind',kind,'createdAt',floor(extract(epoch from created_at)*1000)) v
      from arrival_commerce_private.notifications where subject_id=subject order by created_at desc limit 100
    ) rows; return jsonb_build_object('notifications',result);
  elsif p_action='download' then
    select jsonb_build_object('sha256',g.artifact_sha256,'productId',g.product_id) into result
      from arrival_commerce_private.grants g join arrival_commerce_private.orders a on a.id=g.order_id
      where g.order_id=(p_input->>'orderId')::uuid and g.subject_id=subject and a.status='paid' and not a.uncertain and g.revoked_at is null;
    if result is null then raise exception 'not_available'; end if; return result;
  elsif p_action='finance_scope' then
    return jsonb_build_object('accountId',cfg->>'accountId','environment',case when cfg->>'mode'='test' then 'sandbox' else 'live' end,
      'payments',(select coalesce(jsonb_agg(jsonb_build_object('paymentIntentId',payment_intent_id,'source','younew-primary')),'[]') from arrival_commerce_private.orders where payment_intent_id is not null),
      'evidence','Arrival Commerce private server ledger; provider reconciliation is still required');
  elsif p_action='diagnostics' then
    return jsonb_build_object('exceptions',(select coalesce(jsonb_agg(jsonb_build_object('id',e.id,'orderId',e.order_id,'code',e.code,'createdAt',floor(extract(epoch from e.created_at)*1000))),'[]') from arrival_commerce_private.exceptions e where e.resolved_at is null),
      'queued',(select count(*) from arrival_commerce_private.inbox where status in ('queued','retry','processing')),
      'deadLetters',(select count(*) from arrival_commerce_private.inbox where status='dead_letter'),
      'notificationDeadLetters',(select count(*) from arrival_commerce_private.outbox where status='dead_letter'));
  end if;
  raise exception 'unknown_command';
end $function$;
revoke all on function arrival_commerce_private.command(text,jsonb) from public, anon, authenticated;
grant execute on function arrival_commerce_private.command(text,jsonb) to service_role;

-- Only this invoker wrapper is exposed through PostgREST. No client EXECUTE grant.
create function public.arrival_commerce_command(p_action text,p_input jsonb default '{}'::jsonb)
returns jsonb language sql security invoker set search_path = pg_catalog
as $function$ select arrival_commerce_private.command(p_action,p_input); $function$;
revoke all on function public.arrival_commerce_command(text,jsonb) from public, anon, authenticated;
grant execute on function public.arrival_commerce_command(text,jsonb) to service_role;
comment on function public.arrival_commerce_command(text,jsonb) is 'Server-only Arrival Planner commerce; never callable with anon/authenticated JWTs.';
commit;
