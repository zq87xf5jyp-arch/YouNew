# B2B payment reconciliation and local pack preparation

Canonical continuation of the reviewed `revenue-first-fulfillment` utility, not a new product. Original frozen files in `/Users/ivan/YouNew-Local-2026-09-18` remain unchanged; `PROVENANCE.json` records the copied source hashes. The selected offer remains the September 19 proposal: one city, 3–5 reviewed official routes, branded HTML/print pack, one revision and 90 days of maintenance. EUR 1,500 is a price hypothesis; a real agreement must settle taxes and the complete amount. No subscription or renewal is created.

## Fixed blocker

The previous idempotency hash included payment `checked_at`, reviewer and evidence reference. A mandatory fresh payment readback therefore prevented reuse of an already-prepared pack. The new implementation compares the unchanged order and its stable payment binding while validating **current** payment/refund evidence on every call. It verifies all original artifact hashes and supports old receipts without rewriting them. A fresh refund still blocks reuse. Prior files and manual work journals remain unchanged.

## Read-only Stripe bridge

`reconcile.mjs` uses the existing pinned Stripe 22.6.2 / `2026-08-26.dahlia` SDK pair. It verifies the configured account, exact one-time Checkout Session, approved product, gross EUR total, PaymentIntent, captured charge, and complete refund history. It refuses live keys/objects, unpaid or delayed payments, disputes, partial/full/pending/failed refunds, truncated results and provider failure. All provider operations are GET/list. It cannot create checkout, charge a card, issue a refund, activate live payments or email anyone.

The order-to-provider binding is a trusted operator file, never a browser-supplied subject or metadata claim. Fields: `schema_version: 1`, `order_id`, `account_id`, `session_id` (`cs_test_…`), `payment_intent_id`, and `product_id`. Use the selected order's exact approved amount; the bridge does not invent a VAT rate. Only a test secret/restricted key supplied securely as `YOUNEW_STRIPE_TEST_READ_KEY` is accepted. Do not put keys or private order files in Git or shell history.

From this directory with Node 24 and Python 3.9+:

```sh
npm ci --offline --ignore-scripts --no-audit --no-fund
python3 -m unittest -v
node --test test_reconcile.mjs
node reconcile.mjs /private/binding.json /private/order.json /private/output
node reconcile.mjs /private/binding.json /private/order.json /private/output --prepare
```

The first reconciliation command verifies without preparing. The second prepares the local pack automatically after successful current provider verification and all existing agreement/source-review gates. Always reuse one private output root: its file lock and payment registry are local, not distributed. There is no background executor in this module. Python input arrives over stdin and the child does not inherit provider credentials.

`prepared_not_sent` is distinct from delivery and acceptance. The HTML remains a dated copy; an offline download cannot be recalled. No authenticated hosted download or email delivery is claimed. A refund can occur after a provider read; this module does not pretend to provide a cross-provider transaction. Reconcile again before any separately authorized customer delivery.

The immutable ledger retains its initial evidence, not a live provider balance. `provider_verified_by_cli` remains false because the Python entry point accepts trusted input; `payment_evidence_method` identifies bridge input and the bridge result separately reports its current successful read. Sandbox real receipts and MRR are zero. Fees, VAT, profit and bank settlement are not inferred. Optional analytics are absent.

## Executed evidence and remaining gates

See `VALIDATION.json`: Python regression suite plus Node provider-normalization and real Node→Python artifact tests. One test exercises the pinned SDK with an in-memory HTTP fixture. Synthetic tests do not demonstrate hosted Stripe webhook delivery or real provider-to-application integration. Historical Dashboard success and full refund of a sandbox EUR 1,500 charge are preserved in `revenue-first-web/evidence/STRIPE_SANDBOX_SUCCESS.json` and `STRIPE_SANDBOX_REFUND.json`; they are not new payments or API tests.

No test API key was available in this session. No hosted webhook, production service executor, customer delivery, bank payout, real contract or factual approval has been completed. The current state is **LOCAL CHECKS PASSED / LAUNCH BLOCKED**, not full TECHNICALLY READY. Owner seller/KvK/VAT details, material approval, live onboarding, hosted delivery/service wiring and an approved operating mandate remain launch gates. Stop by disabling the executor/CTA when one is eventually deployed; preserve receipts, fulfilled files and work logs. No deployment or database change is required to roll back this local utility.

## Rules checked on 2026-09-19

- [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/): external purchase rules differ by storefront; enterprise access has specific eligibility, so this public free iOS app receives no external checkout or paid unlock from this change. A web B2B service is the present scope; do not assume the enterprise exception covers future consumer sales.
- [Stripe webhooks](https://docs.stripe.com/webhooks): event delivery may be duplicated and unordered; a future webhook must verify signatures, durably record IDs and reconcile current provider state. This polling bridge does not claim webhook verification.
- [Stripe refunds](https://docs.stripe.com/refunds): refunds may remain pending or fail. Any refund history is therefore routed to review here rather than silently treating the order as fully funded.
- [Checkout retrieval](https://docs.stripe.com/api/checkout/sessions/retrieve), [PaymentIntent retrieval](https://docs.stripe.com/api/payment_intents/retrieve), [refund listing](https://docs.stripe.com/api/refunds/list): current server retrieval underpins the four bounded reads. Never grant delivery from a success redirect.

Actual Stripe live fees and seller tax status are unverified. Published provider price examples are not the account's contracted rate.
