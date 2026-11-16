import {pendingReviewRoot} from './place-review-fixture.ts';
import test, {after} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {readPlaceReview,applyPlaceReview,expansionReviews,selectedPlaceReviews,validatePlaceRecords,reviewPath} from '../scripts/place-review.mjs';
import type {PlaceRevision} from '../scripts/place-review.mjs';
import {loadEditorialRelease} from '../scripts/editorial-release.mjs';
import {buildPublicDataset,paths} from '../scripts/generate-public-content.mjs';
import {isDiscoverableContent} from '../src/lib/content/presentation.ts';
const root=fileURLToPath(new URL('../../../',import.meta.url));
// Freeze this suite's historical publication boundary; current approval is tested separately.
const history=await pendingReviewRoot(root,['pr75-integration-20261116']);
after(()=>history.cleanup());
// This suite describes the three approved expansion batches. Subsequent
// draft follow-ups have their own approval-boundary tests.
const batches=['leiden-stay-parks-20261115','amsterdam-museums-20261115','priority-cities-20261115'];
const proofs=await Promise.all(batches.map(b=>readPlaceReview(root,b)));

test('private discovery needs an explicit draft ID and never makes an ordinary draft discoverable',()=>{
 const draft={id:'museum.rijksmuseum',status:'draft',indexable:false} as const;
 assert.equal(isDiscoverableContent(draft),false);
 assert.equal(isDiscoverableContent({...draft,indexable:true}),false);
 assert.equal(isDiscoverableContent(draft,{publicationAuthorized:false,draftIds:[]}),false);
 assert.equal(isDiscoverableContent(draft,{publicationAuthorized:false,draftIds:[draft.id]}),true);
 assert.equal(isDiscoverableContent({...draft,status:'published'}),false);
 assert.equal(isDiscoverableContent({...draft,status:'published',indexable:true}),true);
});

test('expansion keeps ordinary content byte-equivalent and requires an explicit private build',async()=>{
 const runtime=JSON.parse(await readFile(paths.source,'utf8'));
 const fixture=await pendingReviewRoot(history.root,batches);
 const ordinary=await loadEditorialRelease(fixture.root);const snapshot=JSON.stringify(ordinary);
 try {
 assert.strictEqual(await applyPlaceReview(ordinary,fixture.root,{}),ordinary);
 assert.equal(buildPublicDataset(runtime,{editorialRelease:ordinary}).content.entities.length,76);
 assert.throws(()=>selectedPlaceReviews({YOUNEW_PLACE_REVIEW:batches.join(',')}),/private review/);
 assert.throws(()=>selectedPlaceReviews({YOUNEW_PLACE_REVIEW:batches[0]+','+batches[0],YOUNEW_PRIVATE_REVIEW_BUILD:'1'}),/duplicate/);
 const preview=await applyPlaceReview(ordinary,fixture.root,{YOUNEW_PLACE_REVIEW:batches.join(','),YOUNEW_PRIVATE_REVIEW_BUILD:'1'});
 assert.equal(JSON.stringify(ordinary),snapshot,'input release mutated');
 assert.throws(()=>buildPublicDataset(runtime,{editorialRelease:preview}),/withheld/);
 const old=process.env.YOUNEW_PRIVATE_REVIEW_BUILD;
 try {
  delete process.env.YOUNEW_PRIVATE_REVIEW_BUILD;
  assert.throws(()=>buildPublicDataset(runtime,{editorialRelease:preview,privateReview:true}),/private review/);
  process.env.YOUNEW_PRIVATE_REVIEW_BUILD='1';
  const data=buildPublicDataset(runtime,{editorialRelease:preview,privateReview:true}).content;
  assert.equal(data.entities.length,96);
  const newIds=new Set(proofs.filter(p=>p.manifest.batchId==='amsterdam-museums-20261115').flatMap(p=>p.manifest.ids));
  assert.equal(data.entities.filter(e=>newIds.has(e.id)).length,20);
  for(const e of data.entities.filter(e=>newIds.has(e.id))){assert.equal(e.status,'draft');assert.equal(e.indexable,false);assert.equal(e.governance,null);assert.equal(e.editorial?.reviewedAt,null);assert.equal(e.editorial?.reviewer,null);}
  for(const p of proofs)for(const r of p.records){const e=data.entities.find(e=>e.id===r.id);assert.ok(e?.editorial?.placeReview);assert.ok(e.relatedEntityIds.every(r=>data.entities.some(d=>d.id===r)));
   const source=JSON.parse(r.attributes.place_enrichment).sources[0];
   assert.equal(e.placeDetails?.website?.value,new URL(source.url).href,'verified Website action missing');
   assert.equal(e.placeDetails?.website?.checkedAt,r.attributes.website_checked_at);
   assert.equal(e.editorial.reviewedAt,null);assert.equal(e.editorial.reviewer,null);
  }
 }finally{if(old===undefined)delete process.env.YOUNEW_PRIVATE_REVIEW_BUILD;else process.env.YOUNEW_PRIVATE_REVIEW_BUILD=old;}
 } finally {await fixture.cleanup();}
});

test('every expansion record has aligned EN/NL facts, existing identity and evidence',async()=>{
 const allIds=proofs.flatMap(p=>p.manifest.ids);assert.equal(new Set(allIds).size,allIds.length);
 for(const {manifest,records} of proofs){
  assert.equal(manifest.status,'approved');assert.equal(manifest.publicationAuthorized,true);assert.equal(manifest.approvedAt,'2026-11-15');assert.equal(manifest.reviewerId,'owner.ivan');
  const bases=new Map(await Promise.all(Object.entries(manifest.baseFiles).map(async([id,b])=>[id,JSON.parse(await readFile(`${root}/${b.file}`,'utf8')).records.find((r:PlaceRevision)=>r.id===id)] as const)));
  const checks=JSON.parse(await readFile(`${root}/${reviewPath(manifest.batchId)}/source-checks.json`,'utf8'));
  for(const r of records){const p=JSON.parse(r.attributes.place_enrichment);assert.equal(r.lifecycle_status,'draft');assert.equal(r.verification_status,'needs_review');assert.deepEqual(p.locales.en.blocks.map((b:{id:string})=>b.id),p.locales.nl.blocks.map((b:{id:string})=>b.id));
   for(const s of p.sources)assert.ok(Object.values(checks).some((c:unknown)=>{const x=c as {finalUrl:string;httpStatus?:number;method?:string};return x.finalUrl===s.url&&(x.httpStatus===200||x.method==='web.run');}),'source proof missing');
  }
  const invalid=structuredClone(records);const p=JSON.parse(invalid[0].attributes.place_enrichment);p.locales.nl.blocks[0].source_ids=['missing'];invalid[0].attributes.place_enrichment=JSON.stringify(p);
  assert.throws(()=>validatePlaceRecords(invalid,manifest.ids,bases,true,expansionReviews[manifest.batchId]),/unsourced/);
  const wrong=structuredClone(records);wrong[0].city_id='other-city';assert.throws(()=>validatePlaceRecords(wrong,manifest.ids,bases,true,expansionReviews[manifest.batchId]),/identity changed/);
 }
});

test('all expansion records pass the existing DataProject schema',()=>{
 const check=spawnSync('python3',['-c',`
import sys,pathlib,json,importlib.util
root=pathlib.Path(sys.argv[1]);sys.path.insert(0,str(root/'scripts'))
spec=importlib.util.spec_from_file_location('data_importer',root/'scripts/import-data-project.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
schema=json.loads((root/'DataProject/schema/entity.schema.json').read_text())
for batch in json.loads(sys.argv[2]):
 for r in json.loads((root/'DataProject/editorial'/batch/'records.json').read_text())['records']:m.validate_schema(r,schema,schema,r['id'])
`,root,JSON.stringify(batches)],{encoding:'utf8'});assert.equal(check.status,0,check.stderr);
});

test('approved expansion adds only the twenty exact reviewed historical IDs',async()=>{
 const runtime=JSON.parse(await readFile(paths.source,'utf8')),release=await loadEditorialRelease(history.root);
 const data=buildPublicDataset(runtime,{editorialRelease:release}).content;
 assert.equal(data.entities.length,96);assert.equal(Object.hasOwn(data,'privateReview'),false);
 const proof=proofs.find(p=>p.manifest.batchId==='amsterdam-museums-20261115')!;
 const additions=data.entities.filter(e=>proof.manifest.ids.includes(e.id));assert.equal(additions.length,20);
 assert.ok(additions.every(e=>e.status==='published'&&e.indexable&&e.editorial?.reviewer==='Ivan'&&!e.editorial.placeReview));
 assert.deepEqual(data.entities.filter(e=>runtime.withheldEntityIDs.includes(e.id)).map(e=>e.id).sort(),[...proof.manifest.ids].sort());
 const corrupt=structuredClone(release);Reflect.deleteProperty(corrupt.entities.find(e=>e.id===proof.manifest.ids[0])!.editorial,'approvedAddition');
 assert.throws(()=>buildPublicDataset(runtime,{editorialRelease:corrupt}),/withheld/);
 const unrelated=structuredClone(release);unrelated.entities.find(e=>e.id===proof.manifest.ids[0])!.id='restaurant.breda';
 assert.throws(()=>buildPublicDataset(runtime,{editorialRelease:unrelated}),/withheld/);
});
