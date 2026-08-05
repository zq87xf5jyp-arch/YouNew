import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const metadataMigration = await readFile(
  new URL("../supabase/migrations/20260805134500_article_search_readiness.sql", import.meta.url),
  "utf8"
);
const constraintsMigration = await readFile(
  new URL("../supabase/migrations/20260805134530_article_search_constraints.sql", import.meta.url),
  "utf8"
);
const publicationGateMigration = await readFile(
  new URL("../supabase/migrations/20260805134545_article_search_publication_gate.sql", import.meta.url),
  "utf8"
);
const readinessViewMigration = await readFile(
  new URL("../supabase/migrations/20260805134600_article_search_readiness_view.sql", import.meta.url),
  "utf8"
);
const migration = [metadataMigration, constraintsMigration, publicationGateMigration, readinessViewMigration].join("\n");
const manager = await readFile(
  new URL("../src/components/admin/content-manager.tsx", import.meta.url),
  "utf8"
);
const actions = await readFile(
  new URL("../src/app/(admin)/content/actions.ts", import.meta.url),
  "utf8"
);
const productionSmoke = await readFile(
  new URL("../scripts/production-search-smoke.mjs", import.meta.url),
  "utf8"
);

test("article storage contains the mandatory search applicability model", () => {
  for (const column of [
    "canonical_title", "subcategory", "search_intents", "search_synonyms",
    "search_keywords", "supported_languages", "country_scope", "scope_level",
    "municipality", "national_fallback", "applicable_profiles", "source_urls",
    "content_quality_score", "search_indexed"
  ]) assert.match(migration, new RegExp(`add column if not exists ${column}\\b`), column);

  assert.match(migration, /article_search_metadata_incomplete/);
  assert.match(migration, /with \(security_invoker = true\)/);
  assert.match(migration, /grant select on public\.article_search_readiness to authenticated, service_role/);
});

test("legacy published rows are backfilled through a bounded trigger exception", () => {
  for (const trigger of [
    "enforce_article_publication_gate", "enqueue_article_publication", "set_updated_at"
  ]) {
    assert.match(metadataMigration, new RegExp(`disable trigger ${trigger}`), `${trigger} disabled`);
    assert.match(metadataMigration, new RegExp(`enable trigger ${trigger}`), `${trigger} re-enabled`);
  }
  assert.doesNotMatch(metadataMigration, /disable trigger all/i);
  assert.doesNotMatch(metadataMigration, /\b(status|full_content|publication_evidence)\s*=/i);
});

test("readiness warnings cover every required editorial risk", () => {
  for (const warning of [
    "no_synonyms", "no_official_source", "no_national_fallback", "no_city_mapping",
    "duplicate_intent", "conflicting_aliases", "content_not_indexed", "stale_content",
    "empty_result_risk"
  ]) {
    assert.match(migration, new RegExp(`'${warning}'`), warning);
    assert.match(manager, new RegExp(`${warning}:`), warning);
  }
});

test("Admin reads and writes every search field instead of display-only metadata", () => {
  for (const payloadField of [
    "canonical_title", "subcategory", "search_intents", "search_synonyms",
    "search_keywords", "supported_languages", "country_scope", "scope_level",
    "province", "municipality", "city", "national_fallback", "applicable_profiles",
    "source_urls", "content_quality_score", "search_indexed"
  ]) assert.match(actions, new RegExp(`${payloadField}:`), payloadField);

  assert.match(manager, /Search applicability — обязательные поля/);
  assert.match(manager, /production search index/);
});

test("all 27 canonical life domains are provisioned without overwriting existing categories", () => {
  const inserts = [...migration.matchAll(/\('[^']+', '[a-z0-9-]+', '[^']+', 'draft', \d+\)/g)];
  assert.equal(inserts.length, 27);
  assert.match(migration, /on conflict \(slug\) do nothing/);
});

test("production search smoke covers both browser engines and every release blocker", () => {
  assert.match(productionSmoke, /desktop-chromium/);
  assert.match(productionSmoke, /mobile-webkit/);
  assert.match(productionSmoke, /devices\["iPhone 13"\]/);
  for (const query of ["rent", "housing rent", "work", "huisarts", "Dutch school", "BSN", "SIM card", "parking fine"]) {
    assert.match(productionSmoke, new RegExp(`query: "${query}"`), query);
  }
  assert.match(productionSmoke, /No useful published result matched/);
  assert.match(productionSmoke, /Search all Netherlands/);
  assert.match(productionSmoke, /Link copied/);
  assert.match(productionSmoke, /page\.goBack/);
  assert.match(productionSmoke, /PUBLIC_SEARCH_BASE_URL/);
});
