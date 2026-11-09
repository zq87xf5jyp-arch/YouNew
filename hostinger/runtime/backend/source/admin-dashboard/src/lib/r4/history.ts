import 'server-only';
import {db,rows} from './db';
import {authorize,Denied,hash} from './security';
// Preserve all source tables in the DB. Expose only reviewed business/content
// history here: never authentication tokens, vault data or system configuration.
export const HISTORY_TABLES=['public.articles','public.categories','public.cities','public.map_points','public.official_links','public.feedback','public.bugs','public.releases','public.screenshots','public.app_events','public.app_sessions','public.audit_logs','public.business_inquiries','public.content_governance_state','public.content_governance_versions','public.content_review_events','public.content_review_tasks','public.search_improvement_tasks','public.research_consents','public.research_observations'] as const;
export async function historyTables(){const a=await authorize('history.read');return (await rows(db(),'SELECT t.table_name,t.row_count FROM legacy_tables t JOIN legacy_imports i ON i.source_sha256=t.source_sha256 WHERE i.workspace_id=? ORDER BY t.table_name',[a.workspace_id])).filter(r=>HISTORY_TABLES.some(n=>n===r.table_name));}
export async function historyAssets(){const a=await authorize('history.read');return rows(db(),'SELECT f.id,f.bytes,f.sha256 FROM legacy_assets f JOIN legacy_imports i ON i.source_sha256=f.source_sha256 WHERE i.workspace_id=? ORDER BY f.id',[a.workspace_id]);}
export async function historyAsset(id:string){
 const a=await authorize('history.read');
 if(!/^[a-f0-9-]{36}$/.test(id))throw new Denied(404,'not_found');
 const [f]=await rows(db(),'SELECT f.content,f.bytes,f.sha256 FROM legacy_assets f JOIN legacy_imports i ON i.source_sha256=f.source_sha256 WHERE i.workspace_id=? AND f.id=?',[a.workspace_id,id]);
 if(!f)throw new Denied(404,'not_found');
 const content=Buffer.from(f.content);if(content.length!==f.bytes||hash(content)!==f.sha256)throw new Error('Asset integrity');return content;
}
export async function historyRows(table:string,page:number){
 const a=await authorize('history.read');
 if(!HISTORY_TABLES.some(n=>n===table)||!Number.isInteger(page)||page<0||page>1000)throw new Denied(404,'not_found');
 const result=await rows(db(),`SELECT t.column_names,r.row_index,r.payload FROM legacy_rows r JOIN legacy_tables t ON t.source_sha256=r.source_sha256 AND t.table_name=r.table_name JOIN legacy_imports i ON i.source_sha256=r.source_sha256 WHERE i.workspace_id=? AND r.table_name=? ORDER BY r.row_index LIMIT 25 OFFSET ${page*25}`,[a.workspace_id,table]);
 const decode=(v:unknown)=>typeof v==='string'?JSON.parse(v):v;
 return result.map(r=>({index:Number(r.row_index),values:Object.fromEntries((decode(r.column_names) as string[]).map((k,index)=>[k,(decode(r.payload) as (string|null)[])[index]]))}));
}
