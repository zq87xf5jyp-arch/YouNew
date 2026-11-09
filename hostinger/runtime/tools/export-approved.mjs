import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {dirname,resolve} from 'node:path';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const endpoint=process.env.YOUNEW_LOCAL_CATALOG_API;
if(!['http://127.0.0.1:4404/api/r4/editorial/approved','https://qa-admin.younew.nl/api/r4/editorial/approved'].includes(endpoint))throw Error('Exact isolated local catalog API required');
let batch;
if(process.env.YOUNEW_APPROVED_SNAPSHOT_FILE){batch=JSON.parse(await readFile(process.env.YOUNEW_APPROVED_SNAPSHOT_FILE,'utf8'));}
else{const response=await fetch(endpoint,{headers:{Authorization:'Bearer '+process.env.R4_CATALOG_BUILD_KEY},redirect:'error',signal:AbortSignal.timeout(10000)});if(!response.ok)throw Error('Approved export unavailable; do not reuse stale snapshot');batch=await response.json();}
if(batch.schemaVersion!==1||batch.localOnly!==true||batch.release!=='integration-synthetic-local-v1'||!Array.isArray(batch.entities))throw Error('Invalid catalog envelope');
const base=JSON.parse(await readFile(root+'/source/YouNew/Resources/Data/younew-runtime-data.json'));
const real=JSON.parse(await readFile(root+'/backend/db/catalog-drafts.json')).entities;
for(const e of batch.entities)if(!e.id.startsWith('place.synthetic-')||e.attributes.synthetic!=='true'||e.publicationStatus!=='published'||e.attributes.lifecycleStatus!=='published'||e.attributes.dataProjectRelease!==batch.release||real.some(r=>r.id===e.id))throw Error('Draft/real record in local publication export');
const ids=new Set(base.entities.map(e=>e.id));for(const e of batch.entities){if(ids.has(e.id))throw Error('Duplicate ID');ids.add(e.id);}
base.entities.push(...batch.entities);base.releases.push({id:batch.release,status:'published',localOnly:true});
base.integrationScope='SYNTHETIC LOCAL ACCEPTANCE ONLY; NOT A PRODUCTION RELEASE';
delete base.outputChecksum;
const sort=x=>Array.isArray(x)?x.map(sort):x&&typeof x==='object'?Object.fromEntries(Object.keys(x).sort().map(k=>[k,sort(x[k])])):x;
base.outputChecksum=createHash('sha256').update(JSON.stringify(sort(base),null,2)+'\n').digest('hex');
await mkdir(root+'/evidence',{recursive:true});await writeFile(root+'/evidence/approved-runtime.json',JSON.stringify(base,null,2)+'\n');
await writeFile(root+'/evidence/approved-export.json',JSON.stringify({source:endpoint,at:new Date().toISOString(),realDraftsExcluded:real.length,approvedIDs:batch.entities.map(e=>e.id),checksum:base.outputChecksum},null,2)+'\n');
console.log('Approved local export:',batch.entities.length,'synthetic records;',real.length,'real drafts excluded.');
