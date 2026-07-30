"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import {
  canManageGovernancePolicy,
  canPublishContent,
  canVerifyContent,
  canWorkReviewQueue,
  type AdminRole
} from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";

function requiredText(formData: FormData, key: string, maximum = 1000) {
  const value = String(formData.get(key) ?? "").trim();
  if (!value || value.length > maximum) throw new Error(`Invalid ${key}.`);
  return value;
}

function requiredInteger(formData: FormData, key: string) {
  const value = Number(formData.get(key));
  if (!Number.isSafeInteger(value) || value < 1) throw new Error(`Invalid ${key}.`);
  return value;
}

function optionalUUID(formData: FormData, key: string) {
  const value = String(formData.get(key) ?? "").trim();
  if (!value) return null;
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value)) {
    throw new Error(`Invalid ${key}.`);
  }
  return value;
}

async function governanceClient(
  allowed: (role: AdminRole) => boolean,
  message: string
) {
  const admin = await requireAdmin();
  if (!allowed(admin.role)) throw new Error(message);
  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");
  return { admin, supabase };
}

function rpcError(error: { message: string; details?: string | null } | null) {
  if (error) throw new Error(error.details ? `${error.message}: ${error.details}` : error.message);
}

export async function verifyContentNowAction(formData: FormData) {
  const { supabase } = await governanceClient(
    canVerifyContent,
    "Verification доступна только Owner, Admin или QA."
  );
  const { error } = await supabase.rpc("verify_content_now", {
    p_record_key: requiredText(formData, "recordKey", 240),
    p_expected_version: requiredInteger(formData, "expectedVersion"),
    p_idempotency_key: requiredText(formData, "idempotencyKey", 200),
    p_change_notes: requiredText(formData, "reason", 1000)
  });
  rpcError(error);
  revalidatePath("/trust");
}

export async function approveContentPublicationAction(formData: FormData) {
  const { supabase } = await governanceClient(
    canPublishContent,
    "Publication approval доступен только Owner или Admin."
  );
  const { error } = await supabase.rpc("approve_content_publication", {
    p_record_key: requiredText(formData, "recordKey", 240),
    p_expected_version: requiredInteger(formData, "expectedVersion"),
    p_idempotency_key: requiredText(formData, "idempotencyKey", 200),
    p_reason: requiredText(formData, "reason", 1000)
  });
  rpcError(error);
  revalidatePath("/trust");
}

export async function transitionReviewTaskAction(formData: FormData) {
  const { admin, supabase } = await governanceClient(
    canWorkReviewQueue,
    "Review Queue недоступна для этой роли."
  );
  const ownerID = optionalUUID(formData, "ownerID") ?? (
    String(formData.get("toState")) === "assigned" ? admin.id : null
  );
  const { error } = await supabase.rpc("transition_content_review_task", {
    p_task_id: requiredText(formData, "taskID", 80),
    p_expected_state: requiredText(formData, "expectedState", 40),
    p_to_state: requiredText(formData, "toState", 40),
    p_owner_id: ownerID,
    p_idempotency_key: requiredText(formData, "idempotencyKey", 200),
    p_reason: requiredText(formData, "reason", 1000)
  });
  rpcError(error);
  revalidatePath("/trust");
}

export async function bulkGovernancePolicyAction(formData: FormData) {
  const { supabase } = await governanceClient(
    canManageGovernancePolicy,
    "Policy override доступен только Owner или Admin."
  );
  const recordKeys = requiredText(formData, "recordKeys", 4000)
    .split(/\r?\n|,/)
    .map((value) => value.trim())
    .filter(Boolean);
  if (recordKeys.length === 0 || recordKeys.length > 200) throw new Error("Invalid recordKeys.");
  const { error } = await supabase.rpc("set_governance_owner_and_interval", {
    p_record_keys: recordKeys,
    p_owner_id: optionalUUID(formData, "ownerID"),
    p_review_interval_days: requiredInteger(formData, "reviewIntervalDays"),
    p_reason: requiredText(formData, "reason", 1000)
  });
  rpcError(error);
  revalidatePath("/trust");
}
