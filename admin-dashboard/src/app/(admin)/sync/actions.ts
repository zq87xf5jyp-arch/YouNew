"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { canPublishContent } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export async function requestContentSync() {
  const admin = await requireAdmin();
  if (!canPublishContent(admin.role)) {
    throw new Error("Запуск синхронизации доступен только владельцу или администратору.");
  }
  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");

  const { data: jobId, error: requestError } = await supabase.rpc("request_content_sync");
  if (requestError || typeof jobId !== "string") {
    throw new Error(requestError?.message ?? "Не удалось создать задачу синхронизации.");
  }

  const { error: executionError } = await supabase.functions.invoke("prepare-content-sync", {
    body: { jobId }
  });
  revalidatePath("/sync");
  if (executionError) {
    throw new Error(`Задача ${jobId} создана, но исполнитель недоступен. Проверьте статус и повторите после развёртывания Edge Function.`);
  }
}

export async function activateContentArtifact(formData: FormData) {
  const admin = await requireAdmin();
  if (!canPublishContent(admin.role)) {
    throw new Error("Активация доступна только владельцу или администратору.");
  }

  const artifactId = String(formData.get("artifactId") ?? "").trim();
  if (!uuidPattern.test(artifactId)) {
    throw new Error("Некорректный идентификатор candidate-артефакта.");
  }

  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");
  const { error } = await supabase.rpc("activate_content_artifact", {
    p_artifact_id: artifactId
  });
  if (error) {
    throw new Error(error.message || "Не удалось активировать candidate-артефакт.");
  }

  revalidatePath("/sync");
}
