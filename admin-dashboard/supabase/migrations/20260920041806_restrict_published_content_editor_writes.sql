-- Review candidate only. No production application is authorized by this file.
-- Additive restrictive write policies; preserve existing permissive/SELECT policies,
-- grants, helpers, table data and approved editor nonpublished workflows.
BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '15s';
SET LOCAL search_path = public, pg_catalog;
-- Lock before guards so table/policy/FK changes cannot race validation.
LOCK TABLE public.categories, public.cities, public.map_points IN ACCESS EXCLUSIVE MODE;
DO $guard$
DECLARE r record;
BEGIN
  -- The trusted helper reads approved profiles, not user-editable JWT metadata.
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE oid='private.current_admin_role()'::regprocedure
      AND pg_get_userbyid(proowner)='postgres' AND prosecdef
      AND proacl::text='{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}'
      AND md5(pg_get_functiondef(oid))='a1e11767c8522b45486cb5f9d1c59f75') THEN
    RAISE EXCEPTION 'private.current_admin_role() definition/ownership/ACL drift';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE oid='private.is_approved_admin()'::regprocedure
      AND pg_get_userbyid(proowner)='postgres' AND prosecdef
      AND proacl::text='{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}'
      AND md5(pg_get_functiondef(oid))='a17d86ff97c2b8fee1ae102629cb52d5') THEN
    RAISE EXCEPTION 'private.is_approved_admin() definition/ownership/ACL drift';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname IN ('anon','authenticated') AND (rolsuper OR rolbypassrls))
     OR (SELECT count(*) FROM pg_roles WHERE rolname IN ('anon','authenticated')) <> 2 THEN
    RAISE EXCEPTION 'Client role flags drift';
  END IF;
  FOR r IN SELECT c.* FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE n.nspname='public' AND c.relname IN ('categories','cities','map_points') LOOP
    IF NOT r.relrowsecurity OR r.relforcerowsecurity OR r.relkind<>'r'
       OR pg_get_userbyid(r.relowner)<>'postgres'
       OR r.relacl::text IS DISTINCT FROM '{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres,anon=r/postgres,authenticated=arwd/postgres}' THEN
      RAISE EXCEPTION 'Table %, RLS/owner/grants drift', r.relname;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_attribute a WHERE a.attrelid=r.oid AND a.attname='status'
       AND a.atttypid='public.publication_status'::regtype AND a.attnotnull AND NOT a.attisdropped) THEN
      RAISE EXCEPTION 'Table %, status type/nullability drift', r.relname;
    END IF;
  END LOOP;
  IF (SELECT jsonb_agg(enumlabel ORDER BY enumsortorder) FROM pg_enum WHERE enumtypid='public.publication_status'::regtype)
       IS DISTINCT FROM '["draft","research","review","qa","published","needs_review","archived"]'::jsonb THEN
    RAISE EXCEPTION 'publication_status enum drift';
  END IF;
  IF (SELECT jsonb_agg(jsonb_build_object('table',c.relname,'name',t.tgname,'enabled',t.tgenabled,
       'trigger',pg_get_triggerdef(t.oid),'function_schema',n.nspname,'function',p.proname,
       'definition',pg_get_functiondef(p.oid),'md5',md5(pg_get_functiondef(p.oid))) ORDER BY c.relname,t.tgname)
      FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_proc p ON p.oid=t.tgfoid
      JOIN pg_namespace n ON n.oid=p.pronamespace WHERE NOT t.tgisinternal AND t.tgrelid IN
      ('public.categories'::regclass,'public.cities'::regclass,'public.map_points'::regclass))
       IS DISTINCT FROM '[{"md5":"63f977f8e2e3db6a119fcbe248bf3314","name":"set_updated_at","table":"categories","enabled":"O","trigger":"CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION set_updated_at()","function":"set_updated_at","definition":"CREATE OR REPLACE FUNCTION public.set_updated_at()\n RETURNS trigger\n LANGUAGE plpgsql\n SET search_path TO ''''\nAS $function$\nbegin\n  new.updated_at = now();\n  return new;\nend;\n$function$\n","function_schema":"public"},{"md5":"63f977f8e2e3db6a119fcbe248bf3314","name":"set_updated_at","table":"cities","enabled":"O","trigger":"CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.cities FOR EACH ROW EXECUTE FUNCTION set_updated_at()","function":"set_updated_at","definition":"CREATE OR REPLACE FUNCTION public.set_updated_at()\n RETURNS trigger\n LANGUAGE plpgsql\n SET search_path TO ''''\nAS $function$\nbegin\n  new.updated_at = now();\n  return new;\nend;\n$function$\n","function_schema":"public"},{"md5":"63f977f8e2e3db6a119fcbe248bf3314","name":"set_updated_at","table":"map_points","enabled":"O","trigger":"CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.map_points FOR EACH ROW EXECUTE FUNCTION set_updated_at()","function":"set_updated_at","definition":"CREATE OR REPLACE FUNCTION public.set_updated_at()\n RETURNS trigger\n LANGUAGE plpgsql\n SET search_path TO ''''\nAS $function$\nbegin\n  new.updated_at = now();\n  return new;\nend;\n$function$\n","function_schema":"public"}]'::jsonb THEN
    RAISE EXCEPTION 'Reviewed target trigger definition drift';
  END IF;
  IF (SELECT coalesce(jsonb_agg(jsonb_build_object('name',c.conname,'child_schema',n.nspname,
       'child_table',t.relname,'parent_table',p.relname,'definition',pg_get_constraintdef(c.oid),
       'delete_action',c.confdeltype,'update_action',c.confupdtype,'deferrable',c.condeferrable,'deferred',c.condeferred)
       ORDER BY n.nspname,t.relname,c.conname),'[]'::jsonb)
      FROM pg_constraint c JOIN pg_class t ON t.oid=c.conrelid JOIN pg_namespace n ON n.oid=t.relnamespace
      JOIN pg_class p ON p.oid=c.confrelid WHERE c.contype='f' AND c.confrelid IN
      ('public.categories'::regclass,'public.cities'::regclass,'public.map_points'::regclass))
       IS DISTINCT FROM '[{"name":"ai_knowledge_items_category_id_fkey","deferred":false,"deferrable":false,"definition":"FOREIGN KEY (category_id) REFERENCES categories(id)","child_table":"ai_knowledge_items","child_schema":"public","parent_table":"categories","delete_action":"a","update_action":"a"},{"name":"articles_category_id_fkey","deferred":false,"deferrable":false,"definition":"FOREIGN KEY (category_id) REFERENCES categories(id)","child_table":"articles","child_schema":"public","parent_table":"categories","delete_action":"a","update_action":"a"},{"name":"categories_canonical_category_id_fkey","deferred":false,"deferrable":false,"definition":"FOREIGN KEY (canonical_category_id) REFERENCES categories(id) ON DELETE RESTRICT","child_table":"categories","child_schema":"public","parent_table":"categories","delete_action":"r","update_action":"a"},{"name":"faq_items_category_id_fkey","deferred":false,"deferrable":false,"definition":"FOREIGN KEY (category_id) REFERENCES categories(id)","child_table":"faq_items","child_schema":"public","parent_table":"categories","delete_action":"a","update_action":"a"},{"name":"resources_category_id_fkey","deferred":false,"deferrable":false,"definition":"FOREIGN KEY (category_id) REFERENCES categories(id)","child_table":"resources","child_schema":"public","parent_table":"categories","delete_action":"a","update_action":"a"}]'::jsonb THEN
    RAISE EXCEPTION 'Inbound FK drift; reassess cascade/SET NULL publication effects';
  END IF;
  IF (SELECT coalesce(jsonb_agg(jsonb_build_object('table',tablename,'name',policyname,
    'command',cmd,'permissive',permissive,'roles',roles,'using',qual,'check',with_check)
    ORDER BY tablename COLLATE "C",policyname COLLATE "C"),'[]'::jsonb)
    FROM pg_policies WHERE schemaname='public' AND tablename IN ('categories','cities','map_points') AND policyname NOT IN ('published_content_insert_boundary_v1','published_content_update_boundary_v1','published_content_delete_boundary_v1'))
       IS DISTINCT FROM '[{"name":"content admins delete categories","check":null,"roles":["authenticated"],"table":"categories","using":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","command":"DELETE","permissive":"PERMISSIVE"},{"name":"content admins insert categories","check":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","roles":["authenticated"],"table":"categories","using":null,"command":"INSERT","permissive":"PERMISSIVE"},{"name":"content admins update categories","check":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","roles":["authenticated"],"table":"categories","using":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","command":"UPDATE","permissive":"PERMISSIVE"},{"name":"published categories and approved admins can read","check":null,"roles":["authenticated"],"table":"categories","using":"((status = ''published''::publication_status) OR ( SELECT private.is_approved_admin() AS is_approved_admin))","command":"SELECT","permissive":"PERMISSIVE"},{"name":"published content is public","check":null,"roles":["anon"],"table":"categories","using":"(status = ''published''::publication_status)","command":"SELECT","permissive":"PERMISSIVE"},{"name":"content admins delete cities","check":null,"roles":["authenticated"],"table":"cities","using":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","command":"DELETE","permissive":"PERMISSIVE"},{"name":"content admins insert cities","check":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","roles":["authenticated"],"table":"cities","using":null,"command":"INSERT","permissive":"PERMISSIVE"},{"name":"content admins update cities","check":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","roles":["authenticated"],"table":"cities","using":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","command":"UPDATE","permissive":"PERMISSIVE"},{"name":"published cities and approved admins can read","check":null,"roles":["authenticated"],"table":"cities","using":"((status = ''published''::publication_status) OR ( SELECT private.is_approved_admin() AS is_approved_admin))","command":"SELECT","permissive":"PERMISSIVE"},{"name":"published cities are public","check":null,"roles":["anon"],"table":"cities","using":"(status = ''published''::publication_status)","command":"SELECT","permissive":"PERMISSIVE"},{"name":"content admins delete map points","check":null,"roles":["authenticated"],"table":"map_points","using":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","command":"DELETE","permissive":"PERMISSIVE"},{"name":"content admins insert map points","check":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","roles":["authenticated"],"table":"map_points","using":null,"command":"INSERT","permissive":"PERMISSIVE"},{"name":"content admins update map points","check":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","roles":["authenticated"],"table":"map_points","using":"(( SELECT private.current_admin_role() AS current_admin_role) = ANY (ARRAY[''owner''::admin_role, ''admin''::admin_role, ''editor''::admin_role]))","command":"UPDATE","permissive":"PERMISSIVE"},{"name":"published map points and approved admins can read","check":null,"roles":["authenticated"],"table":"map_points","using":"((status = ''published''::publication_status) OR ( SELECT private.is_approved_admin() AS is_approved_admin))","command":"SELECT","permissive":"PERMISSIVE"},{"name":"published map points are public","check":null,"roles":["anon"],"table":"map_points","using":"(status = ''published''::publication_status)","command":"SELECT","permissive":"PERMISSIVE"}]'::jsonb THEN
    RAISE EXCEPTION 'Existing reviewed RLS policy drift';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public'
      AND tablename IN ('categories','cities','map_points') AND policyname IN ('published_content_insert_boundary_v1','published_content_update_boundary_v1','published_content_delete_boundary_v1')) THEN
    RAISE EXCEPTION 'Boundary already exists; do not replay or replace';
  END IF;
END
$guard$;

CREATE POLICY published_content_insert_boundary_v1 ON public.categories
  AS RESTRICTIVE FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status);
COMMENT ON POLICY published_content_insert_boundary_v1 ON public.categories IS 'YouNew published content write boundary v1; approved owner/admin manage published; existing editor nonpublished rights preserved.';

CREATE POLICY published_content_update_boundary_v1 ON public.categories
  AS RESTRICTIVE FOR UPDATE TO authenticated
  USING ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status)
  WITH CHECK ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status);
COMMENT ON POLICY published_content_update_boundary_v1 ON public.categories IS 'YouNew published content write boundary v1; approved owner/admin manage published; existing editor nonpublished rights preserved.';

CREATE POLICY published_content_delete_boundary_v1 ON public.categories
  AS RESTRICTIVE FOR DELETE TO authenticated
  USING ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status);
COMMENT ON POLICY published_content_delete_boundary_v1 ON public.categories IS 'YouNew published content write boundary v1; approved owner/admin manage published; existing editor nonpublished rights preserved.';

CREATE POLICY published_content_insert_boundary_v1 ON public.cities
  AS RESTRICTIVE FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status);
COMMENT ON POLICY published_content_insert_boundary_v1 ON public.cities IS 'YouNew published content write boundary v1; approved owner/admin manage published; existing editor nonpublished rights preserved.';

CREATE POLICY published_content_update_boundary_v1 ON public.cities
  AS RESTRICTIVE FOR UPDATE TO authenticated
  USING ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status)
  WITH CHECK ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status);
COMMENT ON POLICY published_content_update_boundary_v1 ON public.cities IS 'YouNew published content write boundary v1; approved owner/admin manage published; existing editor nonpublished rights preserved.';

CREATE POLICY published_content_delete_boundary_v1 ON public.cities
  AS RESTRICTIVE FOR DELETE TO authenticated
  USING ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status);
COMMENT ON POLICY published_content_delete_boundary_v1 ON public.cities IS 'YouNew published content write boundary v1; approved owner/admin manage published; existing editor nonpublished rights preserved.';

CREATE POLICY published_content_insert_boundary_v1 ON public.map_points
  AS RESTRICTIVE FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status);
COMMENT ON POLICY published_content_insert_boundary_v1 ON public.map_points IS 'YouNew published content write boundary v1; approved owner/admin manage published; existing editor nonpublished rights preserved.';

CREATE POLICY published_content_update_boundary_v1 ON public.map_points
  AS RESTRICTIVE FOR UPDATE TO authenticated
  USING ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status)
  WITH CHECK ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status);
COMMENT ON POLICY published_content_update_boundary_v1 ON public.map_points IS 'YouNew published content write boundary v1; approved owner/admin manage published; existing editor nonpublished rights preserved.';

CREATE POLICY published_content_delete_boundary_v1 ON public.map_points
  AS RESTRICTIVE FOR DELETE TO authenticated
  USING ((SELECT private.current_admin_role()) = ANY (
    ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
  ) OR status <> 'published'::public.publication_status);
COMMENT ON POLICY published_content_delete_boundary_v1 ON public.map_points IS 'YouNew published content write boundary v1; approved owner/admin manage published; existing editor nonpublished rights preserved.';
COMMIT;
