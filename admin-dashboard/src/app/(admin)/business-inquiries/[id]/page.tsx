import Link from "next/link";
import { notFound } from "next/navigation";
import { BusinessInquiryEditor } from "@/components/admin/business-inquiry-editor";
import { canManageBusinessInquiries } from "@/lib/authorization";
import { PageHeader } from "@/components/admin/page-header";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { requireAdmin } from "@/lib/auth";
import { adaptInquiryDetail as adaptBusinessInquiryDetailRow, CURRENT_INQUIRY_SCHEMA, CURRENT_INQUIRY_CONTRACT, isInquiryId, inquiryEditorUpdate } from "@/lib/business-inquiry-compatibility";
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
  params
}: {
  params: Promise<{ id: string }>;
}) {
  const admin = await requireAdmin();
  if (!canManageBusinessInquiries(admin.role)) return <PageHeader title="Бизнес-заявки" description="Обращения доступны только владельцу и администратору." />;
  const BUSINESS_INQUIRY_DETAIL_SELECT = CURRENT_INQUIRY_CONTRACT.detailSelect;
  const { id } = await params;
  if (!isInquiryId(id)) notFound();
  const supabase = await createSupabaseServerClient();
  if (!supabase) {
    return (
      <>
        <PageHeader title="Бизнес-заявка недоступна" description="Supabase не настроен; сохранение и чтение заблокированы до восстановления источника." />
        <p className="rounded-md border border-amber-400/30 bg-amber-400/10 p-4 text-sm text-amber-100" role="alert">
          Источник данных недоступен. Это состояние не трактуется как отсутствие заявки.
        </p>
      </>
    );
  }
  const { data, error } = await supabase.from("business_inquiries").select(BUSINESS_INQUIRY_DETAIL_SELECT).eq("id", id).maybeSingle();
  if (error) {
    return (
      <>
        <PageHeader title="Бизнес-заявка недоступна" description="Источник данных не ответил; это состояние не трактуется как отсутствие заявки." />
        <p className="rounded-md border border-red-400/30 bg-red-400/10 p-4 text-sm text-red-100" role="alert">
          Не удалось подтвердить запись business_inquiries. Контактные данные не включены в сообщение об ошибке.
        </p>
      </>
    );
  }
  if (!data) notFound();
  const { row: inquiry, issue } = adaptBusinessInquiryDetailRow(data, CURRENT_INQUIRY_SCHEMA);
  if (!inquiry || issue) {
    return (
      <>
        <PageHeader title="Data integrity error" description="Обязательные поля заявки не подтверждены; изменение заблокировано." />
        <p className="rounded-md border border-red-400/30 bg-red-400/10 p-4 text-sm text-red-100" role="alert">
          Запись не содержит корректные id, company_name, reference_code или status. Персональные данные не включены в диагностику.
        </p>
      </>
    );
  }

  return (
    <>
      <PageHeader
        title={`Заявка ${String(inquiry.reference_code)}`}
        description="Персональные данные доступны только одобренным администраторам. Не копируйте их в публичные журналы."
      />
      <div className="mb-4"><Link className="text-sm text-cyan-200 hover:underline" href="/business-inquiries">← Все заявки</Link></div>
      <div className="grid gap-6 xl:grid-cols-[1fr_360px]">
        <Card>
          <CardHeader>
            <CardTitle>Детали заявки</CardTitle>
            <CardDescription>Submission ID: {String(inquiry.id)}</CardDescription>
          </CardHeader>
          <CardContent>
            <dl className="grid gap-4 sm:grid-cols-2">
              {fields.filter(([key]) => CURRENT_INQUIRY_SCHEMA === "pipeline-v2" || !["contact_role", "offer_interest", "legacy_status", "lost_reason", "lost_reason_detail", "won_evidence_type", "won_evidence_at", "status_changed_at"].includes(key)).map(([key, label]) => (
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
            <CardDescription>Сохранение подтверждается источником. Смена статуса не отправляет письмо и не является подтверждением выручки.</CardDescription>
          </CardHeader>
          <CardContent>
            <BusinessInquiryEditor key={inquiry.id} initial={inquiryEditorUpdate(inquiry)} maximumEvidenceDate={new Date().toISOString().slice(0, 10)} />
          </CardContent>
        </Card>
      </div>
    </>
  );
}
