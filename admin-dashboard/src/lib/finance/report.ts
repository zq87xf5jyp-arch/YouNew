import { z } from "zod";

export const metricLabels = {
  invoice: "Выставленные счета",
  charge: "Оплаты у провайдера (с налогами)",
  revenue: "Начисленная выручка без НДС",
  refund: "Возвраты без НДС",
  fee: "Комиссии",
  advertising: "Реклама и привлечение",
  infrastructure: "Инфраструктура и AI",
  support: "Оплаченное сопровождение",
  payout: "Подтверждённые выплаты в банк",
  owner_minutes: "Ручная работа, минуты",
  purchases: "Новые покупки",
  renewals: "Продления",
  cancellations: "Отмены",
  new_customers: "Новые платящие клиенты"
} as const;
export type Metric = keyof typeof metricLabels;
const metrics = Object.keys(metricLabels) as [Metric, ...Metric[]];
const money = z.number().int().nonnegative().max(Number.MAX_SAFE_INTEGER / 100_000);
const month = z.string().regex(/^20\d{2}-(0[1-9]|1[0-2])$/);
const currency = z.enum(["EUR", "USD"]);
const reference = z.string().trim().min(1).max(500);
const row = z.object({
  id: reference, provider: reference, reference, month, currency,
  metric: z.enum(metrics), value: money, source: reference,
  environment: z.enum(["live", "sandbox"]), verified: z.boolean(),
  evidence: reference
}).strict();
export const financeSchema = z.object({
  version: z.literal(1), checkedAt: z.string().datetime(),
  method: reference,
  months: z.array(month).min(1),
  rows: z.array(row).max(100_000),
  coverage: z.array(z.object({
    month, currency, metric: z.enum(metrics), evidence: reference
  }).strict()),
  subscriptions: z.array(z.object({
    month, currency, monthlyNetMinor: money, verified: z.boolean(),
    environment: z.enum(["live", "sandbox"]), evidence: reference
  }).strict()),
  customers: z.array(z.object({
    month, currency, activePayingCustomers: money, verified: z.boolean(),
    environment: z.enum(["live", "sandbox"]), evidence: reference
  }).strict()),
  observations: z.array(z.object({ label: reference, detail: z.string().min(1).max(2000), evidence: reference }).strict()),
  decisions: z.array(reference)
}).strict();
export type FinanceSnapshot = z.infer<typeof financeSchema>;

// Inputs are reviewed evidence, not self-authenticating provider statements.
// No payment, bank payout or CRM status is converted into earned revenue.
export function parseFinanceSnapshot(input: unknown): FinanceSnapshot {
  const snapshot = financeSchema.parse(input);
  const ids = new Map<string, string>();
  snapshot.rows = snapshot.rows.filter((entry) => {
    const key = `${entry.environment}:${entry.provider}:${entry.id}`;
    const encoded = JSON.stringify(entry);
    if (ids.has(key)) {
      if (ids.get(key) !== encoded) throw new Error("Conflicting finance evidence identity");
      return false;
    }
    ids.set(key, encoded);
    return true;
  });
  const snapshots = new Set<string>();
  for (const item of snapshot.subscriptions) {
    const key = `${item.environment}:${item.month}:${item.currency}`;
    if (snapshots.has(key)) throw new Error("Duplicate subscription snapshot");
    snapshots.add(key);
  }
  const customers = new Set<string>();
  for (const item of snapshot.customers) {
    const key = `${item.environment}:${item.month}:${item.currency}`;
    if (customers.has(key)) throw new Error("Duplicate customer snapshot");
    customers.add(key);
  }
  return snapshot;
}

export function financeReport(snapshot: FinanceSnapshot, period: string, unit: "EUR" | "USD") {
  const live = snapshot.rows.filter((entry) => entry.month === period && entry.currency === unit && entry.environment === "live" && entry.verified);
  const totals = Object.fromEntries(metrics.map((metric) => {
    const entries = live.filter((entry) => entry.metric === metric);
    const observed = entries.reduce((sum, entry) => sum + entry.value, 0);
    const complete = snapshot.coverage.some((item) => item.month === period && item.currency === unit && item.metric === metric);
    return [metric, { value: complete ? observed : null, observed: entries.length ? observed : null, complete }];
  })) as Record<Metric, { value: number | null; observed: number | null; complete: boolean }>;
  const resultInputs = ["revenue", "refund", "fee", "advertising", "infrastructure", "support"] as const;
  const operatingResult = resultInputs.every((key) => totals[key].value !== null)
    ? totals.revenue.value! - resultInputs.slice(1).reduce((sum, key) => sum + totals[key].value!, 0)
    : null;
  const subscription = snapshot.subscriptions.find((item) => item.month === period && item.currency === unit && item.environment === "live" && item.verified);
  const customers = snapshot.customers.find((item) => item.month === period && item.currency === unit && item.environment === "live" && item.verified);
  const revenueBySource = Array.from(new Set(live.filter((item) => item.metric === "revenue").map((item) => item.source)))
    .map((source) => ({ source, value: live.filter((item) => item.metric === "revenue" && item.source === source).reduce((sum, item) => sum + item.value, 0) }));
  return {
    period, currency: unit, totals, operatingResult, revenueBySource,
    mrr: subscription?.monthlyNetMinor ?? null,
    activePayingCustomers: customers?.activePayingCustomers ?? null,
    cac: totals.advertising.value !== null && totals.new_customers.value !== null && totals.new_customers.value > 0
      ? totals.advertising.value / totals.new_customers.value : null,
    excludedSandboxRows: snapshot.rows.filter((entry) => entry.environment === "sandbox").length,
    rows: live
  };
}

export function formatMoney(value: number | null, unit: string) {
  return value === null ? "Не измерено" : new Intl.NumberFormat("ru-RU", { style: "currency", currency: unit }).format(value / 100);
}
