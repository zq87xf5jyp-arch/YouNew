import 'server-only';
import {readFile} from 'node:fs/promises';
import {productionMode} from './runtime-mode';
import {editorialPublished} from './editorial-publication';
import {randomUUID,timingSafeEqual} from 'node:crypto';
import {z} from 'zod';
import {db,rows as sqlRows,transaction,type Conn} from './db';
import {authorize,mutationGuard,Denied,hash,type Actor} from './security';

// This rehearsal cannot publish a real organization, even with an administrator session.
export const LOCAL_RELEASE='integration-synthetic-local-v1';
const text=(n:number)=>z.string().trim().min(1).max(n).refine(s=>!/[\x00-\x1f\x7f<>]/.test(s));
const https=z.string().max(2048).refine(s=>{try{const u=new URL(s);return u.protocol==='https:'&&!u.username&&!u.password;}catch{return false;}});
const date=z.string().regex(/^\d{4}-\d{2}-\d{2}$/).refine(s=>{const d=new Date(s);return Number.isFinite(+d)&&d.toISOString().slice(0,10)===s&&s<=new Date().toISOString().slice(0,10);});
const field=z.object({value:text(300),sourceUrl:https,checkedAt:date}).strict().nullable();
const fields={title:text(180),summary:text(800),kind:z.enum(['place','museum','park','restaurant','cafe','hotel']),category:text(80),cityId:z.enum(['amsterdam','utrecht','rotterdam','den-haag','eindhoven','leiden']),coordinate:z.object({latitude:z.number().min(50).max(54),longitude:z.number().min(3).max(8),sourceUrl:https,checkedAt:date}).strict().nullable(),address:field,website:field,email:field,phone:field};
const input=z.object(fields).strict();
const update=input.partial().extend({revision:z.number().int().positive()}).strict();
const provinces:Record<string,string>={amsterdam:'noord-holland',utrecht:'utrecht',rotterdam:'zuid-holland','den-haag':'zuid-holland',eindhoven:'noord-brabant',leiden:'zuid-holland'};
const names:Record<string,string>={address:'address',website:'website',email:'contact_email',phone:'contact_phone'};
function validate<T>(schema:z.ZodType<T>,v:unknown):T{const r=schema.safeParse(v);if(!r.success)throw new Denied(400,'invalid_catalog_input');return r.data;}
type Document={id:string;title:string;summary:string;kind:string;category:string;cityId:string;provinceId:string;aiSummary:string;keywords:string[];relatedEntityIDs:string[];publicationStatus:string;coordinate:{latitude:number;longitude:number}|null;attributes:Record<string,string>;images:unknown[];source:Record<string,unknown>;lastChecked:string;verificationStatus:string};
type CatalogRow={id:string;public_id:string;state:string;revision:number;synthetic:boolean|number;payload:string|Document;request_hash?:string};
async function rows(...args:Parameters<typeof sqlRows>){return await sqlRows(...args) as unknown as CatalogRow[];}
function apply(document:Partial<Document>,edit:Partial<z.infer<typeof input>>):Document{
 const d=structuredClone(document) as Document;d.attributes??={};
 for(const k of ['title','summary','kind','category','cityId'] as const)if(k in edit)d[k]=edit[k]!;
 d.provinceId=provinces[d.cityId];d.relatedEntityIDs=[`city.${d.cityId}`];d.aiSummary=d.summary;
 d.keywords=[d.title,d.cityId,d.kind,d.category];
 if('coordinate' in edit){const c=edit.coordinate;d.coordinate=c?{latitude:c.latitude,longitude:c.longitude}:null;for(const k of ['coordinate_source','coordinates_checked_at'])delete d.attributes[k];if(c){d.attributes.coordinate_source=c.sourceUrl;d.attributes.coordinates_checked_at=c.checkedAt;}}
 for(const [k,attribute] of Object.entries(names))if(k in edit){const f=edit[k as keyof typeof names as 'address'|'website'|'email'|'phone'];for(const a of [attribute,attribute+'_source_url',attribute+'_checked_at'])delete d.attributes[a];if(f){
  if(k==='website'&&!https.safeParse(f.value).success)throw new Denied(400,'invalid_website');
  if(k==='email'&&!/^[A-Za-z0-9.!#$&'*+/=^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$/.test(f.value))throw new Denied(400,'invalid_email');
  if(k==='phone'&&(!/^\+?[0-9 ()\-.]+$/.test(f.value)||f.value.replace(/\D/g,'').length<7||f.value.replace(/\D/g,'').length>15))throw new Denied(400,'invalid_phone');
  d.attributes[attribute]=f.value;d.attributes[attribute+'_source_url']=f.sourceUrl;d.attributes[attribute+'_checked_at']=f.checkedAt;
 }}
 d.publicationStatus='draft';d.attributes.lifecycleStatus='draft';d.attributes.dataProjectRelease=LOCAL_RELEASE;
 return d;
}
function normal(s:string){return s.normalize('NFKC').toLocaleLowerCase('en').replace(/[^\p{L}\p{N}]/gu,'');}
function keys(d:Document){const a=d.attributes;return [hash(normal(d.cityId+':'+d.title)),a.address?hash(normal(d.cityId+':'+a.address)):null,a.website?hash(new URL(a.website).host.toLowerCase()+new URL(a.website).pathname.replace(/\/+$/,'')):null];}
const parse=(r:CatalogRow)=>({...r,payload:typeof r.payload==='string'?JSON.parse(r.payload) as Document:r.payload});
function dto(r:CatalogRow){return {id:r.id,publicId:r.public_id,state:r.state,revision:r.revision,synthetic:!!r.synthetic,document:parse(r).payload};}
function id(s:string){if(!/^[a-f0-9-]{36}$/.test(s))throw new Denied(404,'not_found');}
async function audit(c:Conn,a:Actor,object:string,event:string){await c.execute('INSERT INTO audit_events(id,workspace_id,actor_id,object_id,event,created_at) VALUES(?,?,?,?,?,UTC_TIMESTAMP(3))',[randomUUID(),a.workspace_id,a.id,object,event]);}
function conflict(e:unknown):never{if((e as {code?:string})?.code==='ER_DUP_ENTRY')throw new Denied(409,'catalog_duplicate');throw e;}
export async function catalogList(){const a=await authorize('catalog.read');
 if(productionMode()){
  const file=process.env.R4_EDITORIAL_DRAFTS_FILE;if(!file)throw new Error('Private draft source required');
  const data=JSON.parse(await readFile(file,'utf8')) as {entities:Document[];publication?:unknown};
  if(!Array.isArray(data.entities)||data.entities.some(d=>d.publicationStatus!=='draft'||d.attributes?.synthetic==='true'))throw new Error('Invalid editorial source');
  const state=editorialPublished(data)?'published':'draft';
  return data.entities.map(d=>({id:d.id,publicId:d.id,state,revision:1,synthetic:false,document:d}));
 }
 return (await rows(db(),'SELECT * FROM catalog_places WHERE workspace_id=? ORDER BY public_id',[a.workspace_id])).map(dto);}

export async function catalogGet(key:string){id(key);const a=await authorize('catalog.read');const [r]=await rows(db(),'SELECT * FROM catalog_places WHERE id=? AND workspace_id=?',[key,a.workspace_id]);if(!r)throw new Denied(404,'not_found');return dto(r);}
export async function catalogCreate(body:unknown){
 await mutationGuard();const b=validate(z.object({requestKey:z.string().uuid(),place:input}).strict(),body);
 try{return await transaction(async c=>{const a=await authorize('catalog.write',c,true);if(productionMode())throw new Denied(403,'publication_batch_review_required');const fingerprint=hash(JSON.stringify(b.place));
 const [prior]=await rows(c,'SELECT * FROM catalog_places WHERE workspace_id=? AND request_key=?',[a.workspace_id,b.requestKey]);if(prior){if(prior.request_hash!==fingerprint)throw new Denied(409,'request_conflict');return dto(prior);}
 const key=randomUUID(),publicId='place.synthetic-'+key,now=new Date().toISOString().slice(0,10);
 const d=apply({id:publicId,images:[],source:{title:'Synthetic local fixture',publisher:'Local QA',url:'https://example.invalid/catalog',checkedAt:now,status:'verified_opened',isOfficial:false},lastChecked:now,verificationStatus:'verified',attributes:{verificationStatus:'verified',synthetic:'true',content_language:'en'}},b.place);
 if(!d.title.startsWith('[SYNTHETIC]'))throw new Denied(400,'synthetic_title_required');
 await c.execute('INSERT INTO catalog_places(id,public_id,workspace_id,payload,created_by,synthetic,request_key,request_hash,name_key,address_key,website_key,updated_at) VALUES(?,?,?,?,?,TRUE,?,?,?,?,?,UTC_TIMESTAMP(3))',[key,publicId,a.workspace_id,JSON.stringify(d),a.id,b.requestKey,fingerprint,...keys(d)]);await audit(c,a,key,'catalog.create');return dto({id:key,public_id:publicId,payload:d,state:'draft',revision:1,synthetic:true});});}catch(e){conflict(e);}
}
export async function catalogEdit(key:string,body:unknown){id(key);await mutationGuard();const edit=validate(update,body);try{return await transaction(async c=>{const a=await authorize('catalog.write',c,true);if(productionMode())throw new Denied(403,'publication_batch_review_required');const [r]=await rows(c,'SELECT * FROM catalog_places WHERE id=? AND workspace_id=? FOR UPDATE',[key,a.workspace_id]);if(!r)throw new Denied(404,'not_found');if(!r.synthetic)throw new Denied(403,'canonical_draft_read_only');if(r.revision!==edit.revision)throw new Denied(409,'stale_revision');if(r.state==='published'&&!['owner','admin'].includes(a.role))throw new Denied(403,'forbidden');const d=apply(parse(r).payload,edit);if(r.synthetic&&!d.title.startsWith('[SYNTHETIC]'))throw new Denied(400,'synthetic_title_required');await c.execute("UPDATE catalog_places SET payload=?,state='draft',revision=revision+1,approved_revision=NULL,approved_by=NULL,name_key=?,address_key=?,website_key=?,updated_at=UTC_TIMESTAMP(3) WHERE id=?",[JSON.stringify(d),...keys(d),key]);await audit(c,a,key,'catalog.edit');return dto({...r,payload:d,state:'draft',revision:r.revision+1});});}catch(e){conflict(e);}}
export async function catalogTransition(key:string,body:unknown){id(key);await mutationGuard();const b=validate(z.object({action:z.enum(['submit','approve','withdraw']),revision:z.number().int().positive()}).strict(),body);return transaction(async c=>{const a=await authorize(b.action!=='submit'?'catalog.approve':'catalog.write',c,true);if(productionMode())throw new Denied(403,'publication_batch_review_required');const [r]=await rows(c,'SELECT * FROM catalog_places WHERE id=? AND workspace_id=? FOR UPDATE',[key,a.workspace_id]);if(!r)throw new Denied(404,'not_found');if(r.revision!==b.revision)throw new Denied(409,'stale_revision');if(b.action==='approve'&&(!r.synthetic||!r.public_id.startsWith('place.synthetic-')))throw new Denied(403,'real_publication_locked');if(b.action==='withdraw'){if(r.state!=='published')throw new Denied(409,'invalid_transition');await c.execute("UPDATE catalog_places SET state='draft',revision=revision+1,approved_revision=NULL,approved_by=NULL,updated_at=UTC_TIMESTAMP(3) WHERE id=?",[key]);await audit(c,a,key,'catalog.withdraw');return dto({...r,state:'draft',revision:r.revision+1});}if(r.state!==(b.action==='approve'?'review':'draft'))throw new Denied(409,'invalid_transition');const state=b.action==='approve'?'published':'review';await c.execute('UPDATE catalog_places SET state=?,approved_revision=?,approved_by=?,updated_at=UTC_TIMESTAMP(3) WHERE id=?',[state,b.action==='approve'?r.revision:null,b.action==='approve'?a.id:null,key]);await audit(c,a,key,'catalog.'+b.action);return dto({...r,state});});}
export async function approvedCatalog(headers:Headers){
 const expected=process.env.R4_CATALOG_BUILD_KEY,provided=headers.get('authorization')?.replace(/^Bearer /,'');if(!expected||!provided||provided.length!==expected.length||!timingSafeEqual(Buffer.from(provided),Buffer.from(expected)))throw new Denied(401,'build_auth_required');
 const workspace=process.env.R4_INGEST_WORKSPACE;if(!workspace)throw new Error('Workspace required');
 const records=await rows(db(),"SELECT p.* FROM catalog_places p JOIN profiles a ON a.id=p.approved_by AND a.workspace_id=p.workspace_id WHERE p.workspace_id=? AND p.state='published' AND p.approved_revision=p.revision AND p.synthetic=TRUE AND a.is_approved=TRUE AND a.is_blocked=FALSE AND a.role IN ('owner','admin') ORDER BY p.public_id",[workspace]);
 return {schemaVersion:1,release:LOCAL_RELEASE,localOnly:true,revisions:records.map(r=>({publicId:r.public_id,revision:r.revision})),entities:records.map(r=>{const d=parse(r).payload;return {...d,publicationStatus:'published',attributes:{...d.attributes,lifecycleStatus:'published'}};})};
}
