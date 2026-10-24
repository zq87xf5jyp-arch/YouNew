import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile, rm, mkdir, stat } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { collectStripe, stripeReader, reportingWindow, combineSnapshot, makeReport, validateJournal } from './collect.mjs';
import { run as execute } from './run.mjs';

const run = (config, output, options = {}) => execute(config, output, { ...options, clock: options.clock ?? (() => options.now ?? now) });

const now = new Date('2026-09-19T14:00:00Z');
const when = Date.parse('2026-09-18T12:00:00Z') / 1000;
const scope = { accountId: 'acct_fixture', environment: 'live', payments: [{ paymentIntentId: 'pi_fixture', source: 'younew-primary' }], evidence: 'trusted local commerce ledger' };
const blank = () => ({ version: 1, checkedAt: '2026-09-19T12:00:00Z', method: 'reviewed monthly source', months: ['2026-08', '2026-09'], rows: [], coverage: [], subscriptions: [], customers: [], observations: [], decisions: [] });
const row = (changes = {}) => ({ id: 'accounting-1', provider: 'reviewed-journal', reference: 'source-1', month: '2026-09', currency: 'EUR', metric: 'revenue', value: 10000, source: 'younew-primary', environment: 'live', verified: true, evidence: 'dated source statement', ...changes });
function fixture() {
  const state = { account: { object: 'account', id: 'acct_fixture' }, payment: { object: 'payment_intent', id: 'pi_fixture', livemode: true, status: 'succeeded', currency: 'eur', amount_received: 150000,
    latest_charge: { id: 'ch_fixture', object: 'charge', payment_intent: 'pi_fixture', livemode: true, paid: true, captured: true, status: 'succeeded', amount: 150000, amount_captured: 150000, amount_refunded: 0, currency: 'eur', created: when, disputed: false, balance_transaction: 'txn_charge' } },
    refunds: { object: 'list', has_more: false, data: [] }, transaction: { id: 'txn_charge', object: 'balance_transaction', source: 'ch_fixture', currency: 'eur', created: when, fee: 4750 }, calls: [] };
  const read = async (path, query) => {
    state.calls.push({ path, query });
    if (path === '/v1/account') return structuredClone(state.account);
    if (path === '/v1/payment_intents/pi_fixture') return structuredClone(state.payment);
    if (path === '/v1/balance_transactions/txn_charge') return structuredClone(state.transaction);
    if (path === '/v1/refunds') return structuredClone(state.refunds);
    throw new Error('unexpected provider path');
  };
  return { state, read };
}

test('read adapter only supports restricted matching keys, fixed GET endpoints and finite retry', async () => {
  for (const secret of [undefined, '', 'sk_live_fixture', 'rk_test_fixture']) assert.throws(() => stripeReader(secret, 'live'));
  let calls = 0;
  const reader = stripeReader('rk_live_fixture', 'live', { sleep: async () => {}, fetcher: async (url, init) => {
    calls++; assert.equal(url.hostname, 'api.stripe.com'); assert.equal(init.method, 'GET'); assert.equal(init.redirect, 'error');
    return new Response('{}', { status: 503 });
  } });
  await assert.rejects(reader('/v1/account'), /stripe_read_http_503/); assert.equal(calls, 3);
  await assert.rejects(reader('/v1/payouts'), /endpoint_not_allowed/); assert.equal(calls, 3);
});
test('permanent authentication errors and long provider backoff are not retried', async () => {
  for (const response of [new Response('{}', { status: 401 }), new Response('{}', { status: 429, headers: { 'retry-after': '60' } })]) {
    let calls = 0; const reader = stripeReader('rk_live_fixture', 'live', { fetcher: async () => { calls++; return response; } });
    await assert.rejects(reader('/v1/account')); assert.equal(calls, 1);
  }
});
test('deadline is enforced before any read', async () => {
  const reader = stripeReader('rk_live_fixture', 'live', { deadline: 0, fetcher: async () => { throw new Error('must not call'); } });
  await assert.rejects(reader('/v1/account'), /deadline/);
});
test('bound provider charge/fee are confirmed observations only, never revenue, coverage, MRR or bank payout', async () => {
  const { read, state } = fixture(); const result = await collectStripe(read, scope, now);
  assert.deepEqual(result.rows.map(item => item.metric), ['charge', 'fee']); assert.deepEqual(result.coverage, []);
  assert.equal(result.rows[0].value, 150000); assert.equal(result.rows[1].value, 4750);
  assert.equal(state.calls.length, 4); assert.equal(state.calls[3].query.payment_intent, 'pi_fixture');
  const { report } = makeReport(combineSnapshot(blank(), result, now), result, reportingWindow(undefined, now), now);
  assert.equal(report.weeklyReports[0].totals.charge.observed, 150000);
  assert.equal(report.weeklyReports[0].totals.charge.value, null);
  assert.equal(report.weeklyReports[0].totals.revenue.value, null);
  assert.equal(report.weeklyReports[0].totals.payout.value, null);
  assert.equal(report.weeklyReports[0].operatingResult, null);
});
for (const amount of [1000, 150000]) test(`gross refund ${amount} retains receipt and does not invent refund excluding VAT`, async () => {
  const { read, state } = fixture(); state.payment.latest_charge.amount_refunded = amount;
  state.refunds.data.push({ id: 're_fixture', object: 'refund', payment_intent: 'pi_fixture', charge: 'ch_fixture', status: 'succeeded', amount, created: when, currency: 'eur', balance_transaction: null });
  const result = await collectStripe(read, scope, now);
  assert.equal(result.events.find(item => item.type === 'refund_gross').value, amount);
  assert.ok(!result.rows.some(item => item.metric === 'refund'));
  assert.equal(result.rows.find(item => item.metric === 'charge').value, 150000);
});
test('refund period is its own event date, not original purchase date', async () => {
  const { read, state } = fixture(); state.payment.latest_charge.created = Date.parse('2026-08-01T12:00:00Z') / 1000;
  state.payment.latest_charge.amount_refunded = 150000;
  state.refunds.data.push({ id: 're_fixture', object: 'refund', payment_intent: 'pi_fixture', charge: 'ch_fixture', status: 'succeeded', amount: 150000, created: when, currency: 'eur', balance_transaction: null });
  const result = await collectStripe(read, scope, now);
  const { report } = makeReport(combineSnapshot(blank(), result, now), result, reportingWindow(undefined, now), now);
  assert.ok(!report.observedLiveProviderEvents.some(item => item.type === 'charge'));
  assert.equal(report.observedLiveProviderEvents.find(item => item.type === 'refund_gross').value, 150000);
});
for (const [label, mutate] of [
  ['wrong account', s => s.account.id = 'acct_other'],
  ['wrong payment environment', s => s.payment.livemode = false],
  ['wrong charge identity', s => s.payment.latest_charge.payment_intent = 'pi_other'],
  ['wrong balance source', s => s.transaction.source = 'ch_other'],
  ['wrong refund identity', s => s.refunds.data.push({ id: 're_x', object: 'refund', payment_intent: 'pi_other', charge: 'ch_fixture', currency: 'eur' })],
  ['inconsistent refund total', s => s.payment.latest_charge.amount_refunded = 1],
  ['invalid captured amount', s => s.payment.latest_charge.amount_captured = '150000']
]) test(`${label} fails closed`, async () => { const { state, read } = fixture(); mutate(state); await assert.rejects(collectStripe(read, scope, now)); });
test('sandbox values and USD are separated from live EUR', async () => {
  const { state, read } = fixture(); state.payment.livemode = state.payment.latest_charge.livemode = false;
  state.payment.currency = state.payment.latest_charge.currency = state.transaction.currency = 'usd';
  const result = await collectStripe(read, { ...scope, environment: 'sandbox' }, now);
  const { report } = makeReport(combineSnapshot(blank(), result, now), result, reportingWindow(undefined, now), now);
  assert.deepEqual(report.observedLiveProviderEvents, []); assert.equal(report.sandboxEventsExcluded, 2);
  assert.equal(report.monthlyReports.find(item => item.period === '2026-09' && item.currency === 'USD').totals.charge.observed, null);
});
test('duplicate scope, refund page repetition and partial pending states are explicit', async () => {
  const { read, state } = fixture();
  await assert.rejects(collectStripe(read, { ...scope, payments: [...scope.payments, ...scope.payments] }, now), /duplicate_payment/);
  state.refunds.data = [{ id: 're_x', object: 'refund', charge: 'ch_fixture', payment_intent: 'pi_fixture', currency: 'eur', status: 'pending' }];
  const partial = await collectStripe(read, scope, now); assert.ok(partial.exceptions.some(item => item.code === 'refund_not_final'));
  state.refunds.has_more = true; await assert.rejects(collectStripe(read, scope, now), /duplicate_refund_page/);
});
test('negative provider fee is flagged rather than coerced to zero expense', async () => {
  const { read, state } = fixture(); state.transaction.fee = -100;
  const result = await collectStripe(read, scope, now); assert.ok(!result.rows.some(item => item.metric === 'fee'));
  assert.ok(result.exceptions.some(item => item.code === 'fee_credit_or_invalid_fee_requires_accounting'));
});
test('fresh provider rows deduplicate manual charge evidence; incomplete current-month coverage cannot roll forward', async () => {
  const { read } = fixture(); const provider = await collectStripe(read, scope, now);
  const original = blank(); original.rows = [row({ provider: 'Stripe', reference: 'pi_fixture', metric: 'charge', value: 150000 })];
  original.coverage = ['2026-08', '2026-09'].map(month => ({ month, currency: 'EUR', metric: 'revenue', evidence: 'monthly review' }));
  const combined = combineSnapshot(original, provider, now);
  assert.equal(combined.rows.filter(item => item.metric === 'charge').length, 1);
  assert.deepEqual(combined.coverage.map(item => item.month), ['2026-08']);
});
test('dated journal can calculate actual weekly result only with complete interval coverage', async () => {
  const window = reportingWindow(undefined, now);
  const journal = validateJournal({ version: 1, checkedAt: '2026-09-19T12:00:00Z',
    entries: [{ ...row(), occurredAt: '2026-09-18T12:00:00Z' }, { ...row({ id: 'fee', metric: 'fee', value: 1000 }), occurredAt: '2026-09-18T12:00:00Z' }],
    coverage: ['revenue', 'refund', 'fee', 'advertising', 'infrastructure', 'support'].map(metric => ({ ...window, currency: 'EUR', metric, evidence: 'complete reviewed period' })) }, now);
  const provider = { rows: [], events: [], exceptions: [], status: 'unavailable' };
  assert.equal(makeReport(blank(), provider, window, now, journal).report.weeklyReports[0].operatingResult, 9000);
  journal.coverage.pop(); assert.equal(makeReport(blank(), provider, window, now, journal).report.weeklyReports[0].operatingResult, null);
  journal.entries[0].month = '2026-08'; assert.throws(() => validateJournal(journal, now), /date_invalid/);
});
test('journal cannot attest entries after its review, and equivalent UTC precision preserves window coverage', () => {
  const window = reportingWindow(undefined, now);
  const journal = { version: 1, checkedAt: '2026-09-18T11:00:00Z', entries: [{ ...row(), occurredAt: '2026-09-18T12:00:00Z' }], coverage: [] };
  assert.throws(() => validateJournal(journal, now), /date_invalid/);
  journal.checkedAt = '2026-09-19T12:00:00Z';
  journal.coverage = [{ start: window.start.replace('.000Z', 'Z'), end: window.end.replace('.000Z', 'Z'), currency: 'EUR', metric: 'revenue', evidence: 'reviewed full week' }];
  const normalized = validateJournal(journal, now);
  assert.equal(makeReport(blank(), { rows: [], events: [], exceptions: [], status: 'unavailable' }, window, now, normalized).report.weeklyReports[0].totals.revenue.value, 10000);
});

async function sandboxFiles(fn) {
  const root = await mkdtemp(join(tmpdir(), 'younew-finance-'));
  try {
    const config = join(root, 'config.json'), accounting = join(root, 'accounting.json'), scopePath = join(root, 'scope.json'), output = join(root, 'output');
    await writeFile(accounting, JSON.stringify(blank())); await writeFile(scopePath, JSON.stringify(scope));
    await writeFile(config, JSON.stringify({ enabled: true, accountingSnapshotPath: accounting, paymentScopePath: scopePath }));
    await fn({ root, config, accounting, scopePath, output });
  } finally { await rm(root, { recursive: true, force: true }); }
}
test('actual runtime with missing provider produces immutable incomplete report, not zero profit', async () => sandboxFiles(async files => {
  const result = await run(files.config, files.output, { now, env: {} });
  const report = JSON.parse(await readFile(join(result.directory, 'WEEKLY_REPORT.json')));
  assert.equal(result.status, 'partial'); assert.equal(report.weeklyReports[0].operatingResult, null);
  assert.equal(report.deliveryStatus, 'prepared_not_sent'); assert.ok(report.exceptions.length);
  assert.equal((await stat(join(result.directory, 'WEEKLY_REPORT.json'))).mode & 0o777, 0o600);
}));
test('same attempt is idempotent; a later verified read creates a new dated receipt preserving old one', async () => sandboxFiles(async files => {
  const { read, state } = fixture(); const one = await run(files.config, files.output, { now, readProvider: read });
  const before = await readFile(join(one.directory, 'RECEIPT.json'), 'utf8');
  const two = await run(files.config, files.output, { now, readProvider: read });
  assert.equal(two.directory, one.directory); assert.equal(two.reused, true); assert.equal(state.calls.length, 8);
  const later = await run(files.config, files.output, { now: new Date(+now + 60_000), readProvider: read });
  assert.notEqual(later.directory, one.directory);
  state.payment.latest_charge.amount_refunded = 150000;
  state.refunds.data = [{ id: 're_new', object: 'refund', payment_intent: 'pi_fixture', charge: 'ch_fixture', currency: 'eur', status: 'succeeded', amount: 150000, created: when, balance_transaction: null }];
  const three = await run(files.config, files.output, { now: new Date(+now + 120_000), readProvider: read }); assert.notEqual(three.directory, one.directory);
  assert.equal(await readFile(join(one.directory, 'RECEIPT.json'), 'utf8'), before);
}));
test('successful sandbox synchronization is a completion time; failures retain history without live money or current success', async () => sandboxFiles(async files => {
  const { read, state } = fixture(); state.payment.livemode = state.payment.latest_charge.livemode = false;
  await writeFile(files.scopePath, JSON.stringify({ ...scope, environment: 'sandbox' }));
  const completed = new Date(+now + 4000);
  const first = await run(files.config, files.output, { now, clock: () => completed, readProvider: read });
  const receiptBefore = await readFile(join(first.directory, 'RECEIPT.json'), 'utf8');
  const initial = JSON.parse(await readFile(join(first.directory, 'WEEKLY_REPORT.json')));
  assert.equal(initial.synchronization.attemptedAt, now.toISOString());
  assert.equal(initial.synchronization.stripe.lastSuccessfulAt, completed.toISOString());
  assert.equal(initial.synchronization.accountingReviewedAt, blank().checkedAt);
  assert.equal(initial.synchronization.commerce.lastSuccessfulAt, null);
  assert.equal(initial.synchronization.commerce.attemptedAt, null);
  assert.deepEqual(initial.observedLiveProviderEvents, []); assert.equal(initial.sandboxEventsExcluded, 2);
  const failed = await run(files.config, files.output, { now: new Date(+now + 60_000), env: {} });
  const report = JSON.parse(await readFile(join(failed.directory, 'WEEKLY_REPORT.json')));
  assert.equal(report.synchronization.stripe.lastSuccessfulAt, completed.toISOString());
  assert.equal(report.synchronization.stripe.currentSuccessfulAt, null);
  assert.equal(report.synchronization.stripe.status, 'unavailable');
  assert.equal(report.weeklyReports[0].totals.charge.value, null);
  const snapshot = JSON.parse(await readFile(join(files.output, 'CURRENT_FINANCE_SNAPSHOT.json')));
  assert.match(snapshot.observations.find(item => item.label === 'Source synchronization').detail, /Успех относится к прежнему чтению/);
  assert.equal(snapshot.rows.length, 0); assert.equal(await readFile(join(first.directory, 'RECEIPT.json'), 'utf8'), receiptBefore);
  await writeFile(files.scopePath, JSON.stringify(scope));
  const switched = await run(files.config, files.output, { now: new Date(+now + 120_000), env: {} });
  assert.equal(JSON.parse(await readFile(join(switched.directory, 'WEEKLY_REPORT.json'))).synchronization.stripe.lastSuccessfulAt, null);
}));
test('partial provider reads cannot advance successful synchronization', async () => sandboxFiles(async files => {
  const { read, state } = fixture(); await run(files.config, files.output, { now, readProvider: read });
  state.payment.latest_charge.balance_transaction = null;
  const result = await run(files.config, files.output, { now: new Date(+now + 60_000), readProvider: read });
  const report = JSON.parse(await readFile(join(result.directory, 'WEEKLY_REPORT.json')));
  assert.equal(report.synchronization.stripe.status, 'partial');
  assert.equal(report.synchronization.stripe.currentSuccessfulAt, null);
  assert.equal(report.synchronization.stripe.lastSuccessfulAt, now.toISOString());
}));
test('disable and lock prevent provider reads; tampered report fails closed', async () => sandboxFiles(async files => {
  const config = JSON.parse(await readFile(files.config)); config.enabled = false; await writeFile(files.config, JSON.stringify(config));
  assert.equal((await run(files.config, files.output, { now, readProvider: () => { throw new Error('not called'); } })).status, 'disabled');
  config.enabled = true; await writeFile(files.config, JSON.stringify(config));
  await writeFile(join(files.output, '.finance.lock'), 'existing owner');
  assert.equal((await run(files.config, files.output, { now })).status, 'locked'); await rm(join(files.output, '.finance.lock'));
  const { read } = fixture(); const result = await run(files.config, files.output, { now, readProvider: read });
  await writeFile(join(result.directory, 'WEEKLY_REPORT.md'), 'tampered');
  await assert.rejects(run(files.config, files.output, { now, readProvider: read }), /integrity_failed/);
}));
test('one stable Admin path advances with new facts and exposes a later missing source honestly', async () => sandboxFiles(async files => {
  const { read, state } = fixture(); await run(files.config, files.output, { now, readProvider: read });
  const stable = join(files.output, 'CURRENT_FINANCE_SNAPSHOT.json');
  assert.equal(JSON.parse(await readFile(stable)).rows.find(row => row.metric === 'charge').value, 150000);
  state.payment.amount_received = state.payment.latest_charge.amount = state.payment.latest_charge.amount_captured = 200000;
  await run(files.config, files.output, { now, readProvider: read });
  assert.equal(JSON.parse(await readFile(stable)).rows.find(row => row.metric === 'charge').value, 200000);
  await run(files.config, files.output, { now, env: {} });
  const unavailable = JSON.parse(await readFile(stable)); assert.equal(unavailable.rows.length, 0);
  assert.ok(unavailable.decisions.some(item => item.includes('restricted_read_key')));
  const latest = JSON.parse(await readFile(join(files.output, 'LATEST.json')));
  assert.equal(latest.snapshotPath, stable); assert.notEqual(latest.receiptSnapshotPath, stable);
}));
