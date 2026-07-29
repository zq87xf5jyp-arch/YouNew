import { NextResponse } from "next/server";
import {
  buildPublicContentFeed,
  emptyPublicContentFeed,
  type PublicContentFeedPayload
} from "@/lib/content-sync-feed";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const publicSiteOrigin = "https://younew.nl";
const allowedOrigins = new Set([
  publicSiteOrigin,
  "http://localhost:3000",
  "http://127.0.0.1:3000",
  "http://localhost:3001",
  "http://127.0.0.1:3001"
]);

function corsHeaders(origin: string | null) {
  const headers = new Headers({
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Access-Control-Allow-Headers": "Accept, If-None-Match",
    "Access-Control-Max-Age": "86400",
    "Vary": "Origin",
    "X-Content-Type-Options": "nosniff"
  });
  if (process.env.NODE_ENV === "production") {
    // Hostinger CDN does not reliably preserve Vary: Origin on cached responses.
    // The public feed has one canonical production consumer, so emit its origin
    // on every production response and keep rejecting other Origin requests.
    headers.set("Access-Control-Allow-Origin", publicSiteOrigin);
  } else if (origin && allowedOrigins.has(origin)) {
    headers.set("Access-Control-Allow-Origin", origin);
  }
  return headers;
}

function forbiddenOrigin(request: Request) {
  const origin = request.headers.get("origin");
  return origin !== null && !allowedOrigins.has(origin);
}

function jsonResponse(
  request: Request,
  payload: PublicContentFeedPayload | { error: string },
  status: number,
  cacheControl: string
) {
  const headers = corsHeaders(request.headers.get("origin"));
  headers.set("Cache-Control", cacheControl);
  return NextResponse.json(payload, { status, headers });
}

export async function OPTIONS(request: Request) {
  if (forbiddenOrigin(request)) {
    return new NextResponse(null, {
      status: 403,
      headers: corsHeaders(request.headers.get("origin"))
    });
  }
  return new NextResponse(null, {
    status: 204,
    headers: corsHeaders(request.headers.get("origin"))
  });
}

export async function GET(request: Request) {
  if (forbiddenOrigin(request)) {
    return jsonResponse(request, { error: "Origin is not allowed." }, 403, "no-store");
  }

  const supabase = await createSupabaseServerClient();
  if (!supabase) {
    return jsonResponse(request, { error: "Content sync is temporarily unavailable." }, 503, "no-store");
  }

  const { data, error } = await supabase
    .from("public_content_feed")
    .select("source_version, artifact, artifact_fingerprint, record_count, activated_at")
    .eq("feed_key", "active")
    .maybeSingle();

  if (error) {
    return jsonResponse(request, { error: "Content sync is temporarily unavailable." }, 503, "no-store");
  }
  if (!data) {
    return jsonResponse(
      request,
      emptyPublicContentFeed(),
      200,
      "public, s-maxage=60, stale-while-revalidate=300"
    );
  }

  let payload: PublicContentFeedPayload;
  try {
    payload = buildPublicContentFeed(data);
  } catch {
    return jsonResponse(request, { error: "Active content failed validation." }, 503, "no-store");
  }

  const etag = `"${payload.available ? payload.fingerprint : "empty"}"`;
  const headers = corsHeaders(request.headers.get("origin"));
  headers.set("Cache-Control", "public, s-maxage=60, stale-while-revalidate=300");
  headers.set("ETag", etag);
  if (payload.available) {
    headers.set("X-YouNew-Content-Fingerprint", payload.fingerprint);
  }
  if (request.headers.get("if-none-match") === etag) {
    return new NextResponse(null, { status: 304, headers });
  }
  return NextResponse.json(payload, { status: 200, headers });
}
