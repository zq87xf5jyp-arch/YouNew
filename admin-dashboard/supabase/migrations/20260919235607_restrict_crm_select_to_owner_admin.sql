-- REVIEW ONLY. Not applied or tested. Adds only a table-specific SELECT boundary.
BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '15s';
SET LOCAL search_path = public, pg_catalog;
DO $guard$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class
    WHERE oid = 'public.business_inquiries'::regclass AND relrowsecurity
  ) THEN
    RAISE EXCEPTION 'business_inquiries RLS must already be enabled';
  END IF;
  IF md5(pg_get_functiondef('private.current_admin_role()'::regprocedure))
       IS DISTINCT FROM 'a1e11767c8522b45486cb5f9d1c59f75' THEN
    RAISE EXCEPTION 'current_admin_role definition drift; review before applying';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policy
    WHERE polrelid = 'public.business_inquiries'::regclass
      AND polname = 'approved admins read business inquiries'
      AND polcmd = 'r' AND polpermissive
      AND polroles = ARRAY['authenticated'::regrole::oid]
      AND pg_get_expr(polqual, polrelid) = 'private.is_approved_admin()'
      AND polwithcheck IS NULL
  ) THEN
    RAISE EXCEPTION 'Existing reviewed CRM SELECT policy drift';
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_policy
    WHERE polrelid = 'public.business_inquiries'::regclass
      AND polname = 'crm_owner_admin_select_boundary_v1'
  ) THEN
    RAISE EXCEPTION 'Boundary already exists; do not replay or replace';
  END IF;
END
$guard$;
CREATE POLICY crm_owner_admin_select_boundary_v1
  ON public.business_inquiries
  AS RESTRICTIVE
  FOR SELECT
  TO authenticated
  USING (
    (SELECT private.current_admin_role()) = ANY (
      ARRAY['owner'::public.admin_role, 'admin'::public.admin_role]
    )
  );
COMMENT ON POLICY crm_owner_admin_select_boundary_v1 ON public.business_inquiries
  IS 'YouNew CRM SELECT boundary v1; owner/admin only; no profile or write-policy changes.';
COMMIT;
