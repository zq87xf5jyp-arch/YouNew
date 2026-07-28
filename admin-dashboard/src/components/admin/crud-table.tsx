import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";

type Row = Record<string, unknown>;

export function CrudTable({
  title,
  description,
  rows,
  columns
}: {
  title: string;
  description: string;
  rows: Row[];
  columns: string[];
  cta?: string;
}) {
  return (
    <Card>
      <CardHeader>
        <div>
          <CardTitle>{title}</CardTitle>
          <CardDescription>{description}</CardDescription>
        </div>
      </CardHeader>
      <CardContent>
        <div className="overflow-x-auto">
          <table className="younew-table">
            <thead>
              <tr>
                {columns.map((column) => (
                  <th key={column}>{labelForColumn(column)}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map((row, index) => (
                <tr key={`${String(row.slug ?? row.title ?? row.name ?? index)}-${index}`}>
                  {columns.map((column) => (
                    <td key={column}>{renderCell(row[column])}</td>
                  ))}
                </tr>
              ))}
              {rows.length === 0 ? (
                <tr>
                  <td colSpan={columns.length} className="text-muted-foreground">Нет подтверждённых данных.</td>
                </tr>
              ) : null}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  );
}

const columnLabels: Record<string, string> = {
  title: "Название",
  slug: "Слаг",
  category: "Категория",
  language: "Язык",
  status: "Статус",
  priority: "Приоритет",
  icon: "Иконка",
  color: "Цвет",
  name: "Город",
  province: "Провинция",
  lat: "Широта",
  lng: "Долгота",
  latitude: "Широта",
  longitude: "Долгота",
  type: "Тип",
  severity: "Серьезность",
  platform: "Платформа",
  app_screen: "Экран",
  url: "URL",
  source_type: "Тип источника",
  last_checked_date: "Проверено",
  question: "Вопрос",
  city: "Город",
  official_source: "Офиц. источник",
  user_email: "Email",
  message: "Сообщение",
  user_id: "Пользователь",
  action: "Действие",
  entity_type: "Тип объекта",
  entity_id: "ID объекта",
  created_at: "Создано",
  screen: "Экран",
  views: "Просмотры",
  avg_time: "Среднее время",
  conversion: "Конверсия",
  event_name: "Событие",
  count: "Количество",
  last_seen: "Последний раз",
  query: "Запрос",
  success_rate: "Успех",
  top_result: "Лучший результат",
  label: "Набор данных",
  version: "Версия",
  records: "Записей",
  last_sync: "Последняя синхронизация",
  job: "Задача",
  target: "Цель",
  duration: "Длительность",
  dataset: "Набор данных",
  duration_ms: "Длительность, мс",
  occurred_at: "Время события"
};

const valueLabels: Record<string, string> = {
  draft: "черновик",
  review: "на проверке",
  published: "опубликовано",
  archived: "архив",
  open: "открыта",
  "in progress": "в работе",
  fixed: "исправлена",
  verified: "проверена",
  closed: "закрыта",
  active: "активна",
  broken: "сломана",
  "needs review": "нужна проверка",
  low: "низкий",
  medium: "средний",
  high: "высокий",
  critical: "критический",
  urgent: "срочно",
  new: "новый",
  planned: "запланировано",
  reviewed: "просмотрено",
  resolved: "решено",
  city: "город",
  municipality: "муниципалитет",
  hospital: "больница",
  transport: "транспорт",
  government: "государство",
  education: "образование",
  custom: "пользовательская",
  healthcare: "здравоохранение",
  other: "другое",
  synced: "синхронизировано",
  success: "успешно",
  warning: "предупреждение",
  failed: "ошибка"
};

export function labelForColumn(column: string) {
  return columnLabels[column] ?? column.replaceAll("_", " ");
}

function renderCell(value: unknown) {
  if (typeof value === "string" && Object.prototype.hasOwnProperty.call(valueLabels, value)) {
    return (
      <Badge variant={value === "published" || value === "verified" || value === "active" ? "success" : value === "open" || value === "critical" ? "destructive" : "warning"}>
        {valueLabels[value]}
      </Badge>
    );
  }
  if (typeof value === "boolean") {
    return <Badge variant={value ? "success" : "secondary"}>{value ? "Да" : "Нет"}</Badge>;
  }
  if (value === null || value === undefined || value === "") return <span className="text-muted-foreground">-</span>;
  return String(value);
}
