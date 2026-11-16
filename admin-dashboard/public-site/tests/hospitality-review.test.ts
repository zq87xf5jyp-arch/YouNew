import {pendingReviewRoot} from './place-review-fixture.ts';
import test, {after} from 'node:test';
import assert from 'node:assert/strict';
import {readFile,mkdtemp,writeFile,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {readPlaceReview,applyPlaceReview,sha256,assertCompatibleReviewChain} from '../scripts/place-review.mjs';
import {verifyReviewSelection,composeTextAndPhotoReview} from '../scripts/review-selection.mjs';
import {loadEditorialRelease} from '../scripts/editorial-release.mjs';
import {buildPublicDataset,paths} from '../scripts/generate-public-content.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
// Freeze this suite's historical publication boundary; current approval is tested separately.
const history=await pendingReviewRoot(root,['pr75-integration-20261116']);
after(()=>history.cleanup());
const selectionPath='DataProject/editorial/selections/pr75-fea2401-20261116/selection.json';
const selectionDigest='defc64135bfe6c273f5d70a04ecec61714301778278e3634af2cb449ce38267a';
const batches=['leiden-hospitality-20261116','hospitality-followup-20261116'];
const json=async(p:string)=>JSON.parse(await readFile(join(root,p),'utf8'));

test('frozen fea2401 selection binds all 145 files and distinguishes images from objects',async()=>{
 const s=await verifyReviewSelection(root,selectionPath,selectionDigest);
 assert.equal(s.sourceCommit,'fea2401cc937a258e0ab7293a7d5e912a5bee528');assert.equal(Object.keys(s.files).length,145);
 assert.deepEqual(s.batches.map(b=>[b.records,b.blocksEnNl,b.photos]),[[10,102,10],[10,140,8],[5,50,5]]);
 assert.equal(new Set(s.batches.flatMap(b=>b.ids)).size,23);
 assert.equal(Object.values(s.amsterdamPlacement).filter(p=>p==='dated_hero_candidate').length,9);
 assert.equal(s.amsterdamPlacement['place.de-nieuwe-kerk-amsterdam'],'archive_gallery_only');
});

test('selection verification rejects changed materials, wrong digest and path escape',async()=>{
 await assert.rejects(()=>verifyReviewSelection(root,selectionPath,'0'.repeat(64)),/digest changed/);
 const temp=await mkdtemp(join(tmpdir(),'younew-selection-'));
 try{
  const material=Buffer.from('original');await writeFile(join(temp,'material.txt'),'changed');
  const files:Record<string,{bytes:number;sha256:string}>={'material.txt':{bytes:material.length,sha256:sha256(material)}};
  const s={status:'needs_review',publicationAuthorized:false,approvedAt:null,reviewerId:null,sourceCommit:'a'.repeat(40),files};
  let bytes=JSON.stringify(s);await writeFile(join(temp,'selection.json'),bytes);
  await assert.rejects(()=>verifyReviewSelection(temp,'selection.json',sha256(bytes)),/material changed|size changed/);
  s.files={'../outside':{bytes:0,sha256:sha256('')}};
  bytes=JSON.stringify(s);await writeFile(join(temp,'selection.json'),bytes);
  await assert.rejects(()=>verifyReviewSelection(temp,'selection.json',sha256(bytes)),/escapes repository/);
 }finally{await rm(temp,{recursive:true,force:true});}
});

test('Kazerne and Supernova composition retains every new text block and exact original media',async()=>{
 const base=await readPlaceReview(root,'priority-cities-20261115'),text=await readPlaceReview(root,'priority-cities-followup-20261116'),photo=await readPlaceReview(root,'missing-photos-20261116');
 const saved=await json('DataProject/editorial/selections/pr75-fea2401-20261116/composition-review.json');
 assert.equal(saved.publicationAuthorized,false);assert.equal(saved.sourceSelectionSha256,selectionDigest);
 const combined=[];
 for(const id of ['restaurant.eindhoven-kazerne','hotel.rotterdam-supernova']){
  const b=base.records.find(r=>r.id===id)!,t=text.records.find(r=>r.id===id)!,p=photo.records.find(r=>r.id===id)!;
  const c=composeTextAndPhotoReview(b,t,p);combined.push(c);assert.deepEqual(c.images,p.images);assert.equal(c.lifecycle_status,'draft');
  for(const loc of ['en','nl']){assert.deepEqual(JSON.parse(c.attributes.place_enrichment).locales[loc].blocks,JSON.parse(t.attributes.place_enrichment).locales[loc].blocks);assert.equal(JSON.parse(c.attributes.place_enrichment).locales[loc].alt,JSON.parse(p.attributes.place_enrichment).locales[loc].alt);}
  assert.deepEqual(JSON.parse(c.attributes.place_enrichment).sources,JSON.parse(t.attributes.place_enrichment).sources);
  assert.throws(()=>composeTextAndPhotoReview(b,{...t,images:p.images},p),/already changes photos/);
  assert.throws(()=>composeTextAndPhotoReview(b,t,{...p,attributes:{...p.attributes,slug:'changed'}}),/changed approved facts/);
 }
 assert.deepEqual(combined,saved.records);assert.equal(sha256(JSON.stringify(combined)),saved.recordsSha256);
 // Future approval of both siblings must still fail, independent of private flags.
 for(const pair of [[text,photo],[photo,text]])assert.throws(()=>assertCompatibleReviewChain([base.manifest,...pair.map(p=>({...p.manifest,status:'approved',publicationAuthorized:true}))]),/explicit composition/);
 assert.doesNotThrow(()=>assertCompatibleReviewChain([base.manifest,text.manifest]));
});

for(const batch of batches)test(`${batch}: ten existing sourced EN/NL cards preserve identity, base facts and schema`,async()=>{
 const proof=await readPlaceReview(root,batch);assert.equal(proof.records.length,10);assert.equal(proof.reviewer,null);assert.equal(proof.manifest.publicationAuthorized,false);
 const checks=await json(`DataProject/editorial/${batch}/source-checks.json`);let added=0;
 for(const r of proof.records){
  const base=await json(proof.manifest.baseFiles[r.id].file);const prior=base.records.find((x:{id:string})=>x.id===r.id);const p=JSON.parse(r.attributes.place_enrichment);
  assert.equal(r.attributes.slug,prior.attributes.slug);for(const f of ['id','entity_type','category','city_id','province_id'])assert.equal(r[f as keyof typeof r],prior[f]);
  assert.deepEqual(p.locales.en.blocks.map((b:{id:string})=>b.id),p.locales.nl.blocks.map((b:{id:string})=>b.id));
  for(const s of p.sources){const candidates=Object.values(checks) as Array<{url:string;finalUrl?:string;checkedAt:string;httpStatus:number}>;assert.ok(candidates.some(c=>(c.url===s.url||c.finalUrl===s.url)&&c.checkedAt===s.checked_at&&c.httpStatus===200),`${r.id}:${s.id} missing dated source evidence`);}
  if(batch.startsWith('hospitality-followup')){
   const old=JSON.parse(prior.attributes.place_enrichment);
   for(const loc of ['en','nl']){assert.deepEqual(p.locales[loc].blocks.slice(0,old.locales[loc].blocks.length),old.locales[loc].blocks);added+=p.locales[loc].blocks.length-old.locales[loc].blocks.length;}
   assert.deepEqual(r.images,prior.images);for(const s of old.sources)assert.deepEqual(p.sources.find((x:{id:string})=>x.id===s.id),s);
  }else{assert.equal(p.locales.en.blocks.length,5);assert.ok(!Object.hasOwn(r.attributes,'opening_hours'),'stale summary hours removed');}
 }
 if(batch.startsWith('hospitality-followup'))assert.equal(added,40);
 const result=spawnSync('python3',['-c',`import sys,pathlib,json,importlib.util
r=pathlib.Path(sys.argv[1]);sys.path.insert(0,str(r/'scripts'));s=importlib.util.spec_from_file_location('importer',r/'scripts/import-data-project.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);schema=json.loads((r/'DataProject/schema/entity.schema.json').read_text())
for x in json.loads((r/'DataProject/editorial/${batch}/records.json').read_text())['records']:m.validate_schema(x,schema,schema,x['id'])`,root],{encoding:'utf8'});assert.equal(result.status,0,result.stderr);
});

test('address matching excludes neighbouring units; re-used photos keep exact bytes',async()=>{
 const food=await readPlaceReview(root,batches[0]);
 for(const slug of ['30ml','verboden-toegang','dende']){
  const r=food.records.find(r=>r.attributes.slug===slug)!;const p=JSON.parse(r.attributes.place_enrichment);const url=new URL(p.coordinateEvidence.destinationURL);assert.ok(url.searchParams.get('destination'));
  const key=slug==='30ml'?'ml':slug==='verboden-toegang'?'verboden':'dende';const evidence=await json(`DataProject/editorial/${batches[0]}/evidence/${key}-bag.json`);
  assert.equal(evidence.selectedAddress.weergavenaam.split(',')[0],r.attributes.address.split(',')[0]);assert.ok(!/[AB]$/.test(evidence.selectedAddress.weergavenaam.split(',')[0]));
 }
 for(const width of [480,800,1200])assert.equal(sha256(await readFile(join(root,`DataProject/editorial/${batches[0]}/media/cafelaken-${width}.webp`))),sha256(await readFile(join(root,`DataProject/editorial/leiden-places-20261115/media/lakenhal-${width}.webp`))));
 const follow=await readPlaceReview(root,batches[1]);assert.ok(follow.records.find(r=>r.id==='cafe.utrecht-koffie-leute'));
});

test('twenty revisions never add IDs, inherit approval or enter ordinary output',async()=>{
 const release=await loadEditorialRelease(history.root),runtime=JSON.parse(await readFile(paths.source,'utf8'));assert.strictEqual(await applyPlaceReview(release,history.root,{}),release);
 const ordinary=buildPublicDataset(runtime,{editorialRelease:release}).content;assert.equal(ordinary.entities.length,96);
 const changed=await applyPlaceReview(release,history.root,{YOUNEW_PLACE_REVIEW:batches.join(','),YOUNEW_PRIVATE_REVIEW_BUILD:'1'});const old=process.env.YOUNEW_PRIVATE_REVIEW_BUILD;
 try{process.env.YOUNEW_PRIVATE_REVIEW_BUILD='1';const preview=buildPublicDataset(runtime,{editorialRelease:changed,privateReview:true}).content;assert.deepEqual(preview.entities.map(e=>e.id).sort(),ordinary.entities.map(e=>e.id).sort());
  for(const batch of batches){const p=await readPlaceReview(root,batch);for(const id of p.manifest.ids){const e=preview.entities.find(e=>e.id===id)!;assert.equal(e.status,'draft');assert.equal(e.indexable,false);assert.equal(e.editorial?.reviewer,null);assert.equal(e.editorial?.reviewedAt,null);}}
 }finally{if(old===undefined)delete process.env.YOUNEW_PRIVATE_REVIEW_BUILD;else process.env.YOUNEW_PRIVATE_REVIEW_BUILD=old;}
});

test('new archival photos remain separate, attributed, checksum-bound and never become current heroes',async()=>{
 const dir='DataProject/editorial/hospitality-release-review-20261116';
 await verifyReviewSelection(root,`${dir}/selection.json`,'4996a1f1b37a98491627162ea9a60d1e4bbb0967654d8beb4bded763cdffae5e');
 const media=await json(`${dir}/media-sources.json`);
 assert.equal(media.publicationAuthorized,false);assert.equal(media.accepted.length,2);assert.equal(media.rejected.length,2);
 for(const m of media.accepted){
  assert.equal(m.heroAllowed,false);assert.equal(m.publicationAuthorized,false);assert.equal(m.recommendedPlacement,'archive_gallery_only');
  assert.equal(m.license,'CC BY-SA 4.0');assert.equal(m.commercialUse,true);assert.equal(m.shareAlikeRequired,true);assert.ok(m.author&&m.authorUrl&&m.original.sha256);
  assert.match(m.captureDate,/^2015-/);for(const loc of ['en','nl'])assert.match(m.captions[loc],/2015/);
  for(const [name,value] of Object.entries(m.variants)){
   const v=value as {width:number;bytes:number;sha256:string};const bytes=await readFile(join(root,dir,'media',name));
   assert.equal(bytes.length,v.bytes);assert.equal(sha256(bytes),v.sha256);assert.ok(v.width<=m.original.width);
  }
  const food=await readPlaceReview(root,batches[0]);assert.deepEqual(food.records.find(r=>r.id===m.entityId)!.images,[]);
 }
 const collection=await json(`${dir}/collections.json`);assert.equal(collection.publicationAuthorized,false);assert.equal(collection.collections.length,4);
 const runtime=JSON.parse(await readFile(paths.source,'utf8')),release=await loadEditorialRelease(history.root);const content=buildPublicDataset(runtime,{editorialRelease:release}).content;
 const ids=new Set(content.entities.map(e=>e.id));for(const c of collection.collections)for(const id of c.entityIds)assert.ok(ids.has(id),id);
});
