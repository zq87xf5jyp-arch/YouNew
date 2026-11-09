// Build in a disposable workspace; only a validated complete release can replace current.json.
// No dependency installation, network service creation, DB mutation or remote deployment.
import * as fs from 'node:fs/promises';
import {constants} from 'node:fs';
import {resolve,dirname,join,relative} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash,randomUUID} from 'node:crypto';
import {spawn} from 'node:child_process';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const store=resolve(process.env.YOUNEW_PUBLICATION_ROOT||root+'/publication');
const endpoint=process.env.YOUNEW_LOCAL_CATALOG_API||'http://127.0.0.1:4404/api/r4/editorial/approved';
if(!['http://127.0.0.1:4404/api/r4/editorial/approved','https://qa-admin.younew.nl/api/r4/editorial/approved'].includes(endpoint))throw Error('Unapproved catalog endpoint');
if(!process.env.R4_CATALOG_BUILD_KEY&&endpoint.startsWith('http://127.0.0.1:')){const env=JSON.parse(await fs.readFile(root+'/backend/private/env.json','utf8'));process.env.R4_CATALOG_BUILD_KEY=env.R4_CATALOG_BUILD_KEY;}
if(!process.env.R4_CATALOG_BUILD_KEY)throw Error('Server build key required');
const hash=x=>createHash('sha256').update(typeof x==='string'||Buffer.isBuffer(x)?x:JSON.stringify(x)).digest('hex');
const startedAt=new Date().toISOString(),releaseId='hp-'+Date.now()+'-'+randomUUID().slice(0,8);
await fs.mkdir(store+'/releases',{recursive:true,mode:0o700});await fs.mkdir(store+'/logs',{recursive:true,mode:0o700});
const lock=store+'/build.lock';try{await fs.mkdir(lock);}catch(e){if(e.code==='EEXIST'){console.log('BUSY: another build holds the publication lock');process.exit(75);}throw e;}
await fs.writeFile(lock+'/owner.json',JSON.stringify({pid:process.pid,startedAt,releaseId}));
const stage=store+'/work-'+releaseId,release=store+'/releases/'+releaseId,logPath=store+'/logs/'+releaseId+'.log';
const record={releaseId,startedAt,status:'STARTED',endpoint};
async function snapshot(){const r=await fetch(endpoint,{headers:{Authorization:'Bearer '+process.env.R4_CATALOG_BUILD_KEY},redirect:'error',signal:AbortSignal.timeout(10000)});if(!r.ok)throw Error('Approval API unavailable');const b=await r.json();if(b.schemaVersion!==1||b.localOnly!==true||!Array.isArray(b.revisions)||!Array.isArray(b.entities)||b.entities.length!==b.revisions.length)throw Error('Invalid snapshot');for(const e of b.entities)if(!e.id.startsWith('place.synthetic-')||e.publicationStatus!=='published'||e.attributes?.synthetic!=='true')throw Error('Non-synthetic or draft entry');return b;}
async function run(command,args,cwd){const fd=await fs.open(logPath,'a',0o600);try{await new Promise((ok,bad)=>{const p=spawn(command,args,{cwd,env:{...process.env,NEXT_TELEMETRY_DISABLED:'1',YOUNEW_ATOMIC_BUILD:'1',NODE_BINARY:process.execPath,YOUNEW_LOCAL_NO_BUILD_CACHE:'1',YOUNEW_LOCAL_SOURCE_BASE_COMMIT:'484272957836615deb228d37c4e9d2ac0d9896a8',YOUNEW_LOCAL_CATALOG_API:endpoint,YOUNEW_APPROVED_SNAPSHOT_FILE:stage+'/snapshot.json'},stdio:['ignore',fd.fd,fd.fd]});p.once('error',bad);p.once('exit',code=>code===0?ok():bad(Error('Build exited '+code)));});}finally{await fd.close();}}
const excluded=new Set(['node_modules','.next','out','dist','.git','private','DerivedData']);
async function copy(from,to){await fs.cp(from,to,{recursive:true,mode:constants.COPYFILE_FICLONE,filter:p=>!relative(from,p).split('/').some(x=>excluded.has(x))});}
async function allFiles(dir){const result=[];for(const d of await fs.readdir(dir,{withFileTypes:true})){const p=join(dir,d.name);if(d.isSymbolicLink())throw Error('Output symlink forbidden');if(d.isDirectory())result.push(...await allFiles(p));else result.push(p);}return result;}
try{
 const batch=await snapshot();record.snapshotSha256=hash(batch);
 let previous;try{previous=JSON.parse(await fs.readFile(store+'/current.json','utf8'));}catch(e){if(e.code!=='ENOENT')throw e;}
 if(process.argv.includes('--if-changed')&&previous?.snapshotSha256===record.snapshotSha256){record.status='UNCHANGED';console.log('UNCHANGED: approval snapshot already active');}
 else{
  await fs.mkdir(stage,{recursive:true,mode:0o700});
  await copy(root+'/source',stage+'/source');await copy(root+'/tools',stage+'/tools');
  await fs.mkdir(stage+'/backend/db',{recursive:true});await fs.copyFile(root+'/backend/db/catalog-drafts.json',stage+'/backend/db/catalog-drafts.json');
  await fs.writeFile(stage+'/snapshot.json',JSON.stringify(batch));
  for(const rel of ['source/admin-dashboard','source/admin-dashboard/public-site']){
   const dep=root+'/'+rel+'/node_modules';try{await fs.access(dep);await fs.symlink(dep,stage+'/'+rel+'/node_modules','dir');}catch(e){if(e.code!=='ENOENT')throw e;}
  }
  // Explicit local negative test. It executes a failed build subprocess in the
  // staging directory, never changes the active output and is forbidden remotely.
  if(process.env.YOUNEW_TEST_BUILD_FAILURE==='1'){
   if(endpoint!=='http://127.0.0.1:4404/api/r4/editorial/approved')throw Error('Fault injection is local-only');
   await run(process.execPath,['-e','console.error("Synthetic staged build failure");process.exit(42)'],stage);
  }
  // Large immutable media need not be recopied by Next during page generation.
  const deferred=[];const publicRoot=stage+'/source/admin-dashboard/public-site/public';
  for(const p of await allFiles(publicRoot)){const st=await fs.stat(p);if(st.size>1024*1024 && /\.(mp4|webm|zip|pdf)$/.test(p)){deferred.push(relative(publicRoot,p));await fs.unlink(p);}}
  await run('/bin/bash',['scripts/build.sh'],stage+'/source/admin-dashboard/public-site');
  const out=stage+'/source/admin-dashboard/public-site/out';
  for(const rel of deferred){await fs.mkdir(dirname(out+'/'+rel),{recursive:true});await fs.copyFile(root+'/source/admin-dashboard/public-site/public/'+rel,out+'/'+rel,constants.COPYFILE_FICLONE);}
  record.deferredMedia=deferred;
  for(const path of ['index.html','sitemap.xml','data/search-index.json'])await fs.access(out+'/'+path);
  const draft=JSON.parse(await fs.readFile(root+'/backend/db/catalog-drafts.json','utf8')).entities;
  const files=await allFiles(out);let scanned=0;
  for(const p of files)if(/\.(html|json|xml|js|txt)$/.test(p)){const t=await fs.readFile(p,'utf8');for(const d of draft)if(t.includes(d.id))throw Error('Real draft leaked into output');scanned++;}
  if(hash(await snapshot())!==record.snapshotSha256)throw Error('Approval snapshot changed during build; old release retained');
  await fs.copyFile(stage+'/evidence/approved-runtime.json',out+'/data/younew-runtime-data.json');
  // Dedicated isolated origin: network-only SW, no offline copies of withdrawn
  // content. Already open documents still need a reload after activation.
  await fs.writeFile(out+'/sw.js',"self.addEventListener('install',()=>self.skipWaiting());self.addEventListener('activate',e=>e.waitUntil(self.clients.claim()));self.addEventListener('fetch',e=>{if(e.request.method==='GET')e.respondWith(fetch(new Request(e.request,{cache:'no-store'})));});\n");
  await fs.mkdir(out+'/api',{recursive:true});await fs.writeFile(out+'/api/catalog.json',JSON.stringify(batch)+'\n');
  const manifest={schemaVersion:1,releaseId,snapshotSha256:record.snapshotSha256,activatedAt:new Date().toISOString(),revisions:batch.revisions,localOnly:true};
  await fs.writeFile(out+'/data/publication-status.json',JSON.stringify(manifest,null,2)+'\n');
  const sums=[];for(const p of await allFiles(out))sums.push(hash(await fs.readFile(p))+'  '+relative(out,p));
  await fs.mkdir(release,{mode:0o700});await fs.rename(out,release+'/out');await fs.writeFile(release+'/SHA256SUMS.txt',sums.sort().join('\n')+'\n');
  // A small pointer on the same filesystem is the sole activation boundary.
  const pending=store+'/current.'+releaseId+'.json';await fs.writeFile(pending,JSON.stringify(manifest,null,2)+'\n',{mode:0o600});await fs.rename(pending,store+'/current.json');
  Object.assign(record,{status:'PASS',activatedAt:manifest.activatedAt,previousRelease:previous?.releaseId||null,scannedFiles:scanned,outputFiles:sums.length,revisions:batch.revisions});
  console.log('Activated '+releaseId+'; '+batch.revisions.length+' approved synthetic places.');
 }
}catch(e){record.status='FAIL';record.error=e.message;console.error(e.message);process.exitCode=1;}
finally{
 record.finishedAt=new Date().toISOString();record.seconds=(Date.parse(record.finishedAt)-Date.parse(startedAt))/1000;
 await fs.writeFile(store+'/logs/'+releaseId+'.json',JSON.stringify(record,null,2)+'\n');
 // Only this invocation's new staging workspace is disposable. Releases/logs survive.
 await fs.rm(stage,{recursive:true,force:true});await fs.rm(lock,{recursive:true});
}
