import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile, rm, readdir, mkdir } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createHash } from 'node:crypto';
import { EventEmitter } from 'node:events';
import { TARGETS, collect, run, SourceFailure, validatePublic, publicTransport, publicAddress, safeRedirect, logicalContext, fileSourceAdapters } from './maintenance.mjs';
const now = Date.parse('2026-09-21T08:00:00Z');
const H = 'a'.repeat(64);
const response = (target, override = {}) => {
  let value;
  if (target.kind === 'html') return { status: 200, headers: { 'content-type': 'text/html' }, body: `<html><title>YouNew — Netherlands guide</title><link rel="canonical" href="${target.url}"></html>`, ...override };
  if (target.kind === 'feed') value = { available: false, schemaVersion: 1, recordCount: 0, records: [] };
  else value = { available: true, schema_version: 1, content_version: H, generated_at: '2026-08-01T00:00:00Z', entity_count: 1, published_release_ids: ['test'], artifact: { schemaVersion: 1, datasetFingerprint: H, generatedAt: '2026-08-01T00:00:00Z', entities: [{}] } };
  return { status: 200, headers: { 'content-type': 'application/json', 'x-younew-dataset-fingerprint': H }, body: JSON.stringify(value), ...override };
};
const good = async target => response(target);
const options = { runKey: 'younew-2:week:2026-09-21', trigger: 'heartbeat', transport: good, clock: () => now, sleep: async () => {} };
const envelopeSource = key => ({ schemaVersion: 1, taskKey: key, sourceId: 'github:backup', evidenceAt: '2026-09-13T08:40:00Z', lastAttemptAt: '2026-09-13T08:32:43Z', lastSuccessAt: '2026-09-13T08:33:10Z', result: 'success', sourceRunId: '35428951974', sourceRunAttempt: 1, counters: { tables: 83 }, sourceEvidence: { path: '/private/test-receipt.json', sha256: H } });

test('five fixed targets, empty active feed valid, packaged old source dated, no delivery/schedule claim', async () => {
  const report = await collect(options);
  assert.equal(report.tasks.length, 11); assert.equal(report.status, 'partial');
  assert.equal(report.tasks.find(r => r.taskKey === 'public_content_feed').data.activeFeed, 'absent');
  assert.equal(report.tasks.find(r => r.taskKey === 'packaged_mobile_api').freshness, 'historical_source');
  for (const row of report.tasks.slice(5)) { assert.equal(row.data, null); assert.equal(row.lastSuccessAt, null); assert.equal(row.result, 'unknown'); }
  assert.equal(report.scheduledExecutionConfirmed, false); assert.equal(report.nativeRunId, null); assert.equal(report.notificationSent, false);
});
test('503 then200 retries bounded; terminal403/404 never retry', async () => {
  const counts = {};
  const report = await collect({ ...options, transport: async target => {
    const n = counts[target.taskKey] = (counts[target.taskKey] ?? 0) + 1;
    return response(target, { status: target.taskKey === 'public_home' && n === 1 ? 503 : target.taskKey === 'public_start' ? 403 : target.taskKey === 'public_housing' ? 404 : 200 });
  } });
  assert.equal(counts.public_home, 2); assert.equal(counts.public_start, 1); assert.equal(counts.public_housing, 1);
  assert.equal(report.tasks[1].failureCode, 'access_restricted'); assert.equal(report.tasks[2].lastSuccessAt, null);
});
test('persistent transient has only3 attempts; hung transports bounded by real total deadline', async () => {
  let count = 0;
  const report = await collect({ ...options, transport: async target => { count++; return response(target, { status: 503 }); } });
  assert.equal(count, 15); assert.ok(report.tasks.slice(0, 5).every(row => row.attemptCount === 3));
  const start = performance.now();
  const timed = await collect({ ...options, clock: Date.now, totalMs: 35, attemptMs: 15, transport: () => new Promise(() => {}), sleep: async () => {} });
  assert.ok(performance.now() - start < 500); assert.ok(timed.tasks.slice(0, 5).every(row => row.attemptCount <= 3 && row.result === 'unknown'));
});
test('malformed HTML/json/header mismatch/body overflow do not become200 success or retry', async () => {
  for (const [target, bad] of [[TARGETS[0], { body: '<title>404 YouNew</title>' }], [TARGETS[3], { body: '<html>Oops</html>' }], [TARGETS[4], { headers: { 'content-type': 'application/json' } }], [TARGETS[0], { body: Buffer.alloc(2097153) }]]) {
    assert.throws(() => validatePublic(target, response(target, bad), now));
  }
  let calls = 0; const report = await collect({ ...options, transport: async target => { calls++; return response(target, { body: '<title>other site</title>' }); } });
  assert.equal(calls, 5); assert.ok(report.tasks.every(row => row.result === 'unknown'));
});
test('historical source job success not replaced by fresh collection time; unavailable/malformed preserve prior success', async () => {
  const first = await collect({ ...options, sourceAdapters: { backup_restore: async () => envelopeSource('backup_restore') } });
  const known = first.tasks.find(row => row.taskKey === 'backup_restore');
  assert.equal(known.lastSuccessAt, '2026-09-13T08:33:10Z'); assert.equal(known.freshness, 'historical_source');
  const next = await collect({ ...options, previous: first, sourceAdapters: { backup_restore: async () => ({ ...envelopeSource('backup_restore'), counters: { tables: '0' } }) }, transport: async target => response(target, { status: 503 }) });
  const row = next.tasks.find(row => row.taskKey === 'backup_restore');
  assert.equal(row.result, 'unknown'); assert.equal(row.data, null); assert.equal(row.lastSuccessAt, known.lastSuccessAt);
  assert.equal(next.tasks[0].lastSuccessAt, first.tasks[0].lastSuccessAt); assert.equal(next.tasks[0].observedAt, null);
});
test('candidate-only source cannot become active feed or client delivery; future source invalid', async () => {
  const report = await collect({ ...options, sourceAdapters: { website_app_sync: async () => ({ ...envelopeSource('website_app_sync'), result: 'candidate_only' }) } });
  const row = report.tasks.find(row => row.taskKey === 'website_app_sync');
  assert.equal(row.data.candidateActivation, 'not_confirmed'); assert.equal(row.deliveryState, 'not_confirmed');
  const future = await collect({ ...options, sourceAdapters: { backup_restore: async () => ({ ...envelopeSource('backup_restore'), evidenceAt: '2030-01-01T00:00:00Z' }) } });
  assert.equal(future.tasks.find(r => r.taskKey === 'backup_restore').data, null);
});
test('logical Monday Amsterdam key separate from native run id; manual cannot look scheduled', () => {
  assert.deepEqual(logicalContext({ automationId: 'younew-2', trigger: 'heartbeat', now: new Date('2026-09-20T22:30:00Z') }), { runKey: 'younew-2:week:2026-09-21', trigger: 'heartbeat', nativeRunId: null });
  assert.throws(() => logicalContext({ automationId: 'younew-2', trigger: 'heartbeat', now: new Date('2026-09-22T08:00:00Z') }));
  assert.throws(() => logicalContext({ automationId: 'younew-2', trigger: 'manual', manualKey: 'week:2026-09-21' }));
});
test('immutable run reused before GET, no duplicate receipt, tampering fails closed', async () => {
  const output = await mkdtemp(join(tmpdir(), 'younew-maintenance-'));
  try {
    let calls = 0; const invoke = () => run({ ...options, output, enabled: true, transport: async target => { calls++; return response(target); } });
    const a = await invoke(), b = await invoke(); assert.equal(calls, 5); assert.equal(b.reused, true); assert.equal(b.directory, a.directory);
    assert.equal((await readdir(join(output, 'runs'))).length, 1); assert.equal(b.reportSent, false);
    await writeFile(join(a.directory, 'MAINTENANCE_REPORT.md'), 'tampered');
    await assert.rejects(invoke, /receipt_integrity_failed/); assert.equal(calls, 5);
  } finally { await rm(output, { recursive: true, force: true }); }
});
test('disabled/lock never invokes transport and preserves other owner lock', async () => {
  const output = await mkdtemp(join(tmpdir(), 'younew-maintenance-'));
  try {
    const transport = () => { throw new Error('must not call'); };
    assert.equal((await run({ ...options, output, enabled: false, transport })).status, 'disabled');
    await writeFile(join(output, '.maintenance.lock'), 'other owner');
    assert.equal((await run({ ...options, output, enabled: true, transport })).status, 'locked');
    assert.equal(await readFile(join(output, '.maintenance.lock'), 'utf8'), 'other owner');
  } finally { await rm(output, { recursive: true, force: true }); }
});
test('optional local source hash guard, only sanitized aggregate fields copied', async () => {
  const folder = await mkdtemp(join(tmpdir(), 'younew-maintenance-source-'));
  try {
    const evidence = join(folder, 'receipt.json'); await writeFile(evidence, '{"private":"not copied"}');
    const source = { ...envelopeSource('backup_restore'), sourceEvidence: { path: evidence, sha256: createHash('sha256').update(await readFile(evidence)).digest('hex') }, secret: 'NOT_COPIED' };
    const input = join(folder, 'sources.json'); await writeFile(input, JSON.stringify({ schemaVersion: 1, sources: { backup_restore: source } }));
    const adapters = await fileSourceAdapters(input); const report = await collect({ ...options, sourceAdapters: adapters });
    assert.ok(!JSON.stringify(report).includes('NOT_COPIED')); assert.ok(!JSON.stringify(report).includes('not copied'));
    await writeFile(evidence, '{}'); const after = await collect({ ...options, sourceAdapters: adapters });
    assert.equal(after.tasks.find(r => r.taskKey === 'backup_restore').failureCode, 'source_evidence_hash_mismatch');
  } finally { await rm(folder, { recursive: true, force: true }); }
});
test('transport denies private/mapped/mixed DNS and unsafe redirects without second request', async () => {
  for (const ip of ['127.0.0.1', '10.1.2.3', '169.254.169.254', '100.64.1.2', '192.0.2.1', '224.0.0.1', '::1', '::ffff:127.0.0.1', 'fe80::1', 'fc00::1', '2001:db8::1', '2002:7f00:1::']) assert.equal(publicAddress(ip), false, ip);
  assert.equal(publicAddress('93.184.216.34'), true);
  let requests = 0;
  const read = publicTransport({ lookupFn: async () => [{ address: '93.184.216.34', family: 4 }, { address: '127.0.0.1', family: 4 }], requestFn: () => { requests++; } });
  await assert.rejects(() => read(TARGETS[0], { signal: new AbortController().signal }), /dns_not_public/); assert.equal(requests, 0);
  for (const location of ['http://younew.nl/', 'https://localhost/', 'https://younew.nl/auth/callback', 'https://younew.nl/?code=x', 'https://other.nl/']) assert.throws(() => safeRedirect(TARGETS[0], location));
});
test('actual https wrapper pins public DNS, GET only, destroys overlarge body, caps redirect hops', async () => {
  let calls = 0;
  const requestFn = (url, config, onResponse) => {
    calls++; assert.equal(config.method, 'GET'); assert.equal(config.rejectUnauthorized, true); assert.equal(config.servername, 'younew.nl'); assert.equal(config.headers.Authorization, undefined);
    config.lookup(url.hostname, {}, (error, address) => { assert.equal(error, null); assert.equal(address, '93.184.216.34'); });
    const req = new EventEmitter(); req.end = () => queueMicrotask(() => {
      const incoming = new EventEmitter(); incoming.statusCode = 302; incoming.headers = { location: '/' }; incoming.destroy = () => {}; onResponse(incoming);
    }); return req;
  };
  const read = publicTransport({ lookupFn: async () => [{ address: '93.184.216.34', family: 4 }], requestFn });
  await assert.rejects(() => read(TARGETS[0], { signal: new AbortController().signal }), /redirect_limit/); assert.equal(calls, 3);
  let destroyed = false;
  const large = publicTransport({ lookupFn: async () => [{ address: '93.184.216.34', family: 4 }], requestFn: (_url, _cfg, callback) => {
    const req = new EventEmitter(); req.end = () => queueMicrotask(() => { const incoming = new EventEmitter(); incoming.statusCode = 200; incoming.headers = {}; incoming.destroy = () => { destroyed = true; }; callback(incoming); incoming.emit('data', Buffer.alloc(2097153)); }); return req;
  } });
  await assert.rejects(() => large(TARGETS[0], { signal: new AbortController().signal }), /body_limit/); assert.equal(destroyed, true);
});

test('429 terminal; homepage fallback, login and soft404 fail route identity', async () => {
  const report = await collect({ ...options, transport: async target => response(target, { status: 429 }) });
  assert.ok(report.tasks.slice(0, 5).every(row => row.attemptCount === 1 && row.failureCode === 'access_restricted'));
  assert.throws(() => validatePublic(TARGETS[1], response(TARGETS[0]), now), /page_identity_invalid/);
  assert.throws(() => validatePublic(TARGETS[1], response(TARGETS[1], { body: '<title>Login YouNew</title><link rel="canonical" href="https://younew.nl/start/">' }), now), /site_identity_invalid/);
});
test('success source namespace survives unknown then observed-null success, changed source cannot inherit', async () => {
  const first = await collect({ ...options, sourceAdapters: { backup_restore: async () => envelopeSource('backup_restore') } });
  const missing = await collect({ ...options, previous: first });
  const restored = await collect({ ...options, previous: missing, sourceAdapters: { backup_restore: async () => ({ ...envelopeSource('backup_restore'), lastSuccessAt: null }) } });
  assert.equal(restored.tasks.find(r => r.taskKey === 'backup_restore').lastSuccessAt, '2026-09-13T08:33:10Z');
  const changed = await collect({ ...options, previous: missing, sourceAdapters: { backup_restore: async () => ({ ...envelopeSource('backup_restore'), sourceId: 'different-source', lastSuccessAt: null }) } });
  assert.equal(changed.tasks.find(r => r.taskKey === 'backup_restore').lastSuccessAt, null);
});
test('same key wrong weekly date and previous future evidence fail before network', async () => {
  const output = await mkdtemp(join(tmpdir(), 'younew-maintenance-'));
  try {
    let calls = 0; const transport = async t => { calls++; return response(t); };
    const a = await run({ ...options, output, enabled: true, transport });
    await assert.rejects(() => run({ ...options, output, enabled: true, transport, clock: () => now + 7 * 86400000 }), /run_window_mismatch/);
    assert.equal(calls, 5);
    const rp = join(a.directory, 'MAINTENANCE_REPORT.json'), receiptPath = join(a.directory, 'RECEIPT.json');
    const report = JSON.parse(await readFile(rp)); report.tasks[0].lastSuccessAt = '2030-01-01T00:00:00Z'; await writeFile(rp, JSON.stringify(report));
    const receipt = JSON.parse(await readFile(receiptPath)); receipt.files['MAINTENANCE_REPORT.json'] = createHash('sha256').update(await readFile(rp)).digest('hex'); await writeFile(receiptPath, JSON.stringify(receipt));
    await assert.rejects(() => run({ ...options, output, enabled: true, transport }), /invalid_source_timestamp/); assert.equal(calls, 5);
  } finally { await rm(output, { recursive: true, force: true }); }
});
test('mobile internal artifact mismatch fails; aggregate denominators retained in report', async () => {
  const target = TARGETS[4], bad = response(target); const payload = JSON.parse(bad.body); payload.artifact = {}; bad.body = JSON.stringify(payload);
  assert.throws(() => validatePublic(target, bad, now), /packaged_artifact_mismatch/);
  const report = await collect({ ...options, sourceAdapters: { aging_content_queue: async () => ({ ...envelopeSource('aging_content_queue'), result: 'partial', lastSuccessAt: null, counters: { denominator: 3, verified: 0, unverified: 3, due: 0, overdue: 0 } }) } });
  assert.deepEqual(report.tasks.find(r => r.taskKey === 'aging_content_queue').data.counters, { denominator: 3, verified: 0, unverified: 3, due: 0, overdue: 0 });
});

test('timestamps require explicit UTC/offset and aggregate history is never a current execution', async () => {
  const source = envelopeSource('backup_restore'); source.evidenceAt = '2026-09-13T08:40:00';
  const report = await collect({ ...options, sourceAdapters: { backup_restore: async () => source } });
  assert.equal(report.tasks.find(r => r.taskKey === 'backup_restore').failureCode, 'invalid_source_timestamp');
  const mobile = response(TARGETS[4]), payload = JSON.parse(mobile.body); payload.generated_at = payload.artifact.generatedAt = '2026-08-01T00:00:00'; mobile.body = JSON.stringify(payload);
  assert.throws(() => validatePublic(TARGETS[4], mobile, now), /invalid_source_timestamp/);
});

test('receipt committed before pointer failure is recovered by reuse; older replay cannot rewind LATEST', async () => {
  const output = await mkdtemp(join(tmpdir(), 'younew-maintenance-recovery-'));
  try {
    let calls = 0; const transport = async target => { calls++; return response(target); };
    await assert.rejects(() => run({ ...options, output, enabled: true, transport, afterReceiptCommit: async () => { throw new Error('synthetic pointer failure'); } }), /synthetic pointer failure/);
    assert.equal(calls, 5); await assert.rejects(() => readFile(join(output, 'LATEST.json')), /ENOENT/);
    const recovered = await run({ ...options, output, enabled: true, transport }); assert.equal(recovered.reused, true); assert.equal(calls, 5);
    const first = JSON.parse(await readFile(join(output, 'LATEST.json'))); assert.equal(first.directory, recovered.directory);
    const later = await run({ ...options, output, enabled: true, transport, trigger: 'manual', runKey: 'younew-2:manual-later', clock: () => now + 1000 });
    assert.equal(calls, 10);
    await run({ ...options, output, enabled: true, transport, clock: () => now + 2000 });
    assert.equal(calls, 10); assert.equal(JSON.parse(await readFile(join(output, 'LATEST.json'))).runId, later.runId);
    await writeFile(join(output, 'LATEST.json'), '{}');
    await assert.rejects(() => run({ ...options, output, enabled: true, transport, clock: () => now + 3000 }), /invalid_latest/);
    assert.equal(calls, 10);
  } finally { await rm(output, { recursive: true, force: true }); }
});
