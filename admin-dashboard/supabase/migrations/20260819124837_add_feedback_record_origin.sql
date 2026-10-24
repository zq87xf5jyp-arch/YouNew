-- Classify operational feedback without treating demo or legacy rows as
-- genuine user submissions. Existing rows remain unclassified unless an
-- owner/admin records an audited decision.

alter table public.feedback
  add column if not exists record_origin text not null default 'legacy_unclassified';

alter table public.feedback
  drop constraint if exists feedback_record_origin_check,
  add constraint feedback_record_origin_check check (
    record_origin in ('user_submission', 'sample', 'synthetic_test', 'legacy_unclassified')
  );

create index if not exists feedback_record_origin_created_at_idx
  on public.feedback (record_origin, created_at desc);

revoke update on table public.feedback from authenticated;
grant update (status, resolution_note, resolved_by) on table public.feedback to authenticated;

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
    page_reference, feedback_type, consent_at, record_origin
  )
  values (
    v_id, v_code, v_email, v_message, v_page, 'Web', 'new',
    v_page, v_type, v_now, 'user_submission'
  );

  insert into public.audit_logs (user_id, action, entity_type, entity_id, new_value)
  values (
    null,
    'public_feedback_created',
    'feedback',
    v_id::text,
    jsonb_build_object(
      'status', 'new',
      'feedback_type', v_type,
      'page_reference', v_page,
      'record_origin', 'user_submission'
    )
  );

  return query select v_id, v_code, v_now;
end;
$$;

revoke all on function public.submit_public_feedback(jsonb, text)
  from public, anon, authenticated;
grant execute on function public.submit_public_feedback(jsonb, text) to service_role;

create or replace function public.classify_feedback_origin(
  p_feedback_id uuid,
  p_origin text
)
returns void
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  v_previous text;
begin
  if coalesce(private.current_admin_role()::text, '') not in ('owner', 'admin') then
    raise exception using errcode = '42501', message = 'feedback_origin_admin_required';
  end if;
  if p_origin not in ('user_submission', 'sample', 'synthetic_test', 'legacy_unclassified') then
    raise exception using errcode = '22023', message = 'invalid_feedback_origin';
  end if;

  select record_origin into v_previous
  from public.feedback
  where id = p_feedback_id
  for update;

  if not found then
    raise exception using errcode = 'P0002', message = 'feedback_not_found';
  end if;

  update public.feedback
  set record_origin = p_origin,
      updated_at = statement_timestamp()
  where id = p_feedback_id;

  insert into public.audit_logs (user_id, action, entity_type, entity_id, previous_value, new_value)
  values (
    auth.uid(),
    'feedback_origin_classified',
    'feedback',
    p_feedback_id::text,
    jsonb_build_object('record_origin', v_previous),
    jsonb_build_object('record_origin', p_origin)
  );
end;
$$;

revoke all on function public.classify_feedback_origin(uuid, text)
  from public, anon, authenticated;
grant execute on function public.classify_feedback_origin(uuid, text) to authenticated;

comment on column public.feedback.record_origin is
  'Server-controlled provenance. Only user_submission counts as genuine product feedback by default.';
