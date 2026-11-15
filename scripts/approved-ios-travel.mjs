// Explicit owner-approved LOCAL TEST projection. Never used by the web/release export.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { resolve, relative } from 'node:path';
import { createHash } from 'node:crypto';
export const travelApprovalPath = 'DataProject/editorial/travel-ios-local-20261115-approval.json';
export const travelSelectionHash = 'd00afc1621010eba612be3dc397c08a3b0f3a2633538fbe825697b00b8e0dca7';
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const https = value => { const u = new URL(value); assert.ok(u.protocol === 'https:' && !u.username && !u.password); return value; };
const fields = ['id','entity_type','category','city_id','province_id','title','description','official_source','website','last_checked','review_frequency_days','search_keywords','description_nl'];

export async function applyApprovedTravel(base, release, root) {
  const read = async path => readFile(resolve(root, path));
  const approvalBytes = await read(travelApprovalPath);
  const approval = JSON.parse(approvalBytes);
  assert.equal(approval.status, 'approved', 'Human approval required');
  assert.equal(approval.releaseId, 'ios-travel-local-test-20261115');
  assert.equal(approval.scope.platform, 'ios');
  assert.equal(approval.scope.environment, 'local-test');
  for (const key of ['otherDraftFields','wholeBatchPublication','productionDeployment','testFlight','appStoreConnect','automaticMerge']) assert.equal(approval.scope[key], false);
  const registry = JSON.parse(await read('DataProject/operations/reviewer-registry.json'));
  const reviewer = registry.reviewers.find(r => r.id === approval.reviewerId);
  assert.ok(!registry.policy.automated_reviewers_allowed && reviewer?.active && reviewer.reviewer_type === 'official_owner');
  assert.ok(reviewer.locales.includes('en') && reviewer.locales.includes('nl'));
  assert.match(approval.approvedAt, /^\d{4}-\d{2}-\d{2}$/);
  assert.ok(approval.approvedAt <= new Date().toISOString().slice(0, 10));
  assert.equal(approval.selectionPath, 'docs/younew-upgrade/TRAVEL_APPROVAL_SELECTION_2026-11-15.json');
  assert.equal(approval.selectionSha256, travelSelectionHash, 'Approval cannot widen the human-approved hash');
  const selectionBytes = await read(approval.selectionPath);
  assert.equal(hash(selectionBytes), travelSelectionHash, 'Approved selection changed');
  const selection = JSON.parse(selectionBytes);
  assert.equal(selection.publicationAuthorized, false); // Historical selection remains a draft.
  const verifiedFiles = new Map();
  async function verifyBindings(value) {
    if (Array.isArray(value)) { for (const v of value) await verifyBindings(v); return; }
    if (!value || typeof value !== 'object') return;
    if (value.path && value.sha256) {
      assert.ok(!relative(root, resolve(root, value.path)).startsWith('..') && !value.path.startsWith('/'));
      const bytes = verifiedFiles.get(value.path) ?? await read(value.path);
      assert.equal(hash(bytes), value.sha256, `Approved source/media changed: ${value.path}`);
      if (value.bytes !== undefined) assert.equal(bytes.length, value.bytes);
      verifiedFiles.set(value.path, bytes);
    }
    for (const v of Object.values(value)) await verifyBindings(v);
  }
  await verifyBindings(selection);
  for (const [kind, count] of Object.entries({records:57, photos:32, coordinates:33, collections:6})) {
    const entries = kind === 'collections' ? selection.collections.items : selection[kind];
    assert.equal(entries.length, count);
    assert.equal(new Set(entries.map(e => e.id)).size, count);
    assert.deepEqual(approval.scope[kind], entries.map(e => e.id), 'Approval scope mismatch');
  }
  const result = structuredClone(base);
  result.mode = 'local-test';
  result.releaseID = approval.releaseId;
  const entities = new Map(result.entities.map(e => [e.id, e]));
  const needed = new Set([...selection.photos.map(p => p.id), ...selection.collections.items.flatMap(c => c.entityIDs)]);
  const selectedIDs = new Set(selection.records.map(r => r.id));
  for (const id of needed) {
    if (entities.has(id) || selectedIDs.has(id)) continue;
    const approved = release.entities.find(e => e.id === id);
    assert.ok(approved, `Collection/photo base has no prior approval: ${id}`);
    entities.set(id, structuredClone(approved));
  }
  for (const entry of selection.records) {
    const r = entry.fields;
    assert.deepEqual(Object.keys(r).sort(), [...fields].sort(), 'Unapproved record field');
    const source = JSON.parse(verifiedFiles.get(entry.primarySourceEvidence.path));
    assert.equal(source.status, 'opened');
    assert.equal(r.official_source.status, 'verified_opened');
    assert.ok(r.official_source.is_official && r.description && r.description_nl);
    const age = (Date.now() - Date.parse(r.last_checked + 'T00:00:00Z')) / 86400000;
    assert.ok(age >= 0 && age <= r.review_frequency_days, 'Source evidence requires refresh and approval');
    entities.set(r.id, {id:r.id,kind:r.entity_type === 'nature' ? 'park' : r.entity_type,
      title:r.title,summary:r.description,cityId:r.city_id,provinceId:r.province_id,category:r.category,
      coordinate:null,source:{title:r.official_source.title,publisher:r.official_source.publisher,
        url:https(r.official_source.url),checkedAt:r.last_checked,status:'verified_opened',isOfficial:true},
      lastChecked:r.last_checked,images:[],aiSummary:r.description,relatedEntityIDs:[],
      attributes:{description_nl:r.description_nl,website:https(r.website),iosLocalTest:'true'},
      keywords:r.search_keywords,publicationStatus:'published',verificationStatus:'verified'});
  }
  for (const entry of selection.coordinates) {
    const target = entities.get(entry.id); assert.ok(target);
    const evidence = JSON.parse(verifiedFiles.get(entry.evidence.path));
    assert.ok(evidence.addressMatched && evidence.bag.bron === 'BAG');
    assert.deepEqual(entry.coordinate, evidence.coordinate);
    const [lon, lat] = evidence.bag.centroide_ll.match(/[-\d.]+/g).map(Number);
    assert.deepEqual(entry.coordinate, {latitude:lat,longitude:lon});
    assert.ok(lat >= 50.7 && lat <= 53.7 && lon >= 3.2 && lon <= 7.3);
    target.coordinate = entry.coordinate;
    target.attributes.address = entry.address;
    target.attributes.iosCoordinateAccuracy = 'bag-address-centroid';
    target.attributes.iosCoordinateEvidence = JSON.stringify({url:https(evidence.url),checkedAt:evidence.checkedAt,method:entry.method,license:'CC0 1.0',source:'Kadaster / PDOK, BAG'});
  }
  for (const entry of selection.photos) {
    const target = entities.get(entry.id); assert.ok(target);
    const oldEvidence = JSON.parse(verifiedFiles.get(entry.previousEvidence.path));
    const file = entry.files.find(f => f.width === 1200); assert.ok(file);
    const bundledFileName = `approved-travel-${entry.id}-1200.webp`;
    result.mediaFiles.push({sourceFile:file.path,bundledFileName,sha256:file.sha256});
    target.images = [{id:`approved-travel-${entry.id}`,role:'hero',assetURL:https(oldEvidence.originalURL),
      sourcePageURL:https(entry.sourceURL),license:entry.license,licenseURL:https(entry.licenseURL),
      attribution:`${entry.attribution} Capture: ${entry.captureDate}.`,author:entry.author,
      verified:true,retrievedAt:approval.approvedAt,bundledFileName}];
  }
  result.entities = [...entities.values()];
  result.collections = selection.collections.items.map(c => {
    assert.ok(c.entityIDs.every(id => entities.has(id)), 'Unresolved collection member');
    return {id:c.id,cityId:c.city,title:c.title,entityIDs:c.entityIDs};
  });
  result.travelApproval = {path:travelApprovalPath,sha256:hash(approvalBytes),selectionSha256:travelSelectionHash,
    reviewerId:approval.reviewerId,approvedAt:approval.approvedAt,environment:'local-test'};
  return result;
}
