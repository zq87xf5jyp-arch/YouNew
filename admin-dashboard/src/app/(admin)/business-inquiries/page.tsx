import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { fetchRowsResult } from "@/lib/data";
import { updateBusinessInquiry } from "./actions";

type BusinessInquiryRow = {
  id: string;
  reference_code: string;
  company_name: string;
  contact_person: string;
  email: string;
  phone: string | null;
  website: string;
  organization_type: string;
  kvk_number: string | null;
  city: string;
  province: string;
  target_audience: string[];
  requested_placements: string[];
  campaign_goal: string;
  budget_range: string;
  campaign_start: string | null;
  campaign_end: string | null;
  message: string;
  status: string;
  admin_notes: string | null;
  created_at: string;
};

const statuses = [
  ["new", "Новая"],
  ["reviewing", "На проверке"],
  ["responded", "Ответ отправлен"],
  ["accepted", "Принята"],
  ["declined", "Отклонена"],
  ["test", "Тест"],
  ["archived", "Архив"]
] as const;

function displayList(values: string[]) {
  return values.length ? values.join(", ") : "—";
}

export default async function BusinessInquiriesPage() {
  const result = await fetchRowsResult<BusinessInquiryRow>(
    "business_inquiries",
    [],
    100,
    "created_at"
  );

  return (
    <>
      <PageHeader
        title="Бизнес-заявки"
        description="Приватная очередь заявок с публичного сайта. Контактные данные доступны только ролям owner/admin; изменения статуса и заметок попадают в audit log."
      />
      {result.source !== "supabase" ? (
        <div className="mb-6 rounded-md border border-destructive/40 bg-destructive/10 p-4 text-sm text-red-100" role="alert">
          Данные недоступны: соединение с production Supabase не подтверждено. Демо-заявки не подставляются.
        </div>
      ) : null}
      <div className="space-y-4">
        {result.rows.map((inquiry) => (
          <Card key={inquiry.id}>
            <CardHeader>
              <div className="flex flex-wrap items-start justify-between gap-3">
                <div>
                  <CardTitle>{inquiry.company_name}</CardTitle>
                  <CardDescription>
                    {inquiry.reference_code} · {new Date(inquiry.created_at).toLocaleString("nl-NL", { timeZone: "Europe/Amsterdam" })}
                  </CardDescription>
                </div>
                <Badge variant={inquiry.status === "accepted" ? "success" : inquiry.status === "declined" ? "destructive" : "info"}>
                  {statuses.find(([value]) => value === inquiry.status)?.[1] ?? inquiry.status}
                </Badge>
              </div>
            </CardHeader>
            <CardContent className="space-y-5">
              <dl className="grid gap-3 text-sm md:grid-cols-2 xl:grid-cols-3">
                <div><dt className="text-muted-foreground">Контакт</dt><dd>{inquiry.contact_person} · <a className="text-cyan-200 underline" href={`mailto:${inquiry.email}`}>{inquiry.email}</a></dd></div>
                <div><dt className="text-muted-foreground">Телефон</dt><dd>{inquiry.phone ?? "—"}</dd></div>
                <div><dt className="text-muted-foreground">Сайт</dt><dd><a className="text-cyan-200 underline" href={inquiry.website} rel="noreferrer" target="_blank">{inquiry.website}</a></dd></div>
                <div><dt className="text-muted-foreground">Организация</dt><dd>{inquiry.organization_type} · KvK {inquiry.kvk_number ?? "—"}</dd></div>
                <div><dt className="text-muted-foreground">Локация</dt><dd>{inquiry.city}, {inquiry.province}</dd></div>
                <div><dt className="text-muted-foreground">Бюджет</dt><dd>{inquiry.budget_range}</dd></div>
                <div><dt className="text-muted-foreground">Аудитория</dt><dd>{displayList(inquiry.target_audience)}</dd></div>
                <div><dt className="text-muted-foreground">Размещения</dt><dd>{displayList(inquiry.requested_placements)}</dd></div>
                <div><dt className="text-muted-foreground">Даты</dt><dd>{inquiry.campaign_start && inquiry.campaign_end ? `${inquiry.campaign_start} — ${inquiry.campaign_end}` : "По согласованию"}</dd></div>
              </dl>
              <div className="grid gap-2 text-sm">
                <p><span className="text-muted-foreground">Цель:</span> {inquiry.campaign_goal}</p>
                <p><span className="text-muted-foreground">Описание:</span> {inquiry.message}</p>
              </div>
              <form action={updateBusinessInquiry} className="grid gap-3 border-t border-border pt-4 md:grid-cols-[220px_1fr_auto] md:items-end">
                <input type="hidden" name="id" value={inquiry.id} />
                <label className="grid gap-1 text-sm">
                  <span className="font-medium">Статус</span>
                  <select className="h-10 rounded-md border border-input bg-secondary/50 px-3" name="status" defaultValue={inquiry.status}>
                    {statuses.map(([value, label]) => <option value={value} key={value}>{label}</option>)}
                  </select>
                </label>
                <label className="grid gap-1 text-sm">
                  <span className="font-medium">Внутренняя заметка</span>
                  <textarea className="min-h-20 rounded-md border border-input bg-secondary/50 px-3 py-2" name="adminNotes" maxLength={2000} defaultValue={inquiry.admin_notes ?? ""} />
                </label>
                <Button type="submit">Сохранить</Button>
              </form>
            </CardContent>
          </Card>
        ))}
        {result.source === "supabase" && result.rows.length === 0 ? (
          <Card>
            <CardContent className="py-8 text-sm text-muted-foreground">
              Подтверждённых заявок пока нет.
            </CardContent>
          </Card>
        ) : null}
      </div>
    </>
  );
}
