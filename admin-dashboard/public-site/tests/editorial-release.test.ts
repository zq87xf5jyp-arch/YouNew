import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile,mkdtemp,mkdir,writeFile,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {loadEditorialRelease,projectEditorialRelease,approvalPath} from '../scripts/editorial-release.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
const read=async(p:string)=>JSON.parse(await readFile(resolve(root,p),'utf8'));
const approval=await read(approvalPath);
const records=(await Promise.all(Object.keys(approval.files).map(read))).flatMap(b=>b.records);
const reviewers=await read('DataProject/operations/reviewer-registry.json');
const opts={today:'2026-11-10'};
test('exact owner-reviewed batch publishes both languages without guessed coordinates or photos',async()=>{
  const release=await loadEditorialRelease();assert.equal(release.entities.length,71);
  assert.equal(release.entities.filter(e=>e.coordinate).length,3);
  assert.ok(release.entities.every(e=>e.images.length===0 && e.editorial.locales.en.title && e.editorial.locales.nl.title));
  for(const e of release.entities){const raw=records.find(r=>r.id===e.id);assert.equal(e.editorial.locales.en.summary,raw.description);assert.equal(e.editorial.locales.nl.summary,raw.attributes.description_nl);assert.deepEqual(e.coordinate,raw.coordinates);}
  assert.equal(release.entities.filter(e=>e.editorial.locales.nl.guide).length,10);
});
test('missing approval, reviewer or a changed approved identity is rejected',()=>{
  assert.throws(()=>projectEditorialRelease({...approval,status:'pending'},records,reviewers,opts),/approval/);
  assert.throws(()=>projectEditorialRelease(approval,records,{...reviewers,reviewers:[]},opts),/owner/);
  assert.throws(()=>projectEditorialRelease({...approval,ids:approval.ids.map(()=>approval.ids[0])},records,reviewers,opts),/identities/);
});
test('expired source evidence is rejected even with prior owner approval',()=>{
  assert.throws(()=>projectEditorialRelease(approval,records,reviewers,{today:'2028-11-10'}),/expired/);
});
test('photos and unsafe source links cannot be added to the approved publication',()=>{
  const photo=structuredClone(records);photo[0].images=[{url:'https://example.com/photo.jpg'}];
  assert.throws(()=>projectEditorialRelease(approval,photo,reviewers,opts),/photos/);
  const bad=structuredClone(records);bad[0].official_source.url='javascript:alert(1)';
  assert.throws(()=>projectEditorialRelease(approval,bad,reviewers,opts),/unsafe/);
});
test('guide facts require resolved sources; own business policy is not an official government source',()=>{
  const bad=structuredClone(records);bad.find(r=>r.practical_guide).practical_guide.numbered_steps[0].source_ids=['missing'];
  assert.throws(()=>projectEditorialRelease(approval,bad,reviewers,opts),/unresolved factual/);
  const business=projectEditorialRelease(approval,records,reviewers,opts).entities.filter(e=>e.editorial.section==='BUSINESS');
  assert.equal(business.length,2);assert.ok(business.every(e=>!e.source.isOfficial && e.source.status==='owner_approved_policy'));
});
test('changed source bytes invalidate the approval instead of silently publishing an edit',async()=>{
  const tmp=await mkdtemp(resolve(tmpdir(),'younew-editorial-'));
  try{
    for(const path of [approvalPath,'DataProject/operations/reviewer-registry.json',...Object.keys(approval.files)]){
      const to=resolve(tmp,path);await mkdir(dirname(to),{recursive:true});await writeFile(to,await readFile(resolve(root,path)));
    }
    const changed=Object.keys(approval.files)[0];await writeFile(resolve(tmp,changed),'{}');
    await assert.rejects(loadEditorialRelease(tmp),/approved content changed/);
  }finally{await rm(tmp,{recursive:true,force:true});}
});
