import Stripe from 'stripe';
import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

// Reuses the SDK/API pair already checked in the consumer billing candidate.
export const API_VERSION = '2026-08-26.dahlia';
class GateError extends Error {}
const need = (condition, code) => { if (!condition) throw new GateError(code); };
const ref = value => typeof value === 'string' ? value : value?.id;
const id = (value, prefix) => typeof value === 'string' && new RegExp(`^${prefix}_[A-Za-z0-9]{1,200}$`).test(value);

export function createTestProvider(secret) {
  need(typeof secret === 'string' && /^(sk|rk)_test_[A-Za-z0-9]+$/.test(secret), 'test_key_required');
  // Only retrieval/list methods below are used; no checkout, charge or refund write.
  return new Stripe(secret, { apiVersion: API_VERSION, maxNetworkRetries: 1, timeout: 10_000 });
}

export async function verifyTestPayment(stripe, binding, order, now = new Date()) {
  need(order.mode === 'sandbox', 'sandbox_order_required');
  need(binding && binding.schema_version === 1 && binding.order_id === order.id
    && id(binding.account_id, 'acct') && id(binding.payment_intent_id, 'pi')
    && id(binding.product_id, 'prod') && /^cs_test_[A-Za-z0-9]{1,200}$/.test(binding.session_id), 'invalid_binding');
  need(Number.isSafeInteger(order.amount_minor) && order.amount_minor > 0 && order.currency === 'EUR', 'invalid_order_amount');
  need(Number.isFinite(now.getTime()), 'invalid_clock');
  const account = await stripe.accounts.retrieve();
  need(account.id === binding.account_id, 'account_mismatch');
  const session = await stripe.checkout.sessions.retrieve(binding.session_id, { expand: ['line_items'] });
  need(session.id === binding.session_id && session.object === 'checkout.session'
    && session.livemode === false && session.mode === 'payment' && session.subscription === null,
  'unsupported_session');
  need(session.status === 'complete' && session.payment_status === 'paid', 'session_not_paid');
  need(ref(session.payment_intent) === binding.payment_intent_id
    && session.amount_total === order.amount_minor && session.currency === 'eur', 'session_binding_mismatch');
  need(session.line_items?.has_more === false && session.line_items.data?.length === 1,
    'incomplete_line_items');
  const line = session.line_items.data[0];
  need(line.quantity === 1 && line.price?.livemode === false && line.price?.type === 'one_time'
    && ref(line.price.product) === binding.product_id && line.amount_total === order.amount_minor,
  'product_or_amount_mismatch');
  const payment = await stripe.paymentIntents.retrieve(binding.payment_intent_id, { expand: ['latest_charge'] });
  need(payment.id === binding.payment_intent_id && payment.object === 'payment_intent'
    && payment.livemode === false && payment.status === 'succeeded'
    && payment.amount_received === order.amount_minor && payment.amount === order.amount_minor
    && payment.currency === 'eur', 'payment_not_confirmed');
  const charge = payment.latest_charge;
  need(charge && typeof charge !== 'string' && id(charge.id, 'ch') && charge.object === 'charge'
    && charge.livemode === false && ref(charge.payment_intent) === payment.id && charge.status === 'succeeded'
    && charge.paid === true && charge.captured === true && charge.amount === order.amount_minor
    && charge.currency === 'eur', 'charge_not_confirmed');
  need(charge.disputed === false && charge.refunded === false && charge.amount_refunded === 0,
    'refund_or_dispute_blocks_preparation');
  const refunds = await stripe.refunds.list({ payment_intent: payment.id, limit: 100 });
  need(refunds.object === 'list' && refunds.has_more === false && Array.isArray(refunds.data), 'incomplete_refunds');
  // Conservative: even a failed/cancelled refund needs a human decision. Do not
  // deliver while a requested refund may still change state or need support.
  need(refunds.data.length === 0, 'refund_history_requires_review');
  return {
    schema_version: 1, mode: 'sandbox', id: payment.id, order_id: order.id,
    status: 'confirmed_charge', amount_minor: order.amount_minor, currency: 'EUR',
    refund_status: 'none_confirmed', refunded_amount_minor: 0,
    reference: `stripe-test-api:${binding.account_id}/${session.id}/${charge.id}`,
    checked_at: now.toISOString().replace(/\.\d{3}Z$/, 'Z'),
    method: 'stripe_test_api_readback', reviewed_by: 'bounded Stripe test readback bridge'
  };
}

export function prepareVerified(order, payment, outputRoot, now = new Date()) {
  // Data travels on stdin; no secret, order data or shell interpolation in argv.
  const child = spawnSync('python3', [fileURLToPath(new URL('./reconcile_prepare.py', import.meta.url)), resolve(outputRoot)], {
    input: JSON.stringify({ order, payment, now: now.toISOString().replace(/\.\d{3}Z$/, 'Z') }),
    encoding: 'utf8', timeout: 15_000, maxBuffer: 128 * 1024,
    env: { PATH: process.env.PATH ?? '/usr/bin:/bin', PYTHONDONTWRITEBYTECODE: '1' }
  });
  need(!child.error && child.status === 0, 'local_preparation_refused');
  return JSON.parse(child.stdout);
}

async function main() {
  const [bindingPath, orderPath, outputRoot, prepareFlag] = process.argv.slice(2);
  need(bindingPath && orderPath && outputRoot && (!prepareFlag || prepareFlag === '--prepare'),
    'usage: node reconcile.mjs binding.json order.json /private/output [--prepare]');
  const binding = JSON.parse(readFileSync(bindingPath, 'utf8'));
  const order = JSON.parse(readFileSync(orderPath, 'utf8'));
  const stripe = createTestProvider(process.env.YOUNEW_STRIPE_TEST_READ_KEY);
  const payment = await verifyTestPayment(stripe, binding, order);
  const result = prepareFlag ? prepareVerified(order, payment, outputRoot) : { status: 'verified_not_prepared' };
  process.stdout.write(JSON.stringify({ ...result, mode: 'sandbox', provider_verified_by_bridge: true,
    payment_id: payment.id, checked_at: payment.checked_at, real_receipts_minor: 0,
    delivery_status: 'not_sent', recurring: false, mrr_minor: 0 }) + '\n');
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main().catch(error => {
    // Provider errors can contain request context. Only our allowlisted codes
    // cross the CLI boundary; never emit SDK errors, headers or secrets.
    const code = error instanceof GateError ? error.message : 'provider_read_failed';
    process.stderr.write(`NOT PREPARED: ${code}\n`); process.exitCode = 2;
  });
}
