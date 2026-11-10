import assert from "node:assert/strict";
import test from "node:test";
import { financeReport, parseFinanceSnapshot, type FinanceSnapshot } from "../src/lib/finance/report.ts";
import { canAccessPath } from "../src/lib/authorization.ts";

const blank = (): FinanceSnapshot => ({ version: 1, checkedAt: "2026-09-19T12:07:51Z", method: "reviewed provider statements", months: ["2026-09"], rows: [], coverage: [], subscriptions: [], customers: [], observations: [], decisions: [] });
const entry = (overrides = {}) => ({ id: "payment-1", provider: "test-provider", reference: "statement-line-1", month: "2026-09", currency: "EUR", metric: "charge", value: 150000, source: "b2b-pilot", environment: "live", verified: true, evidence: "provider statement", ...overrides });

test("no source coverage never produces zero revenue, profit or MRR", () => {
  const report = financeReport(blank(), "2026-09", "EUR");
  assert.equal(report.totals.revenue.value, null);
  assert.equal(report.operatingResult, null);
  assert.equal(report.mrr, null);
  assert.equal(report.cac, null);
});
test("sandbox, unverified evidence and other currencies are excluded", () => {
  const data = parseFinanceSnapshot({ ...blank(), rows: [entry({ environment: "sandbox" }), entry({ id: "p2", verified: false }), entry({ id: "p3", currency: "USD" })] });
  const report = financeReport(data, "2026-09", "EUR");
  assert.equal(report.totals.charge.observed, null);
  assert.equal(report.excludedSandboxRows, 1);
  assert.equal(financeReport(data, "2026-09", "USD").totals.charge.observed, 150000);
});
test("charge does not establish earned revenue, bank payout or MRR", () => {
  const data = parseFinanceSnapshot({ ...blank(), rows: [entry()] });
  const report = financeReport(data, "2026-09", "EUR");
  assert.equal(report.totals.charge.observed, 150000);
  assert.equal(report.totals.charge.value, null);
  assert.equal(report.totals.revenue.value, null);
  assert.equal(report.totals.payout.value, null);
  assert.equal(report.mrr, null);
});
test("identical rows deduplicate; contradictory financial identity fails closed", () => {
  assert.equal(parseFinanceSnapshot({ ...blank(), rows: [entry(), entry()] }).rows.length, 1);
  assert.throws(() => parseFinanceSnapshot({ ...blank(), rows: [entry(), entry({ value: 1 })] }), /Conflicting/);
});
test("profit is calculated only with every cost category reconciled; payouts not deducted twice", () => {
  const keys = ["revenue", "refund", "fee", "advertising", "infrastructure", "support"];
  const data = parseFinanceSnapshot({ ...blank(), rows: [entry({ metric: "revenue", value: 10000 }), entry({ id: "fee", metric: "fee", value: 1000 }), entry({ id: "payout", metric: "payout", value: 9000 })], coverage: keys.map((metric) => ({ month: "2026-09", currency: "EUR", metric, evidence: "reviewed all accounts and accruals" })) });
  assert.equal(financeReport(data, "2026-09", "EUR").operatingResult, 9000);
  data.coverage.pop();
  assert.equal(financeReport(data, "2026-09", "EUR").operatingResult, null);
});
test("full refund retains history and can yield negative result after nonrefundable fees", () => {
  const keys = ["revenue", "refund", "fee", "advertising", "infrastructure", "support"];
  const data = parseFinanceSnapshot({ ...blank(), rows: [entry({ metric: "revenue", value: 150000 }), entry({ id: "refund", metric: "refund", value: 150000 }), entry({ id: "fee", metric: "fee", value: 4750 })], coverage: keys.map((metric) => ({ month: "2026-09", currency: "EUR", metric, evidence: "reconciled" })) });
  assert.equal(financeReport(data, "2026-09", "EUR").operatingResult, -4750);
});
test("period isolation, covered zero and division by zero remain distinct", () => {
  const data = parseFinanceSnapshot({ ...blank(), rows: [entry({ month: "2026-08" })], coverage: ["charge", "advertising", "new_customers"].map((metric) => ({ month: "2026-09", currency: "EUR", metric, evidence: "all sources covered" })) });
  const report = financeReport(data, "2026-09", "EUR");
  assert.equal(report.totals.charge.value, 0);
  assert.equal(report.cac, null);
});
test("malformed evidence and negative/fractional amounts are rejected", () => {
  for (const value of [-1, 0.5, Number.MAX_SAFE_INTEGER]) assert.throws(() => parseFinanceSnapshot({ ...blank(), rows: [entry({ value })] }));
  assert.throws(() => parseFinanceSnapshot({ ...blank(), rows: [entry({ evidence: "" })] }));
  assert.throws(() => parseFinanceSnapshot({ ...blank(), rows: [entry({ month: "2026-99" })] }));
});
test("finance route is restricted to owner including nested routes", () => {
  for (const role of ["admin", "editor", "qa", "viewer"] as const) assert.equal(canAccessPath(role, "/finance"), false);
  assert.equal(canAccessPath("owner", "/finance"), true);
  assert.equal(canAccessPath("viewer", "/finance/export"), false);
});
test("unverified and sandbox MRR are excluded; one-off customers are counted independently", () => {
  const base = { month: "2026-09", currency: "EUR", evidence: "provider balances", environment: "live" };
  const data = parseFinanceSnapshot({ ...blank(), subscriptions: [{ ...base, monthlyNetMinor: 9999, verified: false }, { ...base, environment: "sandbox", monthlyNetMinor: 20000, verified: true }], customers: [{ ...base, activePayingCustomers: 1, verified: true }] });
  assert.equal(financeReport(data, "2026-09", "EUR").mrr, null);
  assert.equal(financeReport(data, "2026-09", "EUR").activePayingCustomers, 1);
  data.subscriptions[0].verified = true;
  assert.equal(financeReport(data, "2026-09", "EUR").mrr, 9999);
});
