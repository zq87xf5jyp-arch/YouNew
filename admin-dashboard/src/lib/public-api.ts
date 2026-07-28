import { NextResponse } from "next/server";
import { fetchPublishedRows } from "@/lib/data";

export async function publicTableResponse(table: string) {
  try {
    const rows = await fetchPublishedRows(table);
    return NextResponse.json(
      { data: rows, generated_at: new Date().toISOString() },
      {
        headers: {
          "Cache-Control": "public, s-maxage=300, stale-while-revalidate=3600"
        }
      }
    );
  } catch {
    return NextResponse.json(
      { data: [], error: "Published content is temporarily unavailable." },
      { status: 503, headers: { "Cache-Control": "no-store" } }
    );
  }
}
