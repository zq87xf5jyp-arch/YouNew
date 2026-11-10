// Operator-only, append-only import into an initialized, empty target.
// Passwords and original row values are never written to stdout or Git.
import {createHash} from 'node:crypto';
import * as fs from 'node:fs/promises';
import {createRequire} from 'node:module';
import {pathToFileURL} from 'node:url';

export const WORKSPACE='b8813c64-a7b8-49aa-a10b-89eea40c9769';
export const SOURCE_SHA='f7105eb2493d021f46c48a81c729e3ce1fb12b403790ead57a815cd90b22f410';
export const STORAGE_SHA='076189d4eab41ed5dd71663306da1962680d5ae85fa9fcba41216b88b446361b';
export const sha=v=>createHash('sha256').update(v).digest('hex');
const jsonValue=v=>typeof v==='string'?JSON.parse(v):v;
const fail=message=>{throw new Error(message);};
const uuid=v=>typeof v==='string'&&/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v);
const bool=v=>v==='t'?true:v==='f'?false:fail('Invalid boolean');
export function timestamp(v){
  const m=typeof v==='string'&&v.match(/^(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2})(\.\d{1,6})?\+00(?::00)?$/);
  if(!m||!Number.isFinite(Date.parse(v)))fail('Unsupported source timestamp');
  return m[1]+' '+m[2]+(m[3]??'');
}
// PostgreSQL one-dimensional text arrays, with quoted commas and escapes.
export function array(v){
  if(typeof v!=='string'||!v.startsWith('{')||!v.endsWith('}'))fail('Invalid source array');
  if(v==='{}')return [];
  const result=[];let value='',quoted=false,escaped=false,wasQuoted=false;
  for(const c of v.slice(1,-1)){
    if(escaped){value+=c;escaped=false;continue;}
    if(c==='\\'){escaped=true;continue;}
    if(c==='"'){quoted=!quoted;wasQuoted=true;continue;}
    if(c===','&&!quoted){result.push(value==='NULL'&&!wasQuoted?null:value);value='';wasQuoted=false;continue;}
    if((c==='{'||c==='}')&&!quoted)fail('Nested array unsupported');value+=c;
  }
  if(quoted||escaped)fail('Incomplete source array');result.push(value==='NULL'&&!wasQuoted?null:value);return result;
}
export function plan(bundle){
  if(bundle.schemaVersion!==1||bundle.sourceSha256!==SOURCE_SHA||!Array.isArray(bundle.tables))fail('Pinned source required');
  const tables=new Map();
  for(const t of bundle.tables){
    if(!/^[a-z_][a-z_0-9]*\.[a-z_][a-z_0-9]*$/.test(t.name)||tables.has(t.name)||!Array.isArray(t.rows)||!Array.isArray(t.columns)||new Set(t.columns).size!==t.columns.length)fail('Invalid table');
    if(sha(Buffer.from(t.copyBase64,'base64'))!==t.copySha256)fail('COPY checksum mismatch');
    const rows=t.rows.map(r=>{if(r.length!==t.columns.length||r.some(v=>v!==null&&typeof v!=='string'))fail('Invalid row');return Object.fromEntries(t.columns.map((k,i)=>[k,r[i]]));});
    tables.set(t.name,rows);
  }
  const required=name=>tables.get(name)??fail('Missing source table');
  if(required('auth.mfa_factors').length||required('auth.webauthn_credentials').length)fail('MFA migration requires review');
  const auth=required('auth.users'), sourceProfiles=required('public.profiles');
  if(auth.length!==sourceProfiles.length||new Set(auth.map(r=>r.id)).size!==auth.length)fail('Account mapping incomplete');
  const profiles=sourceProfiles.map(p=>{
    const u=auth.find(u=>u.id===p.id);
    if(!uuid(p.id)||!u||u.email!==p.email||!u.email_confirmed_at||u.deleted_at||u.banned_until||u.is_sso_user==='t'||u.is_anonymous==='t')fail('Unsupported account state');
    if(!/^\$2[aby]\$10\$[./A-Za-z0-9]{53}$/.test(u.encrypted_password)||!['owner','admin','editor','qa','viewer'].includes(p.role))fail('Unsupported account credentials or role');
    if(typeof p.email!=='string'||p.email.length>254||p.email!==p.email.trim().toLowerCase()||!p.full_name||p.full_name.length>120)fail('Profile projection needs review');
    return {id:p.id,workspace_id:WORKSPACE,email:p.email,full_name:p.full_name,password_hash:u.encrypted_password,role:p.role,is_approved:bool(p.is_approved),is_blocked:false};
  });
  if(new Set(profiles.map(p=>p.id)).size!==profiles.length||new Set(profiles.map(p=>p.email)).size!==profiles.length)fail('Duplicate profile');
  const payloadMap={company_name:'companyName',contact_person:'contactPerson',email:'email',phone:'phone',website:'website',inquiry_type:'inquiryType',organization_type:'organizationType',kvk_number:'kvkNumber',city:'city',province:'province',campaign_goal:'campaignGoal',budget_range:'budgetRange',campaign_start:'campaignStart',campaign_end:'campaignEnd',message:'description',source_page:'sourcePage',utm_source:'utmSource',utm_medium:'utmMedium',utm_campaign:'utmCampaign',utm_content:'utmContent',utm_term:'utmTerm'};
  const inquiries=required('public.business_inquiries').map(r=>{
    if(!uuid(r.id)||!r.reference_code||r.reference_code.length>24||r.handled_by&&!profiles.some(p=>p.id===r.handled_by)||!['new','reviewing','responded','accepted','declined','test','archived'].includes(r.status))fail('Inquiry projection needs review');
    const payload=Object.fromEntries(Object.entries(payloadMap).map(([k,v])=>[v,r[k]]));
    Object.assign(payload,{targetAudience:array(r.target_audience),requestedPlacements:array(r.requested_placements),consentToPrivacy:bool(r.consent_to_privacy),confirmAccuracy:bool(r.confirm_accuracy)});
    // Existing reviewed pipeline rule; original status and every source field stay intact.
    return {id:r.id,workspace_id:WORKSPACE,receipt:r.reference_code,payload:JSON.stringify(payload),status:['declined','test','archived'].includes(r.status)?'archived':'new',legacy_status:r.status,admin_notes:r.admin_notes,handled_by:r.handled_by,contact_role:null,offer_interest:'not_specified',created_at:timestamp(r.created_at),consent_at:timestamp(r.consent_at),updated_at:timestamp(r.updated_at)};
  });
  if(new Set(inquiries.map(r=>r.id)).size!==inquiries.length||new Set(inquiries.map(r=>r.receipt)).size!==inquiries.length)fail('Duplicate inquiry');
  const objects=required('storage.objects');
  if(bundle.storageSha256!==STORAGE_SHA||!Array.isArray(bundle.assets)||bundle.assets.length!==objects.length||new Set(bundle.assets.map(a=>a.id)).size!==objects.length)fail('Complete pinned storage export required');
  const assets=bundle.assets.map(a=>{
    const object=objects.find(o=>o.id===a.id),content=Buffer.from(a.dataBase64,'base64');
    if(!uuid(a.id)||!object||content.length!==a.bytes||!a.bytes||a.bytes>1048576||JSON.parse(object.metadata).size!==a.bytes||sha(content)!==a.sha256)fail('Asset verification failed');
    return {id:a.id,sha256:a.sha256,bytes:a.bytes,content};
  });
  return {profiles,inquiries,assets,tables:bundle.tables,rowCount:bundle.tables.reduce((n,t)=>n+t.rows.length,0)};
}

async function insert(c,table,row){const columns=Object.keys(row);await c.execute(`INSERT INTO ${table}(${columns.join(',')}) VALUES(${columns.map(()=>'?').join(',')})`,Object.values(row));}
export async function importData(c,bundle,bundleSha){
  const data=plan(bundle);const [[lock]]=await c.execute('SELECT GET_LOCK(?,10) AS acquired',['younew_legacy_import']);if(lock.acquired!==1)fail('Import lock unavailable');
  try{
    await c.query("SET SESSION sql_mode='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION',time_zone='+00:00'");
    const [[prior]]=await c.execute('SELECT * FROM legacy_imports WHERE source_sha256=?',[SOURCE_SHA]);
    if(prior){if(prior.bundle_sha256!==bundleSha)fail('Changed bundle for imported source');await verifyArchive(c,data);return {status:'VERIFIED_ALREADY_IMPORTED',tables:data.tables.length,rows:data.rowCount};}
    for(const table of ['profiles','workspaces','sessions','business_inquiries','catalog_places','private_files','legacy_imports']){
      const [[r]]=await c.query(`SELECT COUNT(*) AS total FROM ${table}`);if(r.total)fail('Empty target required; no merging or overwrite attempted');
    }
    await c.beginTransaction();
    await insert(c,'workspaces',{id:WORKSPACE,name:'YouNew'});
    await insert(c,'legacy_imports',{source_sha256:SOURCE_SHA,bundle_sha256:bundleSha,workspace_id:WORKSPACE,table_count:data.tables.length,row_count:data.rowCount,imported_at:new Date()});
    for(const t of data.tables){
      await insert(c,'legacy_tables',{source_sha256:SOURCE_SHA,table_name:t.name,column_names:JSON.stringify(t.columns),row_count:t.rows.length,copy_sha256:t.copySha256,copy_payload:Buffer.from(t.copyBase64,'base64')});
      for(let i=0;i<t.rows.length;i++){const payload=JSON.stringify(t.rows[i]);await insert(c,'legacy_rows',{source_sha256:SOURCE_SHA,table_name:t.name,row_index:i,payload,payload_sha256:sha(payload)});}
    }
    for(const asset of data.assets)await insert(c,'legacy_assets',{source_sha256:SOURCE_SHA,...asset});
    for(const row of data.profiles)await insert(c,'profiles',row);
    const [[now]]=await c.query('SELECT UTC_TIMESTAMP(3) AS at');
    for(const row of data.inquiries)await insert(c,'business_inquiries',{...row,status_changed_at:now.at});
    await verifyArchive(c,data);
    for(const [table,records] of [['profiles',data.profiles],['business_inquiries',data.inquiries]])for(const expected of records){
      const [[row]]=await c.execute(`SELECT * FROM ${table} WHERE id=?`,[expected.id]);
      for(const [key,value] of Object.entries(expected)){
        const normalizedDate=v=>String(v).replace(/(\.\d*?)0+$/,'$1').replace(/\.$/,'');
        const same=key==='payload'?JSON.stringify(jsonValue(row[key]))===value:typeof value==='boolean'?!!row[key]===value:key.endsWith('_at')?normalizedDate(row[key])===normalizedDate(value):row[key]===value;
        if(!same)fail('Projection verification failed: '+table+'.'+key);
      }
    }
    await c.commit();return {status:'IMPORTED_VERIFIED',tables:data.tables.length,rows:data.rowCount,assets:data.assets.length,profiles:data.profiles.length,inquiries:data.inquiries.length,sessionsImported:0};
  }catch(e){await c.rollback();throw e;}finally{await c.execute('SELECT RELEASE_LOCK(?)',['younew_legacy_import']);}
}
async function verifyArchive(c,data){
  const [assets]=await c.execute('SELECT id,sha256,bytes,content FROM legacy_assets WHERE source_sha256=?',[SOURCE_SHA]);
  if(assets.length!==data.assets.length)fail('Asset count mismatch');
  for(const a of data.assets){const saved=assets.find(s=>s.id===a.id);if(!saved||saved.sha256!==a.sha256||saved.bytes!==a.bytes||sha(saved.content)!==a.sha256)fail('Stored asset verification failed');}
  for(const t of data.tables){
    const [[saved]]=await c.execute('SELECT * FROM legacy_tables WHERE source_sha256=? AND table_name=?',[SOURCE_SHA,t.name]);
    const [rows]=await c.execute('SELECT row_index,payload,payload_sha256 FROM legacy_rows WHERE source_sha256=? AND table_name=? ORDER BY row_index',[SOURCE_SHA,t.name]);
    if(!saved||sha(saved.copy_payload)!==t.copySha256||saved.row_count!==t.rows.length||JSON.stringify(jsonValue(saved.column_names))!==JSON.stringify(t.columns)||rows.length!==t.rows.length)fail('Archive verification failed');
    for(let i=0;i<rows.length;i++){const payload=JSON.stringify(jsonValue(rows[i].payload));if(rows[i].row_index!==i||payload!==JSON.stringify(t.rows[i])||rows[i].payload_sha256!==sha(payload))fail('Row verification failed');}
  }
}

if(process.argv[1]&&import.meta.url===pathToFileURL(process.argv[1]).href){
  const [mode,file,expectedSha]=process.argv.slice(2);
  const bytes=await fs.readFile(file);if(sha(bytes)!==expectedSha)fail('Bundle checksum mismatch');
  const bundle=JSON.parse(bytes);const data=plan(bundle);
  if(mode==='--plan')console.log(JSON.stringify({status:'PLAN_VALIDATED',tables:data.tables.length,rows:data.rowCount,profiles:data.profiles.length,inquiries:data.inquiries.length,workspace:WORKSPACE}));
  else if(mode==='--apply'){
    const env=process.env;if(!((env.R4_LOCAL==='true'&&/^r4_legacy_/.test(env.R4_DB_NAME??''))||(env.R4_LOCAL==='false'&&env.R4_DB_NAME==='u246392949_younp1'&&env.R4_DB_USER===env.R4_DB_NAME&&env.R4_DB_HOST==='127.0.0.1')))fail('Explicit migration target required');
    const mysql=createRequire(process.cwd()+'/package.json')('mysql2/promise');
    const c=await mysql.createConnection({user:env.R4_DB_USER,password:env.R4_DB_PASSWORD,database:env.R4_DB_NAME,...(env.R4_DB_SOCKET?{socketPath:env.R4_DB_SOCKET}:{host:env.R4_DB_HOST??'127.0.0.1'}),charset:'utf8mb4_unicode_ci',dateStrings:true,multipleStatements:false});
    try{console.log(JSON.stringify(await importData(c,bundle,expectedSha)));}catch(e){console.error('Import stopped:',e.code??e.message);process.exitCode=1;}finally{await c.end();}
  }else fail('Use --plan or --apply');
}
