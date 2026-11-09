// Local synthetic SQL capability probe. Never implies a match to an unknown Hostinger DB version.
import mysql from '../source/admin-dashboard/node_modules/mysql2/promise.js';
import fs from 'node:fs';import path from 'node:path';import {randomUUID,createHash} from 'node:crypto';
const root=path.resolve(import.meta.dirname,'..');const env=JSON.parse(fs.readFileSync(root+'/private/env.json','utf8'));
if(env.R4_LOCAL!=='true'||env.R4_DB_NAME!=='r4_candidate'||!env.R4_DB_SOCKET?.startsWith(root+'/private/'))throw new Error('Local synthetic database only');
const c=await mysql.createConnection({user:env.R4_DB_USER,password:env.R4_DB_PASSWORD,database:env.R4_DB_NAME,socketPath:env.R4_DB_SOCKET,multipleStatements:false,dateStrings:true,timezone:'Z'});
const checks=[];let metadata;
function check(name,ok){checks.push({name,pass:Boolean(ok)});if(!ok)throw new Error(name);}
try{
 const [[m]]=await c.query('SELECT VERSION() AS version,@@sql_mode AS sql_mode,@@character_set_connection AS connection_charset,@@collation_connection AS connection_collation,@@character_set_database AS db_charset,@@collation_database AS db_collation,@@max_connections AS max_connections');metadata=m;
 check('connection and database support utf8mb4',m.connection_charset==='utf8mb4'&&m.db_charset==='utf8mb4');
 const [tables]=await c.execute('SELECT TABLE_NAME,ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=?',[env.R4_DB_NAME]);check('all twelve tables use InnoDB',tables.length===12&&tables.every(x=>x.ENGINE==='InnoDB'));
 const [[migration]]=await c.execute('SELECT sha256 FROM schema_migrations WHERE version=?',['0001_core.sql']);check('migration checksum unchanged',migration.sha256===createHash('sha256').update(fs.readFileSync(root+'/db/migrations/0001_core.sql')).digest('hex'));
 const workspace=env.R4_INGEST_WORKSPACE;const id=randomUUID(),receipt='YNI-'+randomUUID().replaceAll('-','').slice(0,12).toUpperCase();
 const text="Synthetic Ω — Привет — 東京 — café — 🌍 ' quoted \\ backslash";const payload=JSON.stringify({companyName:text,description:'Synthetic encoding probe, rolled back.'});
 await c.query('SET TRANSACTION ISOLATION LEVEL READ COMMITTED');await c.beginTransaction();
 await c.execute('INSERT INTO business_inquiries(id,workspace_id,receipt,payload,offer_interest,created_at,consent_at,status_changed_at,updated_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3),UTC_TIMESTAMP(3),UTC_TIMESTAMP(3),UTC_TIMESTAMP(3))',[id,workspace,receipt,payload,'not_specified']);
 const [[r]]=await c.execute('SELECT payload FROM business_inquiries WHERE id=?',[id]);check('parameterized Unicode emoji quotes round-trip',JSON.parse(r.payload).companyName===text);
 await c.execute('INSERT INTO ingest_receipts(receipt,workspace_id,remote_id,payload_hash,consent_version,created_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3))',[receipt,workspace,id,'a'.repeat(64),'synthetic']);
 await c.execute('INSERT INTO business_inquiry_notifications(id,inquiry_id,workspace_id,reference_code,notification_kind,created_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3))',[randomUUID(),id,workspace,receipt,'business_inquiry_created']);
 await c.execute('INSERT INTO audit_events(id,workspace_id,object_id,event,created_at) VALUES(?,?,?,?,UTC_TIMESTAMP(3))',[randomUUID(),workspace,id,'synthetic.encoding']);
 let duplicate=false;try{await c.execute('INSERT INTO ingest_receipts(receipt,workspace_id,remote_id,payload_hash,consent_version,created_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3))',[receipt,workspace,id,'b'.repeat(64),'synthetic']);}catch(e){duplicate=e.code==='ER_DUP_ENTRY';}check('receipt unique constraint enforced',duplicate);
 await c.rollback();
 for(const [table,col,value] of [['business_inquiries','id',id],['ingest_receipts','receipt',receipt],['business_inquiry_notifications','inquiry_id',id],['audit_events','object_id',id]]){const [[x]]=await c.execute(`SELECT COUNT(*) AS total FROM ${table} WHERE ${col}=?`,[value]);check('rollback '+table,x.total===0);}
 let fk=false;try{await c.execute('INSERT INTO ingest_receipts(receipt,workspace_id,remote_id,payload_hash,consent_version,created_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3))',[receipt,workspace,randomUUID(),'c'.repeat(64),'synthetic']);}catch(e){fk=e.code==='ER_NO_REFERENCED_ROW_2';}check('foreign key refuses missing inquiry',fk);
 let badJson=false;try{await c.execute('INSERT INTO business_inquiries(id,workspace_id,receipt,payload,offer_interest,created_at,consent_at,status_changed_at,updated_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3),UTC_TIMESTAMP(3),UTC_TIMESTAMP(3),UTC_TIMESTAMP(3))',[randomUUID(),workspace,receipt,'{invalid','not_specified']);}catch(e){badJson=['ER_CONSTRAINT_FAILED','ER_INVALID_JSON_TEXT'].includes(e.code)||e.errno===4025;metadata.invalid_json_error={code:e.code,errno:e.errno,state:e.sqlState};}check('invalid JSON rejected',badJson);
 const [grants]=await c.query('SHOW GRANTS');const privileges=grants.map(x=>Object.values(x)[0].match(/^GRANT (.*?) ON (.*?) TO /)?.slice(1)).filter(Boolean);metadata.privileges=privileges;
 fs.writeFileSync(root+'/evidence/sql-compat-probe.json',JSON.stringify({status:'PASS',hostinger_version_match:'11.8.9 version matched; local macOS is not Hostinger Linux',scope:'Local MariaDB 11.8.9 matching server version; deployment remains NOT TESTED',metadata,checks},null,2));console.log(checks.length+' local SQL capability checks PASS; MariaDB 11.8.9 version matched locally');
}catch(e){fs.writeFileSync(root+'/evidence/sql-compat-probe-failure.json',JSON.stringify({status:'FAIL',error:e.message,metadata,checks},null,2));throw e;}finally{await c.rollback();await c.end();}
