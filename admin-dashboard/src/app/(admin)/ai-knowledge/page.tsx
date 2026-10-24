import { AlertTriangle } from "lucide-react";
import { PageHeader } from "@/components/admin/page-header";
import { CrudTable } from "@/components/admin/crud-table";
import { ReadOnlySource } from "@/components/admin/read-only-source";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { fetchRowsResult } from "@/lib/data";

const fallbackRows = [
  { question: "Как зарегистрироваться в Нидерландах?", category: "Документы и сервисы", city: "Любой", language: "ru", status: "published", official_source: true },
  { question: "Что такое DigiD?", category: "Документы и сервисы", city: "Любой", language: "ru", status: "review", official_source: true },
  { question: "Можно ли использовать OVpay в автобусах?", category: "Транспорт", city: "Любой", language: "ru", status: "draft", official_source: false }
];

export default async function AIKnowledgePage() {
  const result = await fetchRowsResult("ai_knowledge_items", fallbackRows);
  const rows = result.rows;
  const riskyItems = rows.filter((row) => !Boolean(row.official_source)).length;
  return (
    <>
      <PageHeader title="Знания для AI" description="Только просмотр оперативной таблицы. Она не заменяет packaged governed retrieval dataset и не выдаётся за release evidence." />
      <ReadOnlySource
        state={result.state}
        label={result.source === "supabase" ? "Supabase ai_knowledge_items" : result.source === "demo" ? "explicit local demo" : "Supabase unavailable"}
        detail={result.state === "data" ? `${rows.length} rows returned by the authenticated query.` : result.state === "empty" ? "Successful authenticated query returned zero rows." : result.state === "forbidden" ? "The authenticated identity is not permitted to read this source." : result.source === "demo" ? "Synthetic rows are not production knowledge." : "No AI-knowledge row count or source-completeness claim is made."}
      />
      <div className="grid gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><AlertTriangle className="size-4 text-yellow-200" />Предупреждение об источниках</CardTitle>
            <CardDescription>Ответы без официального URL помечаются как рискованные и не должны использоваться для важных рекомендаций.</CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">{result.state === "unavailable" || result.state === "forbidden" ? "Источник не прочитан; полнота официальных ссылок неизвестна." : result.state === "empty" ? "Измерено: запрос вернул ноль строк." : riskyItems ? `У ${riskyItems} записей нет подтверждённого официального источника.` : "В возвращённых строках официальный источник отмечен у каждой записи."}</p>
          </CardContent>
        </Card>
        <CrudTable title="База знаний" description="Read-only operational projection; publication authority remains with governed packaged content." rows={rows} columns={["question", "category", "city", "language", "status", "official_source"]} />
      </div>
    </>
  );
}
