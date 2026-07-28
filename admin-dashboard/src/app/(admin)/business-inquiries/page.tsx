import { PageHeader } from "@/components/admin/page-header";
import { BusinessInquiryList, type BusinessInquiryListRow } from "@/components/admin/business-inquiry-list";
import { fetchRowsResult } from "@/lib/data";
import { requireAdmin } from "@/lib/auth";

export default async function BusinessInquiriesPage() {
  await requireAdmin();
  const result = await fetchRowsResult<BusinessInquiryListRow>("business_inquiries", [], 250, "created_at");
  return (
    <>
      <PageHeader
        title="Бизнес-заявки"
        description="Заявки с публичной формы, их источник, согласие, статус обработки и безопасный журнал изменений."
      />
      <BusinessInquiryList rows={result.rows} available={result.source === "supabase"} />
    </>
  );
}
