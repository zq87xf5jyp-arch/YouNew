-- The publication trigger must be able to call the private role-check helper
-- without granting authenticated users USAGE on the private schema.
--
-- The function remains trigger-only: direct execution stays revoked from
-- public, anon and authenticated, and every publication still evaluates
-- auth.uid() through private.current_admin_role().

alter function public.enforce_article_publication_gate()
  security definer;

alter function public.enforce_article_publication_gate()
  set search_path = pg_catalog;

revoke all on function public.enforce_article_publication_gate()
  from public, anon, authenticated;

grant execute on function public.enforce_article_publication_gate()
  to service_role;
