"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { canManageBusinessInquiries } from "@/lib/authorization";
import { CURRENT_INQUIRY_SCHEMA, CURRENT_INQUIRY_CONTRACT, parseInquiryUpdate, verifyInquiryUpdate, type InquiryActionResult } from "@/lib/business-inquiry-compatibility";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export async function updateBusinessInquiry(formData: FormData): Promise<InquiryActionResult> {
  const admin = await requireAdmin();
  if (!canManageBusinessInquiries(admin.role)) return { ok: false, message: "Недостаточно прав для обработки заявки." };
  const parsed = parseInquiryUpdate(formData, CURRENT_INQUIRY_SCHEMA);
  if (!parsed) return { ok: false, message: "Проверьте поддерживаемый статус, поля, заметку (до 2000 символов) и версию заявки. Изменения не отправлены." };
  const supabase = await createSupabaseServerClient();
  if (!supabase) return { ok: false, message: "Источник заявок недоступен. Черновик оставлен в форме." };
  try {
    const { data: updated, error } = await supabase.from("business_inquiries")
      .update({ ...parsed.values, handled_by: admin.id })
      .eq("id", parsed.id)
      .eq("updated_at", parsed.version)
      .select(CURRENT_INQUIRY_CONTRACT.updateSelect)
      .maybeSingle();
    if (error || !updated) return { ok: false, message: "Обновление не подтверждено: заявка могла измениться или стать недоступной. Скопируйте черновик и перечитайте заявку." };
    const row = verifyInquiryUpdate(updated, parsed, admin.id);
    if (!row) return { ok: false, message: "Ответ источника не подтвердил все изменения. Скопируйте черновик и перечитайте заявку." };
    revalidatePath("/business-inquiries");
    revalidatePath(`/business-inquiries/${parsed.id}`);
    return { ok: true, row };
  } catch {
    return { ok: false, message: "Связь с источником прервалась. Результат сохранения неизвестен; черновик оставлен в форме. Перечитайте заявку перед повторной попыткой." };
  }
}

export async function updateBusinessInquiryNotification(formData: FormData) {
  const admin = await requireAdmin();
  if (!canManageBusinessInquiries(admin.role)) throw new Error("Недостаточно прав.");

  const id = String(formData.get("id") ?? "");
  const status = String(formData.get("status") ?? "");
  if (!uuidPattern.test(id) || (status !== "read" && status !== "archived")) {
    throw new Error("Некорректные данные уведомления.");
  }

  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");
  const { data: updated, error } = await supabase
    .from("business_inquiry_notifications")
    .update({ status })
    .eq("id", id)
    .select("id")
    .maybeSingle();
  if (error || !updated) throw new Error("Не удалось подтвердить обновление внутреннего уведомления.");

  revalidatePath("/business-inquiries");
}
