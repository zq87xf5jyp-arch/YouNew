import { NextResponse } from "next/server";
import { csvCell } from "@/lib/business-inquiry-export";
import {
  adaptInquiryExport as adaptBusinessInquiryExportRows,
  CURRENT_INQUIRY_SCHEMA, CURRENT_INQUIRY_CONTRACT, isInquiryId, isInquiryVersion
} from "@/lib/business-inquiry-compatibility";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function GET() {
  const supabase = await createSupabaseServerClient();
  if (!supabase) return NextResponse.json({ error: "Unavailable" }, { status: 503, headers: { "Cache-Control": "no-store" } });
  const { data: { user }, error: userError } = await supabase.auth.getUser();
  if (userError || !user) return NextResponse.json({ error: "Unauthorized" }, { status: 401, headers: { "Cache-Control": "no-store" } });
  const { data: profile, error: profileError } = await supabase.from("profiles").select("role,is_approved").eq("id", user.id).maybeSingle();
  if (profileError) return NextResponse.json({ error: "Authorization source unavailable" }, { status: 503, headers: { "Cache-Control": "no-store" } });
  if (!profile?.is_approved || !["owner", "admin"].includes(String(profile.role))) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403, headers: { "Cache-Control": "no-store" } });
  }

  const BUSINESS_INQUIRY_EXPORT_SELECT = CURRENT_INQUIRY_CONTRACT.exportSelect;
  const batchSize = 500;
  const maximumRows = 10_000;
  const exportWatermark = new Date().toISOString();
  const data: unknown[] = [];
  let cursor: { created_at: string; id: string } | null = null;
  while (data.length <= maximumRows) {
    let query = supabase
      .from("business_inquiries")
      .select(BUSINESS_INQUIRY_EXPORT_SELECT)
      .lte("created_at", exportWatermark)
      .order("created_at", { ascending: false })
      .order("id", { ascending: false })
      .limit(Math.min(batchSize, maximumRows + 1 - data.length));
    if (cursor) {
      query = query.or(`created_at.lt.${cursor.created_at},and(created_at.eq.${cursor.created_at},id.lt.${cursor.id})`);
    }
    const { data: batch, error } = await query;
    if (error || !Array.isArray(batch)) return NextResponse.json({ error: "Unavailable" }, { status: 503, headers: { "Cache-Control": "no-store" } });
    const rows = batch as unknown[];
    const checkedBatch = adaptBusinessInquiryExportRows(rows, CURRENT_INQUIRY_SCHEMA);
    if (checkedBatch.issues.length || checkedBatch.rows.length !== rows.length || checkedBatch.rows.some(row => !isInquiryId(row.id) || !isInquiryVersion(row.created_at))) {
      return NextResponse.json({ error: "Data integrity error" }, { status: 503, headers: { "Cache-Control": "no-store" } });
    }
    if (data.length + rows.length > maximumRows) {
      return NextResponse.json({ error: "Export exceeds the documented 10000-row safety limit; narrow the export scope." }, { status: 413, headers: { "Cache-Control": "no-store" } });
    }
    data.push(...rows);
    if (rows.length < batchSize) break;
    const last = rows.at(-1);
    if (!last || typeof last !== "object" || Array.isArray(last)) {
      return NextResponse.json({ error: "Data integrity error" }, { status: 503, headers: { "Cache-Control": "no-store" } });
    }
    const cursorCandidate = last as Record<string, unknown>;
    if (typeof cursorCandidate.created_at !== "string" || typeof cursorCandidate.id !== "string") {
      return NextResponse.json({ error: "Data integrity error" }, { status: 503, headers: { "Cache-Control": "no-store" } });
    }
    cursor = { created_at: cursorCandidate.created_at, id: cursorCandidate.id };
  }

  const adapted = adaptBusinessInquiryExportRows(data, CURRENT_INQUIRY_SCHEMA);
  if (adapted.issues.length > 0 || adapted.rows.length !== data.length) {
    return NextResponse.json({ error: "Data integrity error" }, { status: 503, headers: { "Cache-Control": "no-store" } });
  }

  const columns = CURRENT_INQUIRY_CONTRACT.exportColumns;
  const csv = [
    columns.join(","),
    ...adapted.rows.map((row) => columns.map((column) => csvCell((row as unknown as Record<string, unknown>)[column])).join(","))
  ].join("\r\n");
  return new NextResponse(csv, {
    headers: {
      "Cache-Control": "no-store",
      "Content-Disposition": `attachment; filename="younew-business-inquiries-${new Date().toISOString().slice(0, 10)}.csv"`,
      "Content-Type": "text/csv; charset=utf-8",
      "X-Content-Type-Options": "nosniff",
      "X-YouNew-Export-Row-Count": String(data.length),
      "X-YouNew-Export-Complete": "true",
      "X-YouNew-Export-Watermark": exportWatermark
    }
  });
}
