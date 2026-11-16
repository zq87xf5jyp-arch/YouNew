import test, {after} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {readPlaceReview,applyPlaceReview,validatePlaceRecords,expansionReviews} from '../scripts/place-review.mjs';
import type {PlaceRevision} from '../scripts/place-review.mjs';
import {loadEditorialRelease} from '../scripts/editorial-release.mjs';
import {buildPublicDataset,paths} from '../scripts/generate-public-content.mjs';
import {pendingReviewRoot} from './place-review-fixture.ts';
const root=fileURLToPath(new URL('../../../',import.meta.url));
// This suite retains the historical pre-integration approval boundary.
const history=await pendingReviewRoot(root,['pr75-integration-20261116']);
after(()=>history.cleanup());
const batch='priority-cities-followup-20261116';
const proof=await readPlaceReview(root,batch),base=await readPlaceReview(root,'priority-cities-20261115');
type Revision=PlaceRevision & {last_checked:string;coordinates:unknown;related_entity_ids:string[]};
type Source={id:string;url:string;checked_at:string};
type Enrichment={sources:Source[];coordinateEvidence:unknown;locales:Record<'en'|'nl',{alt:string;blocks:{id:string;text:string;source_ids:string[]}[]}>};
const parse=(r:PlaceRevision)=>JSON.parse(r.attributes.place_enrichment) as Enrichment;

test('ten existing revisions add paired content while retaining approved facts, media and coordinates',async()=>{
 const release=await loadEditorialRelease(history.root);const known=new Set(buildPublicDataset(JSON.parse(await readFile(paths.source,'utf8')),{editorialRelease:release}).content.entities.map(e=>e.id));
 assert.equal(proof.records.length,10);assert.equal(proof.reviewer,null);assert.equal(proof.manifest.publicationAuthorized,false);
 assert.equal(proof.manifest.privateOnly,true);assert.deepEqual(proof.manifest.publicationScope?.addedIds,[]);
 const cities=new Set<string>();
 for(const r of proof.records as Revision[]){
  const prior=base.records.find(b=>b.id===r.id) as Revision;assert.ok(prior);cities.add(r.city_id);
  assert.deepEqual(r.coordinates,prior.coordinates);assert.deepEqual(r.images,prior.images);assert.equal(r.attributes.slug,prior.attributes.slug);
  const p=parse(r),b=parse(prior);assert.deepEqual(p.coordinateEvidence,b.coordinateEvidence);
  for(const locale of ['en','nl'] as const){assert.equal(p.locales[locale].blocks.length,7);assert.deepEqual(p.locales[locale].blocks.slice(0,5),b.locales[locale].blocks);assert.equal(p.locales[locale].alt,b.locales[locale].alt);}
  assert.deepEqual(p.locales.en.blocks.map(b=>b.id),p.locales.nl.blocks.map(b=>b.id));
  for(const s of b.sources)assert.deepEqual(p.sources.find(x=>x.id===s.id),s);
  for(const id of r.related_entity_ids){assert.notEqual(id,r.id);assert.ok(known.has(id),'related ID must already exist');}
  assert.equal(new Set(r.related_entity_ids).size,r.related_entity_ids.length);
 }
 assert.deepEqual([...cities].sort(),['den-haag','eindhoven','rotterdam','utrecht']);
});

test('source evidence keeps earlier dates and does not relabel a blocked request as a fresh check',async()=>{
 const checks=JSON.parse(await readFile(`${root}/DataProject/editorial/${batch}/source-checks.json`,'utf8')) as Record<string,{url:string;checkedAt:string;httpStatus:number;recheckedThisBatch?:boolean;reusedFrom?:string}>;
 for(const r of proof.records as Revision[]){
  const p=parse(r);assert.equal(r.last_checked,p.sources.map(s=>s.checked_at).sort().at(-1));
  for(const s of p.sources){const c=Object.values(checks).find(c=>c.url===s.url&&c.checkedAt===s.checked_at);assert.ok(c);assert.equal(c.httpStatus,200);if(s.checked_at==='2026-11-15'){assert.equal(c.recheckedThisBatch,false);assert.ok(c.reusedFrom);}}
 }
 assert.equal(Object.values(checks).filter(c=>c.checkedAt==='2026-11-16').length,11);
 const west=proof.records.find(r=>r.id==='nature.den-haag-westbroekpark') as Revision;assert.equal(west.last_checked,'2026-11-15');
 // An edit that silently refreshes an old source must fail the production reader.
 const altered=structuredClone(proof.records),p=parse(altered[0]);p.sources[0].checked_at='2026-11-16';altered[0].attributes.place_enrichment=JSON.stringify(p);
 assert.throws(()=>validatePlaceRecords(altered,proof.manifest.ids,new Map(base.records.map(r=>[r.id,r])),true,expansionReviews[batch]),/prior source dates/);
});

test('ordinary release is unchanged; private revision replaces IDs without additions',async()=>{
 const release=await loadEditorialRelease(history.root),runtime=JSON.parse(await readFile(paths.source,'utf8'));
 assert.strictEqual(await applyPlaceReview(release,history.root,{}),release);
 const ordinary=buildPublicDataset(runtime,{editorialRelease:release}).content;assert.equal(ordinary.entities.length,96);
 const privateRelease=await applyPlaceReview(release,history.root,{YOUNEW_PLACE_REVIEW:batch,YOUNEW_PRIVATE_REVIEW_BUILD:'1'});
 const old=process.env.YOUNEW_PRIVATE_REVIEW_BUILD;
 try{
  process.env.YOUNEW_PRIVATE_REVIEW_BUILD='1';const data=buildPublicDataset(runtime,{editorialRelease:privateRelease,privateReview:true}).content;
  assert.deepEqual(data.entities.map(e=>e.id).sort(),ordinary.entities.map(e=>e.id).sort());
  for(const id of proof.manifest.ids){const e=data.entities.find(e=>e.id===id);assert.ok(e);assert.equal(e.status,'draft');assert.equal(e.indexable,false);assert.equal(e.editorial?.reviewer,null);assert.equal(e.editorial?.reviewedAt,null);}
 }finally{if(old===undefined)delete process.env.YOUNEW_PRIVATE_REVIEW_BUILD;else process.env.YOUNEW_PRIVATE_REVIEW_BUILD=old;}
 await assert.rejects(()=>applyPlaceReview(release,history.root,{YOUNEW_PLACE_REVIEW:`${batch},missing-photos-20261116`,YOUNEW_PRIVATE_REVIEW_BUILD:'1'}),/separate private previews/);
});

test('follow-up revisions retain the existing DataProject and iOS-compatible entity schema',()=>{
 const result=spawnSync('python3',['-c',`
import sys,pathlib,json,importlib.util
root=pathlib.Path(sys.argv[1]);sys.path.insert(0,str(root/'scripts'))
spec=importlib.util.spec_from_file_location('data_importer',root/'scripts/import-data-project.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
schema=json.loads((root/'DataProject/schema/entity.schema.json').read_text())
for r in json.loads((root/'DataProject/editorial/${batch}/records.json').read_text())['records']:m.validate_schema(r,schema,schema,r['id'])
`,root],{encoding:'utf8'});assert.equal(result.status,0,result.stderr);
});

test('content follow-up cannot inherit approval from a base that is still pending',async()=>{
 const fixture=await pendingReviewRoot(history.root,['priority-cities-20261115']);
 try{const release=await loadEditorialRelease(fixture.root);await assert.rejects(()=>applyPlaceReview(release,fixture.root,{YOUNEW_PLACE_REVIEW:batch,YOUNEW_PRIVATE_REVIEW_BUILD:'1'}),/approved base in the release/);}finally{await fixture.cleanup();}
});
