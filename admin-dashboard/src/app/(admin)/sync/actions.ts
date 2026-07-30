"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import { canPublishContent } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";

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
