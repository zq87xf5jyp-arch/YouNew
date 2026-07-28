"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireAdmin } from "@/lib/auth";
import { canManageBusinessInquiries } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const statuses = new Set(["new", "contacted", "qualified", "closed", "rejected", "spam"]);
const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export async function updateBusinessInquiry(formData: FormData) {
  const admin = await requireAdmin();
  if (!canManageBusinessInquiries(admin.role)) throw new Error("Недостаточно прав.");
  const id = String(formData.get("id") ?? "");
  const status = String(formData.get("status") ?? "");
  const internalNote = String(formData.get("internalNote") ?? "").trim();
  if (!uuidPattern.test(id) || !statuses.has(status) || internalNote.length > 4000) {
    throw new Error("Некорректные данные заявки.");
  }

  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");
  const { error } = await supabase
    .from("business_inquiries")
    .update({
      status,
      internal_note: internalNote || null,
      handled_by: admin.id
    })
    .eq("id", id);
  if (error) throw new Error("Не удалось обновить заявку.");

  revalidatePath("/business-inquiries");
  revalidatePath(`/business-inquiries/${id}`);
  redirect(`/business-inquiries/${id}?saved=1`);
}
