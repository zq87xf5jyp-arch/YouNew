-- Template only: replace both UUID placeholders with the root-provided SECOND synthetic order and subject.
-- Do not execute before the first normal purchase/restore/refund path is accepted.
begin;
set local statement_timeout='10s';
set local lock_timeout='3s';
create function arrival_commerce_private.sandbox_grant_probe()
returns trigger language plpgsql security invoker set search_path=pg_catalog
as $probe$
begin
  if new.order_id=tg_argv[0]::uuid and new.subject_id=tg_argv[1]::uuid
    and clock_timestamp()<tg_argv[2]::timestamptz then
    raise exception using errcode='P0001',message='arrival_sandbox_grant_probe';
  end if;
  return new;
end
$probe$;
revoke all on function arrival_commerce_private.sandbox_grant_probe() from public,anon,authenticated,service_role;
do $scope$
declare
  target_order uuid:='cfd5a3b9-dd5f-4222-bfc0-f40591bf2ed2';
  target_subject uuid:='9d903cb1-372f-43e0-b6ae-a4d3b87c48ae';
  expires_at timestamptz:=clock_timestamp()+interval '90 seconds';
begin
  if not exists(select 1 from arrival_commerce_private.policy where value->>'mode'='test'
      and value->>'accountId'='acct_1UHKAQ3DfFAjsQJw') then
    raise exception 'test_policy_required';
  end if;
  if not exists(select 1 from arrival_commerce_private.orders o join auth.users u on u.id=o.subject_id
      where o.id=target_order and o.subject_id=target_subject and o.product_id='arrival_planner_v1'
      and o.status='pending' and o.session_id is not null
      and u.email like '%@example.invalid' and u.email_confirmed_at is not null)
    or exists(select 1 from arrival_commerce_private.grants where order_id=target_order) then
    raise exception 'exact_unfulfilled_synthetic_order_required';
  end if;
  execute format('create trigger arrival_sandbox_grant_probe before insert on arrival_commerce_private.grants for each row when (new.order_id=%L::uuid) execute function arrival_commerce_private.sandbox_grant_probe(%L,%L,%L)',
    target_order::text,target_order::text,target_subject::text,expires_at::text);
end
$scope$;
commit;
-- Worker finish rolls back the unissued grant atomically, then existing fail RPC records retry.
-- No manual worker calls while the90s probe is active. At most two scheduled minutes can encounter it.
-- Capture real retry/error_code plus absent grant, then let expiry or exact cleanup permit automatic recovery.
