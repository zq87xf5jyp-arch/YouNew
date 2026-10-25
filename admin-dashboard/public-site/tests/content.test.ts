import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const siteRoot = new URL("../", import.meta.url);
const content = JSON.parse(await readFile(new URL("src/generated/public-content.json", siteRoot), "utf8"));
const provenance = JSON.parse(await readFile(new URL("public/data/content-provenance.json", siteRoot), "utf8"));
const freshnessExclusions = JSON.parse(await readFile(new URL("src/generated/public-freshness-exclusions.json", siteRoot), "utf8"));
const legacyConfirmations = JSON.parse(await readFile(new URL("../../DataProject/quality/phase6-1-public-record-confirmations.json", siteRoot), "utf8"));
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
  assert.deepEqual(provenance.acceptedReleaseIds, ["amsterdam-v0.1.8", "cities-v0.1.0"]);
  assert.equal(content.stats.entities, provenance.counts.acceptedRecords);
  assert.equal(content.entities.length, content.stats.entities);
  assert.equal(freshnessExclusions.count, 170);
  assert.equal(provenance.counts.freshnessExcludedRecords, 170);
  const excludedIds = new Set(freshnessExclusions.records.map((record: { id: string }) => record.id));
  assert.ok(content.entities.every((entity: { id: string }) => !excludedIds.has(entity.id)));
  assert.ok(content.entities.every((entity: { status: string; releaseId: string; trust: { sourceChecked: boolean } }) =>
    entity.status === "published" &&
    provenance.acceptedReleaseIds.includes(entity.releaseId) &&
    entity.trust.sourceChecked === true
  ));
  assert.ok(!content.entities.some((entity: { id: string }) =>
    entity.id === "event.worldpride-amsterdam-2026-pride-walk" ||
    entity.id === "event.worldpride-amsterdam-2026-pride-park" ||
    entity.id === "event.worldpride-amsterdam-2026-open-air-film-festival" ||
    entity.id === "event.worldpride-amsterdam-2026-senior-pride-concert" ||
    entity.id === "event.worldpride-amsterdam-2026-canal-parade" ||
    entity.id === "restaurant.breda"
  ));
  const governedIds = content.entities
    .filter((entity: { governance: unknown }) => entity.governance !== null)
    .map((entity: { id: string }) => entity.id)
    .sort();
  assert.deepEqual(governedIds, legacyConfirmations.records.map((record: { id: string }) => record.id).sort());
  for (const entity of content.entities.filter((item: { id: string }) => governedIds.includes(item.id))) {
    assert.equal(entity.governance.confidenceScore, 65);
    assert.equal(entity.governance.verificationStatus, "unverified");
    assert.equal(entity.indexable, false);
    assert.equal(entity.governance.reviewedBy, null);
    assert.equal(entity.governance.confidenceBreakdown.humanReviewer, 0);
    assert.equal(entity.governance.confidenceBreakdown.independentReview, 0);
    assert.equal(entity.governance.officialSourceURL, entity.source.url);
    assert.equal(entity.source.checkedAt, entity.governance.lastVerifiedAt);
  }
  const drivingLicence = content.entities.find((entity: { id: string }) => entity.id === "government_service.driving-licence-amsterdam");
  assert.equal(drivingLicence?.governance ?? null, null);
  assert.equal(drivingLicence?.indexable, true);
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
    category.entityCount >= 0 && category.entityCount === category.entityIds.length
  ));
  assert.ok(content.categories.filter((category: { entityCount: number }) => category.entityCount === 0).length >= 20);
  assert.ok(content.provinces.every((province: { entityCount: number; entityIds: string[] }) =>
    province.entityCount > 0 && province.entityCount === province.entityIds.length
  ));
});

test("the public website exposes the verified app image catalogue", () => {
  const media = content.entities.flatMap((entity: { images: unknown[] }) => entity.images);
  assert.ok(media.length > 0, `expected images on the remaining current public records, received ${media.length}`);
  assert.equal(media.some((image: { id?: string }) => image.id === "media.museum.amsterdam-museum.thumbnail.3e34aacbba"), false);
  assert.ok(content.entities.every((entity: { title: string; images: Array<{ role: string; url: string; alt: string }> }) =>
    entity.images.some((image) => image.role === "hero") &&
    entity.images.every((image) =>
      /^https?:\/\//.test(image.url) &&
      image.alt.length > 0 &&
      image.alt !== `${entity.title} — ${image.role.replace("_", " ")}`
    )
  ));
});

test("local partners are source-checked but never promoted to sponsored or verified organizations", () => {
  const partners = content.organizations.filter((entity: { sourceKind: string }) => entity.sourceKind === "localPartner");
  assert.equal(partners.length, 0, "stale local partners must stay out of public output until field-level reverification");
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

test("legacy governance confirmations fail closed when their release or source binding changes", () => {
  type RuntimeEntity = {
    id: string;
    source: Record<string, unknown>;
    attributes: Record<string, unknown>;
  };
  const runtimeEntities = canonicalRuntime.entities as RuntimeEntity[];
  const amsterdam = runtimeEntities.find((entity) => entity.id === "city.amsterdam");
  assert.ok(amsterdam);
  const withSourceMismatch = {
    ...canonicalRuntime,
    entities: runtimeEntities.map((entity) => entity.id === amsterdam.id
      ? { ...entity, source: { ...entity.source, url: "https://www.amsterdam.nl/en/" } }
      : entity)
  };
  assert.throws(
    () => generator.buildPublicDataset(withSourceMismatch, { verifyChecksum: false }),
    /source URL mismatch/
  );

  const withReleaseMismatch = {
    ...canonicalRuntime,
    entities: runtimeEntities.map((entity) => entity.id === amsterdam.id
      ? { ...entity, attributes: { ...entity.attributes, dataProjectRelease: "amsterdam-v0.1.8" } }
      : entity)
  };
  assert.throws(
    () => generator.buildPublicDataset(withReleaseMismatch, { verifyChecksum: false }),
    /release mismatch/
  );
});
