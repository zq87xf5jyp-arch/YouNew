import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const siteRoot = new URL("../", import.meta.url);
const content = JSON.parse(await readFile(new URL("src/generated/public-content.json", siteRoot), "utf8"));
const provenance = JSON.parse(await readFile(new URL("public/data/content-provenance.json", siteRoot), "utf8"));
const canonicalRuntime = JSON.parse(await readFile(new URL("../../YouNew/Resources/Data/younew-runtime-data.json", siteRoot), "utf8"));
const generator = (await import(new URL("scripts/generate-public-content.mjs", siteRoot).href)) as {
  assignStableSlugs: (
    records: Array<{ id: string; title: string }>,
    baseForRecord?: (record: { id: string; title: string }) => string
  ) => Map<string, string>;
  buildPublicDataset: (runtime: unknown, options?: { verifyChecksum?: boolean }) => unknown;
};

test("generated public content comes only from governed production releases", () => {
  assert.equal(provenance.sourceMode, "production");
  assert.deepEqual(provenance.acceptedReleaseIds, ["amsterdam-v0.1.1", "cities-v0.1.0"]);
  assert.equal(content.stats.entities, provenance.counts.acceptedRecords);
  assert.equal(content.entities.length, content.stats.entities);
  assert.ok(content.entities.every((entity: { status: string; releaseId: string; trust: { sourceChecked: boolean } }) =>
    entity.status === "published" &&
    provenance.acceptedReleaseIds.includes(entity.releaseId) &&
    entity.trust.sourceChecked === true
  ));
});

test("derived collections, routes and slugs are internally consistent", () => {
  const expectedTotal =
    content.stats.cities + content.stats.guides + content.stats.organizations + content.stats.places;
  assert.equal(expectedTotal, content.stats.entities);

  for (const type of ["city", "guide", "organization", "place"] as const) {
    const records = content.entities.filter((entity: { type: string }) => entity.type === type);
    const slugs = records.map((entity: { slug: string }) => entity.slug);
    assert.equal(new Set(slugs).size, slugs.length);
    assert.ok(slugs.every((slug: string) => /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug)));
  }

  assert.ok(content.categories.length > 0);
  assert.ok(content.categories.every((category: { entityCount: number; entityIds: string[] }) =>
    category.entityCount > 0 && category.entityCount === category.entityIds.length
  ));
  assert.ok(content.provinces.every((province: { entityCount: number; entityIds: string[] }) =>
    province.entityCount > 0 && province.entityCount === province.entityIds.length
  ));
});

test("local partners are source-checked but never promoted to sponsored or verified organizations", () => {
  const partners = content.organizations.filter((entity: { sourceKind: string }) => entity.sourceKind === "localPartner");
  assert.ok(partners.length > 0);
  for (const partner of partners) {
    assert.deepEqual(partner.trust, { sourceChecked: true, officialSource: false });
    assert.equal(partner.source.publisherOfficial, false);
    assert.equal("sponsored" in partner, false);
    assert.equal("verifiedOrganization" in partner, false);
  }
});

test("slug collisions receive deterministic stable suffixes", () => {
  const records = [
    { id: "place.second", title: "Same title" },
    { id: "place.first", title: "Same title" }
  ];
  const first = generator.assignStableSlugs(records);
  const second = generator.assignStableSlugs([...records].reverse());
  assert.equal(first.get("place.first"), second.get("place.first"));
  assert.equal(first.get("place.second"), second.get("place.second"));
  assert.notEqual(first.get("place.first"), first.get("place.second"));
});

test("generator rejects a non-production canonical dataset", () => {
  assert.throws(
    () => generator.buildPublicDataset({ mode: "preview", releases: [], entities: [] }),
    /mode=production/
  );
});

test("generator rejects unknown schema versions and excludes unknown entity kinds", () => {
  assert.throws(
    () => generator.buildPublicDataset({ ...canonicalRuntime, schemaVersion: 99 }),
    /Unsupported canonical schemaVersion/
  );

  const unknownEntity = {
    ...canonicalRuntime.entities[0],
    id: "advertiser.private-record",
    kind: "advertiser",
    title: "Private advertiser record"
  };
  const output = generator.buildPublicDataset({
    ...canonicalRuntime,
    entities: [...canonicalRuntime.entities, unknownEntity]
  }, { verifyChecksum: false }) as { content: { entities: Array<{ id: string }> }; provenance: { counts: { excludedRecords: number } } };
  assert.equal(output.content.entities.some((entity) => entity.id === unknownEntity.id), false);
  assert.ok(output.provenance.counts.excludedRecords >= 1);
});

test("generator rejects a tampered checked-in runtime payload", () => {
  const tampered = {
    ...canonicalRuntime,
    entities: canonicalRuntime.entities.map((entity: { id: string; title: string }, index: number) => index === 0 ? { ...entity, title: `${entity.title} tampered` } : entity)
  };
  assert.throws(() => generator.buildPublicDataset(tampered), /outputChecksum does not match/);
});
