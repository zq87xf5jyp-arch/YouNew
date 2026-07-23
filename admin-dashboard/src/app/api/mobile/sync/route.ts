import { buildMobileSyncPayload, requestMatchesCurrentVersion } from "@/lib/mobile-sync";

const cacheControl = "public, max-age=0, s-maxage=300, stale-while-revalidate=3600";

export async function GET(request: Request) {
  const snapshot = buildMobileSyncPayload();
  const headers = {
    "Cache-Control": cacheControl,
    "Content-Type": "application/json; charset=utf-8",
    ETag: snapshot.etag,
    "X-Content-Type-Options": "nosniff",
    "X-YouNew-Dataset-Fingerprint": snapshot.contentVersion
  };

  if (requestMatchesCurrentVersion(request.headers.get("if-none-match"))) {
    return new Response(null, { status: 304, headers });
  }

  return new Response(snapshot.body, { status: 200, headers });
}
