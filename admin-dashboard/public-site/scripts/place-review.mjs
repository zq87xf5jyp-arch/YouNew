// Hash-bound revisions to existing approved IDs: private review or explicit owner release.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
export const placeReviewBatch='leiden-places-20261115';
export const placeReviewPath=`DataProject/editorial/${placeReviewBatch}`;
export const placePublishedMediaPath=`/images/places/${placeReviewBatch}`;
export const sha256=b=>createHash('sha256').update(b).digest('hex');
const https=value=>{const u=new URL(value);assert.equal(u.protocol,'https:');assert.ok(!u.username&&!u.password);return value;};

export async function readPlaceReview(root) {
  const path=resolve(root,placeReviewPath);
  const manifest=JSON.parse(await readFile(resolve(path,'manifest.json'),'utf8'));
  const bytes=await readFile(resolve(path,'records.json'));
  assert.equal(sha256(bytes),manifest.recordsSha256,'changed review records');
  assert.equal(manifest.batchId,placeReviewBatch);
  const reviewers=JSON.parse(await readFile(resolve(root,'DataProject/operations/reviewer-registry.json'),'utf8'));
  const batch=JSON.parse(bytes);assert.equal(batch.publication_status,'draft');
  assert.equal(batch.records.length,5);assert.equal(new Set(manifest.ids).size,5);
  const bases=new Map();
  for(const [id,base] of Object.entries(manifest.baseFiles)) {
    assert.match(base.file,/^DataProject\/staging\/content-20261109\/WP-\d{2}-M1-leiden-20261109\.json$/);
    const bytes=await readFile(resolve(root,base.file));assert.equal(sha256(bytes),base.sha256,'approved base changed');
    bases.set(id,JSON.parse(bytes).records.find(r=>r.id===id));
  }
  for(const [file,proof] of Object.entries(manifest.media)) {
    assert.match(file,/^[a-z]+-(480|800|1200)\.webp$/);
    assert.equal(sha256(await readFile(resolve(path,'media',file))),proof.sha256,'changed review image');
  }
  validatePlaceRecords(batch.records,manifest.ids,bases);
  const reviewer=validatePlaceApproval(manifest,batch.records,reviewers);
  return {manifest,records:batch.records,reviewer};
}

export function validatePlaceRecords(records,ids,bases) {
  assert.equal(new Set(records.map(r=>r.id)).size,ids.length,'duplicate revision ID');
  for(const r of records) {
    const base=bases.get(r.id);assert.ok(ids.includes(r.id)&&base,'revision requires an existing ID');
    for(const field of ['entity_type','category','city_id','province_id'])assert.equal(r[field],base[field],'identity changed');
    assert.equal(r.attributes.slug,base.attributes.slug,'URL changed');
    assert.equal(r.lifecycle_status,'draft');assert.equal(r.verification_status,'needs_review');
    const p=JSON.parse(r.attributes.place_enrichment);
    assert.equal(p.status,'needs_review');assert.equal(p.approvedAt,null);assert.equal(p.reviewer,null);
    const sourceIds=new Set(p.sources.map(s=>s.id));assert.equal(sourceIds.size,p.sources.length);
    for(const s of p.sources){https(s.url);assert.equal(s.is_official,true);assert.equal(s.status,'verified_opened');assert.equal(s.checked_at,r.last_checked);}
    assert.ok(r.coordinates.latitude>52.1&&r.coordinates.latitude<52.3&&r.coordinates.longitude>4.4&&r.coordinates.longitude<4.6,'outside Leiden');
    for(const locale of ['en','nl']) {
      assert.ok(p.locales[locale].alt.length>10);
      assert.ok(p.locales[locale].blocks.length>=5);
      for(const b of p.locales[locale].blocks)assert.ok(b.text.length>10&&b.source_ids.length&&b.source_ids.every(id=>sourceIds.has(id)),'unsourced text');
    }
    https(p.tickets.url);assert.ok(sourceIds.has(p.tickets.sourceId));https(p.coordinateEvidence.url);
    assert.equal(r.images.length,1);
    for(const image of r.images){assert.equal(image.verified,true);https(image.source_page_url);https(image.asset_url);assert.match(image.license_url,/^https:\/\/creativecommons.org\/licenses\/(by|by-sa)\/(3|4)\.0\/?$/);assert.ok(image.attribution.length>10);assert.match(image.public_asset_path,/^\/images\/place-review\/[a-z]+-1200\.webp$/);}
  }
}

export function placeApprovalDigest(manifest) {
  return sha256(JSON.stringify({batchId:manifest.batchId,ids:manifest.ids,recordsSha256:manifest.recordsSha256,media:manifest.media}));
}

export function validatePlaceApproval(manifest,records,registry,{today=new Date().toISOString().slice(0,10)}={}) {
  if(manifest.status==='needs_review') {
    assert.equal(manifest.publicationAuthorized,false,'unapproved publication');
    assert.equal(manifest.approvedAt,null);assert.equal(manifest.reviewerId,null);
    return null;
  }
  assert.equal(manifest.status,'approved','unknown revision status');
  assert.equal(manifest.publicationAuthorized,true,'explicit publication approval required');
  assert.equal(manifest.approvalSha256,placeApprovalDigest(manifest),'approval payload changed');
  assert.match(manifest.approvedAt,/^\d{4}-\d{2}-\d{2}$/);
  assert.ok(manifest.approvedAt<=today&&manifest.approvedAt>=manifest.preparedAt,'invalid approval date');
  assert.equal(registry.policy.automated_reviewers_allowed,false);
  const reviewer=registry.reviewers.find(r=>r.id===manifest.reviewerId);
  assert.ok(reviewer?.active===true&&reviewer.reviewer_type==='official_owner','registered human owner required');
  assert.ok(['en','nl'].every(l=>reviewer.locales.includes(l)),'reviewer locale mismatch');
  for(const r of records) {
    assert.ok(reviewer.categories.includes(r.category),'reviewer category mismatch');
    assert.ok(r.last_checked<=today&&r.last_checked<=manifest.approvedAt,'invalid checked date');
    assert.ok(Date.parse(r.last_checked)+r.review_frequency_days*86400000>=Date.parse(today),'revision source review expired');
  }
  return reviewer;
}

export async function applyPlaceReview(release,root,env=process.env) {
  const privateReview=Boolean(env.YOUNEW_PLACE_REVIEW);
  if(privateReview) {
    assert.equal(env.YOUNEW_PLACE_REVIEW,placeReviewBatch,'unknown review');
    assert.equal(env.YOUNEW_PRIVATE_REVIEW_BUILD,'1','private review build required');
  }
  const {manifest,records,reviewer}=await readPlaceReview(root);
  if(!privateReview&&!reviewer)return release;
  const batchHash=sha256(`${release.batchSha256}:${privateReview?'PRIVATE-REVIEW':'APPROVED-REVISION'}:${manifest.recordsSha256}:${manifest.approvalSha256??''}`);
  const ids=new Set(release.entities.map(e=>e.id));assert.ok(records.every(r=>ids.has(r.id)),'cannot add catalogue IDs');
  const revisions=new Map(records.map(r=>[r.id,r]));
  return {...release,batchSha256:batchHash,...(!privateReview?{baseBatchSha256:release.batchSha256,approvedAt:manifest.approvedAt,revisions:[{id:manifest.batchId,recordsSha256:manifest.recordsSha256,approvalSha256:manifest.approvalSha256,approvedAt:manifest.approvedAt,reviewerId:manifest.reviewerId,count:records.length}]}:{}),entities:release.entities.map(e=>{
    const r=revisions.get(e.id);if(!r)return {...e,editorial:{...e.editorial,batchSha256:batchHash}};
    const p=JSON.parse(r.attributes.place_enrichment);
    return {...e,summary:r.description,coordinate:r.coordinates,lastChecked:r.last_checked,relatedEntityIDs:r.related_entity_ids,
      source:{...e.source,url:r.official_source.url,checkedAt:r.last_checked},
      attributes:{...e.attributes,...r.attributes,...(!privateReview?{dataProjectRevision:manifest.batchId,place_enrichment:JSON.stringify({...p,status:'approved',approvedAt:manifest.approvedAt,reviewer:reviewer.name})}:{})},
      images:r.images.map(i=>({id:i.id,role:i.role,verified:i.verified,assetURL:i.asset_url,publicAssetPath:privateReview?i.public_asset_path:`${placePublishedMediaPath}/${i.public_asset_path.split('/').at(-1)}`,alt:i.alt,attribution:i.attribution,license:i.license,licenseURL:i.license_url,sourcePageURL:i.source_page_url,retrievedAt:i.retrieved_at})),
      editorial:{...e.editorial,...(privateReview?{placeReview:{batchId:placeReviewBatch,preparedAt:p.preparedAt,approvedAt:null}}:{placeReview:undefined,reviewedAt:manifest.approvedAt,reviewer:reviewer.name,batchSha256:batchHash}),place:{locales:Object.fromEntries(['en','nl'].map(l=>[l,{alt:p.locales[l].alt,blocks:p.locales[l].blocks.map(b=>({id:b.id,text:b.text,title:b.title,sourceIds:b.source_ids}))}])),tickets:p.tickets},
        sources:p.sources.map(s=>({id:s.id,title:s.title,publisher:s.publisher,url:s.url,checkedAt:s.checked_at})),
        locales:{en:{...e.editorial.locales.en,summary:r.description},nl:{...e.editorial.locales.nl,summary:r.attributes.description_nl}}}
    };
  })};
}
