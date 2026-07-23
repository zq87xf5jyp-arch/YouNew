"use server";

import { revalidatePath } from "next/cache";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const allowedKeys = ["app_name", "support_email", "telegram_link", "app_store_link", "google_play_link", "privacy_policy_url", "terms_url", "default_city", "default_language", "announcement"] as const;

export async function saveSettings(formData: FormData) {
  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");

  const rows: Array<{ key: string; value: string; status: "published" }> = allowedKeys.map((key) => ({ key, value: String(formData.get(key) ?? ""), status: "published" }));
  rows.push({ key: "maintenance_mode", value: formData.get("maintenance_mode") === "on" ? "true" : "false", status: "published" });

  const { error } = await supabase.from("app_settings").upsert(rows, { onConflict: "key" });
  if (error) throw new Error(`Не удалось сохранить настройки: ${error.message}`);
  revalidatePath("/settings");
}
