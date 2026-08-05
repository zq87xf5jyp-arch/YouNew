import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const siteRoot = new URL("../", import.meta.url);

test("privacy policy contains one network-services disclosure", async () => {
  const source = await readFile(new URL("src/app/privacy/page.tsx", siteRoot), "utf8");
  const headings = source.match(/<h2>Network services and technical logs<\/h2>/g) ?? [];

  assert.equal(headings.length, 1);
});

test("updates page derives the Amsterdam release from published content", async () => {
  const source = await readFile(new URL("src/app/updates/page.tsx", siteRoot), "utf8");
  const content = JSON.parse(
    await readFile(new URL("src/generated/public-content.json", siteRoot), "utf8")
  ) as { publishedReleaseIds: string[] };
  const currentRelease = content.publishedReleaseIds.find((releaseId) =>
    releaseId.startsWith("amsterdam-v")
  );

  assert.equal(currentRelease, "amsterdam-v0.1.7");
  assert.match(source, /publishedReleaseIds\.find\(\(releaseId\) => releaseId\.startsWith\("amsterdam-v"\)\)/);
  assert.doesNotMatch(source, /amsterdam-v0\.1\.4/);
});
