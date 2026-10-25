import assert from "node:assert/strict";
import { readdir, readFile } from "node:fs/promises";
import test from "node:test";

const routeFiles = [
  "dashboard", "analytics", "sync", "trust", "content", "business-inquiries",
  "categories", "cities", "map", "visual-qa", "bugs", "releases", "links",
  "ai-knowledge", "feedback", "settings", "audit-log"
];

const routeSources = await Promise.all(routeFiles.map(async (route) => ({
  route,
  source: await readFile(new URL(`../src/app/(admin)/${route}/page.tsx`, import.meta.url), "utf8")
})));
const readiness = await readFile(new URL("../src/components/admin/release-readiness-overview.tsx", import.meta.url), "utf8");
const table = await readFile(new URL("../src/components/admin/crud-table.tsx", import.meta.url), "utf8");
const releaseGenerator = await readFile(new URL("../scripts/generate-release-truth.mjs", import.meta.url), "utf8");

async function collectTsxSources(directory: URL, label: string): Promise<Array<{ file: string; source: string }>> {
  const files: Array<{ file: string; source: string }> = [];
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const entryUrl = new URL(entry.isDirectory() ? `${entry.name}/` : entry.name, directory);
    if (entry.isDirectory()) {
      files.push(...await collectTsxSources(entryUrl, `${label}/${entry.name}`));
    } else if (entry.isFile() && entry.name.endsWith(".tsx")) {
      files.push({ file: `${label}/${entry.name}`, source: await readFile(entryUrl, "utf8") });
    }
  }
  return files;
}

const adminUiSources = [
  ...await collectTsxSources(new URL("../src/app/(admin)/", import.meta.url), "src/app/(admin)"),
  ...await collectTsxSources(new URL("../src/components/admin/", import.meta.url), "src/components/admin")
];

test("all 17 registered route pages are present and prototype CRUD affordances stay absent", () => {
  assert.equal(routeSources.length, 17);
  for (const { route, source } of routeSources) {
    assert.doesNotMatch(source, /\bcta=/, `${route} must not pass a string-only CRUD CTA`);
    assert.doesNotMatch(source, /actions=\{\s*<Button\b/, `${route} must not render an inert PageHeader button`);
  }
  assert.doesNotMatch(table, /cta\??:/);
});

test("every Admin Button in routes and nested components has a real outcome", () => {
  for (const { file, source } of adminUiSources) {
    for (const match of source.matchAll(/<Button\b([^>]*)>/g)) {
      const attributes = match[1] ?? "";
      assert.match(
        attributes,
        /\b(?:type="submit"|asChild|onClick=)/,
        `${file} contains a visible Button without a confirmed submit, link or handler outcome`
      );
    }
  }
});

test("release UI cannot restore the frozen production verdict or counts", () => {
  const combined = `${routeSources.map(({ source }) => source).join("\n")}\n${readiness}`;
  for (const forbidden of [
    /FULL PRODUCT LIVE/i,
    /GO LIVE завершён/i,
    /Version 30 LIVE/i,
    /578 HTML\s*·\s*108 тестов/i,
    /29 тестов\s*·\s*CSP enforced/i
  ]) {
    assert.doesNotMatch(combined, forbidden);
  }
  assert.doesNotMatch(releaseGenerator, /agree on \d+ packaged records/);
  assert.match(releaseGenerator, /\$\{packagedCount\} packaged public records/);
});
