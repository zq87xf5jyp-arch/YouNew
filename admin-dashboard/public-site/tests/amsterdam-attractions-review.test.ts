import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {readPlaceReview,applyPlaceReview,sha256,selectedPlaceReviews} from '../scripts/place-review.mjs';
import {loadEditorialRelease} from '../scripts/editorial-release.mjs';
import {buildPublicDataset,paths} from '../scripts/generate-public-content.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
const batch='amsterdam-attractions-20261116',dir=`${root}/DataProject/editorial/${batch}`;
const proof=await readPlaceReview(root,batch);

test('ten historical Amsterdam IDs remain excluded from the ordinary public release',async()=>{
 const release=await loadEditorialRelease();assert.strictEqual(await applyPlaceReview(release,root,{}),release);
 assert.equal(proof.reviewer,null);assert.equal(proof.manifest.status,'needs_review');assert.equal(proof.manifest.privateOnly,true);assert.equal(proof.manifest.publicationAuthorized,false);
 const data=buildPublicDataset(JSON.parse(await readFile(paths.source,'utf8')),{editorialRelease:release}).content;
 assert.equal(data.entities.length,96);assert.equal(data.entities.filter(e=>e.type==='place'&&e.images.length).length,50);
 for(const id of proof.manifest.ids)assert.ok(!data.entities.some(e=>e.id===id));
 assert.throws(()=>selectedPlaceReviews({YOUNEW_PLACE_REVIEW:batch}),/private review/);
});

test('explicit private preview adds ten draft cards and retains five photo candidates',async()=>{
 const release=await loadEditorialRelease(),runtime=JSON.parse(await readFile(paths.source,'utf8')),before=JSON.stringify(release);
 const selected=await applyPlaceReview(release,root,{YOUNEW_PLACE_REVIEW:`${batch},missing-photos-20261116`,YOUNEW_PRIVATE_REVIEW_BUILD:'1'});
 assert.equal(JSON.stringify(release),before);assert.throws(()=>buildPublicDataset(runtime,{editorialRelease:selected}),/withheld/);
 const old=process.env.YOUNEW_PRIVATE_REVIEW_BUILD;
 try {
  process.env.YOUNEW_PRIVATE_REVIEW_BUILD='1';const data=buildPublicDataset(runtime,{editorialRelease:selected,privateReview:true}).content;
  assert.equal(data.entities.length,106);assert.equal(data.entities.filter(e=>e.type==='place'&&e.images.length).length,55);
  const candidates=data.entities.filter(e=>proof.manifest.ids.includes(e.id));assert.equal(candidates.length,10);
  for(const e of candidates){assert.equal(e.status,'draft');assert.equal(e.indexable,false);assert.equal(e.editorial?.reviewedAt,null);assert.equal(e.editorial?.reviewer,null);assert.ok(e.editorial?.placeReview);assert.ok(e.placeDetails?.website?.value);assert.equal(e.images.length,0);}
  for(const id of (await readPlaceReview(root,'missing-photos-20261116')).manifest.ids)assert.equal(data.entities.find(e=>e.id===id)?.images.length,1);
 }finally{if(old===undefined)delete process.env.YOUNEW_PRIVATE_REVIEW_BUILD;else process.env.YOUNEW_PRIVATE_REVIEW_BUILD=old;}
});

test('paired text has source evidence and coordinates match selected BAG addresses',async()=>{
 const checks=JSON.parse(await readFile(`${dir}/source-checks.json`,'utf8'));
 for(const r of proof.records){const p=JSON.parse(r.attributes.place_enrichment);
  assert.deepEqual(p.locales.en.blocks.map((b:{id:string})=>b.id),p.locales.nl.blocks.map((b:{id:string})=>b.id));
  for(const s of p.sources){const c=Object.values(checks).find((x:any)=>x.finalUrl===s.url) as any;assert.ok(c);assert.equal(c.checkedAt,r.last_checked);assert.ok(c.httpStatus===200||(c.method==='web.run'&&c.verificationScope.includes('manual live check')));}
  const geo=Object.values(checks).find((x:any)=>x.finalUrl===p.coordinateEvidence.url) as any;assert.equal(geo.selectedAddress.woonplaatsnaam,'Amsterdam');
  const [lon,lat]=geo.selectedAddress.centroide_ll.match(/[0-9.]+/g).map(Number);assert.deepEqual(r.coordinates,{latitude:Number(lat.toFixed(7)),longitude:Number(lon.toFixed(7))});assert.equal(r.attributes.address,geo.selectedAddress.weergavenaam);assert.match(p.coordinateEvidence.method,/not a surveyed entrance/);
 }
 const issues=JSON.parse(await readFile(`${dir}/review-issues.json`,'utf8'));assert.deepEqual(issues.issues.map((x:any)=>x.id).sort(),['place.de-nieuwe-kerk-amsterdam','place.oba-oosterdok']);assert.ok(issues.issues.every((x:any)=>x.blockingBeforePublication));
 const nieuwe=JSON.parse(proof.records.find(r=>r.id==='place.de-nieuwe-kerk-amsterdam')!.attributes.place_enrichment);assert.match(nieuwe.locales.en.blocks.find((b:any)=>b.id==='hours').text,/different hours/);assert.match(nieuwe.locales.nl.blocks.find((b:any)=>b.id==='hours').text,/andere tijden/);
});

test('all 32 existing photo-package files remain byte-identical to fa0ec02',async()=>{
 const baseline=JSON.parse(await readFile(`${dir}/evidence/preserved-pr75.json`,'utf8'));assert.equal(baseline.commit,'fa0ec02db9bf9a7eda9a285b6b6a230daf34bf2a');assert.equal(Object.keys(baseline.files).length,32);
 for(const [file,digest] of Object.entries(baseline.files))assert.equal(sha256(await readFile(`${root}/${file}`)),digest,file);
});

test('ten revisions conform to the existing entity schema without changing iOS',()=>{
 const result=spawnSync('python3',['-c',`
import sys,pathlib,json,importlib.util
root=pathlib.Path(sys.argv[1]);sys.path.insert(0,str(root/'scripts'))
spec=importlib.util.spec_from_file_location('data_importer',root/'scripts/import-data-project.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
schema=json.loads((root/'DataProject/schema/entity.schema.json').read_text())
for r in json.loads((root/'DataProject/editorial/${batch}/records.json').read_text())['records']:m.validate_schema(r,schema,schema,r['id'])
`,root],{encoding:'utf8'});assert.equal(result.status,0,result.stderr);
});
