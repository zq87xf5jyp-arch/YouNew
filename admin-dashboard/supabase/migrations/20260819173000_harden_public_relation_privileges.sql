-- Remove inherited relation-owner capabilities from browser roles. Application
-- DML and SELECT grants remain explicit in their owning migrations.

begin;

alter default privileges for role postgres in schema public
  revoke all privileges on tables from public, anon, authenticated;

alter default privileges for role supabase_admin in schema public
  revoke all privileges on tables from public, anon, authenticated;

revoke truncate, references, trigger, maintain
on all tables in schema public
from public, anon, authenticated;

commit;
