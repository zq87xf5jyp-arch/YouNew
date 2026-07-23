import { Activity, Database, ShieldCheck, Users } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { StatCard } from "@/components/admin/stat-card";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { createSupabaseServerClient } from "@/lib/supabase/server";

type EventRow = { event_name: string; screen: string | null; platform: string; occurred_at: string };

export default async function AnalyticsPage() {
  const supabase = await createSupabaseServerClient();
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const [eventsResult, sessionsResult] = supabase
    ? await Promise.all([
        supabase.from("app_events").select("event_name,screen,platform,occurred_at").gte("occurred_at", since).order("occurred_at", { ascending: false }).limit(100),
        supabase.from("app_sessions").select("session_id", { count: "exact", head: true }).gte("started_at", since)
      ])
    : [{ data: null, error: new Error("not configured") }, { count: 0, error: new Error("not configured") }];

  const events = (eventsResult.data ?? []) as EventRow[];
  const eventCounts = Object.entries(events.reduce<Record<string, number>>((counts, event) => {
    counts[event.event_name] = (counts[event.event_name] ?? 0) + 1;
    return counts;
  }, {})).map(([event_name, count]) => ({ event_name, count }));
  const connected = Boolean(supabase) && !eventsResult.error && !sessionsResult.error;

  return (
    <>
      <PageHeader title="Аналитика" description="Privacy-friendly события из Supabase без рекламных идентификаторов и выдуманных показателей." />
      <section className="grid gap-4 md:grid-cols-3">
        <StatCard label="События за 24 часа" value={events.length} note="Последние 100 событий" icon={Activity} tone="info" />
        <StatCard label="Сессии за 24 часа" value={sessionsResult.count ?? 0} note="Агрегированное количество" icon={Users} tone="success" />
        <StatCard label="Типы событий" value={eventCounts.length} note="Без содержимого свободных полей" icon={Database} />
      </section>
      <div className="mt-6 grid gap-6">
        <Card>
          <CardHeader className="flex-row items-center gap-3">
            <ShieldCheck className="text-cyan-200" />
            <div><CardTitle>Состояние сбора</CardTitle><CardDescription>Данные читаются только одобренными администраторами согласно RLS.</CardDescription></div>
            <Badge className="ml-auto" variant={connected ? "success" : "warning"}>{connected ? "подключено" : "нет данных"}</Badge>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground">Свободные поисковые запросы и чувствительные пользовательские данные в панели не отображаются.</CardContent>
        </Card>
        <CrudTable title="События" description="Агрегирование за последние 24 часа." rows={eventCounts} columns={["event_name", "count"]} cta="Экспорт CSV" />
        <CrudTable title="Последние события" description="До 100 последних записей." rows={events} columns={["event_name", "screen", "platform", "occurred_at"]} cta="Обновить" />
      </div>
    </>
  );
}
