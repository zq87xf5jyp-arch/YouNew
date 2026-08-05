import Link from "next/link";
import { Activity, AppWindow, CheckCircle2, CircleAlert, Database, Download, ShieldCheck } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

const integerFormatter = new Intl.NumberFormat("ru-RU");
const percentFormatter = new Intl.NumberFormat("ru-RU", {
  style: "percent",
  maximumFractionDigits: 1
});

export function AnalyticsPeriodPicker({ days }: { days: 7 | 30 | 90 }) {
  return (
    <nav aria-label="Период аналитики" className="flex rounded-xl border border-border/70 bg-background/45 p-1">
      {([7, 30, 90] as const).map((period) => (
        <Link
          aria-current={days === period ? "page" : undefined}
          className={days === period
            ? "rounded-lg bg-cyan-400/15 px-3 py-2 text-sm font-semibold text-cyan-100"
            : "rounded-lg px-3 py-2 text-sm text-muted-foreground transition hover:bg-white/5 hover:text-foreground"}
          href={`/analytics?days=${period}`}
          key={period}
        >
          {period} дней
        </Link>
      ))}
    </nav>
  );
}

export type AnalyticsBarRow = {
  label: string;
  value: number;
  detail?: string;
};

export function AnalyticsHorizontalBars({
  title,
  description,
  rows,
  valueLabel = "сессий"
}: {
  title: string;
  description: string;
  rows: AnalyticsBarRow[];
  valueLabel?: string;
}) {
  const maximum = Math.max(0, ...rows.map((row) => row.value));
  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
        <CardDescription>{description}</CardDescription>
      </CardHeader>
      <CardContent>
        {maximum > 0 ? (
          <div className="space-y-3">
            {rows.map((row) => (
              <div className="grid gap-1" key={row.label}>
                <div className="flex min-w-0 items-baseline gap-3 text-sm">
                  <span className="min-w-0 flex-1 truncate font-medium" title={row.label}>{row.label}</span>
                  {row.detail ? <span className="text-xs text-muted-foreground">{row.detail}</span> : null}
                  <strong className="tabular-nums">{integerFormatter.format(row.value)} {valueLabel}</strong>
                </div>
                <div className="h-2 overflow-hidden rounded-full bg-white/5">
                  <div
                    className="h-full rounded-full bg-gradient-to-r from-cyan-500 to-blue-400"
                    style={{ width: `${Math.max(2, (row.value / maximum) * 100)}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="flex min-h-40 items-center justify-center rounded-lg border border-dashed text-sm text-muted-foreground">
            Нет подтверждённых данных за выбранный период.
          </div>
        )}
      </CardContent>
    </Card>
  );
}

export function AnalyticsFunnelChart({
  rows
}: {
  rows: Array<{ step: string; label: string; sessions: number; events: number; rateFromVisits: number | null }>;
}) {
  const maximum = Math.max(0, ...rows.map((row) => row.sessions));
  return (
    <Card>
      <CardHeader>
        <CardTitle>Воронка действий</CardTitle>
        <CardDescription>
          Доля рассчитана от сессий с просмотром страницы/экрана. Этапы могут пересекаться и не являются строгой последовательностью.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-3">
        {rows.map((row) => (
          <div className="grid gap-1" key={row.step}>
            <div className="flex items-baseline gap-3 text-sm">
              <span className="flex-1 font-medium">{row.label}</span>
              <span className="text-xs text-muted-foreground">{integerFormatter.format(row.events)} событий</span>
              <strong className="tabular-nums">{integerFormatter.format(row.sessions)} сессий</strong>
              <span className="w-14 text-right text-xs tabular-nums text-cyan-200">
                {row.rateFromVisits === null ? "—" : percentFormatter.format(row.rateFromVisits)}
              </span>
            </div>
            <div className="h-3 overflow-hidden rounded-full bg-white/5">
              <div
                className="h-full rounded-full bg-gradient-to-r from-amber-500 via-orange-400 to-cyan-400"
                style={{ width: `${maximum > 0 && row.sessions > 0 ? Math.max(2, (row.sessions / maximum) * 100) : 0}%` }}
              />
            </div>
          </div>
        ))}
      </CardContent>
    </Card>
  );
}

type SourceStatus = "connected" | "empty" | "missing" | "attention" | "error";

const sourcePresentation: Record<SourceStatus, {
  label: string;
  variant: "success" | "warning" | "destructive";
  icon: typeof CheckCircle2;
}> = {
  connected: { label: "подключён", variant: "success", icon: CheckCircle2 },
  empty: { label: "нет подтверждённых данных", variant: "warning", icon: CircleAlert },
  missing: { label: "не подключён", variant: "warning", icon: CircleAlert },
  attention: { label: "требует внимания", variant: "warning", icon: CircleAlert },
  error: { label: "ошибка", variant: "destructive", icon: CircleAlert }
};

export function AnalyticsSourceMatrix({
  sources
}: {
  sources: Array<{
    id: string;
    title: string;
    detail: string;
    status: SourceStatus;
    kind: "web" | "app-store" | "database" | "quality";
  }>;
}) {
  const sourceIcons = {
    web: AppWindow,
    "app-store": Download,
    database: Database,
    quality: ShieldCheck
  } as const;
  return (
    <Card>
      <CardHeader>
        <CardTitle>Источники и доверие к данным</CardTitle>
        <CardDescription>Пустые метрики означают отсутствие подтверждённого трафика или неподключённый источник, а не технический отказ.</CardDescription>
      </CardHeader>
      <CardContent className="grid gap-3 lg:grid-cols-2">
        {sources.map((source) => {
          const presentation = sourcePresentation[source.status];
          const Icon = sourceIcons[source.kind];
          const StatusIcon = presentation.icon;
          return (
            <div className="rounded-xl border border-border/70 bg-background/35 p-4" key={source.id}>
              <div className="flex items-start gap-3">
                <Icon aria-hidden className="mt-0.5 size-5 text-cyan-200" />
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <h4 className="font-semibold">{source.title}</h4>
                    <Badge variant={presentation.variant}><StatusIcon className="size-3" />{presentation.label}</Badge>
                  </div>
                  <p className="mt-2 text-sm text-muted-foreground">{source.detail}</p>
                </div>
              </div>
            </div>
          );
        })}
      </CardContent>
    </Card>
  );
}

export function AnalyticsMetricGlossary() {
  const definitions = [
    ["Сессия", "Одна анонимная вкладка браузера или сессия приложения. Это не уникальный человек."],
    ["Активный instance", "Случайный идентификатор после согласия на аналитику. На Web живёт в sessionStorage и не отслеживает человека между вкладками."],
    ["Просмотр страницы", "Событие page_view или screen_view для пути без query-параметров."],
    ["Ключевое действие", "Открытие официального источника/результата, сохранение, завершение шага, бизнес-контакт или переход в App Store."],
    ["Переход в App Store", "Клик по CTA на younew.nl. Это намерение загрузить, но не фактическая загрузка."],
    ["Первая загрузка", "Подтверждённая App Store Connect единица первого скачивания; источник должен быть синхронизирован отдельно."],
    ["Вовлечённая сессия", "Сессия длительностью не менее 10 секунд. Порог диагностический, не доказательство ценности."],
    ["Медианная длительность", "Середина распределения длительности сессий. Надёжнее среднего при долго открытых вкладках."],
    ["Ошибка", "Только явные app_error или sync_failed в продуктовой телеметрии; не заменяет crash-monitoring."],
    ["Privacy threshold", "Разрезы по языку, городу и версии показываются только при 3+ сессиях за период."]
  ];
  return (
    <Card>
      <CardHeader>
        <CardTitle>Что означает каждый показатель</CardTitle>
        <CardDescription>Определения предотвращают подмену людей сессиями, кликов загрузками и отсутствия данных нулём.</CardDescription>
      </CardHeader>
      <CardContent>
        <dl className="grid gap-x-8 gap-y-4 md:grid-cols-2">
          {definitions.map(([term, definition]) => (
            <div key={term}>
              <dt className="font-semibold">{term}</dt>
              <dd className="mt-1 text-sm text-muted-foreground">{definition}</dd>
            </div>
          ))}
        </dl>
      </CardContent>
    </Card>
  );
}

export function AnalyticsEmptyValue({ label = "нет данных" }: { label?: string }) {
  return <span className="inline-flex items-center gap-1 text-muted-foreground"><Activity className="size-3" />{label}</span>;
}
