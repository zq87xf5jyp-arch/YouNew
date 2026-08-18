import { NextResponse } from "next/server";
import { csvCell } from "@/lib/business-inquiry-export";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function GET() {
  const supabase = await createSupabaseServerClient();
  if (!supabase) return NextResponse.json({ error: "Unavailable" }, { status: 503 });
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  const { data: profile } = await supabase.from("profiles").select("role,is_approved").eq("id", user.id).maybeSingle();
  if (!profile?.is_approved || !["owner", "admin"].includes(String(profile.role))) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  const { data, error } = await supabase
    .from("business_inquiries")
    .select("reference_code,company_name,contact_person,email,contact_role,inquiry_type,offer_interest,status,lost_reason,won_evidence_type,won_evidence_at,status_changed_at,source_page,created_at")
    .order("created_at", { ascending: false })
    .limit(1000);
  if (error) return NextResponse.json({ error: "Unavailable" }, { status: 503 });

  const columns = [
    "reference_code",
    "company_name",
    "contact_person",
    "email",
    "contact_role",
    "inquiry_type",
    "offer_interest",
    "status",
    "lost_reason",
    "won_evidence_type",
    "won_evidence_at",
    "status_changed_at",
    "source_page",
    "created_at"
  ] as const;
  const csv = [
    columns.join(","),
    ...(data ?? []).map((row) => columns.map((column) => csvCell(row[column])).join(","))
  ].join("\r\n");
  return new NextResponse(csv, {
    headers: {
      "Cache-Control": "no-store",
      "Content-Disposition": `attachment; filename="younew-business-inquiries-${new Date().toISOString().slice(0, 10)}.csv"`,
      "Content-Type": "text/csv; charset=utf-8",
      "X-Content-Type-Options": "nosniff"
    }
  });
}
