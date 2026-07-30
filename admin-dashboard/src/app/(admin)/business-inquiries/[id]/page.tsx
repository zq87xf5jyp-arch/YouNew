import Link from "next/link";
import { notFound } from "next/navigation";
import { updateBusinessInquiry } from "../actions";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { requireAdmin } from "@/lib/auth";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const fields = [
  ["company", "Компания"],
  ["contact_name", "Контакт"],
  ["work_email", "Рабочий email"],
  ["phone", "Телефон"],
  ["website", "Сайт"],
  ["inquiry_type", "Тип запроса"],
  ["organization_type", "Тип организации"],
  ["kvk_number", "KvK"],
  ["city", "Город"],
  ["province", "Провинция"],
  ["target_audience", "Аудитория"],
  ["requested_placements", "Форматы"],
  ["campaign_goal", "Цель"],
  ["budget_range", "Диапазон бюджета"],
  ["campaign_start", "Начало"],
  ["campaign_end", "Окончание"],
  ["message", "Сообщение"],
  ["source_page", "Страница"],
  ["consent_at", "Согласие"],
  ["created_at", "Создано"]
] as const;

export default async function BusinessInquiryDetailsPage({
  params,
  searchParams
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ saved?: string }>;
}) {
  await requireAdmin();
  const { id } = await params;
  const saved = (await searchParams).saved === "1";
  const supabase = await createSupabaseServerClient();
  if (!supabase) notFound();
  const { data: inquiry } = await supabase.from("business_inquiries").select("*").eq("id", id).maybeSingle();
  if (!inquiry) notFound();

  return (
    <>
      <PageHeader
        title={`Заявка ${String(inquiry.confirmation_code)}`}
        description="Персональные данные доступны только одобренным администраторам. Не копируйте их в публичные журналы."
      />
      <div className="mb-4"><Link className="text-sm text-cyan-200 hover:underline" href="/business-inquiries">← Все заявки</Link></div>
      {saved ? <p className="mb-4 rounded-md border border-emerald-400/30 bg-emerald-400/10 p-3 text-sm text-emerald-100" role="status">Статус и внутренняя заметка сохранены; изменение записано в audit log без контактных данных.</p> : null}
      <div className="grid gap-6 xl:grid-cols-[1fr_360px]">
        <Card>
          <CardHeader>
            <CardTitle>Детали заявки</CardTitle>
            <CardDescription>Submission ID: {String(inquiry.id)}</CardDescription>
          </CardHeader>
          <CardContent>
            <dl className="grid gap-4 sm:grid-cols-2">
              {fields.map(([key, label]) => (
                <div className={key === "message" ? "sm:col-span-2" : ""} key={key}>
                  <dt className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">{label}</dt>
                  <dd className="mt-1 break-words text-sm">{Array.isArray(inquiry[key]) ? inquiry[key].join(", ") : String(inquiry[key] ?? "—")}</dd>
                </div>
              ))}
            </dl>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Обработка</CardTitle>
            <CardDescription>Изменения статуса и заметки фиксируются без копирования сообщения или контактов в audit log.</CardDescription>
          </CardHeader>
          <CardContent>
            <form action={updateBusinessInquiry} className="space-y-4">
              <input type="hidden" name="id" value={String(inquiry.id)} />
              <div className="space-y-2">
                <Label htmlFor="inquiry-status">Статус</Label>
                <select id="inquiry-status" name="status" defaultValue={String(inquiry.status)} className="h-10 w-full rounded-md border border-input bg-secondary/50 px-3 text-sm">
                  <option value="new">новая</option>
                  <option value="contacted">связались</option>
                  <option value="qualified">подтверждена</option>
                  <option value="closed">закрыта</option>
                  <option value="rejected">отклонена</option>
                  <option value="spam">спам</option>
                </select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="internal-note">Внутренняя заметка</Label>
                <Textarea id="internal-note" name="internalNote" maxLength={4000} defaultValue={String(inquiry.internal_note ?? "")} />
                <p className="text-xs text-muted-foreground">Не добавляйте сюда лишние персональные данные.</p>
              </div>
              <Button type="submit">Сохранить</Button>
              <p className="text-xs text-muted-foreground">Текущий статус: <Badge variant="secondary">{String(inquiry.status)}</Badge></p>
            </form>
          </CardContent>
        </Card>
      </div>
    </>
  );
}
