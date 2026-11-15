import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
import { readPlaceReview } from '../../admin-dashboard/public-site/scripts/place-review.mjs';
const root = fileURLToPath(new URL('../../', import.meta.url));
const digest = bytes => createHash('sha256').update(bytes).digest('hex');

test('completion selection binds four licensed photos, five coordinates and six ticket URLs without granting approval', async () => {
  const selection = JSON.parse(await readFile(resolve(root, 'docs/younew-upgrade/LEIDEN_COMPLETION_SELECTION_2026-11-15.json')));
  assert.equal(selection.publicationAuthorized, false);
  assert.equal(selection.status, 'needs_review');
  assert.equal(selection.reviewerId, null);
  assert.equal(selection.approvedAt, null);
  const records = new Map();
  for (const [batch, hashes] of Object.entries(selection.sourcePackages)) {
    const path = resolve(root, 'DataProject/editorial', batch);
    assert.equal(digest(await readFile(resolve(path, 'records.json'))), hashes.recordsSha256);
    assert.equal(digest(await readFile(resolve(path, 'manifest.json'))), hashes.manifestSha256);
    for (const record of (await readPlaceReview(root, batch)).records) records.set(record.id, record);
  }
  assert.equal(selection.photos.length, 4);
  assert.equal(selection.coordinates.length, 5);
  assert.equal(selection.tickets.length, 6);
  for (const list of [selection.photos, selection.coordinates, selection.tickets]) {
    assert.equal(new Set(list.map(item => item.id)).size, list.length);
  }
  for (const photo of selection.photos) {
    const image = records.get(photo.id).images[0];
    assert.equal(photo.sourcePage, image.source_page_url);
    assert.equal(photo.licenseURL, image.license_url);
    assert.equal(photo.attribution, image.attribution);
    assert.equal(Object.keys(photo.files).length, 3);
    for (const [file, proof] of Object.entries(photo.files)) {
      const bytes = await readFile(resolve(root, file));
      assert.equal(digest(bytes), proof.sha256);
      assert.equal(bytes.length, proof.bytes);
    }
  }
  for (const coordinate of selection.coordinates) {
    assert.deepEqual(coordinate.coordinate, records.get(coordinate.id).coordinates);
    assert.deepEqual(coordinate.evidence, JSON.parse(records.get(coordinate.id).attributes.place_enrichment).coordinateEvidence);
  }
  for (const ticket of selection.tickets) {
    assert.equal(ticket.url, JSON.parse(records.get(ticket.id).attributes.place_enrichment).tickets.url);
    assert.equal(ticket.httpStatus, 200);
    assert.equal(new URL(ticket.finalURL).protocol, 'https:');
  }
});
