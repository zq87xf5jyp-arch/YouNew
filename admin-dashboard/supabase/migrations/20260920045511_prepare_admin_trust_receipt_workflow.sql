begin;
set local lock_timeout='5s';
set local statement_timeout='15s';
do $guard$ begin
  if md5(pg_get_functiondef('verify_content_now(text,integer,text,text)'::regprocedure)) <> 'c92df6346448c6929233b19534ff2625' then raise exception 'Trust baseline function drift'; end if;
  if (select pg_get_userbyid(proowner) from pg_proc where oid='verify_content_now(text,integer,text,text)'::regprocedure) <> 'postgres' or (select array_agg(case when acl.grantee=0 then 'PUBLIC' else pg_get_userbyid(acl.grantee)::text end order by case when acl.grantee=0 then 'PUBLIC' else pg_get_userbyid(acl.grantee)::text end) from pg_proc p cross join lateral aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) acl where p.oid='verify_content_now(text,integer,text,text)'::regprocedure) is distinct from array['authenticated','postgres']::text[] then raise exception 'Trust baseline owner or ACL drift'; end if;
  if md5(pg_get_functiondef('approve_content_publication(text,integer,text,text)'::regprocedure)) <> '1976622e48adceef16d856b408627263' then raise exception 'Trust baseline function drift'; end if;
  if (select pg_get_userbyid(proowner) from pg_proc where oid='approve_content_publication(text,integer,text,text)'::regprocedure) <> 'postgres' or (select array_agg(case when acl.grantee=0 then 'PUBLIC' else pg_get_userbyid(acl.grantee)::text end order by case when acl.grantee=0 then 'PUBLIC' else pg_get_userbyid(acl.grantee)::text end) from pg_proc p cross join lateral aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) acl where p.oid='approve_content_publication(text,integer,text,text)'::regprocedure) is distinct from array['authenticated','postgres']::text[] then raise exception 'Trust baseline owner or ACL drift'; end if;
  if md5(pg_get_functiondef('transition_content_review_task(uuid,governance_review_state,governance_review_state,uuid,text,text)'::regprocedure)) <> '8772d88195ad0d67be98133978f86a7c' then raise exception 'Trust baseline function drift'; end if;
  if (select pg_get_userbyid(proowner) from pg_proc where oid='transition_content_review_task(uuid,governance_review_state,governance_review_state,uuid,text,text)'::regprocedure) <> 'postgres' or (select array_agg(case when acl.grantee=0 then 'PUBLIC' else pg_get_userbyid(acl.grantee)::text end order by case when acl.grantee=0 then 'PUBLIC' else pg_get_userbyid(acl.grantee)::text end) from pg_proc p cross join lateral aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) acl where p.oid='transition_content_review_task(uuid,governance_review_state,governance_review_state,uuid,text,text)'::regprocedure) is distinct from array['authenticated','postgres']::text[] then raise exception 'Trust baseline owner or ACL drift'; end if;
  if md5(pg_get_functiondef('private.governance_current_admin_role()'::regprocedure)) <> '24953681ff1701e5eb0b969bb9291601' then raise exception 'Trust baseline function drift'; end if;
  if to_regprocedure('public.admin_trust_action(text,uuid,text,integer,uuid,public.governance_review_state,timestamptz,public.governance_review_state,uuid,text)') is not null then raise exception 'Trust wrapper already exists'; end if;
end $guard$;
-- Generic review work may approve evidence, but it must not close a task.
-- Task closure remains an atomic consequence of approve_content_publication().

create or replace function public.transition_content_review_task(
  p_task_id uuid,
  p_expected_state public.governance_review_state,
  p_to_state public.governance_review_state,
  p_owner_id uuid,
  p_idempotency_key text,
  p_reason text
)
returns public.content_review_tasks
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_role text := coalesce(private.governance_current_admin_role(), '');
  v_task public.content_review_tasks;
  v_state public.content_governance_state;
  v_event_id uuid := gen_random_uuid();
  v_event_type text;
begin
  if v_actor is null or v_role not in ('owner', 'admin', 'editor', 'qa') then
    raise exception using errcode = '42501', message = 'review_role_required';
  end if;
  if char_length(coalesce(p_idempotency_key, '')) < 8 then
    raise exception using errcode = '22023', message = 'idempotency_key_required';
  end if;
  if p_to_state = 'approved' and v_role not in ('owner', 'admin', 'qa') then
    raise exception using errcode = '42501', message = 'review_approval_role_required';
  end if;
  if not (
    (p_expected_state = 'needs_review' and p_to_state = 'assigned')
    or (p_expected_state = 'assigned' and p_to_state = 'in_review')
    or (p_expected_state = 'in_review' and p_to_state = 'approved')
    or (p_expected_state = 'monitoring' and p_to_state = 'expired')
    or (p_expected_state = 'expired' and p_to_state = 'needs_review')
  ) then
    raise exception using errcode = '22023', message = 'invalid_review_transition';
  end if;

  -- Match verify/publication: locate identity, then lock state before task.
  select task.* into v_task from public.content_review_tasks task where task.id=p_task_id;
  if not found then raise exception using errcode='P0002', message='review_task_not_found'; end if;
  select state.* into v_state from public.content_governance_state state where state.id=v_task.governance_state_id for update;
  select task.* into v_task from public.content_review_tasks task where task.id=p_task_id for update;
  if not found or v_task.governance_state_id <> v_state.id then raise exception using errcode='40001', message='review_task_identity_conflict'; end if;
  if exists (
    select 1 from public.content_review_events event
    where event.task_id = v_task.id
      and event.actor_id = v_actor
      and event.idempotency_key = p_idempotency_key
  ) then
    return v_task;
  end if;
  if v_task.state <> p_expected_state then
    raise exception using errcode = '40001', message = 'review_state_conflict';
  end if;
  if p_to_state = 'assigned' and p_owner_id is null then
    raise exception using errcode = '22023', message = 'review_owner_required';
  end if;
  if p_owner_id is not null and not exists (
    select 1 from public.profiles reviewer
    where reviewer.id = p_owner_id
      and reviewer.is_approved = true
      and reviewer.role in ('owner', 'admin', 'editor', 'qa')
  ) then
    raise exception using errcode = '22023', message = 'active_review_owner_required';
  end if;

  v_event_type := case p_to_state
    when 'assigned' then 'assigned'
    when 'in_review' then 'review_started'
    when 'approved' then 'review_approved'
    when 'monitoring' then 'monitoring_started'
    when 'expired' then 'expired'
    when 'needs_review' then 'needs_review'
  end;

  insert into public.content_review_events (
    id, governance_state_id, task_id, event_type, from_state, to_state,
    actor_id, actor_type, triggering_governance_version, idempotency_key, reason
  ) values (
    v_event_id, v_state.id, v_task.id, v_event_type, p_expected_state,
    p_to_state, v_actor, 'human', v_state.version, p_idempotency_key,
    coalesce(nullif(btrim(p_reason), ''), 'Review workflow transition.')
  );

  update public.content_review_tasks task
  set state = p_to_state,
      owner_id = coalesce(p_owner_id, task.owner_id),
      assigned_at = case when p_to_state = 'assigned' then now() else task.assigned_at end,
      started_at = case when p_to_state = 'in_review' then now() else task.started_at end,
      updated_at = now()
  where task.id = v_task.id
  returning task.* into v_task;

  perform set_config('younew.human_review_event_id', v_event_id::text, true);
  perform set_config('younew.transformation_identifier', 'transition_review_task:v2', true);
  update public.content_governance_state
  set review_state = p_to_state
  where id = v_state.id;
  return v_task;
end;
$$;

revoke all on function public.transition_content_review_task(
  uuid, public.governance_review_state, public.governance_review_state,
  uuid, text, text
) from public, anon, authenticated, service_role;
grant execute on function public.transition_content_review_task(
  uuid, public.governance_review_state, public.governance_review_state,
  uuid, text, text
) to authenticated;

comment on function public.transition_content_review_task(
  uuid, public.governance_review_state, public.governance_review_state,
  uuid, text, text
) is 'Review workflow v2; approved tasks close only during explicit publication approval.';

-- PREPARE phase, after the reviewed transition v2 definition. No legacy ACL
-- revocation here: the still-deployed old UI must remain callable until rollout.
create function public.admin_trust_action(
  p_action text, p_request_id uuid, p_record_key text, p_expected_version integer,
  p_task_id uuid, p_expected_state public.governance_review_state,
  p_expected_updated_at timestamptz, p_to_state public.governance_review_state,
  p_owner_id uuid, p_reason text
) returns jsonb
language plpgsql security definer set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_role text := coalesce(private.governance_current_admin_role(), '');
  v_state public.content_governance_state;
  v_task public.content_review_tasks;
  v_receipt public.governance_action_receipts;
  v_payload jsonb;
  v_fingerprint text;
  v_action text;
  v_replayed boolean := false;
begin
  -- Authorization is checked even for a previously successful request.
  if v_actor is null or v_role not in ('owner','admin','editor','qa') then
    raise exception using errcode='42501', message='review_role_required';
  end if;
  if p_action is null or p_action not in ('transition','verify','publish')
     or p_request_id is null or p_record_key is null
     or char_length(p_record_key) not between 1 and 240 or p_record_key <> btrim(p_record_key)
     or p_expected_version is null or p_expected_version < 1 or p_expected_version >= 2147483647
     or p_reason is null or char_length(p_reason) not between 2 and 1000 or p_reason <> btrim(p_reason)
  then raise exception using errcode='22023', message='invalid_trust_request'; end if;
  if (p_action='verify' or (p_action='transition' and p_to_state='approved'))
     and v_role not in ('owner','admin','qa') then
    raise exception using errcode='42501', message='verification_role_required';
  end if;
  if p_action='publish' and v_role not in ('owner','admin') then
    raise exception using errcode='42501', message='publication_role_required';
  end if;
  if p_action='transition' then
    if p_task_id is null or p_expected_state is null or p_expected_updated_at is null
       or not isfinite(p_expected_updated_at) or p_to_state is null
       or not ((p_expected_state='needs_review' and p_to_state='assigned')
         or (p_expected_state='assigned' and p_to_state='in_review')
         or (p_expected_state='in_review' and p_to_state='approved')
         or (p_expected_state='monitoring' and p_to_state='expired')
         or (p_expected_state='expired' and p_to_state='needs_review'))
       or (p_to_state='assigned' and p_owner_id is null)
    then raise exception using errcode='22023', message='invalid_review_transition'; end if;
  elsif p_task_id is not null or p_expected_state is not null or p_expected_updated_at is not null
     or p_to_state is not null or p_owner_id is not null then
    raise exception using errcode='22023', message='invalid_trust_request';
  end if;
  v_payload := jsonb_build_array(p_action,p_record_key,p_expected_version,p_task_id,p_expected_state,
    case when p_expected_updated_at is null then null else to_char(p_expected_updated_at at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS.US"Z"') end,
    p_to_state,p_owner_id,p_reason);
  v_fingerprint := encode(sha256(convert_to(v_payload::text,'UTF8')),'hex');
  v_action := 'admin_trust/' || p_action || '/' || v_fingerprint;
  -- One key is serialized across actions/targets for this actor. Hash collisions
  -- only serialize unrelated work; authorization and the actual key still match.
  perform pg_advisory_xact_lock(hashtextextended(v_actor::text || ':' || p_request_id::text,0));
  select receipt.* into v_receipt from public.governance_action_receipts receipt
    where receipt.actor_id=v_actor and receipt.idempotency_key=p_request_id::text
      and receipt.action like 'admin_trust/%';
  if found then
    if v_receipt.action <> v_action then
      raise exception using errcode='40001', message='idempotency_payload_conflict';
    end if;
    v_replayed := true;
  end if;
  -- All guarded governance mutations lock state before tasks. The v2 companion
  -- adjusts the legacy transition lock order to match verify/publication.
  select state.* into v_state from public.content_governance_state state
    where state.record_key=p_record_key for update;
  if not found then raise exception using errcode='P0002', message='governance_record_not_found'; end if;
  if v_replayed and v_receipt.governance_state_id <> v_state.id then
    raise exception using errcode='40001', message='idempotency_payload_conflict';
  end if;
  if p_task_id is not null then
    select task.* into v_task from public.content_review_tasks task where task.id=p_task_id for update;
    if not found or v_task.governance_state_id <> v_state.id then
      raise exception using errcode='P0002', message='review_task_not_found';
    end if;
  end if;
  if not v_replayed then
    if v_state.version <> p_expected_version then
      raise exception using errcode='40001', message='governance_version_conflict';
    end if;
    if p_action='transition' and (v_task.state <> p_expected_state or v_task.updated_at <> p_expected_updated_at) then
      raise exception using errcode='40001', message='review_version_conflict';
    end if;
    if p_action='transition' then
      perform public.transition_content_review_task(p_task_id,p_expected_state,p_to_state,p_owner_id,
        'admin-trust:' || p_request_id::text,p_reason);
    elsif p_action='verify' then
      -- Reject future-source evidence as well as absent/stale evidence. The
      -- existing verifier remains responsible for the remaining prerequisites.
      if v_state.source_opened_at > now() then
        raise exception using errcode='22023', message='official_source_must_be_recently_opened';
      end if;
      perform public.verify_content_now(p_record_key,p_expected_version,'admin-trust:' || p_request_id::text,p_reason);
    else
      perform public.approve_content_publication(p_record_key,p_expected_version,'admin-trust:' || p_request_id::text,p_reason);
    end if;
    select state.* into v_state from public.content_governance_state state where state.id=v_state.id;
    if v_state.version <> p_expected_version+1 then
      raise exception using errcode='40001', message='unexpected_governance_result';
    end if;
    insert into public.governance_action_receipts(actor_id,action,idempotency_key,governance_state_id,result_version)
      values(v_actor,v_action,p_request_id::text,v_state.id,v_state.version) returning * into v_receipt;
  end if;
  if p_task_id is not null then
    select task.* into v_task from public.content_review_tasks task where task.id=p_task_id;
  end if;
  return jsonb_build_object(
    'receipt',jsonb_build_object('id',v_receipt.id,'actorId',v_actor,'action',p_action,
      'requestId',p_request_id,'recordKey',p_record_key,'governanceStateId',v_receipt.governance_state_id,
      'requestFingerprint',v_fingerprint,'resultVersion',v_receipt.result_version,'confirmedAt',v_receipt.created_at),
    'replayed',v_replayed,'current',jsonb_build_object('state',to_jsonb(v_state),'task',case when p_task_id is null then null else to_jsonb(v_task) end)
  );
end;
$$;
revoke all on function public.admin_trust_action(text,uuid,text,integer,uuid,public.governance_review_state,timestamptz,public.governance_review_state,uuid,text) from public,anon,authenticated,service_role;
grant execute on function public.admin_trust_action(text,uuid,text,integer,uuid,public.governance_review_state,timestamptz,public.governance_review_state,uuid,text) to authenticated;
comment on function public.admin_trust_action(text,uuid,text,integer,uuid,public.governance_review_state,timestamptz,public.governance_review_state,uuid,text) is 'Trust Admin receipt-bound workflow v1. Wrapper retains INSERT-only operation confirmations, separate from current readback; trusted service_role/postgres powers are unchanged. No source fetching or client publication.';

commit;
