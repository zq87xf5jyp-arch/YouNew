import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import test from "node:test";

import { assembleOperationalTruth } from "../src/lib/release-truth/operational-classification.ts";

const readJSON = async (url: URL) => JSON.parse(await readFile(url, "utf8"));
const adminTruth = await readJSON(new URL("../src/generated/release-truth.json", import.meta.url));
const publicTruth = await readJSON(new URL("../public-site/src/generated/release-truth-public.json", import.meta.url));
const map = await readJSON(new URL("../src/generated/canonical-map-points.json", import.meta.url));
const links = await readJSON(new URL("../src/generated/canonical-official-links.json", import.meta.url));

test("release-truth digest binds the full snapshot and public projection", () => {
  const digestPayload = { ...adminTruth };
  delete digestPayload.snapshotID;
  delete digestPayload.snapshotDigest;
  const digest = createHash("sha256").update(JSON.stringify(digestPayload)).digest("hex");
  assert.equal(adminTruth.snapshotDigest, digest);
  assert.equal(adminTruth.snapshotID, `release-truth.${digest.slice(0, 16)}`);
  assert.equal(publicTruth.snapshotID, adminTruth.snapshotID);
  assert.equal(publicTruth.snapshotDigest, adminTruth.snapshotDigest);
  assert.match(adminTruth.candidateCommit, /^[a-f0-9]{40}$/);
  assert.deepEqual([...adminTruth.sourceTreeExclusions].sort(), [
    "admin-dashboard/public-site/src/generated/release-truth-public.json",
    "admin-dashboard/public-site/src/generated/trust-dashboard.json",
    "admin-dashboard/src/generated/release-readiness.json",
    "admin-dashboard/src/generated/release-truth.json",
    "admin-dashboard/src/generated/trust-dashboard.json"
  ]);
});

test("release truth stays PARTIAL when candidate evidence is incomplete", () => {
  assert.equal(adminTruth.technicalVerdict, "PARTIAL");
  assert.equal(adminTruth.deploymentAuthorization, "not_granted");
  assert.equal(adminTruth.gates.candidateCI.result, "blocked");
  assert.equal(adminTruth.gates.linkHealth.result, "blocked");
  assert.equal(adminTruth.gates.legacyCompatibilityArtifacts.result, "pass");
  assert.equal(adminTruth.metrics.linkHealth.state, "unknown");
  assert.equal(adminTruth.metrics.linkHealth.value, null);
  assert.equal(adminTruth.metrics.linkHealth.denominator, null);
  if (adminTruth.sourceTreeState === "dirty") {
    assert.ok(adminTruth.limitations.some((item: string) => item.includes("uncommitted source-tree changes")));
  }
});

test("Dashboard, Trust, Releases and public Trust consume only shared release truth", async () => {
  const consumers = await Promise.all([
    readFile(new URL("../src/app/(admin)/dashboard/page.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/trust/page.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/releases/page.tsx", import.meta.url), "utf8"),
    readFile(new URL("../public-site/src/components/knowledge-trust-summary.tsx", import.meta.url), "utf8")
  ]);
  for (const source of consumers) {
    assert.doesNotMatch(source, /(?:release-readiness|trust-dashboard|data-project-dashboard)\.json/);
  }
  assert.match(consumers[0], /releaseTruth/);
  assert.match(consumers[1], /ReleaseReadinessOverview/);
  assert.match(consumers[2], /releaseTruth/);
  assert.match(consumers[3], /release-truth-public\.json/);
});

test("all three deprecated projections are pinned to the shared snapshot", async () => {
  const projections = await Promise.all([
    readJSON(new URL("../src/generated/release-readiness.json", import.meta.url)),
    readJSON(new URL("../src/generated/trust-dashboard.json", import.meta.url)),
    readJSON(new URL("../public-site/src/generated/trust-dashboard.json", import.meta.url))
  ]);
  for (const projection of projections) {
    assert.equal(projection.schemaVersion, "release-truth-compatibility-v1");
    assert.equal(projection.deprecated, true);
    assert.equal(projection.snapshotID, adminTruth.snapshotID);
    assert.equal(projection.snapshotDigest, adminTruth.snapshotDigest);
  }
});

test("only the Release Truth generator owns deprecated Admin and public projections", async () => {
  const legacyGenerator = await readFile(new URL("../../scripts/generate_trust_dashboard.py", import.meta.url), "utf8");
  const releaseGenerator = await readFile(new URL("../scripts/generate-release-truth.mjs", import.meta.url), "utf8");
  assert.doesNotMatch(legacyGenerator, /admin-dashboard\/src\/generated\/trust-dashboard\.json/);
  assert.doesNotMatch(legacyGenerator, /admin-dashboard\/public-site\/src\/generated\/trust-dashboard\.json/);
  assert.match(releaseGenerator, /adminTrustDashboard/);
  assert.match(releaseGenerator, /publicTrustDashboard/);
});

test("every public development, test and production build regenerates shared release truth", async () => {
  const publicPackage = await readJSON(new URL("../public-site/package.json", import.meta.url));
  const publicBuild = await readFile(new URL("../public-site/scripts/build.sh", import.meta.url), "utf8");
  assert.match(publicPackage.scripts.dev, /generate:runtime/);
  assert.match(publicPackage.scripts["dev:lan"], /generate:runtime/);
  assert.match(publicPackage.scripts.test, /generate:runtime/);
  assert.match(publicPackage.scripts["generate:runtime"], /generate-release-truth\.mjs/);
  assert.match(publicBuild, /generate-release-truth\.mjs/);
  assert.ok(
    publicBuild.indexOf("generate-public-content.mjs") < publicBuild.indexOf("generate-release-truth.mjs"),
    "release truth must bind the public payload generated for the same build"
  );
});

test("stale and unavailable operational sources cannot hide an available queue", () => {
  const observedAt = "2026-08-19T12:00:00.000Z";
  const operational = assembleOperationalTruth(
    {
      error: null,
      data: {
        denominator: 1,
        verified: 1,
        review_due_soon: 0,
        overdue: 0,
        disputed: 0,
        source_unavailable: 0,
        published: 1,
        average_confidence: 100,
        median_confidence: 100,
        review_queue: 1,
        review_sla_breaches: 0,
        generated_at: "2026-08-17T12:00:00.000Z"
      }
    },
    {
      error: null,
      count: 1,
      data: [{
        id: "task-1",
        governance_state_id: "state-1",
        owner_id: null,
        reason: "Synthetic independent-source test",
        severity: "high",
        severity_rank: 1,
        state: "needs_review",
        sla_due_at: "2026-08-20T12:00:00.000Z",
        resolved_at: null,
        created_at: "2026-08-19T10:00:00.000Z",
        updated_at: "2026-08-19T10:00:00.000Z"
      }]
    },
    { error: { message: "synthetic query failure" }, data: null },
    { error: null, data: null, count: 0 },
    observedAt
  );
  assert.equal(operational.governanceSummary.state, "stale");
  assert.equal(operational.reviewQueue.state, "available");
  if (operational.reviewQueue.state === "available") assert.equal(operational.reviewQueue.data.total, 1);
  assert.equal(operational.reviewSlaBreaches.state, "available");
  if (operational.reviewSlaBreaches.state === "available") assert.equal(operational.reviewSlaBreaches.data, 0);
  assert.equal(operational.governanceRisks.state, "unavailable");
});

test("review pagination is ordered in SQL and SLA count is an independent exact query", async () => {
  const [loader, classifier, trust] = await Promise.all([
    readFile(new URL("../src/lib/release-truth/operational.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/lib/release-truth/operational-classification.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/trust/page.tsx", import.meta.url), "utf8")
  ]);
  assert.match(loader, /from\("admin_review_queue"\)[\s\S]*order\("severity_rank"[\s\S]*order\("sla_due_at"[\s\S]*order\("id"[\s\S]*range\(offset/);
  assert.match(loader, /select\("id", \{ count: "exact", head: true \}\)[\s\S]*\.lt\("sla_due_at", observedAt\)/);
  assert.doesNotMatch(classifier, /\.sort\(/);
  assert.doesNotMatch(classifier, /review_sla_breaches/);
  assert.match(trust, /reviewSlaBreaches\.state === "available"/);
  assert.match(trust, /SLA breach count unavailable/);
});

test("canonical map has stable source identities and preserves public API fields", () => {
  assert.deepEqual(map.counts, {
    contentEntities: 6,
    municipalities: 342,
    total: 348,
    categories: 33,
    cities: 5
  });
  assert.equal(map.points.length, map.counts.total);
  assert.equal(new Set(map.points.map((point: Record<string, unknown>) => point.id)).size, map.points.length);
  assert.equal(
    new Set(map.points.map((point: Record<string, unknown>) => `${point.source_kind}:${point.source_id}`)).size,
    map.points.length
  );
  for (const point of map.points) {
    for (const field of ["id", "title", "type", "latitude", "longitude", "city", "province", "description", "source_url", "status", "icon", "color", "created_at", "updated_at"]) {
      assert.ok(Object.hasOwn(point, field), `missing public map field ${field}`);
    }
    assert.ok(point.latitude >= -90 && point.latitude <= 90);
    assert.ok(point.longitude >= -180 && point.longitude <= 180);
  }
});

test("map API and packaged Admin projection share a registry beside the separate operational editor", async () => {
  const [api, page] = await Promise.all([
    readFile(new URL("../src/app/api/public/map-points/route.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/map/page.tsx", import.meta.url), "utf8")
  ]);
  assert.match(api, /canonicalMap\.points/);
  assert.match(api, /canonicalMap\.datasetFingerprint/);
  assert.match(api, /data: canonicalMap\.points/);
  assert.match(api, /generated_at: canonicalMap\.generatedAt/);
  assert.match(api, /dataset_fingerprint: canonicalMap\.datasetFingerprint/);
  assert.match(api, /ETag: etag/);
  assert.match(api, /if-none-match/);
  assert.match(api, /status: 304/);
  assert.match(page, /canonicalMap/);
  assert.match(page, /canonicalMap\.points/);
  assert.match(page, /rows=\{visibleRows\}/);
  assert.match(page, /<MapPointManager/);
  assert.match(page, /apiMode="packaged"/);
  assert.doesNotMatch(api, /createSupabase|map_points/);
});

test("official-link registry collapses exact canonical duplicates without claiming health", () => {
  assert.equal(links.counts.references, 689);
  assert.equal(links.counts.canonicalLinks, 685);
  assert.equal(links.counts.duplicatesCollapsed, 4);
  assert.equal(links.counts.references - links.counts.canonicalLinks, links.counts.duplicatesCollapsed);
  assert.equal(links.links.length, links.counts.canonicalLinks);
  assert.equal(new Set(links.links.map((link: Record<string, unknown>) => link.canonical_url)).size, links.links.length);
  assert.equal(
    links.links.reduce((total: number, link: Record<string, unknown>) => total + Number(link.reference_count), 0),
    links.counts.references
  );
  assert.deepEqual(links.linkHealth, {
    state: "unknown",
    reasonCode: "network_check_not_part_of_deterministic_build",
    observedAt: null,
    validThrough: null,
    total: null,
    reachable: null,
    confirmedBroken: null
  });
  assert.ok(links.links.every((link: Record<string, unknown>) => link.link_health_state === "unknown"));
});

test("Admin Links joins retained operational checks without upgrading unchecked health", async () => {
  const page = await readFile(new URL("../src/app/(admin)/links/page.tsx", import.meta.url), "utf8");
  assert.match(page, /official_link_operational_latest/);
  assert.match(page, /fetchRowsResult/);
  assert.match(page, /operation\?\.link_health_state \?\? "unknown"/);
  assert.match(page, /classifyOfficialLinkObservation\(operation, operational\.observedAt\)/);
  assert.match(page, /Invalid, epoch, future and stale timestamps never contribute to coverage/);
  assert.doesNotMatch(page, /100%|healthy links/i);
});

test("Supabase compatibility migration is additive, RLS-bound and history-preserving", async () => {
  const [migration, generator] = await Promise.all([
    readFile(new URL("../supabase/migrations/20260819124839_add_canonical_map_overrides.sql", import.meta.url), "utf8"),
    readFile(new URL("../scripts/generate-canonical-admin-data.mjs", import.meta.url), "utf8")
  ]);
  for (const required of [
    "official_link_registry_entries",
    "official_link_aliases",
    "official_link_check_results",
    "security_invoker = true",
    "preview_legacy_official_link_duplicates",
    "soft_supersede_legacy_official_link",
    "legacy_map_points_read_only",
    "revoke insert, update, delete on table public.map_points"
  ]) assert.match(migration, new RegExp(required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "i"));
  assert.match(migration, /left\(v_suffix, 1\) = '\?'/);
  assert.match(migration, /official_link_url_credentials_forbidden/);
  assert.match(migration, /official_link_url_dot_segment_forbidden/);
  assert.match(migration, /official_link_url_non_ascii_or_whitespace/);
  assert.match(generator, /parsed\.username \|\| parsed\.password/);
  assert.match(generator, /%2e%2e/);
  assert.match(generator, /\[\^\\x21-\\x7e\]/);
  assert.doesNotMatch(migration, /delete\s+from\s+public\.official_links/i);
});

test("generated canonical data and release truth are current", () => {
  const scripts = ["generate-canonical-admin-data.mjs", "generate-release-truth.mjs"];
  for (const script of scripts) {
    const result = spawnSync(process.execPath, [fileURLToPath(new URL(`../scripts/${script}`, import.meta.url)), "--check"], {
      encoding: "utf8"
    });
    assert.equal(result.status, 0, `${script}: ${result.stderr}`);
  }
});

test("route launcher, notifications and read-only evidence states are explicit", async () => {
  const [launcher, topbar, layout, table, sourceView, dataAdapter] = await Promise.all([
    readFile(new URL("../src/components/admin/route-launcher.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/components/admin/topbar.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/layout.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/components/admin/crud-table.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/components/admin/read-only-source.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/lib/data.ts", import.meta.url), "utf8")
  ]);
  assert.match(launcher, /canAccessPath/);
  assert.match(launcher, /router\.push/);
  assert.match(topbar, /canManageBusinessInquiries/);
  assert.match(topbar, /business-inquiries#notifications/);
  assert.match(layout, /status", "unread/);
  assert.doesNotMatch(table, /cta\??:/);
  for (const value of ["user_submission", "sample", "synthetic_test", "legacy_unclassified", "lease_expires_at"]) {
    assert.match(table, new RegExp(value));
  }
  for (const state of ["data", "empty", "forbidden", "unavailable", "stale"]) {
    assert.match(sourceView, new RegExp(`\\b${state}\\b`));
  }
  assert.match(dataAdapter, /data\.length === 0 \? "empty" : "data"/);
  assert.match(dataAdapter, /permission denied/);
});

test("compact release evidence links only to routes allowed for the current role", async () => {
  const [readiness, dashboard, trust] = await Promise.all([
    readFile(new URL("../src/components/admin/release-readiness-overview.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/dashboard/page.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/app/(admin)/trust/page.tsx", import.meta.url), "utf8")
  ]);
  assert.match(readiness, /role && canAccessPath\(role, "\/releases"\)/);
  assert.match(dashboard, /ReleaseReadinessOverview compact role=\{admin\.role\}/);
  assert.match(trust, /ReleaseReadinessOverview compact role=\{admin\.role\}/);
});
