"use client";

import { useActionState } from "react";
import { Save } from "lucide-react";
import { saveSettings, type SettingsActionState } from "@/app/(admin)/settings/actions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import type { AdminSettings, EditableSettingKey } from "@/lib/admin-settings";

const initialState: SettingsActionState = { status: "idle", message: "" };
const textSettingFields = [
  "app_name", "support_email", "telegram_link", "app_store_link", "google_play_link",
  "privacy_policy_url", "terms_url", "default_city", "default_language"
] as const satisfies readonly EditableSettingKey[];

export function SettingsForm({ settings }: { settings: AdminSettings }) {
  const [state, action, pending] = useActionState(saveSettings, initialState);
  return (
    <form action={action} className="grid gap-4 lg:grid-cols-2">
      {textSettingFields.map((name) => (
        <div key={name} className="flex flex-col gap-2">
          <Label htmlFor={name}>{settingLabels[name] ?? name.replaceAll("_", " ")}</Label>
          <Input id={name} name={name} defaultValue={settings[name]} required={name === "app_name" || name === "support_email" || name === "default_city" || name === "default_language"} />
        </div>
      ))}
      <div className="flex flex-col gap-2 lg:col-span-2">
        <Label htmlFor="announcement">Объявление в приложении</Label>
        <Textarea id="announcement" name="announcement" maxLength={500} defaultValue={settings.announcement} placeholder="Необязательное сообщение, которое можно показать в приложении..." />
      </div>
      <label className="flex items-center gap-3 rounded-md border border-border bg-secondary/25 p-3 text-sm">
        <input name="maintenance_mode" type="checkbox" defaultChecked={settings.maintenance_mode} className="size-4 accent-orange-500" />
        Режим обслуживания
      </label>
      <div className="flex items-center gap-3 lg:col-span-2">
        <Button type="submit" disabled={pending}><Save data-icon="inline-start" />{pending ? "Сохранение…" : "Сохранить настройки"}</Button>
        {state.status !== "idle" ? (
          <p className={state.status === "success" ? "text-sm text-emerald-200" : "text-sm text-red-200"} role={state.status === "error" ? "alert" : "status"}>
            {state.message}
          </p>
        ) : null}
      </div>
    </form>
  );
}

const settingLabels: Record<string, string> = {
  app_name: "Название приложения",
  support_email: "Email поддержки",
  telegram_link: "Ссылка Telegram",
  app_store_link: "Ссылка App Store",
  google_play_link: "Ссылка Google Play",
  privacy_policy_url: "Политика конфиденциальности",
  terms_url: "Условия использования",
  default_city: "Город по умолчанию",
  default_language: "Язык по умолчанию"
};
