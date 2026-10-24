import https from 'node:https';
import { lookup } from 'node:dns/promises';
import { isIP } from 'node:net';
import { createHash, randomUUID } from 'node:crypto';
import { readFile, writeFile, mkdir, lstat, open, rename, rm, chmod } from 'node:fs/promises';
import { join, resolve, basename } from 'node:path';

export const TARGETS = Object.freeze([
  { taskKey: 'public_home', url: 'https://younew.nl/', kind: 'html' },
  { taskKey: 'public_start', url: 'https://younew.nl/start/', kind: 'html' },
  { taskKey: 'public_housing', url: 'https://younew.nl/essentials/housing-and-renting/', kind: 'html' },
  { taskKey: 'public_content_feed', url: 'https://admin.younew.nl/api/public/content-sync', kind: 'feed' },
  { taskKey: 'packaged_mobile_api', url: 'https://admin.younew.nl/api/mobile/sync', kind: 'mobile' }
].map(Object.freeze));
export const SOURCE_KEYS = Object.freeze(['broken_links', 'aging_content_queue', 'feedback_intake', 'website_app_sync', 'backup_restore', 'weekly_owner_report']);
const MAX_BODY = 2 * 1024 * 1024;
const TRANSIENT = new Set([408, 500, 502, 503, 504]);
const hash = value => createHash('sha256').update(value).digest('hex');
const json = value => JSON.stringify(value, null, 2) + '\n';
const stamp = value => typeof value === 'string' && /^\d{4}-\d\d-\d\dT.*(?:Z|[+-]\d\d:\d\d)$/.test(value) && Number.isFinite(Date.parse(value));
const hex = value => typeof value === 'string' && /^[a-f0-9]{64}$/.test(value);
const amsterdamDate = value => new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Amsterdam', year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date(value));
const object = value => value !== null && typeof value === 'object' && !Array.isArray(value);
export class SourceFailure extends Error {
  constructor(code, transient = false) { super(code); this.code = code; this.transient = transient; }
}
function requireValue(ok, code = 'invalid_source') { if (!ok) throw new SourceFailure(code); }
function finiteDate(value, now) { requireValue(stamp(value) && Date.parse(value) <= now, 'invalid_source_timestamp'); return value; }
export function publicAddress(address) {
  if (isIP(address) === 4) {
    const [a, b, c] = address.split('.').map(Number);
    return !(a === 0 || a === 10 || a === 127 || a >= 224 || (a === 100 && b >= 64 && b <= 127) ||
      (a === 169 && b === 254) || (a === 172 && b >= 16 && b <= 31) || (a === 192 && (b === 168 || b === 0 || (b === 88 && c === 99))) ||
      (a === 198 && (b === 18 || b === 19 || (b === 51 && c === 100))) || (a === 203 && b === 0 && c === 113));
  }
  // Accept global-unicast IPv6 only; reject special/documentation/transition blocks.
  if (isIP(address) !== 6 || !/^2[0-9a-f]{3}:/i.test(address)) return false;
  const s = address.toLowerCase();
  return !/^2001:(?:0{0,3}[0-9a-f]{1,2}:|db8:)/.test(s) && !s.startsWith('2002:') && !s.startsWith('3fff:') && !s.includes('.');
}
export function safeRedirect(target, location) {
  const next = new URL(location, target.url), original = new URL(target.url);
  requireValue(next.protocol === 'https:' && next.origin === original.origin && next.pathname === original.pathname && !next.search && !next.hash && !next.username && !next.password, 'redirect_not_allowed');
  return next;
}
async function withSignal(promise, signal) {
  if (signal.aborted) throw new SourceFailure('deadline', true);
  let listener;
  try { return await Promise.race([promise, new Promise((_, reject) => {
    listener = () => reject(new SourceFailure('deadline', true)); signal.addEventListener('abort', listener, { once: true });
  })]); } finally { if (listener) signal.removeEventListener('abort', listener); }
}
// Fixed public GET only. No cookies, Authorization, arbitrary URLs, proxy or env credentials.
export function publicTransport({ lookupFn = lookup, requestFn = https.request } = {}) {
  return async (target, { signal }) => {
    requireValue(TARGETS.some(item => item.url === target.url && item.kind === target.kind), 'target_not_allowed');
    let url = new URL(target.url);
    for (let redirects = 0; redirects <= 2; redirects++) {
      const addresses = await withSignal(lookupFn(url.hostname, { all: true, verbatim: true }), signal);
      requireValue(addresses.length > 0 && addresses.every(item => publicAddress(item.address)), 'dns_not_public');
      const selected = addresses[0];
      const response = await withSignal(new Promise((res, rej) => {
        const req = requestFn(url, { method: 'GET', agent: false, signal, rejectUnauthorized: true, servername: url.hostname,
          headers: { Accept: target.kind === 'html' ? 'text/html' : 'application/json', 'User-Agent': 'YouNew-Weekly-ReadOnly/1' },
          lookup: (_hostname, options, callback) => options?.all ? callback(null, [selected]) : callback(null, selected.address, selected.family) }, incoming => {
          const status = incoming.statusCode;
          const headers = incoming.headers;
          if (status !== 200) { incoming.destroy(); res({ status, headers, body: Buffer.alloc(0) }); return; }
          if (Number(headers['content-length'] ?? 0) > MAX_BODY) { incoming.destroy(); rej(new SourceFailure('body_limit')); return; }
          let bytes = 0; const chunks = [];
          incoming.on('data', chunk => { bytes += chunk.length; if (bytes > MAX_BODY) { incoming.destroy(); rej(new SourceFailure('body_limit')); } else chunks.push(chunk); });
          incoming.on('end', () => res({ status, headers, body: Buffer.concat(chunks) }));
          incoming.on('error', () => rej(new SourceFailure('transport_unavailable', true)));
        });
        req.on('error', error => rej(error instanceof SourceFailure ? error : new SourceFailure('transport_unavailable', true)));
        req.end();
      }), signal);
      if (![301, 302, 303, 307, 308].includes(response.status)) return response;
      if (redirects === 2) throw new SourceFailure('redirect_limit');
      url = safeRedirect(target, response.headers.location);
    }
  };
}
export function validatePublic(target, response, now) {
  const body = Buffer.from(response.body);
  requireValue(body.length <= MAX_BODY, 'body_limit');
  const type = response.headers?.['content-type'] ?? '';
  if (target.kind === 'html') {
    requireValue(/^text\/html(?:;|$)/i.test(type), 'unexpected_content_type');
    const html = body.toString('utf8');
    const title = html.match(/<title\b[^>]*>([^<]{1,500})<\/title>/i)?.[1];
    requireValue(title && /younew/i.test(title) && !/\b(?:404|403|500|not found|access denied|log ?in|sign ?in)\b/i.test(title), 'site_identity_invalid');
    const canonicalTags = html.match(/<link\b[^>]*>/gi) ?? [];
    const canonical = canonicalTags.find(tag => /\brel\s*=\s*(["'])canonical\1/i.test(tag))?.match(/\bhref\s*=\s*(["'])(.*?)\1/i)?.[2];
    requireValue(canonical === target.url, 'page_identity_invalid');
    requireValue(!/<(?:h1|title)\b[^>]*>[^<]*(?:404|page not found|pagina niet gevonden|страница не найдена|access denied|sign in|log in)[^<]*<\//i.test(html), 'soft_error_page');
    return { sourceAt: null, data: { identity: 'YouNew title and exact canonical path', httpStatus: 200, bytes: body.length, bodySha256: hash(body), semantics: 'http_identity_only_not_browser_journey_or_advice_verification' } };
  }
  requireValue(/^application\/json(?:;|$)/i.test(type), 'unexpected_content_type');
  let payload; try { payload = JSON.parse(body.toString('utf8')); } catch { throw new SourceFailure('malformed_json'); }
  requireValue(object(payload));
  if (target.kind === 'feed') {
    requireValue(payload.schemaVersion === 1 && typeof payload.available === 'boolean' && Array.isArray(payload.records) && Number.isInteger(payload.recordCount) && payload.records.length === payload.recordCount);
    if (!payload.available) {
      requireValue(payload.recordCount === 0);
      return { sourceAt: null, data: { available: false, recordCount: 0, activeFeed: 'absent', clientDelivery: 'not_confirmed' } };
    }
    requireValue(payload.recordCount > 0 && payload.recordCount <= 500 && hex(payload.fingerprint) && typeof payload.sourceVersion === 'string' && payload.sourceVersion.length > 0 && payload.sourceVersion.length <= 180);
    finiteDate(payload.activatedAt, now);
    requireValue(response.headers['x-younew-content-fingerprint'] === payload.fingerprint, 'fingerprint_header_mismatch');
    for (const record of payload.records) requireValue(object(record) && record.kind === 'article' && typeof record.id === 'string' && typeof record.title === 'string' && typeof record.slug === 'string' && typeof record.officialSourceUrl === 'string' && record.officialSourceUrl.startsWith('https://') && stamp(record.updatedAt) && stamp(record.publishedAt));
    for (const record of payload.records) { finiteDate(record.updatedAt, now); finiteDate(record.publishedAt, now); }
    requireValue(new Set(payload.records.map(r => r.id)).size === payload.records.length);
    return { sourceAt: payload.activatedAt, data: { available: true, recordCount: payload.recordCount, fingerprint: payload.fingerprint, activeFeed: 'observed', clientDelivery: 'not_confirmed' } };
  }
  requireValue(payload.available === true && payload.schema_version === 1 && hex(payload.content_version) && Number.isInteger(payload.entity_count) && payload.entity_count >= 0 && Array.isArray(payload.published_release_ids) && payload.published_release_ids.every(s => typeof s === 'string') && object(payload.artifact));
  requireValue(payload.artifact.schemaVersion === 1 && payload.artifact.datasetFingerprint === payload.content_version && payload.artifact.generatedAt === payload.generated_at && Array.isArray(payload.artifact.entities) && payload.artifact.entities.length === payload.entity_count, 'packaged_artifact_mismatch');
  finiteDate(payload.generated_at, now);
  requireValue(response.headers['x-younew-dataset-fingerprint'] === payload.content_version, 'fingerprint_header_mismatch');
  return { sourceAt: payload.generated_at, data: { contentVersion: payload.content_version, entityCount: payload.entity_count, semantics: 'packaged_snapshot_not_live_database', clientDelivery: 'not_confirmed' } };
}
async function attempts(operation, { clock, deadline, attemptMs, sleep }) {
  const history = []; let value;
  for (let attempt = 1; attempt <= 3; attempt++) {
    const start = clock(); const remaining = deadline - start;
    if (remaining <= 0) return { ok: false, code: 'deadline', history };
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), Math.min(attemptMs, remaining));
    try {
      value = await withSignal(operation(controller.signal), controller.signal);
      history.push({ attempt, attemptedAt: new Date(start).toISOString(), completedAt: new Date(clock()).toISOString(), result: 'observed' });
      return { ok: true, value, history };
    } catch (error) {
      const failure = error instanceof SourceFailure ? error : new SourceFailure('source_unavailable');
      history.push({ attempt, attemptedAt: new Date(start).toISOString(), completedAt: new Date(clock()).toISOString(), result: failure.code });
      if (!failure.transient || attempt === 3 || deadline - clock() <= 0) return { ok: false, code: failure.code, history };
    } finally { clearTimeout(timer); }
    await sleep(Math.min(100 * attempt, Math.max(0, deadline - clock())));
  }
}
const sourceResults = new Set(['success', 'failure', 'partial', 'skipped', 'candidate_only', 'plan_only', 'unavailable']);
export function validateSource(taskKey, value, now) {
  requireValue(object(value) && value.schemaVersion === 1 && value.taskKey === taskKey && typeof value.sourceId === 'string' && /^[a-zA-Z0-9_.:/-]{1,180}$/.test(value.sourceId) && sourceResults.has(value.result));
  finiteDate(value.evidenceAt, now);
  for (const key of ['lastAttemptAt', 'lastSuccessAt', 'scheduleEvidenceAt']) if (value[key] != null) finiteDate(value[key], Date.parse(value.evidenceAt));
  requireValue(value.sourceRunId == null || (typeof value.sourceRunId === 'string' && /^[a-zA-Z0-9_.:-]{1,120}$/.test(value.sourceRunId)));
  requireValue(value.sourceRunAttempt == null || (Number.isInteger(value.sourceRunAttempt) && value.sourceRunAttempt > 0));
  requireValue(value.lastSuccessAt == null || ['success', 'candidate_only', 'partial', 'failure', 'skipped', 'plan_only', 'unavailable'].includes(value.result));
  const counters = {};
  for (const [key, item] of Object.entries(value.counters ?? {})) {
    requireValue(['denominator', 'verified', 'unverified', 'sourceUnavailable', 'due', 'overdue', 'slaBreaches', 'open', 'broken', 'restricted', 'transient', 'records', 'errors', 'tables'].includes(key) && (item === null || (Number.isSafeInteger(item) && item >= 0)));
    counters[key] = item;
  }
  requireValue(object(value.sourceEvidence) && typeof value.sourceEvidence.path === 'string' && value.sourceEvidence.path.startsWith('/') && value.sourceEvidence.path.length < 2000 && hex(value.sourceEvidence.sha256));
  return { sourceId: value.sourceId, evidenceAt: value.evidenceAt, result: value.result, lastAttemptAt: value.lastAttemptAt ?? null, lastSuccessAt: value.lastSuccessAt ?? null,
    scheduleEvidenceAt: value.scheduleEvidenceAt ?? null, sourceRunId: value.sourceRunId ?? null, sourceRunAttempt: value.sourceRunAttempt ?? null, counters,
    sourceEvidence: { path: value.sourceEvidence.path, sha256: value.sourceEvidence.sha256 }, candidateActivation: 'not_confirmed', clientDelivery: 'not_confirmed' };
}
function rowBase(taskKey, runKey, result, now, previous) {
  return { taskKey, executor: 'existing_younew_2_weekly_report_read_stage', observedAt: result.ok ? new Date(now).toISOString() : null,
    scheduleEvidenceAt: null, attemptId: `${runKey}:${taskKey}`, lastAttemptAt: result.history.at(-1)?.attemptedAt ?? null,
    lastSuccessAt: previous?.lastSuccessAt ?? null, lastSuccessSourceId: previous?.lastSuccessSourceId ?? null, lastSuccessEvidence: previous?.lastSuccessEvidence ?? null,
    result: result.ok ? 'observed' : 'unknown', failureCode: result.ok ? null : result.code,
    attemptCount: result.history.length, requestHistory: result.history, nextEligibleRetryAt: null,
    sourceAt: null, sourceAgeSeconds: null, freshness: 'unknown', sourceEvidence: null, data: null, deliveryState: 'not_confirmed' };
}
export async function collect({ runKey, trigger, nativeRunId = null, previous = null, transport = publicTransport(), sourceAdapters = {}, clock = Date.now, sleep = ms => new Promise(r => setTimeout(r, ms)), totalMs = 30_000, attemptMs = 5_000 } = {}) {
  const began = clock(), deadline = began + totalMs;
  const prior = key => previous?.tasks?.find(item => item.taskKey === key);
  const publicRows = await Promise.all(TARGETS.map(async target => {
    const result = await attempts(async signal => {
      const response = await transport(target, { signal });
      if (response.status !== 200) throw new SourceFailure([401, 402, 403, 429].includes(response.status) ? 'access_restricted' : `http_${Number(response.status)}`, TRANSIENT.has(response.status));
      return validatePublic(target, response, clock());
    }, { clock, deadline, attemptMs, sleep });
    const now = clock(), row = rowBase(target.taskKey, runKey, result, now, prior(target.taskKey));
    if (result.ok) Object.assign(row, { sourceAt: result.value.sourceAt, data: result.value.data, lastSuccessAt: row.observedAt, lastSuccessSourceId: target.url,
      lastSuccessEvidence: { kind: 'public_http_semantic_read', at: row.observedAt, url: target.url }, sourceEvidence: { url: target.url },
      sourceAgeSeconds: result.value.sourceAt ? Math.floor((now - Date.parse(result.value.sourceAt)) / 1000) : null,
      freshness: result.value.sourceAt ? (now - Date.parse(result.value.sourceAt) > 7 * 86400000 ? 'historical_source' : 'dated_source') : 'source_time_unknown' });
    return row;
  }));
  const otherRows = await Promise.all(SOURCE_KEYS.map(async key => {
    if (!sourceAdapters[key]) return rowBase(key, runKey, { ok: false, code: 'authorized_source_not_configured', history: [] }, clock(), prior(key));
    const result = await attempts(async signal => validateSource(key, await sourceAdapters[key]({ signal }), clock()), { clock, deadline, attemptMs, sleep });
    const row = rowBase(key, runKey, result, clock(), prior(key));
    if (result.ok) {
      const value = result.value;
      const sameSource = prior(key)?.lastSuccessSourceId === value.sourceId;
      const oldSuccess = sameSource ? prior(key)?.lastSuccessAt : null;
      row.lastSuccessAt = value.lastSuccessAt && (!oldSuccess || Date.parse(value.lastSuccessAt) > Date.parse(oldSuccess)) ? value.lastSuccessAt : oldSuccess ?? null;
      row.lastSuccessSourceId = row.lastSuccessAt ? value.sourceId : null;
      row.lastSuccessEvidence = row.lastSuccessAt === value.lastSuccessAt ? value.sourceEvidence : (sameSource ? prior(key)?.lastSuccessEvidence ?? null : null);
      Object.assign(row, { scheduleEvidenceAt: value.scheduleEvidenceAt, sourceAt: value.evidenceAt, sourceEvidence: value.sourceEvidence, data: value,
        sourceAgeSeconds: Math.floor((clock() - Date.parse(value.evidenceAt)) / 1000), freshness: clock() - Date.parse(value.evidenceAt) > 7 * 86400000 ? 'historical_source' : 'dated_source' });
    }
    return row;
  }));
  const tasks = [...publicRows, ...otherRows];
  return { schemaVersion: 1, automationId: 'younew-2', reportingDate: amsterdamDate(began), runKey, trigger, nativeRunId, scheduledExecutionConfirmed: false, startedAt: new Date(began).toISOString(), completedAt: new Date(clock()).toISOString(),
    status: tasks.some(row => row.result === 'unknown' || (row.data?.result && !['success', 'candidate_only'].includes(row.data.result))) ? 'partial' : 'observed',
    reportState: 'prepared_not_sent', deliveryState: 'not_confirmed', notificationSent: false, tasks,
    limitations: ['HTTP identity is not a browser journey or advice verification.', 'Candidate, active feed, packaged snapshot and client delivery are separate.',
      'Source observation timestamps do not prove a scheduled run.', 'Unknown counters are null; no authorized private source is borrowed from finance.',
      'No SMTP, email, content task creation, activation, publication or mutation is performed.', 'Operational counts may include owner/synthetic records; they do not measure real users.', 'Trust aggregates cover operational governance records, not the complete packaged website/iOS dataset.'] };
}
export function markdown(report) {
  return `# YouNew: датированный maintenance-срез\n\n${report.completedAt}; ${report.reportState}. Scheduled execution: не подтверждён. Доставка владельцу: не подтверждена.\n\n` +
    report.tasks.map(row => `- ${row.taskKey}: ${row.result}; попыток чтения ${row.attemptCount}; последняя попытка ${row.lastAttemptAt ?? 'unknown'}; последний подтверждённый успех ${row.lastSuccessAt ?? 'unknown'}; дата источника ${row.sourceAt ?? 'unknown'} (${row.freshness}); ${row.failureCode ?? row.data?.semantics ?? row.data?.result ?? 'read only'}; source job attempt ${row.data?.lastAttemptAt ?? 'unknown'}; counters ${row.data?.counters ? JSON.stringify(row.data.counters) : 'unknown'}.`).join('\n') + '\n\n' + report.limitations.join('\n') + '\n';
}
async function privateRoot(path) { await mkdir(path, { recursive: true, mode: 0o700 }); const info = await lstat(path); requireValue(info.isDirectory() && !info.isSymbolicLink(), 'unsafe_output'); await chmod(path, 0o700); }
async function readJson(path) { const info = await lstat(path); requireValue(info.isFile() && !info.isSymbolicLink() && info.size <= MAX_BODY, 'invalid_local_file'); return JSON.parse(await readFile(path, 'utf8')); }
async function writeExclusive(path, value) { await writeFile(path, typeof value === 'string' ? value : json(value), { flag: 'wx', mode: 0o600 }); }
async function verifyRun(directory, now) {
  const info = await lstat(directory); requireValue(info.isDirectory() && !info.isSymbolicLink(), 'invalid_receipt_directory');
  const receipt = await readJson(join(directory, 'RECEIPT.json'));
  requireValue(Object.keys(receipt.files ?? {}).sort().join(',') === 'MAINTENANCE_REPORT.json,MAINTENANCE_REPORT.md', 'invalid_receipt');
  for (const [name, sha] of Object.entries(receipt.files)) { await readJsonIfJson(join(directory, name)); requireValue(hex(sha) && hash(await readFile(join(directory, name))) === sha, 'receipt_integrity_failed'); }
  const report = await readJson(join(directory, 'MAINTENANCE_REPORT.json')); requireValue(report.runKey === receipt.runKey && hash(report.runKey) === basename(directory), 'receipt_identity_mismatch');
  requireValue(report.schemaVersion === 1 && report.automationId === 'younew-2' && ['manual', 'heartbeat'].includes(report.trigger), 'previous_namespace_invalid');
  finiteDate(report.startedAt, now); finiteDate(report.completedAt, now);
  requireValue(Date.parse(report.startedAt) <= Date.parse(report.completedAt) && receipt.generatedAt === report.completedAt && report.reportingDate === amsterdamDate(report.startedAt), 'previous_time_invalid');
  const context = logicalContext({ automationId: 'younew-2', trigger: report.trigger, manualKey: report.trigger === 'manual' ? report.runKey.slice('younew-2:'.length) : undefined, nativeRunId: report.nativeRunId, now: new Date(report.startedAt) });
  requireValue(context.runKey === report.runKey && (report.nativeRunId === null || (typeof report.nativeRunId === 'string' && /^[a-zA-Z0-9_.:-]{1,120}$/.test(report.nativeRunId))), 'previous_context_invalid');
  const expected = [...TARGETS.map(t => t.taskKey), ...SOURCE_KEYS];
  requireValue(Array.isArray(report.tasks) && report.tasks.length === expected.length && new Set(report.tasks.map(r => r.taskKey)).size === expected.length && report.tasks.every(r => expected.includes(r.taskKey)), 'previous_task_inventory_invalid');
  for (const row of report.tasks) {
    for (const key of ['observedAt', 'lastAttemptAt', 'lastSuccessAt', 'sourceAt', 'scheduleEvidenceAt']) if (row[key] !== null) finiteDate(row[key], Date.parse(report.completedAt));
    if (row.lastSuccessAt !== null) {
      const target = TARGETS.find(t => t.taskKey === row.taskKey);
      requireValue(typeof row.lastSuccessSourceId === 'string' && (target ? row.lastSuccessSourceId === target.url : /^[a-zA-Z0-9_.:/-]{1,180}$/.test(row.lastSuccessSourceId)) && object(row.lastSuccessEvidence), 'previous_source_namespace_invalid');
    } else requireValue(row.lastSuccessSourceId === null, 'previous_success_invalid');
  }
  return { receipt, report };
}
async function readJsonIfJson(path) { const info = await lstat(path); requireValue(info.isFile() && !info.isSymbolicLink() && info.size <= MAX_BODY, 'invalid_receipt_file'); }
async function readLatest(root, now) {
  let latest;
  try { latest = await readJson(join(root, 'LATEST.json')); } catch (error) { if (error.code === 'ENOENT') return null; throw error; }
  requireValue(hex(latest.runId), 'invalid_latest');
  let verified;
  try { verified = await verifyRun(join(root, 'runs', latest.runId), now); } catch (error) { if (error.code === 'ENOENT') throw new SourceFailure('latest_receipt_unavailable'); throw error; }
  requireValue(latest.runKey === verified.report.runKey && latest.completedAt === verified.report.completedAt, 'latest_identity_mismatch');
  return { ...verified, latest };
}
async function publishLatest(root, directory, report, now) {
  const previous = await readLatest(root, now);
  // Replaying an older receipt must not rewind the current report pointer.
  if (previous && Date.parse(previous.report.completedAt) >= Date.parse(report.completedAt)) return;
  const pointer = join(root, `.latest-${randomUUID()}`);
  try {
    await writeExclusive(pointer, { runId: basename(directory), runKey: report.runKey, directory, completedAt: report.completedAt, reportPath: join(directory, 'MAINTENANCE_REPORT.json'), reportState: 'prepared_not_sent', deliveryState: 'not_confirmed' });
    await rename(pointer, join(root, 'LATEST.json'));
  } finally { await rm(pointer, { force: true }); }
}
export async function run({ output, runKey, trigger, nativeRunId = null, enabled = false, afterReceiptCommit, ...options }) {
  requireValue(typeof runKey === 'string' && /^[a-zA-Z0-9_.:-]{1,180}$/.test(runKey) && ['manual', 'heartbeat'].includes(trigger), 'invalid_run_context');
  requireValue(nativeRunId === null || (typeof nativeRunId === 'string' && /^[a-zA-Z0-9_.:-]{1,120}$/.test(nativeRunId)), 'invalid_native_run_id');
  if (!enabled) return { status: 'disabled', networkRequests: 0, reportSent: false };
  const root = resolve(output); await privateRoot(root); await privateRoot(join(root, 'runs'));
  let lock; try { lock = await open(join(root, '.maintenance.lock'), 'wx', 0o600); await lock.write(json({ pid: process.pid, runKey })); }
  catch (error) { if (error.code === 'EEXIST') return { status: 'locked', networkRequests: 0, reportSent: false }; throw error; }
  let temp;
  try {
    const now = options.clock?.() ?? Date.now();
    const context = logicalContext({ automationId: 'younew-2', trigger, manualKey: trigger === 'manual' ? runKey.slice('younew-2:'.length) : undefined, nativeRunId, now: new Date(now) });
    requireValue(context.runKey === runKey, 'run_window_mismatch');
    const runId = hash(runKey), directory = join(root, 'runs', runId);
    try { const existing = await verifyRun(directory, now); requireValue(existing.report.runKey === runKey && existing.report.trigger === trigger && existing.report.reportingDate === amsterdamDate(now) && existing.report.nativeRunId === nativeRunId, 'existing_context_mismatch'); await publishLatest(root, directory, existing.report, now); return { status: existing.report.status, reused: true, directory, runId, reportSent: false, deliveryState: 'not_confirmed' }; }
    catch (error) { if (error.code !== 'ENOENT') throw error; try { await lstat(directory); throw new SourceFailure('incomplete_existing_run'); } catch (e) { if (e.code !== 'ENOENT') throw e; } }
    const previous = (await readLatest(root, now))?.report ?? null;
    const report = await collect({ runKey, trigger, nativeRunId, previous, ...options });
    temp = join(root, 'runs', `.preparing-${randomUUID()}`); await mkdir(temp, { mode: 0o700 });
    await writeExclusive(join(temp, 'MAINTENANCE_REPORT.json'), report); await writeExclusive(join(temp, 'MAINTENANCE_REPORT.md'), markdown(report));
    const files = {}; for (const name of ['MAINTENANCE_REPORT.json', 'MAINTENANCE_REPORT.md']) files[name] = hash(await readFile(join(temp, name)));
    await writeExclusive(join(temp, 'RECEIPT.json'), { schemaVersion: 1, runKey, generatedAt: report.completedAt, implementationSha256: hash(await readFile(new URL('./maintenance.mjs', import.meta.url))), files, reportState: 'prepared_not_sent', deliveryState: 'not_confirmed' });
    await rename(temp, directory); temp = null;
    if (afterReceiptCommit) await afterReceiptCommit();
    await publishLatest(root, directory, report, options.clock?.() ?? Date.now());
    return { status: report.status, reused: false, directory, runId, reportSent: false, deliveryState: 'not_confirmed' };
  } finally { if (temp) await rm(temp, { recursive: true, force: true }); await lock.close(); await rm(join(root, '.maintenance.lock')); }
}
export function logicalContext({ trigger, automationId, manualKey, nativeRunId = null, now = new Date() }) {
  requireValue(automationId === 'younew-2', 'automation_not_allowed');
  if (trigger === 'manual') { requireValue(/^manual-[a-zA-Z0-9_.-]{1,100}$/.test(manualKey ?? ''), 'manual_key_required'); return { runKey: `${automationId}:${manualKey}`, trigger, nativeRunId }; }
  requireValue(trigger === 'heartbeat', 'invalid_trigger');
  const date = new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Amsterdam', year: 'numeric', month: '2-digit', day: '2-digit' }).format(now);
  const weekday = new Intl.DateTimeFormat('en-US', { timeZone: 'Europe/Amsterdam', weekday: 'short' }).format(now);
  requireValue(weekday === 'Mon', 'outside_monday_report_window');
  return { runKey: `${automationId}:week:${date}`, trigger, nativeRunId };
}
// Local evidence is an optional aggregate envelope; credentials and free text are never copied.
export async function fileSourceAdapters(path) {
  if (!path) return {};
  const envelope = await readJson(path); requireValue(envelope.schemaVersion === 1 && object(envelope.sources), 'invalid_source_envelope');
  requireValue(Object.keys(envelope.sources).every(key => SOURCE_KEYS.includes(key)), 'unknown_source_key');
  return Object.fromEntries(Object.entries(envelope.sources).map(([key, value]) => [key, async () => {
    const evidence = value?.sourceEvidence; requireValue(evidence && typeof evidence.path === 'string' && hex(evidence.sha256), 'missing_evidence');
    await readJsonIfJson(evidence.path); requireValue(hash(await readFile(evidence.path)) === evidence.sha256, 'source_evidence_hash_mismatch'); return value;
  }]));
}
