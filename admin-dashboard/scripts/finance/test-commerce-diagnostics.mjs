import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, writeFile, readFile, rm, stat } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { commerceDiagnosticsReader, collectCommerceDiagnostics, emptyCommerceDiagnostics, commerceReportState, commerceReportLines, COMMERCE_ORIGIN, COMMERCE_PROJECT, DIAGNOSTICS_MAX_AGE_MS } from './commerce-diagnostics.mjs';
import { run } from './run.mjs';
import { startPostgres, checkout, event, finishInput, paid, other } from '../../services/digital-commerce/supabase/tests/postgres.mjs';

const encode = value => Buffer.from(JSON.stringify(value)).toString('base64url');
const fixtureKey = (claims = {}) => `${encode({ alg: 'HS256' })}.${encode({ role: 'service_role', ref: COMMERCE_PROJECT, ...claims })}.synthetic_not_a_real_signature`;
const config = { enabled: true, origin: COMMERCE_ORIGIN, expectedAccountId: 'acct_fixture', environment: 'sandbox' };
const scope = { accountId: 'acct_fixture', environment: 'sandbox', payments: [], evidence: 'synthetic scope' };
const diagnostic = { queued: 0, deadLetters: 0, notificationDeadLetters: 0, exceptions: [] };

test('fixed project and action allowlist reject alternate origins, client tokens and writes before fetch', async () => {
  let calls = 0; const options = { fetcher: async () => { calls++; return Response.json({}); } };
  for (const origin of ['https://other.supabase.co', `${COMMERCE_ORIGIN}/`, `${COMMERCE_ORIGIN}?x=1`]) {
    assert.throws(() => commerceDiagnosticsReader({ ...config, origin }, fixtureKey(), options));
  }
  for (const key of [undefined, 'sb_secret_opaque', fixtureKey({ role: 'anon' }), fixtureKey({ ref: 'other' })]) {
    assert.throws(() => commerceDiagnosticsReader(config, key, options));
  }
  const read = commerceDiagnosticsReader(config, fixtureKey(), options);
  await assert.rejects(read('checkout_claim'), /action_not_allowed/); assert.equal(calls, 0);
});

test('temporary failures have a finite retry and never persist the provider error body', async () => {
  let calls = 0;
  const read = commerceDiagnosticsReader(config, fixtureKey(), { sleep: async () => {}, fetcher: async (url, init) => {
    calls++; assert.equal(url.origin, COMMERCE_ORIGIN); assert.equal(url.pathname, '/rest/v1/rpc/arrival_commerce_command');
    assert.equal(init.method, 'POST'); assert.equal(init.redirect, 'error'); assert.equal(init.cache, 'no-store');
    assert.deepEqual(JSON.parse(init.body), { p_action: 'diagnostics', p_input: {} });
    return new Response('secret_provider_body', { status: 503 });
  } });
  await assert.rejects(read('diagnostics'), error => error.message === 'commerce_read_http_503'); assert.equal(calls, 3);
});

test('authentication errors, long Retry-After and malformed responses do not trigger repeated calls', async () => {
  for (const [body, init] of [['secret', { status: 401 }], ['secret', { status: 429, headers: { 'retry-after': '60' } }], ['not json', { status: 200 }]]) {
    let calls = 0; const read = commerceDiagnosticsReader(config, fixtureKey(), { fetcher: async () => { calls++; return new Response(body, init); } });
    await assert.rejects(read('diagnostics')); assert.equal(calls, 1);
  }
});

test('request deadline, streamed response size and unfinished body are bounded', async () => {
  let calls = 0;
  const late = commerceDiagnosticsReader(config, fixtureKey(), { deadline: 0, fetcher: async () => { calls++; } });
  await assert.rejects(late('diagnostics'), /deadline/); assert.equal(calls, 0);
  const large = commerceDiagnosticsReader(config, fixtureKey(), { fetcher: async () => new Response('a'.repeat(1_000_001)) });
  await assert.rejects(large('diagnostics'), /response_limit/);
  const keepAlive = setInterval(() => {}, 100);
  try {
    const stalled = commerceDiagnosticsReader(config, fixtureKey(), { timeoutMs: 20, fetcher: async () => new Response(new ReadableStream({ start(controller) { controller.enqueue(new TextEncoder().encode('{}')); } })) });
    await assert.rejects(stalled('diagnostics'), /source_timeout/);
  } finally { clearInterval(keepAlive); }
});

test('scope/account/environment failures stop before diagnostics and incomplete counters fail closed', async () => {
  for (const mutation of [{ accountId: 'acct_other' }, { environment: 'live' }]) {
    const calls = []; await assert.rejects(collectCommerceDiagnostics(async action => { calls.push(action); return { ...scope, ...mutation }; }, config), /scope_mismatch/);
    assert.deepEqual(calls, ['finance_scope']);
  }
  for (const queued of [undefined, null, -1, '0']) {
    await assert.rejects(collectCommerceDiagnostics(async action => action === 'finance_scope' ? scope : { ...diagnostic, queued }, config), /diagnostics_invalid/);
  }
});

test('zero observed queues never imply worker health or zero pending notifications; old evidence becomes stale', async () => {
  const now = new Date();
  const evidence = await collectCommerceDiagnostics(async action => action === 'finance_scope' ? scope : diagnostic, config, now, { clock: () => now });
  assert.equal(evidence.paymentPending, 0); assert.equal(evidence.notificationPending, null); assert.equal(evidence.workerLiveness, 'unknown');
  const stale = commerceReportState(evidence, new Date(+now + DIAGNOSTICS_MAX_AGE_MS));
  assert.equal(stale.status, 'stale'); assert.equal(stale.paymentPending, null); assert.equal(stale.lastObserved.paymentPending, 0);
  assert.match(commerceReportLines(evidence, new Date(+now + DIAGNOSTICS_MAX_AGE_MS)).join('\n'), /устарел/);
  assert.equal(emptyCommerceDiagnostics().paymentDeadLetters, null);
});

test('an exception created during RPC collection is included at the honest completion timestamp; future evidence still fails', async () => {
  const start = new Date('2026-09-19T12:00:00Z'); const end = new Date(+start + 4000);
  const raw = { ...diagnostic, exceptions: [{ code: 'provider_unavailable', createdAt: +start + 2000 }] };
  const read = async action => action === 'finance_scope' ? scope : raw;
  const result = await collectCommerceDiagnostics(read, config, start, { clock: () => end });
  assert.equal(result.observedAt, end.toISOString()); assert.equal(result.ownerExceptionCount, 1);
  assert.equal(result.ownerExceptionGroups[0].oldestAt, new Date(+start + 2000).toISOString());
  raw.exceptions[0].createdAt = +end + 1;
  await assert.rejects(collectCommerceDiagnostics(read, config, start, { clock: () => end }), /exception_invalid/);
});

test('private exception identifiers and unknown arbitrary code text are not exported', async () => {
  const now = new Date(); const privateText = 'secret_provider_string';
  const result = await collectCommerceDiagnostics(async action => action === 'finance_scope' ? { ...scope, payments: [{ paymentIntentId: 'pi_private', source: 'younew-primary' }] }
    : { ...diagnostic, exceptions: [{ id: 'event:evt_private', orderId: other, code: privateText, createdAt: +now - 1000 }] }, config, now);
  assert.deepEqual(result.ownerExceptionGroups, [{ code: 'other_exception_requires_review', count: 1, oldestAt: new Date(+now - 1000).toISOString() }]);
  for (const value of [privateText, 'evt_private', 'pi_private', other]) assert.ok(!JSON.stringify(result).includes(value));
});

async function inputs(root, commerceDiagnostics = config) {
  const now = new Date(); const accountingPath = join(root, 'accounting.json');
  await writeFile(accountingPath, JSON.stringify({ version: 1, checkedAt: now.toISOString(), method: 'SYNTHETIC LOCAL ACCEPTANCE ONLY', months: [now.toISOString().slice(0, 7)], rows: [], coverage: [], subscriptions: [], customers: [], observations: [], decisions: [] }));
  const configPath = join(root, 'config.json');
  await writeFile(configPath, JSON.stringify({ enabled: true, accountingSnapshotPath: accountingPath, commerceDiagnostics }));
  return { configPath, output: join(root, 'output') };
}

test('disabled configuration makes no commerce calls; missing key is unknown in the actual report', async () => {
  const root = await mkdtemp(join(tmpdir(), 'younew-commerce-report-'));
  try {
    const files = await inputs(root, { ...config, enabled: false }); let calls = 0;
    const commerceTransport = { fetcher: async () => { calls++; throw new Error('must not call'); } };
    let result = await run(files.configPath, files.output, { env: {}, commerceTransport });
    let report = JSON.parse(await readFile(join(result.directory, 'WEEKLY_REPORT.json')));
    assert.equal(report.commerceOperations.status, 'disabled'); assert.equal(report.commerceOperations.paymentPending, null);
    await inputs(root); result = await run(files.configPath, files.output, { env: {}, commerceTransport });
    report = JSON.parse(await readFile(join(result.directory, 'WEEKLY_REPORT.json')));
    assert.equal(report.commerceOperations.status, 'unavailable'); assert.equal(report.commerceOperations.paymentDeadLetters, null); assert.equal(calls, 0);
    assert.ok(report.decisions.some(value => value.includes('commerce_service_key_missing_or_invalid')));
  } finally { await rm(root, { recursive: true, force: true }); }
});

test('real PostgreSQL queue and dead letter flow through fixed collector into actual private owner report; later failure removes current counts', async () => {
  const db = startPostgres(); const root = await mkdtemp(join(tmpdir(), 'younew-commerce-pg-report-'));
  try {
    await db.reset(); const order = await checkout(db); await event(db, order, 'evt_fixture_paid');
    await db.rpc('finish', finishInput(await db.rpc('claim'), paid)); await db.rpc('notify');
    await db.rpc('receive', { id: 'evt_fixture_unbound', digest: 'b'.repeat(64), referenceKind: 'payment', referenceId: 'pi_fixture_unbound' });
    for (let index = 0; index < 5; index++) {
      const job = await db.rpc('claim'); await db.rpc('fail', { id: job.id, token: job.token, code: 'order_binding_not_ready' });
      if (index < 4) db.sql("update arrival_commerce_private.inbox set next_at=clock_timestamp() where id='evt_fixture_unbound'");
    }
    await event(db, await checkout(db, other), 'evt_fixture_pending');
    const files = await inputs(root); const actions = [];
    const commerceTransport = { fetcher: async (url, init) => {
      assert.equal(url.origin, COMMERCE_ORIGIN); assert.equal(url.pathname, '/rest/v1/rpc/arrival_commerce_command');
      const body = JSON.parse(init.body); assert.deepEqual(body.p_input, {}); actions.push(body.p_action);
      assert.ok(['finance_scope', 'diagnostics'].includes(body.p_action));
      return Response.json(await db.rpc(body.p_action, body.p_input));
    } };
    const first = await run(files.configPath, files.output, { env: { YOUNEW_COMMERCE_DIAGNOSTICS_SERVICE_ROLE_KEY: fixtureKey() }, commerceTransport });
    assert.deepEqual(actions, ['finance_scope', 'diagnostics']);
    const report = JSON.parse(await readFile(join(first.directory, 'WEEKLY_REPORT.json')));
    const receipt = await readFile(join(first.directory, 'RECEIPT.json'), 'utf8');
    assert.equal(report.commerceOperations.paymentPending, 1); assert.equal(report.commerceOperations.paymentDeadLetters, 1);
    assert.equal(report.commerceOperations.ownerExceptionCount, 1); assert.equal(report.commerceOperations.notificationPending, null);
    assert.equal(report.commerceOperations.workerLiveness, 'unknown'); assert.equal(report.weeklyReports[0].operatingResult, null);
    assert.equal(report.synchronization.commerce.currentSuccessfulAt, report.commerceOperations.observedAt);
    assert.equal(report.synchronization.commerce.lastSuccessfulAt, report.commerceOperations.observedAt);
    assert.match(await readFile(join(first.directory, 'WEEKLY_REPORT.md'), 'utf8'), /order_binding_not_ready/);
    const snapshot = JSON.parse(await readFile(join(first.directory, 'FINANCE_SNAPSHOT.json')));
    assert.equal(snapshot.rows.length, 0); assert.ok(snapshot.decisions.some(value => value.includes('owner action required')));
    const observation = snapshot.observations.find(item => item.label === 'Arrival Commerce operations').detail;
    assert.ok(observation.includes(report.commerceOperations.expiresAt)); assert.match(observation, /требуется новое чтение/);
    const serialized = JSON.stringify(report) + JSON.stringify(snapshot) + await readFile(join(first.directory, 'COMMERCE_DIAGNOSTICS.json'), 'utf8');
    for (const value of [fixtureKey(), 'evt_fixture', 'pi_fixture', order.orderId, other]) assert.ok(!serialized.includes(value));
    assert.equal((await stat(join(first.directory, 'COMMERCE_DIAGNOSTICS.json'))).mode & 0o777, 0o600);
    const second = await run(files.configPath, files.output, { env: {}, commerceTransport });
    assert.notEqual(first.directory, second.directory); assert.equal(await readFile(join(first.directory, 'RECEIPT.json'), 'utf8'), receipt);
    const current = JSON.parse(await readFile(join(files.output, 'CURRENT_FINANCE_SNAPSHOT.json')));
    assert.ok(current.observations.find(item => item.label === 'Arrival Commerce operations').detail.includes('unavailable'));
    assert.ok(!current.decisions.some(value => value.includes('owner action required: payment dead letters 1')));
    const failedReport = JSON.parse(await readFile(join(second.directory, 'WEEKLY_REPORT.json')));
    assert.equal(failedReport.commerceOperations.paymentDeadLetters, null);
    assert.equal(failedReport.synchronization.commerce.currentSuccessfulAt, null);
    assert.equal(failedReport.synchronization.commerce.lastSuccessfulAt, report.commerceOperations.observedAt);
    assert.equal(failedReport.commerceOperations.lastWorkerSuccessAt, null);
    assert.equal(actions.length, 2);
  } finally { db.close(); await rm(root, { recursive: true, force: true }); }
});
