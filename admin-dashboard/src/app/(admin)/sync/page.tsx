import { Database, ShieldCheck } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { CrudTable } from "@/components/admin/crud-table";
import { SyncRequestPanel } from "@/components/admin/sync-request-panel";
import { Badge } from "@/components/ui/badge";
import { requireAdmin, isLocalDemoAdminEnabled } from "@/lib/auth";
import { canRequestSync } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { buildMobileSyncPayload } from "@/lib/mobile-sync";
import { formatSyncTime } from "@/lib/sync-workflow";

type Row = Record<string, unknown>;
export default async function SyncPage() {
  const admin = await requireAdmin(), runtime = buildMobileSyncPayload();
  const localDemo = admin.id === "demo-admin" && isLocalDemoAdminEnabled();
  let client: Awaited<ReturnType<typeof createSupabaseServerClient>> = null;
  try { client = await createSupabaseServerClient(); } catch { /* Independent data sources remain unknown. */ }
  async function rows(table: string, columns: string, order: string, limit: number) {
    try {
      if (!client) return null;
      const value = await client.from(table).select(columns).order(order, { ascending: false }).limit(limit).abortSignal(AbortSignal.timeout(5000));
      return value.error || !Array.isArray(value.data) ? null : value.data as unknown as Row[];
    } catch { return null; }
  }
  const [datasets, jobs, feed] = await Promise.all([
    rows("content_sync_state", "dataset,version,records,last_sync,status", "last_sync", 50),
    rows("sync_jobs", "id,job,type,target,status,created_at,started_at,completed_at,records_processed,records_failed,artifact_fingerprint,error_summary,duration_ms,details", "created_at", 20),
    rows("public_content_feed", "feed_key,source_version,artifact_fingerprint,record_count,activated_at", "activated_at", 2)
  ]);
  const connected = datasets !== null && jobs !== null;
  const observedAt = new Date().toISOString();
  const active = feed?.find((row) => row.feed_key === "active");
  const feedValid = active && typeof active.artifact_fingerprint === "string" && /^[a-f0-9]{64}$/.test(active.artifact_fingerprint) && typeof active.record_count === "number" && Number.isSafeInteger(active.record_count) && active.record_count > 0 && typeof active.activated_at === "string" && Number.isFinite(Date.parse(active.activated_at));
  const succeeded = jobs?.filter((row) => row.type === "content_artifact_candidate" && row.status === "succeeded" && typeof row.completed_at === "string" && Number.isFinite(Date.parse(row.completed_at))).sort((a,b) => Date.parse(String(b.completed_at))-Date.parse(String(a.completed_at)))[0];
  return <>
    <PageHeader title="Публикация и синхронизация" description="Подготовка кандидата, отдельная ручная активация и сохранённые состояния разных источников." />
    <Card><CardHeader><CardTitle className="flex items-center gap-2"><Database className="size-5" />Ручная подготовка кандидата</CardTitle><CardDescription>Подготовка и активация — отдельные операции. Работающий автоматический синхронизатор по расписанию не подтверждён.</CardDescription></CardHeader>
      <CardContent className="space-y-4 text-sm text-muted-foreground">
        <div className="flex flex-wrap items-center gap-2"><Badge variant={connected ? "success" : localDemo ? "warning" : "destructive"}>{connected ? "административные источники прочитаны" : localDemo ? "локальное демо" : "NOT VERIFIED"}</Badge><span>Чтение · Amsterdam: {formatSyncTime(observedAt)}. Это время наблюдения, не время синхронизации или обновления данных.</span></div>
        {localDemo ? <p>Локальное демо: production-состояние не подтверждено, запуск недоступен.</p> : canRequestSync(admin.role) ? <SyncRequestPanel userId={admin.id} disabled={!connected} /> : <p>Запуск доступен только Owner/Admin.</p>}
        <p>Последний сохранённый успешный candidate среди последних 20 задач: {jobs === null ? "неизвестно — журнал недоступен" : succeeded ? formatSyncTime(String(succeeded.completed_at)) : "не найден в этом окне"}. Время: Europe/Amsterdam. Это не подтверждение публикации.</p>
      </CardContent></Card>
    <div className="mt-6 grid gap-6 lg:grid-cols-2">
      <Card><CardHeader><CardTitle>Активированный web feed</CardTitle><CardDescription>Отдельная запись public_content_feed, доступная через /api/public/content-sync; доставка в публичный сайт проверяется отдельно.</CardDescription></CardHeader><CardContent className="space-y-2 text-sm">
        {feed === null ? <p>Состояние неизвестно: источник недоступен.</p> : !active ? <p>Активная запись не найдена. Это не ошибка подготовки кандидата.</p> : !feedValid ? <p>Состояние неизвестно: метаданные активной записи не прошли проверку.</p> : <><p>Записей: {String(active.record_count)}</p><p>Активация · Amsterdam: {formatSyncTime(String(active.activated_at))}</p><p className="break-all font-mono text-xs">{String(active.artifact_fingerprint)}</p><p className="text-xs text-muted-foreground">Эта запись не доказывает обновление уже открытого сайта или установленного приложения.</p></>}
      </CardContent></Card>
      <Card><CardHeader><CardTitle>Упакованный mobile runtime этой сборки Admin</CardTitle><CardDescription>Независимый набор /api/mobile/sync. Подготовка Supabase candidate не меняет эту сборку или iOS на устройстве.</CardDescription></CardHeader><CardContent className="space-y-2 text-sm">
        <p>Записей: {runtime.entityCount}</p><p>Сформирован: {runtime.generatedAt}</p><p className="break-all font-mono text-xs">{runtime.contentVersion}</p><p className="text-xs">Релизы: {runtime.publishedReleaseIds.join(", ")}</p>
      </CardContent></Card>
    </div>
    <Card className="mt-6"><CardHeader><CardTitle className="flex items-center gap-2"><ShieldCheck className="size-4" />Защита публикации</CardTitle></CardHeader><CardContent className="text-sm text-muted-foreground"><ul className="list-disc space-y-1 pl-5">
      <li>Версионирование и проверка publishability остаются отдельными условиями публикации; подготовка кандидата не заменяет их.</li>
      <li>Candidate собирается только из записей со статусом published; их источники и даты проверки не обновляются этим действием.</li>
      <li>Public content feed API возвращает 503 при недоступном или некорректном активном feed; это не гарантия доступности всех API.</li>
      <li><code>/api/mobile/sync</code> отдаёт упакованный runtime с ETag по dataset fingerprint.</li>
      <li>Откат сборки выполняется развёртыванием ранее проверенной версии; состояние активного feed требует отдельного рассмотрения.</li>
      <li>Live DNS/TLS, rate limiting, журнал production-публикаций и фактический deploy требуют отдельной проверки.</li>
    </ul></CardContent></Card>
    <div className="mt-6 grid min-w-0 grid-cols-1 gap-6">
      {datasets === null ? <Card><CardContent className="p-6">Административные снимки недоступны. Их состояние неизвестно.</CardContent></Card> : <CrudTable title="Сохранённые административные снимки" description="Исторические значения и их даты, а не подтверждение текущей синхронизации. Поле status сохранено источником." rows={datasets} columns={["dataset", "version", "records", "last_sync", "status"]} />}
      {jobs === null ? <Card><CardContent className="p-6">Журнал задач недоступен. Последние попытки и успехи неизвестны.</CardContent></Card> : <CrudTable title="Последние 20 задач" description="queued означает очередь, а не работающий исполнитель. Историческое started_at не доказывает фактический старт. content_publication не обрабатывается ручным candidate-исполнителем." rows={jobs} columns={["id", "job", "type", "target", "status", "records_processed", "records_failed", "artifact_fingerprint", "error_summary", "duration_ms", "created_at", "started_at", "completed_at"]} />}
      <p className="text-xs text-muted-foreground">Старые поля queued_at, heartbeat_at, lease_expires_at, attempt_count и timed_out_at из отдельного canonical lease-предложения не подтверждены текущей схемой sync_jobs. Аренда и попытки нового исполнителя читаются только для выбранного собственного запроса выше; отсутствие этих полей не означает ноль.</p>
    </div>
  </>;
}
