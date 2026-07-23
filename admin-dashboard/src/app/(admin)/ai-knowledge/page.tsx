import { AlertTriangle } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { fetchRows } from "@/lib/data";

const fallbackRows = [
  { question: "Как зарегистрироваться в Нидерландах?", category: "Документы и сервисы", city: "Любой", language: "ru", status: "published", official_source: true },
  { question: "Что такое DigiD?", category: "Документы и сервисы", city: "Любой", language: "ru", status: "review", official_source: true },
  { question: "Можно ли использовать OVpay в автобусах?", category: "Транспорт", city: "Любой", language: "ru", status: "draft", official_source: false }
];

export default async function AIKnowledgePage() {
  const rows = await fetchRows("ai_knowledge_items", fallbackRows);
  const riskyItems = rows.filter((row) => !Boolean(row.official_source)).length;
  return (
    <>
      <PageHeader title="Знания для AI" description="Управляйте проверенными вопросами и ответами для мобильного AI-ассистента. В экспорт должны попадать только опубликованные и проверенные материалы." />
      <div className="grid gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><AlertTriangle className="size-4 text-yellow-200" />Предупреждение об источниках</CardTitle>
            <CardDescription>Ответы без официального URL помечаются как рискованные и не должны использоваться для важных рекомендаций.</CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">{riskyItems ? `У ${riskyItems} записей нет подтверждённого официального источника.` : "Все записи имеют подтверждённый официальный источник."}</p>
          </CardContent>
        </Card>
        <CrudTable title="База знаний" description="Пары вопрос-ответ, категории, город/провинция и даты проверки." rows={rows} columns={["question", "category", "city", "language", "status", "official_source"]} cta="Новая запись" />
      </div>
    </>
  );
}
