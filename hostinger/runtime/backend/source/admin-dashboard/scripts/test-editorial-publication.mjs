import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {editorialPublished} from '../src/lib/r4/editorial-publication.ts';
const root=new URL('../../../../../../',import.meta.url);
const data=JSON.parse(readFileSync(new URL('hostinger/runtime/backend/db/catalog-drafts.json',root)));
const approval=JSON.parse(readFileSync(new URL('../src/generated/editorial-approval.json',import.meta.url)));
const publication={...approval,status:'active',sourceCommit:'a'.repeat(40),publicProvenanceSha256:'b'.repeat(64),activatedAt:'2026-11-10T20:00:00Z'};
test('unactivated approval remains draft; exact activated documents are published',()=>{
 assert.equal(editorialPublished(data),false);
 assert.equal(editorialPublished({...data,publication}),true);
});
test('receipt and document mismatches fail closed',()=>{
 for(const patch of [{status:'approved'},{batchSha256:'0'.repeat(64)},{documentsSha256:'0'.repeat(64)},{activatedAt:'2099-01-01T00:00:00Z'},{sourceCommit:''}]) assert.throws(()=>editorialPublished({...data,publication:{...publication,...patch}}));
 const changed=structuredClone(data);changed.entities[0].summary+=' changed';
 assert.throws(()=>editorialPublished({...changed,publication}));
 assert.throws(()=>editorialPublished({...data,entities:data.entities.slice(1),publication}));
});
