"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireAdmin } from "@/lib/auth";
import { canManageBusinessInquiries } from "@/lib/authorization";
import {
  isBusinessInquiryLostReason,
  isBusinessInquiryOfferInterest,
  isBusinessInquiryStatus,
  isBusinessInquiryWonEvidenceType
} from "@/lib/business-inquiry-pipeline";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const isoDatePattern = /^\d{4}-\d{2}-\d{2}$/;

function validEvidenceDate(value: string) {
  if (!isoDatePattern.test(value) || value > new Date().toISOString().slice(0, 10)) return false;
  const parsed = new Date(`${value}T00:00:00.000Z`);
  return !Number.isNaN(parsed.valueOf()) && parsed.toISOString().slice(0, 10) === value;
}

export async function updateBusinessInquiry(formData: FormData) {
  const admin = await requireAdmin();
  if (!canManageBusinessInquiries(admin.role)) throw new Error("Недостаточно прав.");
  const id = String(formData.get("id") ?? "");
  const status = String(formData.get("status") ?? "");
  const contactRole = String(formData.get("contactRole") ?? "").trim();
  const offerInterest = String(formData.get("offerInterest") ?? "");
  const lostReason = String(formData.get("lostReason") ?? "");
  const lostReasonDetail = String(formData.get("lostReasonDetail") ?? "").trim();
  const wonEvidenceType = String(formData.get("wonEvidenceType") ?? "");
  const wonEvidenceDate = String(formData.get("wonEvidenceDate") ?? "");
  const internalNote = String(formData.get("internalNote") ?? "").trim();
  const contactRoleInvalid = contactRole.length > 120 || (contactRole.length > 0 && contactRole.length < 2);
  const lostReasonInvalid = status === "lost" && !isBusinessInquiryLostReason(lostReason);
  const lostReasonDetailInvalid = status === "lost" && (
    (lostReasonDetail.length > 0 && lostReasonDetail.length < 5)
    || lostReasonDetail.length > 500
    || (lostReason === "other_explicit" && lostReasonDetail.length === 0)
  );
  const wonEvidenceInvalid = status === "won" && (
    !isBusinessInquiryWonEvidenceType(wonEvidenceType)
    || !validEvidenceDate(wonEvidenceDate)
  );
  if (
    !uuidPattern.test(id)
    || !isBusinessInquiryStatus(status)
    || !isBusinessInquiryOfferInterest(offerInterest)
    || contactRoleInvalid
    || lostReasonInvalid
    || lostReasonDetailInvalid
    || wonEvidenceInvalid
    || internalNote.length > 2000
  ) {
    throw new Error("Некорректные данные заявки.");
  }

  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");
  const { error } = await supabase
    .from("business_inquiries")
    .update({
      status,
      contact_role: contactRole || null,
      offer_interest: offerInterest,
      lost_reason: status === "lost" ? lostReason : null,
      lost_reason_detail: status === "lost" ? lostReasonDetail || null : null,
      won_evidence_type: status === "won" ? wonEvidenceType : null,
      won_evidence_at: status === "won" ? `${wonEvidenceDate}T00:00:00.000Z` : null,
      admin_notes: internalNote || null,
      handled_by: admin.id
    })
    .eq("id", id);
  if (error) throw new Error("Не удалось обновить заявку.");

  revalidatePath("/business-inquiries");
  revalidatePath(`/business-inquiries/${id}`);
  redirect(`/business-inquiries/${id}?saved=1`);
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
  const { error } = await supabase
    .from("business_inquiry_notifications")
    .update({ status })
    .eq("id", id);
  if (error) throw new Error("Не удалось обновить внутреннее уведомление.");

  revalidatePath("/business-inquiries");
}
