import { NextResponse } from "next/server";
import { z } from "zod";
import { timingSafeEqual } from "node:crypto";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

const propertyValue = z.union([z.string().max(160), z.number().finite(), z.boolean(), z.null()]);
const eventSchema = z.object({
  app_instance_id: z.string().min(1).max(128),
  session_id: z.string().min(1).max(128).optional(),
  event_name: z.string().regex(/^[a-z][a-z0-9_]{1,79}$/),
  screen: z.string().max(120).optional(),
  platform: z.enum(["iOS", "Android", "Web"]).default("iOS"),
  app_version: z.string().max(40).optional(),
  language: z.string().max(12).optional(),
  city: z.string().max(80).optional(),
  properties: z.record(z.string().max(40), propertyValue).refine((value) => Object.keys(value).length <= 20).default({}),
  occurred_at: z.string().datetime().optional()
}).strict();

const batchSchema = z.object({
  events: z.array(eventSchema).min(1).max(100)
});

export async function POST(request: Request) {
  const configuredToken = process.env.INTERNAL_ANALYTICS_INGEST_TOKEN;
  if (process.env.MOBILE_ANALYTICS_ENABLED !== "true" || !configuredToken) {
    return NextResponse.json(
      { accepted: 0, stored: false, error: "Analytics ingestion is not configured." },
      { status: 503, headers: { "Cache-Control": "no-store" } }
    );
  }

  const providedToken = request.headers.get("authorization")?.replace(/^Bearer\s+/i, "") ?? "";
  const expected = Buffer.from(configuredToken);
  const provided = Buffer.from(providedToken);
  if (expected.length !== provided.length || !timingSafeEqual(expected, provided)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401, headers: { "Cache-Control": "no-store" } });
  }
  const contentLength = Number(request.headers.get("content-length") ?? "0");
  if (contentLength > 65_536) {
    return NextResponse.json({ error: "Payload too large" }, { status: 413, headers: { "Cache-Control": "no-store" } });
  }

  const body = await request.json().catch(() => null);
  const parsed = batchSchema.safeParse(body);

  if (!parsed.success) {
    return NextResponse.json({ error: "Некорректный формат событий" }, { status: 400, headers: { "Cache-Control": "no-store" } });
  }

  const supabase = createSupabaseAdminClient();
  const rows = parsed.data.events.map((event) => ({
    ...event,
    occurred_at: event.occurred_at ?? new Date().toISOString()
  }));

  if (!supabase) {
    return NextResponse.json(
      { accepted: 0, stored: false, error: "Analytics storage is not configured." },
      { status: 503, headers: { "Cache-Control": "no-store" } }
    );
  }

  const { error } = await supabase.from("app_events").insert(rows);
  if (error) {
    return NextResponse.json({ error: "Не удалось сохранить события", details: error.message }, { status: 500 });
  }

  return NextResponse.json({ accepted: rows.length, stored: true }, { headers: { "Cache-Control": "no-store" } });
}
