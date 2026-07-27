import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const root = new URL("../", import.meta.url);
const siteConfig = JSON.parse(
  await readFile(new URL("src/config/site-config.json", root), "utf8"),
);
const status = JSON.parse(
  await readFile(new URL("src/config/status.json", root), "utf8"),
);

test("App Store configuration uses the verified YouNew listing", () => {
  assert.equal(siteConfig.schemaVersion, 2);
  assert.equal(siteConfig.appStore.available, true);
  assert.equal(siteConfig.appStore.id, "6782617312");
  assert.equal(
    siteConfig.appStore.url,
    "https://apps.apple.com/app/id6782617312",
  );
  assert.match(siteConfig.appStore.version, /^\d+\.\d+$/);
  assert.equal(siteConfig.statusBanner.enabled, false);
});

test("public status and App Store call-to-action stay consistent", () => {
  assert.equal(status.ios.status, "available");
  assert.equal(status.ios.publicVersion, siteConfig.appStore.version);
  assert.equal(status.ios.appStoreId, siteConfig.appStore.id);
  assert.equal(status.ios.appStoreUrl, siteConfig.appStore.url);
  assert.equal(status.ios.releasedAt, siteConfig.appStore.releasedAt);
  assert.ok(
    status.webAlternatives.some(
      (entry: { href: string }) => entry.href === siteConfig.appStore.url,
    ),
  );
});
