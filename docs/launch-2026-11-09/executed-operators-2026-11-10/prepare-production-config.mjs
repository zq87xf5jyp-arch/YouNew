// Prepare disconnected private runtime state. Does not edit hPanel or public_html.
import assert from 'node:assert/strict';
import * as fs from 'node:fs/promises';
import {randomBytes,scryptSync,createHash} from 'node:crypto';
import {createRequire} from 'node:module';
const source='/home/u246392949/domains/qa-catalog.younew.nl/younew-private/launch-source';
const root='/home/u246392949/domains/younew.nl/younew-private/launch-production';
const admin='/home/u246392949/domains/admin.younew.nl/younew-private';
const e=process.env,sha=v=>createHash('sha256').update(v).digest('hex');
let connection,phase='guard';
try {
 assert.equal(e.R4_DB_NAME,'u246392949_younp1');assert.equal(e.R4_DB_USER,e.R4_DB_NAME);
 assert.equal(e.R4_DB_HOST,'127.0.0.1');assert.equal(e.R4_LOCAL,'false');
 const restore=JSON.parse(await fs.readFile(root+'/backup-restore-result.json','utf8'));
 assert.equal(restore.status,'PASS');assert.equal(restore.database,e.R4_DB_NAME);
 const mysql=createRequire(process.cwd()+'/package.json')('mysql2/promise');
 connection=await mysql.createConnection({host:e.R4_DB_HOST,user:e.R4_DB_USER,password:e.R4_DB_PASSWORD,database:e.R4_DB_NAME,connectTimeout:5000});
 const [[sessions]]=await connection.query('SELECT COUNT(*) AS n FROM sessions');assert.equal(sessions.n,0);
 const [[receipts]]=await connection.query('SELECT COUNT(*) AS n FROM ingest_receipts');assert.equal(receipts.n,0);
 await connection.end();connection=null;
 const migration=await fs.readFile(root+'/migration.env','utf8');
 const drafts=await fs.readFile(source+'/hostinger/runtime/backend/db/catalog-drafts.json');
 const entities=JSON.parse(drafts).entities;assert.equal(entities.length,71);assert.ok(entities.every(x=>x.publicationStatus==='draft'&&x.attributes?.synthetic!=='true'));
 phase='private-preparation';
 await fs.mkdir(admin,{mode:0o700});
 await fs.writeFile(root+'/editorial-drafts.json',drafts,{flag:'wx',mode:0o600});
 const ingest=randomBytes(48).toString('hex'),files=randomBytes(48).toString('hex'),salt=randomBytes(16).toString('hex');
 const dummy='scrypt32768$'+salt+'$'+scryptSync(randomBytes(48),salt,64,{N:32768,r:8,p:1,maxmem:64*1024*1024}).toString('hex');
 const extra={R4_RUNTIME_MODE:'production',R4_ORIGIN:'https://admin.younew.nl',R4_INGEST_WORKSPACE:'b8813c64-a7b8-49aa-a10b-89eea40c9769',R4_INGEST_KEY:ingest,R4_FILES_KEY:files,R4_FILES_URL:'https://younew.nl/api/private-files.php',R4_DUMMY_PASSWORD_HASH:dummy,R4_EDITORIAL_DRAFTS_FILE:root+'/editorial-drafts.json'};
 await fs.writeFile(admin+'/launch.env',migration+(migration.endsWith('\n')?'':'\n')+Object.entries(extra).map(([k,v])=>k+'='+v).join('\n')+'\n',{flag:'wx',mode:0o600});
 const service=root+'/file-service-cf6ab6f';
 await fs.mkdir(service,{mode:0o700});
 for(const p of ['public','private','private/files','private/files-data'])await fs.mkdir(service+'/'+p,{mode:0o700});
 const fileCode=await fs.readFile(source+'/hostinger/runtime/backend/php/public/private-files.php');
 await fs.writeFile(service+'/public/private-files.php',fileCode,{flag:'wx',mode:0o600});
 await fs.writeFile(service+'/private/files/config.php',"<?php return ['key'=>'"+files+"'];\n",{flag:'wx',mode:0o600});
 // This config is staged only. The running forms-v1 service and queue are untouched.
 await fs.writeFile(root+'/business-sync-config.php',"<?php return ['url'=>'https://admin.younew.nl','ingestKey'=>'"+ingest+"','local'=>false,'documentRoot'=>'/home/u246392949/domains/younew.nl/public_html'];\n",{flag:'wx',mode:0o600});
 const report={status:'PREPARED_NOT_ACTIVE',at:new Date().toISOString(),runtimeEnv:admin+'/launch.env',database:e.R4_DB_NAME,mode:'production',drafts:entities.length,draftsSha256:sha(drafts),fileCodeSha256:sha(fileCode),credentialsCopiedFromQa:false,publicHtmlChanged:false,hpanelChanged:false,queueChanged:false};
 await fs.writeFile(root+'/production-config-result.json',JSON.stringify(report,null,2)+'\n',{flag:'wx',mode:0o600});
 console.log(JSON.stringify(report));
}catch(error){console.error(JSON.stringify({status:'STOPPED',phase,code:error.code??'GUARD_OR_VERIFICATION_FAILED'}));process.exitCode=1;}
finally{await connection?.end();}
