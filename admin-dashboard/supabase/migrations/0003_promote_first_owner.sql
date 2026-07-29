-- Owner promotion is intentionally not automated or tied to a repository UUID.
-- Create the Auth user first, then run the explicit, audited statement documented
-- in admin-dashboard/README.md with that user's actual Auth UUID.
do $$
begin
  raise notice 'No owner was promoted automatically. Complete the documented owner bootstrap after Auth user creation.';
end $$;
