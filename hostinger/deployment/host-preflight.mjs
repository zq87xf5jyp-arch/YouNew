// Read-only except writing/deleting its own new random permission probe (post-approval only).
import {createRequire} from 'node:module';import * as fs from 'node:fs/promises';import {randomUUID} from 'node:crypto';
const mysql=createRequire(process.cwd()+'/package.json')('mysql2/promise');
if(process.argv[2]!=='--approved-probe'||process.env.R4_DB_NAME!=='u246392949_younq1')throw Error('New approved QA only');
const privateRoot='/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1';
const checks={node:process.version,major24:process.versions.node.split('.')[0]==='24',cwd:process.cwd(),persistentWrite:false};
const probe=privateRoot+'/logs/preflight-'+randomUUID()+'.tmp';await fs.writeFile(probe,'synthetic permission probe',{flag:'wx',mode:0o600});checks.persistentWrite=(await fs.readFile(probe,'utf8'))==='synthetic permission probe';await fs.unlink(probe);
const c=await mysql.createConnection({host:process.env.R4_DB_HOST,user:process.env.R4_DB_USER,password:process.env.R4_DB_PASSWORD,database:process.env.R4_DB_NAME,connectTimeout:5000});
try {
 const [[meta]]=await c.query('SELECT VERSION() AS version,DATABASE() AS selected_database,@@sql_mode AS sql_mode,@@character_set_connection AS charset,@@collation_connection AS collation,@@max_user_connections AS max_user_connections');
 checks.database=meta;
 const grantee="REPLACE(GRANTEE,CHAR(39),'')=CURRENT_USER()";
 const [privileges]=await c.query(`SELECT PRIVILEGE_TYPE,IS_GRANTABLE,TABLE_SCHEMA FROM information_schema.SCHEMA_PRIVILEGES WHERE ${grantee}`);
 const [globalPrivileges]=await c.query(`SELECT PRIVILEGE_TYPE,IS_GRANTABLE FROM information_schema.USER_PRIVILEGES WHERE ${grantee}`);
 const [tablePrivileges]=await c.query(`SELECT PRIVILEGE_TYPE,IS_GRANTABLE,TABLE_SCHEMA,TABLE_NAME FROM information_schema.TABLE_PRIVILEGES WHERE ${grantee}`);
 const [columnPrivileges]=await c.query(`SELECT PRIVILEGE_TYPE,IS_GRANTABLE,TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME FROM information_schema.COLUMN_PRIVILEGES WHERE ${grantee}`);
 const [tables]=await c.execute('SELECT TABLE_NAME,TABLE_TYPE,ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=? ORDER BY TABLE_NAME',[process.env.R4_DB_NAME]);
 checks.privileges=privileges;
 checks.globalPrivileges=globalPrivileges;
 checks.tablePrivileges=tablePrivileges;
 checks.columnPrivileges=columnPrivileges;
 checks.tables=tables;
 // Report actual evidence; these direct grants do not establish role inheritance.
 const [roles]=await c.query('SELECT CURRENT_ROLE() AS active_role');
 checks.role=roles[0];
 console.log(JSON.stringify(checks));
} finally { await c.end(); }
