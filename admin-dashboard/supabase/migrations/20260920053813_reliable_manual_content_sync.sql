-- REVIEW-ONLY candidate. No scheduler/backfill/content activation.
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='15s';
SET LOCAL search_path=public,pg_catalog;
LOCK TABLE public.sync_jobs,public.published_content_artifacts IN ACCESS EXCLUSIVE MODE;
DO $guard$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE oid='public.request_content_sync()'::regprocedure AND md5(pg_get_functiondef(oid))='5225dd07ea621544513c5011237b6a4f' AND pg_get_userbyid(proowner)='postgres' AND proacl::text='{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}') THEN RAISE EXCEPTION 'Reviewed request_content_sync() drift'; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE oid='public.activate_content_artifact(uuid)'::regprocedure AND md5(pg_get_functiondef(oid))='d1161bfd74c306ec7f82c99698a277c5' AND pg_get_userbyid(proowner)='postgres' AND proacl::text='{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}') THEN RAISE EXCEPTION 'Reviewed activate_content_artifact(uuid) drift'; END IF;
  IF md5(pg_get_functiondef('private.current_admin_role()'::regprocedure)) IS DISTINCT FROM 'a1e11767c8522b45486cb5f9d1c59f75' THEN RAISE EXCEPTION 'Approved profile helper drift'; END IF;
  IF (SELECT jsonb_agg(jsonb_build_object('name',c.relname,'owner',pg_get_userbyid(c.relowner),'rls',c.relrowsecurity,'acl',c.relacl::text) ORDER BY c.relname)
      FROM pg_class c WHERE c.oid IN ('public.sync_jobs'::regclass,'public.published_content_artifacts'::regclass)) IS DISTINCT FROM '[{"acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=arw/postgres}","rls":true,"name":"published_content_artifacts","owner":"postgres"},{"acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,authenticated=ar/postgres}","rls":true,"name":"sync_jobs","owner":"postgres"}]'::jsonb THEN RAISE EXCEPTION 'Reviewed Sync table/ACL/RLS drift'; END IF;
  IF (SELECT jsonb_agg(to_jsonb(p) ORDER BY tablename,policyname) FROM pg_policies p WHERE schemaname='public' AND tablename IN ('sync_jobs','published_content_artifacts')) IS DISTINCT FROM '[{"cmd":"SELECT","qual":"private.is_approved_admin()","roles":["authenticated"],"tablename":"published_content_artifacts","permissive":"PERMISSIVE","policyname":"approved admins read content artifacts","schemaname":"public","with_check":null},{"cmd":"ALL","qual":"(private.current_admin_role() = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role]))","roles":["authenticated"],"tablename":"published_content_artifacts","permissive":"PERMISSIVE","policyname":"owners and admins manage content artifacts","schemaname":"public","with_check":"(private.current_admin_role() = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role]))"},{"cmd":"INSERT","qual":null,"roles":["authenticated"],"tablename":"sync_jobs","permissive":"PERMISSIVE","policyname":"approved admins insert sync jobs","schemaname":"public","with_check":"(private.current_admin_role() = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role]))"},{"cmd":"SELECT","qual":"private.is_approved_admin()","roles":["authenticated"],"tablename":"sync_jobs","permissive":"PERMISSIVE","policyname":"approved admins read sync jobs","schemaname":"public","with_check":null}]'::jsonb THEN RAISE EXCEPTION 'Reviewed Sync policies drift'; END IF;
  IF (SELECT jsonb_agg(jsonb_build_object('table',c.relname,'name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'not_null',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid)) ORDER BY c.relname,a.attnum)
       FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace JOIN pg_attribute a ON a.attrelid=c.oid LEFT JOIN pg_attrdef d ON d.adrelid=c.oid AND d.adnum=a.attnum
       WHERE n.nspname='public' AND c.relname IN ('sync_jobs','published_content_artifacts') AND a.attnum>0 AND NOT a.attisdropped) IS DISTINCT FROM '[{"name":"id","type":"uuid","table":"published_content_artifacts","default":"gen_random_uuid()","not_null":true},{"name":"source_version","type":"text","table":"published_content_artifacts","default":null,"not_null":true},{"name":"artifact","type":"jsonb","table":"published_content_artifacts","default":null,"not_null":true},{"name":"artifact_fingerprint","type":"text","table":"published_content_artifacts","default":null,"not_null":true},{"name":"record_count","type":"integer","table":"published_content_artifacts","default":null,"not_null":true},{"name":"status","type":"text","table":"published_content_artifacts","default":"''candidate''::text","not_null":true},{"name":"created_by","type":"uuid","table":"published_content_artifacts","default":null,"not_null":false},{"name":"created_at","type":"timestamp with time zone","table":"published_content_artifacts","default":"now()","not_null":true},{"name":"activated_at","type":"timestamp with time zone","table":"published_content_artifacts","default":null,"not_null":false},{"name":"id","type":"uuid","table":"sync_jobs","default":"gen_random_uuid()","not_null":true},{"name":"job","type":"text","table":"sync_jobs","default":null,"not_null":true},{"name":"target","type":"text","table":"sync_jobs","default":null,"not_null":true},{"name":"status","type":"text","table":"sync_jobs","default":"''queued''::text","not_null":true},{"name":"duration_ms","type":"integer","table":"sync_jobs","default":null,"not_null":false},{"name":"details","type":"jsonb","table":"sync_jobs","default":"''{}''::jsonb","not_null":true},{"name":"created_by","type":"uuid","table":"sync_jobs","default":null,"not_null":false},{"name":"created_at","type":"timestamp with time zone","table":"sync_jobs","default":"now()","not_null":true},{"name":"type","type":"text","table":"sync_jobs","default":null,"not_null":true},{"name":"started_at","type":"timestamp with time zone","table":"sync_jobs","default":"now()","not_null":true},{"name":"completed_at","type":"timestamp with time zone","table":"sync_jobs","default":null,"not_null":false},{"name":"initiator","type":"uuid","table":"sync_jobs","default":null,"not_null":false},{"name":"source_version","type":"text","table":"sync_jobs","default":null,"not_null":false},{"name":"target_version","type":"text","table":"sync_jobs","default":null,"not_null":false},{"name":"records_processed","type":"integer","table":"sync_jobs","default":"0","not_null":true},{"name":"records_failed","type":"integer","table":"sync_jobs","default":"0","not_null":true},{"name":"error_summary","type":"text","table":"sync_jobs","default":null,"not_null":false},{"name":"artifact_fingerprint","type":"text","table":"sync_jobs","default":null,"not_null":false},{"name":"idempotency_key","type":"text","table":"sync_jobs","default":null,"not_null":true}]'::jsonb THEN RAISE EXCEPTION 'Reviewed Sync column contract drift'; END IF;
  IF (SELECT jsonb_agg(jsonb_build_object('table',c.conrelid::regclass::text,'name',c.conname,'definition',pg_get_constraintdef(c.oid)) ORDER BY c.conrelid::regclass::text,c.conname)
       FROM pg_constraint c WHERE c.conrelid IN ('public.sync_jobs'::regclass,'public.published_content_artifacts'::regclass)) IS DISTINCT FROM '[{"name":"published_content_artifacts_artifact_fingerprint_check","table":"published_content_artifacts","definition":"CHECK ((artifact_fingerprint ~ ''^[a-f0-9]{64}$''::text))"},{"name":"published_content_artifacts_artifact_fingerprint_key","table":"published_content_artifacts","definition":"UNIQUE (artifact_fingerprint)"},{"name":"published_content_artifacts_created_by_fkey","table":"published_content_artifacts","definition":"FOREIGN KEY (created_by) REFERENCES profiles(id)"},{"name":"published_content_artifacts_pkey","table":"published_content_artifacts","definition":"PRIMARY KEY (id)"},{"name":"published_content_artifacts_record_count_check","table":"published_content_artifacts","definition":"CHECK ((record_count >= 0))"},{"name":"published_content_artifacts_status_check","table":"published_content_artifacts","definition":"CHECK ((status = ANY (ARRAY[''candidate''::text, ''active''::text, ''superseded''::text, ''rejected''::text])))"},{"name":"sync_jobs_created_by_fkey","table":"sync_jobs","definition":"FOREIGN KEY (created_by) REFERENCES profiles(id)"},{"name":"sync_jobs_idempotency_key_unique","table":"sync_jobs","definition":"UNIQUE (idempotency_key)"},{"name":"sync_jobs_initiator_fkey","table":"sync_jobs","definition":"FOREIGN KEY (initiator) REFERENCES profiles(id)"},{"name":"sync_jobs_pkey","table":"sync_jobs","definition":"PRIMARY KEY (id)"},{"name":"sync_jobs_record_counts_check","table":"sync_jobs","definition":"CHECK (((records_processed >= 0) AND (records_failed >= 0)))"},{"name":"sync_jobs_status_check","table":"sync_jobs","definition":"CHECK ((status = ANY (ARRAY[''queued''::text, ''running''::text, ''succeeded''::text, ''failed''::text, ''cancelled''::text])))"}]'::jsonb THEN RAISE EXCEPTION 'Reviewed Sync constraints drift'; END IF;
  IF EXISTS(SELECT 1 FROM pg_trigger WHERE tgrelid IN ('public.sync_jobs'::regclass,'public.published_content_artifacts'::regclass) AND NOT tgisinternal) THEN RAISE EXCEPTION 'Unexpected Sync trigger'; END IF;
  IF to_regclass('private.content_sync_executions') IS NOT NULL OR to_regprocedure('private.content_sync_receipt(uuid)') IS NOT NULL OR to_regprocedure('public.request_content_sync(uuid)') IS NOT NULL OR to_regprocedure('public.get_content_sync_request(uuid)') IS NOT NULL OR to_regprocedure('public.claim_content_sync_candidate(uuid,uuid)') IS NOT NULL OR to_regprocedure('public.finalize_content_sync_candidate(uuid,uuid,uuid,text,text)') IS NOT NULL OR to_regprocedure('public.fail_content_sync_candidate(uuid,uuid,uuid,text)') IS NOT NULL THEN RAISE EXCEPTION 'Sync boundary already exists; review instead of replay'; END IF;
END
$guard$;
-- Included after exact baseline guards; all writes are candidate-only.
CREATE TABLE private.content_sync_executions (
  job_id uuid PRIMARY KEY REFERENCES public.sync_jobs(id) ON DELETE RESTRICT,
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count BETWEEN 0 AND 3),
  lease_token uuid,
  lease_expires_at timestamptz,
  last_attempt_at timestamptz,
  next_retry_at timestamptz,
  CHECK (lease_expires_at IS NULL OR (lease_token IS NOT NULL AND last_attempt_at IS NOT NULL))
);
ALTER TABLE private.content_sync_executions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON private.content_sync_executions FROM PUBLIC, anon, authenticated, service_role;
COMMENT ON TABLE private.content_sync_executions IS 'Manual content candidate execution v1; no scheduler, no historical backfill; preserve on rollback.';

CREATE FUNCTION private.content_sync_receipt(p_job_id uuid) RETURNS jsonb
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog AS $receipt$
  SELECT jsonb_build_object(
    'id',j.id,'status',j.status,'createdAt',j.created_at,
    'completedAt',j.completed_at,'fingerprint',j.artifact_fingerprint,
    'recordCount',j.records_processed,'errorCode',j.error_summary,
    'attemptCount',x.attempt_count,'attemptAt',x.last_attempt_at,
    'leaseExpiresAt',x.lease_expires_at,'nextRetryAt',x.next_retry_at,
    'retryAfterMs',CASE WHEN x.next_retry_at IS NULL THEN 0 ELSE greatest(0,ceil(extract(epoch FROM (x.next_retry_at-clock_timestamp()))*1000))::integer END,
    'retryable',CASE WHEN x.job_id IS NULL THEN j.status IN ('queued','failed')
      ELSE (j.status='queued' OR (j.status='failed' AND x.next_retry_at IS NOT NULL AND x.attempt_count<3)
        OR (j.status='running' AND x.lease_expires_at<=clock_timestamp() AND x.attempt_count<3)) END,
    'executionKnown',x.job_id IS NOT NULL,'activation','manual','productionReplacementAllowed',false
  ) FROM public.sync_jobs j LEFT JOIN private.content_sync_executions x ON x.job_id=j.id
    WHERE j.id=p_job_id AND j.type='content_artifact_candidate';
$receipt$;

CREATE FUNCTION public.request_content_sync(p_request_id uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $request$
DECLARE v_actor uuid := auth.uid(); v_job public.sync_jobs%rowtype;
BEGIN
  IF v_actor IS NULL OR coalesce(private.current_admin_role()::text,'') NOT IN ('owner','admin') THEN
    RAISE EXCEPTION USING errcode='42501',message='sync_role_required';
  END IF;
  IF p_request_id IS NULL THEN RAISE EXCEPTION USING errcode='22023',message='invalid_request_id'; END IF;
  INSERT INTO public.sync_jobs(id,job,type,target,status,started_at,initiator,source_version,idempotency_key,details)
    VALUES(p_request_id,'content_artifact_candidate','content_artifact_candidate','github-canonical-handoff',
      'queued',clock_timestamp(),v_actor,'supabase-operational','content-sync:'||p_request_id::text,
      jsonb_build_object('activation','manual','production_replacement_allowed',false,'request_protocol','stable-v1'))
    ON CONFLICT DO NOTHING;
  SELECT * INTO v_job FROM public.sync_jobs WHERE id=p_request_id;
  IF NOT FOUND OR v_job.initiator IS DISTINCT FROM v_actor OR v_job.type<>'content_artifact_candidate'
     OR v_job.target<>'github-canonical-handoff' OR v_job.idempotency_key<>'content-sync:'||p_request_id::text THEN
    RAISE EXCEPTION USING errcode='23505',message='sync_request_conflict';
  END IF;
  RETURN p_request_id;
END;
$request$;

CREATE FUNCTION public.get_content_sync_request(p_request_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $read$
BEGIN
  IF auth.uid() IS NULL OR coalesce(private.current_admin_role()::text,'') NOT IN ('owner','admin') THEN
    RAISE EXCEPTION USING errcode='42501',message='sync_role_required';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.sync_jobs WHERE id=p_request_id AND initiator=auth.uid()
      AND type='content_artifact_candidate' AND target='github-canonical-handoff') THEN RETURN NULL; END IF;
  RETURN private.content_sync_receipt(p_request_id);
END;
$read$;

CREATE FUNCTION public.claim_content_sync_candidate(p_job_id uuid,p_actor_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $claim$
DECLARE j public.sync_jobs%rowtype; x private.content_sync_executions%rowtype; v_now timestamptz;
BEGIN
  IF p_actor_id IS NULL OR NOT EXISTS (SELECT 1 FROM public.profiles WHERE id=p_actor_id AND is_approved AND role IN ('owner','admin')) THEN
    RAISE EXCEPTION USING errcode='42501',message='sync_role_required';
  END IF;
  SELECT * INTO j FROM public.sync_jobs WHERE id=p_job_id FOR UPDATE;
  IF NOT FOUND OR j.initiator IS DISTINCT FROM p_actor_id OR j.type<>'content_artifact_candidate'
     OR j.target<>'github-canonical-handoff' THEN
    RAISE EXCEPTION USING errcode='P0002',message='sync_job_not_found';
  END IF;
  IF j.status IN ('succeeded','cancelled') THEN RETURN jsonb_build_object('claimed',false,'receipt',private.content_sync_receipt(p_job_id)); END IF;
  SELECT * INTO x FROM private.content_sync_executions WHERE job_id=p_job_id FOR UPDATE;
  -- A legacy running job has no fence. Never guess that its old executor stopped.
  IF NOT FOUND AND j.status='running' THEN RETURN jsonb_build_object('claimed',false,'receipt',private.content_sync_receipt(p_job_id)); END IF;
  IF NOT FOUND THEN
    INSERT INTO private.content_sync_executions(job_id) VALUES(p_job_id) RETURNING * INTO x;
  END IF;
  v_now:=clock_timestamp();
  IF j.status='running' AND x.lease_expires_at>v_now THEN RETURN jsonb_build_object('claimed',false,'receipt',private.content_sync_receipt(p_job_id)); END IF;
  IF x.attempt_count>=3 OR (j.status='failed' AND x.attempt_count>0 AND x.next_retry_at IS NULL) THEN
    IF j.status='running' AND x.lease_expires_at<=v_now THEN
      UPDATE public.sync_jobs SET status='failed',completed_at=v_now,error_summary='lease_expired_exhausted',records_failed=1 WHERE id=p_job_id;
      UPDATE private.content_sync_executions SET lease_expires_at=NULL,next_retry_at=NULL WHERE job_id=p_job_id;
    END IF;
    RETURN jsonb_build_object('claimed',false,'receipt',private.content_sync_receipt(p_job_id));
  END IF;
  IF x.next_retry_at>v_now THEN RETURN jsonb_build_object('claimed',false,'receipt',private.content_sync_receipt(p_job_id)); END IF;
  UPDATE private.content_sync_executions SET attempt_count=attempt_count+1,lease_token=gen_random_uuid(),
    lease_expires_at=v_now+interval '90 seconds',last_attempt_at=v_now,next_retry_at=NULL
    WHERE job_id=p_job_id RETURNING * INTO x;
  UPDATE public.sync_jobs SET status='running',started_at=v_now,completed_at=NULL,error_summary=NULL WHERE id=p_job_id;
  RETURN jsonb_build_object('claimed',true,'leaseToken',x.lease_token,'receipt',private.content_sync_receipt(p_job_id));
END;
$claim$;

CREATE FUNCTION public.finalize_content_sync_candidate(p_job_id uuid,p_actor_id uuid,p_lease_token uuid,p_artifact_json text,p_fingerprint text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $finish$
DECLARE j public.sync_jobs%rowtype; x private.content_sync_executions%rowtype;
  a jsonb; v_count integer; v_version text; existing public.published_content_artifacts%rowtype; v_now timestamptz;
BEGIN
  IF p_actor_id IS NULL OR NOT EXISTS (SELECT 1 FROM public.profiles WHERE id=p_actor_id AND is_approved AND role IN ('owner','admin')) THEN
    RAISE EXCEPTION USING errcode='42501',message='sync_role_required';
  END IF;
  IF p_artifact_json IS NULL OR octet_length(p_artifact_json)>2097152 OR p_fingerprint IS NULL
     OR p_fingerprint !~ '^[a-f0-9]{64}$' OR encode(sha256(convert_to(p_artifact_json,'UTF8')),'hex')<>p_fingerprint THEN
    RAISE EXCEPTION USING errcode='22023',message='invalid_artifact';
  END IF;
  a:=p_artifact_json::jsonb;
  IF jsonb_typeof(a) IS DISTINCT FROM 'object' OR a->>'schemaVersion' IS DISTINCT FROM '1'
     OR a->>'source' IS DISTINCT FROM 'supabase-operational' OR jsonb_typeof(a->'records') IS DISTINCT FROM 'array'
     OR jsonb_typeof(a->'recordCount') IS DISTINCT FROM 'number'
     OR (a->>'recordCount') !~ '^[0-9]{1,3}$'
     OR jsonb_typeof(a->'sourceVersion') IS DISTINCT FROM 'string'
     OR length(a->>'sourceVersion') NOT BETWEEN 1 AND 180
     OR a->>'generatedAt' IS DISTINCT FROM a->>'sourceVersion' THEN
    RAISE EXCEPTION USING errcode='22023',message='invalid_artifact';
  END IF;
  v_count:=(a->>'recordCount')::integer; v_version:=a->>'sourceVersion';
  IF v_count>500 OR jsonb_array_length(a->'records')<>v_count THEN RAISE EXCEPTION USING errcode='22023',message='invalid_artifact'; END IF;
  SELECT * INTO j FROM public.sync_jobs WHERE id=p_job_id FOR UPDATE;
  IF NOT FOUND OR j.initiator IS DISTINCT FROM p_actor_id OR j.type<>'content_artifact_candidate' OR j.target<>'github-canonical-handoff' THEN
    RAISE EXCEPTION USING errcode='P0002',message='sync_job_not_found';
  END IF;
  SELECT * INTO x FROM private.content_sync_executions WHERE job_id=p_job_id FOR UPDATE;
  IF NOT FOUND OR p_lease_token IS NULL OR x.lease_token IS DISTINCT FROM p_lease_token THEN
    RAISE EXCEPTION USING errcode='40001',message='sync_lease_lost';
  END IF;
  -- Safe retry of a committed finalization whose HTTP response was lost.
  IF j.status='succeeded' THEN
    IF j.artifact_fingerprint IS DISTINCT FROM p_fingerprint OR j.records_processed<>v_count OR j.target_version IS DISTINCT FROM v_version THEN
      RAISE EXCEPTION USING errcode='40001',message='sync_result_conflict';
    END IF;
    SELECT * INTO existing FROM public.published_content_artifacts WHERE artifact_fingerprint=p_fingerprint;
    IF NOT FOUND OR existing.artifact IS DISTINCT FROM a OR existing.record_count<>v_count OR existing.source_version<>v_version THEN
      RAISE EXCEPTION USING errcode='40001',message='sync_result_conflict';
    END IF;
    RETURN private.content_sync_receipt(p_job_id);
  END IF;
  IF j.status<>'running' OR x.lease_expires_at IS NULL OR x.lease_expires_at<=clock_timestamp() THEN
    RAISE EXCEPTION USING errcode='40001',message='sync_lease_lost';
  END IF;
  INSERT INTO public.published_content_artifacts(source_version,artifact,artifact_fingerprint,record_count,status,created_by)
    VALUES(v_version,a,p_fingerprint,v_count,'candidate',p_actor_id) ON CONFLICT(artifact_fingerprint) DO NOTHING;
  SELECT * INTO existing FROM public.published_content_artifacts WHERE artifact_fingerprint=p_fingerprint FOR SHARE;
  IF NOT FOUND OR existing.artifact IS DISTINCT FROM a OR existing.source_version<>v_version OR existing.record_count<>v_count
     OR existing.status NOT IN ('candidate','active') THEN
    RAISE EXCEPTION USING errcode='40001',message='sync_artifact_conflict';
  END IF;
  v_now:=clock_timestamp();
  IF x.lease_expires_at<=v_now THEN RAISE EXCEPTION USING errcode='40001',message='sync_lease_lost'; END IF;
  UPDATE public.sync_jobs SET status='succeeded',completed_at=v_now,target_version=v_version,records_processed=v_count,
    records_failed=0,artifact_fingerprint=p_fingerprint,error_summary=NULL,
    duration_ms=greatest(0,floor(extract(epoch FROM (v_now-x.last_attempt_at))*1000))::integer,
    details=details||jsonb_build_object('candidate_only',true,'activation','manual','production_replacement_allowed',false,'execution_protocol','fenced-v1')
    WHERE id=p_job_id;
  UPDATE private.content_sync_executions SET lease_expires_at=NULL,next_retry_at=NULL WHERE job_id=p_job_id;
  RETURN private.content_sync_receipt(p_job_id);
END;
$finish$;

CREATE FUNCTION public.fail_content_sync_candidate(p_job_id uuid,p_actor_id uuid,p_lease_token uuid,p_error_code text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $fail$
DECLARE j public.sync_jobs%rowtype; x private.content_sync_executions%rowtype; v_now timestamptz;
BEGIN
  IF p_actor_id IS NULL OR NOT EXISTS (SELECT 1 FROM public.profiles WHERE id=p_actor_id AND is_approved AND role IN ('owner','admin')) THEN
    RAISE EXCEPTION USING errcode='42501',message='sync_role_required';
  END IF;
  IF p_error_code IS NULL OR p_error_code NOT IN ('source_read_failed','candidate_write_failed','source_invalid','source_limit_exceeded','sync_artifact_conflict') THEN
    RAISE EXCEPTION USING errcode='22023',message='invalid_failure_code';
  END IF;
  SELECT * INTO j FROM public.sync_jobs WHERE id=p_job_id FOR UPDATE;
  IF NOT FOUND OR j.initiator IS DISTINCT FROM p_actor_id OR j.type<>'content_artifact_candidate' OR j.target<>'github-canonical-handoff' THEN
    RAISE EXCEPTION USING errcode='P0002',message='sync_job_not_found';
  END IF;
  SELECT * INTO x FROM private.content_sync_executions WHERE job_id=p_job_id FOR UPDATE;
  IF NOT FOUND OR p_lease_token IS NULL OR x.lease_token IS DISTINCT FROM p_lease_token THEN
    RAISE EXCEPTION USING errcode='40001',message='sync_lease_lost';
  END IF;
  -- Finalized success always wins over a delayed failure report.
  IF j.status='succeeded' THEN RETURN private.content_sync_receipt(p_job_id); END IF;
  IF j.status='failed' AND x.lease_expires_at IS NULL THEN RETURN private.content_sync_receipt(p_job_id); END IF;
  v_now:=clock_timestamp();
  IF j.status<>'running' OR x.lease_expires_at IS NULL OR x.lease_expires_at<=v_now THEN
    RAISE EXCEPTION USING errcode='40001',message='sync_lease_lost';
  END IF;
  UPDATE public.sync_jobs SET status='failed',completed_at=v_now,records_failed=1,error_summary=p_error_code,
    duration_ms=greatest(0,floor(extract(epoch FROM (v_now-x.last_attempt_at))*1000))::integer WHERE id=p_job_id;
  UPDATE private.content_sync_executions SET lease_expires_at=NULL,
    next_retry_at=CASE WHEN attempt_count<3 AND p_error_code IN ('source_read_failed','candidate_write_failed')
      THEN v_now+make_interval(secs=>attempt_count) ELSE NULL END WHERE job_id=p_job_id;
  RETURN private.content_sync_receipt(p_job_id);
END;
$fail$;

REVOKE ALL ON FUNCTION private.content_sync_receipt(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.request_content_sync(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.get_content_sync_request(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.request_content_sync(uuid),public.get_content_sync_request(uuid) TO authenticated;
REVOKE ALL ON FUNCTION public.claim_content_sync_candidate(uuid,uuid),public.finalize_content_sync_candidate(uuid,uuid,uuid,text,text),public.fail_content_sync_candidate(uuid,uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.claim_content_sync_candidate(uuid,uuid),public.finalize_content_sync_candidate(uuid,uuid,uuid,text,text),public.fail_content_sync_candidate(uuid,uuid,uuid,text) TO service_role;

COMMIT;
