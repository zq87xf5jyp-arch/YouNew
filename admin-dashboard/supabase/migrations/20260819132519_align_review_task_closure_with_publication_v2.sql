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

  select task.* into v_task
  from public.content_review_tasks task
  where task.id = p_task_id
  for update;
  if not found then
    raise exception using errcode = 'P0002', message = 'review_task_not_found';
  end if;
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

  select state.* into v_state
  from public.content_governance_state state
  where state.id = v_task.governance_state_id
  for update;
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
