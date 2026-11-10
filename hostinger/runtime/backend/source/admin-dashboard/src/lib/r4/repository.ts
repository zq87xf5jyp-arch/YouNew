import 'server-only';
import type {RowDataPacket} from 'mysql2/promise';
import {randomUUID} from 'node:crypto';
import {db,rows,transaction} from './db';
import {authorize,mutationGuard,Denied} from './security';
import {parseInquiryUpdate,CURRENT_INQUIRY_SCHEMA,verifyInquiryUpdate,isInquiryId} from '../business-inquiry-compatibility';
const date=(v:string|null)=>v==null?null:new Date(String(v).replace(' ','T')+(/Z$/.test(String(v))?'':'Z')).toISOString();
function dto(r:RowDataPacket):Record<string,unknown>{
 const p=typeof r.payload==='string'?JSON.parse(r.payload):r.payload;
 const map:Record<string,string>={company_name:'companyName',contact_person:'contactPerson',email:'email',phone:'phone',website:'website',inquiry_type:'inquiryType',organization_type:'organizationType',kvk_number:'kvkNumber',city:'city',province:'province',target_audience:'targetAudience',requested_placements:'requestedPlacements',campaign_goal:'campaignGoal',budget_range:'budgetRange',campaign_start:'campaignStart',campaign_end:'campaignEnd',message:'description',source_page:'sourcePage'};
 const out:Record<string,unknown>={};for(const [k,v] of Object.entries(map))out[k]=p[v];
 for(const k of ['id','status','admin_notes','handled_by','contact_role','offer_interest','lost_reason','lost_reason_detail','won_evidence_type'])out[k]=r[k];
 for(const k of ['won_evidence_at','created_at','consent_at','status_changed_at','updated_at'])out[k]=date(r[k]);
 return {...out,reference_code:r.receipt,legacy_status:r.legacy_status??null};
}
export async function listInquiries(limit=250){const a=await authorize('crm.read');if(![250,10001].includes(limit))throw new Denied(400,'invalid_limit');return (await rows(db(),`SELECT * FROM business_inquiries WHERE workspace_id=? ORDER BY created_at DESC,id DESC LIMIT ${limit}`,[a.workspace_id])).map(dto);}
export async function getInquiry(id:string){const a=await authorize('crm.read');if(!isInquiryId(id))throw new Denied(404,'not_found');const [r]=await rows(db(),'SELECT * FROM business_inquiries WHERE id=? AND workspace_id=?',[id,a.workspace_id]);if(!r)throw new Denied(404,'not_found');return dto(r);}
export async function notifications(){const a=await authorize('crm.read');return (await rows(db(),'SELECT id,inquiry_id,reference_code,notification_kind,status,created_at,read_at,read_by FROM business_inquiry_notifications WHERE workspace_id=? ORDER BY created_at DESC LIMIT 100',[a.workspace_id])).map(r=>({id:String(r.id),inquiry_id:String(r.inquiry_id),reference_code:String(r.reference_code),notification_kind:r.notification_kind as "business_inquiry_created",status:r.status as "unread"|"read"|"archived",created_at:date(r.created_at)!,read_at:date(r.read_at),read_by:r.read_by as string|null}));}
export async function updateInquiry(form:FormData){
 await mutationGuard();
 return transaction(async c=>{
  const a=await authorize('crm.write',c,true);const parsed=parseInquiryUpdate(form,CURRENT_INQUIRY_SCHEMA);if(!parsed)throw new Denied(400,'invalid_update');
  const [r]=await rows(c,'SELECT * FROM business_inquiries WHERE id=? AND workspace_id=? FOR UPDATE',[parsed.id,a.workspace_id]);if(!r)throw new Denied(404,'not_found');
  if(date(r.updated_at)!==new Date(parsed.version).toISOString())throw new Denied(409,'stale_version');
  const v=parsed.values;const updated=new Date(Math.max(Date.now(),new Date(date(r.updated_at)!).getTime()+1));
  await c.execute('UPDATE business_inquiries SET status=?,admin_notes=?,contact_role=?,offer_interest=?,lost_reason=?,lost_reason_detail=?,won_evidence_type=?,won_evidence_at=?,handled_by=?,updated_at=?,status_changed_at=? WHERE id=? AND workspace_id=?',[v.status,v.admin_notes,v.contact_role,v.offer_interest,v.lost_reason,v.lost_reason_detail,v.won_evidence_type,v.won_evidence_at?new Date(v.won_evidence_at):null,a.id,updated,r.status!==v.status?updated:new Date(date(r.status_changed_at)!),parsed.id,a.workspace_id]);
  await c.execute('INSERT INTO audit_events(id,workspace_id,actor_id,object_id,event,created_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3))',[randomUUID(),a.workspace_id,a.id,parsed.id,'inquiry.updated']);
  const [now]=await rows(c,'SELECT * FROM business_inquiries WHERE id=? AND workspace_id=?',[parsed.id,a.workspace_id]);const result=verifyInquiryUpdate(dto(now),parsed,a.id);if(!result)throw new Error('Integrity');return result;
 });
}
export async function updateNotification(form:FormData){await mutationGuard();return transaction(async c=>{const a=await authorize('crm.write',c,true);if([...form.keys()].some(k=>!['id','status'].includes(k))||form.getAll('id').length!==1||form.getAll('status').length!==1)throw new Denied(400,'invalid_request');const id=String(form.get('id')),status=String(form.get('status'));if(!isInquiryId(id)||!['read','archived'].includes(status))throw new Denied(400,'invalid_request');const [r]=await rows(c,'SELECT id FROM business_inquiry_notifications WHERE id=? AND workspace_id=? FOR UPDATE',[id,a.workspace_id]);if(!r)throw new Denied(404,'not_found');await c.execute('UPDATE business_inquiry_notifications SET status=?,read_at=UTC_TIMESTAMP(3),read_by=? WHERE id=? AND workspace_id=?',[status,a.id,id,a.workspace_id]);return {ok:true};});}
export async function audit(){const a=await authorize('audit.read');return rows(db(),'SELECT object_id,event,created_at FROM audit_events WHERE workspace_id=? ORDER BY created_at DESC LIMIT 100',[a.workspace_id]);}
