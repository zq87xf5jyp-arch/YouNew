import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile,mkdtemp,mkdir,symlink,writeFile,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {readPlaceReview,applyPlaceReview,validatePlaceRecords,reviewPath,placeReviewBatches} from '../scripts/place-review.mjs';
import {buildPublicDataset,paths} from '../scripts/generate-public-content.mjs';
import {loadEditorialRelease,approvalPath} from '../scripts/editorial-release.mjs';
import type {PlaceRevision} from '../scripts/place-review.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
const batch='leiden-nature-culture-20261115';
const {manifest,records}=await readPlaceReview(root,batch);
const env={YOUNEW_PLACE_REVIEW:batch,YOUNEW_PRIVATE_REVIEW_BUILD:'1'};
const bases=new Map(await Promise.all(Object.entries(manifest.baseFiles).map(async([id,b])=>[id,JSON.parse(await readFile(`${root}/${b.file}`,'utf8')).records.find((r:PlaceRevision)=>r.id===id)] as const)));
test('five existing IDs gain bilingual private text without changing the approved release',async()=>{
 const release=await loadEditorialRelease();const before=JSON.stringify(release);
 assert.strictEqual(await applyPlaceReview(release,root,{}),release);
 await assert.rejects(applyPlaceReview(release,root,{YOUNEW_PLACE_REVIEW:batch}),/private review/);
 assert.throws(()=>reviewPath('../unregistered'),/unknown review/);
 const preview=await applyPlaceReview(release,root,env);
 const runtime=JSON.parse(await readFile(paths.source,'utf8'));
 const publicPreview=buildPublicDataset(runtime,{editorialRelease:preview}).content;
 assert.equal(publicPreview.entities.length,76);
 assert.equal(publicPreview.entities.filter(e=>e.editorial?.placeReview?.batchId===batch).length,5);
 assert.equal(JSON.stringify(release),before);
 assert.deepEqual(preview.entities.map(e=>e.id),release.entities.map(e=>e.id));
 const changed=preview.entities.filter(e=>e.editorial?.placeReview?.batchId===batch);
 assert.equal(changed.length,5);
 assert.equal(changed.filter(e=>e.coordinate).length,5);
 assert.equal(changed.filter(e=>e.editorial?.place?.tickets).length,1);
 assert.ok(changed.every(e=>e.images.length===1));
 assert.equal(preview.entities.filter(e=>e.images.length).length,10);
 assert.equal(preview.entities.filter(e=>e.editorial?.placeReview).length,5);
 assert.equal(Object.keys(manifest.media).length,15);
 for(const e of publicPreview.entities.filter(e=>manifest.ids.includes(e.id)))assert.ok(e.relatedEntityIds.every(id=>publicPreview.entities.some(other=>other.id===id)));
 for(const [file,proof] of Object.entries(manifest.media))if(file.endsWith('-480.webp'))assert.ok(proof.bytes<80000);
 for(const e of changed)for(const language of ['en','nl'] as const)assert.ok(e.editorial!.place!.locales[language].blocks.length>=5);
});
test('optional park tickets remain absent; invented pins, unsupported tickets and unlicensed photos fail',()=>{
 const mutate=(change:(r:typeof records)=>void)=>{const copy=structuredClone(records);change(copy);assert.throws(()=>validatePlaceRecords(copy,manifest.ids,bases,true));};
 mutate(r=>{const p=JSON.parse(r[0].attributes.place_enrichment);p.coordinateEvidence.destinationURL='https://www.google.com/maps/dir/?destination=52.2,4.5';r[0].attributes.place_enrichment=JSON.stringify(p);});
 mutate(r=>{const p=JSON.parse(r[0].attributes.place_enrichment);p.tickets={url:'https://example.com',sourceId:'invented'};r[0].attributes.place_enrichment=JSON.stringify(p);});
 mutate(r=>{const p=JSON.parse(r[1].attributes.place_enrichment);p.tickets.url='https://example.com/tickets';r[1].attributes.place_enrichment=JSON.stringify(p);});
 mutate(r=>{r[0].images=[{verified:false,license_url:'https://unlicensed.example/'}];});
 mutate(r=>{r[0].id=r[1].id;});
 mutate(r=>{const p=JSON.parse(r[0].attributes.place_enrichment);p.locales.nl.blocks[0].source_ids=['missing'];r[0].attributes.place_enrichment=JSON.stringify(p);});
});
test('all five revisions pass the existing entity schema',()=>{
 const check=spawnSync('python3',['-c',`
import sys,pathlib,json,importlib.util
root=pathlib.Path(sys.argv[1]);sys.path.insert(0,str(root/'scripts'))
spec=importlib.util.spec_from_file_location('data_importer',root/'scripts/import-data-project.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
schema=json.loads((root/'DataProject/schema/entity.schema.json').read_text())
for r in json.loads((root/'${reviewPath(batch)}/records.json').read_text())['records']:m.validate_schema(r,schema,schema,r['id'])
`,root],{encoding:'utf8'});assert.equal(check.status,0,check.stderr);
});

test('owner-approved nature batch publishes five stable IDs and preserves the first batch',async()=>{
 const release=await loadEditorialRelease();
 assert.equal(manifest.status,'approved');assert.equal(manifest.publicationAuthorized,true);
 assert.equal(manifest.approvedAt,'2026-11-15');assert.equal(manifest.reviewerId,'owner.ivan');
 const revised=release.entities.filter(e=>manifest.ids.includes(e.id));assert.equal(revised.length,5);
 assert.ok(revised.every(e=>e.images.length===1&&e.editorial.place&&!e.editorial.placeReview));
 const data=buildPublicDataset(JSON.parse(await readFile(paths.source,'utf8')),{editorialRelease:release}).content;
 assert.ok(data.entities.filter(e=>manifest.ids.includes(e.id)).every(e=>e.images.every(i=>i.url.startsWith(`/images/places/${batch}/`))&&!JSON.stringify(e).includes('/images/place-review/')));
 const published=release.entities.filter(e=>e.images.length&&!manifest.ids.includes(e.id));
 const preview=await applyPlaceReview(release,root,env);
 for(const e of published){const after=preview.entities.find(x=>x.id===e.id)!;assert.deepEqual(after.images,e.images);assert.deepEqual(after.editorial.place,e.editorial.place);assert.equal(after.editorial.reviewedAt,e.editorial.reviewedAt);}
});


test('pending nature manifest still stays out of an ordinary release',async()=>{
 const temp=await mkdtemp(join(tmpdir(),'younew-nature-gate-'));
 try {
  await mkdir(`${temp}/DataProject/editorial/${batch}`,{recursive:true});
  for(const path of ['DataProject/staging','DataProject/operations',...placeReviewBatches.filter(b=>b!==batch).map(b=>reviewPath(b)),approvalPath])await symlink(`${root}/${path}`,`${temp}/${path}`);
  for(const path of ['records.json','media'])await symlink(`${root}/${reviewPath(batch)}/${path}`,`${temp}/${reviewPath(batch)}/${path}`);
  await writeFile(`${temp}/${reviewPath(batch)}/manifest.json`,JSON.stringify({...manifest,status:'needs_review',publicationAuthorized:false,approvedAt:null,reviewerId:null}));
  const release=await loadEditorialRelease(temp);
  assert.equal(release.entities.filter(e=>e.images.length).length,5);
  assert.ok(release.entities.filter(e=>manifest.ids.includes(e.id)).every(e=>!e.images.length&&!e.editorial.place&&!e.editorial.placeReview));
 } finally {await rm(temp,{recursive:true,force:true});}
});
