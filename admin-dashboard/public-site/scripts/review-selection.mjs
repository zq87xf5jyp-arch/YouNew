// Editorial evidence only. This module is deliberately not imported by release
// generators: a selection or a composed review is never publication approval.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {resolve,relative,isAbsolute} from 'node:path';
import {sha256,validateMediaOnlyRecords} from './place-review.mjs';

export async function verifyReviewSelection(root,selectionPath,expectedSha256) {
  const bytes=await readFile(resolve(root,selectionPath));
  assert.equal(sha256(bytes),expectedSha256,'selection digest changed');
  const selection=JSON.parse(bytes);
  assert.equal(selection.status,'needs_review');
  assert.equal(selection.publicationAuthorized,false);
  assert.equal(selection.approvedAt,null);assert.equal(selection.reviewerId,null);
  assert.match(selection.sourceCommit,/^[a-f0-9]{40}$/);
  for(const [file,proof] of Object.entries(selection.files)) {
    const path=resolve(root,file),rel=relative(resolve(root),path);
    assert.ok(!isAbsolute(file)&&!rel.startsWith('..'),'selection path escapes repository');
    const data=await readFile(path);
    assert.equal(data.length,proof.bytes,`selection size changed: ${file}`);
    assert.equal(sha256(data),proof.sha256,`selection material changed: ${file}`);
  }
  return selection;
}

// Conservative, deterministic three-way composition for future human review.
// Only a proven media-only delta can be overlaid on an exact text revision.
// Conflicting photo/alt edits fail rather than picking one version by order.
export function composeTextAndPhotoReview(base,text,photo) {
  assert.equal(base.id,text.id);assert.equal(base.id,photo.id);
  validateMediaOnlyRecords([photo],new Map([[base.id,base]]));
  assert.deepEqual(text.images,base.images,'text revision already changes photos');
  for(const field of ['entity_type','category','city_id','province_id'])assert.equal(text[field],base[field]);
  assert.equal(text.attributes.slug,base.attributes.slug);
  const tp=JSON.parse(text.attributes.place_enrichment),bp=JSON.parse(base.attributes.place_enrichment),pp=JSON.parse(photo.attributes.place_enrichment);
  assert.equal(text.lifecycle_status,'draft');assert.equal(text.verification_status,'needs_review');
  assert.equal(tp.status,'needs_review');assert.equal(tp.approvedAt,null);assert.equal(tp.reviewer,null);
  for(const locale of ['en','nl']) {
    assert.equal(tp.locales[locale].alt,bp.locales[locale].alt,'conflicting text alt');
    for(const block of bp.locales[locale].blocks)assert.deepEqual(tp.locales[locale].blocks.find(b=>b.id===block.id),block,'base text changed');
    tp.locales[locale].alt=pp.locales[locale].alt;
  }
  return {...structuredClone(text),images:structuredClone(photo.images),attributes:{...text.attributes,place_enrichment:JSON.stringify(tp)}};
}
