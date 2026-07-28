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
    "create table if not exists public.business_inquiries",
    "add column if not exists inquiry_type text",
    "id, reference_code, contact_person, company_name, email, phone, website",
    "private.business_inquiry_rate_limits",
    "grant update (status, admin_notes, handled_by) on table public.business_inquiries to authenticated",
    "business_inquiries enable row level security",
    "feedback_rate_limits enable row level security",
    "published_content_artifacts enable row level security",
    "request_content_sync",
    "enqueue_article_publication",
    "create or replace function private.current_admin_role()",
    "create or replace function private.is_approved_admin()",
    "set search_path = ''",
    "revoke execute on functions from anon, authenticated, service_role",
    "revoke select, insert, update, delete on tables from anon, authenticated, service_role",
    "revoke usage, select on sequences from anon, authenticated, service_role",
    "revoke all on function public.submit_business_inquiry(jsonb, text) from public, anon, authenticated",
    "revoke all on function public.submit_public_feedback(jsonb, text) from public, anon, authenticated"
  ]) {
    assert.match(sql, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "i"));
  }
  assert.doesNotMatch(sql, /grant execute on function public\.submit_(?:business_inquiry|public_feedback).* to anon/i);
  assert.doesNotMatch(sql, /create table public\.business_inquiries\s*\(/i);
  assert.doesNotMatch(sql, /public\.business_inquiry_rate_limits/i);
});

test("workspace handoff endpoint is private and never uses a service-role browser credential", async () => {
  const source = await readFile(new URL("../src/app/api/workspace/status/route.ts", import.meta.url), "utf8");
  assert.match(source, /authorization\?\.startsWith\("Bearer "\)/);
  assert.match(source, /X-Robots-Tag/);
  assert.match(source, /no-store, private/);
  assert.doesNotMatch(source, /SUPABASE_SERVICE_ROLE_KEY|service_role/);
});

test("Admin business fields match the deployed production contract", async () => {
  const sources = await Promise.all([
    "../src/app/(admin)/business-inquiries/actions.ts",
    "../src/app/(admin)/business-inquiries/[id]/page.tsx",
    "../src/app/(admin)/business-inquiries/export/route.ts",
    "../src/components/admin/business-inquiry-list.tsx",
    "../src/app/api/workspace/status/route.ts"
  ].map((path) => readFile(new URL(path, import.meta.url), "utf8")));
  const source = sources.join("\n");

  for (const required of [
    "reference_code",
    "company_name",
    "contact_person",
    "admin_notes",
    "reviewing",
    "responded",
    "accepted",
    "declined",
    "archived"
  ]) assert.match(source, new RegExp(required));
  assert.doesNotMatch(source, /confirmation_code|contact_name|work_email|internal_note/);
});

test("Admin content activation exposes only a reviewed active feed", async () => {
  const [migration, route, action, middleware] = await Promise.all([
    readFile(new URL("../supabase/migrations/20260728212059_activate_public_content_feed.sql", import.meta.url), "utf8"),
    readFile(new URL("../src/app/api/public/content-sync/route.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/sync/actions.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/middleware.ts", import.meta.url), "utf8")
  ]);

  for (const required of [
    "create table if not exists public.public_content_feed",
    "public_content_feed enable row level security",
    "revoke all on table public.public_content_feed from public, anon, authenticated",
    "grant select on table public.public_content_feed to anon, authenticated",
    "create or replace function public.activate_content_artifact",
    "private.current_admin_role()",
    "empty_content_artifact_not_activatable",
    "content_artifact_record_count_mismatch",
    "content_artifact_activated",
    "status = 'superseded'",
    "status = 'active'"
  ]) assert.match(migration, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "i"));

  assert.match(route, /\.from\("public_content_feed"\)/);
  assert.match(route, /buildPublicContentFeed/);
  assert.match(route, /Access-Control-Allow-Origin/);
  assert.match(route, /https:\/\/younew\.nl/);
  assert.match(route, /If-None-Match/i);
  assert.doesNotMatch(route, /SUPABASE_SERVICE_ROLE_KEY|service_role/);
  assert.match(action, /\.rpc\("activate_content_artifact"/);
  assert.match(middleware, /isPublicApi[\s\S]*if \(isPublicApi\) return NextResponse\.next\(\)/);
});
