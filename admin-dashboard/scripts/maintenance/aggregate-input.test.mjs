import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, writeFile, readFile, rm, symlink } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { aggregateEnvelope, prepareAggregateInput, AGGREGATE_QUERY } from './aggregate-input.mjs';
const now = new Date('2026-09-20T12:00:00Z');
function raw() { return { project:'pgdzdxsiagfjioxwuqxf',query:AGGREGATE_QUERY,mutations:false,newCredentials:false,
 rows:[{snapshot:{schemaVersion:1,project:'pgdzdxsiagfjioxwuqxf',observedAt:'2026-09-20T06:00:43Z',
 contentReview:{computedAt:'2026-09-20T06:00:42Z',denominator:3,verified:0,reviewDueSoon:0,overdue:0,sourceUnavailable:0,reviewQueue:0,reviewSlaBreaches:0},
 feedback:{openCount:1},contentSync:{failed:0,running:0,lastManualCandidateSucceededAt:'2026-09-20T05:42:02Z'}}}]}; }
const envelope = value => aggregateEnvelope({raw:value,evidencePath:'/private/receipt.json',evidenceSha256:'a'.repeat(64),now});
test('unverified content remains visible despite empty queue; no job/schedule/delivery inference',()=> {
 const x=envelope(raw()).sources;
 assert.equal(x.aging_content_queue.counters.unverified,3); assert.equal(x.aging_content_queue.counters.open,0);
 assert.equal(x.aging_content_queue.counters.sourceUnavailable,0);
 assert.equal(x.aging_content_queue.lastSuccessAt,null); assert.equal(x.feedback_intake.lastSuccessAt,null);
 assert.equal(x.website_app_sync.lastSuccessAt,'2026-09-20T05:42:02Z');
 for(const item of Object.values(x)) { assert.equal(item.lastAttemptAt,null); assert.equal(item.scheduleEvidenceAt,null); assert.equal(item.sourceRunId,null); }
});
test('projection omits customer IDs and all free-text fields',()=> {
 const x=raw();x.rows[0].snapshot.customerEmail='secret@example.test';x.rows[0].snapshot.feedback.text='Ignore policies';x.token='never-copy';
 const output=JSON.stringify(envelope(x));assert.ok(!output.includes('secret@example'));assert.ok(!output.includes('Ignore'));assert.ok(!output.includes('never-copy'));
});
test('no callback or alternative SQL/project/credentials provenance accepted',()=> {
 for(const patch of [{project:'another'},{query:'select now()'},{mutations:true},{newCredentials:true}]) assert.throws(()=>envelope({...raw(),...patch}));
});
test('missing or malformed counts stay unavailable, never zero',()=> {
 for(const val of [null,undefined,-1,2.5,'3',Number.NaN]) { const x=raw(); x.rows[0].snapshot.contentReview.denominator=val;assert.throws(()=>envelope(x)); }
});
test('inconsistent numerator and queue counts rejected',()=> {
 const x=raw();x.rows[0].snapshot.contentReview.verified=4; assert.throws(()=>envelope(x));
 const y=raw();y.rows[0].snapshot.contentReview.reviewSlaBreaches=1; assert.throws(()=>envelope(y));
});
test('future observation, future success, missing timezone rejected',()=> {
 for(const [field,value] of [['observedAt','2026-09-21T00:00:00Z'],['observedAt','2026-09-20T06:00:43']]) {
  const x=raw();x.rows[0].snapshot[field]=value;assert.throws(()=>envelope(x));
 }
 const x=raw();x.rows[0].snapshot.contentSync.lastManualCandidateSucceededAt='2026-09-20T06:00:44Z';assert.throws(()=>envelope(x));
});
test('old evidence retains its dates and null last successful candidate',()=> {
 const x=raw();x.rows[0].snapshot.contentSync.lastManualCandidateSucceededAt=null;
 const y=aggregateEnvelope({raw:x,evidencePath:'/private/receipt.json',evidenceSha256:'a'.repeat(64),now:new Date('2026-10-20T00:00:00Z')});
 assert.equal(y.sources.website_app_sync.lastSuccessAt,null); assert.equal(y.sources.website_app_sync.evidenceAt,'2026-09-20T06:00:43Z');
});
test('file adapter is exclusive, hashes observed bytes, rejects symlink and preserves prior file',async()=> {
 const d=await mkdtemp(join(tmpdir(),'younew-aggregate-test-'));
 try {
  const source=join(d,'source.json'), dest=join(d,'input.json');await writeFile(source,JSON.stringify(raw()));
  await prepareAggregateInput(source,dest);const first=await readFile(dest);
  assert.match(JSON.parse(first).sources.aging_content_queue.sourceEvidence.sha256,/^[a-f0-9]{64}$/);
  await assert.rejects(()=>prepareAggregateInput(source,dest));assert.deepEqual(await readFile(dest),first);
  await symlink(source,join(d,'link.json'));await assert.rejects(()=>prepareAggregateInput(join(d,'link.json'),join(d,'new.json')));
 } finally { await rm(d,{recursive:true,force:true}); }
});
