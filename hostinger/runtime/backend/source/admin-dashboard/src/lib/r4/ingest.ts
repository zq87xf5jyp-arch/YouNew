import 'server-only';
import {createHmac,randomUUID,timingSafeEqual} from 'node:crypto';
import {db,rows,transaction} from './db';
import {Denied,hash} from './security';
import {envelopeSchema} from './payload';
function canonical(v:unknown):string{return v===null||typeof v!=='object'?JSON.stringify(v):Array.isArray(v)?'['+v.map(canonical).join(',')+']':'{'+Object.keys(v).sort().map(k=>JSON.stringify(k)+':'+canonical((v as Record<string,unknown>)[k])).join(',')+'}';}
export async function ingest(body:string,h:Headers){
 const ts=h.get('x-r4-time')??'',nonce=h.get('x-r4-nonce')??'',signature=h.get('x-r4-signature')??'',key=process.env.R4_INGEST_KEY;
 if(!key||key.length<64)throw new Error('Ingest configuration');
 if(!/^\d{10}$/.test(ts)||Math.abs(Date.now()/1000-Number(ts))>120||!/^[a-f0-9]{64}$/.test(nonce)||!/^[a-f0-9]{64}$/.test(signature))throw new Denied(401,'ingest_auth_required');
 const expected=createHmac('sha256',key).update(['POST','/api/r4/ingest/business',ts,nonce,hash(body)].join('\n')).digest();
 if(!timingSafeEqual(expected,Buffer.from(signature,'hex')))throw new Denied(401,'ingest_auth_required');
 await db().execute('DELETE FROM ingest_nonces WHERE expires_at<UTC_TIMESTAMP(3) LIMIT 100');
 try{await db().execute('INSERT INTO ingest_nonces(nonce,expires_at) VALUES(?,DATE_ADD(UTC_TIMESTAMP(3),INTERVAL 5 MINUTE))',[nonce]);}catch(e){if((e as {code?:string}).code==='ER_DUP_ENTRY')throw new Denied(409,'replay_denied');throw e;}
 let raw;try{raw=JSON.parse(body);}catch{throw new Denied(400,'invalid_payload');}const parsed=envelopeSchema.safeParse(raw);if(!parsed.success)throw new Denied(400,'invalid_payload');
 const x=parsed.data,w=process.env.R4_INGEST_WORKSPACE;if(!w)throw new Error('Ingest workspace required');const payloadHash=hash(canonical(x));
 for(let attempt=0;attempt<3;attempt++){
  try{return await transaction(async c=>{
   const id=randomUUID(),created=new Date(x.p_created_at),p=x.p_payload;
   await c.execute('INSERT INTO business_inquiries(id,workspace_id,receipt,payload,contact_role,offer_interest,created_at,consent_at,status_changed_at,updated_at) VALUES(?,?,?,?,?,?,?,?,?,UTC_TIMESTAMP(3))',[id,w,x.p_receipt,JSON.stringify(p),p.contactRole||null,p.offerInterest,created,created,created]);
   await c.execute('INSERT INTO ingest_receipts(receipt,workspace_id,remote_id,payload_hash,consent_version,created_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3))',[x.p_receipt,w,id,payloadHash,x.p_consent_version]);
   await c.execute('INSERT INTO business_inquiry_notifications(id,inquiry_id,workspace_id,reference_code,notification_kind,created_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3))',[randomUUID(),id,w,x.p_receipt,'business_inquiry_created']);
   await c.execute('INSERT INTO audit_events(id,workspace_id,actor_id,object_id,event,created_at) VALUES(?,?,NULL,?,?,UTC_TIMESTAMP(3))',[randomUUID(),w,id,'inquiry.ingested']);
   return [{receipt:x.p_receipt,remote_id:id}];
  });}catch(e){
   if((e as {code?:string}).code==='ER_DUP_ENTRY'){const [r]=await rows(db(),'SELECT remote_id,payload_hash FROM ingest_receipts WHERE receipt=? AND workspace_id=?',[x.p_receipt,w]);if(!r)throw new Denied(503,'retry_later');if(r.payload_hash!==payloadHash)throw new Denied(409,'receipt_conflict');return [{receipt:x.p_receipt,remote_id:r.remote_id}];}
   if(['ER_LOCK_DEADLOCK','ER_LOCK_WAIT_TIMEOUT'].includes((e as {code?:string}).code??'')&&attempt<2)continue;throw e;
  }
 }
 throw new Denied(503,'retry_later');
}
