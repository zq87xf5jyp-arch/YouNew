import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migrationUrl = new URL(
  "../supabase/migrations/20260805120952_search_content_model.sql",
  import.meta.url
);
const managerUrl = new URL("../src/components/admin/content-manager.tsx", import.meta.url);
const actionsUrl = new URL("../src/app/(admin)/content/actions.ts", import.meta.url);

test("article search model contains every governed ranking field and publication warning", async () => {
  const sql = await readFile(migrationUrl, "utf8");

  for (const field of [
    "canonical_title",
    "search_subcategory",
    "search_intents",
    "search_synonyms",
    "search_keywords",
    "search_languages",
    "content_scope",
    "province_id",
    "municipality_id",
    "city_id",
    "national_fallback",
    "audience_profiles",
    "search_quality_score",
    "search_indexed",
    "search_warnings"
  ]) {
    assert.match(sql, new RegExp(`add column if not exists ${field}`));
  }
  assert.match(sql, /private\.refresh_article_search_metadata/);
  assert.match(sql, /search:quality_below_80/);
  assert.match(sql, /new\.validation_errors := v_preserved_errors \|\| v_warnings/);
  assert.match(sql, /new\.search_indexed := new\.status = 'published'/);
  assert.match(sql, /with \(security_invoker = true\)/);
  assert.match(sql, /revoke all on function private\.refresh_article_search_metadata\(\)/);
});

test("Admin editor sends and explains the governed search fields", async () => {
  const [manager, actions] = await Promise.all([
    readFile(managerUrl, "utf8"),
    readFile(actionsUrl, "utf8")
  ]);

  assert.match(manager, /Canonical title/);
  assert.match(manager, /Synonyms EN/);
  assert.match(manager, /Synonyms NL/);
  assert.match(manager, /Synonyms RU/);
  assert.match(manager, /national fallback/);
  assert.match(manager, /Search quality/);
  assert.match(manager, /Search warnings/);
  assert.match(actions, /search_intents: commaSeparated/);
  assert.match(actions, /search_synonyms:/);
  assert.match(actions, /audience_profiles: commaSeparated/);
});
