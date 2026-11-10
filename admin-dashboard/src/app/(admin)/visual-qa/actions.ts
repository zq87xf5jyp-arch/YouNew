"use server";

import { createHash } from "node:crypto";
import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { canReviewScreenshots, isReviewId, isReviewVersion, screenshotColumns, screenshotKind, SCREENSHOT_MAX_BYTES, validScreenshotPath, visualStatuses, type ScreenshotRow, type VisualQAResult } from "@/lib/visual-qa";

const text = (form: FormData, key: string) => typeof form.get(key) === "string" ? String(form.get(key)).trim() : "";
const digest = (bytes: Uint8Array) => createHash("sha256").update(bytes).digest("hex");
async function bounded<T>(operation: PromiseLike<T>, milliseconds = 10000): Promise<T> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  try { return await Promise.race([Promise.resolve(operation), new Promise<never>((_resolve, reject) => { timer = setTimeout(() => reject(new Error("operation_timeout_unknown")), milliseconds); })]); }
  finally { clearTimeout(timer); }
}

export async function createScreenshotReview(form: FormData): Promise<VisualQAResult> {
  const admin = await requireAdmin();
  if (!canReviewScreenshots(admin.role)) return { ok: false, message: "Загрузка доступна только владельцу, администратору и QA." };
  const id = text(form, "id"), screen = text(form, "screen_type"), platform = text(form, "platform"), device = text(form, "device"), notes = text(form, "notes"), file = form.get("file");
  if (!isReviewId(id) || !screen || screen.length > 120 || !["iOS", "Android", "Web"].includes(platform) || !["iPhone", "Android", "Tablet", "Desktop"].includes(device) || notes.length > 4000) return { ok: false, message: "Проверьте экран, платформу, устройство и заметки (до 4000 символов)." };
  if (!(file instanceof File) || file.size > SCREENSHOT_MAX_BYTES || file.size === 0) return { ok: false, message: "Выберите PNG или JPEG до 512 КБ." };
  const bytes = new Uint8Array(await file.arrayBuffer());
  const kind = screenshotKind(bytes, file.type);
  if (!kind) return { ok: false, message: "Содержимое файла не соответствует PNG/JPEG. SVG и HTML не принимаются." };
  const path = `reviews/${admin.id}/${id}.${kind}`;
  const supabase = await createSupabaseServerClient();
  if (!supabase) return { ok: false, message: "Источник недоступен. Файл не загружен." };
  const bucket = supabase.storage.from("screenshots");
  const matches = (row: ScreenshotRow) => row.id === id && row.file_path === path && row.created_by === admin.id && row.screen_type === screen && row.platform === platform && row.device === device && row.notes === (notes || null) && validScreenshotPath(row);
  async function storedBytesState(): Promise<"match" | "different" | "unknown"> {
    const recovered = await bucket.download(path, {}, { signal: AbortSignal.timeout(8000), cache: "no-store" });
    if (recovered.error || !recovered.data) return "unknown";
    return recovered.data.size === bytes.length && digest(new Uint8Array(await recovered.data.arrayBuffer())) === digest(bytes) ? "match" : "different";
  }
  try {
    // Stable client submission id survives retry; never overwrite a prior review or image.
    const existing = await bounded(supabase.from("screenshots").select(screenshotColumns).eq("id", id).maybeSingle());
    if (existing.error) return { ok: false, message: "Не удалось проверить предыдущий результат. Сохраните файл и повторите с тем же идентификатором." };
    if (existing.data) {
      if (!matches(existing.data as ScreenshotRow)) return { ok: false, message: "Идентификатор уже занят другой версией проверки. Обновите каталог; существующая запись сохранена." };
      const stored = await storedBytesState();
      if (stored === "unknown") return { ok: false, message: "Запись существует, но приватный файл сейчас недоступен: соответствие неизвестно. Повторите с тем же идентификатором и файлом." };
      return stored === "match" ? { ok: true, row: existing.data as ScreenshotRow, message: "Эта проверка уже сохранена. Повторная загрузка не выполнена." }
        : { ok: false, message: "Сохранённый файл отличается. Обновите каталог; существующая запись не заменена." };
    }
    const uploaded = await bounded(bucket.upload(path, bytes, { contentType: file.type, cacheControl: "0", upsert: false }));
    if (uploaded.error) {
      // A lost upload response may still have stored the exact object. Resume only after byte verification.
      if (await storedBytesState() !== "match") {
        return { ok: false, message: "Загрузка не подтверждена. Сохраните файл и повторите с тем же идентификатором; чужой или отличающийся файл не заменён." };
      }
    } else if (uploaded.data?.path !== path) {
      return { ok: false, message: "Хранилище не подтвердило ожидаемый путь. Создание записи остановлено; перечитайте каталог." };
    }
    const payload = { id, file_path: path, expected_file_path: null, screen_type: screen, platform, device, notes: notes || null, visual_status: "needs review", markers: [], created_by: admin.id };
    const inserted = await bounded(supabase.from("screenshots").insert(payload).select(screenshotColumns).single());
    if (!inserted.error && inserted.data && matches(inserted.data as ScreenshotRow) && inserted.data.visual_status === "needs review" && isReviewVersion(inserted.data.updated_at)) {
      revalidatePath("/visual-qa");
      return { ok: true, row: inserted.data as ScreenshotRow, message: "Скриншот и проверка сохранены. Статус: нужна ручная проверка." };
    }
    const reread = await bounded(supabase.from("screenshots").select(screenshotColumns).eq("id", id).maybeSingle());
    if (!reread.error && reread.data && matches(reread.data as ScreenshotRow)) {
      revalidatePath("/visual-qa");
      return { ok: true, row: reread.data as ScreenshotRow, message: "Сохранение подтверждено повторным чтением. Автоматическая визуальная проверка не выполнялась." };
    }
    // No cleanup race with an insert that may still commit. Same-id retry resumes verified bytes.
    return { ok: false, message: "Запись не подтверждена. Приватный файл может остаться без записи; он не удалён. Повторите с тем же идентификатором и файлом или перечитайте каталог." };
  } catch {
    return { ok: false, message: "Связь прервалась; результат неизвестен. Сохраните файл и идентификатор для повтора. Автоматическое удаление не выполнялось." };
  }
}

export async function saveScreenshotReview(form: FormData): Promise<VisualQAResult> {
  const admin = await requireAdmin();
  if (!canReviewScreenshots(admin.role)) return { ok: false, message: "Сохранение доступно только владельцу, администратору и QA." };
  const id = text(form, "id"), version = text(form, "updated_at"), status = text(form, "visual_status"), notes = text(form, "notes");
  if (!isReviewId(id) || !isReviewVersion(version) || !(visualStatuses as readonly string[]).includes(status) || notes.length > 4000 || (status !== "needs review" && !notes)) return { ok: false, message: "Для результата ручной проверки нужна заметка. Проверьте статус, версию и длину заметки." };
  const supabase = await createSupabaseServerClient();
  if (!supabase) return { ok: false, message: "Источник недоступен. Изменения не сохранены." };
  try {
    const current = await bounded(supabase.from("screenshots").select(screenshotColumns).eq("id", id).maybeSingle());
    if (current.error || !current.data || current.data.updated_at !== version || !validScreenshotPath(current.data as ScreenshotRow)) return { ok: false, message: "Запись недоступна или изменилась. Обновите каталог; черновик не сохранён." };
    const updated = await bounded(supabase.from("screenshots").update({ notes: notes || null, visual_status: status }).eq("id", id).eq("updated_at", version).eq("file_path", current.data.file_path).select(screenshotColumns).maybeSingle());
    if (updated.error || !updated.data || updated.data.id !== id || updated.data.file_path !== current.data.file_path || updated.data.notes !== (notes || null) || updated.data.visual_status !== status || !isReviewVersion(updated.data.updated_at) || updated.data.updated_at === version) return { ok: false, message: "Сохранение не подтверждено. Обновите каталог перед повтором; черновик остаётся в форме." };
    revalidatePath("/visual-qa");
    return { ok: true, row: updated.data as ScreenshotRow, message: "Результат ручной проверки сохранён." };
  } catch {
    return { ok: false, message: "Результат сохранения неизвестен. Перечитайте каталог перед повтором." };
  }
}
