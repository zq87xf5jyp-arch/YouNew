import { SourceError } from './collect.mjs';

export const COMMERCE_ORIGIN = 'https://pgdzdxsiagfjioxwuqxf.supabase.co';
export const COMMERCE_PROJECT = 'pgdzdxsiagfjioxwuqxf';
export const DIAGNOSTICS_MAX_AGE_MS = 15 * 60_000;
const need = (ok, code) => { if (!ok) throw new SourceError(code); };
const record = value => value !== null && typeof value === 'object' && !Array.isArray(value);
const count = value => Number.isSafeInteger(value) && value >= 0;
const id = (value, prefix) => typeof value === 'string' && new RegExp(`^${prefix}_[A-Za-z0-9_]{1,220}$`).test(value);
const knownCodes = new Set(['checkout_creation_uncertain', 'attempt_limit', 'refund_or_dispute_review', 'notification_failed',
  'provider_unavailable', 'order_binding_not_ready', 'stale_reconciliation', 'payment_identity_changed',
  'refund_reversal_requires_review', 'paid_state_regression', 'session_scope_mismatch', 'session_amount_mismatch',
  'session_product_mismatch', 'missing_payment_intent', 'payment_not_confirmed', 'charge_not_confirmed',
  'refund_list_incomplete', 'refund_scope_mismatch', 'refund_amount_mismatch', 'provider_account_or_mode_mismatch', 'provider_catalog_mismatch']);

function serviceKey(secret) {
  // Deliberately support the existing project-bound legacy service JWT only.
  // A client anon JWT or an unbound opaque key is not accepted by this reader.
  need(typeof secret === 'string' && secret.length < 8192 && /^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/.test(secret), 'commerce_service_key_missing_or_invalid');
  let claims;
  try { claims = JSON.parse(Buffer.from(secret.split('.')[1], 'base64url').toString('utf8')); } catch { throw new SourceError('commerce_service_key_missing_or_invalid'); }
  need(record(claims) && claims.role === 'service_role' && claims.ref === COMMERCE_PROJECT, 'commerce_service_key_scope_mismatch');
  return secret;
}

async function readBounded(response, maxBytes, signal) {
  const reader = response.body?.getReader(); need(reader, 'commerce_response_invalid');
  const chunks = []; let length = 0;
  const abort = () => { reader.cancel().catch(() => {}); };
  signal.addEventListener('abort', abort, { once: true });
  try {
    need(!signal.aborted, 'commerce_source_timeout');
    for (;;) {
      const { done, value } = await reader.read(); if (done) break;
      length += value.byteLength; need(length <= maxBytes, 'commerce_response_limit'); chunks.push(value);
    }
    need(!signal.aborted, 'commerce_source_timeout');
  } finally { signal.removeEventListener('abort', abort); await reader.cancel().catch(() => {}); }
  try { return JSON.parse(Buffer.concat(chunks).toString('utf8')); } catch { throw new SourceError('commerce_response_invalid'); }
}

export function commerceDiagnosticsReader(config, secret, { fetcher = fetch, sleep = ms => new Promise(r => setTimeout(r, ms)), timeoutMs = 6000, deadline = Date.now() + 20_000 } = {}) {
  need(config?.enabled === true && config.origin === COMMERCE_ORIGIN, 'commerce_project_not_enabled_or_mismatched');
  need(id(config.expectedAccountId, 'acct') && ['sandbox', 'live'].includes(config.environment), 'commerce_expected_scope_required');
  const key = serviceKey(secret);
  return async action => {
    need(action === 'diagnostics' || action === 'finance_scope', 'commerce_action_not_allowed');
    for (let attempt = 0; attempt < 3; attempt++) {
      need(Date.now() < deadline, 'commerce_source_deadline_exceeded');
      try {
        const signal = AbortSignal.timeout(Math.max(1, Math.min(timeoutMs, deadline - Date.now())));
        const response = await fetcher(new URL('/rest/v1/rpc/arrival_commerce_command', COMMERCE_ORIGIN), {
          method: 'POST', redirect: 'error', cache: 'no-store', credentials: 'omit',
          headers: { apikey: key, Authorization: `Bearer ${key}`, Accept: 'application/json', 'Content-Type': 'application/json' },
          body: JSON.stringify({ p_action: action, p_input: {} }),
          signal
        });
        if (!response.ok) {
          await response.body?.cancel().catch(() => {});
          if ((response.status === 429 || response.status >= 500) && attempt < 2) {
            const retry = response.headers.get('retry-after');
            const delay = retry === null ? 200 * 2 ** attempt : /^\d+$/.test(retry) ? Number(retry) * 1000 : NaN;
            need(Number.isFinite(delay) && delay <= 1000 && Date.now() + delay < deadline, 'commerce_retry_deferred');
            await sleep(delay); continue;
          }
          throw new SourceError(`commerce_read_http_${response.status}`);
        }
        return await readBounded(response, 1_000_000, signal);
      } catch (error) {
        if (error instanceof SourceError) throw error;
        if (attempt === 2) throw new SourceError('commerce_transport_unavailable');
        await sleep(100 * 2 ** attempt);
      }
    }
    throw new SourceError('commerce_retry_exhausted');
  };
}

export function emptyCommerceDiagnostics(status = 'disabled', failureCode = null) {
  return { version: 1, status, observedAt: null, expiresAt: null, project: COMMERCE_PROJECT, accountId: null, environment: null,
    paymentPending: null, paymentDeadLetters: null, notificationPending: null, notificationDeadLetters: null,
    ownerExceptionCount: null, ownerExceptionGroups: [], workerLiveness: 'unknown', lastWorkerAttemptAt: null, lastWorkerSuccessAt: null,
    failureCode, limits: ['Queue counters do not prove worker execution or provider health.', 'Current RPC does not expose notification pending count or worker execution timestamps.'] };
}

export async function collectCommerceDiagnostics(read, config, startedAt = new Date(), { clock = () => new Date() } = {}) {
  need(config?.enabled === true && config.origin === COMMERCE_ORIGIN && id(config.expectedAccountId, 'acct')
    && ['sandbox', 'live'].includes(config.environment), 'commerce_expected_scope_required');
  const scope = await read('finance_scope');
  need(record(scope) && scope.accountId === config.expectedAccountId && scope.environment === config.environment
    && Array.isArray(scope.payments) && scope.payments.length <= 10_000, 'commerce_scope_mismatch');
  // Validate the source contract but never write its payment identities to diagnostics.
  const seen = new Set();
  for (const payment of scope.payments) {
    need(record(payment) && id(payment.paymentIntentId, 'pi') && payment.source === 'younew-primary' && !seen.has(payment.paymentIntentId), 'commerce_scope_mismatch');
    seen.add(payment.paymentIntentId);
  }
  const raw = await read('diagnostics');
  const now = clock();
  need(now instanceof Date && Number.isFinite(+now) && +now >= +startedAt, 'commerce_observation_clock_invalid');
  need(record(raw) && count(raw.queued) && count(raw.deadLetters) && count(raw.notificationDeadLetters)
    && Array.isArray(raw.exceptions) && raw.exceptions.length <= 10_000, 'commerce_diagnostics_invalid');
  const groups = new Map();
  for (const item of raw.exceptions) {
    need(record(item) && typeof item.code === 'string' && item.code.length <= 80 && Number.isSafeInteger(item.createdAt)
      && item.createdAt > 0 && item.createdAt <= +now, 'commerce_exception_invalid');
    const code = knownCodes.has(item.code) ? item.code : 'other_exception_requires_review';
    const group = groups.get(code) ?? { code, count: 0, oldestAt: new Date(item.createdAt).toISOString() };
    group.count++; if (item.createdAt < Date.parse(group.oldestAt)) group.oldestAt = new Date(item.createdAt).toISOString();
    groups.set(code, group);
  }
  return { ...emptyCommerceDiagnostics('observed'), observedAt: now.toISOString(), expiresAt: new Date(+now + DIAGNOSTICS_MAX_AGE_MS).toISOString(),
    accountId: scope.accountId, environment: scope.environment, paymentPending: raw.queued, paymentDeadLetters: raw.deadLetters,
    notificationDeadLetters: raw.notificationDeadLetters, ownerExceptionCount: raw.exceptions.length,
    ownerExceptionGroups: [...groups.values()].sort((a, b) => a.code.localeCompare(b.code)) };
}

export function commerceReportState(evidence, now = new Date()) {
  if (evidence.status !== 'observed' || Date.parse(evidence.expiresAt) > +now) return evidence;
  return { ...evidence, status: 'stale', paymentPending: null, paymentDeadLetters: null, notificationDeadLetters: null,
    ownerExceptionCount: null, ownerExceptionGroups: [], lastObserved: {
      paymentPending: evidence.paymentPending, paymentDeadLetters: evidence.paymentDeadLetters,
      notificationDeadLetters: evidence.notificationDeadLetters, ownerExceptionCount: evidence.ownerExceptionCount,
      ownerExceptionGroups: evidence.ownerExceptionGroups } };
}

export function commerceReportLines(evidence, now = new Date()) {
  const state = commerceReportState(evidence, now);
  const lines = [`Arrival Commerce · источник ${state.status}; среда ${state.environment ?? 'не установлена'}; срез ${state.observedAt ?? 'не получен'}.`,
    `Очередь платежей (queued/retry/processing): ${state.paymentPending ?? 'неизвестно'}; исчерпаны повторы платежей: ${state.paymentDeadLetters ?? 'неизвестно'}; уведомлений: ${state.notificationDeadLetters ?? 'неизвестно'}.`,
    `Исключения владельца: ${state.ownerExceptionCount ?? 'неизвестно'}. Ожидающие уведомления: неизвестно — текущий RPC их не возвращает.`,
    'Работа worker: UNKNOWN. Время последнего запуска/успеха не доступно; пустая очередь не доказывает исправность.',
    ...state.ownerExceptionGroups.map(group => `Исключение ${group.code}: ${group.count}; самое раннее ${group.oldestAt}.`)];
  if (state.status === 'observed') lines.push(`Это срез очереди, а не доказательство непрерывной работы. После ${state.expiresAt} требуется новое чтение.`);
  if (state.status === 'stale') lines.push('Срез устарел; прежние счётчики не выдаются за текущее состояние.');
  if (state.failureCode) lines.push(`Причина отсутствия данных: ${state.failureCode}.`);
  return lines;
}

export function commerceDecisions(evidence) {
  const prefix = 'Arrival Commerce: ';
  const result = [`${prefix}worker execution and pending notifications remain UNKNOWN; connect timestamped executor evidence before unattended service.`];
  if (evidence.status !== 'observed') result.push(`${prefix}${evidence.status}; read-only diagnostics unavailable. ${evidence.failureCode ?? 'Connect the deployed, scope-verified diagnostics source with the existing private executor credential.'}`);
  if (evidence.paymentDeadLetters > 0 || evidence.notificationDeadLetters > 0 || evidence.ownerExceptionCount > 0) result.push(`${prefix}owner action required: payment dead letters ${evidence.paymentDeadLetters}, notification dead letters ${evidence.notificationDeadLetters}, open exceptions ${evidence.ownerExceptionCount}. Review the private queue before new obligations.`);
  if (evidence.paymentPending > 0) result.push(`${prefix}${evidence.paymentPending} payment jobs await processing; this alone does not establish delay or worker failure.`);
  return result;
}
