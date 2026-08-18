import { PageHeader } from "@/components/admin/page-header";
import { BusinessInquiryList, type BusinessInquiryListRow } from "@/components/admin/business-inquiry-list";
import {
  BusinessInquiryNotificationInbox,
  type BusinessInquiryNotificationRow
} from "@/components/admin/business-inquiry-notification-inbox";
import { fetchRowsResult } from "@/lib/data";
import { requireAdmin } from "@/lib/auth";

export default async function BusinessInquiriesPage() {
  await requireAdmin();
  const [inquiryResult, notificationResult] = await Promise.all([
    fetchRowsResult<BusinessInquiryListRow>("business_inquiries", [], 250, "created_at"),
    fetchRowsResult<BusinessInquiryNotificationRow>("business_inquiry_notifications", [], 100, "created_at")
  ]);
  return (
    <>
      <PageHeader
        title="Бизнес-заявки"
        description="Заявки с публичной формы, внутренний PII-minimised inbox, согласие, статус обработки и безопасный журнал изменений."
      />
      <BusinessInquiryNotificationInbox
        notifications={notificationResult.rows}
        available={notificationResult.source === "supabase"}
      />
      <BusinessInquiryList rows={inquiryResult.rows} available={inquiryResult.source === "supabase"} />
    </>
  );
}
