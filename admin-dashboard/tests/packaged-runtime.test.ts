import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { copyFileSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const adminRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const verifierPath = resolve(adminRoot, "scripts/verify-packaged-governed-runtime.mjs");
const runtimePath = resolve(adminRoot, "src/generated/governed-runtime.json");
const manifestPath = resolve(adminRoot, "src/generated/governed-runtime-manifest.json");

function createPackagedFixture() {
  const fixtureRoot = mkdtempSync(join(tmpdir(), "younew-packaged-runtime-"));
  mkdirSync(resolve(fixtureRoot, "scripts"), { recursive: true });
  mkdirSync(resolve(fixtureRoot, "src/generated"), { recursive: true });
  copyFileSync(verifierPath, resolve(fixtureRoot, "scripts/verify-packaged-governed-runtime.mjs"));
  copyFileSync(runtimePath, resolve(fixtureRoot, "src/generated/governed-runtime.json"));
  copyFileSync(manifestPath, resolve(fixtureRoot, "src/generated/governed-runtime-manifest.json"));
  return fixtureRoot;
}

function runVerifier(fixtureRoot: string) {
  return execFileSync(
    process.execPath,
    [resolve(fixtureRoot, "scripts/verify-packaged-governed-runtime.mjs")],
    { encoding: "utf8", stdio: "pipe" }
  );
}

test("Hostinger package accepts the checked-in governed runtime", (context) => {
  const fixtureRoot = createPackagedFixture();
  context.after(() => rmSync(fixtureRoot, { recursive: true, force: true }));
  assert.match(runVerifier(fixtureRoot), /Verified packaged governed runtime: 182 entities/);
});

test("Hostinger package rejects a runtime whose bytes no longer match the manifest", (context) => {
  const fixtureRoot = createPackagedFixture();
  context.after(() => rmSync(fixtureRoot, { recursive: true, force: true }));
  const fixtureRuntimePath = resolve(fixtureRoot, "src/generated/governed-runtime.json");
  writeFileSync(fixtureRuntimePath, `${readFileSync(fixtureRuntimePath, "utf8")} `);

  assert.throws(
    () => runVerifier(fixtureRoot),
    /runtime SHA-256 does not match the manifest/
  );
});
