// Exercise the real built HTTP application without any DB configuration.
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {createServer} from 'node:net';
import {setTimeout} from 'node:timers/promises';

const listener=createServer();
await new Promise(resolve=>listener.listen(0,'127.0.0.1',resolve));
const port=listener.address().port;
await new Promise(resolve=>listener.close(resolve));
const env={...process.env,NODE_ENV:'production',NEXT_TELEMETRY_DISABLED:'1'};
for(const key of Object.keys(env))if(key.startsWith('R4_')||key==='YOUNEW_RUNTIME_ENV_FILE')delete env[key];
const server=spawn(process.execPath,['node_modules/next/dist/bin/next','start','-H','127.0.0.1','-p',String(port)],{env,stdio:'ignore'});
const base=`http://127.0.0.1:${port}`;
try{
 let ready=false;
 for(let n=0;n<60;n++){
  if(server.exitCode!==null)throw Error('HTTP test server exited');
  try{ready=(await fetch(base+'/login')).status===200;}catch{}
  if(ready)break;
  await setTimeout(250);
 }
 assert.ok(ready,'Login page must render without DB configuration');
 const dashboard=await fetch(base+'/dashboard',{redirect:'manual'});
 assert.equal(dashboard.status,307);
 assert.equal(dashboard.headers.get('location'),'/login');
 for(const cookie of ['', 'younew_hostprep_session=malformed']){
  for(const route of ['/api/r4/me','/api/r4/inquiries','/api/r4/catalog']){
   const response=await fetch(base+route,{headers:{cookie}});
   assert.equal(response.status,401,route);
   assert.deepEqual(await response.json(),{error:'authentication_required'});
   assert.match(response.headers.get('cache-control'),/no-store/);
   assert.match(response.headers.get('x-robots-tag'),/noindex/);
  }
 }
 const unavailable=await fetch(base+'/api/r4/me',{headers:{cookie:'younew_hostprep_session='+'a'.repeat(64)}});
 assert.equal(unavailable.status,503,'A plausible session still requires the unavailable DB');
 assert.deepEqual(await unavailable.json(),{error:'service_unavailable'});
 console.log('PASS: login renders; anonymous and malformed sessions are denied before DB access; plausible sessions fail closed; private responses are not cached.');
}finally{
 server.kill('SIGTERM');
 await new Promise(resolve=>server.exitCode!==null?resolve():server.once('exit',resolve));
}
