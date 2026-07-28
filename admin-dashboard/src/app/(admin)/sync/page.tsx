import { Database, ShieldCheck } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { CrudTable } from "@/components/admin/crud-table";
import { fetchRowsResult } from "@/lib/data";
import { buildMobileSyncPayload } from "@/lib/mobile-sync";
import { activateContentArtifact, requestContentSync } from "./actions";

type ContentArtifactRow = {
  id: string;
  source_version: string;
  artifact_fingerprint: string;
  record_count: number;
  status: "candidate" | "active" | "superseded" | "rejected";
  created_at: string;
  activated_at: string | null;
};

export default async function SyncPage() {
  const canonicalRuntime = buildMobileSyncPayload();
  const [datasetResult, jobResult, artifactResult] = await Promise.all([
    fetchRowsResult("content_sync_state", []),
    fetchRowsResult("sync_jobs", [], 20, "created_at"),
    fetchRowsResult("published_content_artifacts", [], 20, "created_at")
  ]);
  const connected = datasetResult.source === "supabase"
    && jobResult.source === "supabase"
    && artifactResult.source === "supabase";
  const demo = datasetResult.source === "demo"
    || jobResult.source === "demo"
    || artifactResult.source === "demo";
  const stateLabel = connected ? "подключено" : demo ? "локальное демо" : "NOT VERIFIED";
  const artifacts = artifactResult.rows as ContentArtifactRow[];
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
          <p>Приложение, публичный сайт и API админки используют один проверенный набор опубликованных данных; Supabase хранит административное состояние.</p>
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
              <li><code>/api/public/content-sync</code> отдаёт сайту только вручную активированный непустой Admin-артефакт;</li>
              <li>откат выполняется повторным развёртыванием ранее проверенной версии;</li>
              <li>live DNS/TLS, rate limiting, журнал production-публикаций и фактический deploy требуют отдельной проверки.</li>
            </ul>
          </div>
          <form action={requestContentSync}>
            <Button type="submit" disabled={!connected}>
              Подготовить candidate-артефакт
            </Button>
            <p className="mt-2 text-xs">Команда создаёт и проверяет кандидата для ручного GitHub handoff. Она не активирует production-версию.</p>
          </form>
        </CardContent>
      </Card>
      <Card className="mt-6">
        <CardHeader>
          <CardTitle>Admin updates для публичного сайта</CardTitle>
          <CardDescription>
            Активация публикует отдельную проверенную ленту на странице <code>/updates</code>. Она не перезаписывает канонический DataProject.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {artifacts.length === 0 ? (
            <p className="text-sm text-muted-foreground">Артефакты ещё не подготовлены.</p>
          ) : artifacts.map((artifact) => (
            <article key={artifact.id} className="rounded-md border border-border bg-secondary/30 p-4">
              <div className="flex flex-wrap items-center gap-2">
                <Badge variant={artifact.status === "active" ? "success" : artifact.status === "candidate" ? "warning" : "secondary"}>
                  {artifact.status}
                </Badge>
                <span className="text-sm font-medium">{artifact.record_count} записей</span>
                <span className="ml-auto text-xs text-muted-foreground">{new Date(artifact.created_at).toLocaleString("ru-RU")}</span>
              </div>
              <dl className="mt-3 grid gap-2 text-xs text-muted-foreground sm:grid-cols-2">
                <div><dt>Source version</dt><dd className="break-all font-mono text-foreground">{artifact.source_version}</dd></div>
                <div><dt>Fingerprint</dt><dd className="break-all font-mono text-foreground">{artifact.artifact_fingerprint}</dd></div>
              </dl>
              {artifact.status === "candidate" ? (
                <form action={activateContentArtifact} className="mt-4">
                  <input type="hidden" name="artifactId" value={artifact.id} />
                  <Button type="submit" size="sm" disabled={!connected || artifact.record_count <= 0}>
                    Активировать на сайте
                  </Button>
                  {artifact.record_count <= 0 ? (
                    <p className="mt-2 text-xs text-destructive">Пустой candidate нельзя активировать.</p>
                  ) : (
                    <p className="mt-2 text-xs text-muted-foreground">После активации эта версия станет доступна публичному сайту через защищённый read-only API.</p>
                  )}
                </form>
              ) : null}
            </article>
          ))}
        </CardContent>
      </Card>
      <div className="mt-6 grid gap-6">
        <CrudTable title="Наборы данных" description="Текущее подтверждённое административное состояние." rows={datasetResult.rows} columns={["dataset", "version", "records", "last_sync", "status"]} cta="Обновить состояние" />
        <CrudTable title="История задач" description="Последние подтверждённые операции публикации и проверки." rows={jobResult.rows} columns={["job", "target", "status", "records_processed", "records_failed", "artifact_fingerprint", "error_summary", "duration_ms", "created_at"]} />
      </div>
    </>
  );
}
