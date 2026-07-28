import { createClient } from "@supabase/supabase-js";
import { validatePublicFeedbackPayload } from "./validation.ts";

const allowedOrigins = new Set([
  "https://younew.nl",
  "https://www.younew.nl",
  "http://localhost:3000",
  "http://localhost:3001",
  "http://127.0.0.1:3000",
  "http://127.0.0.1:3001",
]);

function responseHeaders(origin: string) {
  return {
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "content-type",
    "Cache-Control": "no-store",
    "Content-Type": "application/json; charset=utf-8",
    "Vary": "Origin",
    "X-Content-Type-Options": "nosniff",
  };
}

function jsonResponse(
  origin: string,
  status: number,
  payload: Record<string, unknown>,
) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: responseHeaders(origin),
  });
}

async function sha256Hex(value: string) {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return Array.from(
    new Uint8Array(digest),
    (byte) => byte.toString(16).padStart(2, "0"),
  ).join("");
}

Deno.serve(async (request) => {
  const origin = request.headers.get("origin") ?? "";
  if (!allowedOrigins.has(origin)) {
    return new Response(JSON.stringify({ error: "origin_not_allowed" }), {
      status: 403,
      headers: {
        "Cache-Control": "no-store",
        "Content-Type": "application/json; charset=utf-8",
        "X-Content-Type-Options": "nosniff",
      },
    });
  }
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: responseHeaders(origin),
    });
  }
  if (request.method !== "POST") {
    return jsonResponse(origin, 405, { error: "method_not_allowed" });
  }
  if (
    !request.headers.get("content-type")?.toLowerCase().startsWith(
      "application/json",
    )
  ) {
    return jsonResponse(origin, 415, { error: "json_required" });
  }

  const declaredLength = Number(request.headers.get("content-length") ?? "0");
  if (Number.isFinite(declaredLength) && declaredLength > 16_384) {
    return jsonResponse(origin, 413, { error: "payload_too_large" });
  }

  let payload: unknown;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse(origin, 400, { error: "invalid_json" });
  }

  const validation = validatePublicFeedbackPayload(payload);
  if (!validation.valid) {
    return jsonResponse(origin, 400, {
      error: "validation_failed",
      fields: validation.fields,
    });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const rateLimitSalt = Deno.env.get("PUBLIC_FEEDBACK_RATE_LIMIT_SALT");
  if (
    !supabaseUrl || !serviceRoleKey || !rateLimitSalt ||
    rateLimitSalt.length < 32
  ) {
    return jsonResponse(origin, 503, { error: "service_unavailable" });
  }

  const forwardedFor = request.headers.get("x-forwarded-for")?.split(",")[0]
    ?.trim();
  const connectingIp = request.headers.get("cf-connecting-ip")?.trim();
  const rateKey = await sha256Hex(
    `${rateLimitSalt}:${forwardedFor || connectingIp || "unavailable"}`,
  );
  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });

  const { data, error } = await supabase.rpc("submit_public_feedback", {
    p_payload: payload,
    p_rate_key: rateKey,
  });
  if (error) {
    if (error.message.includes("rate_limited")) {
      return jsonResponse(origin, 429, { error: "rate_limited" });
    }
    if (
      error.message.includes("validation_failed") ||
      error.message.includes("invalid_submission") ||
      error.message.includes("invalid_request")
    ) {
      return jsonResponse(origin, 400, { error: "validation_failed" });
    }
    return jsonResponse(origin, 503, { error: "service_unavailable" });
  }

  const receipt = Array.isArray(data) ? data[0] : data;
  if (
    !receipt ||
    typeof receipt.confirmation_code !== "string" ||
    !/^YNF-[A-F0-9]{12}$/.test(receipt.confirmation_code) ||
    typeof receipt.created_at !== "string"
  ) {
    return jsonResponse(origin, 503, { error: "confirmation_unavailable" });
  }

  return jsonResponse(origin, 201, {
    confirmationId: receipt.confirmation_code,
    createdAt: receipt.created_at,
  });
});
