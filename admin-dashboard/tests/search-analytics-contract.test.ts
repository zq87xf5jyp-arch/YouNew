import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const sql = await readFile(new URL("../supabase/migrations/20260805122546_search_gap_analytics.sql", import.meta.url), "utf8");

test("search analytics migration is privacy-safe, RLS protected and creates repeated-gap tasks", () => {
  assert.match(sql, /normalized_query_safe/);
  assert.match(sql, /\[redacted\][\s\S]*\[unmapped\]/);
  assert.match(sql, /alter table public\.search_improvement_tasks enable row level security/);
  assert.match(sql, /private\.is_approved_admin\(\)/);
  assert.match(sql, /occurrence_count \+ 1 >= 3 then 'open'/);
  assert.match(sql, /occurrence_count \+ 1 >= 10 then 'critical'/);
  assert.match(sql, /with \(security_invoker = true\)/);
  assert.doesNotMatch(sql, /grant (?:insert|all).* to anon/i);
});
