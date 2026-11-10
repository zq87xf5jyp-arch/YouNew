import assert from 'node:assert/strict';
import * as fs from 'node:fs/promises';
import {createRequire} from 'node:module';
import {execFileSync} from 'node:child_process';
import {createHash,createHmac,randomBytes,randomUUID} from 'node:crypto';
const root='/home/u246392949/domains/younew.nl/younew-private/launch-production';
const e=process.env,phase=process.argv[2];assert.ok(['start','observe'].includes(phase));
assert.equal(e.R4_DB_NAME,'u246392949_younp1');assert.equal(e.R4_RUNTIME_MODE,'production');assert.equal(e.R4_ORIGIN,'https://admin.younew.nl');
const mysql=createRequire(process.cwd()+'/package.json')('mysql2/promise');let c;
try{
 const active=JSON.parse(await fs.readFile(root+'/production-active-release.json','utf8'));assert.equal(active.status,'ACTIVE');
 c=await mysql.createConnection({host:e.R4_DB_HOST,user:e.R4_DB_USER,password:e.R4_DB_PASSWORD,database:e.R4_DB_NAME,connectTimeout:5000});
 const counts={};for(const table of ['profiles','business_inquiries','ingest_receipts','business_inquiry_notifications','legacy_assets','legacy_rows']){const [[r]]=await c.query('SELECT COUNT(*) AS n FROM `'+table+'`');counts[table]=r.n;}
 const [profiles]=await c.query('SELECT id,workspace_id,email,full_name,password_hash,role,is_approved,is_blocked FROM profiles ORDER BY id');
 const profileSha256=createHash('sha256').update(JSON.stringify(profiles)).digest('hex');
 assert.equal(counts.profiles,4);assert.equal(counts.legacy_assets,1);
 const sqlite=JSON.parse(execFileSync('python3',['-c',`import sqlite3,json\np='/home/u246392949/domains/younew.nl/younew-private/forms-data/submissions.sqlite'\nwith sqlite3.connect('file:'+p+'?mode=ro',uri=True) as c:\n tables=[r[0] for r in c.execute("select name from sqlite_master where type='table'")]\n print(json.dumps({'counts':dict(c.execute('select kind,count(*) from submissions group by kind')),'businessIds':[r[0] for r in c.execute("select id from submissions where kind='business' order by id")],'receipts':c.execute('select count(*) from delivery_receipts').fetchone()[0] if 'delivery_receipts' in tables else 0,'integrity':c.execute('pragma integrity_check').fetchone()[0]}))`],{encoding:'utf8'}));
 assert.equal(sqlite.integrity,'ok');assert.ok(sqlite.counts.business>=4);assert.ok(sqlite.counts.feedback>=1);
 const checks=[];
 for(const path of ['/api/r4/me','/api/r4/catalog','/api/r4/editorial/approved']){const r=await fetch(e.R4_ORIGIN+path);assert.equal(r.status,401);assert.ok(r.headers.get('cache-control').includes('no-store'));checks.push({path,status:r.status,noStore:true});}
 if(phase==='start'){
  assert.equal(counts.business_inquiries,3);assert.equal(counts.ingest_receipts,0);
  const body=JSON.stringify({operation:'read',key:randomUUID()}),ts=String(Math.floor(Date.now()/1000)),nonce=randomBytes(32).toString('hex');
  const sig=createHmac('sha256',e.R4_FILES_KEY).update(ts+'\n'+nonce+'\n'+createHash('sha256').update(body).digest('hex')).digest('hex');
  const r=await fetch(e.R4_FILES_URL,{method:'POST',headers:{'Content-Type':'application/json','X-R4-Time':ts,'X-R4-Nonce':nonce,'X-R4-Signature':sig},body});assert.equal(r.status,404);assert.ok(r.headers.get('cache-control').includes('no-store'));
  checks.push({path:'/api/private-files.php',signedReadMissingFile:404,noFakeFileCreated:true});
  const report={status:'READY_AND_RESUMED',at:new Date().toISOString(),commit:active.commit,counts,profileSha256,sqlite,checks};
  await fs.writeFile(root+'/production-business-start.private.json',JSON.stringify(report,null,2)+'\n',{flag:'wx',mode:0o600});
  await fs.rename(root+'/PRODUCTION_BUSINESS_PAUSED',root+'/PRODUCTION_BUSINESS_PRELAUNCH_PAUSE.saved');
  console.log(JSON.stringify({...report,sqlite:{counts:sqlite.counts,receipts:sqlite.receipts,integrity:sqlite.integrity}}));
 }else{
  const before=JSON.parse(await fs.readFile(root+'/production-business-start.private.json','utf8'));assert.equal(before.profileSha256,profileSha256);
  const results=[];for(const receipt of before.sqlite.businessIds){const [[r]]=await c.query('SELECT (SELECT COUNT(*) FROM business_inquiries WHERE receipt=?) AS inquiries,(SELECT COUNT(*) FROM ingest_receipts WHERE receipt=?) AS receipts,(SELECT COUNT(*) FROM business_inquiry_notifications WHERE reference_code=?) AS notifications',[receipt,receipt,receipt]);results.push(r);}
  const log=await fs.readFile(root+'/logs/business-cron.jsonl','utf8').catch(()=> '');const events=log.trim().split('\n').filter(Boolean).map(x=>JSON.parse(x));
  const complete=results.every(r=>r.inquiries===1&&r.receipts===1&&r.notifications===1)&&sqlite.receipts>=before.sqlite.businessIds.length;
  const report={status:complete?'PASS':'PENDING',at:new Date().toISOString(),commit:active.commit,counts,profileHashesAndRolesUnchanged:true,sqlite:{counts:sqlite.counts,receipts:sqlite.receipts,integrity:sqlite.integrity},baselineBusiness:before.sqlite.businessIds.length,baselineResults:results,completedScheduledRuns:events.filter(x=>x.event==='cron_end').length,events:events.map(({receipt,...safe})=>safe),checks};
  await fs.writeFile(root+'/production-business-observed.json',JSON.stringify(report,null,2)+'\n',{mode:0o600});console.log(JSON.stringify(report));
 }
}catch(error){console.error(JSON.stringify({status:'STOPPED',phase,errorType:error.name,code:error.code??'CHECK_FAILED',message:error.name==='AssertionError'?error.message:undefined}));process.exitCode=1;}finally{await c?.end();}
