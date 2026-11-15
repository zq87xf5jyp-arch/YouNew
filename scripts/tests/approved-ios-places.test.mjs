import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { projectApprovedPlaces, aliases } from '../export-approved-ios-places.mjs';
import { loadEditorialRelease } from '../../admin-dashboard/public-site/scripts/editorial-release.mjs';

test('bundle is an exact approved projection, preserving identities and unknown coordinates', async () => {
  const artifact = await projectApprovedPlaces();
  const bundled = JSON.parse(await readFile(new URL('../../YouNew/Resources/Data/younew-approved-places.json', import.meta.url)));
  assert.deepEqual(bundled, artifact);
  const release = await loadEditorialRelease();
  assert.equal(artifact.entities.length, 7);
  assert.equal(artifact.entities.filter(entity => entity.coordinate !== null).length, 2);
  assert.equal(new Set(Object.values(aliases)).size, 7);
  for (const entity of artifact.entities) {
    const source = release.entities.find(item => item.id === entity.id);
    assert.deepEqual(entity, { ...source, attributes: { ...source.attributes, iosLegacyPlaceID: aliases[source.id] } });
    assert.deepEqual(entity.coordinate, source.coordinate);
    assert.deepEqual(entity.images, []);
    assert.ok(entity.editorial.locales.en.summary && entity.editorial.locales.nl.summary);
  }
});

test('private review environment is rejected rather than exported', async () => {
  const previous = process.env.YOUNEW_PLACE_REVIEW;
  try {
    process.env.YOUNEW_PLACE_REVIEW = 'leiden-places-20261115';
    await assert.rejects(projectApprovedPlaces(), /Private review/);
  } finally {
    if (previous === undefined) delete process.env.YOUNEW_PLACE_REVIEW;
    else process.env.YOUNEW_PLACE_REVIEW = previous;
  }
});
