import { PageHeader } from "@/components/admin/page-header";
import { ReadOnlySource } from "@/components/admin/read-only-source";
import { BusinessInquiryList } from "@/components/admin/business-inquiry-list";
import {
  BusinessInquiryNotificationInbox,
  type BusinessInquiryNotificationRow
} from "@/components/admin/business-inquiry-notification-inbox";
import { requireAdmin } from "@/lib/auth";
import { canManageBusinessInquiries } from "@/lib/authorization";
import {
  adaptInquiryList as adaptBusinessInquiryListRows,
  CURRENT_INQUIRY_SCHEMA, CURRENT_INQUIRY_CONTRACT
} from "@/lib/business-inquiry-compatibility";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { classifyDataQueryError } from "@/lib/data";

export default async function BusinessInquiriesPage() {
  const admin = await requireAdmin();
  if (!canManageBusinessInquiries(admin.role)) return <PageHeader title="Бизнес-заявки" description="Обращения доступны только владельцу и администратору." />;
  const BUSINESS_INQUIRY_LIST_SELECT = CURRENT_INQUIRY_CONTRACT.listSelect;
  const supabase = await createSupabaseServerClient();
  const [inquiryResult, notificationResult] = supabase ? await Promise.all([
    supabase.from("business_inquiries").select(BUSINESS_INQUIRY_LIST_SELECT).order("created_at", { ascending: false }).limit(250),
    supabase.from("business_inquiry_notifications").select("id,inquiry_id,reference_code,notification_kind,status,created_at,read_at,read_by").order("created_at", { ascending: false }).limit(100)
  ]) : [{ data: null, error: new Error("configuration") }, { data: null, error: new Error("configuration") }];
  const adapted = adaptBusinessInquiryListRows(Array.isArray(inquiryResult.data) ? inquiryResult.data : [], CURRENT_INQUIRY_SCHEMA);
  const inquiryIntegrityFailure = !inquiryResult.error && (!Array.isArray(inquiryResult.data) || adapted.issues.length > 0);
  const inquiryState = inquiryResult.error
    ? classifyDataQueryError(inquiryResult.error)
    : inquiryIntegrityFailure
      ? "unavailable"
      : (inquiryResult.data ?? []).length === 0 ? "empty" : "data";
  const notificationIntegrityFailure = !notificationResult.error && !Array.isArray(notificationResult.data);
  const notificationState = notificationResult.error
    ? classifyDataQueryError(notificationResult.error)
    : notificationIntegrityFailure ? "unavailable" : (notificationResult.data ?? []).length === 0 ? "empty" : "data";
  return (
    <>
      <PageHeader
        title="Бизнес-заявки"
        description="Заявки с публичной формы, внутренний PII-minimised inbox, согласие и статус обработки."
      />
      <ReadOnlySource
        state={inquiryState}
        label="Supabase business_inquiries"
        detail={inquiryState === "data"
          ? `Успешный запрос вернул последние ${adapted.rows.length} валидных заявок (лимит 250).`
          : inquiryState === "empty"
            ? "Успешный запрос измерил ноль доступных заявок."
            : inquiryState === "forbidden"
              ? "Доступ к заявкам запрещён текущей роли."
              : inquiryIntegrityFailure
                ? `Data integrity error: ${adapted.issues.length} записей не прошли обязательную схему. Частичная выборка не считается измеренным нулём.`
                : "Источник заявок недоступен; отсутствие строк не считается нулём."}
      />
      <ReadOnlySource
        state={notificationState}
        label="Supabase business_inquiry_notifications"
        detail={notificationState === "data"
          ? `Успешный запрос вернул последние ${(notificationResult.data ?? []).length} уведомлений (лимит 100).`
          : notificationState === "empty"
            ? "Успешный запрос измерил ноль доступных уведомлений."
            : notificationState === "forbidden"
              ? "Доступ к inbox запрещён текущей роли."
              : "Inbox недоступен; отсутствие строк не считается нулём."}
      />
      <BusinessInquiryNotificationInbox
        notifications={(notificationResult.data ?? []) as BusinessInquiryNotificationRow[]}
        available={!notificationResult.error && !notificationIntegrityFailure}
      />
      <BusinessInquiryList
        schema={CURRENT_INQUIRY_SCHEMA}
        rows={adapted.rows}
        available={!inquiryResult.error && !inquiryIntegrityFailure}
        integrityIssues={adapted.issues}
      />
    </>
  );
}
