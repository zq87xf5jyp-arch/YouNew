import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile,unlink,writeFile}from'node:fs/promises';
import {pendingReviewRoot} from './place-review-fixture.ts';
import {fileURLToPath}from'node:url';
import{readPlaceReview,applyPlaceReview,placeApprovalDigest}from'../scripts/place-review.mjs';
import{loadEditorialRelease}from'../scripts/editorial-release.mjs';
import{integrationInputs,verifyIntegration}from'../scripts/pr75-integration.mjs';
import{buildPublicDataset,paths}from'../scripts/generate-public-content.mjs';
import{preferredMedia}from'../src/lib/media/selection.ts';
import type{PublicMediaAsset}from'../src/lib/content/types';
const root=fileURLToPath(new URL('../../../',import.meta.url)),id='pr75-integration-20261116';

test('exact frozen selections yield 43 unique existing IDs and two separately hashed compositions',async()=>{
 const p=await readPlaceReview(root,id),i=await integrationInputs(root);
 assert.equal(p.records.length,43);assert.equal(p.reviewer?.name,'Ivan');assert.equal(p.manifest.reviewerId,'owner.ivan');assert.equal(new Set(p.records.map(r=>r.id)).size,43);
 assert.equal(p.records.filter(r=>r.images.length).length,32);assert.equal(p.records.filter(r=>r.attributes.media_placements).length,8);
 assert.deepEqual(i.mergedHashes,{'restaurant.eindhoven-kazerne':'8a407face9de7d5e4feeeff7a576dd4e9ad7b21ba9665850b0f25368b3f06c2e','hotel.rotterdam-supernova':'6ed0a97e133d1f1a1dbe068a00339cf13d378f6c0375f5f63fb7ec29c57c274c'});
 assert.equal(i.additions.length,10);assert.equal(i.collections.collections.length,4);
});

test('pending owner decisions cannot be activated; any material change invalidates integration',async()=>{
 const p=await readPlaceReview(root,id);
 const fixture=await pendingReviewRoot(root,[id]);
 try {
  const path=`${fixture.root}/DataProject/editorial/${id}/owner-approvals.json`;
  const approved=JSON.parse(await readFile(path,'utf8'));
  await unlink(path); // Replace the fixture symlink, never the real approval receipt.
  for(const key of Object.keys(approved.decisions)){
   const pending=structuredClone(approved);pending.decisions[key].status='needs_review';
   await writeFile(path,JSON.stringify(pending));
   await assert.rejects(()=>verifyIntegration(fixture.root,p.manifest,p.records),/exact owner decision/);
  }
 }finally{await fixture.cleanup();}
 const bad=structuredClone(p.records);bad[0].attributes.description_nl='Changed after selection';
 await assert.rejects(()=>verifyIntegration(root,p.manifest,bad),/differs from frozen/);
 assert.notEqual(placeApprovalDigest(p.manifest),placeApprovalDigest({...p.manifest,integrationReviewSha256:'0'.repeat(64)}));
});

test('archive role never falls back into a hero, card or map image',()=>{
 const archived={id:'archive',role:'gallery',placement:'archive_gallery_only',url:'/a.webp'} as PublicMediaAsset;
 const current={id:'current',role:'gallery',url:'/b.webp'} as PublicMediaAsset;
 for(const roles of [['hero'],['thumbnail','hero','gallery'],['gallery','hero']] as const){assert.equal(preferredMedia([archived],roles),null);assert.equal(preferredMedia([archived,current],roles),current);}
});

test('approved ordinary output has only exact additions, complete media and collections; no stale Nieuwe Kerk hours',async()=>{
 const release=await loadEditorialRelease(),runtime=JSON.parse(await readFile(paths.source,'utf8'));
 const c=buildPublicDataset(runtime,{editorialRelease:release}).content;
 assert.equal(c.entities.length,106);assert.equal(c.entities.filter(e=>e.type==='place').length,84);
 assert.equal(c.entities.filter(e=>e.type==='place'&&e.images.length).length,68);
 assert.equal(c.editorialCollections?.length,4);assert.ok(!('privateReview'in c));
 const p=await readPlaceReview(root,id);
 for(const r of p.records){const e=c.entities.find(e=>e.id===r.id)!;assert.equal(e.status,'published');assert.equal(e.indexable,true);assert.equal(e.editorial?.reviewer,'Ivan');assert.equal(e.editorial?.reviewedAt,'2026-11-16');assert.ok(!e.editorial?.placeReview);}
 assert.ok(!JSON.stringify(c).includes('/images/place-review/'));
 assert.strictEqual(await applyPlaceReview(release,root,{}),release);
  for(const e of c.entities.filter(e=>e.images.some(i=>i.placement==='archive_gallery_only'))){assert.equal(preferredMedia(e.images,['hero','gallery']),null);for(const m of e.images){assert.ok(m.captions?.en&&m.captions.nl);assert.equal(m.role,'gallery');}}
  const kerk=c.entities.find(e=>e.id==='place.de-nieuwe-kerk-amsterdam')!;assert.doesNotMatch(JSON.stringify(kerk.editorial?.place),/10:00|17:00|10\.00|17\.00/);
 const fixture=await pendingReviewRoot(root,[id]);
 try{
  const old=buildPublicDataset(runtime,{editorialRelease:await loadEditorialRelease(fixture.root)}).content;
  assert.equal(old.entities.length,96);assert.ok(!('editorialCollections'in old));
  assert.deepEqual(c.entities.filter(e=>!old.entities.some(o=>o.id===e.id)).map(e=>e.id).sort(),[...p.manifest.publicationScope!.addedIds].sort());
  for(const e of old.entities){assert.equal(c.entities.find(x=>x.id===e.id)?.route,e.route);}
 }finally{await fixture.cleanup();}
});

test('editorial approval is not production permission, and private preview remains draft',async()=>{
 const request=JSON.parse(await readFile(`${root}/DataProject/editorial/${id}/review-request.json`,'utf8'));
 assert.equal(request.scope.productionDeploymentApproved,false);
 const fixture=await pendingReviewRoot(root,[id]),before=process.env.YOUNEW_PRIVATE_REVIEW_BUILD;
 try{
  const release=await loadEditorialRelease(fixture.root),runtime=JSON.parse(await readFile(paths.source,'utf8'));
  const selected=await applyPlaceReview(release,fixture.root,{YOUNEW_PLACE_REVIEW:id,YOUNEW_PRIVATE_REVIEW_BUILD:'1'});
  process.env.YOUNEW_PRIVATE_REVIEW_BUILD='1';const c=buildPublicDataset(runtime,{editorialRelease:selected,privateReview:true}).content;
  assert.equal(c.entities.length,106);
  const p=await readPlaceReview(fixture.root,id);for(const r of p.records){const e=c.entities.find(e=>e.id===r.id)!;assert.equal(e.status,'draft');assert.equal(e.indexable,false);assert.equal(e.editorial?.reviewer,null);}
 }finally{if(before===undefined)delete process.env.YOUNEW_PRIVATE_REVIEW_BUILD;else process.env.YOUNEW_PRIVATE_REVIEW_BUILD=before;await fixture.cleanup();}
});
