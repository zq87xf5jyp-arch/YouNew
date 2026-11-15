import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile, writeFile, mkdir, mkdtemp, copyFile, rm } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { tmpdir } from 'node:os';
import { fileURLToPath } from 'node:url';
import { projectApprovedPlaces } from '../export-approved-ios-places.mjs';
import { applyApprovedTravel, travelApprovalPath, travelSelectionHash } from '../approved-ios-travel.mjs';
import { loadEditorialRelease } from '../../admin-dashboard/public-site/scripts/editorial-release.mjs';
const root = fileURLToPath(new URL('../../', import.meta.url));
const selectionPath = 'docs/younew-upgrade/TRAVEL_APPROVAL_SELECTION_2026-11-15.json';
const selection = JSON.parse(await readFile(resolve(root, selectionPath)));
const base = await projectApprovedPlaces();
const release = await loadEditorialRelease();
const files = new Set([travelApprovalPath, selectionPath, 'DataProject/operations/reviewer-registry.json']);
function collect(value) {
  if (!value || typeof value !== 'object') return;
  if (value.path && value.sha256) files.add(value.path);
  for (const child of Object.values(value)) collect(child);
}
collect(selection);
async function rejectsMutation(change, pattern) {
  const temp = await mkdtemp(resolve(tmpdir(), 'younew-travel-test-'));
  try {
    for (const file of files) {
      const destination = resolve(temp, file);
      await mkdir(dirname(destination), {recursive:true});
      await copyFile(resolve(root,file), destination);
    }
    await change(temp);
    await assert.rejects(applyApprovedTravel(base,release,temp),pattern);
  } finally { await rm(temp,{recursive:true,force:true}); }
}
async function changeApproval(temp, mutate) {
  const path=resolve(temp,travelApprovalPath); const value=JSON.parse(await readFile(path));
  mutate(value); await writeFile(path,JSON.stringify(value));
}
test('local candidate projects exactly approved scope; production and legacy tickets remain unchanged', async()=>{
  const local=await projectApprovedPlaces(root,{localTest:true});
  assert.equal(local.mode,'local-test');
  assert.equal(local.entities.length,85);
  assert.equal(local.mediaFiles.length,36);
  assert.equal(local.collections.length,6);
  assert.equal(local.entities.filter(e=>e.attributes.iosCoordinateAccuracy==='bag-address-centroid').length,33);
  assert.equal(local.entities.filter(e=>e.attributes.iosTicketURL).length,6);
  assert.equal(local.travelApproval.selectionSha256,travelSelectionHash);
  for (const entity of base.entities) assert.deepEqual(local.entities.find(e=>e.id===entity.id),entity);
  assert.deepEqual(JSON.parse(await readFile(resolve(root,'YouNew/Resources/Data/younew-approved-places.json'))),base);
  assert.deepEqual(JSON.parse(await readFile(resolve(root,'YouNew/Resources/Data/younew-approved-local-test.json'))),local);
  for (const item of selection.records) {
    const entity=local.entities.find(e=>e.id===item.id);
    assert.equal(entity.summary,item.fields.description);
    assert.equal(entity.attributes.description_nl,item.fields.description_nl);
    assert.equal(entity.attributes.iosTicketURL,undefined);
    assert.equal(entity.attributes.opening_hours,undefined);
  }
  for (const collection of local.collections) assert.ok(collection.entityIDs.every(id=>local.entities.some(e=>e.id===id)));
  for (const id of selection.unresolvedSources) assert.ok(!local.entities.some(e=>e.id===id));
  for (const rejected of selection.unresolvedCoordinates) assert.equal(local.entities.find(e=>e.id===rejected.id).coordinate,null);
});
test('local media matches approved bytes, attribution and license; rejected foam stays absent', async()=>{
  const local=await projectApprovedPlaces(root,{localTest:true});
  for (const media of local.mediaFiles) assert.deepEqual(await readFile(resolve(root,media.sourceFile)),await readFile(resolve(root,'YouNew/Resources/Data/ApprovedLeidenMedia',media.bundledFileName)));
  for (const photo of selection.photos) {
    const image=local.entities.find(e=>e.id===photo.id).images[0];
    assert.equal(image.author,photo.author);assert.equal(image.licenseURL,photo.licenseURL);
    assert.ok(image.attribution.includes(photo.captureDate));
  }
  assert.ok(!local.mediaFiles.some(f=>f.bundledFileName.includes('museum.foam')));
});
test('missing or widened owner permission fails closed', async()=>{
  await rejectsMutation(t=>changeApproval(t,a=>a.status='needs_review'),/Human approval/);
  await rejectsMutation(t=>changeApproval(t,a=>a.scope.environment='production'),/Expected values/);
  await rejectsMutation(t=>changeApproval(t,a=>a.scope.photos.pop()),/Approval scope mismatch/);
  await rejectsMutation(t=>changeApproval(t,a=>a.reviewerId='robot'),/assert/);
});
test('changed selection, source and derivative bytes fail closed', async()=>{
  await rejectsMutation(t=>writeFile(resolve(t,selectionPath),'{}'),/Approved selection changed/);
  await rejectsMutation(t=>writeFile(resolve(t,selection.records[0].source.path),'{}'),/Approved source\/media changed/);
  await rejectsMutation(t=>writeFile(resolve(t,selection.photos[0].files[0].path),'wrong image'),/Approved source\/media changed/);
});
