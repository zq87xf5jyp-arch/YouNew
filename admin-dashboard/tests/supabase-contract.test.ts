import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migrationUrl = new URL(
  "../supabase/migrations/20260728075522_younew_production_operations.sql",
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
  const source = await readFile(new URL("../next.config.ts", import.meta.url), "utf8");
  for (const required of [
    "Content-Security-Policy",
    "default-src 'self'",
    "frame-ancestors 'none'",
    "object-src 'none'",
    "connect-src 'self' https://*.supabase.co wss://*.supabase.co",
    "Strict-Transport-Security",
    "Cross-Origin-Opener-Policy"
  ]) {
    assert.match(source, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
  }
  assert.doesNotMatch(source, /script-src[^"\n]*https?:\/\/(?!\*\.supabase\.co)/);
});
