// Operator CLI only. No grant changes, no automatic recovery, no real-data import.
import mysql from 'mysql2/promise';import fs from 'node:fs';import path from 'node:path';import {createHash} from 'node:crypto';
const root=path.resolve('../..');const c=await mysql.createConnection({user:process.env.R4_DB_USER,password:process.env.R4_DB_PASSWORD,database:process.env.R4_DB_NAME,...(process.env.R4_DB_SOCKET?{socketPath:process.env.R4_DB_SOCKET}:{host:process.env.R4_DB_HOST??'127.0.0.1',port:3306}),multipleStatements:false});
try{
 const [[lock]]=await c.execute('SELECT GET_LOCK(?,10) AS acquired',['younew_r4_migrations']);if(lock.acquired!==1)throw new Error('Migration lock unavailable');
 let ledger=[];try{[ledger]=await c.execute('SELECT version,sha256 FROM schema_migrations');}catch(e){if(e.code!=='ER_NO_SUCH_TABLE')throw e;}
 for(const file of fs.readdirSync(root+'/db/migrations').filter(n=>/^\d+_.*\.sql$/.test(n)).sort()){
  const sql=fs.readFileSync(root+'/db/migrations/'+file,'utf8'),sha=createHash('sha256').update(sql).digest('hex'),prior=ledger.find(r=>r.version===file);
  if(prior){if(prior.sha256!==sha)throw new Error('Applied migration checksum mismatch: '+file);console.log(file+' VERIFIED_ALREADY_APPLIED');continue;}
  // Each file consists of simple, reviewed DDL statements; no delimiters or stored routines.
  for(const statement of sql.split(';').map(v=>v.trim()).filter(Boolean))await c.query(statement);
  await c.execute('INSERT INTO schema_migrations(version,sha256) VALUES(?,?)',[file,sha]);console.log(file+' APPLIED');
 }
}catch(e){console.error('Migration stopped:',e.code??e.message);process.exitCode=1;}finally{await c.execute('SELECT RELEASE_LOCK(?)',['younew_r4_migrations']).catch(()=>{});await c.end();}
