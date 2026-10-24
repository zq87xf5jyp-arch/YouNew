import { parseFinanceSnapshot, financeReport, formatMoney } from '../../src/lib/finance/report.ts';

export class SourceError extends Error {}
const need = (ok, code) => { if (!ok) throw new SourceError(code); };
const identifier = (value, prefix) => typeof value === 'string' && new RegExp(`^${prefix}_[A-Za-z0-9]{1,200}$`).test(value);
const minor = value => Number.isSafeInteger(value) && value >= 0 && value <= 90_071_992_547;
const reference = value => typeof value === 'string' ? value : value?.id;
const instant = value => Number.isSafeInteger(value) && value > 0 ? new Date(value * 1000).toISOString() : null;
const keyOf = row => `${row.environment}:${row.provider}:${row.id}`;
const utcInstant = value => typeof value === 'string' && /^20\d{2}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z$/.test(value)
  && Number.isFinite(Date.parse(value)) && new Date(value).toISOString() === (value.includes('.') ? value : value.replace('Z', '.000Z'));
export const API_VERSION = '2026-08-26.dahlia';

export function validateScope(scope) {
  need(scope && identifier(scope.accountId, 'acct') && ['live', 'sandbox'].includes(scope.environment), 'scope_account_or_environment_invalid');
  need(typeof scope.evidence === 'string' && scope.evidence.length > 0 && scope.evidence.length <= 500, 'scope_evidence_required');
  need(Array.isArray(scope.payments) && scope.payments.length <= 100, 'scope_payment_limit');
  const seen = new Set();
  for (const item of scope.payments) {
    need(identifier(item.paymentIntentId, 'pi') && typeof item.source === 'string' && /^younew-[a-z0-9_-]{1,100}$/.test(item.source), 'invalid_younew_payment_binding');
    need(!seen.has(item.paymentIntentId), 'duplicate_payment_binding');
    seen.add(item.paymentIntentId);
  }
  return scope;
}

// Only this fixed host and these GET paths exist. No mutable provider capability.
export function stripeReader(secret, environment, { fetcher = fetch, sleep = ms => new Promise(r => setTimeout(r, ms)), timeoutMs = 10_000, deadline = Date.now() + 120_000 } = {}) {
  need(['live', 'sandbox'].includes(environment), 'provider_environment_invalid');
  need(typeof secret === 'string' && new RegExp(`^rk_${environment === 'live' ? 'live' : 'test'}_[A-Za-z0-9]+$`).test(secret), 'restricted_read_key_missing_or_wrong_environment');
  return async (path, query = {}) => {
    need(/^\/v1\/(account|payment_intents\/pi_[A-Za-z0-9]+|balance_transactions\/txn_[A-Za-z0-9]+|refunds)$/.test(path), 'endpoint_not_allowed');
    const url = new URL(path, 'https://api.stripe.com');
    for (const [key, value] of Object.entries(query)) url.searchParams.set(key, String(value));
    for (let attempt = 0; attempt < 3; attempt++) {
      need(Date.now() < deadline, 'source_deadline_exceeded');
      try {
        const response = await fetcher(url, { method: 'GET', redirect: 'error', headers: {
          Authorization: `Bearer ${secret}`, 'Stripe-Version': API_VERSION
        }, signal: AbortSignal.timeout(Math.max(1, Math.min(timeoutMs, deadline - Date.now()))) });
        if (!response.ok) {
          if ((response.status === 429 || response.status >= 500) && attempt < 2) {
            const retryAfter = response.headers.get('retry-after');
            const delay = retryAfter === null ? 250 * 2 ** attempt : /^\d+$/.test(retryAfter) ? Number(retryAfter) * 1000 : NaN;
            // Long or unrecognized provider limits defer to the next executor run.
            need(Number.isFinite(delay) && delay <= 1000 && Date.now() + delay < deadline, 'provider_retry_deferred');
            await sleep(delay); continue;
          }
          throw new SourceError(`stripe_read_http_${response.status}`);
        }
        const body = await response.text();
        need(body.length <= 2_000_000, 'provider_response_too_large');
        return JSON.parse(body);
      } catch (error) {
        if (error instanceof SourceError) throw error;
        if (attempt === 2) throw new SourceError('stripe_transport_or_response_failed');
        await sleep(100 * 2 ** attempt);
      }
    }
    throw new SourceError('stripe_retry_exhausted');
  };
}

export async function collectStripe(read, rawScope, now = new Date()) {
  const scope = validateScope(rawScope);
  const live = scope.environment === 'live';
  const account = await read('/v1/account');
  need(account.id === scope.accountId && account.object === 'account', 'provider_account_mismatch');
  const rows = [], events = [], exceptions = [];
  const provider = `Stripe:${scope.accountId}`;
  const evidence = `stripe-read-only:${scope.accountId}; checked ${now.toISOString()}`;
  const seenTransactions = new Set();
  function event(type, objectId, value, currency, occurredAt, source) {
    need(occurredAt && new Date(occurredAt) <= now, 'provider_event_time_invalid');
    need(['eur', 'usd'].includes(currency) && minor(value), 'provider_amount_or_currency_unsupported');
    const normalized = { type, id: objectId, value, currency: currency.toUpperCase(), occurredAt, source, environment: scope.environment, evidence };
    events.push(normalized);
    return normalized;
  }
  function rowFrom(item, metric, ref) {
    rows.push({ id: `${metric}:${item.id}`, provider, reference: ref, month: item.occurredAt.slice(0, 7), currency: item.currency,
      metric, value: item.value, source: item.source, environment: item.environment, verified: true, evidence });
  }
  async function fee(transactionId, sourceId, source) {
    if (!transactionId) { exceptions.push({ code: 'balance_transaction_pending', reference: sourceId }); return; }
    need(identifier(transactionId, 'txn'), 'balance_transaction_id_invalid');
    if (seenTransactions.has(transactionId)) return;
    const transaction = await read(`/v1/balance_transactions/${transactionId}`);
    need(transaction.id === transactionId && transaction.object === 'balance_transaction' && reference(transaction.source) === sourceId, 'balance_transaction_binding_mismatch');
    seenTransactions.add(transactionId);
    // A negative fee is a credit. Current accounting schema only accepts positive
    // expense rows: keep the signed fact for review, never clamp it to zero.
    if (!minor(transaction.fee)) { exceptions.push({ code: 'fee_credit_or_invalid_fee_requires_accounting', reference: transactionId }); return; }
    rowFrom(event('fee', transactionId, transaction.fee, transaction.currency, instant(transaction.created), source), 'fee', transactionId);
  }
  for (const binding of scope.payments) {
    const payment = await read(`/v1/payment_intents/${binding.paymentIntentId}`, { 'expand[]': 'latest_charge' });
    need(payment.id === binding.paymentIntentId && payment.object === 'payment_intent' && payment.livemode === live, 'payment_identity_or_environment_mismatch');
    const charge = payment.latest_charge;
    if (payment.status !== 'succeeded') { exceptions.push({ code: 'scoped_payment_not_succeeded', reference: binding.paymentIntentId }); continue; }
    need(charge && typeof charge === 'object' && identifier(charge.id, 'ch') && charge.object === 'charge' && charge.livemode === live && reference(charge.payment_intent) === payment.id, 'charge_identity_or_environment_mismatch');
    need(charge.paid === true && charge.captured === true && charge.status === 'succeeded' && minor(charge.amount_captured)
      && charge.amount_captured > 0 && charge.amount_captured === charge.amount && payment.amount_received === charge.amount_captured
      && charge.currency === payment.currency, 'charge_capture_unconfirmed');
    rowFrom(event('charge', charge.id, charge.amount_captured, charge.currency, instant(charge.created), binding.source), 'charge', payment.id);
    if (charge.disputed !== false) exceptions.push({ code: 'dispute_requires_review', reference: charge.id });
    await fee(reference(charge.balance_transaction), charge.id, binding.source);
    let after, finished = false, successfulRefunds = 0;
    const seenRefunds = new Set();
    for (let page = 0; page < 5; page++) {
      const refunds = await read('/v1/refunds', { payment_intent: payment.id, limit: 100, ...(after ? { starting_after: after } : {}) });
      need(refunds.object === 'list' && typeof refunds.has_more === 'boolean' && Array.isArray(refunds.data) && refunds.data.length <= 100, 'invalid_refund_page');
      for (const refund of refunds.data) {
        need(refund.object === 'refund' && identifier(refund.id, 're') && reference(refund.payment_intent) === payment.id && reference(refund.charge) === charge.id
          && (refund.livemode === undefined || refund.livemode === live) && refund.currency === charge.currency, 'refund_binding_mismatch');
        need(!seenRefunds.has(refund.id), 'duplicate_refund_page'); seenRefunds.add(refund.id);
        if (refund.status !== 'succeeded') { exceptions.push({ code: 'refund_not_final', reference: refund.id }); continue; }
        const item = event('refund_gross', refund.id, refund.amount, refund.currency, instant(refund.created), binding.source);
        successfulRefunds += item.value;
        await fee(reference(refund.balance_transaction), refund.id, binding.source);
      }
      if (!refunds.has_more) { finished = true; break; }
      need(refunds.data.length > 0, 'empty_refund_pagination'); after = refunds.data.at(-1).id;
    }
    need(finished, 'refund_pagination_limit');
    need(minor(charge.amount_refunded) && successfulRefunds === charge.amount_refunded && successfulRefunds <= charge.amount_captured, 'refund_totals_inconsistent');
  }
  return { status: exceptions.length ? 'partial' : 'scoped_read_complete', accountId: scope.accountId, environment: scope.environment,
    checkedAt: now.toISOString(), rows, events, exceptions, scopeCount: scope.payments.length,
    coverage: [], note: 'Only trusted YouNew payment bindings; never full business coverage. Gross refunds are not refunds of earned revenue. No bank payout evidence.' };
}

export function reportingWindow(ending, now = new Date()) {
  const value = ending ?? now.toISOString().slice(0, 10);
  need(/^20\d{2}-\d{2}-\d{2}$/.test(value), 'invalid_week_end');
  const end = new Date(`${value}T00:00:00Z`);
  need(Number.isFinite(+end) && end.toISOString().slice(0, 10) === value && end <= now, 'invalid_or_future_week_end');
  return { start: new Date(+end - 7 * 86400000).toISOString(), end: end.toISOString() };
}

export function combineSnapshot(reviewed, provider, now) {
  const original = parseFinanceSnapshot(reviewed);
  const rows = [...original.rows];
  for (const fresh of provider.rows) {
    // Same observed charge/fee must not survive twice under a manual label.
    for (let i = rows.length - 1; i >= 0; i--) {
      if (rows[i].environment === fresh.environment && rows[i].metric === fresh.metric
        && (keyOf(rows[i]) === keyOf(fresh) || (/^Stripe(?::|$)/i.test(rows[i].provider) && rows[i].reference === fresh.reference))) rows.splice(i, 1);
    }
    rows.push(fresh);
  }
  const closedAtReview = period => new Date(`${period}-01T00:00:00Z`).getTime() < +new Date(original.checkedAt)
    && new Date(Date.UTC(Number(period.slice(0, 4)), Number(period.slice(5, 7)), 1)) <= new Date(original.checkedAt);
  const touched = new Set(provider.rows.map(row => `${row.month}:${row.currency}:${row.metric}`));
  return parseFinanceSnapshot({ ...original, checkedAt: now.toISOString(),
    method: `Read-only source reconciliation; accounting snapshot dated ${original.checkedAt}; partial scope, no automatic accrual or bank confirmation`,
    months: [...new Set([...original.months, ...rows.map(row => row.month)])].sort(), rows,
    // Existing open-month coverage cannot be rolled forward to a newer timestamp.
    coverage: original.coverage.filter(item => closedAtReview(item.month) && !touched.has(`${item.month}:${item.currency}:${item.metric}`)),
    subscriptions: original.subscriptions.filter(item => closedAtReview(item.month)),
    customers: original.customers.filter(item => closedAtReview(item.month)),
    observations: [...original.observations, { label: 'Accounting evidence date', detail: `Existing accounting assertions were reviewed at ${original.checkedAt}. Provider charge data does not verify revenue, full costs, bank receipt, MRR or customer totals.`, evidence: 'reviewed accounting snapshot; retained separately in run inputs' }],
    decisions: [...new Set([...original.decisions, ...provider.exceptions.map(item => `Financial reconciliation: ${item.code}`)])]
  });
}

export function validateJournal(input, now) {
  need(input && input.version === 1 && Array.isArray(input.entries) && input.entries.length <= 100_000
    && Array.isArray(input.coverage) && utcInstant(input.checkedAt)
    && new Date(input.checkedAt) <= now, 'accounting_journal_invalid');
  const rows = input.entries.map(({ occurredAt, ...row }) => {
    need(utcInstant(occurredAt) && new Date(occurredAt) <= now && new Date(occurredAt) <= new Date(input.checkedAt)
      && row.month === occurredAt.slice(0, 7), 'accounting_entry_date_invalid');
    return row;
  });
  const blank = { version: 1, checkedAt: new Date(input.checkedAt).toISOString(), method: 'Reviewed dated accounting journal', months: [...new Set(rows.map(row => row.month)), now.toISOString().slice(0, 7)],
    rows, coverage: [], subscriptions: [], customers: [], observations: [], decisions: [] };
  const parsed = parseFinanceSnapshot(blank);
  need(parsed.rows.length === rows.length, 'accounting_journal_duplicate_entry');
  for (const item of input.coverage) {
    need(utcInstant(item.start) && utcInstant(item.end) && Date.parse(item.start) < Date.parse(item.end)
      && new Date(item.end) <= new Date(input.checkedAt), 'accounting_coverage_window_invalid');
    parseFinanceSnapshot({ ...blank, rows: [], coverage: [{ month: now.toISOString().slice(0, 7), currency: item.currency, metric: item.metric, evidence: item.evidence }] });
  }
  return input;
}

export function makeReport(snapshot, provider, window, now, journal = null) {
  const events = provider.events.filter(item => item.environment === 'live' && item.occurredAt >= window.start && item.occurredAt < window.end);
  const observed = [];
  for (const item of events) {
    let group = observed.find(row => row.type === item.type && row.source === item.source && row.currency === item.currency);
    if (!group) { group = { type: item.type, source: item.source, currency: item.currency, value: 0, events: 0 }; observed.push(group); }
    group.value += item.value; group.events++;
  }
  const period = `week:[${window.start},${window.end})`;
  const dated = (journal?.entries ?? []).filter(item => Date.parse(item.occurredAt) >= Date.parse(window.start) && Date.parse(item.occurredAt) < Date.parse(window.end)).map(({ occurredAt, ...row }) => ({ ...row, month: period }));
  const changedMetrics = new Set();
  for (const item of events.filter(item => item.type === 'charge' || item.type === 'fee')) {
    const row = provider.rows.find(row => row.id === `${item.type}:${item.id}`);
    if (!row) continue;
    const matches = dated.filter(old => old.environment === row.environment && old.metric === row.metric && (keyOf(old) === keyOf(row)
      || (/^Stripe(?::|$)/i.test(old.provider) && old.reference === row.reference)));
    if (matches.length !== 1 || matches[0].value !== row.value || matches[0].currency !== row.currency || !matches[0].verified) changedMetrics.add(`${row.currency}:${row.metric}`);
    for (const match of matches) dated.splice(dated.indexOf(match), 1);
    dated.push({ ...row, month: period });
  }
  const coverage = (journal?.coverage ?? []).filter(item => Date.parse(item.start) <= Date.parse(window.start) && Date.parse(item.end) >= Date.parse(window.end)
    && !changedMetrics.has(`${item.currency}:${item.metric}`)).map(item => ({ month: period, currency: item.currency, metric: item.metric, evidence: item.evidence }));
  // The shared engine aggregates validated rows over a window label. Source rows
  // retain their real dates/months in the journal; no artificial monthly data is saved.
  const weeklyReports = ['EUR', 'USD'].map(currency => financeReport({ ...snapshot, rows: dated, coverage, subscriptions: [], customers: [] }, period, currency));
  const reviewedOperationalObservations = snapshot.observations.filter(item =>
    ['Arrival sandbox acceptance', 'Arrival sandbox test controls', 'Supabase · оплаченные счета USD 50'].includes(item.label));
  const report = { schemaVersion: 1, generatedAt: now.toISOString(), window, state: 'partial_not_reconciled',
    observedLiveProviderEvents: observed, sandboxEventsExcluded: provider.events.filter(item => item.environment === 'sandbox').length,
    weeklyReports, accountingJournalCheckedAt: journal?.checkedAt ?? null,
    monthlyReports: snapshot.months.flatMap(month => ['EUR', 'USD'].map(currency => financeReport(snapshot, month, currency))),
    exceptions: provider.exceptions, decisions: snapshot.decisions, reviewedOperationalObservations,
    limits: ['Weekly accounting requires dated reviewed journal entries plus explicit interval coverage; monthly snapshots are not reassigned to weeks.', 'The order scope does not prove all-provider completeness.', 'Provider receipts, earned revenue and bank payouts remain separate.'],
    deliveryStatus: 'prepared_not_sent' };
  const lines = [`YouNew · недельный отчёт ${window.start.slice(0,10)} — ${window.end.slice(0,10)} (конец не включён, UTC)`, '',
    `Проверка источника: ${provider.status}. Срез ${now.toISOString()}.`,
    ...observed.map(item => `Подтверждённая часть · ${item.type} · ${item.source}: ${formatMoney(item.value, item.currency)} (${item.events} операций).`),
    provider.status === 'unavailable' ? 'Нет доступа к свежей сверке провайдера. Live-поступления за неделю не установлены.'
      : provider.environment === 'sandbox' ? 'Проверен только sandbox; live-поступления за неделю не установлены.'
      : observed.length ? 'Полнота поступлений не подтверждена.' : 'В проверенной разрешённой выборке live-операций за неделю не найдено; общая выручка неизвестна.',
    ...weeklyReports.map(item => `${item.currency}: выручка без НДС ${formatMoney(item.totals.revenue.value, item.currency)}; результат ${formatMoney(item.operatingResult, item.currency)}; поступления в банк ${formatMoney(item.totals.payout.value, item.currency)}.`),
    ...weeklyReports.map(item => `${item.currency}: новые клиенты ${item.totals.new_customers.value ?? 'не измерено'}; продления ${item.totals.renewals.value ?? 'не измерено'}; отмены ${item.totals.cancellations.value ?? 'не измерено'}; часы владельца ${item.totals.owner_minutes.value === null ? 'не измерено' : item.totals.owner_minutes.value / 60}.`),
    'Тестовые платежи sandbox не включаются в доход.', '',
    'Главный барьер: отсутствует полная сверка доступных платёжных источников, начисленной выручки, расходов и банка.',
    ...provider.exceptions.map(item => `Требуется действие: ${item.code}.`),
    'Месячные факты сохранены отдельно: их нельзя автоматически приписывать этой неделе.',
    'Каналы, эффект улучшений и переговоры с покупателями: источник этой финансовой задачи их не измеряет.',
    ...(reviewedOperationalObservations.length ? ['', 'Датированные финансовые и операционные сведения — не полная сверка периода и не новая проверка:',
      ...reviewedOperationalObservations.flatMap(item => [`${item.label}: ${item.detail}`, `Источник: ${item.evidence}`])] : [])
  ];
  return { report, markdown: lines.join('\n') + '\n' };
}
