import 'server-only';
import {randomBytes,randomUUID,createHmac} from 'node:crypto';
import {db,rows,transaction} from './db';
import {authorize,mutationGuard,Denied,hash} from './security';
import {isInquiryId} from '../business-inquiry-compatibility';
async function storage(operation:'read'|'write',key:string,data?:string){
 const url=process.env.R4_FILES_URL,secret=process.env.R4_FILES_KEY;if(!url||!secret||secret.length<64)throw new Error('File configuration');const u=new URL(url);if(u.protocol!=='https:' && !(process.env.R4_LOCAL==='true'&&url==='http://127.0.0.1:4408/private-files.php'))throw new Error('File origin');
 const body=JSON.stringify({operation,key,...(data?{data}:{})}),ts=String(Math.floor(Date.now()/1000)),nonce=randomBytes(32).toString('hex');
 const signature=createHmac('sha256',secret).update([ts,nonce,hash(body)].join('\n')).digest('hex');
 const r=await fetch(url,{method:'POST',headers:{'content-type':'application/json','x-r4-time':ts,'x-r4-nonce':nonce,'x-r4-signature':signature},body,redirect:'error',signal:AbortSignal.timeout(5000),cache:'no-store'});if(!r.ok)throw new Error('File unavailable');return r.json();
}
export async function readFile(id:string){const a=await authorize('files.read');if(!isInquiryId(id))throw new Denied(404,'not_found');const [f]=await rows(db(),'SELECT f.storage_key,f.sha256,f.bytes FROM private_files f JOIN business_inquiries i ON i.id=f.inquiry_id AND i.workspace_id=f.workspace_id WHERE f.id=? AND f.workspace_id=?',[id,a.workspace_id]);if(!f)throw new Denied(404,'not_found');const r=await storage('read',f.storage_key);const data=Buffer.from(r.data??'','base64');if(data.length!==f.bytes||hash(data)!==f.sha256)throw new Error('File integrity');return data;}
export async function writeFile(value:unknown){const input=value as Record<string,unknown>;await mutationGuard();return transaction(async c=>{
 const a=await authorize('files.write',c,true);if(!input||Object.keys(input).some(k=>!['inquiryId','data'].includes(k))||!isInquiryId(input.inquiryId)||typeof input.data!=='string'||input.data.length>1400000||!/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(input.data))throw new Denied(400,'invalid_file');
 const [i]=await rows(c,'SELECT id FROM business_inquiries WHERE id=? AND workspace_id=? FOR UPDATE',[input.inquiryId,a.workspace_id]);if(!i)throw new Denied(404,'not_found');
 const data=Buffer.from(input.data,'base64');if(!data.length||data.length>1048576)throw new Denied(400,'invalid_file');const id=randomUUID(),storageKey=randomUUID();
 await storage('write',storageKey,input.data);
 await c.execute('INSERT INTO private_files(id,workspace_id,inquiry_id,storage_key,mime,sha256,bytes) VALUES(?,?,?,?,?,?,?)',[id,a.workspace_id,i.id,storageKey,'application/octet-stream',hash(data),data.length]);
 await c.execute('INSERT INTO audit_events(id,workspace_id,actor_id,object_id,event,created_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3))',[randomUUID(),a.workspace_id,a.id,id,'file.added']);return {id};
 });}
