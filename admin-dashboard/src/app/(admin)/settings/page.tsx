import { Save } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { saveSettings } from "./actions";

const defaults: Record<string, string> = {
  app_name: "YouNew.nl", support_email: "support@younew.nl", telegram_link: "https://t.me/younew",
  app_store_link: "", google_play_link: "", privacy_policy_url: "https://younew.nl/privacy",
  terms_url: "https://younew.nl/terms", default_city: "Amsterdam", default_language: "en", announcement: "", maintenance_mode: "false"
};

export default async function SettingsPage() {
  const supabase = await createSupabaseServerClient();
  const { data } = supabase ? await supabase.from("app_settings").select("key,value") : { data: null };
  const settings = { ...defaults };
  for (const row of data ?? []) settings[String(row.key)] = typeof row.value === "string" ? row.value : String(row.value ?? "");
  return (
    <>
      <PageHeader title="Настройки" description="Настройте ссылки приложения, город и язык по умолчанию, поддержку, режим обслуживания и объявление для пользователей." />
      <Card>
        <CardHeader>
          <CardTitle>Конфигурация приложения</CardTitle>
          <CardDescription>Хранится в app_settings и экспортируется через публичный endpoint настроек.</CardDescription>
        </CardHeader>
        <CardContent>
          <form action={saveSettings} className="grid gap-4 lg:grid-cols-2">
            {[
              "app_name", "support_email", "telegram_link", "app_store_link", "google_play_link",
              "privacy_policy_url", "terms_url", "default_city", "default_language"
            ].map((name) => (
              <div key={name} className="flex flex-col gap-2">
                <Label htmlFor={name}>{settingLabels[name] ?? name.replaceAll("_", " ")}</Label>
                <Input id={name} name={name} defaultValue={settings[name]} />
              </div>
            ))}
            <div className="flex flex-col gap-2 lg:col-span-2">
              <Label htmlFor="announcement">Объявление в приложении</Label>
              <Textarea id="announcement" name="announcement" defaultValue={settings.announcement} placeholder="Необязательное сообщение, которое можно показать в приложении..." />
            </div>
            <label className="flex items-center gap-3 rounded-md border border-border bg-secondary/25 p-3 text-sm">
              <input name="maintenance_mode" type="checkbox" defaultChecked={settings.maintenance_mode === "true"} className="size-4 accent-orange-500" />
              Режим обслуживания
            </label>
            <div className="lg:col-span-2">
              <Button type="submit"><Save data-icon="inline-start" />Сохранить настройки</Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </>
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
