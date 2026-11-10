import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

import {
  canAccessPath,
  canEditArticle,
  canEditContent,
  canManageSettings,
  canApproveTrustPublication,
  canVerifyContent,
  canWorkReviewQueue,
  canPublishContent,
  canRequestSync,
  resolveLocalDemoAdminRole,
  routePolicies
} from "../src/lib/authorization.ts";
import { canTrustAction, nextTrustTransition, trustRequest } from "../src/lib/trust-workflow.ts";
import {
  CONTENT_IMAGE_CLEANUP_CANDIDATE_LIMIT,
  isManagedContentImagePath
} from "../src/lib/content-images.ts";

const [actions, manager, uploader, browserStorage, adminStorage, syncActions, trustActions, trustPage, articleMigration, storageMigration, reviewMigration, pgTap] =
  await Promise.all([
    readFile(new URL("../src/app/(admin)/content/actions.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/components/admin/content-manager.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/components/admin/content-image-uploader.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/lib/supabase/content-image-storage.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/lib/supabase/admin.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/sync/actions.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/trust/actions.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/trust/page.tsx", import.meta.url), "utf8"),
    readFile(new URL("../supabase/migrations/20260819124835_harden_editor_published_articles.sql", import.meta.url), "utf8"),
    readFile(new URL("../supabase/migrations/20260819124836_harden_content_image_storage.sql", import.meta.url), "utf8"),
    readFile(new URL("../supabase/migrations/20260819132519_align_review_task_closure_with_publication_v2.sql", import.meta.url), "utf8"),
    readFile(new URL("../supabase/tests/admin_content_security_test.sql", import.meta.url), "utf8")
  ]);
const contentPage = await readFile(new URL("../src/app/(admin)/content/page.tsx", import.meta.url), "utf8");

test("Admin route registry and Trust mutation permissions agree", () => {
  const expectedRoutes = [
    "/dashboard", "/analytics", "/finance", "/sync", "/trust", "/content",
    "/business-inquiries", "/categories", "/cities", "/map", "/visual-qa",
    "/bugs", "/releases", "/links", "/ai-knowledge", "/feedback", "/settings", "/audit-log"
  ];
  assert.equal(expectedRoutes.length, 18);
  assert.deepEqual(routePolicies.map((policy) => policy.prefix).sort(), [...expectedRoutes].sort());
  assert.equal(new Set(routePolicies.map((policy) => policy.prefix)).size, expectedRoutes.length);
  for (const role of ["owner", "admin", "editor", "qa", "viewer"] as const) {
    assert.equal(canAccessPath(role, "/finance"), role === "owner");
    assert.equal(canAccessPath(role, "/finance/details"), role === "owner");
  }
  for (const role of ["owner", "admin"] as const) {
    for (const policy of routePolicies) assert.equal(canAccessPath(role, policy.prefix), role === "owner" || policy.prefix !== "/finance");
    assert.equal(canPublishContent(role), true);
    assert.equal(canApproveTrustPublication(role), true);
    assert.equal(canRequestSync(role), true);
    assert.equal(canManageSettings(role), true);
  }
  assert.equal(canEditContent("editor"), true);
  assert.equal(canEditArticle("editor", "draft"), true);
  assert.equal(canEditArticle("editor", "review", "qa"), true);
  assert.equal(canEditArticle("editor", "research"), false);
  assert.equal(canEditArticle("editor", "needs_review"), false);
  assert.equal(canEditArticle("editor", "archived"), false);
  assert.equal(canEditArticle("editor", "published"), false);
  assert.equal(canEditArticle("qa", "draft"), false);
  assert.equal(canManageSettings("editor"), false);
  assert.equal(canAccessPath("owner", "/unregistered-admin-surface"), false);
  assert.equal(resolveLocalDemoAdminRole("editor"), "editor");
  assert.equal(resolveLocalDemoAdminRole("admin"), "owner");
  assert.equal(resolveLocalDemoAdminRole(undefined), "owner");
  assert.match(syncActions, /canRequestSync/);
  assert.match(trustActions, /canTrustAction\(admin\.role/);
  for (const role of ["owner", "admin", "editor", "qa", "viewer"] as const) {
    assert.equal(canTrustAction(role, "publish"), canApproveTrustPublication(role));
    assert.equal(canTrustAction(role, "verify"), canVerifyContent(role));
    assert.equal(canTrustAction(role, "transition", "assigned"), canWorkReviewQueue(role));
    assert.equal(canTrustAction(role, "transition", "approved"), canVerifyContent(role));
  }
});

test("content actions authorize the stored status and clean images only after a guarded mutation", () => {
  assert.match(actions, /select\("status,images,updated_at"\)/);
  assert.match(actions, /canEditArticle\(admin\.role, String\((?:current|article)\.status\)\)/);
  assert.match(actions, /\.eq\("status", (?:current|article)\.status\)/);
  assert.match(actions, /\.eq\("updated_at", (?:current|article)\.updated_at\)/);
  assert.match(actions, /content_image_paths_in_use/);
  assert.match(actions, /createSupabaseAdminClient/);
  assert.match(actions, /normalizeCleanupCandidatePaths/);
  assert.match(actions, /CONTENT_IMAGE_CLEANUP_CANDIDATE_LIMIT/);
  assert.match(actions, /CONTENT_IMAGE_CLEANUP_BATCH_LIMIT/);
  assert.match(actions, /isManagedContentImagePath/);
  assert.match(actions, /export async function createArticle\(input: ArticleInput, cleanupCandidatePaths: unknown = \[\]\)/);
  assert.match(actions, /export async function updateArticle\(id: string, input: ArticleInput, cleanupCandidatePaths: unknown = \[\]\)/);
  assert.match(actions, /await removeUnreferencedContentImages\([\s\S]*normalizeCleanupCandidatePaths\(cleanupCandidatePaths\)[\s\S]*\)/);
  assert.match(actions, /\.\.\.normalizeCleanupCandidatePaths\(cleanupCandidatePaths\)/);
  assert.match(actions, /await removeUnreferencedContentImages\(paths\)/);
  assert.match(actions, /const removablePaths = paths\.filter\(\(path\) => !referencedPaths\.has\(path\)\)/);
  assert.match(actions, /\.remove\(removablePaths\)/);
  assert.match(actions, /candidatePaths\.slice\(0, limit\)\.filter\(isManagedContentImagePath\)/);
  assert.match(actions, /canEditArticle\(admin\.role, String\(current\.status\), input\.status\)/);
  assert.match(actions, /if \(input\.status === "published"\)/);
  assert.doesNotMatch(actions, /preservePublicationEvidence/);
  assert.match(manager, /requiresFreshReview \? "review" : article\.status/);
  assert.match(manager, /updateArticle\(editingId, draft, cleanupCandidatePaths\)/);
  assert.match(manager, /createArticle\(draft, cleanupCandidatePaths\)/);
  assert.match(manager, /setCleanupCandidatePaths\(\[\]\)/);
  assert.match(uploader, /onRemove\(image, persistedPaths\.includes\(image\.path\)\)/);

  const createSection = actions.slice(actions.indexOf("export async function createArticle"), actions.indexOf("export async function updateArticle"));
  const updateSection = actions.slice(actions.indexOf("export async function updateArticle"), actions.indexOf("export async function deleteArticle"));
  assert.ok(createSection.indexOf("if (error) throw") < createSection.indexOf("await removeUnreferencedContentImages"));
  assert.ok(updateSection.indexOf("if (error) throw") < updateSection.indexOf("await removeUnreferencedContentImages"));
});

test("content-image cleanup candidates are bounded to generated article paths", () => {
  assert.equal(CONTENT_IMAGE_CLEANUP_CANDIDATE_LIMIT, 24);
  assert.equal(isManagedContentImagePath("articles/article-123/1770000000000-uuid-cover.webp"), true);
  assert.equal(isManagedContentImagePath("articles/article-123/.hidden.webp"), false);
  assert.equal(isManagedContentImagePath("articles/article-123/nested/cover.webp"), false);
  assert.equal(isManagedContentImagePath("articles/article-123/cover.jpg"), false);
  assert.equal(isManagedContentImagePath("../content-images/cover.webp"), false);
  assert.equal(isManagedContentImagePath("articles/article-123/" + "a".repeat(221) + ".webp"), false);
});

test("content query failures disable mutations instead of becoming a green empty source", () => {
  assert.match(contentPage, /queryResult\.error/);
  assert.match(contentPage, /sourceState[\s\S]*"forbidden"/);
  assert.match(contentPage, /canEdit=\{canEditContent\(admin\.role\) && \(dataMode === "supabase" \|\| dataMode === "demo"\)\}/);
  assert.match(manager, /dataMode === "forbidden" \? "Supabase: доступ запрещён"/);
  assert.match(manager, /Редактирование заблокировано/);
});

test("browser image code cannot issue Storage DELETE and the UI hides published controls from editors", () => {
  assert.doesNotMatch(browserStorage, /\.remove\s*\(/);
  assert.doesNotMatch(uploader, /removeContentImage/);
  assert.match(adminStorage, /^import "server-only";/);
  assert.match(manager, /Браузер не удаляет Storage-объект/);
  assert.match(manager, /canManagePublished \|\| canEditorManageArticleStatus\(row\.status\)/);
  assert.match(manager, /Только Owner\/Admin/);
});

test("database hardening separates draft editing from published authority", () => {
  assert.match(articleMigration, /array\['draft'::public\.publication_status, 'review'::public\.publication_status, 'qa'::public\.publication_status\]/);
  assert.match(articleMigration, /create policy "content admins update articles"/);
  assert.match(articleMigration, /create policy "content admins delete articles"/);
  assert.doesNotMatch(articleMigration, /storage\.objects/);
  assert.match(storageMigration, /private\.content_image_is_published\(name\)/);
  assert.match(storageMigration, /drop policy if exists "editors delete content images"/);
  assert.doesNotMatch(storageMigration, /create policy "editors delete content images"/);
  assert.match(storageMigration, /grant execute on function public\.content_image_paths_in_use\(text\[\]\)\s+to service_role/i);
  assert.match(storageMigration, /security invoker/i);
});

test("approved review tasks can close only through explicit publication approval", () => {
  assert.doesNotMatch(trustPage, /state === "approved"[^\n]+"closed"/);
  assert.equal(nextTrustTransition("approved"), null);
  const invalidClosure = new FormData();
  for (const [key, value] of Object.entries({
    idempotencyKey: "77000000-0000-4000-8000-000000000001", recordKey: "synthetic:closure",
    expectedVersion: "1", reason: "Synthetic closure denial", taskID: "77000000-0000-4000-8000-000000000002",
    expectedState: "approved", toState: "closed", expectedUpdatedAt: "2026-09-20T04:00:00.000001Z"
  })) invalidClosure.set(key, value);
  assert.equal(trustRequest(invalidClosure, "transition", "77000000-0000-4000-8000-000000000003"), null);
  assert.doesNotMatch(reviewMigration, /p_expected_state = 'approved'\s+and p_to_state = 'closed'/);
  assert.doesNotMatch(reviewMigration, /when 'closed' then 'closed'/);
  assert.doesNotMatch(reviewMigration, /resolved_at = case when p_to_state = 'closed'/);
  assert.match(reviewMigration, /transition_review_task:v2/);
  assert.match(pgTap, /select plan\(37\)/i);
  assert.match(pgTap, /editor cannot update a published article/i);
  assert.match(pgTap, /admin cannot close an approved task through the generic transition/i);
});
