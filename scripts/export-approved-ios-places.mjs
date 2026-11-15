/** Deterministic iOS projection of the SAME owner-approved release used by web.
 * Never edit the generated JSON; change/reapprove upstream content instead.
 */
import assert from 'node:assert/strict';
import { readFile, writeFile, mkdir, copyFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
import { applyApprovedCompletion } from './approved-ios-completion.mjs';
import { loadEditorialRelease } from '../admin-dashboard/public-site/scripts/editorial-release.mjs';

export const aliases = {
  'place.leiden-lakenhal': 'leiden-seed-museum-de-lakenhal',
  'place.leiden-hortus': 'leiden-seed-hortus-botanicus',
  'place.leiden-burcht': 'leiden-seed-burcht-van-leiden',
  'place.leiden-rmo': 'leiden-seed-rijksmuseum-van-oudheden',
  'place.leiden-naturalis': 'leiden-seed-naturalis-biodiversity-center',
  'museum.leiden-boerhaave': 'leiden-seed-rijksmuseum-boerhaave',
  'museum.leiden-wereldmuseum': 'leiden-seed-wereldmuseum-leiden',
  'restaurant.leiden-bikini': 'leiden-seed-bikini-bikini',
  'restaurant.leiden-in-den-doofpot': 'leiden-seed-restaurant-in-den-doofpot',
  'restaurant.leiden-verboden-toegang': 'leiden-seed-restaurant-verboden-toegang',
  'restaurant.leiden-prentenkabinet': 'leiden-seed-het-prentenkabinet',
  'restaurant.leiden-oudt-leyden': 'leiden-seed-oudt-leyden'
};
const root = fileURLToPath(new URL('../', import.meta.url));
export async function projectApprovedPlaces(repositoryRoot = root) {
  assert.ok(!process.env.YOUNEW_PLACE_REVIEW, 'Private review cannot enter the iOS bundle');
  const release = await loadEditorialRelease(repositoryRoot);
  const entities = Object.entries(aliases).map(([id, legacyID]) => {
    const entity = release.entities.find(item => item.id === id);
    assert.ok(entity && !entity.editorial.placeReview, `Missing approved base record: ${id}`);
    assert.equal(entity.cityId, 'leiden');
    assert.equal(entity.images.length, 0, 'This release did not approve new photos');
    assert.ok(entity.attributes.description_nl && entity.attributes.address);
    return { ...entity, attributes: { ...entity.attributes, iosLegacyPlaceID: legacyID } };
  });
  const completion = await applyApprovedCompletion(entities, repositoryRoot);
  return { schemaVersion: 1, mode: 'production', releaseID: release.id,
    approvedBatchSha256: release.batchSha256, migrationRegistry: {}, withheldEntityIDs: [], ...completion };
}
if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const output = resolve(root, 'YouNew/Resources/Data/younew-approved-places.json');
  const artifact = await projectApprovedPlaces();
  const content = JSON.stringify(artifact, null, 2) + '\n';
  const mediaDirectory = resolve(root, 'YouNew/Resources/Data/ApprovedLeidenMedia');
  for (const media of artifact.mediaFiles) {
    const source = resolve(root, media.sourceFile);
    const destination = resolve(mediaDirectory, media.bundledFileName);
    if (process.argv.includes('--check')) assert.deepEqual(await readFile(destination), await readFile(source), 'Bundled approved image changed');
    else { await mkdir(mediaDirectory, { recursive: true }); await copyFile(source, destination); }
  }
  if (process.argv.includes('--check')) assert.equal(await readFile(output, 'utf8'), content, 'Regenerate approved iOS projection');
  else await writeFile(output, content);
  console.log('Approved iOS projection: 12 approved Leiden places; exactly 4 photos, 5 coordinates, 6 ticket links approved.');
}
