import { canonicalMap } from "@/lib/canonical-admin-data";

const etag = `"${canonicalMap.datasetFingerprint}"`;
const headers = {
  "Cache-Control": "public, s-maxage=300, stale-while-revalidate=3600",
  ETag: etag,
  "X-Content-Type-Options": "nosniff"
};

export async function GET(request: Request) {
  if (request.headers.get("if-none-match") === etag) return new Response(null, { status: 304, headers });
  return Response.json({
    data: canonicalMap.points,
    generated_at: canonicalMap.generatedAt,
    dataset_fingerprint: canonicalMap.datasetFingerprint,
    source: "packaged_governed_content_and_official_municipality_registry"
  }, { headers });
}
