// Field-scoped owner approval. Historical review packages must stay unpublished.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { resolve, basename } from 'node:path';
import { createHash } from 'node:crypto';
import { readPlaceReview } from '../admin-dashboard/public-site/scripts/place-review.mjs';
export const approvalPath = 'DataProject/editorial/leiden-ios-completion-20261115-approval.json';
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const https = value => {
  const url = new URL(value);
  assert.ok(url.protocol === 'https:' && !url.username && !url.password, 'Unsafe approved URL');
  return value;
};

export async function applyApprovedCompletion(entities, root) {
  const approvalBytes = await readFile(resolve(root, approvalPath));
  const approval = JSON.parse(approvalBytes);
  assert.equal(approval.schemaVersion, 1);
  assert.equal(approval.releaseId, 'ios-leiden-completion-20261115');
  assert.equal(approval.status, 'approved', 'Explicit owner approval required');
  assert.equal(approval.scope.platform, 'ios');
  for (const key of ['otherDraftFields', 'wholeBatchPublication', 'productionDeployment']) assert.equal(approval.scope[key], false);
  assert.match(approval.approvedAt, /^\d{4}-\d{2}-\d{2}$/);
  assert.ok(approval.approvedAt <= new Date().toISOString().slice(0,10));
  const registry = JSON.parse(await readFile(resolve(root, 'DataProject/operations/reviewer-registry.json')));
  const reviewer = registry.reviewers.find(item => item.id === approval.reviewerId);
  assert.ok(registry.policy.automated_reviewers_allowed === false && reviewer?.active && reviewer.reviewer_type === 'official_owner', 'Registered human owner required');
  assert.equal(approval.selectionPath, 'docs/younew-upgrade/LEIDEN_COMPLETION_SELECTION_2026-11-15.json');
  const bytes = await readFile(resolve(root, approval.selectionPath));
  assert.equal(hash(bytes), approval.selectionSha256, 'Approved selection changed');
  const selection = JSON.parse(bytes);
  assert.equal(selection.status, 'needs_review');
  assert.equal(selection.publicationAuthorized, false);
  const records = new Map();
  for (const [batch, proof] of Object.entries(selection.sourcePackages)) {
    assert.ok(['leiden-places-20261115','leiden-nature-culture-20261115'].includes(batch));
    const path = resolve(root, 'DataProject/editorial', batch);
    assert.equal(hash(await readFile(resolve(path, 'records.json'))), proof.recordsSha256, 'Approved source changed');
    assert.equal(hash(await readFile(resolve(path, 'manifest.json'))), proof.manifestSha256, 'Approved manifest changed');
    for (const record of (await readPlaceReview(root, batch)).records) records.set(record.id, record);
  }
  const result = structuredClone(entities);
  const mediaFiles = [];
  for (const [kind, count] of Object.entries({ photos: 4, coordinates: 5, tickets: 6 })) {
    const entries = selection[kind];
    assert.equal(entries.length, count);
    assert.equal(new Set(entries.map(e => e.id)).size, count);
    assert.deepEqual(approval.scope[kind], entries.map(e => e.id), 'Approval scope mismatch');
    for (const entry of entries) {
      const target = result.find(e => e.id === entry.id);
      const record = records.get(entry.id);
      assert.ok(target && record && target.cityId === 'leiden', 'Only existing Leiden cards may change');
      assert.ok(reviewer.categories.includes(record.category));
      const enrichment = JSON.parse(record.attributes.place_enrichment);
      if (kind === 'photos') {
        const image = record.images[0];
        assert.equal(image.source_page_url, entry.sourcePage);
        assert.equal(image.license, entry.license);
        assert.equal(image.license_url, entry.licenseURL);
        assert.equal(image.attribution, entry.attribution);
        for (const [file, proof] of Object.entries(entry.files)) {
          assert.match(file, /^DataProject\/editorial\/leiden-(places|nature-culture)-20261115\/media\/[a-z]+-(480|800|1200)\.webp$/);
          const data = await readFile(resolve(root, file));
          assert.equal(hash(data), proof.sha256, 'Approved image changed');
          assert.equal(data.length, proof.bytes);
        }
        const sourceFile = Object.keys(entry.files).find(file => file.endsWith('-1200.webp'));
        assert.ok(sourceFile);
        const bundledFileName = `approved-leiden-${basename(sourceFile)}`;
        mediaFiles.push({ sourceFile, bundledFileName, sha256: entry.files[sourceFile].sha256 });
        target.images = [{ id: image.id, role: 'hero', assetURL: https(image.asset_url),
          sourcePageURL: https(entry.sourcePage), license: entry.license, licenseURL: https(entry.licenseURL),
          attribution: entry.attribution, author: entry.attribution.split(' · ')[0],
          verified: true, retrievedAt: image.retrieved_at, bundledFileName }];
      } else if (kind === 'coordinates') {
        assert.deepEqual(entry.coordinate, record.coordinates);
        assert.deepEqual(entry.evidence, enrichment.coordinateEvidence);
        https(entry.evidence.url);
        target.coordinate = entry.coordinate;
        target.attributes.iosCoordinateEvidence = JSON.stringify(entry.evidence);
      } else {
        assert.equal(entry.url, enrichment.tickets.url);
        const source = enrichment.sources.find(s => s.id === enrichment.tickets.sourceId);
        assert.ok(source && source.url === entry.sourceURL && source.is_official);
        target.attributes.iosTicketURL = https(entry.url);
        target.attributes.iosTicketSourceURL = https(entry.sourceURL);
        target.attributes.iosTicketCheckedAt = entry.checkedAt;
      }
    }
  }
  return { entities: result, mediaFiles, completionApproval: {
    path: approvalPath, sha256: hash(approvalBytes), selectionSha256: approval.selectionSha256,
    reviewerId: approval.reviewerId, approvedAt: approval.approvedAt
  } };
}
