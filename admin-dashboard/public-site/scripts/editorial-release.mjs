// A source-hash-bound publication path for the exact batch reviewed by the owner.
// Compact editorial guides are not certified as full PracticalGuide v2 records.
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {resolve, relative} from 'node:path';
import {fileURLToPath} from 'node:url';

const root = fileURLToPath(new URL('../../../', import.meta.url));
export const approvalPath = 'DataProject/editorial/leiden-20261110-approval.json';
const digest = value => createHash('sha256').update(value).digest('hex');
function requireValue(value, message) { if (!value) throw new Error(`Editorial release: ${message}`); }
function https(value) {
  const u = new URL(value);
  requireValue(u.protocol === 'https:' && !u.username && !u.password, 'unsafe source URL');
  return value;
}
function text(value) { requireValue(typeof value === 'string' && value.trim() && !/[\u0000-\u0008\u000b\u000c\u000e-\u001f]/.test(value), 'invalid text'); return value; }
function source(s, today) {
  requireValue(s?.is_official === true && s.status === 'verified_opened', 'unverified source');
  requireValue(/^\d{4}-\d{2}-\d{2}$/.test(s.checked_at) && s.checked_at <= today, 'invalid source date');
  return {id:s.id ?? 'source.primary',title:text(s.title),publisher:text(s.publisher),url:https(s.url),checkedAt:s.checked_at};
}
function compactGuide(g, record, today) {
  requireValue(g?.id === record.id && ['en','nl'].includes(g.locale), 'guide identity mismatch');
  const sources = g.official_sources.map(s => source(s,today));
  const ids = new Set(sources.map(s=>s.id));
  requireValue(ids.size === sources.length && ids.size > 0, 'duplicate or missing guide sources');
  const block = b => {
    requireValue(b && Array.isArray(b.source_ids) && b.source_ids.length && b.source_ids.every(id=>ids.has(id)), 'unresolved factual source');
    return {id:text(b.id),text:text(b.text ?? b.body),sourceIds:b.source_ids};
  };
  const steps = g.numbered_steps.map((s,i)=>{
    requireValue(s.position === i+1,'unordered guide steps');
    return {...block(s),title:text(s.title)};
  });
  requireValue(steps.length > 0,'guide without instructions');
  return {
    audience:g.who_this_is_for ? block(g.who_this_is_for) : null,
    situation:g.when_you_need_it ? block(g.when_you_need_it) : null,
    steps,documents:(g.required_documents ?? []).map(block),warnings:(g.warnings ?? []).map(block),
    sections:(g.sections ?? []).map(s=>({...block(s),title:text(s.title)})),
    disclaimer:text(g.disclaimer),sources
  };
}

export function projectEditorialRelease(approval, records, reviewers, {today=new Date().toISOString().slice(0,10)}={}) {
  requireValue(approval.schemaVersion===1 && approval.status==='approved','explicit owner approval required');
  requireValue(approval.releaseId==='editorial-leiden-20261110' && /^\d{4}-\d{2}-\d{2}$/.test(approval.approvedAt) && approval.approvedAt<=today,'invalid approved release');
  requireValue(approval.count===71 && records.length===71 && approval.ids.length===71,'batch count mismatch');
  requireValue(approval.scope?.unknownFields==='remain_empty' && approval.scope.images==='none','unsupported publication scope');
  const reviewer=reviewers.reviewers.find(r=>r.id===approval.reviewerId);
  requireValue(reviewers.policy?.automated_reviewers_allowed===false && reviewer?.active===true && reviewer.reviewer_type==='official_owner','registered owner required');
  requireValue(['en','nl'].every(l=>reviewer.locales.includes(l)),'reviewer locale mismatch');
  const ids=new Set(records.map(r=>r.id));
  requireValue(ids.size===71 && new Set(approval.ids).size===71 && approval.ids.every(id=>ids.has(id)),'approved identities differ');
  const entities=records.map(r=>{
    const a=r.attributes;
    requireValue(r.lifecycle_status==='draft' && r.verification_status==='needs_review' && a.catalog_review_batch==='leiden-20261109','unexpected source lifecycle');
    requireValue(reviewer.categories.includes(r.category),'reviewer category mismatch');
    requireValue(r.images.length===0,'photos were not approved');
    requireValue(/^\d{4}-\d{2}-\d{2}$/.test(r.last_checked) && r.last_checked<=today,'invalid review date');
    requireValue(new Date(`${r.last_checked}T00:00:00Z`).getTime()+r.review_frequency_days*86400000>=new Date(`${today}T00:00:00Z`).getTime(),'source review expired');
    requireValue(['EXPLORE','LIVE','COLLECTIONS','BUSINESS'].includes(a.content_section),'invalid section');
    requireValue(r.related_entity_ids.every(id=>ids.has(id) || ['city.den-haag','city.eindhoven','city.rotterdam','city.utrecht'].includes(id)),'unresolved related record');
    // These two records are the owner's own submission policy, approved in this
    // exact batch. They are not represented as independently verified government facts.
    const ownPolicy=a.content_section==='BUSINESS' && ['business.leiden-add','business.leiden-claim-correct'].includes(r.id) && r.official_source.url==='https://younew.nl/for-business/local/';
    const primary=ownPolicy ? {id:'source.primary',title:r.title,publisher:'YouNew',url:r.official_source.url,checkedAt:approval.approvedAt} : source(r.official_source,today);
    requireValue(r.coordinates===null || (Number.isFinite(r.coordinates.latitude) && r.coordinates.latitude>=50.7 && r.coordinates.latitude<=53.7 && Number.isFinite(r.coordinates.longitude) && r.coordinates.longitude>=3.2 && r.coordinates.longitude<=7.3),'invalid coordinate');
    const locales=Object.fromEntries(['en','nl'].map(locale=>{
      const guide=a.content_section==='LIVE' ? compactGuide(locale==='en'?r.practical_guide:JSON.parse(a.practical_guide_nl),r,today) : null;
      return [locale,{title:text(locale==='en'?r.title:a.title_nl ?? r.title),summary:text(locale==='en'?r.description:a.description_nl),guide}];
    }));
    const category=a.content_section==='LIVE' ? ({gp:'healthcare',pharmacy:'healthcare',transport:'transport',bicycle:'transport',contacts:'emergency'}[r.category] ?? 'government') : a.content_section==='BUSINESS'?'business':a.content_section==='COLLECTIONS'?'things-to-do':null;
    const kind=a.content_section==='EXPLORE' ? (r.entity_type==='nature'?'park':r.entity_type) : 'knowledgeTopic';
    const sources=locales.en.guide?.sources ?? [primary,...(a.additional_sources?JSON.parse(a.additional_sources):[]).filter(url=>url!==primary.url).map((url,i)=>({id:`source.additional-${i}`,url:https(url),title:new URL(url).hostname,publisher:new URL(url).hostname,checkedAt:r.last_checked}))];
    return {
      id:r.id,kind,title:r.title,summary:r.description,cityId:r.city_id,provinceId:r.province_id,category:r.category,
      coordinate:r.coordinates,source:{title:primary.title,publisher:primary.publisher,url:primary.url,checkedAt:primary.checkedAt,status:ownPolicy?'owner_approved_policy':'verified_opened',isOfficial:!ownPolicy && r.official_source.is_official},
      lastChecked:r.last_checked,images:[],aiSummary:r.ai_summary,relatedEntityIDs:r.related_entity_ids,
      attributes:{...a,website:r.website ?? '',lifecycleStatus:'published',verificationStatus:'verified',dataProjectRelease:approval.releaseId,...(category?{publicWebCategory:category}:{})},
      keywords:r.search_keywords,publicationStatus:'published',verificationStatus:'verified',
      editorial:{schemaVersion:1,section:a.content_section,locales,sources,reviewedAt:approval.approvedAt,reviewer:reviewer.name,batchSha256:approval.batchSha256}
    };
  });
  return {id:approval.releaseId,batchSha256:approval.batchSha256,approvedAt:approval.approvedAt,entities};
}

export async function loadEditorialRelease(repositoryRoot=root) {
  const approval=JSON.parse(await readFile(resolve(repositoryRoot,approvalPath),'utf8'));
  const sortedFiles=Object.fromEntries(Object.entries(approval.files).sort(([a],[b])=>a.localeCompare(b)));
  requireValue(digest(JSON.stringify(sortedFiles))===approval.batchSha256,'approval manifest hash mismatch');
  const records=[];
  for (const [file,sha] of Object.entries(sortedFiles)) {
    requireValue(/^DataProject\/staging\/content-20261109\/WP-\d{2}-M1-leiden-20261109\.json$/.test(file),'unexpected source path');
    const full=resolve(repositoryRoot,file);
    requireValue(!relative(repositoryRoot,full).startsWith('..'),'source path escapes repository');
    const bytes=await readFile(full);
    requireValue(digest(bytes)===sha,`approved content changed: ${file}`);
    const batch=JSON.parse(bytes);requireValue(batch.publication_status==='draft','historical staged batch changed');
    records.push(...batch.records);
  }
  const reviewers=JSON.parse(await readFile(resolve(repositoryRoot,'DataProject/operations/reviewer-registry.json'),'utf8'));
  return projectEditorialRelease(approval,records,reviewers);
}
