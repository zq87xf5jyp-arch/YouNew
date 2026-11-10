import * as fs from 'node:fs/promises';import {randomUUID} from 'node:crypto';
import {db} from '../backend/source/admin-dashboard/src/lib/r4/db.ts';
const root=new URL('../',import.meta.url).pathname;Object.assign(process.env,JSON.parse(await fs.readFile(root+'backend/private/env.json','utf8')));
if(process.env.R4_LOCAL!=='true'||!process.env.R4_DB_SOCKET.startsWith(root+'backend/private/'))throw Error('Local only');
const checks=[];function check(n,b){checks.push({name:n,status:b?'PASS':'FAIL'});if(!b)throw Error(n);}
let c=await db().getConnection();
try{
 const [[m]]=await c.query('SELECT VERSION() AS version,@@SESSION.sql_mode AS mode,@@SESSION.time_zone AS tz,@@collation_connection AS collation,@@GLOBAL.sql_mode AS globalMode');
 check('MariaDB_11_8_9',m.version.startsWith('11.8.9-'));check('global_host_nonstrict_unchanged',!m.globalMode.includes('STRICT_TRANS_TABLES'));check('backend_strict_UTC_utf8mb4',m.mode.includes('STRICT_TRANS_TABLES')&&m.tz==='+00:00'&&m.collation==='utf8mb4_unicode_ci');
 await c.beginTransaction();let refused=false;try{await c.execute('INSERT INTO audit_events(id,workspace_id,object_id,event,created_at) VALUES(?,?,?,?,UTC_TIMESTAMP(3))',[randomUUID(),process.env.R4_INGEST_WORKSPACE,randomUUID(),'x'.repeat(1000)]);}catch(e){refused=e.code==='ER_DATA_TOO_LONG';}await c.rollback();check('overlong_write_refused_without_truncation',refused);
 await c.query("SET SESSION sql_mode='NO_ENGINE_SUBSTITUTION'");c.release();c=await db().getConnection();const [[again]]=await c.query('SELECT @@SESSION.sql_mode AS mode');check('reused_connection_strict_restored',again.mode.includes('STRICT_TRANS_TABLES'));
 await fs.writeFile(root+'../evidence/db-session.json',JSON.stringify({status:'PASS',metadata:m,checks},null,2));console.log('PASS',checks.length,'backend SQL-session checks');
}finally{await c.rollback();c.release();}
process.exit(0);
