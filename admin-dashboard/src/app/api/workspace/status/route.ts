import { createClient } from "@supabase/supabase-js";

export const dynamic = "force-dynamic";

const responseHeaders = {
  "Cache-Control": "no-store, private",
  "Content-Type": "application/json; charset=utf-8",
  "X-Content-Type-Options": "nosniff",
  "X-Robots-Tag": "noindex, nofollow"
};

function json(status: number, payload: Record<string, unknown>) {
  return Response.json(payload, { status, headers: responseHeaders });
}

export async function GET(request: Request) {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  const authorization = request.headers.get("authorization");
  if (!supabaseUrl || !anonKey) return json(503, { error: "service_unavailable" });
  if (!authorization?.startsWith("Bearer ")) return json(401, { error: "authentication_required" });

  const supabase = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { autoRefreshToken: false, persistSession: false }
  });
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData.user) return json(401, { error: "invalid_session" });

  const { data: profile } = await supabase
    .from("profiles")
    .select("role,is_approved")
    .eq("id", userData.user.id)
    .maybeSingle();
  if (
    !profile?.is_approved ||
    (profile.role !== "owner" && profile.role !== "admin")
  ) {
    return json(403, { error: "forbidden" });
  }

  const [
    inquiries,
    feedback,
    failedSync,
    reviewContent,
    brokenLinks,
    latestSync,
    latestDeployment,
    currentRelease,
    serviceStatuses
  ] = await Promise.all([
    supabase.from("business_inquiries").select("id", { count: "exact", head: true }).in("status", ["new", "contacted", "qualified"]),
    supabase.from("feedback").select("id", { count: "exact", head: true }).in("status", ["new", "reviewed", "planned"]),
    supabase.from("sync_jobs").select("id", { count: "exact", head: true }).eq("status", "failed"),
    supabase.from("articles").select("id", { count: "exact", head: true }).in("status", ["draft", "research", "review", "qa", "needs_review"]),
    supabase.from("official_links").select("id", { count: "exact", head: true }).eq("status", "broken"),
    supabase.from("sync_jobs").select("id,type,status,completed_at,artifact_fingerprint,error_summary").order("created_at", { ascending: false }).limit(1).maybeSingle(),
    supabase.from("deployment_status").select("id,service_id,environment,status,commit_sha,artifact_fingerprint,deployed_at,error_summary").order("created_at", { ascending: false }).limit(1).maybeSingle(),
    supabase.from("releases").select("version,platform,status,release_date").order("created_at", { ascending: false }).limit(1).maybeSingle(),
    supabase.from("service_status").select("service_id,status,checked_at,public_message").order("checked_at", { ascending: false }).limit(50)
  ]);

  const results = [inquiries, feedback, failedSync, reviewContent, brokenLinks, latestSync, latestDeployment, currentRelease, serviceStatuses];
  if (results.some((result) => result.error)) {
    return json(503, {
      schemaVersion: 1,
      status: "degraded",
      checkedAt: new Date().toISOString(),
      error: "operational_data_unavailable"
    });
  }

  return json(200, {
    schemaVersion: 1,
    visibility: "private",
    refresh: "manual",
    checkedAt: new Date().toISOString(),
    counters: {
      openInquiries: inquiries.count ?? 0,
      openFeedback: feedback.count ?? 0,
      failedSyncJobs: failedSync.count ?? 0,
      contentNeedingReview: reviewContent.count ?? 0,
      brokenLinks: brokenLinks.count ?? 0
    },
    latestContentSync: latestSync.data,
    latestDeployment: latestDeployment.data,
    currentRelease: currentRelease.data,
    services: serviceStatuses.data ?? []
  });
}
