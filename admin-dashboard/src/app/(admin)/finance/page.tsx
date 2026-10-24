import { redirect } from "next/navigation";
import { PageHeader } from "@/components/admin/page-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { requireAdmin } from "@/lib/auth";
import { loadFinanceSnapshot } from "@/lib/finance/load";
import { financeReport, formatMoney, metricLabels, type Metric } from "@/lib/finance/report";

export const dynamic = "force-dynamic";

export default async function FinancePage({ searchParams }: { searchParams: Promise<{ month?: string; currency?: string }> }) {
  const admin = await requireAdmin();
  if (admin.role !== "owner") redirect("/dashboard?error=forbidden");
  const { snapshot, error } = await loadFinanceSnapshot();
  const params = await searchParams;
  const period = snapshot?.months.includes(params.month ?? "") ? params.month! : snapshot?.months.toSorted().at(-1) ?? "";
  const unit = params.currency === "USD" ? "USD" : "EUR";
  const report = snapshot ? financeReport(snapshot, period, unit) : null;
  const valueText = (key: Metric, value: number | null) => ["owner_minutes", "purchases", "renewals", "cancellations", "new_customers"].includes(key)
    ? value === null ? "Не измерено" : String(value)
    : formatMoney(value, unit);
  return <>
    <PageHeader title="Финансы YouNew" description="Реальные оплаты, начисленная выручка и банковские выплаты учитываются отдельно. Sandbox исключён. Доступ только владельцу." />
    {error || !snapshot || !report ? <Card><CardHeader><CardTitle>Нет доступа к финансовым данным</CardTitle></CardHeader><CardContent>{error}</CardContent></Card> : <>
      <p className="mb-4 text-sm text-muted-foreground">Срез: {snapshot.checkedAt} · {snapshot.method}. Это датированный снимок, не онлайн-синхронизация.</p>
      <form className="mb-6 flex flex-wrap items-end gap-4" action="/finance" method="get">
        <label className="grid gap-1 text-sm">Месяц<select aria-label="Месяц" name="month" defaultValue={period} className="rounded border border-border bg-background p-2">{snapshot.months.map((item) => <option key={item}>{item}</option>)}</select></label>
        <label className="grid gap-1 text-sm">Валюта<select aria-label="Валюта" name="currency" defaultValue={unit} className="rounded border border-border bg-background p-2"><option>EUR</option><option>USD</option></select></label>
        <button className="rounded bg-primary px-4 py-2 text-primary-foreground" type="submit">Показать</button>
      </form>
      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {[["Выручка без НДС", formatMoney(report.totals.revenue.value, unit)], ["Операционный результат", formatMoney(report.operatingResult, unit)], ["MRR", formatMoney(report.mrr, unit)], ["Выплачено в банк", formatMoney(report.totals.payout.value, unit)]].map(([title, value]) => <Card key={title}><CardHeader><CardTitle className="text-sm">{title}</CardTitle></CardHeader><CardContent className="text-xl font-semibold">{value}</CardContent></Card>)}
      </section>
      <p className="my-4 text-sm text-muted-foreground">Результат до налогов владельца: выручка − возвраты − комиссии − привлечение − инфраструктура − сопровождение. Без полной сверки всех составляющих результат неизвестен. Неоплаченное время владельца показано отдельно.</p>
      <Card><CardHeader><CardTitle>Показатели за {period} · {unit}</CardTitle></CardHeader><CardContent>
        <div className="overflow-x-auto"><table className="w-full text-left text-sm"><caption className="sr-only">Финансовые показатели и полнота сверки</caption><thead><tr><th className="p-3">Показатель</th><th className="p-3">Итог периода</th><th className="p-3">Наблюдаемая часть</th></tr></thead><tbody>
          {(Object.keys(metricLabels) as Metric[]).map((key) => <tr key={key} className="border-t border-border"><th scope="row" className="p-3 font-medium">{metricLabels[key]}</th><td className="p-3">{valueText(key, report.totals[key].value)}</td><td className="p-3 text-muted-foreground">{report.totals[key].complete ? "Полная сверка" : report.totals[key].observed === null ? "Нет подтверждения" : `${valueText(key, report.totals[key].observed)} · неполная сверка`}</td></tr>)}
        </tbody></table></div>
        <p className="mt-4 text-sm">Активных платящих клиентов: {report.activePayingCustomers ?? "Не измерено"} · CAC: {formatMoney(report.cac, unit)} · тестовых записей исключено: {report.excludedSandboxRows}.</p>
      </CardContent></Card>
      <section className="mt-6 grid gap-4 lg:grid-cols-2"><Card><CardHeader><CardTitle>Подтверждённые наблюдения</CardTitle></CardHeader><CardContent className="space-y-4">{snapshot.observations.map((item) => <div key={item.label}><h3 className="font-medium">{item.label}</h3><p className="text-sm text-muted-foreground">{item.detail}</p><p className="mt-1 break-words text-xs text-muted-foreground">Источник: {item.evidence}</p></div>)}</CardContent></Card>
        <Card><CardHeader><CardTitle>Ошибки и решения</CardTitle></CardHeader><CardContent><ul className="space-y-3 text-sm">{snapshot.decisions.map((item) => <li key={item}>• {item}</li>)}</ul><h3 className="mt-6 font-medium">Выручка по источникам</h3>{report.revenueBySource.length ? report.revenueBySource.map((item) => <p key={item.source} className="text-sm">{item.source}: {formatMoney(item.value, unit)}{report.totals.revenue.complete ? "" : " · неполная сверка"}</p>) : <p className="text-sm text-muted-foreground">Нет сверенных данных по источникам. Разовые пилоты не считаются MRR.</p>}</CardContent></Card></section>
    </>}
  </>;
}
