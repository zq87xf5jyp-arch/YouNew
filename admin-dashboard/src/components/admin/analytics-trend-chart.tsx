import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import type { AnalyticsTrendPoint } from "@/lib/analytics/dashboard";

const width = 760;
const height = 250;
const padding = 30;

function polyline(
  points: AnalyticsTrendPoint[],
  value: (point: AnalyticsTrendPoint) => number,
  maximum: number
) {
  if (points.length < 2 || maximum <= 0) return "";
  const drawableWidth = width - padding * 2;
  const drawableHeight = height - padding * 2;
  return points.map((point, index) => {
    const x = padding + (index / (points.length - 1)) * drawableWidth;
    const y = height - padding - (value(point) / maximum) * drawableHeight;
    return `${x.toFixed(1)},${y.toFixed(1)}`;
  }).join(" ");
}

export function AnalyticsTrendChart({ points, days }: { points: AnalyticsTrendPoint[]; days: number }) {
  const maximum = Math.max(0, ...points.flatMap((point) => [point.events, point.sessions, point.keyActions, point.errors]));
  const eventPoints = polyline(points, (point) => point.events, maximum);
  const sessionPoints = polyline(points, (point) => point.sessions, maximum);
  const keyActionPoints = polyline(points, (point) => point.keyActions, maximum);
  const errorPoints = polyline(points, (point) => point.errors, maximum);
  const hasData = maximum > 0;

  return (
    <Card>
      <CardHeader>
        <CardTitle>Посещаемость и активность за {days} дней</CardTitle>
        <CardDescription>
          Сессии — анонимные посещения вкладки, а не уникальные люди. Дни и границы периода рассчитаны в UTC.
        </CardDescription>
      </CardHeader>
      <CardContent>
        {hasData ? (
          <>
            <svg
              role="img"
              aria-labelledby="analytics-trend-title analytics-trend-description"
              className="h-auto w-full"
              viewBox={`0 0 ${width} ${height}`}
            >
              <title id="analytics-trend-title">События и сессии по дням</title>
              <desc id="analytics-trend-description">
                Линии показывают количество событий, анонимных сессий, ключевых действий и ошибок для каждого дня выбранного периода.
              </desc>
              {[0, 0.25, 0.5, 0.75, 1].map((ratio) => {
                const y = height - padding - ratio * (height - padding * 2);
                return (
                  <g key={ratio}>
                    <line x1={padding} x2={width - padding} y1={y} y2={y} stroke="hsl(var(--border))" strokeWidth="1" />
                    <text x="4" y={y + 4} fill="hsl(var(--muted-foreground))" fontSize="11">
                      {Math.round(maximum * ratio)}
                    </text>
                  </g>
                );
              })}
              <polyline points={eventPoints} fill="none" stroke="#22d3ee" strokeWidth="3" strokeLinejoin="round" />
              <polyline points={sessionPoints} fill="none" stroke="#f59e0b" strokeWidth="3" strokeLinejoin="round" />
              <polyline points={keyActionPoints} fill="none" stroke="#22c55e" strokeWidth="2.5" strokeLinejoin="round" />
              <polyline points={errorPoints} fill="none" stroke="#ef4444" strokeWidth="2.5" strokeLinejoin="round" />
            </svg>
            <div className="mt-3 flex flex-wrap gap-4 text-xs text-muted-foreground">
              <span className="flex items-center gap-2"><span className="size-2.5 rounded-full bg-cyan-400" />События</span>
              <span className="flex items-center gap-2"><span className="size-2.5 rounded-full bg-amber-500" />Сессии</span>
              <span className="flex items-center gap-2"><span className="size-2.5 rounded-full bg-green-500" />Ключевые действия</span>
              <span className="flex items-center gap-2"><span className="size-2.5 rounded-full bg-red-500" />Ошибки</span>
              <span className="ml-auto">{points[0]?.date} — {points.at(-1)?.date}</span>
            </div>
          </>
        ) : (
          <div className="flex min-h-48 items-center justify-center rounded-lg border border-dashed text-sm text-muted-foreground">
            За выбранный период подтверждённых production-событий нет.
          </div>
        )}
      </CardContent>
    </Card>
  );
}
