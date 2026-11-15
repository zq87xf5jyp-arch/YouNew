import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { projectApprovedPlaces, aliases } from '../export-approved-ios-places.mjs';
import { loadEditorialRelease } from '../../admin-dashboard/public-site/scripts/editorial-release.mjs';

test('bundle is an exact approved projection, preserving every field outside the exact owner-approved completion', async () => {
  const artifact = await projectApprovedPlaces();
  const bundled = JSON.parse(await readFile(new URL('../../YouNew/Resources/Data/younew-approved-places.json', import.meta.url)));
  assert.deepEqual(bundled, artifact);
  const release = await loadEditorialRelease();
  assert.equal(artifact.entities.length, 12);
  assert.equal(artifact.entities.filter(entity => entity.coordinate !== null).length, 7);
  assert.equal(new Set(Object.values(aliases)).size, 12);
  assert.equal(artifact.entities.filter(entity => entity.images.length === 1).length, 4);
  assert.equal(artifact.entities.filter(entity => entity.attributes.iosTicketURL).length, 6);
  const selection = JSON.parse(await readFile(new URL('../../docs/younew-upgrade/LEIDEN_COMPLETION_SELECTION_2026-11-15.json', import.meta.url)));
  for (const entity of artifact.entities) {
    const source = release.entities.find(item => item.id === entity.id);
    const unchanged = structuredClone(entity);
    unchanged.coordinate = source.coordinate;
    unchanged.images = source.images;
    for (const key of ['iosCoordinateEvidence','iosTicketURL','iosTicketSourceURL','iosTicketCheckedAt']) delete unchanged.attributes[key];
    assert.deepEqual(unchanged, { ...source, attributes: { ...source.attributes, iosLegacyPlaceID: aliases[source.id] } });
    const coordinate = selection.coordinates.find(item => item.id === entity.id);
    assert.deepEqual(entity.coordinate, coordinate?.coordinate ?? source.coordinate);
    const ticket = selection.tickets.find(item => item.id === entity.id);
    assert.equal(entity.attributes.iosTicketURL, ticket?.url);
    const photo = selection.photos.find(item => item.id === entity.id);
    assert.equal(entity.images.length, photo ? 1 : 0);
    if (photo) {
      assert.equal(entity.images[0].sourcePageURL, photo.sourcePage);
      assert.equal(entity.images[0].license, photo.license);
      assert.equal(entity.images[0].attribution, photo.attribution);
    }
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
