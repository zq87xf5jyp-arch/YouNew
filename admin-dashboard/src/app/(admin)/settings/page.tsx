import { PageHeader } from "@/components/admin/page-header";
import { SettingsForm } from "@/components/admin/settings-form";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { parseStoredSettings, settingKeys } from "@/lib/admin-settings";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export default async function SettingsPage() {
  const supabase = await createSupabaseServerClient();
  const result = supabase
    ? await supabase.from("app_settings").select("key,value,status").in("key", settingKeys)
    : { data: null, error: new Error("configuration") };
  const parsed = result.error ? null : parseStoredSettings(result.data ?? []);
  const unavailable = Boolean(result.error) || !parsed?.success;
  return (
    <>
      <PageHeader title="Настройки" description="Настройте ссылки приложения, город и язык по умолчанию, поддержку, режим обслуживания и объявление для пользователей." />
      <Card>
        <CardHeader>
          <CardTitle>Конфигурация приложения</CardTitle>
          <CardDescription>Хранится в app_settings и экспортируется через публичный endpoint настроек.</CardDescription>
        </CardHeader>
        <CardContent>
          {unavailable ? (
            <div className="rounded-md border border-red-400/30 bg-red-400/10 p-4 text-sm text-red-100" role="alert">
              Настройки недоступны или не прошли schema validation. Сохранение заблокировано, чтобы defaults или повреждённые значения не перезаписали рабочую конфигурацию.
            </div>
          ) : <SettingsForm settings={parsed.data} />}
        </CardContent>
      </Card>
    </>
  );
}
