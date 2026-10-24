begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(60);

select is(
  (select count(*) from public.app_settings where key in (
    'app_name', 'support_email', 'telegram_link', 'app_store_link', 'google_play_link',
    'privacy_policy_url', 'terms_url', 'default_city', 'default_language', 'announcement', 'maintenance_mode'
  )),
  11::bigint,
  'the complete validated Admin Settings contract is provisioned'
);
select is(
  (select jsonb_typeof(value) from public.app_settings where key = 'maintenance_mode'),
  'boolean',
  'maintenance mode preserves its public JSON boolean type'
);
select ok(
  (select bool_and(status = 'published'::public.publication_status)
   from public.app_settings
   where key in ('telegram_link', 'app_store_link', 'google_play_link', 'privacy_policy_url', 'terms_url', 'announcement')),
  'newly bootstrapped Settings keys have an explicit initial publication state'
);

select has_view('public', 'admin_review_queue', 'canonical Admin review queue view exists');
select has_index('public', 'content_review_tasks', 'content_review_tasks_admin_queue_idx', 'review queue has a deterministic pagination index');
select ok(
  (select coalesce(reloptions, '{}'::text[]) @> array['security_invoker=true']
   from pg_class where oid = 'public.admin_review_queue'::regclass),
  'Admin review queue executes with caller RLS'
);
select ok(
  has_table_privilege('authenticated', 'public.admin_review_queue', 'SELECT')
    and not has_table_privilege('anon', 'public.admin_review_queue', 'SELECT'),
  'review queue is readable only through an authenticated Admin boundary'
);
select matches(
  pg_get_viewdef('public.admin_review_queue'::regclass, true),
  $$CASE (task\.)?severity[\s\S]*'critical'[\s\S]*THEN 0[\s\S]*'high'[\s\S]*THEN 1[\s\S]*'medium'[\s\S]*THEN 2[\s\S]*resolved_at IS NULL$$,
  'review queue exposes canonical severity order and only unresolved tasks'
);

select has_column('public', 'feedback', 'record_origin', 'feedback origin column exists');
select ok(
  (select pg_get_constraintdef(oid) from pg_constraint where conrelid = 'public.feedback'::regclass and conname = 'feedback_record_origin_check')
    like all (array['%user_submission%', '%sample%', '%synthetic_test%', '%legacy_unclassified%']),
  'feedback origins are constrained to the approved taxonomy'
);
select is(
  (select column_default from information_schema.columns where table_schema = 'public' and table_name = 'feedback' and column_name = 'record_origin'),
  '''legacy_unclassified''::text',
  'legacy rows fail closed to unclassified'
);
select ok(
  not has_column_privilege('authenticated', 'public.feedback', 'record_origin', 'UPDATE'),
  'authenticated clients cannot forge feedback provenance'
);
select ok(
  has_column_privilege('authenticated', 'public.feedback', 'status', 'UPDATE'),
  'approved feedback workflow may still update status'
);
select ok(
  not has_function_privilege('anon', 'public.submit_public_feedback(jsonb,text)', 'EXECUTE'),
  'anonymous clients cannot bypass the feedback Edge boundary'
);
select ok(
  has_function_privilege('service_role', 'public.submit_public_feedback(jsonb,text)', 'EXECUTE'),
  'service boundary can submit validated feedback'
);
select ok(
  has_function_privilege('authenticated', 'public.classify_feedback_origin(uuid,text)', 'EXECUTE')
    and not has_function_privilege('anon', 'public.classify_feedback_origin(uuid,text)', 'EXECUTE'),
  'only authenticated admins can reach the audited classification RPC'
);
select matches(
  pg_get_functiondef('public.submit_public_feedback(jsonb,text)'::regprocedure),
  $$record_origin[\s\S]*'user_submission'$$,
  'public feedback function stamps provenance server-side'
);

select is(
  (select count(*) from information_schema.columns where table_schema = 'public' and table_name = 'sync_jobs' and column_name in (
    'queued_at', 'heartbeat_at', 'lease_expires_at', 'lease_token', 'attempt_count', 'timed_out_at'
  )),
  6::bigint,
  'all sync lease columns exist'
);
select ok(
  (select pg_get_constraintdef(oid) from pg_constraint where conrelid = 'public.sync_jobs'::regclass and conname = 'sync_jobs_status_check') like '%timed_out%',
  'timed_out is a terminal sync status'
);
select ok(
  (select is_nullable = 'YES' from information_schema.columns where table_schema = 'public' and table_name = 'sync_jobs' and column_name = 'started_at'),
  'queued jobs no longer pretend to have started'
);
select has_index('public', 'sync_jobs', 'sync_jobs_queued_claim_idx', 'queued claim index exists');
select has_index('public', 'sync_jobs', 'sync_jobs_running_lease_idx', 'running lease index exists');
select ok(
  has_function_privilege('service_role', 'public.claim_sync_job(uuid)', 'EXECUTE')
    and has_function_privilege('service_role', 'public.heartbeat_sync_job(uuid,uuid)', 'EXECUTE')
    and has_function_privilege('service_role', 'public.finalize_sync_job(uuid,uuid,text,jsonb)', 'EXECUTE'),
  'service boundary owns lease lifecycle RPCs'
);
select ok(
  not has_function_privilege('anon', 'public.claim_sync_job(uuid)', 'EXECUTE')
    and not has_function_privilege('authenticated', 'public.claim_sync_job(uuid)', 'EXECUTE'),
  'public clients cannot claim sync jobs'
);
select ok(
  exists (
    select 1 from cron.job
    where jobname = 'younew-sync-job-lease-reconciliation'
      and schedule = '*/5 * * * *'
      and command = 'select * from private.reconcile_stale_sync_jobs(true);'
  ),
  'stale sync reconciliation ships as a five-minute dry-run until separately activated'
);
select ok(
  not has_table_privilege('authenticated', 'public.sync_jobs', 'INSERT')
    and not exists (
      select 1 from pg_policies
      where schemaname = 'public' and tablename = 'sync_jobs'
        and policyname = 'approved admins insert sync jobs'
    ),
  'browser Admin sessions cannot forge sync history through direct INSERT'
);

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
  ('00000000-0000-0000-0000-000000000000', '73000000-0000-4000-8000-000000000001', 'authenticated', 'authenticated', 'feedback-editor@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()),
  ('00000000-0000-0000-0000-000000000000', '73000000-0000-4000-8000-000000000002', 'authenticated', 'authenticated', 'feedback-qa@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()),
  ('00000000-0000-0000-0000-000000000000', '73000000-0000-4000-8000-000000000003', 'authenticated', 'authenticated', 'feedback-viewer@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()),
  ('00000000-0000-0000-0000-000000000000', '73000000-0000-4000-8000-000000000004', 'authenticated', 'authenticated', 'feedback-admin@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now()),
  ('00000000-0000-0000-0000-000000000000', '73000000-0000-4000-8000-000000000005', 'authenticated', 'authenticated', 'feedback-owner@example.invalid', '', now(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, now(), now());

update public.profiles
set role = case id
    when '73000000-0000-4000-8000-000000000001'::uuid then 'editor'::public.admin_role
    when '73000000-0000-4000-8000-000000000002'::uuid then 'qa'::public.admin_role
    when '73000000-0000-4000-8000-000000000003'::uuid then 'viewer'::public.admin_role
    when '73000000-0000-4000-8000-000000000004'::uuid then 'admin'::public.admin_role
    else 'owner'::public.admin_role
  end,
  is_approved = true
where id between '73000000-0000-4000-8000-000000000001'::uuid
  and '73000000-0000-4000-8000-000000000005'::uuid;

set local role service_role;

select lives_ok(
  $$
    insert into public.feedback (id, user_email, message, status, record_origin)
    values ('71000000-0000-4000-8000-000000000001', null, 'Synthetic feedback fixture for provenance validation.', 'new', 'synthetic_test')
  $$,
  'synthetic fixtures can be labelled explicitly by the service boundary'
);
select is(
  (select record_origin from public.feedback where id = '71000000-0000-4000-8000-000000000001'),
  'synthetic_test',
  'synthetic fixture remains distinguishable from user feedback'
);

select lives_ok(
  $$
    create temporary table feedback_receipt on commit drop as
    select * from public.submit_public_feedback(
      '{
        "email":"feedback-test@example.invalid",
        "message":"This synthetic message validates server-controlled feedback provenance.",
        "pageReference":"/test/feedback",
        "feedbackType":"suggestion",
        "consentToPrivacy":true,
        "websiteConfirmation":"",
        "recordOrigin":"sample"
      }'::jsonb,
      repeat('f', 64)
    )
  $$,
  'validated public feedback is accepted through the RPC'
);
select is(
  (select feedback.record_origin from public.feedback join feedback_receipt on feedback.id = feedback_receipt.id),
  'user_submission',
  'accepted public feedback receives user_submission origin'
);
select isnt(
  (select feedback.record_origin from public.feedback join feedback_receipt on feedback.id = feedback_receipt.id),
  'sample',
  'client-provided origin is ignored'
);
select throws_ok(
  $$
    insert into public.feedback (message, record_origin)
    values ('Invalid origin fixture is rejected by the database.', 'forged')
  $$,
  '23514',
  null,
  'unknown feedback origins are rejected'
);

reset role;
select set_config('request.jwt.claim.sub', '73000000-0000-4000-8000-000000000001', true);
select set_config('request.jwt.claims', '{"sub":"73000000-0000-4000-8000-000000000001","role":"authenticated"}', true);
set local role authenticated;
select throws_ok(
  $$ select public.classify_feedback_origin('71000000-0000-4000-8000-000000000001', 'sample') $$,
  '42501', 'feedback_origin_admin_required',
  'editor cannot classify feedback provenance'
);

reset role;
select set_config('request.jwt.claim.sub', '73000000-0000-4000-8000-000000000002', true);
select set_config('request.jwt.claims', '{"sub":"73000000-0000-4000-8000-000000000002","role":"authenticated"}', true);
set local role authenticated;
select throws_ok(
  $$ select public.classify_feedback_origin('71000000-0000-4000-8000-000000000001', 'sample') $$,
  '42501', 'feedback_origin_admin_required',
  'QA cannot classify feedback provenance'
);

reset role;
select set_config('request.jwt.claim.sub', '73000000-0000-4000-8000-000000000003', true);
select set_config('request.jwt.claims', '{"sub":"73000000-0000-4000-8000-000000000003","role":"authenticated"}', true);
set local role authenticated;
select throws_ok(
  $$ select public.classify_feedback_origin('71000000-0000-4000-8000-000000000001', 'sample') $$,
  '42501', 'feedback_origin_admin_required',
  'viewer cannot classify feedback provenance'
);

reset role;
select set_config('request.jwt.claim.sub', '73000000-0000-4000-8000-000000000004', true);
select set_config('request.jwt.claims', '{"sub":"73000000-0000-4000-8000-000000000004","role":"authenticated"}', true);
set local role authenticated;
select lives_ok(
  $$ select public.classify_feedback_origin('71000000-0000-4000-8000-000000000001', 'sample') $$,
  'admin can classify feedback provenance'
);

reset role;
set local role service_role;
select is(
  (select record_origin from public.feedback where id = '71000000-0000-4000-8000-000000000001'),
  'sample',
  'admin classification is stored'
);

reset role;
select set_config('request.jwt.claim.sub', '73000000-0000-4000-8000-000000000005', true);
select set_config('request.jwt.claims', '{"sub":"73000000-0000-4000-8000-000000000005","role":"authenticated"}', true);
set local role authenticated;
select lives_ok(
  $$ select public.classify_feedback_origin('71000000-0000-4000-8000-000000000001', 'synthetic_test') $$,
  'owner can classify feedback provenance'
);
select throws_ok(
  $$
    insert into public.sync_jobs (job, type, target, status, queued_at, source_version, idempotency_key, details)
    values ('forged', 'forged', 'forged', 'succeeded', now(), 'browser', 'forged:sync-history', '{}')
  $$,
  '42501', null,
  'Owner cannot forge a terminal sync row through Data API privileges'
);
select lives_ok(
  $$ select public.request_content_sync() $$,
  'Owner can still request sync through the role-checked RPC'
);

reset role;
set local role service_role;
select is(
  (select record_origin from public.feedback where id = '71000000-0000-4000-8000-000000000001'),
  'synthetic_test',
  'owner classification is stored'
);
select is(
  (select count(*) from public.audit_logs where entity_id = '71000000-0000-4000-8000-000000000001' and action = 'feedback_origin_classified'),
  2::bigint,
  'every privileged classification writes a PII-free audit event'
);

select lives_ok(
  $$
    insert into public.sync_jobs (
      id, job, type, target, status, queued_at, source_version, idempotency_key, details
    ) values (
      '72000000-0000-4000-8000-000000000001', 'lease-test', 'lease-test', 'disposable', 'queued',
      '2026-08-19 12:00:00+00', 'synthetic', 'lease-test:1', '{}'
    )
  $$,
  'a queued synthetic sync job can be created'
);
create temporary table claimed_lease on commit drop as
select public.claim_sync_job('72000000-0000-4000-8000-000000000001') as token;
select ok((select token is not null from claimed_lease), 'queued job is atomically claimed');
select is(public.claim_sync_job('72000000-0000-4000-8000-000000000001'), null::uuid, 'a running job cannot be claimed twice');
select ok(
  (select status = 'running' and attempt_count = 1 and started_at is not null and lease_token = claimed_lease.token
   from public.sync_jobs cross join claimed_lease where id = '72000000-0000-4000-8000-000000000001'),
  'claim initializes the complete lease state'
);
select is(
  public.finalize_sync_job(
    '72000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000999',
    'succeeded',
    '{}'::jsonb
  ),
  false,
  'a mismatched lease cannot finalize a job'
);
select is(
  public.heartbeat_sync_job('72000000-0000-4000-8000-000000000001', (select token from claimed_lease)),
  true,
  'the active worker can renew its lease'
);
select is(
  public.finalize_sync_job(
    '72000000-0000-4000-8000-000000000001',
    (select token from claimed_lease),
    'succeeded',
    jsonb_build_object('records_processed', 3, 'artifact_fingerprint', repeat('a', 64))
  ),
  true,
  'the matching active lease can finalize the job'
);
select ok(
  (select status = 'succeeded' and lease_token is null and records_processed = 3
   from public.sync_jobs where id = '72000000-0000-4000-8000-000000000001'),
  'successful finalization clears the lease and records bounded results'
);

select lives_ok(
  $$
    insert into public.sync_jobs (id, job, type, target, status, queued_at, source_version, idempotency_key, details)
    values
      ('72000000-0000-4000-8000-000000000002', 'stale-queued', 'stale-queued', 'disposable', 'queued', '2026-08-19 11:49:59+00', 'synthetic', 'lease-test:2', '{}'),
      ('72000000-0000-4000-8000-000000000003', 'boundary-queued', 'boundary-queued', 'disposable', 'queued', '2026-08-19 11:50:00+00', 'synthetic', 'lease-test:3', '{}')
  $$,
  'queued timeout boundary fixtures are accepted'
);
create temporary table queued_dry_run on commit drop as
select * from private.reconcile_stale_sync_jobs(true, '2026-08-19 12:00:00+00');
select is((select eligible_count from queued_dry_run where reason = 'queued_timeout'), 1::bigint, 'only jobs older than ten minutes are eligible');
create temporary table queued_cleanup on commit drop as
select * from private.reconcile_stale_sync_jobs(false, '2026-08-19 12:00:00+00');
select is((select changed_count from queued_cleanup where reason = 'queued_timeout'), 1::bigint, 'queued cleanup changes only the eligible row');
select ok(
  (select bool_and((id = '72000000-0000-4000-8000-000000000002' and status = 'timed_out')
                or (id = '72000000-0000-4000-8000-000000000003' and status = 'queued'))
   from public.sync_jobs where id in ('72000000-0000-4000-8000-000000000002', '72000000-0000-4000-8000-000000000003')),
  'boundary cleanup preserves a job queued exactly ten minutes ago'
);
select ok(
  exists (
    select 1 from public.audit_logs
    where entity_id = '72000000-0000-4000-8000-000000000002'
      and action = 'sync_job_timed_out'
      and new_value = '{"type":"stale-queued","reason":"queued_timeout"}'::jsonb
  ),
  'timeout audit contains only operational type and reason'
);

select lives_ok(
  $$
    insert into public.sync_jobs (
      id, job, type, target, status, queued_at, started_at, heartbeat_at,
      lease_expires_at, lease_token, attempt_count, source_version, idempotency_key, details
    ) values
    (
      '72000000-0000-4000-8000-000000000004', 'stale-running', 'stale-running', 'disposable', 'running',
      '2026-08-19 11:30:00+00', '2026-08-19 11:31:00+00', '2026-08-19 11:40:00+00',
      '2026-08-19 11:55:00+00', '72000000-0000-4000-8000-000000000444', 1,
      'synthetic', 'lease-test:4', '{}'
    ),
    (
      '72000000-0000-4000-8000-000000000005', 'boundary-running', 'boundary-running', 'disposable', 'running',
      '2026-08-19 11:30:00+00', '2026-08-19 11:31:00+00', '2026-08-19 11:45:00+00',
      '2026-08-19 12:15:00+00', '72000000-0000-4000-8000-000000000555', 1,
      'synthetic', 'lease-test:5', '{}'
    )
  $$,
  'expired running lease fixture is accepted'
);
create temporary table running_dry_run on commit drop as
select * from private.reconcile_stale_sync_jobs(true, '2026-08-19 12:00:00+00');
select is((select eligible_count from running_dry_run where reason = 'running_lease_expired'), 1::bigint, 'expired running lease is reported by dry-run');
create temporary table running_cleanup on commit drop as
select * from private.reconcile_stale_sync_jobs(false, '2026-08-19 12:00:00+00');
select is((select changed_count from running_cleanup where reason = 'running_lease_expired'), 1::bigint, 'expired running lease is timed out once');
select is(
  (select status from public.sync_jobs where id = '72000000-0000-4000-8000-000000000005'),
  'running',
  'a heartbeat exactly fifteen minutes old remains running'
);
select is(public.claim_sync_job('72000000-0000-4000-8000-000000000004'), null::uuid, 'timed-out terminal jobs cannot be reclaimed');

reset role;
select * from finish();
rollback;
