begin;
set local statement_timeout='10s';
set local lock_timeout='3s';
drop trigger if exists arrival_sandbox_grant_probe on arrival_commerce_private.grants;
drop function if exists arrival_commerce_private.sandbox_grant_probe();
commit;
