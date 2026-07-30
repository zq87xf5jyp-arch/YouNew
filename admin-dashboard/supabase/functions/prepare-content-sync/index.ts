import { createClient } from "@supabase/supabase-js";
import {
  buildPublishedContentArtifact,
  fingerprintArtifact,
  type PublishedArticleRecord,
} from "./artifact.ts";

const jsonHeaders = {
  "Cache-Control": "no-store",
  "Content-Type": "application/json; charset=utf-8",
  "X-Content-Type-Options": "nosniff",
};

function response(status: number, payload: Record<string, unknown>) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: jsonHeaders,
  });
}

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return response(405, { error: "method_not_allowed" });
  }
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const authorization = request.headers.get("authorization");
  if (!supabaseUrl || !anonKey || !serviceRoleKey || !authorization) {
    return response(503, { error: "service_unavailable" });
  }

  let payload: unknown;
  try {
    payload = await request.json();
  } catch {
    return response(400, { error: "invalid_json" });
  }
  const jobId = typeof payload === "object" && payload !== null &&
      "jobId" in payload && typeof payload.jobId === "string" &&
      /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
        .test(payload.jobId)
    ? payload.jobId
    : null;
  if (!jobId) return response(400, { error: "invalid_job" });

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser();
  if (userError || !userData.user) {
    return response(401, { error: "unauthorized" });
  }

  const service = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data: profile } = await service
    .from("profiles")
    .select("role,is_approved")
    .eq("id", userData.user.id)
    .maybeSingle();
  if (
    !profile?.is_approved ||
    (profile.role !== "owner" && profile.role !== "admin")
  ) {
    return response(403, { error: "forbidden" });
  }

  const { data: job } = await service
    .from("sync_jobs")
    .select("id,status,type,initiator")
    .eq("id", jobId)
    .maybeSingle();
  if (
    !job ||
    job.type !== "content_artifact_candidate" ||
    job.initiator !== userData.user.id
  ) {
    return response(404, { error: "job_not_found" });
  }
  if (job.status === "succeeded") {
    return response(200, { jobId, status: "succeeded", idempotent: true });
  }
  if (job.status !== "queued" && job.status !== "failed") {
    return response(409, { error: "job_not_runnable" });
  }

  const startedAt = new Date().toISOString();
  await service.from("sync_jobs").update({
    status: "running",
    started_at: startedAt,
    completed_at: null,
    error_summary: null,
  }).eq("id", jobId);

  try {
    const { data, error } = await service
      .from("articles")
      .select(
        "id,title,slug,short_description,full_content,language,source_url,verified_date,updated_at,published_at,category_id,categories(slug)",
      )
      .eq("status", "published")
      .order("id");
    if (error) throw new Error("published_content_read_failed");

    const artifact = buildPublishedContentArtifact(
      (data ?? []) as unknown as PublishedArticleRecord[],
    );
    const fingerprint = await fingerprintArtifact(artifact);
    const { error: artifactError } = await service
      .from("published_content_artifacts")
      .upsert({
        source_version: artifact.sourceVersion,
        artifact,
        artifact_fingerprint: fingerprint,
        record_count: artifact.recordCount,
        status: "candidate",
        created_by: userData.user.id,
      }, {
        onConflict: "artifact_fingerprint",
        ignoreDuplicates: true,
      });
    if (artifactError) throw new Error("candidate_write_failed");

    const completedAt = new Date().toISOString();
    await service.from("sync_jobs").update({
      status: "succeeded",
      completed_at: completedAt,
      target_version: artifact.sourceVersion,
      records_processed: artifact.recordCount,
      records_failed: 0,
      artifact_fingerprint: fingerprint,
      duration_ms: Math.max(0, Date.parse(completedAt) - Date.parse(startedAt)),
      details: {
        candidate_only: true,
        activation: "manual",
        production_replacement_allowed: false,
      },
    }).eq("id", jobId);

    return response(200, {
      jobId,
      status: "succeeded",
      recordCount: artifact.recordCount,
      fingerprint,
      activation: "manual",
    });
  } catch (error) {
    const summary = error instanceof Error
      ? error.message.slice(0, 180)
      : "content_sync_failed";
    await service.from("sync_jobs").update({
      status: "failed",
      completed_at: new Date().toISOString(),
      records_failed: 1,
      error_summary: summary,
    }).eq("id", jobId);
    return response(503, { error: "content_sync_failed", jobId });
  }
});
