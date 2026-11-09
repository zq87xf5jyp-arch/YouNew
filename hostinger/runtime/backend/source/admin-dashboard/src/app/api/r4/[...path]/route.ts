import {publicationStatus,publicCatalog} from '@/lib/r4/publication';
import {catalogList,catalogGet,catalogCreate,catalogEdit,catalogTransition,approvedCatalog} from '@/lib/r4/catalog';
import {NextResponse} from 'next/server';
import {login,logout,signedIn,safeError,Denied} from '@/lib/r4/security';
import {listInquiries,getInquiry,updateInquiry,notifications,updateNotification,audit} from '@/lib/r4/repository';
import {readFile,writeFile} from '@/lib/r4/files';
import {ingest} from '@/lib/r4/ingest';
export const runtime='nodejs'; export const dynamic='force-dynamic';
const responseHeaders={'Cache-Control':'no-store, private','X-Content-Type-Options':'nosniff'};
async function textBody(req:Request,maximum=32768){const reader=req.body?.getReader();if(!reader)return '';let size=0;const chunks=[];while(true){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>maximum){await reader.cancel();throw new Denied(413,'too_large');}chunks.push(Buffer.from(value));}return Buffer.concat(chunks).toString('utf8');}
function form(body:unknown){if(!body||typeof body!=='object'||Array.isArray(body))throw new Denied(400,'invalid_update');const f=new FormData();for(const [k,v] of Object.entries(body)){if(typeof v!=='string')throw new Denied(400,'invalid_update');f.append(k,v);}return f;}
async function handle(req:Request,{params}:{params:Promise<{path:string[]}>}){try{
 const path=(await params).path.join('/'),method=req.method;let result;
 if(method==='GET'&&path==='editorial/approved')result=await approvedCatalog(req.headers);
 else if(method==='GET'&&path==='public/catalog')result=await publicCatalog();
 else if(method==='GET'&&path==='catalog/publication-status')result=await publicationStatus();
 else if(method==='GET'&&path==='catalog')result=await catalogList();
 else if(method==='POST'&&path==='catalog')result=await catalogCreate(JSON.parse(await textBody(req)));
 else if(method==='GET'&&/^catalog\/[^/]+$/.test(path))result=await catalogGet(path.split('/')[1]);
 else if(method==='PATCH'&&/^catalog\/[^/]+$/.test(path))result=await catalogEdit(path.split('/')[1],JSON.parse(await textBody(req)));
 else if(method==='POST'&&/^catalog\/[^/]+\/transition$/.test(path))result=await catalogTransition(path.split('/')[1],JSON.parse(await textBody(req)));
 else if(method==='POST'&&path==='ingest/business') result=await ingest(await textBody(req),req.headers);
 else if(method==='POST'&&path==='login'){const b=JSON.parse(await textBody(req));if(Object.keys(b).some(k=>!['email','password'].includes(k)))throw new Denied(400,'invalid_request');result=await login(b.email,b.password);}
 else if(method==='POST'&&path==='logout'){await logout();result={ok:true};}
 else if(method==='GET'&&path==='me') result=await signedIn();
 else if(method==='GET'&&path==='inquiries')result=await listInquiries();
 else if(method==='GET'&&/^inquiries\/[^/]+$/.test(path))result=await getInquiry(path.split('/')[1]);
 else if(method==='PATCH'&&/^inquiries\/[^/]+$/.test(path)){const f=form(JSON.parse(await textBody(req)));if(f.get('id')!==path.split('/')[1])throw new Denied(400,'id_mismatch');result=await updateInquiry(f);}
 else if(method==='GET'&&path==='notifications')result=await notifications();
 else if(method==='PATCH'&&path==='notifications')result=await updateNotification(form(JSON.parse(await textBody(req))));
 else if(method==='GET'&&path==='audit')result=await audit();
 else if(method==='POST'&&path==='files')result=await writeFile(JSON.parse(await textBody(req,1400200)));
 else if(method==='GET'&&/^files\/[^/]+$/.test(path)){const b=await readFile(path.split('/')[1]);return new Response(new Uint8Array(b),{headers:{...responseHeaders,'Content-Type':'application/octet-stream','Content-Disposition':'attachment; filename="younew-private-attachment.bin"'}});}
 else {await signedIn();throw new Denied(404,'not_found');}
 return NextResponse.json(result,{headers:responseHeaders});
 }catch(e){const r=e instanceof SyntaxError?{status:400,body:{error:'invalid_json'}}:safeError(e);return NextResponse.json(r.body,{status:r.status,headers:responseHeaders});}}
export {handle as GET,handle as POST,handle as PATCH,handle as DELETE,handle as PUT};
