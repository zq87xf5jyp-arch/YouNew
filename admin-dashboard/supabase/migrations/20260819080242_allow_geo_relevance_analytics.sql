-- Extend the existing consent-gated analytics ingestion contract for the
-- action-first geo release. This migration deliberately patches the latest
-- hardened function body instead of weakening its UUID, consent, timestamp,
-- rate-limit or service-role-only boundaries.

do $migration$
declare
  v_definition text;
  v_patched text;
begin
  select pg_get_functiondef('public.ingest_analytics_batch(jsonb)'::regprocedure)
  into v_definition;

  if position('''analytics_consent_granted'',' || chr(10) || '    ''analytics_consent_revoked'',' in v_definition) = 0
    or position('    ''duration_ms''' || chr(10) || '  ]::text[];' in v_definition) = 0
    or position('    if v_consent <> ''2026-07-28'' then' in v_definition) = 0
    or position('    if v_name in (''lead_start'', ''lead_submit'', ''pilot_request'') and v_properties <> ''{}''::jsonb then' in v_definition) = 0 then
    raise exception 'ingest_analytics_batch contract changed; refusing an unsafe geo analytics patch';
  end if;

  v_patched := replace(
    v_definition,
    '''analytics_consent_granted'',' || chr(10) || '    ''analytics_consent_revoked'',',
    '''analytics_consent_granted'',' || chr(10) ||
    '    ''explicit_city_detected'',' || chr(10) ||
    '    ''city_filter_applied'',' || chr(10) ||
    '    ''city_filter_corrected'',' || chr(10) ||
    '    ''local_result_available'',' || chr(10) ||
    '    ''national_fallback_shown'',' || chr(10) ||
    '    ''wrong_geo_result_reported'',' || chr(10) ||
    '    ''action_panel_cta_clicked'',' || chr(10) ||
    '    ''time_to_first_action'',' || chr(10) ||
    '    ''analytics_consent_revoked'','
  );

  v_patched := replace(
    v_patched,
    '    ''duration_ms''' || chr(10) || '  ]::text[];',
    '    ''duration_ms'',' || chr(10) ||
    '    ''normalized_query_safe'',' || chr(10) ||
    '    ''intent_ids'',' || chr(10) ||
    '    ''filter_type'',' || chr(10) ||
    '    ''filter_city'',' || chr(10) ||
    '    ''filter_province'',' || chr(10) ||
    '    ''filter_category'',' || chr(10) ||
    '    ''filter_profile'',' || chr(10) ||
    '    ''zero_result'',' || chr(10) ||
    '    ''fallback_tier'',' || chr(10) ||
    '    ''position'',' || chr(10) ||
    '    ''city'',' || chr(10) ||
    '    ''intent_id'',' || chr(10) ||
    '    ''source''' || chr(10) ||
    '  ]::text[];'
  );

  v_patched := replace(
    v_patched,
    '    if v_consent <> ''2026-07-28'' then',
    '    if v_consent is distinct from ''2026-07-28'' then'
  );

  v_patched := replace(
    v_patched,
    '    if v_name in (''lead_start'', ''lead_submit'', ''pilot_request'') and v_properties <> ''{}''::jsonb then',
    $validation$    if v_name in (
      'explicit_city_detected',
      'city_filter_applied',
      'city_filter_corrected',
      'local_result_available',
      'national_fallback_shown',
      'wrong_geo_result_reported',
      'action_panel_cta_clicked',
      'time_to_first_action'
    ) and v_city is not null then
      raise exception 'geo events do not accept top-level city' using errcode = '22023';
    end if;

    if v_name in (
      'explicit_city_detected',
      'local_result_available',
      'national_fallback_shown',
      'wrong_geo_result_reported'
    ) and (
      not (v_properties ?& array['city', 'intent_id'])
      or (select count(*) from jsonb_object_keys(v_properties)) <> 2
      or v_properties ->> 'city' !~ '^[a-z0-9]+(-[a-z0-9]+)*$'
      or v_properties ->> 'intent_id' !~ '^[a-z0-9]+([.-][a-z0-9]+)*$'
    ) then
      raise exception 'geo outcome event properties are invalid' using errcode = '22023';
    end if;

    if v_name in ('city_filter_applied', 'city_filter_corrected') and (
      not (v_properties ?& array['city', 'source'])
      or (select count(*) from jsonb_object_keys(v_properties)) <> 2
      or v_properties ->> 'city' !~ '^[a-z0-9]+(-[a-z0-9]+)*$'
      or v_properties ->> 'source' not in ('query', 'filter')
    ) then
      raise exception 'city filter event properties are invalid' using errcode = '22023';
    end if;

    if v_name = 'action_panel_cta_clicked' and (
      not (v_properties ?& array['city', 'content_id'])
      or (select count(*) from jsonb_object_keys(v_properties)) <> 2
      or v_properties ->> 'city' !~ '^[a-z0-9]+(-[a-z0-9]+)*$'
      or v_properties ->> 'content_id' !~ '^[a-z0-9]+([._-][a-z0-9]+)*$'
    ) then
      raise exception 'action panel event properties are invalid' using errcode = '22023';
    end if;

    if v_name = 'time_to_first_action' and (
      not (v_properties ?& array['city', 'intent_id', 'duration_ms'])
      or (select count(*) from jsonb_object_keys(v_properties)) <> 3
      or v_properties ->> 'city' !~ '^[a-z0-9]+(-[a-z0-9]+)*$'
      or v_properties ->> 'intent_id' !~ '^[a-z0-9]+([.-][a-z0-9]+)*$'
      or jsonb_typeof(v_properties -> 'duration_ms') <> 'number'
      or (v_properties ->> 'duration_ms')::numeric < 0
      or (v_properties ->> 'duration_ms')::numeric > 3600000
    ) then
      raise exception 'time-to-action event properties are invalid' using errcode = '22023';
    end if;

    if v_name in ('lead_start', 'lead_submit', 'pilot_request') and v_properties <> '{}'::jsonb then$validation$
  );

  if v_patched = v_definition then
    raise exception 'geo analytics patch made no change';
  end if;

  execute v_patched;
end
$migration$;

comment on function public.ingest_analytics_batch(jsonb) is
  'Consent-gated, rate-limited analytics ingestion with bounded search, geo relevance, action-panel, lead-funnel and app events; executable only by service_role.';
