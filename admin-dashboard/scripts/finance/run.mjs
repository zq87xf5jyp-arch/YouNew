import { readFile, writeFile, appendFile, mkdir, open, lstat, rename, rm, chmod } from 'node:fs/promises';
import { resolve, isAbsolute, join } from 'node:path';
import { createHash, randomUUID } from 'node:crypto';
import { parseFinanceSnapshot } from '../../src/lib/finance/report.ts';
import { SourceError, stripeReader, collectStripe, combineSnapshot, makeReport, reportingWindow, validateScope, validateJournal } from './collect.mjs';
import { commerceDiagnosticsReader, collectCommerceDiagnostics, emptyCommerceDiagnostics, commerceReportLines, commerceDecisions } from './commerce-diagnostics.mjs';
import { synchronizationState, synchronizationLines } from './synchronization.mjs';

const digest = value => createHash('sha256').update(JSON.stringify(value)).digest('hex');
const codeOf = error => error instanceof SourceError ? error.message : 'local_input_or_provider_unavailable';
const receiptFiles = ['FINANCE_SNAPSHOT.json', 'WEEKLY_REPORT.json', 'WEEKLY_REPORT.md', 'PROVIDER_OBSERVATIONS.json', 'REVIEWED_ACCOUNTING_INPUT.json', 'COMMERCE_DIAGNOSTICS.json'];
async function privateJson(path, value) { await writeFile(path, JSON.stringify(value, null, 2) + '\n', { mode: 0o600, flag: 'wx' }); }
async function readJson(path) {
  const file = await lstat(path);
  if (!file.isFile() || file.isSymbolicLink() || file.size > 10_000_000) throw new SourceError('input_file_invalid');
  return JSON.parse(await readFile(path, 'utf8'));
}
async function safeRoot(output) {
  const root = resolve(output);
  await mkdir(root, { recursive: true, mode: 0o700 });
  const info = await lstat(root);
  if (!info.isDirectory() || info.isSymbolicLink()) throw new SourceError('private_output_root_invalid');
  await chmod(root, 0o700);
  return root;
}
async function log(root, item) {
  const handle = await open(join(root, 'runs.jsonl'), 'a', 0o600);
  try { await handle.write(JSON.stringify(item) + '\n'); } finally { await handle.close(); }
}
function emptySnapshot(now) {
  return { version: 1, checkedAt: now.toISOString(), method: 'Accounting source unavailable', months: [now.toISOString().slice(0, 7)],
    rows: [], coverage: [], subscriptions: [], customers: [], observations: [], decisions: ['Connect reviewed accounting, expense and bank evidence.'] };
}
function semanticProvider(provider) {
  return { status: provider.status, accountId: provider.accountId, environment: provider.environment,
    rows: provider.rows.map(({ evidence, ...row }) => row),
    events: provider.events.map(({ evidence, ...item }) => item), exceptions: provider.exceptions };
}

async function verifiedReceipt(directory) {
  const info = await lstat(directory);
  if (!info.isDirectory() || info.isSymbolicLink()) throw new SourceError('run_directory_invalid');
  const receipt = await readJson(join(directory, 'RECEIPT.json'));
  if (!receipt.files || Object.keys(receipt.files).length !== receiptFiles.length) throw new SourceError('existing_report_file_inventory_incomplete');
  for (const [name, hash] of Object.entries(receipt.files)) {
    if (!receiptFiles.includes(name)) throw new SourceError('existing_report_file_inventory_invalid');
    const info = await lstat(join(directory, name));
    if (!info.isFile() || info.isSymbolicLink() || info.size > 10_000_000) throw new SourceError('existing_report_file_invalid');
    if (createHash('sha256').update(await readFile(join(directory, name))).digest('hex') !== hash) throw new SourceError('existing_report_integrity_failed');
  }
  return receipt;
}

async function previousSynchronization(root) {
  let latest;
  try { latest = await readJson(join(root, 'LATEST.json')); } catch (error) { if (error.code === 'ENOENT') return null; throw error; }
  if (!/^20\d{2}-\d{2}-\d{2}-[a-f0-9]{24}$/.test(latest.runId)) throw new SourceError('previous_report_reference_invalid');
  // Never follow a directory supplied by mutable LATEST metadata.
  const directory = join(root, 'runs', latest.runId);
  await verifiedReceipt(directory);
  return (await readJson(join(directory, 'WEEKLY_REPORT.json'))).synchronization ?? null;
}

export async function run(configPath, output, { weekEnding, now = new Date(), clock = () => new Date(), env = process.env, readProvider, commerceTransport, commerceClock } = {}) {
  const root = await safeRoot(output);
  let lock;
  try {
    lock = await open(join(root, '.finance.lock'), 'wx', 0o600);
    await lock.write(JSON.stringify({ pid: process.pid, startedAt: now.toISOString() }));
  } catch (error) {
    if (error.code === 'EEXIST') return { status: 'locked', action: 'No duplicate run started. Check the lock owner before removing a stale lock.' };
    throw error;
  }
  let temporary;
  try {
    const config = await readJson(configPath);
    if (config.enabled !== true) { await log(root, { at: now.toISOString(), status: 'disabled', providerCalls: 0 }); return { status: 'disabled' }; }
    const previous = await previousSynchronization(root);
    const window = reportingWindow(weekEnding, now);
    const inputExceptions = [];
    let journal = null;
    if (config.accountingJournalPath) {
      try {
        if (!isAbsolute(config.accountingJournalPath)) throw new SourceError('accounting_journal_path_required');
        journal = validateJournal(await readJson(config.accountingJournalPath), now);
      } catch { inputExceptions.push({ code: 'accounting_journal_unavailable', reference: 'accountingJournalPath' }); }
    } else inputExceptions.push({ code: 'dated_weekly_accounting_source_missing', reference: 'accountingJournalPath' });
    let accounting;
    try {
      if (!isAbsolute(config.accountingSnapshotPath ?? '')) throw new SourceError('accounting_path_required');
      accounting = parseFinanceSnapshot(await readJson(config.accountingSnapshotPath));
      if (new Date(accounting.checkedAt) > now) throw new SourceError('accounting_snapshot_future_dated');
    } catch (error) {
      accounting = emptySnapshot(now); inputExceptions.push({ code: 'accounting_source_unavailable', reference: 'accountingSnapshotPath' });
    }
    let scope, providerCompletedAt = null;
    let provider = { status: 'unavailable', rows: [], events: [], exceptions: [], coverage: [] };
    try {
      if (!isAbsolute(config.paymentScopePath ?? '')) throw new SourceError('payment_scope_path_required');
      scope = validateScope(await readJson(config.paymentScopePath));
      const reader = readProvider ?? stripeReader(env.YOUNEW_STRIPE_FINANCE_READ_KEY, scope.environment);
      provider = await collectStripe(reader, scope, now);
      providerCompletedAt = clock().toISOString();
    } catch (error) {
      provider.exceptions.push({ code: codeOf(error), reference: 'stripe_source' });
    }
    provider.exceptions.push(...inputExceptions);
    let commerce = emptyCommerceDiagnostics();
    if (config.commerceDiagnostics?.enabled === true) {
      try {
        const read = commerceDiagnosticsReader(config.commerceDiagnostics, env.YOUNEW_COMMERCE_DIAGNOSTICS_SERVICE_ROLE_KEY, commerceTransport);
        commerce = await collectCommerceDiagnostics(read, config.commerceDiagnostics, now, { clock: commerceClock });
      } catch (error) { commerce = emptyCommerceDiagnostics('unavailable', error instanceof SourceError ? error.message : 'commerce_source_unavailable'); }
    }
    if (commerce.status !== 'observed') provider.exceptions.push({ code: commerce.failureCode ?? 'commerce_diagnostics_disabled', reference: 'commerce_diagnostics' });
    if (commerce.paymentDeadLetters > 0 || commerce.notificationDeadLetters > 0 || commerce.ownerExceptionCount > 0) {
      provider.exceptions.push({ code: 'commerce_owner_action_required', reference: 'commerce_diagnostics' });
    }
    const journalRows = (journal?.entries ?? []).map(({ occurredAt, ...row }) => row);
    const accountingForReport = parseFinanceSnapshot({ ...accounting,
      months: [...new Set([...accounting.months, ...journalRows.map(row => row.month)])],
      rows: [...accounting.rows, ...journalRows] });
    const reportNow = clock();
    const synchronization = synchronizationState({ attemptedAt: now.toISOString(), completedAt: reportNow.toISOString(),
      accountingReviewedAt: inputExceptions.some(item => item.code === 'accounting_source_unavailable') ? null : accounting.checkedAt,
      provider, providerCompletedAt, scope, commerce, commerceConfig: config.commerceDiagnostics, previous });
    const combined = combineSnapshot(accountingForReport, provider, reportNow);
    const snapshot = parseFinanceSnapshot({ ...combined,
      observations: [...combined.observations.filter(item => !['Arrival Commerce operations', 'Source synchronization'].includes(item.label)), {
        label: 'Source synchronization', detail: synchronizationLines(synchronization).join(' '),
        evidence: 'Completion timestamps from this private executor; prior success retained only from an integrity-verified report for the same source/account/environment' }, {
        label: 'Arrival Commerce operations', detail: commerceReportLines(commerce, reportNow).slice(0, 4).join(' ')
          + (commerce.expiresAt ? ` После ${commerce.expiresAt} срез устарел: требуется новое чтение; это не online-проверка.` : ''),
        evidence: commerce.observedAt ? `Private service-only RPC; observed ${commerce.observedAt}; worker execution unverified` : `No current commerce diagnostics: ${commerce.status}` }],
      decisions: [...combined.decisions.filter(item => !item.startsWith('Arrival Commerce: ')), ...commerceDecisions(commerce)] });
    const { report, markdown } = makeReport(snapshot, provider, window, reportNow, journal);
    report.commerceOperations = commerce;
    report.synchronization = synchronization;
    const ownerMarkdown = markdown + '\n' + commerceReportLines(commerce, reportNow).join('\n') + '\n' + synchronizationLines(synchronization).join('\n') + '\n';
    const implementationHash = digest(await Promise.all(['./run.mjs', './collect.mjs', './commerce-diagnostics.mjs', './synchronization.mjs', '../../src/lib/finance/report.ts'].map(path => readFile(new URL(path, import.meta.url), 'utf8'))));
    const identity = digest({ version: 3, implementationHash, window, accounting, journal, scope: scope ?? null, provider: semanticProvider(provider), commerce, synchronization });
    const runId = `${window.end.slice(0, 10)}-${identity.slice(0, 24)}`;
    const runs = join(root, 'runs'); await mkdir(runs, { recursive: true, mode: 0o700 });
    const runDirectory = await lstat(runs);
    if (!runDirectory.isDirectory() || runDirectory.isSymbolicLink()) throw new SourceError('run_directory_invalid');
    const destination = join(runs, runId);
    let reused = false;
    try {
      const receipt = await verifiedReceipt(destination);
      if (receipt.identity !== identity || !receipt.files) throw new SourceError('existing_report_identity_mismatch');
      reused = true;
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
      // A pre-existing incomplete directory is never overwritten or repaired silently.
      try { await lstat(destination); throw new SourceError('existing_report_incomplete'); } catch (statError) { if (statError.code !== 'ENOENT') throw statError; }
      temporary = join(runs, `.preparing-${randomUUID()}`); await mkdir(temporary, { mode: 0o700 });
      await privateJson(join(temporary, 'FINANCE_SNAPSHOT.json'), snapshot);
      await privateJson(join(temporary, 'WEEKLY_REPORT.json'), report);
      await privateJson(join(temporary, 'PROVIDER_OBSERVATIONS.json'), provider);
      await privateJson(join(temporary, 'COMMERCE_DIAGNOSTICS.json'), commerce);
      await privateJson(join(temporary, 'REVIEWED_ACCOUNTING_INPUT.json'), { monthlySnapshot: accounting, datedJournal: journal });
      await writeFile(join(temporary, 'WEEKLY_REPORT.md'), ownerMarkdown, { flag: 'wx', mode: 0o600 });
      const files = {};
      for (const name of ['FINANCE_SNAPSHOT.json', 'WEEKLY_REPORT.json', 'WEEKLY_REPORT.md', 'PROVIDER_OBSERVATIONS.json', 'REVIEWED_ACCOUNTING_INPUT.json', 'COMMERCE_DIAGNOSTICS.json']) files[name] = createHash('sha256').update(await readFile(join(temporary, name))).digest('hex');
      await privateJson(join(temporary, 'RECEIPT.json'), { version: 2, identity, implementationHash, generatedAt: reportNow.toISOString(), status: 'prepared_not_sent', files });
      await rename(temporary, destination); temporary = undefined;
    }
    const currentSnapshot = join(root, 'CURRENT_FINANCE_SNAPSHOT.json');
    const currentTemp = join(root, `.current-${randomUUID()}`);
    await writeFile(currentTemp, await readFile(join(destination, 'FINANCE_SNAPSHOT.json')), { mode: 0o600, flag: 'wx' });
    await rename(currentTemp, currentSnapshot);
    const latestTemp = join(root, `.latest-${randomUUID()}`);
    await privateJson(latestTemp, { runId, directory: destination, checkedAt: reportNow.toISOString(), synchronization, providerStatus: provider.status, commerceStatus: commerce.status, commerceObservedAt: commerce.observedAt, workerLiveness: 'unknown', state: 'partial_not_reconciled', snapshotPath: currentSnapshot, receiptSnapshotPath: join(destination, 'FINANCE_SNAPSHOT.json') });
    await rename(latestTemp, join(root, 'LATEST.json'));
    await log(root, { at: now.toISOString(), runId, status: reused ? 'reused_after_source_attempt' : 'prepared', providerStatus: provider.status, commerceStatus: commerce.status, workerLiveness: 'unknown', exceptions: provider.exceptions.map(item => item.code), messageSent: false });
    if (provider.exceptions.length) {
      await appendFile(join(root, 'exceptions.jsonl'), JSON.stringify({ at: now.toISOString(), runId, exceptions: provider.exceptions }) + '\n', { mode: 0o600 });
    }
    return { status: 'partial', reused, runId, directory: destination, providerStatus: provider.status, commerceStatus: commerce.status, workerLiveness: 'unknown', exceptionCount: provider.exceptions.length, reportSent: false };
  } catch (error) {
    await log(root, { at: now.toISOString(), status: 'failed_closed', code: codeOf(error), previousReportsPreserved: true });
    throw error;
  } finally {
    if (temporary) await rm(temporary, { recursive: true, force: true });
    await lock.close(); await rm(join(root, '.finance.lock'));
  }
}
