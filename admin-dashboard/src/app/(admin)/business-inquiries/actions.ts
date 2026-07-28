"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const inquiryStatuses = new Set([
  "new",
  "reviewing",
  "responded",
  "accepted",
  "declined",
  "test",
  "archived"
]);
const uuidPattern =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export async function updateBusinessInquiry(formData: FormData) {
  const admin = await requireAdmin();
  if (admin.role !== "owner" && admin.role !== "admin") {
    throw new Error("Недостаточно прав для изменения бизнес-заявки.");
  }

  const id = String(formData.get("id") ?? "");
  const status = String(formData.get("status") ?? "");
  const adminNotes = String(formData.get("adminNotes") ?? "").trim();
  if (!uuidPattern.test(id)) throw new Error("Некорректный идентификатор заявки.");
  if (!inquiryStatuses.has(status)) throw new Error("Некорректный статус заявки.");
  if (adminNotes.length > 2000) throw new Error("Заметка не должна превышать 2000 символов.");

  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");

  const { data, error } = await supabase
    .from("business_inquiries")
    .update({ status, admin_notes: adminNotes || null })
    .eq("id", id)
    .select("id")
    .maybeSingle();

  if (error || !data) {
    throw new Error("Не удалось обновить бизнес-заявку.");
  }
  revalidatePath("/business-inquiries");
}
