"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { checkStoredOfficialLink } from "@/lib/official-link-check";
import { canCheckOfficialLink, validLinkVersion, officialLinkStatus, MAX_LINK_NOTES_LENGTH, MAX_EXISTING_LINK_NOTES_LENGTH, type OfficialLinkActionResult, type OfficialLinkRow } from "@/lib/official-link-workflow";

const columns = "id,title,url,source_type,status,last_checked_date,notes,updated_at";
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function verifyOfficialLink(form: FormData): Promise<OfficialLinkActionResult> {
  const admin = await requireAdmin();
  if (!canCheckOfficialLink(admin.role)) return { ok: false, message: "Проверка и сохранение доступны только владельцу и администратору." };
  const id = form.get("id"), expectedURL = form.get("url"), version = form.get("updated_at");
  if (typeof id !== "string" || !uuid.test(id) || typeof expectedURL !== "string" || expectedURL.length > 2048 || !validLinkVersion(version)) {
    return { ok: false, message: "Некорректная ссылка или версия записи. Обновите каталог." };
  }
  const supabase = await createSupabaseServerClient();
  if (!supabase) return { ok: false, message: "Каталог недоступен. Проверка не запущена." };
  try {
    const current = await supabase.from("official_links").select(columns).eq("id", id).maybeSingle();
    if (current.error || !current.data) return { ok: false, message: "Запись недоступна. Проверка не запущена." };
    const row = current.data as OfficialLinkRow;
    if (row.id !== id || row.url !== expectedURL || row.updated_at !== version) return { ok: false, message: "Ссылка изменилась. Обновите каталог перед проверкой." };
    if (row.notes !== null && (typeof row.notes !== "string" || row.notes.length > MAX_EXISTING_LINK_NOTES_LENGTH)) {
      return { ok: false, message: "Журнал заметок достиг безопасного размера. Проверка не запущена; существующие заметки сохранены." };
    }
    // Probe only the RLS-readable stored URL, never a new URL supplied by a client.
    const check = await checkStoredOfficialLink(row.url);
    const status = officialLinkStatus(check);
    const date = check.checkedAt.slice(0, 10);
    const observation = JSON.stringify({ kind: "http_observation_not_content_verification", checkedBy: admin.id, ...check });
    const notes = `${row.notes ?? ""}${row.notes ? "\n\n" : ""}[YouNew HTTP check]\n${observation}\n[/YouNew HTTP check]`;
    if (notes.length > MAX_LINK_NOTES_LENGTH) return { ok: false, message: "HTTP-проверка выполнена, но результат не сохранён: заметки превышают безопасный размер." };
    const saved = await supabase.from("official_links").update({ status, last_checked_date: date, notes })
      .eq("id", id).eq("url", row.url).eq("updated_at", version).select(columns).maybeSingle();
    if (saved.error || !saved.data) return { ok: false, message: "Сохранение результата не подтверждено: запись могла измениться. Обновите каталог перед повтором." };
    if (saved.data.id !== id || saved.data.url !== row.url || saved.data.status !== status || saved.data.last_checked_date !== date || saved.data.notes !== notes || !validLinkVersion(saved.data.updated_at) || saved.data.updated_at === version) {
      return { ok: false, message: "Ответ источника не подтвердил результат. Перечитайте каталог перед повтором." };
    }
    revalidatePath("/links");
    return { ok: true, row: saved.data as OfficialLinkRow, check };
  } catch {
    return { ok: false, message: "Связь с каталогом прервалась. Сохранение неизвестно; обновите список перед повтором." };
  }
}
