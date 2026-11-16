import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile}from'node:fs/promises';
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
 assert.equal(p.records.length,43);assert.equal(p.reviewer,null);assert.equal(new Set(p.records.map(r=>r.id)).size,43);
 assert.equal(p.records.filter(r=>r.images.length).length,32);assert.equal(p.records.filter(r=>r.attributes.media_placements).length,8);
 assert.deepEqual(i.mergedHashes,{'restaurant.eindhoven-kazerne':'8a407face9de7d5e4feeeff7a576dd4e9ad7b21ba9665850b0f25368b3f06c2e','hotel.rotterdam-supernova':'6ed0a97e133d1f1a1dbe068a00339cf13d378f6c0375f5f63fb7ec29c57c274c'});
 assert.equal(i.additions.length,10);assert.equal(i.collections.collections.length,4);
});

test('pending owner decisions cannot be activated; any material change invalidates integration',async()=>{
 const p=await readPlaceReview(root,id);
 await assert.rejects(()=>verifyIntegration(root,{...p.manifest,status:'approved',approvedAt:'2026-11-16',reviewerId:'owner.ivan'},p.records),/exact owner decision/);
 const bad=structuredClone(p.records);bad[0].attributes.description_nl='Changed after selection';
 await assert.rejects(()=>verifyIntegration(root,p.manifest,bad),/differs from frozen/);
 assert.notEqual(placeApprovalDigest(p.manifest),placeApprovalDigest({...p.manifest,integrationReviewSha256:'0'.repeat(64)}));
});

test('archive role never falls back into a hero, card or map image',()=>{
 const archived={id:'archive',role:'gallery',placement:'archive_gallery_only',url:'/a.webp'} as PublicMediaAsset;
 const current={id:'current',role:'gallery',url:'/b.webp'} as PublicMediaAsset;
 for(const roles of [['hero'],['thumbnail','hero','gallery'],['gallery','hero']] as const){assert.equal(preferredMedia([archived],roles),null);assert.equal(preferredMedia([archived,current],roles),current);}
});

test('ordinary output stays unchanged; private integration has complete EN/NL media, collections and no stale Nieuwe Kerk hours',async()=>{
 const release=await loadEditorialRelease(),runtime=JSON.parse(await readFile(paths.source,'utf8'));
 const ordinary=buildPublicDataset(runtime,{editorialRelease:release}).content;assert.equal(ordinary.entities.length,96);assert.ok(!('editorialCollections'in ordinary));
 assert.strictEqual(await applyPlaceReview(release,root,{}),release);
 const selected=await applyPlaceReview(release,root,{YOUNEW_PLACE_REVIEW:id,YOUNEW_PRIVATE_REVIEW_BUILD:'1'}),before=process.env.YOUNEW_PRIVATE_REVIEW_BUILD;
 try{process.env.YOUNEW_PRIVATE_REVIEW_BUILD='1';const c=buildPublicDataset(runtime,{editorialRelease:selected,privateReview:true}).content;
  assert.equal(c.entities.length,106);
  const p=await readPlaceReview(root,id);for(const r of p.records){const e=c.entities.find(e=>e.id===r.id)!;assert.equal(e.status,'draft');assert.equal(e.indexable,false);assert.equal(e.editorial?.reviewer,null);}
  for(const e of c.entities.filter(e=>e.images.some(i=>i.placement==='archive_gallery_only'))){assert.equal(preferredMedia(e.images,['hero','gallery']),null);for(const m of e.images){assert.ok(m.captions?.en&&m.captions.nl);assert.equal(m.role,'gallery');}}
  const kerk=c.entities.find(e=>e.id==='place.de-nieuwe-kerk-amsterdam')!;assert.doesNotMatch(JSON.stringify(kerk.editorial?.place),/10:00|17:00|10\.00|17\.00/);
 }finally{if(before===undefined)delete process.env.YOUNEW_PRIVATE_REVIEW_BUILD;else process.env.YOUNEW_PRIVATE_REVIEW_BUILD=before;}
});
