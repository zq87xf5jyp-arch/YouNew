"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/auth";
import {
  editableSettingKeys,
  parseSettingsFormData,
  settingKeys,
  settingStatusSchema,
  type AdminSettingStatus
} from "@/lib/admin-settings";
import { canManageSettings } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export type SettingsActionState = {
  status: "idle" | "success" | "error";
  message: string;
};

export async function saveSettings(
  _previousState: SettingsActionState,
  formData: FormData
): Promise<SettingsActionState> {
  const admin = await requireAdmin();
  if (!canManageSettings(admin.role)) return { status: "error", message: "Недостаточно прав для изменения настроек." };
  const supabase = await createSupabaseServerClient();
  if (!supabase) return { status: "error", message: "Supabase не настроен." };

  const parsed = parseSettingsFormData(formData);
  if (!parsed.success) return { status: "error", message: "Проверьте обязательные поля, HTTPS-ссылки, язык и canonical city." };

  const currentResult = await supabase.from("app_settings").select("key,status").in("key", settingKeys);
  if (currentResult.error) return { status: "error", message: "Не удалось подтвердить текущие статусы настроек. Конфигурация не изменена." };
  const statuses = new Map<string, AdminSettingStatus>();
  for (const row of currentResult.data ?? []) {
    const parsedStatus = settingStatusSchema.safeParse(row.status);
    if (!(settingKeys as readonly string[]).includes(row.key) || !parsedStatus.success || statuses.has(row.key)) {
      return { status: "error", message: "Текущие настройки не прошли schema validation. Конфигурация не изменена." };
    }
    statuses.set(row.key, parsedStatus.data);
  }
  if (statuses.size !== settingKeys.length) {
    return { status: "error", message: "Набор настроек неполон. Конфигурация не изменена." };
  }

  // Status is deliberately omitted from the write. The read above proves that
  // every allowlisted row exists and is valid, while a value-only upsert cannot
  // revert a publication-state change made concurrently by another admin.
  const rows: Array<{ key: string; value: string | boolean }> = editableSettingKeys
    .map((key) => ({ key, value: parsed.data[key] }));
  rows.push({ key: "maintenance_mode", value: parsed.data.maintenance_mode });

  const { error } = await supabase.from("app_settings").upsert(rows, { onConflict: "key" });
  if (error) return { status: "error", message: "Не удалось сохранить настройки. Конфигурация не изменена полностью." };
  revalidatePath("/settings");
  return { status: "success", message: "Настройки сохранены." };
}
