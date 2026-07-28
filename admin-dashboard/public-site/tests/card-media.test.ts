import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
import test from "node:test";
import { cardMediaForEntity } from "../src/lib/content/card-media.ts";
import type { ContentEntity } from "../src/lib/content/types.ts";

const siteRoot = new URL("../", import.meta.url);
const content = JSON.parse(await readFile(new URL("src/generated/public-content.json", siteRoot), "utf8")) as {
  datasetFingerprint: string;
  entities: ContentEntity[];
};
const manifest = JSON.parse(await readFile(new URL("public/data/card-image-manifest.json", siteRoot), "utf8")) as {
  datasetFingerprint: string;
  entries: Array<{ entityId: string; localPath: string; sha256: string }>;
};

test("every published entity has a distinct local card image with attribution", async () => {
  assert.ok(content.entities.length > 0);
  assert.equal(manifest.datasetFingerprint, content.datasetFingerprint);
  assert.equal(manifest.entries.length, content.entities.length);

  const paths = new Set<string>();
  for (const entity of content.entities) {
    const media = cardMediaForEntity(entity);
    assert.ok(media, `Missing card media for ${entity.id}`);
    assert.ok(media.alt.length > 0);
    assert.match(media.sourceUrl, /^https:\/\//);
    assert.match(media.licenseUrl, /^https:\/\/creativecommons\.org\//);
    assert.ok(!paths.has(media.src), `Duplicate card media path: ${media.src}`);
    paths.add(media.src);
    await access(new URL(`public${media.src}`, siteRoot));
  }

  assert.equal(paths.size, content.entities.length);
  assert.equal(new Set(manifest.entries.map((entry) => entry.localPath)).size, content.entities.length);
  assert.ok(manifest.entries.every((entry) => /^[a-f0-9]{64}$/.test(entry.sha256)));
});
