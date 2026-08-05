import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const adminWorkspace = await readFile(new URL("../pnpm-workspace.yaml", import.meta.url), "utf8");
const adminLock = await readFile(new URL("../pnpm-lock.yaml", import.meta.url), "utf8");
const publicWorkspace = await readFile(new URL("../public-site/pnpm-workspace.yaml", import.meta.url), "utf8");
const publicLock = await readFile(new URL("../public-site/pnpm-lock.yaml", import.meta.url), "utf8");
const videoWorkspace = await readFile(new URL("../../BuildWeekVideo/pnpm-workspace.yaml", import.meta.url), "utf8");
const videoLock = await readFile(new URL("../../BuildWeekVideo/pnpm-lock.yaml", import.meta.url), "utf8");

function packageVersions(lockfile: string, packageName: string) {
  const escapedName = packageName.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const matches = lockfile.matchAll(new RegExp(`^  ['\"]?${escapedName}@([^:'\"]+)['\"]?:$`, "gm"));
  return [...new Set([...matches].map((match) => match[1]))].sort();
}

test("Admin and public-site lockfiles pin the patched PostCSS and brace-expansion lines", () => {
  for (const [name, workspace, lockfile] of [
    ["Admin", adminWorkspace, adminLock],
    ["Public site", publicWorkspace, publicLock]
  ] as const) {
    assert.match(workspace, /^  postcss: 8\.5\.23$/m, `${name} PostCSS override`);
    assert.match(workspace, /^  brace-expansion@<1\.1\.18: 1\.1\.18$/m, `${name} brace-expansion v1 override`);
    assert.match(workspace, /^  brace-expansion@>=2\.0\.0 <2\.1\.4: 2\.1\.4$/m, `${name} brace-expansion v2 override`);
    assert.match(workspace, /^  brace-expansion@>=3\.0\.0 <5\.0\.9: 5\.0\.9$/m, `${name} brace-expansion v3+ override`);
    assert.deepEqual(packageVersions(lockfile, "postcss"), ["8.5.23"], `${name} PostCSS resolution`);
    assert.deepEqual(packageVersions(lockfile, "brace-expansion"), ["1.1.18", "5.0.9"], `${name} brace-expansion resolutions`);
  }
});

test("BuildWeekVideo pins every audited dependency and explicitly allows the verified esbuild install", () => {
  assert.match(videoWorkspace, /^  esbuild: true$/m);
  assert.match(videoWorkspace, /^  '@eslint\/plugin-kit': 0\.3\.4$/m);
  assert.match(videoWorkspace, /^  fast-uri: 3\.1\.5$/m);
  assert.match(videoWorkspace, /^  postcss: 8\.5\.23$/m);
  assert.match(videoWorkspace, /^  brace-expansion@<1\.1\.18: 1\.1\.18$/m);
  assert.match(videoWorkspace, /^  brace-expansion@>=2\.0\.0 <2\.1\.4: 2\.1\.4$/m);
  assert.match(videoWorkspace, /^  brace-expansion@>=3\.0\.0 <5\.0\.9: 5\.0\.9$/m);

  assert.deepEqual(packageVersions(videoLock, "@eslint/plugin-kit"), ["0.3.4"]);
  assert.deepEqual(packageVersions(videoLock, "fast-uri"), ["3.1.5"]);
  assert.deepEqual(packageVersions(videoLock, "postcss"), ["8.5.23"]);
  assert.deepEqual(packageVersions(videoLock, "brace-expansion"), ["1.1.18", "2.1.4"]);
});
