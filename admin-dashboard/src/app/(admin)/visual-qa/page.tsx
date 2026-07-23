import { ImageUp, Plus, Sparkles } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

const screenshots = ["Главная", "Категории", "Дашборд", "Карта", "AI-ассистент", "Транспорт", "Библиотека"];

export default function VisualQAPage() {
  return (
    <>
      <PageHeader title="Проверка интерфейса" description="Загружайте скриншоты приложения, задавайте экран/устройство, ставьте маркеры проблем, сравнивайте ожидаемый и текущий вид и создавайте ошибки прямо из проверки." actions={<Button><ImageUp data-icon="inline-start" />Загрузить скриншот</Button>} />
      <div className="grid gap-6 xl:grid-cols-[0.85fr_1.15fr]">
        <Card>
          <CardHeader>
            <CardTitle>Загрузка скриншота</CardTitle>
            <CardDescription>Файлы хранятся в приватном бакете Supabase Storage для одобренных админов.</CardDescription>
          </CardHeader>
          <CardContent>
            <form className="flex flex-col gap-4">
              <div className="rounded-lg border border-dashed border-cyan-400/35 bg-cyan-400/10 p-8 text-center">
                <ImageUp className="mx-auto size-9 text-cyan-200" />
                <p className="mt-3 text-sm font-semibold">Перетащите скриншоты сюда</p>
                <p className="text-xs text-muted-foreground">PNG/JPEG, размеры App Store, симулятор или реальное устройство.</p>
              </div>
              <div className="grid gap-4 md:grid-cols-2">
                <div className="flex flex-col gap-2"><Label>Тип экрана</Label><Input placeholder="Главная, Карта, Транспорт..." /></div>
                <div className="flex flex-col gap-2"><Label>Платформа</Label><Input placeholder="iOS / Android / Web" /></div>
                <div className="flex flex-col gap-2"><Label>Устройство</Label><Input placeholder="iPhone / Android / Tablet" /></div>
                <div className="flex flex-col gap-2"><Label>Статус</Label><Input placeholder="хорошо / нужна проверка / сломано / исправлено" /></div>
              </div>
              <div className="flex flex-col gap-2"><Label>Заметки</Label><Textarea placeholder="Опишите проблемы отступов, контраста, верстки или текста..." /></div>
              <Button type="button"><Plus data-icon="inline-start" />Создать проверку</Button>
            </form>
          </CardContent>
        </Card>
        <div className="grid gap-6">
          <Card>
            <CardHeader>
              <CardTitle>Доска проверки</CardTitle>
              <CardDescription>Маркеры показывают вручную отмеченные проблемы интерфейса.</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-3 md:grid-cols-2">
              {screenshots.map((item, index) => (
                <div key={item} className="relative aspect-[9/16] rounded-lg border border-border bg-gradient-to-br from-[#07152b] to-[#020713] p-4">
                  <p className="text-sm font-semibold">{item}</p>
                  <p className="text-xs text-muted-foreground">iPhone · dark mode</p>
                  <div className="absolute left-[52%] top-[38%] grid size-8 place-items-center rounded-full bg-primary font-bold text-primary-foreground">{index + 1}</div>
                  <Badge className="absolute bottom-3 left-3" variant={index % 3 === 0 ? "success" : "warning"}>{index % 3 === 0 ? "хорошо" : "нужна проверка"}</Badge>
                </div>
              ))}
            </CardContent>
          </Card>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2"><Sparkles className="size-4 text-cyan-200" />AI-анализ интерфейса</CardTitle>
              <CardDescription>Скоро. Автоматическое распознавание визуальных проблем можно включить позже после подключения OpenAI Vision API.</CardDescription>
            </CardHeader>
          </Card>
        </div>
      </div>
    </>
  );
}
