"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { canManageFeedback, feedbackStatuses, type FeedbackActionResult, type FeedbackStatus } from "@/lib/feedback";

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function updateFeedback(formData: FormData): Promise<FeedbackActionResult> {
  const admin = await requireAdmin();
  if (!canManageFeedback(admin.role)) return { ok: false, message: "Недостаточно прав для обработки обращений." };

  const id = formData.get("id");
  const status = formData.get("status");
  const note = formData.get("resolution_note");
  const expectedUpdatedAt = formData.get("updated_at");
  if (typeof id !== "string" || !uuidPattern.test(id) || typeof status !== "string" || !Object.hasOwn(feedbackStatuses, status) || typeof note !== "string" || note.length > 4000 || typeof expectedUpdatedAt !== "string" || expectedUpdatedAt.length > 64 || !Number.isFinite(Date.parse(expectedUpdatedAt))) {
    return { ok: false, message: "Проверьте статус, комментарий и версию обращения. Изменения не отправлены." };
  }
  const resolutionNote = note.trim() || null;
  if ((status === "resolved" || status === "rejected") && !resolutionNote) {
    return { ok: false, message: "Укажите результат проверки или причину отклонения." };
  }

  const supabase = await createSupabaseServerClient();
  if (!supabase) return { ok: false, message: "Источник обращений недоступен. Черновик сохранён в форме." };
  try {
    // The existing session and RLS remain authoritative. Comparing the exact
    // version prevents one administrator from overwriting another's review.
    const { data, error } = await supabase.from("feedback")
      .update({ status, resolution_note: resolutionNote, resolved_by: status === "resolved" ? admin.id : null })
      .eq("id", id)
      .eq("updated_at", expectedUpdatedAt)
      .select("id,status,resolution_note,resolved_by,updated_at")
      .maybeSingle();
    if (error) return { ok: false, message: "Сохранение не подтверждено. Обновите список и проверьте обращение перед повторной попыткой; черновик оставлен в форме." };
    if (!data) return { ok: false, message: "Обращение изменилось или больше недоступно. Черновик оставлен в форме: скопируйте его и обновите список." };
    if (data.id !== id || data.status !== status || data.resolution_note !== resolutionNote || data.resolved_by !== (status === "resolved" ? admin.id : null) || typeof data.updated_at !== "string" || !Number.isFinite(Date.parse(data.updated_at))) {
      return { ok: false, message: "Ответ источника не подтвердил все изменения. Перечитайте обращение перед повторной попыткой." };
    }
    revalidatePath("/feedback");
    return { ok: true, row: { ...data, status: data.status as FeedbackStatus } };
  } catch {
    return { ok: false, message: "Связь с источником прервалась. Результат сохранения неизвестен; обновите список перед повторной попыткой." };
  }
}
