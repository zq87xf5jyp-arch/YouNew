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

test("release control reflects the verified GO LIVE evidence", async () => {
  const component = await readFile(
    new URL("../src/components/admin/release-readiness-overview.tsx", import.meta.url),
    "utf8"
  );
  const readiness = JSON.parse(
    await readFile(new URL("../src/generated/release-readiness.json", import.meta.url), "utf8")
  ) as {
    posture: string;
    evidence: {
      admin: { tests_passed: number; deployment_status: string; csp_enforcement: string };
      supabase: { backup_restore_evidence: string; temporary_access_revoked: boolean };
      ios: {
        app_store_distribution: string;
        app_review: string;
        public_release: string;
        public_release_source: string;
        physical_device_install: string;
        physical_device_launch: string;
        physical_device_process_health: string;
      };
    };
    remaining_items: Array<{ id: string }>;
  };

  assert.equal(readiness.posture, "full_product_live");
  assert.equal(readiness.evidence.admin.tests_passed, 29);
  assert.equal(readiness.evidence.admin.deployment_status, "live");
  assert.equal(readiness.evidence.admin.csp_enforcement, "upstream_header_plus_html_meta_fallback");
  assert.equal(readiness.evidence.supabase.backup_restore_evidence, "pass");
  assert.equal(readiness.evidence.supabase.temporary_access_revoked, true);
  assert.equal(readiness.evidence.ios.app_store_distribution, "pass");
  assert.equal(readiness.evidence.ios.app_review, "approved_and_released");
  assert.equal(readiness.evidence.ios.public_release, "live");
  assert.equal(readiness.evidence.ios.public_release_source, "apple_lookup_api_country_nl");
  assert.equal(readiness.evidence.ios.physical_device_install, "pass");
  assert.equal(readiness.evidence.ios.physical_device_launch, "pass");
  assert.equal(readiness.evidence.ios.physical_device_process_health, "running_after_30_seconds");
  assert.match(component, /readiness\.evidence\.ios\.release_status_label/);
  assert.match(component, /readiness\.evidence\.ios\.release_note/);
  assert.doesNotMatch(component, /Waiting for Review|installed on iPhone/);
  assert.deepEqual(readiness.remaining_items.map((item) => item.id), [
    "storage-backup-automation",
    "guide-depth"
  ]);
});
