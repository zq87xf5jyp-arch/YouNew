// OPERATOR ONLY, after explicit approval of the new isolated DB. Never part of app start/build/cron.
import mysql from 'mysql2/promise';
import * as fs from 'node:fs/promises';import {createHash,randomUUID,randomBytes,scryptSync} from 'node:crypto';
import {dirname,resolve} from 'node:path';import {fileURLToPath} from 'node:url';
if(process.argv[2]!=='--apply'||process.env.R4_DB_NAME!=='u246392949_younq1'||process.env.R4_DB_HOST!=='127.0.0.1'||process.env.R4_LOCAL!=='false')throw Error('Explicit isolated Hostinger initialization required');
const dir=dirname(fileURLToPath(import.meta.url));
const privateRoot='/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1';
await fs.access(privateRoot+'/logs');
try{await fs.access(privateRoot+'/synthetic-users.json');throw Error('Existing seed never overwritten');}catch(e){if(e.code!=='ENOENT')throw e;}
const c=await mysql.createConnection({host:'127.0.0.1',port:3306,user:process.env.R4_DB_USER,password:process.env.R4_DB_PASSWORD,database:process.env.R4_DB_NAME,charset:'utf8mb4_unicode_ci',multipleStatements:false});
try{
 const [[v]]=await c.query('SELECT VERSION() AS version');if(!v.version.startsWith('11.8.9-'))throw Error('Recheck compatibility for changed MariaDB version');
 const [tables]=await c.execute('SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA=?',[process.env.R4_DB_NAME]);if(tables.length)throw Error('New empty QA database required; no reset or migration recovery attempted');
 await c.query("SET SESSION sql_mode='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION',time_zone='+00:00'");
 for(const file of (await fs.readdir(dir+'/migrations')).filter(x=>/^\d+_.*\.sql$/.test(x)).sort()){
  const sql=await fs.readFile(dir+'/migrations/'+file,'utf8');for(const statement of sql.split(';').map(s=>s.trim()).filter(Boolean))await c.query(statement);
  await c.execute('INSERT INTO schema_migrations(version,sha256) VALUES(?,?)',[file,createHash('sha256').update(sql).digest('hex')]);
 }
 const encode=p=>{const salt=randomBytes(16).toString('hex');return 'scrypt32768$'+salt+'$'+scryptSync(p,salt,64,{N:32768,r:8,p:1,maxmem:64*1024*1024}).toString('hex');};
 const spaces=['11111111-1111-4111-8111-111111111111','22222222-2222-4222-8222-222222222222'];const users={};
 await c.beginTransaction();
 for(let i=0;i<spaces.length;i++)await c.execute('INSERT INTO workspaces(id,name) VALUES(?,?)',[spaces[i],'Synthetic Hostinger QA '+i]);
 for(const [name,role,approved,blocked,w] of [['owner','owner',1,0,0],['admin','admin',1,0,0],['editor','editor',1,0,0],['viewer','viewer',1,0,0],['qa','qa',1,0,0],['pending','admin',0,0,0],['blocked','admin',1,1,0],['other','admin',1,0,1]]){
  const id=randomUUID(),password=randomBytes(24).toString('hex');users[name]={id,email:name+'@example.invalid',password,workspace:spaces[w]};
  await c.execute('INSERT INTO profiles(id,workspace_id,email,full_name,password_hash,role,is_approved,is_blocked) VALUES(?,?,?,?,?,?,?,?)',[id,spaces[w],users[name].email,'Synthetic '+name,encode(password),role,approved,blocked]);
 }
 // The 14 real drafts are deliberately NOT imported into the server acceptance DB.
 await fs.writeFile(privateRoot+'/synthetic-users.json',JSON.stringify({users,dummyHash:encode(randomBytes(24).toString('hex'))}),{mode:0o600,flag:'wx'});
 await c.commit();console.log('QA migrations and eight synthetic accounts created. Secrets remain in private file; set dummyHash in the managed app environment, then restart.');
}catch(e){await c.rollback().catch(()=>{});console.error('Initialization stopped:',e.code||e.message);process.exitCode=1;}finally{await c.end();}
