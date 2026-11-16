import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {readPlaceReview,applyPlaceReview,validateMediaOnlyRecords,reviewPath} from '../scripts/place-review.mjs';
import type {PlaceRevision} from '../scripts/place-review.mjs';
import {loadEditorialRelease} from '../scripts/editorial-release.mjs';
import {buildPublicDataset,paths} from '../scripts/generate-public-content.mjs';
import {pendingReviewRoot} from './place-review-fixture.ts';
const root=fileURLToPath(new URL('../../../',import.meta.url));
const batch='missing-photos-20261116';
const {manifest,records}=await readPlaceReview(root,batch);
const bases=new Map(await Promise.all(Object.entries(manifest.baseFiles).map(async([id,b])=>[id,JSON.parse(await readFile(`${root}/${b.file}`,'utf8')).records.find((r:PlaceRevision)=>r.id===id)] as const)));
const env={YOUNEW_PLACE_REVIEW:batch,YOUNEW_PRIVATE_REVIEW_BUILD:'1'};

test('media follow-up remains draft; ordinary release keeps all nine empty slots',async()=>{
 assert.equal(manifest.status,'needs_review');assert.equal(manifest.publicationAuthorized,false);assert.equal(manifest.approvedAt,null);assert.equal(manifest.reviewerId,null);
 const release=await loadEditorialRelease();
 assert.strictEqual(await applyPlaceReview(release,root,{}),release);
 const normal=buildPublicDataset(JSON.parse(await readFile(paths.source,'utf8')),{editorialRelease:release}).content;
 assert.equal(normal.entities.length,96);assert.equal(normal.entities.filter(e=>e.type==='place'&&e.images.length).length,50);
 const gaps=JSON.parse(await readFile(`${root}/${reviewPath(batch)}/research.json`,'utf8')).cards;
 assert.equal(gaps.length,9);assert.equal(gaps.filter((g:{status:string})=>g.status==='candidate_ready').length,5);
 for(const gap of gaps)assert.equal(normal.entities.find(e=>e.id===gap.id)?.images.length,0);
 assert.ok(!JSON.stringify(normal).includes('/images/place-review/'));
});

test('private preview adds only five media slots and preserves catalogue IDs, routes and facts',async()=>{
 const release=await loadEditorialRelease(),runtime=JSON.parse(await readFile(paths.source,'utf8'));
 const normal=buildPublicDataset(runtime,{editorialRelease:release}).content;
 const preview=buildPublicDataset(runtime,{editorialRelease:await applyPlaceReview(release,root,env)}).content;
 assert.deepEqual(preview.entities.map(e=>[e.id,e.route]),normal.entities.map(e=>[e.id,e.route]));
 assert.equal(preview.entities.filter(e=>e.type==='place'&&e.images.length).length,55);
 assert.deepEqual(preview.entities.filter(e=>e.editorial?.placeReview).map(e=>e.id).sort(),[...manifest.ids].sort());
 validateMediaOnlyRecords(records,bases);
 for(const r of records) {
  const changed=preview.entities.find(e=>e.id===r.id)!;const before=normal.entities.find(e=>e.id===r.id)!;
  for(const k of ['route','title','summary','coordinate','placeDetails','relatedEntityIds'] as const)assert.deepEqual(changed[k],before[k],`changed ${k}`);
  assert.equal(changed.editorial?.reviewedAt,null);assert.equal(changed.images.length,1);
 }
});

test('media-only guard rejects changed prices, dates, URLs, source text and replacing an existing photo',()=>{
 for(const mutate of [
  (r:PlaceRevision)=>{r.attributes.slug='changed';},
  (r:PlaceRevision)=>{r.attributes.website_checked_at='2026-11-16';},
  (r:PlaceRevision)=>{const p=JSON.parse(r.attributes.place_enrichment);p.locales.en.blocks[0].text='A new unapproved price';r.attributes.place_enrichment=JSON.stringify(p);},
 ]) {const copy=structuredClone(records);mutate(copy[0]);assert.throws(()=>validateMediaOnlyRecords(copy,bases),/changed approved facts/);}
 const occupied=structuredClone(bases);occupied.get(records[0].id)!.images=records[0].images;
 assert.throws(()=>validateMediaOnlyRecords(records,occupied),/empty slot/);
});

test('private media cannot be layered over an unapproved content base',async()=>{
 const fixture=await pendingReviewRoot(root,['leiden-stay-parks-20261115']);
 try {const release=await loadEditorialRelease(fixture.root);await assert.rejects(applyPlaceReview(release,fixture.root,env),/approved base in the release/);}finally{await fixture.cleanup();}
});

test('five photo records conform to the existing entity schema',()=>{
 const check=spawnSync('python3',['-c',`
import sys,pathlib,json,importlib.util
root=pathlib.Path(sys.argv[1]);sys.path.insert(0,str(root/'scripts'))
spec=importlib.util.spec_from_file_location('data_importer',root/'scripts/import-data-project.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
schema=json.loads((root/'DataProject/schema/entity.schema.json').read_text())
for r in json.loads((root/'DataProject/editorial/${batch}/records.json').read_text())['records']:m.validate_schema(r,schema,schema,r['id'])
`,root],{encoding:'utf8'});assert.equal(check.status,0,check.stderr);
});
