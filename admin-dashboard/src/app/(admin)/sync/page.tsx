import { Database, ShieldCheck } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { CrudTable } from "@/components/admin/crud-table";
import { fetchRowsResult } from "@/lib/data";
import { buildMobileSyncPayload } from "@/lib/mobile-sync";

export default async function SyncPage() {
  const canonicalRuntime = buildMobileSyncPayload();
  const [datasetResult, jobResult] = await Promise.all([
    fetchRowsResult("content_sync_state", []),
    fetchRowsResult("sync_jobs", [], 20, "created_at")
  ]);
  const connected = datasetResult.source === "supabase" && jobResult.source === "supabase";
  const demo = datasetResult.source === "demo" || jobResult.source === "demo";
  const stateLabel = connected ? "подключено" : demo ? "локальное демо" : "NOT VERIFIED";
  return (
    <>
      <PageHeader
        title="Публикация и синхронизация"
        description="Контроль состояния наборов данных и истории публикаций Supabase."
      />
      <Card>
        <CardHeader>
          <div className="flex items-center gap-3">
            <Database className="text-muted-foreground" />
            <div>
              <CardTitle>{connected ? "Supabase административное состояние доступно" : "Состояние Supabase не подтверждено"}</CardTitle>
              <CardDescription>
                {connected
                  ? "Панель прочитала фактическое состояние наборов данных и журнал задач."
                  : demo
                    ? "Показаны только явно включённые локальные демо-данные; это не состояние production."
                    : "Production-подключение или запросы к таблицам не подтверждены. Демо-данные скрыты."}
              </CardDescription>
            </div>
            <Badge className="ml-auto" variant={connected ? "success" : demo ? "warning" : "destructive"}>{stateLabel}</Badge>
          </div>
        </CardHeader>
        <CardContent className="space-y-4 text-sm text-muted-foreground">
          <p>Приложение, публичный сайт и endpoint админки собираются из одного управляемого runtime-артефакта; Supabase хранит административное состояние.</p>
          <dl className="grid gap-3 rounded-md border border-border bg-secondary/30 p-4 text-xs sm:grid-cols-2">
            <div><dt className="font-medium text-foreground">Dataset fingerprint</dt><dd className="mt-1 break-all font-mono">{canonicalRuntime.contentVersion}</dd></div>
            <div><dt className="font-medium text-foreground">Опубликованные записи</dt><dd className="mt-1">{canonicalRuntime.entityCount}</dd></div>
            <div><dt className="font-medium text-foreground">Сформирован</dt><dd className="mt-1">{canonicalRuntime.generatedAt}</dd></div>
            <div><dt className="font-medium text-foreground">Релизы</dt><dd className="mt-1">{canonicalRuntime.publishedReleaseIds.join(", ")}</dd></div>
          </dl>
          <div className="rounded-md border border-border bg-secondary/30 p-4">
            <div className="mb-2 flex items-center gap-2 font-medium text-foreground"><ShieldCheck className="size-4" />Защита публикации</div>
            <ul className="list-disc space-y-1 pl-5">
              <li>версионирование и проверка publishability остаются обязательными;</li>
              <li>в публичный payload попадают только опубликованные записи;</li>
              <li>public API возвращает 503 вместо вымышленных данных при недоступном Supabase;</li>
              <li><code>/api/mobile/sync</code> отдаёт только этот опубликованный runtime с ETag по dataset fingerprint;</li>
              <li>rollback выполняется повторным развёртыванием ранее проверенного immutable release artifact;</li>
              <li>live DNS/TLS, rate limiting, журнал production-публикаций и фактический deploy требуют отдельной проверки.</li>
            </ul>
          </div>
        </CardContent>
      </Card>
      <div className="mt-6 grid gap-6">
        <CrudTable title="Наборы данных" description="Текущее подтверждённое административное состояние." rows={datasetResult.rows} columns={["dataset", "version", "records", "last_sync", "status"]} cta="Обновить состояние" />
        <CrudTable title="История задач" description="Последние подтверждённые операции публикации и проверки." rows={jobResult.rows} columns={["job", "target", "status", "duration_ms", "created_at"]} cta="Новая задача" />
      </div>
    </>
  );
}
