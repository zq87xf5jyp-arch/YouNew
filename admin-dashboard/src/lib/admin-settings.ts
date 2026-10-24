import { z } from "zod";
import { canonicalCities } from "./canonical-admin-data.ts";

export const editableSettingKeys = [
  "app_name",
  "support_email",
  "telegram_link",
  "app_store_link",
  "google_play_link",
  "privacy_policy_url",
  "terms_url",
  "default_city",
  "default_language",
  "announcement"
] as const;

export const settingKeys = [...editableSettingKeys, "maintenance_mode"] as const;
export type EditableSettingKey = (typeof editableSettingKeys)[number];
export type AdminSettingKey = (typeof settingKeys)[number];
export type AdminSettings = Record<EditableSettingKey, string> & { maintenance_mode: boolean };
export const settingStatusSchema = z.enum(["draft", "review", "published", "archived"]);
export type AdminSettingStatus = z.infer<typeof settingStatusSchema>;

const canonicalCityNames = new Set(canonicalCities().map((city) => city.name));
const optionalHttpsUrl = z.string().trim().max(500).refine((value) => {
  if (!value) return true;
  try {
    return new URL(value).protocol === "https:";
  } catch {
    return false;
  }
}, "Требуется корректный HTTPS URL.");

export const settingsSchema = z.object({
  app_name: z.string().trim().min(1).max(80),
  support_email: z.string().trim().email().max(254),
  telegram_link: optionalHttpsUrl,
  app_store_link: optionalHttpsUrl,
  google_play_link: optionalHttpsUrl,
  privacy_policy_url: optionalHttpsUrl,
  terms_url: optionalHttpsUrl,
  default_city: z.string().trim().refine((value) => canonicalCityNames.has(value), "Неизвестный canonical city."),
  default_language: z.enum(["en", "nl", "ru"]),
  announcement: z.string().trim().max(500),
  maintenance_mode: z.boolean()
}).strict();

export function parseStoredSettings(input: unknown[]) {
  const values = new Map<string, string | boolean>();
  let invalidShape = false;
  for (const candidate of input) {
    if (!candidate || typeof candidate !== "object" || Array.isArray(candidate)) {
      invalidShape = true;
      continue;
    }
    const row = candidate as Record<string, unknown>;
    const key = typeof row.key === "string" ? row.key : "";
    const value = row.value;
    const validValue = key === "maintenance_mode" ? typeof value === "boolean" : typeof value === "string";
    const validStatus = settingStatusSchema.safeParse(row.status).success;
    if (!(settingKeys as readonly string[]).includes(key) || !validValue || !validStatus || values.has(key)) {
      invalidShape = true;
      continue;
    }
    values.set(key, value as string | boolean);
  }
  const missingKeys = settingKeys.filter((key) => !values.has(key));
  if (invalidShape || missingKeys.length > 0) {
    return { success: false as const, missingKeys };
  }
  const parsed = settingsSchema.safeParse(Object.fromEntries(settingKeys.map((key) => [key, values.get(key)])));
  return parsed.success
    ? { success: true as const, data: parsed.data }
    : { success: false as const, missingKeys: [] as AdminSettingKey[] };
}

export function parseSettingsFormData(formData: FormData) {
  return settingsSchema.safeParse({
    ...Object.fromEntries(editableSettingKeys.map((key) => [key, String(formData.get(key) ?? "")])),
    maintenance_mode: formData.get("maintenance_mode") === "on"
  });
}
