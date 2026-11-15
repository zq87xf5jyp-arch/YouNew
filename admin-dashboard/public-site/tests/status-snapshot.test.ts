import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const root = new URL("../", import.meta.url);
const json = async (path: string) => JSON.parse(await readFile(new URL(path, root), "utf8"));
const snapshot = await json("src/config/status.json");
const content = await json("src/generated/public-content.json");
const provenance = await json("public/data/content-provenance.json");
const ios = await json("../../YouNew/Resources/Data/younew-runtime-data.json");
type Entity = { id: string; type: string; practicalGuide: unknown; verifiedAt: string; status: string };
const entities: Entity[] = content.entities;

test("status is one dated static snapshot with scoped checks and explicit unknowns", () => {
  assert.equal(snapshot.schemaVersion, 2);
  assert.equal(snapshot.snapshotType, "static");
  assert.equal(snapshot.liveMonitoring, false);
  assert.match(snapshot.assessment, /^PARTIAL/);
  for (const service of ["website", "content", "businessForm"]) assert.equal(snapshot[service].status, "checked");
  assert.equal(snapshot.ios.status, "unconfirmed");
  assert.match(snapshot.website.summary, /Hostinger.*PHP.*Node\.js and MariaDB/);
  assert.match(snapshot.limitations.join(" "), /does not provide live uptime monitoring/);
  assert.match(snapshot.limitations.join(" "), /Field Core Web Vitals are not confirmed/);
  assert.match(snapshot.limitations.join(" "), /App Store Connect access is not verified/);
  assert.doesNotMatch(JSON.stringify(snapshot), /Sites v\d+|Secure Supabase endpoints|177 published|182 published|Xcode Cloud validation passed/);
});

test("status totals and fingerprint agree with the actual publishable artifact", () => {
  assert.ok(entities.every((entity) => entity.status === "published"));
  assert.deepEqual(snapshot.content.counts, {
    total: entities.length,
    places: entities.filter((entity) => entity.type === "place").length,
    summaryGuides: entities.filter((entity) => entity.type === "guide" && !entity.practicalGuide).length,
    cities: entities.filter((entity) => entity.type === "city").length,
    fullGuides: entities.filter((entity) => entity.type === "guide" && entity.practicalGuide).length
  });
  assert.equal(snapshot.content.datasetFingerprint, content.datasetFingerprint);
  assert.equal(snapshot.content.datasetFingerprint, provenance.datasetFingerprint);
  assert.equal(snapshot.content.counts.total, provenance.counts.acceptedRecords);
});

test("snapshot date does not replace source verification or editorial release dates", () => {
  const dates = [...new Set(entities.map((entity) => entity.verifiedAt.slice(0, 10)))].sort();
  assert.deepEqual(snapshot.content.sourceCheckedDates, dates);
  assert.equal(snapshot.content.asOf, provenance.editorialRelease.approvedAt);
  for (const date of [snapshot.checkedAt, snapshot.content.asOf, snapshot.ios.releasedAt, ...dates]) {
    assert.match(date, /^\d{4}-\d{2}-\d{2}$/);
    assert.equal(new Date(date).toISOString().slice(0, 10), date);
    assert.ok(date <= snapshot.checkedAt);
  }
  assert.match(snapshot.history, /historical evidence, not the current/);
});

test("web and iOS discrepancy is calculated from ID sets, not assumed release parity", () => {
  const webIDs = new Set(entities.map((entity) => entity.id));
  const iosIDs = new Set<string>(ios.entities.map((entity: { id: string }) => entity.id));
  assert.deepEqual(snapshot.ios.sourceComparison, {
    sharedIDs: [...webIDs].filter((id) => iosIDs.has(id)).length,
    webOnlyIDs: [...webIDs].filter((id) => !iosIDs.has(id)).length,
    iosOnlyIDs: [...iosIDs].filter((id) => !webIDs.has(id)).length
  });
  assert.match(snapshot.ios.summary, /contents of the shipped app were not checked/);
});

test("public status JSON is the normal build copy and evidence links are safe", async () => {
  assert.deepEqual(await json("public/data/status.json"), snapshot);
  const build = await readFile(new URL("scripts/build.sh", root), "utf8");
  assert.match(build, /cp src\/config\/status\.json public\/data\/status\.json/);
  for (const link of [...snapshot.evidenceLinks, ...snapshot.webAlternatives]) {
    assert.ok(link.label.trim());
    assert.match(link.href, /^(?:\/(?!\/)|https:\/\/itunes\.apple\.com\/lookup\?|mailto:support@younew\.nl$)/);
  }
});
