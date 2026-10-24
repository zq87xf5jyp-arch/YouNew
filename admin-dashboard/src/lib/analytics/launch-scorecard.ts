export type LaunchMetricStatus = "measured" | "measured-zero" | "unavailable";

export type LaunchMetric = {
  id:
    | "organic_visitors"
    | "company_page_views"
    | "repeat_visits"
    | "applications_started"
    | "applications_saved"
    | "registered_companies"
    | "confirmed_partners"
    | "actual_revenue";
  label: string;
  value: number | null;
  unit: "count" | "eur";
  status: LaunchMetricStatus;
  evidence: string;
};

type EventRow = { event_name: string; event_count: number | string | null };
type PageRow = { screen: string; page_views: number | string | null };

function count(value: number | string | null | undefined) {
  const parsed = Number(value ?? 0);
  return Number.isFinite(parsed) && parsed > 0 ? Math.trunc(parsed) : 0;
}

function observedMetric(
  metric: Omit<LaunchMetric, "status">,
  available: boolean
): LaunchMetric {
  if (!available) return { ...metric, value: null, status: "unavailable" };
  return { ...metric, status: metric.value === 0 ? "measured-zero" : "measured" };
}

export function buildLaunchScorecard({
  analyticsAvailable,
  eventRows,
  pageRows,
  businessStoreAvailable,
  savedApplications
}: {
  analyticsAvailable: boolean;
  eventRows: EventRow[];
  pageRows: PageRow[];
  businessStoreAvailable: boolean;
  savedApplications: number | null;
}): LaunchMetric[] {
  const eventCount = (name: string) => eventRows
    .filter((row) => row.event_name === name)
    .reduce((sum, row) => sum + count(row.event_count), 0);
  const companyPageViews = pageRows
    .filter((row) => /^\/(?:organizations|nl\/organisaties)\/[^/]+\/?$/.test(row.screen))
    .reduce((sum, row) => sum + count(row.page_views), 0);

  return [
    {
      id: "organic_visitors",
      label: "Органические посетители",
      value: null,
      unit: "count",
      status: "unavailable",
      evidence: "Search Console ещё не подключён; page views нельзя выдавать за organic traffic."
    },
    observedMetric({
      id: "company_page_views",
      label: "Просмотры карточек компаний",
      value: companyPageViews,
      unit: "count",
      evidence: "Consented page_view для EN /organizations/:slug и NL /nl/organisaties/:slug."
    }, analyticsAvailable),
    {
      id: "repeat_visits",
      label: "Повторные посещения",
      value: null,
      unit: "count",
      status: "unavailable",
      evidence: "Текущие агрегаты не считают экземпляры с двумя и более сессиями; оценка не подменяется вычитанием."
    },
    observedMetric({
      id: "applications_started",
      label: "Начатые заявки",
      value: eventCount("lead_start"),
      unit: "count",
      evidence: "Consented lead_start; без полей формы и контактных данных."
    }, analyticsAvailable),
    observedMetric({
      id: "applications_saved",
      label: "Сохранённые заявки",
      value: businessStoreAvailable ? count(savedApplications) : null,
      unit: "count",
      evidence: "Фактические строки business_inquiries, созданные в выбранном периоде."
    }, businessStoreAvailable),
    {
      id: "registered_companies",
      label: "Зарегистрированные компании",
      value: null,
      unit: "count",
      status: "unavailable",
      evidence: "Сохранённая заявка не равна регистрации; отдельный подтверждённый activation state ещё не развёрнут."
    },
    {
      id: "confirmed_partners",
      label: "Подтверждённые партнёры",
      value: null,
      unit: "count",
      status: "unavailable",
      evidence: "Research tracker не является production-источником факта партнёрства."
    },
    {
      id: "actual_revenue",
      label: "Фактическая выручка",
      value: null,
      unit: "eur",
      status: "unavailable",
      evidence: "Подключённого ledger/payment-источника нет; интерес и won-статус не считаются выручкой."
    }
  ];
}
