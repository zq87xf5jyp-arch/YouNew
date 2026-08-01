-- Supabase logical dumps intentionally exclude managed schemas such as auth.
-- Recreate the reviewed cross-schema dependency after the application schema
-- and private trigger function have been restored.

begin;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert or update of email on auth.users
  for each row execute procedure private.handle_new_admin_user();

commit;
