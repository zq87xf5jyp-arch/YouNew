import { NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";

function csvCell(value: unknown) {
  const text = String(value ?? "");
  return `"${text.replaceAll("\"", "\"\"")}"`;
}

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
    .select("confirmation_code,company,contact_name,work_email,inquiry_type,status,source_page,created_at")
    .order("created_at", { ascending: false })
    .limit(1000);
  if (error) return NextResponse.json({ error: "Unavailable" }, { status: 503 });

  const columns = ["confirmation_code", "company", "contact_name", "work_email", "inquiry_type", "status", "source_page", "created_at"] as const;
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
