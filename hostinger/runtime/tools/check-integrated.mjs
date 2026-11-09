import assert from 'node:assert/strict';
import {readFile,readdir,writeFile,mkdir} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {buildPublicDataset,assertCanonicalRuntimeChecksum} from '../source/admin-dashboard/public-site/scripts/generate-public-content.mjs';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..'),web=root+'/source/admin-dashboard/public-site';
const read=async p=>JSON.parse(await readFile(p,'utf8'));const checks=[];
function check(name,condition){assert.ok(condition,name);checks.push({name,status:'PASS'});}
const drafts=(await read(root+'/backend/db/catalog-drafts.json')).entities;
const manifest=await read(root+'/publication/current.json'),out=root+'/publication/releases/'+manifest.releaseId+'/out';
const runtime=await read(out+'/data/younew-runtime-data.json'),content=buildPublicDataset(runtime).content,search=await read(out+'/data/search-index.json');
assertCanonicalRuntimeChecksum(runtime);check('runtime_checksum',true);
const publicAPI=await (await fetch('http://127.0.0.1:4404/api/r4/public/catalog')).json();
check('approved_API_matches_export',JSON.stringify(publicAPI.entities.map(e=>e.id).sort())===JSON.stringify(runtime.entities.filter(e=>e.id.startsWith('place.synthetic-')).map(e=>e.id).sort()));
for(const d of drafts){check('no_draft_public_content:'+d.id,!content.entities.some(e=>e.id===d.id));check('no_draft_search:'+d.id,!JSON.stringify(search).includes(d.id));check('no_draft_iOS_export:'+d.id,!runtime.entities.some(e=>e.id===d.id));}
check('71_draft_envelopes_preserved',drafts.length===71&&drafts.every(d=>d.attributes.lifecycleStatus==='draft'));
let leaked=[];async function scan(p){for(const f of await readdir(p,{withFileTypes:true})){const file=resolve(p,f.name);if(f.isDirectory())await scan(file);else if(/\.(html|json|xml|txt)$/.test(f.name)){const text=await readFile(file,'utf8');for(const d of drafts)if(text.includes(d.id))leaked.push(file.slice(root.length)+':'+d.id);}}}
await scan(out);check('no_draft_in_all_static_HTML_JSON_sitemap',leaked.length===0);
const places=content.entities.filter(e=>e.id.startsWith('place.synthetic-'));check('synthetic_publication_count',places.length===publicAPI.entities.length);
for(const p of places){check('hotel_city_mapping:'+p.id,p.sourceKind==='hotel'&&p.narrowCategory==='hotel'&&p.categorySlugs.includes('local-services')&&p.cityId==='utrecht');check('no_fabricated_coordinates_or_photos:'+p.id,p.coordinate===null&&p.images.length===0);const html=await readFile(out+p.route+'/index.html','utf8');check('ordinary_card_generated:'+p.id,html.includes(p.title.replaceAll('&','&amp;')));}
const withContact=places.find(p=>p.title.includes('Integration hotel'));if(withContact)check('sourced_contact_projection',withContact.placeDetails.email.value==='desk@example.invalid'&&withContact.placeDetails.website.value==='https://hotel.example.invalid/');
const empty=places.find(p=>p.title.includes('Browser hotel'));if(empty)check('empty_optional_fields',empty.placeDetails===null&&empty.coordinate===null&&empty.images.length===0);
const onlyDraft={...runtime,entities:drafts};check('draft_gate_without_checksum_shortcut_in_normal_build',buildPublicDataset(onlyDraft,{verifyChecksum:false}).content.entities.length===0);
// iOS RuntimeEntity contract, including nullable coordinates and the existing hotel enum case.
const swift=await readFile(root+'/source/YouNew/Services/DataProjectRuntimeLoader.swift','utf8');check('iOS_consumer_published_gate',swift.includes('record.publicationStatus == "published"'));check('iOS_hotel_consumer',swift.includes('.hotel'));
for(const e of runtime.entities.filter(e=>e.id.startsWith('place.synthetic-'))){check('iOS_shape:'+e.id,['id','kind','title','summary','category','lastChecked','aiSummary','publicationStatus','verificationStatus'].every(k=>typeof e[k]==='string')&&Array.isArray(e.images)&&Array.isArray(e.keywords)&&Array.isArray(e.relatedEntityIDs)&&Object.values(e.attributes).every(v=>typeof v==='string')&&e.coordinate===null);}
const result={status:'PASS',checks,ios:{schema:'PASS',canonicalConversion:'PASS',nativeSwiftConversion:'NOT_TESTED',appBuild:'NOT_TESTED',simulatorRun:'NOT_TESTED'},limits:['Local synthetic publication only','Static catalog requires an explicit rebuild after approval/withdrawal','Canonical production release-truth covers the base dataset; integration-local-only.json identifies the synthetic overlay']};
await mkdir(root+'/evidence',{recursive:true});
await writeFile(root+'/evidence/integrated-checks.json',JSON.stringify(result,null,2)+'\n');console.log('PASS',checks.length,'integration artifact checks');
