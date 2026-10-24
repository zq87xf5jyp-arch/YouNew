import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migrationUrl = new URL(
  "../supabase/migrations/20260728192120_younew_production_operations.sql",
  import.meta.url
);

test("production migration contains publication, submission, RLS and sync gates", async () => {
  const sql = await readFile(migrationUrl, "utf8");
  for (const required of [
    "enforce_article_publication_gate",
    "submit_business_inquiry",
    "submit_public_feedback",
    "business_inquiries enable row level security",
    "feedback_rate_limits enable row level security",
    "published_content_artifacts enable row level security",
    "request_content_sync",
    "enqueue_article_publication",
    "revoke all on function public.submit_business_inquiry(jsonb, text) from public, anon, authenticated",
    "revoke all on function public.submit_public_feedback(jsonb, text) from public, anon, authenticated"
  ]) {
    assert.match(sql, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "i"));
  }
  assert.doesNotMatch(sql, /grant execute on function public\.submit_(?:business_inquiry|public_feedback).* to anon/i);
});

test("workspace handoff endpoint is private and never uses a service-role browser credential", async () => {
  const source = await readFile(new URL("../src/app/api/workspace/status/route.ts", import.meta.url), "utf8");
  assert.match(source, /authorization\?\.startsWith\("Bearer "\)/);
  assert.match(source, /X-Robots-Tag/);
  assert.match(source, /no-store, private/);
  assert.match(source, /official_link_operational_latest/);
  assert.match(source, /brokenLinks: linkHealthSourceState === "available" \? freshBrokenLinks : null/);
  assert.doesNotMatch(source, /SUPABASE_SERVICE_ROLE_KEY|service_role/);
});

test("admin responses enforce a bounded CSP and transport security", async () => {
  const nextConfig = await readFile(new URL("../next.config.ts", import.meta.url), "utf8");
  const policy = await readFile(new URL("../src/lib/security-policy.ts", import.meta.url), "utf8");
  const layout = await readFile(new URL("../src/app/layout.tsx", import.meta.url), "utf8");
  const { adminScriptSourceDirective } = await import("../src/lib/security-policy.ts");
  for (const required of [
    "default-src 'self'",
    "frame-ancestors 'none'",
    "object-src 'none'",
    "connect-src 'self' https://*.supabase.co wss://*.supabase.co"
  ]) {
    assert.match(policy, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
  }
  for (const required of [
    "Content-Security-Policy",
    "ADMIN_CONTENT_SECURITY_POLICY",
    "Strict-Transport-Security",
    "Cross-Origin-Opener-Policy"
  ]) {
    assert.match(nextConfig, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
  }
  assert.match(layout, /httpEquiv="Content-Security-Policy"/);
  assert.match(layout, /ADMIN_META_CONTENT_SECURITY_POLICY/);
  assert.doesNotMatch(policy, /script-src[^"\n]*https?:\/\/(?!\*\.supabase\.co)/);
  assert.match(adminScriptSourceDirective("development"), /'unsafe-eval'/);
  assert.doesNotMatch(adminScriptSourceDirective("production"), /'unsafe-eval'/);
});

test("release control uses one fail-closed deterministic truth snapshot", async () => {
  const component = await readFile(
    new URL("../src/components/admin/release-readiness-overview.tsx", import.meta.url),
    "utf8"
  );
  const truth = JSON.parse(
    await readFile(new URL("../src/generated/release-truth.json", import.meta.url), "utf8")
  ) as {
    schemaVersion: number;
    snapshotDigest: string;
    candidateCommit: string;
    sourceTreeState: string;
    technicalVerdict: string;
    deploymentAuthorization: string;
    publication: {
      inventory: { total: number };
      packaged: { entityCount: number };
      deployed: { state: string; entityCount: number | null; declaredEntityCount: number | null };
    };
    metrics: { linkHealth: { state: string; value: number | null; denominator: number | null } };
    gates: Record<string, { result: string }>;
  };

  assert.equal(truth.schemaVersion, 2);
  assert.match(truth.snapshotDigest, /^[a-f0-9]{64}$/);
  assert.match(truth.candidateCommit, /^[a-f0-9]{40}$/);
  assert.ok(["clean", "dirty"].includes(truth.sourceTreeState));
  assert.equal(truth.technicalVerdict, "PARTIAL");
  assert.equal(truth.deploymentAuthorization, "not_granted");
  assert.equal(truth.publication.inventory.total, 454);
  assert.equal(truth.publication.packaged.entityCount, 7);
  assert.equal(truth.publication.deployed.state, "unknown");
  assert.equal(truth.publication.deployed.entityCount, null);
  assert.equal(truth.publication.deployed.declaredEntityCount, null);
  assert.deepEqual(truth.metrics.linkHealth, {
    kind: "ratio",
    unit: "percent",
    value: null,
    numerator: null,
    denominator: null,
    state: "unknown",
    reasonCode: "network_check_not_run",
    formula: { id: "reachable-links-over-inspected-links", version: 1 },
    sourceIDs: ["link-health"]
  });
  assert.equal(truth.gates.linkHealth.result, "blocked");
  assert.match(component, /releaseTruth\.technicalVerdict/);
  assert.match(component, /production не разрешён/);
  assert.doesNotMatch(component, /GO LIVE завершён|full_product_live/);
});
