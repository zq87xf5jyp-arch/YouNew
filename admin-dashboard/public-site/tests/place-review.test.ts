import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {applyPlaceReview,readPlaceReview,validatePlaceRecords,placeReviewBatch,placeReviewPath} from '../scripts/place-review.mjs';
import {loadEditorialRelease} from '../scripts/editorial-release.mjs';
import {buildPublicDataset,paths} from '../scripts/generate-public-content.mjs';
import type {PlaceRevision} from '../scripts/place-review.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
const read=async(path:string)=>JSON.parse(await readFile(path,'utf8'));
const {manifest,records}=await readPlaceReview(root);
const bases=new Map(await Promise.all(Object.entries(manifest.baseFiles).map(async([id,b])=>[id,(await read(`${root}/${b.file}`)).records.find((r:PlaceRevision)=>r.id===id) as PlaceRevision] as const)));
const env={YOUNEW_PLACE_REVIEW:placeReviewBatch,YOUNEW_PRIVATE_REVIEW_BUILD:'1'};
test('ordinary release retains 71 approved records, no revision text, and no new photographs',async()=>{
  const release=await loadEditorialRelease();
  assert.equal(release.entities.length,71);assert.ok(release.entities.every((e)=>!e.editorial.placeReview&&e.images.length===0));
  assert.strictEqual(await applyPlaceReview(release,root,{}),release);
});
test('review is opt-in, existing IDs and URLs survive, and both languages share dated sources',async()=>{
  const release=await loadEditorialRelease();
  await assert.rejects(applyPlaceReview(release,root,{YOUNEW_PLACE_REVIEW:placeReviewBatch}),/private review/);
  await assert.rejects(applyPlaceReview(release,root,{...env,YOUNEW_PLACE_REVIEW:'unknown'}),/unknown review/);
  const review=await applyPlaceReview(release,root,env);
  const runtime=await read(paths.source);
  const normal=buildPublicDataset(runtime,{editorialRelease:release}).content;
  const preview=buildPublicDataset(runtime,{editorialRelease:review}).content;
  assert.equal(normal.entities.length,76);assert.equal(preview.entities.length,76);
  assert.deepEqual(preview.entities.map((e)=>[e.id,e.route]),normal.entities.map((e)=>[e.id,e.route]));
  const changed=preview.entities.filter((e)=>e.editorial?.placeReview);
  assert.equal(changed.length,5);assert.equal(changed.filter((e)=>e.images.length===1&&e.coordinate&&e.placeDetails?.address).length,5);
  for(const e of changed){assert.equal(e.editorial!.placeReview!.approvedAt,null);assert.ok(e.relatedEntityIds.every((id:string)=>preview.entities.some((other)=>other.id===id)));for(const l of ['en','nl'] as const)assert.ok(e.editorial!.place!.locales[l].blocks.length>=5);}
  assert.equal(normal.entities.filter((e)=>e.type==='place'&&e.images.length).length,0);
});
test('duplicate IDs, changed URLs, unsafe URLs, unverified media and unsourced statements fail closed',()=>{
  const mutate=(fn:(r:typeof records)=>void)=>{const copy=structuredClone(records);fn(copy);assert.throws(()=>validatePlaceRecords(copy,manifest.ids,bases));};
  mutate(r=>r[1].id=r[0].id);
  mutate(r=>r[0].attributes.slug='new-url');
  mutate(r=>r[0].images[0].verified=false);
  mutate(r=>r[0].images[0].license_url='https://unlicensed.example/');
  mutate(r=>{const p=JSON.parse(r[0].attributes.place_enrichment);p.tickets.url='javascript:alert(1)';r[0].attributes.place_enrichment=JSON.stringify(p);});
  mutate(r=>{const p=JSON.parse(r[0].attributes.place_enrichment);p.locales.nl.blocks[0].source_ids=['missing'];r[0].attributes.place_enrichment=JSON.stringify(p);});
});
test('source and media evidence stays outside default public assets and declared revisions remain drafts',async()=>{
  const links=await read(`${root}/${placeReviewPath}/link-checks.json`);
  assert.equal(links.length,18);assert.ok(links.every((l:{http:number})=>l.http===200));
  assert.ok(records.every((r)=>r.lifecycle_status==='draft'&&r.verification_status==='needs_review'));
  assert.equal(Object.keys(manifest.media).length,15);
  for(const [name,proof] of Object.entries(manifest.media) as [string,{bytes:number}][])if(name.endsWith('-480.webp'))assert.ok(proof.bytes<80000);
});
test('five revisions conform to the existing DataProject entity schema without new dependencies',()=>{
  const check=spawnSync('python3',['-c',`
import sys, pathlib, json, importlib.util
root=pathlib.Path(sys.argv[1]);sys.path.insert(0,str(root/'scripts'))
spec=importlib.util.spec_from_file_location('data_importer',root/'scripts/import-data-project.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
schema=json.loads((root/'DataProject/schema/entity.schema.json').read_text())
for record in json.loads((root/'${placeReviewPath}/records.json').read_text())['records']:
    module.validate_schema(record,schema,schema,record['id'])
`,root],{encoding:'utf8'});
  assert.equal(check.status,0,check.stderr);
});
