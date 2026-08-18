import Link from "next/link";
import { notFound } from "next/navigation";
import { updateBusinessInquiry } from "../actions";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { requireAdmin } from "@/lib/auth";
import {
  BUSINESS_INQUIRY_LOST_REASON_LABELS,
  BUSINESS_INQUIRY_LOST_REASONS,
  BUSINESS_INQUIRY_OFFER_INTERESTS,
  BUSINESS_INQUIRY_OFFER_LABELS,
  BUSINESS_INQUIRY_STATUSES,
  BUSINESS_INQUIRY_STATUS_LABELS,
  BUSINESS_INQUIRY_WON_EVIDENCE_LABELS,
  BUSINESS_INQUIRY_WON_EVIDENCE_TYPES
} from "@/lib/business-inquiry-pipeline";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const fields = [
  ["company_name", "Компания"],
  ["contact_person", "Контакт"],
  ["email", "Рабочий email"],
  ["phone", "Телефон"],
  ["website", "Сайт"],
  ["contact_role", "Роль контакта"],
  ["inquiry_type", "Тип запроса"],
  ["offer_interest", "Интерес к предложению"],
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
  ["legacy_status", "Исходный legacy-статус"],
  ["lost_reason", "Причина отказа"],
  ["lost_reason_detail", "Фактическое пояснение отказа"],
  ["won_evidence_type", "Тип доказательства won"],
  ["won_evidence_at", "Дата доказательства won"],
  ["status_changed_at", "Статус изменён"],
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
        title={`Заявка ${String(inquiry.reference_code)}`}
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
                  {BUSINESS_INQUIRY_STATUSES.map((status) => (
                    <option value={status} key={status}>{BUSINESS_INQUIRY_STATUS_LABELS[status]}</option>
                  ))}
                </select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="contact-role">Роль контакта</Label>
                <Input id="contact-role" name="contactRole" minLength={2} maxLength={120} defaultValue={String(inquiry.contact_role ?? "")} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="offer-interest">Интерес к предложению</Label>
                <select id="offer-interest" name="offerInterest" defaultValue={String(inquiry.offer_interest)} className="h-10 w-full rounded-md border border-input bg-secondary/50 px-3 text-sm">
                  {BUSINESS_INQUIRY_OFFER_INTERESTS.map((offer) => (
                    <option value={offer} key={offer}>{BUSINESS_INQUIRY_OFFER_LABELS[offer]}</option>
                  ))}
                </select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="lost-reason">Причина отказа</Label>
                <select id="lost-reason" name="lostReason" defaultValue={String(inquiry.lost_reason ?? "")} className="h-10 w-full rounded-md border border-input bg-secondary/50 px-3 text-sm">
                  <option value="">Не выбрана</option>
                  {BUSINESS_INQUIRY_LOST_REASONS.map((reason) => (
                    <option value={reason} key={reason}>{BUSINESS_INQUIRY_LOST_REASON_LABELS[reason]}</option>
                  ))}
                </select>
                <p className="text-xs text-muted-foreground">Обязательна для lost. Не выводите причину из молчания до завершения разрешённой серии контактов.</p>
              </div>
              <div className="space-y-2">
                <Label htmlFor="lost-reason-detail">Пояснение отказа</Label>
                <Textarea id="lost-reason-detail" name="lostReasonDetail" minLength={5} maxLength={500} defaultValue={String(inquiry.lost_reason_detail ?? "")} />
                <p className="text-xs text-muted-foreground">Обязательно для «другая причина»; не добавляйте лишние персональные данные.</p>
              </div>
              <div className="space-y-2">
                <Label htmlFor="won-evidence-type">Доказательство won</Label>
                <select id="won-evidence-type" name="wonEvidenceType" defaultValue={String(inquiry.won_evidence_type ?? "")} className="h-10 w-full rounded-md border border-input bg-secondary/50 px-3 text-sm">
                  <option value="">Не выбрано</option>
                  {BUSINESS_INQUIRY_WON_EVIDENCE_TYPES.map((evidence) => (
                    <option value={evidence} key={evidence}>{BUSINESS_INQUIRY_WON_EVIDENCE_LABELS[evidence]}</option>
                  ))}
                </select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="won-evidence-date">Дата доказательства won</Label>
                <Input id="won-evidence-date" name="wonEvidenceDate" type="date" max={new Date().toISOString().slice(0, 10)} defaultValue={String(inquiry.won_evidence_at ?? "").slice(0, 10)} />
                <p className="text-xs text-muted-foreground">Для won одновременно обязательны контролируемый тип и дата доказательства.</p>
              </div>
              <div className="space-y-2">
                <Label htmlFor="internal-note">Внутренняя заметка</Label>
                <Textarea id="internal-note" name="internalNote" maxLength={2000} defaultValue={String(inquiry.admin_notes ?? "")} />
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
