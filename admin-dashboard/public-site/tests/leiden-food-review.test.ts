import {pendingReviewRoot} from './place-review-fixture.ts';
import test, {after} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {readPlaceReview,applyPlaceReview,reviewPath,validatePlaceRecords} from '../scripts/place-review.mjs';
import type {PlaceRevision} from '../scripts/place-review.mjs';
import {loadEditorialRelease} from '../scripts/editorial-release.mjs';
import {buildPublicDataset,paths} from '../scripts/generate-public-content.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
// Freeze this suite's historical publication boundary; current approval is tested separately.
const history=await pendingReviewRoot(root,['pr75-integration-20261116']);
after(()=>history.cleanup());
const batch='leiden-food-20261115';
const {manifest,records}=await readPlaceReview(root,batch);
const env={YOUNEW_PLACE_REVIEW:batch,YOUNEW_PRIVATE_REVIEW_BUILD:'1'};
const bases=new Map(await Promise.all(Object.entries(manifest.baseFiles).map(async([id,b])=>[id,JSON.parse(await readFile(`${root}/${b.file}`,'utf8')).records.find((r:PlaceRevision)=>r.id===id)] as const)));

test('approved food batch publishes exactly five revisions and pending approval still excludes them',async()=>{
 assert.equal(manifest.status,'approved');assert.equal(manifest.publicationAuthorized,true);assert.equal(manifest.reviewerId,'owner.ivan');
 const release=await loadEditorialRelease(history.root);
 const revised=release.entities.filter(e=>manifest.ids.includes(e.id));assert.equal(revised.length,5);
 assert.ok(revised.every(e=>e.images.length===1&&e.editorial?.place&&!e.editorial.placeReview&&!e.editorial.place.tickets));
 const preview=await applyPlaceReview(release,history.root,env);assert.deepEqual(preview.entities.map(e=>e.id),release.entities.map(e=>e.id));
 assert.ok(preview.entities.filter(e=>manifest.ids.includes(e.id)).every(e=>e.editorial.placeReview?.batchId===batch));
 await assert.rejects(applyPlaceReview(release,history.root,{YOUNEW_PLACE_REVIEW:batch}),/private review/);
 const fixture=await pendingReviewRoot(history.root,[batch]);
 try {const withheld=await loadEditorialRelease(fixture.root);assert.ok(withheld.entities.filter(e=>manifest.ids.includes(e.id)).every(e=>!e.images.length&&!e.editorial.place));}
 finally {await fixture.cleanup();}
 const data=buildPublicDataset(JSON.parse(await readFile(paths.source,'utf8')),{editorialRelease:release}).content;assert.equal(data.entities.length,96);
 for(const e of data.entities.filter(e=>manifest.ids.includes(e.id)))assert.ok(e.relatedEntityIds.every(id=>data.entities.some(other=>other.id===id)));
});

test('food revisions retain identities, bilingual source links and licensed dated photographs',()=>{
 assert.equal(Object.keys(manifest.media).length,15);
 for(const r of records){
  assert.equal(r.attributes.slug,bases.get(r.id)!.attributes.slug);
  const p=JSON.parse(r.attributes.place_enrichment);
  assert.deepEqual(p.locales.en.blocks.map((b:{id:string})=>b.id),p.locales.nl.blocks.map((b:{id:string})=>b.id));
  assert.equal(p.tickets,null);
  for(const l of ['en','nl']){
   assert.equal(p.locales[l].blocks.length,6);
   const prices=p.locales[l].blocks.find((b:{id:string})=>b.id==='prices');assert.ok(prices.text.includes('€'));
  }
 }
 for(const [file,proof] of Object.entries(manifest.media))if(file.endsWith('-480.webp'))assert.ok(proof.bytes<80000);
 const roos=records.find(r=>r.id==='cafe.leiden-roos')!;
 assert.match(JSON.parse(roos.attributes.place_enrichment).locales.en.alt,/2010.*before ROOS/);
 assert.match(JSON.parse(roos.attributes.place_enrichment).locales.nl.alt,/2010.*vóór ROOS/);
 const burcht=records.find(r=>r.id==='restaurant.leiden-grand-cafe-burcht')!;
 assert.match(JSON.parse(burcht.attributes.place_enrichment).locales.en.alt,/Archive.*1963/);
});

test('food source references and route destinations cannot be replaced with unsupported data',()=>{
 const invalid=structuredClone(records);const p=JSON.parse(invalid[0].attributes.place_enrichment);
 p.coordinateEvidence.destinationURL='https://www.google.com/maps/dir/?api=1&destination=52.2,4.5';invalid[0].attributes.place_enrichment=JSON.stringify(p);
 assert.throws(()=>validatePlaceRecords(invalid,manifest.ids,bases,true),/coordinate destination mismatch/);
 const unsourced=structuredClone(records);const nl=JSON.parse(unsourced[3].attributes.place_enrichment);nl.locales.nl.blocks[3].source_ids=['unknown-menu'];unsourced[3].attributes.place_enrichment=JSON.stringify(nl);
 assert.throws(()=>validatePlaceRecords(unsourced,manifest.ids,bases,true),/unsourced text/);
});

test('all food revisions pass the existing DataProject entity schema',()=>{
 const check=spawnSync('python3',['-c',`
import sys,pathlib,json,importlib.util
root=pathlib.Path(sys.argv[1]);sys.path.insert(0,str(root/'scripts'))
spec=importlib.util.spec_from_file_location('data_importer',root/'scripts/import-data-project.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
schema=json.loads((root/'DataProject/schema/entity.schema.json').read_text())
for r in json.loads((root/'${reviewPath(batch)}/records.json').read_text())['records']:m.validate_schema(r,schema,schema,r['id'])
`,root],{encoding:'utf8'});assert.equal(check.status,0,check.stderr);
});
