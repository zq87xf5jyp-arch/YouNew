import { createClient } from "npm:@supabase/supabase-js@2.108.2";
import { validateBusinessInquiryPayload } from "../_shared/business-inquiry.ts";

const defaultOrigins = ["https://younew.nl", "https://www.younew.nl"];

function allowedOrigins(): Set<string> {
  const configured = Deno.env.get("BUSINESS_INQUIRY_ALLOWED_ORIGINS")
    ?.split(",")
    .map((value) => value.trim())
    .filter(Boolean);
  return new Set(configured?.length ? configured : defaultOrigins);
}

function corsHeaders(origin: string): Record<string, string> {
  return {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Headers": "content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Max-Age": "600",
    "Cache-Control": "no-store",
    "Content-Type": "application/json; charset=utf-8",
    "Vary": "Origin"
  };
}

function json(origin: string, status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders(origin) });
}

async function sha256(value: string): Promise<string> {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, "0")).join("");
}

function clientAddress(request: Request): string {
  return (
    request.headers.get("cf-connecting-ip")
    ?? request.headers.get("x-real-ip")
    ?? request.headers.get("x-forwarded-for")?.split(",")[0]?.trim()
    ?? ""
  );
}

Deno.serve(async (request) => {
  const origin = request.headers.get("origin") ?? "";
  if (!allowedOrigins().has(origin)) {
    return new Response(null, { status: 403, headers: { "Cache-Control": "no-store", "Vary": "Origin" } });
  }

  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders(origin) });
  }
  if (request.method !== "POST") return json(origin, 405, { error: "method_not_allowed" });
  if (!request.headers.get("content-type")?.toLowerCase().startsWith("application/json")) {
    return json(origin, 415, { error: "json_required" });
  }

  const contentLength = Number(request.headers.get("content-length") ?? "0");
  if (Number.isFinite(contentLength) && contentLength > 16_384) {
    return json(origin, 413, { error: "payload_too_large" });
  }

  let payload: unknown;
  try {
    const raw = await request.text();
    if (raw.length > 16_384) return json(origin, 413, { error: "payload_too_large" });
    payload = JSON.parse(raw);
  } catch {
    return json(origin, 400, { error: "invalid_json" });
  }

  const validation = validateBusinessInquiryPayload(payload);
  if (!validation.valid) return json(origin, 422, { error: "validation_failed", fields: validation.errors });

  const projectUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const rateLimitSalt = Deno.env.get("BUSINESS_INQUIRY_RATE_LIMIT_SALT");
  const address = clientAddress(request);
  if (!projectUrl || !serviceRoleKey || !rateLimitSalt || !address) {
    return json(origin, 503, { error: "submission_unavailable" });
  }

  const fingerprintHash = await sha256(`${rateLimitSalt}|${address}`);
  const supabase = createClient(projectUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false }
  });
  const { data, error } = await supabase.rpc("submit_business_inquiry", {
    submission: validation.value,
    fingerprint_hash: fingerprintHash
  });

  if (error) {
    if (error.message.includes("rate_limit")) return json(origin, 429, { error: "rate_limited" });
    return json(origin, 503, { error: "submission_unavailable" });
  }

  const reference = Array.isArray(data) && typeof data[0]?.reference_code === "string"
    ? data[0].reference_code
    : null;
  if (!reference) return json(origin, 503, { error: "submission_unavailable" });

  return json(origin, 201, {
    ok: true,
    reference,
    message: "Your inquiry was received. Keep this reference for follow-up."
  });
});
