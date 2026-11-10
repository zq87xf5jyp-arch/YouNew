import { randomUUID } from "node:crypto";
import { VisualQAManager } from "@/components/admin/visual-qa-manager";
import { requireAdmin } from "@/lib/auth";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { canReviewScreenshots, SCREENSHOT_PREVIEW_SECONDS, screenshotColumns, validScreenshotPath, type ScreenshotRow, type ScreenshotView } from "@/lib/visual-qa";

export const dynamic = "force-dynamic";
export const revalidate = 0;

async function bounded<T>(operation: PromiseLike<T>): Promise<T> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try { return await Promise.race([Promise.resolve(operation), new Promise<never>((_resolve, reject) => { timer = setTimeout(() => reject(new Error("read_timeout")), 8000); })]); }
  finally { clearTimeout(timer); }
}
import { CheckCircle2, CircleSlash2 } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { ReadOnlySource } from "@/components/admin/read-only-source";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

const manualChecks = [
  "Точный H1 и активная навигация",
  "Desktop 1440×900 и mobile 390×844",
  "Ограничения Owner, Editor, QA и Viewer",
  "Focus states, контраст и отсутствие перекрытий",
  "Отсутствие горизонтального scroll",
  "Каждый видимый control имеет подтверждённый результат"
];

export default async function VisualQAPage() {
  const admin = await requireAdmin();
  if (!canReviewScreenshots(admin.role)) return <PageHeader title="Проверка интерфейса" description="Доступ только владельцу, администратору и QA." />;
  const supabase = await createSupabaseServerClient();
  let available = false;
  let rows: ScreenshotView[] = [];
  if (supabase) { try {
    const result = await bounded(supabase.from("screenshots").select(screenshotColumns).order("created_at", { ascending: false }).limit(20));
    if (!result.error && Array.isArray(result.data)) {
      available = true;
      const source = result.data as ScreenshotRow[];
      rows = source.map(row => ({ ...row, previewUrl: null }));
      const paths = source.filter(validScreenshotPath).map(row => row.file_path);
      if (paths.length) { try {
        const signed = await bounded(supabase.storage.from("screenshots").createSignedUrls(paths, SCREENSHOT_PREVIEW_SECONDS));
        rows = rows.map(row => ({ ...row, previewUrl: signed.data?.find(item => item.path === row.file_path && !item.error)?.signedUrl ?? null }));
      } catch { /* Database rows remain known even when private previews are unavailable. */ } }
    }
  } catch { available = false; rows = []; } }

  return (
    <>
      <PageHeader
        title="Проверка интерфейса"
        description="Приватные скриншоты и ручные результаты сохраняются в существующем каталоге. Ни загрузка, ни ручная оценка не подтверждают прохождение изолированного E2E."
      />
    <VisualQAManager key={admin.id} rows={rows} available={available} requestId={randomUUID()} draftKey={`younew-visual-qa-draft-v1:${admin.id}`} />
      <ReadOnlySource
        state="unknown"
        label="isolated Playwright artifacts"
        detail="В текущем runtime нет подтверждённого CI artifact. Отсутствие evidence не отображается как успешная проверка."
      />
      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><CircleSlash2 className="size-4 text-amber-200" />Изолированная автоматическая проверка</CardTitle>
            <CardDescription>Приватный ручной журнал ниже не заменяет изолированный Playwright workflow или автоматический анализ.</CardDescription>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground">
            Скриншоты и отчёт появляются только после реального isolated E2E run. До этого состояние остаётся unknown.
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Обязательная матрица проверки</CardTitle>
            <CardDescription>Контракт pre-production visual validation.</CardDescription>
          </CardHeader>
          <CardContent>
            <ul className="space-y-3 text-sm">
              {manualChecks.map((item) => (
                <li className="flex items-start gap-2" key={item}>
                  <CheckCircle2 className="mt-0.5 size-4 shrink-0 text-cyan-200" aria-hidden="true" />
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      </div>
    </>
  );
}
