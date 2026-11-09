import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const runtime = JSON.parse(await readFile(new URL("../../../YouNew/Resources/Data/younew-runtime-data.json", import.meta.url), "utf8"));
const { buildPublicDataset } = await import("../scripts/generate-public-content.mjs");
const hotel = {
  ...runtime.entities[0],
  id: "hotel.synthetic-catalog-test",
  kind: "hotel",
  title: "Synthetic hotel fixture",
  category: "hotel",
  coordinate: null,
  images: [],
  governance: null,
  attributes: { ...runtime.entities[0].attributes, lifecycleStatus: "published" },
  publicationStatus: "published"
};
function project(entity: typeof hotel) {
  return buildPublicDataset({ ...runtime, entities: [entity] }, { verifyChecksum: false }).content;
}
test("the existing hotel kind projects as a place without inventing coordinates, media or affiliation", () => {
  const output = project(hotel);
  const record = output.entities.find((item: {id: string}) => item.id === hotel.id);
  assert.ok(record, "a supported hotel must not silently disappear from web projection");
  assert.equal(record.type, "place");
  assert.equal(record.sourceKind, "hotel");
  assert.equal(record.narrowCategory, "hotel");
  assert.deepEqual(record.categorySlugs, ["local-services"]);
  assert.match(record.route, /^\/places\//);
  assert.equal(record.coordinate, null);
  assert.deepEqual(record.images, []);
  assert.equal("sponsored" in record, false);
  assert.equal("verifiedOrganization" in record, false);
});
test("hotel projection still rejects draft and unverified records", () => {
  for (const entity of [
    { ...hotel, publicationStatus: "preview" },
    { ...hotel, attributes: { ...hotel.attributes, lifecycleStatus: "draft" } },
    { ...hotel, verificationStatus: "unverified" },
    { ...hotel, source: { ...hotel.source, status: "unavailable" } }
  ]) assert.equal(project(entity).entities.length, 0);
});
