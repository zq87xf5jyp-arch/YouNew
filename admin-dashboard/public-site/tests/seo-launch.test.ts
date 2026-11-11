import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import test from 'node:test';
const {projectPracticalGuideDraft,projectPublishedPracticalGuide}=await import(new URL('../scripts/practical-guide.mjs',import.meta.url).href);
import {returningWithinWindow} from '../src/lib/analytics/guide-return.ts';
const base=new URL('../../../DataProject/editorial/student-guides-20261111/',import.meta.url);
const manifest=JSON.parse(await readFile(new URL('manifest.json',base),'utf8'));
for(const item of manifest.guides) for(const file of item.files) test(`${file}: complete draft validates but cannot publish`,async()=>{
 const raw=JSON.parse(await readFile(new URL(file,base),'utf8'));
 const guide=projectPracticalGuideDraft(raw,{id:item.id,language:raw.locale,route:raw.seo.canonicalPath});
 assert.equal(guide.status,'draft');assert.equal(guide.reviewer,null);assert.equal(guide.publicationGate,null);
 assert.ok(guide.faqs.length>=3);assert.equal(projectPublishedPracticalGuide(raw),null);
 const broken=structuredClone(raw);broken.numberedSteps[0].sourceIDs=['made-up-source'];
 assert.throws(()=>projectPracticalGuideDraft(broken),/unknown source/);
 const unreviewed=structuredClone(raw);unreviewed.status='published';
 assert.throws(()=>projectPublishedPracticalGuide(unreviewed),/media|reviewer/);
});
test('return flag covers only 7 through 30 days and carries no identifier',()=>{
 for(const [date,want] of [['2026-11-04',true],['2026-10-12',true],['2026-11-05',false],['2026-10-11',false],['2026-11-12',false],['not-date',false],[null,false]] as const)assert.equal(returningWithinWindow(date,'2026-11-11'),want);
});
test('localized published payload keeps the English compatibility contract and full review gates',async()=>{
 const raw=JSON.parse(await readFile(new URL('G01-nl.json',base),'utf8'));
 const fixture={...raw,status:'published',confidenceLevel:'high',reviewer:{id:'test-only-reviewer',name:'Synthetic test editor',role:'Test fixture only',reviewerType:'human_editor',reviewedAt:'2026-11-11'},publicationGate:{status:'passed',checkedAt:'2026-11-11',checks:Object.fromEntries(['schema','factual_sources','links','language','media','duplicate_content','accessibility'].map(k=>[k,true])),notes:'Synthetic unit fixture, not an editorial approval.',evidenceIDs:['test-only']}};
 const parent={id:raw.id,title:raw.title,route:raw.seo.canonicalPath,language:'nl',mediaAssets:[{verified:true,alt:'Test fixture image',publicAssetPath:'/images/guide-workflow-nl.svg',assetURL:'https://example.invalid/test.svg',sourcePageURL:'https://example.invalid/source',licenseURL:'https://example.invalid/rights'}]};
 assert.equal(projectPublishedPracticalGuide(fixture,parent).seo.canonicalPath,raw.seo.canonicalPath);
 assert.throws(()=>projectPublishedPracticalGuide({...fixture,locale:'en'},parent),/page language/);
 assert.throws(()=>projectPublishedPracticalGuide({...fixture,publicationGate:null},parent),/publicationGate/);
 assert.throws(()=>projectPracticalGuideDraft(fixture,parent),/unapproved draft/);
});
