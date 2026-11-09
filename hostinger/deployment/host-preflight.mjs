// Read-only except writing/deleting its own new random permission probe (post-approval only).
import mysql from 'mysql2/promise';import * as fs from 'node:fs/promises';import {randomUUID} from 'node:crypto';
if(process.argv[2]!=='--approved-probe'||process.env.R4_DB_NAME!=='u246392949_younq1')throw Error('New approved QA only');
const privateRoot='/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1';
const checks={node:process.version,major24:process.versions.node.split('.')[0]==='24',cwd:process.cwd(),persistentWrite:false};
const probe=privateRoot+'/logs/preflight-'+randomUUID()+'.tmp';await fs.writeFile(probe,'synthetic permission probe',{flag:'wx',mode:0o600});checks.persistentWrite=(await fs.readFile(probe,'utf8'))==='synthetic permission probe';await fs.unlink(probe);
const c=await mysql.createConnection({host:process.env.R4_DB_HOST,user:process.env.R4_DB_USER,password:process.env.R4_DB_PASSWORD,database:process.env.R4_DB_NAME,connectTimeout:5000});
try{const [[meta]]=await c.query('SELECT VERSION() AS version,@@sql_mode AS sql_mode,@@character_set_connection AS charset,@@collation_connection AS collation,@@max_user_connections AS max_user_connections');checks.database=meta;const [privileges]=await c.query("SELECT PRIVILEGE_TYPE,IS_GRANTABLE,TABLE_SCHEMA FROM information_schema.SCHEMA_PRIVILEGES WHERE REPLACE(GRANTEE,CHAR(39),'')=CURRENT_USER()");checks.privileges=privileges;console.log(JSON.stringify(checks));}finally{await c.end();}
