-- Prepare an isolated local Supabase target for a production logical restore.
-- Objects in the dump are created by local supabase_admin before ownership is
-- reassigned to postgres. Remove local CLI default Data API grants first so
-- the explicit ACL statements in the production dump remain authoritative.

alter default privileges for role supabase_admin in schema public
  revoke all privileges on tables from anon, authenticated;
alter default privileges for role supabase_admin in schema public
  revoke all privileges on sequences from anon, authenticated;
alter default privileges for role supabase_admin in schema public
  revoke execute on functions from anon, authenticated;
