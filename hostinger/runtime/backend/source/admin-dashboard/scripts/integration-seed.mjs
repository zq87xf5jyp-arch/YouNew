import mysql from 'mysql2/promise';
import {readFileSync} from 'node:fs';
import {randomUUID,createHash} from 'node:crypto';
import path from 'node:path';
const root=path.resolve('../..'),env=JSON.parse(readFileSync(root+'/private/env.json')),users=JSON.parse(readFileSync(root+'/private/users.json'));
if(env.R4_LOCAL!=='true'||!env.R4_DB_SOCKET?.startsWith(root+'/private/'))throw Error('Local isolated socket required');
const c=await mysql.createConnection({user:env.R4_DB_USER,password:env.R4_DB_PASSWORD,database:env.R4_DB_NAME,socketPath:env.R4_DB_SOCKET});
const hash=s=>createHash('sha256').update(s).digest('hex'),normal=s=>s.normalize('NFKC').toLocaleLowerCase('en').replace(/[^\p{L}\p{N}]/gu,'');
const entities=JSON.parse(readFileSync(root+'/db/catalog-drafts.json')).entities;
if(entities.length!==71||new Set(entities.map(d=>d.id)).size!==71)throw Error('Expected exact canonical batch');
await c.beginTransaction();
try{
 for(const d of entities){
  if(d.publicationStatus!=='draft'||d.attributes.lifecycleStatus!=='draft')throw Error('Draft required');
  const a=d.attributes,keys=[hash(normal(d.cityId+':'+d.title)),a.address?hash(normal(d.cityId+':'+a.address)):null,a.website&&a.website_shared_source!=='true'?hash(new URL(a.website).host.toLowerCase()+new URL(a.website).pathname.replace(/\/+$/,'')):null];
  const [existing]=await c.execute('SELECT id,synthetic,state,payload FROM catalog_places WHERE public_id=? AND workspace_id=?',[d.id,users.editor.workspace]);
  if(existing.length){
   const old=existing[0];if(old.synthetic||old.state!=='draft')throw Error('Refuse to replace a synthetic or non-draft record');
   const prior=typeof old.payload==='string'?JSON.parse(old.payload):old.payload;
   if(JSON.stringify(prior)!==JSON.stringify(d))await c.execute("UPDATE catalog_places SET payload=?,revision=revision+1,name_key=?,address_key=?,website_key=?,updated_at=UTC_TIMESTAMP(3) WHERE id=? AND synthetic=FALSE AND state='draft'",[JSON.stringify(d),...keys,old.id]);
  }else{
   await c.execute('INSERT INTO catalog_places(id,public_id,workspace_id,payload,created_by,synthetic,request_key,request_hash,name_key,address_key,website_key,updated_at) VALUES(?,?,?,?,?,FALSE,?,?,?,?,?,UTC_TIMESTAMP(3))',[randomUUID(),d.id,users.editor.workspace,JSON.stringify(d),users.editor.id,randomUUID(),hash(JSON.stringify(d)),...keys]);
  }
 }
 await c.commit();
}catch(e){await c.rollback();throw e;}finally{await c.end();}
console.log('71 canonical non-publishable drafts synchronized; no unrelated data removed');
