import 'server-only';
import {authorize} from './security';
async function readPublished(path:string){
 const origin=process.env.R4_CATALOG_PUBLIC_ORIGIN;
 if(!origin)throw new Error('Not configured');
 const u=new URL(origin);
 if(u.username||u.password||u.pathname!=='/'||u.search||u.hash||!(u.protocol==='https:'||origin==='http://127.0.0.1:4408'))throw new Error('Invalid catalog publication origin');
 const headers:Record<string,string>={};
 if(process.env.R4_CATALOG_STATUS_AUTH)headers.Authorization=process.env.R4_CATALOG_STATUS_AUTH;
 const r=await fetch(origin+path,{cache:'no-store',redirect:'error',headers,signal:AbortSignal.timeout(3000)});
 if(!r.ok)throw Error('Not observed');
 const text=await r.text();if(text.length>2000000)throw Error('Invalid response');return JSON.parse(text);
}
export async function publicCatalog(){
 const b=await readPublished('/api/catalog.json');
 if(b.schemaVersion!==1||b.localOnly!==true||!Array.isArray(b.entities))throw Error('Invalid published catalog');
 return b;
}
export async function publicationStatus(){
 await authorize('catalog.read');
 try{
  const b=await readPublished('/data/publication-status.json');
  if(b.schemaVersion!==1||!/^hp-[a-zA-Z0-9-]+$/.test(b.releaseId)||!Array.isArray(b.revisions)||!Number.isFinite(Date.parse(b.activatedAt))||b.revisions.some((x:{publicId:string;revision:number})=>!/^place\.synthetic-[a-f0-9-]{36}$/.test(x.publicId)||!Number.isInteger(x.revision)||x.revision<1))throw Error('Invalid status');
  return {available:true,observedAt:new Date().toISOString(),releaseId:b.releaseId,activatedAt:b.activatedAt,revisions:b.revisions};
 }catch{return {available:false,reason:'not_observed'};}
}
