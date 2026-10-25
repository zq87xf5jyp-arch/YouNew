begin;

create extension if not exists pgtap with schema extensions;
set local search_path = public, private, extensions;

select plan(32);

select ok(
  (select relrowsecurity from pg_class where oid = 'private.pilot_usage_events'::regclass),
  'raw pilot usage events have RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'private.pilot_usage_reports'::regclass)
    and (select relrowsecurity from pg_class where oid = 'private.pilot_usage_report_segments'::regclass),
  'aggregate report storage has RLS enabled'
);
select ok(
  not has_table_privilege('anon', 'private.pilot_usage_events', 'SELECT')
    and not has_table_privilege('authenticated', 'private.pilot_usage_events', 'SELECT')
    and not has_table_privilege('anon', 'private.pilot_usage_reports', 'SELECT')
    and not has_table_privilege('authenticated', 'private.pilot_usage_reports', 'SELECT'),
  'raw and aggregate pilot data is unavailable to browser roles'
);
select ok(
  has_function_privilege(
    'service_role',
    'public.generate_pilot_usage_report(uuid,date,date,boolean)',
    'EXECUTE'
  )
    and has_function_privilege(
      'service_role',
      'public.export_pilot_usage_report(uuid)',
      'EXECUTE'
    )
    and not has_function_privilege(
      'anon',
      'public.export_pilot_usage_report(uuid)',
      'EXECUTE'
    )
    and not has_function_privilege(
      'authenticated',
      'public.export_pilot_usage_report(uuid)',
      'EXECUTE'
    ),
  'only service_role can generate or export a pilot report'
);
select is(
  (
    select count(*)
    from information_schema.columns
    where table_schema = 'private'
      and table_name = 'pilot_usage_events'
      and column_name in (
        'email', 'phone', 'name', 'ip', 'ip_address', 'user_id',
        'message', 'free_text', 'partner_status', 'sponsor_status'
      )
  ),
  0::bigint,
  'raw pilot event schema accepts no direct PII, free text or commercial influence field'
);
select is(
  (
    select count(*)
    from information_schema.columns
    where table_schema = 'private'
      and table_name = 'pilot_usage_report_segments'
      and column_name in (
        'client_scope_id', 'subject_token_hash', 'email', 'phone', 'name',
        'ip', 'ip_address', 'user_id', 'message', 'free_text'
      )
  ),
  0::bigint,
  'exportable report segments contain no client or individual identifier'
);
select ok(
  (
    select pg_get_constraintdef(oid)
    from pg_constraint
    where conrelid = 'private.pilot_usage_events'::regclass
      and conname = 'pilot_usage_events_event_name_check'
  ) like all (array['%route_opened%', '%step_completed%', '%official_source_opened%', '%search_used%']),
  'pilot usage accepts only the four reviewed bounded events'
);
select ok(
  (
    select pg_get_constraintdef(oid)
    from pg_constraint
    where conrelid = 'private.pilot_usage_events'::regclass
      and conname = 'pilot_usage_events_consent_granted_check'
  ) like '%consent_granted%',
  'raw pilot storage requires affirmative consent'
);
select is(
  (
    select count(*)
    from information_schema.columns
    where table_schema = 'private'
      and table_name in ('pilot_usage_events', 'pilot_usage_reports', 'pilot_usage_report_segments')
      and column_name ~ '(partner|sponsor)'
  ),
  0::bigint,
  'partner and sponsor status cannot affect report storage'
);

set local role service_role;

select throws_ok(
  $$
    insert into private.pilot_usage_events (
      client_scope_id, subject_token_hash, event_name, occurred_at,
      consent_version, consent_granted
    ) values (
      'aaaaaaaa-0000-4000-8000-000000000001', repeat('f', 64),
      'route_opened', '2026-08-18 12:00:00+00', 'pilot-v1', false
    )
  $$,
  '23514',
  null,
  'non-consented usage is rejected at the table boundary'
);

insert into private.pilot_usage_events (
  client_scope_id, subject_token_hash, event_name, occurred_at,
  consent_version, consent_granted, is_sample, created_at
)
select
  'aaaaaaaa-0000-4000-8000-000000000001',
  lpad(to_hex(subject_number), 64, '0'),
  'route_opened',
  '2026-08-18 12:00:00+00',
  'pilot-v1',
  true,
  false,
  '2026-08-18 12:01:00+00'
from generate_series(1, 6) as subject_number;

insert into private.pilot_usage_events (
  client_scope_id, subject_token_hash, event_name, occurred_at,
  consent_version, consent_granted, is_sample, created_at
)
select
  'aaaaaaaa-0000-4000-8000-000000000001',
  lpad(to_hex(subject_number + 100), 64, '0'),
  'step_completed',
  '2026-08-18 13:00:00+00',
  'pilot-v1',
  true,
  false,
  '2026-08-18 13:01:00+00'
from generate_series(1, 4) as subject_number;

insert into private.pilot_usage_events (
  client_scope_id, subject_token_hash, event_name, occurred_at,
  consent_version, consent_granted, is_sample, created_at
)
select
  'bbbbbbbb-0000-4000-8000-000000000002',
  lpad(to_hex(subject_number + 200), 64, '0'),
  'route_opened',
  '2026-08-18 12:00:00+00',
  'pilot-v1',
  true,
  false,
  '2026-08-18 12:01:00+00'
from generate_series(1, 7) as subject_number;

insert into private.pilot_usage_events (
  client_scope_id, subject_token_hash, event_name, occurred_at,
  consent_version, consent_granted, is_sample, created_at
)
select
  'aaaaaaaa-0000-4000-8000-000000000001',
  lpad(to_hex(subject_number + 300), 64, '0'),
  'search_used',
  '2026-08-18 14:00:00+00',
  'pilot-v1',
  true,
  true,
  '2026-08-18 14:01:00+00'
from generate_series(1, 5) as subject_number;

create temporary table generated_reports (
  label text primary key,
  id uuid not null
) on commit drop;

select lives_ok(
  $$
    insert into generated_reports
    values (
      'real',
      public.generate_pilot_usage_report(
        'aaaaaaaa-0000-4000-8000-000000000001',
        '2026-08-18',
        '2026-08-18',
        false
      )
    )
  $$,
  'a real aggregate report can be generated for one client scope'
);
select is(
  (
    select count(*)
    from private.pilot_usage_report_segments
    where report_id = (select id from generated_reports where label = 'real')
  ),
  1::bigint,
  'only the segment meeting both minimum thresholds is stored'
);
select is(
  (
    select participant_count
    from private.pilot_usage_report_segments
    where report_id = (select id from generated_reports where label = 'real')
  ),
  6::bigint,
  'eligible segment exposes only the aggregate participant count'
);
select is(
  (
    select event_count
    from private.pilot_usage_report_segments
    where report_id = (select id from generated_reports where label = 'real')
  ),
  6::bigint,
  'eligible segment exposes only the aggregate event count'
);
select is(
  (
    select suppressed_segment_count
    from private.pilot_usage_reports
    where id = (select id from generated_reports where label = 'real')
  ),
  1::bigint,
  'the four-person cohort is suppressed without exposing its counts'
);
select is(
  (
    select sum(event_count)
    from private.pilot_usage_report_segments
    where report_id = (select id from generated_reports where label = 'real')
  ),
  6::numeric,
  'a different client scope is never combined into the report'
);

create temporary table exported_reports on commit drop as
select
  'real'::text as label,
  public.export_pilot_usage_report(
    (select id from generated_reports where label = 'real')
  ) as payload;

select is((select payload ->> 'dataLabel' from exported_reports where label = 'real'), 'aggregate data', 'real reports are explicitly labelled aggregate data');
select is((select payload ->> 'minimumCohort' from exported_reports where label = 'real'), '5', 'export states the minimum cohort of five');
select is((select payload ->> 'smallCohortsSuppressed' from exported_reports where label = 'real'), 'true', 'export states that small cohorts are suppressed');
select is((select jsonb_array_length(payload -> 'segments') from exported_reports where label = 'real'), 1, 'suppressed cohorts are absent from exported segments');
select ok(
  (select payload::text from exported_reports where label = 'real') !~* '(aaaaaaaa|bbbbbbbb|subject|token|email|phone|ip_address|user_id|message|timeline)',
  'export JSON contains no client scope, individual identifier, PII, message or timeline'
);
select ok(
  (select payload::text from exported_reports where label = 'real') !~* '(partner|sponsor)',
  'partner and sponsor status cannot influence the export payload'
);

select lives_ok(
  $$
    insert into generated_reports
    values (
      'sample',
      public.generate_pilot_usage_report(
        'aaaaaaaa-0000-4000-8000-000000000001',
        '2026-08-18',
        '2026-08-18',
        true
      )
    )
  $$,
  'sample data can be generated separately from real aggregates'
);
insert into exported_reports
select
  'sample',
  public.export_pilot_usage_report(
    (select id from generated_reports where label = 'sample')
  );
select is((select payload ->> 'dataLabel' from exported_reports where label = 'sample'), 'sample data', 'demo report is visibly labelled sample data');
select is((select payload ->> 'sampleData' from exported_reports where label = 'sample'), 'true', 'demo report exposes a machine-readable sample marker');
select is(
  (
    select (segment ->> 'eventCount')::bigint
    from exported_reports,
      lateral jsonb_array_elements(payload -> 'segments') as segment
    where label = 'sample'
  ),
  5::bigint,
  'sample report contains only its five synthetic events'
);
select is(
  (
    select (segment ->> 'eventName')
    from exported_reports,
      lateral jsonb_array_elements(payload -> 'segments') as segment
    where label = 'sample'
  ),
  'search_used',
  'sample and real data are never combined'
);
select ok(
  (
    select expires_at - generated_at = interval '730 days'
    from private.pilot_usage_reports
    where id = (select id from generated_reports where label = 'real')
  ),
  'aggregate report expiry uses the 24-month default'
);
select throws_ok(
  $$select public.generate_pilot_usage_report(
    'aaaaaaaa-0000-4000-8000-000000000001',
    '2026-01-01',
    '2026-05-01',
    false
  )$$,
  '22023',
  'invalid_report_scope',
  'reports cannot exceed the bounded pilot period'
);
update private.pilot_usage_reports
set expires_at = statement_timestamp() - interval '1 second'
where id = (select id from generated_reports where label = 'real');
select throws_ok(
  $$select public.export_pilot_usage_report(
    (select id from generated_reports where label = 'real')
  )$$,
  '22023',
  'report_not_available',
  'expired report exports fail closed'
);
select ok(
  pg_get_functiondef('public.generate_pilot_usage_report(uuid,date,date,boolean)'::regprocedure) !~* '(partner|sponsor)',
  'report generation has no partner or sponsor branch'
);
select is(
  (
    select count(*)
    from information_schema.columns
    where table_schema = 'private'
      and table_name in ('pilot_usage_reports', 'pilot_usage_report_segments')
      and data_type in ('text', 'character varying')
      and column_name not in ('data_label', 'event_name')
  ),
  0::bigint,
  'aggregate report storage has no free-text field'
);

reset role;

select * from finish();
rollback;
