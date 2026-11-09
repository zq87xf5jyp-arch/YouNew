-- Read-only, no secret-bearing SHOW GRANTS output.
SELECT VERSION(),@@SESSION.sql_mode,@@character_set_connection,@@collation_connection,@@GLOBAL.max_connections,@@SESSION.max_user_connections;
SELECT PRIVILEGE_TYPE,IS_GRANTABLE,TABLE_SCHEMA FROM information_schema.SCHEMA_PRIVILEGES WHERE REPLACE(GRANTEE,CHAR(39),'')=CURRENT_USER();
SELECT TABLE_NAME,ENGINE,TABLE_COLLATION FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE();
