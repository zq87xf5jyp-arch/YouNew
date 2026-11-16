// Exact, additive integration of the two frozen PR75 selections. No source edits.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {verifyReviewSelection,composeTextAndPhotoReview} from './review-selection.mjs';
export const integrationBatch='pr75-integration-20261116';
export const integrationPath=`DataProject/editorial/${integrationBatch}`;
export const selections=[
 ['DataProject/editorial/selections/pr75-fea2401-20261116/selection.json','defc64135bfe6c273f5d70a04ecec61714301778278e3634af2cb449ce38267a'],
 ['DataProject/editorial/hospitality-release-review-20261116/selection.json','4996a1f1b37a98491627162ea9a60d1e4bbb0967654d8beb4bded763cdffae5e']
];
export const digest=value=>createHash('sha256').update(typeof value==='string'||Buffer.isBuffer(value)?value:JSON.stringify(value)).digest('hex');
const json=async(root,p)=>JSON.parse(await readFile(resolve(root,p),'utf8'));
const folder=b=>`DataProject/editorial/${b}`;
export async function integrationInputs(root){
 for(const [p,sha] of selections)await verifyReviewSelection(root,p,sha);
 const names=['amsterdam-attractions-20261116','priority-cities-followup-20261116','missing-photos-20261116','leiden-hospitality-20261116','hospitality-followup-20261116'];
 const byId=new Map(),origin=new Map(),bases={},sourceChecks={},media={},mediaCopies={},provenance={};
 const baseline=await json(root,`${folder('priority-cities-20261115')}/records.json`);
 const originals={};
 for(const b of names){
  const dir=folder(b),m=await json(root,`${dir}/manifest.json`),rs=(await json(root,`${dir}/records.json`)).records;originals[b]=rs;
  const checks=await json(root,`${dir}/source-checks.json`);for(const [key,value]of Object.entries(checks))sourceChecks[`${b}:${key}`]=value;
  for(const r of rs){
   if(byId.has(r.id))continue;byId.set(r.id,structuredClone(r));origin.set(r.id,b);bases[r.id]=m.baseFiles[r.id];
  }
 }
 for(const id of ['restaurant.eindhoven-kazerne','hotel.rotterdam-supernova']){
  const b=baseline.records.find(r=>r.id===id),t=originals[names[1]].find(r=>r.id===id),p=originals[names[2]].find(r=>r.id===id);
  byId.set(id,composeTextAndPhotoReview(b,t,p));origin.set(id,names[2]);
 }
 const archiveIds=new Set(['nature.leiden-rembrandtpark','hotel.leiden-rembrandt-hotel','restaurant.eindhoven-kazerne','hotel.rotterdam-supernova','place.de-nieuwe-kerk-amsterdam','place.leiden-cafe-laken']);
 for(const [id,r]of byId){
  const b=origin.get(id),dir=folder(b),m=await json(root,`${dir}/manifest.json`),ps=await json(root,`${dir}/media-sources.json`);
  const placements={};
  for(const image of r.images){
   const name=image.public_asset_path.split('/').at(-1),largest=Number(/-(1024|1200)\.webp$/.exec(name)[1]);
   for(const width of [480,800,largest]){const file=name.replace(/-(1024|1200)\.webp$/,`-${width}.webp`);assert.ok(m.media[file]);media[file]=m.media[file];mediaCopies[file]=`${dir}/media/${file}`;}
   if(archiveIds.has(id)){
    image.role='gallery';const p=JSON.parse(r.attributes.place_enrichment);
    placements[image.id]={placement:'archive_gallery_only',captions:{en:p.locales.en.alt,nl:p.locales.nl.alt}};
   }
  }
  if(Object.keys(placements).length)r.attributes.media_placements=JSON.stringify(placements);
  provenance[id]={sourceBatch:b,sourceRecordSha256:digest(originals[b].find(r=>r.id===id)),photoEvidence:ps[id]??null,combined:['restaurant.eindhoven-kazerne','hotel.rotterdam-supernova'].includes(id)};
 }
 const extra=await json(root,'DataProject/editorial/hospitality-release-review-20261116/media-sources.json');
 for(const item of extra.accepted){
  assert.equal(item.heroAllowed,false);assert.equal(item.commercialUse,true);assert.equal(item.recommendedPlacement,'archive_gallery_only');
  const r=byId.get(item.entityId),stem=item.entityId==='restaurant.leiden-bikini'?'havenarchive':'stationswegarchive';assert.equal(r.images.length,0);
  for(const [file,proof]of Object.entries(item.variants)){const name=`${stem}-${proof.width}.webp`;media[name]=proof;mediaCopies[name]=`DataProject/editorial/hospitality-release-review-20261116/media/${file}`;}
  const photo={id:`media.${r.id}.archive-2015`,role:'gallery',source_page_url:item.sourcePage,asset_url:item.originalUrl,public_asset_path:`/images/place-review/${stem}-1200.webp`,license:item.license,license_url:item.licenseUrl,attribution:`${item.author} · ${item.captureDate} · ${item.attribution}`,verified:true,retrieved_at:item.retrievedAt,alt:item.captions.en};r.images=[photo];
  const p=JSON.parse(r.attributes.place_enrichment);for(const loc of ['en','nl'])p.locales[loc].alt=item.captions[loc];r.attributes.place_enrichment=JSON.stringify(p);
  r.attributes.media_placements=JSON.stringify({[photo.id]:{placement:'archive_gallery_only',captions:item.captions}});
  provenance[r.id].supplementalPhoto=item;
 }
 const records=[...byId.values()].sort((a,b)=>a.id.localeCompare(b.id));assert.equal(records.length,43);
 const collections=await json(root,'DataProject/editorial/hospitality-release-review-20261116/collections.json');
 const mergedHashes=Object.fromEntries(['restaurant.eindhoven-kazerne','hotel.rotterdam-supernova'].map(id=>[id,digest(records.find(r=>r.id===id))]));
 return {records,bases,sourceChecks,media,mediaCopies,provenance,collections,mergedHashes,additions:originals[names[0]].map(r=>r.id)};
}
export async function verifyIntegration(root,manifest,records){
 const input=await integrationInputs(root);assert.deepEqual(records,input.records,'integration differs from frozen source transformations');
 assert.deepEqual(manifest.baseFiles,input.bases);assert.deepEqual(manifest.publicationScope.addedIds,input.additions);assert.equal(manifest.publicationScope.supersedesHistoricalWithholding,true);assert.deepEqual(manifest.media,input.media);
 for(const [file,src]of Object.entries(input.mediaCopies))assert.equal(digest(await readFile(resolve(root,`${integrationPath}/media/${file}`))),digest(await readFile(resolve(root,src))),'source photo bytes changed');
 for(const [name,value]of [['source-checks.json',input.sourceChecks],['media-sources.json',input.provenance],['collections.json',input.collections]])assert.deepEqual(await json(root,`${integrationPath}/${name}`),value,`changed ${name}`);
 const request=await json(root,`${integrationPath}/review-request.json`);
 assert.equal(digest(request),manifest.integrationReviewSha256,'review request changed');
 assert.equal(request.recordsSha256,manifest.recordsSha256);assert.equal(request.sourceChecksSha256,manifest.sourceChecksSha256);assert.equal(request.mediaSourcesSha256,manifest.mediaSourcesSha256);
 assert.deepEqual(request.media,manifest.media);assert.deepEqual(request.mergedRecordHashes,input.mergedHashes);assert.equal(request.collectionsSha256,digest(input.collections));assert.deepEqual(request.selections,selections);
 const approvals=await json(root,`${integrationPath}/owner-approvals.json`);
 const expected={selection1:selections[0][1],selection2:selections[1][1],...input.mergedHashes,integration:manifest.integrationReviewSha256};
 assert.deepEqual(Object.keys(approvals.decisions).sort(),Object.keys(expected).sort());
 for(const [id,sha]of Object.entries(expected)){
  const d=approvals.decisions[id];assert.equal(d.sha256,sha,'approval targets changed');
  if(manifest.status==='approved'){assert.equal(d.status,'approved','exact owner decision required');assert.equal(d.reviewerId,manifest.reviewerId);assert.equal(d.approvedAt,manifest.approvedAt);assert.ok(d.ownerConfirmation?.length>20,'owner confirmation not recorded');}
  else{assert.ok(['needs_review','approved'].includes(d.status));}
 }
 return {collections:input.collections.collections};
}
