import { PageHeader } from "@/components/admin/page-header";
import { ReadOnlySource } from "@/components/admin/read-only-source";
import { CrudTable } from "@/components/admin/crud-table";
import { BugManager } from "@/components/admin/bug-manager";
import { requireAdmin, isLocalDemoAdminEnabled } from "@/lib/auth";
import { sampleBugs } from "@/lib/data";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { bugColumns, bugReadErrorState, canManageBugs, validBugRow, type BugRow } from "@/lib/bugs";

export const dynamic = "force-dynamic";
export const revalidate = 0;

export default async function BugsPage() {
  const admin = await requireAdmin();
  const allowed = canManageBugs(admin.role);
  let rows: BugRow[] = [], state: "data" | "empty" | "forbidden" | "unavailable" | "demo" = allowed ? "unavailable" : "forbidden";
  if (allowed) {
    try {
      const supabase = await createSupabaseServerClient();
      if (supabase) {
        const result = await supabase.from("bugs").select(bugColumns).order("updated_at", { ascending: false }).order("id", { ascending: true }).limit(100).abortSignal(AbortSignal.timeout(8000));
        if (result.error) state = bugReadErrorState(result.error);
        else if (Array.isArray(result.data) && result.data.every(validBugRow)) { rows = result.data; state = rows.length ? "data" : "empty"; }
      }
    } catch { /* A failed source does not establish an empty queue. */ }
    if (state === "unavailable" && isLocalDemoAdminEnabled()) state = "demo";
  }
  const available = state === "data" || state === "empty";
  const label = available ? "Supabase bugs" : state === "demo" ? "explicit local demo" : state === "forbidden" ? "Supabase forbidden" : "Supabase unavailable";
  const detail = state === "data" ? `Прочитано ${rows.length} записей из авторизованной выборки до 100.` : state === "empty" ? "Авторизованный запрос выполнен: в выборке нет записей. Это не подтверждает отсутствие ошибок продукта." : state === "forbidden" ? "Доступ к очереди ошибок разрешён только Owner/Admin/QA; данные и количество не раскрываются." : state === "demo" ? "Синтетические строки только для просмотра; это не данные рабочего сервиса." : "Источник недоступен; количество и статусы неизвестны.";
  return <>
    <PageHeader title="Трекер ошибок" description="Создание, редактирование, шаги воспроизведения и ручной статус ошибки. Изменения доступны Owner/Admin/QA." />
    <ReadOnlySource state={state} label={label} detail={detail} />
    {state === "demo" ? <CrudTable title="Локальная демонстрация" description="Только просмотр синтетических ошибок; сохранение отключено." rows={sampleBugs} columns={["title", "severity", "priority", "status", "platform", "app_screen"]} /> : allowed && state !== "forbidden" ? <BugManager rows={rows} available={available} userId={admin.id} /> : null}
  </>;
}
