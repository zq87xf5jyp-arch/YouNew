// Hash-bound revisions to existing approved IDs: private review or explicit owner release.
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
export const placeReviewBatch='leiden-places-20261115';
// Expansion batches use the same hash-bound review format. They are private
// candidates only; activating additional IDs requires a separately reviewed release.
export const expansionReviews={
  'leiden-stay-parks-20261115':{count:10,city:'leiden',bounds:[52.1,52.3,4.4,4.6]},
  'amsterdam-museums-20261115':{count:20,city:'amsterdam',bounds:[52.28,52.44,4.73,5.02],allowPrivateAdditions:true},
  'priority-cities-20261115':{count:14,cities:{utrecht:[52,52.2,5,5.25],rotterdam:[51.8,52,4.3,4.65],'den-haag':[52,52.2,4.2,4.4],eindhoven:[51.35,51.55,5.35,5.6]}},
  'missing-photos-20261116':{count:4,cities:{leiden:[52.1,52.3,4.4,4.6],eindhoven:[51.35,51.55,5.35,5.6]},mediaOnlyBases:['leiden-stay-parks-20261115','priority-cities-20261115']},
};
export const placeReviewBatches=[placeReviewBatch,'leiden-nature-culture-20261115','leiden-food-20261115',...Object.keys(expansionReviews)];
export function selectedPlaceReviews(env=process.env) {
  if(!env.YOUNEW_PLACE_REVIEW)return [];
  assert.equal(env.YOUNEW_PRIVATE_REVIEW_BUILD,'1','private review build required');
  const ids=env.YOUNEW_PLACE_REVIEW.split(',');
  assert.equal(new Set(ids).size,ids.length,'duplicate selected review');
  ids.forEach(reviewPath);return ids;
}
export function reviewPath(batch=placeReviewBatch) {
  assert.ok(placeReviewBatches.includes(batch),'unknown review');
  return `DataProject/editorial/${batch}`;
}
export const placeReviewPath=`DataProject/editorial/${placeReviewBatch}`;
export const placePublishedMediaPath=`/images/places/${placeReviewBatch}`;
export const sha256=b=>createHash('sha256').update(b).digest('hex');
const https=value=>{const u=new URL(value);assert.equal(u.protocol,'https:');assert.ok(!u.username&&!u.password);return value;};

export async function readPlaceReview(root,batchId=placeReviewBatch) {
  const path=resolve(root,reviewPath(batchId));
  const manifest=JSON.parse(await readFile(resolve(path,'manifest.json'),'utf8'));
  const bytes=await readFile(resolve(path,'records.json'));
  assert.equal(sha256(bytes),manifest.recordsSha256,'changed review records');
  assert.equal(manifest.batchId,batchId);
  if(manifest.prepublicationCheck?.file) {
    assert.equal(manifest.prepublicationCheck.file,'DataProject/editorial/expansion-prepublication-20261115.json');
    assert.equal(sha256(await readFile(resolve(root,manifest.prepublicationCheck.file))),manifest.prepublicationCheck.sha256,'changed prepublication evidence');
  }
  const reviewers=JSON.parse(await readFile(resolve(root,'DataProject/operations/reviewer-registry.json'),'utf8'));
  const batch=JSON.parse(bytes);assert.equal(batch.publication_status,'draft');
  const expansion=expansionReviews[batchId];
  const count=expansion?.count??5;
  assert.equal(batch.records.length,count);assert.equal(new Set(manifest.ids).size,count);
  if(expansion) {
    assert.equal(manifest.privateOnly,manifest.status!=='approved','private/public approval scope mismatch');
    if(manifest.status==='approved') {
      assert.equal(manifest.publicationScope?.type,'owner-approved-existing-ids');
      assert.deepEqual(manifest.publicationScope.addedIds,expansion.allowPrivateAdditions?manifest.ids:[],'unapproved added IDs');
      assert.equal(manifest.publicationScope.supersedesHistoricalWithholding,Boolean(expansion.allowPrivateAdditions));
    }
  }
  if(expansion) {
    assert.equal(sha256(await readFile(resolve(path,'source-checks.json'))),manifest.sourceChecksSha256,'changed source evidence');
    assert.equal(sha256(await readFile(resolve(path,'media-sources.json'))),manifest.mediaSourcesSha256,'changed media provenance');
  }
  const bases=new Map();
  for(const [id,base] of Object.entries(manifest.baseFiles)) {
    if(expansion?.mediaOnlyBases) {
      const sourceBatch=expansion.mediaOnlyBases.find(b=>base.file===`${reviewPath(b)}/records.json`);
      assert.ok(sourceBatch,'media revision requires an approved editorial base');
      const source=await readPlaceReview(root,sourceBatch);
      assert.ok(source.manifest.ids.includes(id),'unknown media base ID');
    } else if(expansion?.allowPrivateAdditions)assert.equal(base.file,'DataProject/batches/WP-06/M2-amsterdam-001.json');
    else assert.match(base.file,/^DataProject\/staging\/content-20261109\/WP-\d{2}-M1-leiden-20261109\.json$/);
    const bytes=await readFile(resolve(root,base.file));assert.equal(sha256(bytes),base.sha256,'approved base changed');
    bases.set(id,JSON.parse(bytes).records.find(r=>r.id===id));
  }
  for(const [file,proof] of Object.entries(manifest.media)) {
    assert.match(file,/^[a-z]+-(480|800|1200)\.webp$/);
    assert.equal(sha256(await readFile(resolve(path,'media',file))),proof.sha256,'changed review image');
  }
  validatePlaceRecords(batch.records,manifest.ids,bases,batchId!==placeReviewBatch,expansion);
  if(expansion?.mediaOnlyBases) {
    validateMediaOnlyRecords(batch.records,bases);
    const sources=JSON.parse(await readFile(resolve(path,'media-sources.json'),'utf8'));
    assert.deepEqual(Object.keys(sources).sort(),[...manifest.ids].sort(),'incomplete media provenance');
    for(const record of batch.records) {
      const proof=sources[record.id],photo=record.images[0];
      assert.match(proof.licenseEvidence,new RegExp(`^${reviewPath(batchId)}/evidence/commons-[0-9]+\\.json$`));
      const bytes=await readFile(resolve(root,proof.licenseEvidence));
      assert.equal(sha256(bytes),proof.licenseEvidenceSha256,'changed license evidence');
      const info=JSON.parse(bytes).imageinfo[0];
      assert.equal(photo.source_page_url,info.descriptionurl);
      assert.equal(photo.asset_url,info.url);
      assert.equal(photo.license,info.extmetadata.LicenseShortName.value);
      assert.equal(photo.license_url,info.extmetadata.LicenseUrl.value.replace(/^http:/,'https:'));
      assert.equal(proof.originalSha1,info.sha1);
      assert.equal(proof.outputLicense,photo.license);
      assert.equal(proof.commercialReuse,true);assert.equal(proof.adaptationAllowed,true);
      for(const credit of [proof.author,proof.title,proof.created])assert.ok(photo.attribution.includes(credit),'missing photo credit');
    }
  }
  const requiredMedia=batch.records.flatMap(r=>r.images.flatMap(i=>[480,800,1200].map(w=>i.public_asset_path.split('/').at(-1).replace('-1200.webp',`-${w}.webp`))));
  assert.deepEqual(Object.keys(manifest.media).sort(),requiredMedia.sort(),'incomplete or extraneous review media');
  const reviewer=validatePlaceApproval(manifest,batch.records,reviewers);
  return {manifest,records:batch.records,reviewer};
}

// A photo follow-up cannot silently revert already approved facts, dates or URLs.
export function validateMediaOnlyRecords(records,bases) {
  const withoutMedia=record=>{
    const copy=structuredClone(record);copy.images=[];
    const enrichment=JSON.parse(copy.attributes.place_enrichment);
    for(const locale of ['en','nl'])enrichment.locales[locale].alt='';
    copy.attributes.place_enrichment=enrichment;
    return copy;
  };
  for(const record of records) {
    const base=bases.get(record.id);
    assert.ok(base&&base.images.length===0,'media follow-up must fill an existing empty slot');
    assert.equal(record.images.length,1,'media follow-up needs one verified image');
    assert.deepEqual(withoutMedia(record),withoutMedia(base),'media-only revision changed approved facts');
  }
}

export function validatePlaceRecords(records,ids,bases,optionalTickets=false,expansion=null) {
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
    const bounds=expansion?.cities?.[r.city_id]??expansion?.bounds??[52.1,52.3,4.4,4.6];
    if(expansion?.cities)assert.ok(Object.hasOwn(expansion.cities,r.city_id),'wrong review city');
    else if(expansion)assert.equal(r.city_id,expansion.city,'wrong review city');
    if(r.coordinates)assert.ok(r.coordinates.latitude>bounds[0]&&r.coordinates.latitude<bounds[1]&&r.coordinates.longitude>bounds[2]&&r.coordinates.longitude<bounds[3],'outside review city');
    else assert.ok(expansion&&p.coordinateEvidence===null,'missing coordinate evidence');
    for(const locale of ['en','nl']) {
      assert.ok(p.locales[locale].alt.length>10||(expansion&&r.images.length===0&&p.locales[locale].alt===''));
      assert.ok(p.locales[locale].blocks.length>=5);
      for(const b of p.locales[locale].blocks)assert.ok(b.text.length>10&&b.source_ids.length&&b.source_ids.every(id=>sourceIds.has(id)),'unsourced text');
    }
    if(p.tickets) {
      https(p.tickets.url);assert.ok(sourceIds.has(p.tickets.sourceId));
      if(optionalTickets)assert.ok(p.sources.some(s=>s.id===p.tickets.sourceId&&s.url===p.tickets.url),'ticket URL not sourced');
    } else assert.ok(optionalTickets&&p.tickets===null,'missing ticket evidence');
    if(r.coordinates)https(p.coordinateEvidence.url);
    if(optionalTickets&&r.coordinates) {
      assert.ok(p.sources.some(s=>s.url===p.coordinateEvidence.url),'coordinate source missing');
      const destination=new URL(p.coordinateEvidence.destinationURL).searchParams.get('destination');
      assert.equal(destination,`${r.coordinates.latitude},${r.coordinates.longitude}`,'coordinate destination mismatch');
    }
    assert.ok(r.images.length===1||(expansion&&r.images.length===0),'one verified photo or explicit missing media');
    for(const image of r.images){assert.equal(image.verified,true);https(image.source_page_url);https(image.asset_url);assert.match(image.license_url,expansion?/^https:\/\/creativecommons.org\/(?:licenses\/(?:by|by-sa)\/(?:2|3|4)\.0(?:\/nl)?|publicdomain\/zero\/1\.0(?:\/deed\.en)?)\/?$/:/^https:\/\/creativecommons.org\/licenses\/(by|by-sa)\/(2|3|4)\.0(?:\/nl)?\/?$/);assert.ok(image.attribution.length>10);assert.match(image.public_asset_path,/^\/images\/place-review\/[a-z]+-1200\.webp$/);}
  }
}

export function placeApprovalDigest(manifest) {
  return sha256(JSON.stringify({batchId:manifest.batchId,ids:manifest.ids,recordsSha256:manifest.recordsSha256,media:manifest.media,...(expansionReviews[manifest.batchId]?{publicationScope:manifest.publicationScope}: {})}));
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
  const selected=selectedPlaceReviews(env);
  let result=release;
  for(const batchId of placeReviewBatches) {
    const proof=await readPlaceReview(root,batchId);
    const privateReview=selected.includes(batchId);
    if(!privateReview&&!proof.reviewer)continue;
    // Do not apply the same approved revision twice when previewing an already
    // projected release. Draft revisions never enter an ordinary build.
    if(!privateReview&&result.revisions?.some(r=>r.id===batchId&&r.approvalSha256===proof.manifest.approvalSha256))continue;
    result=projectPlaceRevision(result,proof,privateReview);
  }
  return result;
}

function projectPlaceRevision(release,{manifest,records,reviewer},privateReview) {
  if(expansionReviews[manifest.batchId]?.mediaOnlyBases) {
    for(const base of Object.values(manifest.baseFiles)) {
      const baseId=base.file.split('/').at(-2);
      assert.ok(release.revisions?.some(r=>r.id===baseId&&r.recordsSha256===base.sha256&&r.reviewerId==='owner.ivan'),'media requires its approved base in the release');
    }
  }
  const batchHash=sha256(`${release.batchSha256}:${privateReview?'PRIVATE-REVIEW':'APPROVED-REVISION'}:${manifest.recordsSha256}:${manifest.approvalSha256??''}`);
  const ids=new Set(release.entities.map(e=>e.id));
  const additions=records.filter(r=>!ids.has(r.id));
  if(additions.length)assert.ok(expansionReviews[manifest.batchId]?.allowPrivateAdditions&&(privateReview||(reviewer&&manifest.publicationScope?.addedIds.length===additions.length&&additions.every(r=>manifest.publicationScope.addedIds.includes(r.id)))),'cannot add catalogue IDs');
  // These IDs already exist in DataProject but are withheld from the public
  // runtime. Keep their draft lifecycle explicit throughout the local preview.
  const seeds=additions.map(r=>({
    id:r.id,kind:r.entity_type,title:r.title,summary:r.description,cityId:r.city_id,provinceId:r.province_id,category:r.category,
    coordinate:r.coordinates,images:[],aiSummary:r.ai_summary,relatedEntityIDs:r.related_entity_ids,keywords:r.search_keywords,
    publicationStatus:privateReview?'draft':'published',verificationStatus:privateReview?'needs_review':'verified',
    attributes:{...r.attributes,website:r.website,lifecycleStatus:privateReview?'draft':'published',verificationStatus:privateReview?'needs_review':'verified',dataProjectRelease:privateReview?`private-review.${manifest.batchId}`:release.id},
    source:{...r.official_source,isOfficial:true,checkedAt:r.last_checked},
    editorial:{schemaVersion:1,section:'EXPLORE',reviewedAt:null,reviewer:null,batchSha256:batchHash,...(!privateReview?{approvedAddition:{batchId:manifest.batchId,recordsSha256:manifest.recordsSha256,approvalSha256:manifest.approvalSha256}}:{}),
      locales:{en:{title:r.title,summary:r.description,guide:null},nl:{title:r.attributes.title_nl??r.title,summary:r.attributes.description_nl,guide:null}}}
  }));
  const revisions=new Map(records.map(r=>[r.id,r]));
  return {...release,batchSha256:batchHash,...(privateReview?{privateReview:true}:{}),...(!privateReview?{baseBatchSha256:release.baseBatchSha256??release.batchSha256,approvedAt:manifest.approvedAt,revisions:[...(release.revisions??[]),{id:manifest.batchId,recordsSha256:manifest.recordsSha256,approvalSha256:manifest.approvalSha256,approvedAt:manifest.approvedAt,reviewerId:manifest.reviewerId,count:records.length,...(additions.length?{addedIds:additions.map(r=>r.id)}:{})}]}:{}),entities:[...release.entities,...seeds].map(e=>{
    const r=revisions.get(e.id);if(!r)return {...e,editorial:{...e.editorial,batchSha256:batchHash}};
    const p=JSON.parse(r.attributes.place_enrichment);
    return {...e,summary:r.description,coordinate:r.coordinates,lastChecked:r.last_checked,relatedEntityIDs:r.related_entity_ids,
      source:{...e.source,url:r.official_source.url,checkedAt:r.last_checked},
      attributes:{...e.attributes,...r.attributes,...(!privateReview?{dataProjectRevision:manifest.batchId,place_enrichment:JSON.stringify({...p,status:'approved',approvedAt:manifest.approvedAt,reviewer:reviewer.name})}:{})},
      images:r.images.map(i=>({id:i.id,role:i.role,verified:i.verified,assetURL:i.asset_url,publicAssetPath:privateReview?i.public_asset_path:`/images/places/${manifest.batchId}/${i.public_asset_path.split('/').at(-1)}`,alt:i.alt,attribution:i.attribution,license:i.license,licenseURL:i.license_url,sourcePageURL:i.source_page_url,retrievedAt:i.retrieved_at})),
      editorial:{...e.editorial,batchSha256:batchHash,...(privateReview?{reviewedAt:null,reviewer:null,placeReview:{batchId:manifest.batchId,preparedAt:p.preparedAt,approvedAt:null}}:{placeReview:undefined,reviewedAt:manifest.approvedAt,reviewer:reviewer.name}),place:{locales:Object.fromEntries(['en','nl'].map(l=>[l,{alt:p.locales[l].alt,blocks:p.locales[l].blocks.map(b=>({id:b.id,text:b.text,title:b.title,sourceIds:b.source_ids}))}])),tickets:p.tickets},
        sources:p.sources.map(s=>({id:s.id,title:s.title,publisher:s.publisher,url:s.url,checkedAt:s.checked_at})),
        locales:{en:{...e.editorial.locales.en,summary:r.description},nl:{...e.editorial.locales.nl,summary:r.attributes.description_nl}}}
    };
  })};
}

// Only exact additions projected from a validated human-approved manifest may
// supersede historical withholding; all unrelated runtime IDs still fail closed.
export function isApprovedPlaceAddition(entity,release) {
  const proof=entity.editorial?.approvedAddition;
  const revision=release?.revisions?.find(r=>r.id===proof?.batchId);
  return Boolean(proof&&revision&&expansionReviews[proof.batchId]?.allowPrivateAdditions&&
    revision.addedIds?.includes(entity.id)&&revision.reviewerId==='owner.ivan'&&
    revision.recordsSha256===proof.recordsSha256&&revision.approvalSha256===proof.approvalSha256&&
    entity.attributes?.dataProjectRevision===revision.id&&entity.editorial.reviewedAt===revision.approvedAt&&
    entity.publicationStatus==='published'&&entity.verificationStatus==='verified'&&
    entity.attributes.lifecycleStatus==='published'&&entity.attributes.verificationStatus==='verified'&&
    entity.source?.status==='verified_opened'&&!entity.editorial.placeReview);
}
