import { CheckCircle2 } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import dataProject from "@/generated/data-project-dashboard.json";

const checklist = [
  "Все критические ошибки исправлены",
  "Политика конфиденциальности обновлена",
  "Условия использования обновлены",
  "Скриншоты App Store проверены",
  "Скриншоты Google Play проверены",
  "URL поддержки работает",
  "Лендинг работает",
  "Universal Links проверены",
  "Android App Links проверены",
  "Нет сломанных официальных ссылок",
  "Визуальная проверка одобрена",
  "Контент проверен",
  "Резервная копия создана"
];

export default function ReleasesPage() {
  const nextDataRelease = dataProject.next_release;

  return (
    <>
      <PageHeader title="Чек-лист релиза" description="Product Releases и независимые Data Releases с собственными версиями и QA." actions={<Button><CheckCircle2 data-icon="inline-start" />Создать релиз</Button>} />
      <div className="mb-6 grid gap-6 xl:grid-cols-[0.8fr_1.2fr]">
        <Card>
          <CardHeader>
            <CardTitle>Текущий Data Release</CardTitle>
            <CardDescription>Версия данных, находящаяся у пользователей.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex items-center justify-between gap-3">
              <span className="text-sm text-muted-foreground">Release</span>
              <Badge variant="warning">{dataProject.runtime_release.version}</Badge>
            </div>
            <p className="text-sm">{dataProject.runtime_release.note}</p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Следующий Data Release</CardTitle>
            <CardDescription>{nextDataRelease ? `${nextDataRelease.dataset} · v${nextDataRelease.version}` : "Не запланирован"}</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {nextDataRelease ? (
              <>
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <p className="text-sm font-semibold">{nextDataRelease.id}</p>
                    <p className="text-xs text-muted-foreground">{nextDataRelease.milestone} · {nextDataRelease.published_records} / {nextDataRelease.target_records} records</p>
                  </div>
                  <Badge>{nextDataRelease.status}</Badge>
                </div>
                <div className="grid gap-2 sm:grid-cols-2 lg:grid-cols-4">
                  {Object.entries(nextDataRelease.qa).map(([gate, status]) => (
                    <div key={gate} className="rounded-md border border-border bg-secondary/25 p-2 text-xs">
                      <span className="font-medium uppercase">{gate}</span>
                      <span className="ml-2 text-muted-foreground">{status}</span>
                    </div>
                  ))}
                </div>
              </>
            ) : null}
          </CardContent>
        </Card>
      </div>
      <h2 className="mb-4 text-lg font-semibold">PRODUCT Release</h2>
      <div className="grid gap-6 xl:grid-cols-[0.8fr_1.2fr]">
        <Card>
          <CardHeader>
            <CardTitle>Следующий релиз</CardTitle>
            <CardDescription>Версия 1.0.0 · iOS · тестирование</CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-4">
            <div className="rounded-lg border border-border bg-secondary/35 p-4">
              <p className="text-sm font-semibold">Описание релиза</p>
              <p className="mt-2 text-sm text-muted-foreground">Улучшены городские гайды, понятность карты, визуальные исправления и надежность источников AI.</p>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-muted-foreground">Готовность</span>
              <Badge variant="success">82%</Badge>
            </div>
            <div className="h-2 rounded-full bg-secondary"><div className="h-2 w-[82%] rounded-full bg-primary" /></div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Основной чек-лист</CardTitle>
            <CardDescription>Обязательные пункты перед статусом “готово к релизу”.</CardDescription>
          </CardHeader>
          <CardContent className="grid gap-3 md:grid-cols-2">
            {checklist.map((item, index) => (
              <label key={item} className="flex items-center gap-3 rounded-md border border-border bg-secondary/25 p-3 text-sm">
                <input type="checkbox" defaultChecked={index < 10} className="size-4 accent-orange-500" />
                {item}
              </label>
            ))}
          </CardContent>
        </Card>
      </div>
    </>
  );
}
