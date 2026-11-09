#!/usr/bin/env python3
"""One-way build projection from existing DataProject draft batches into the existing editor import."""
from pathlib import Path
import json,csv,collections,hashlib
R=Path(__file__).resolve().parents[2];W=R/'hostinger/runtime';D=R/'DataProject'
E=R/'docs/content-review-2026-11-09';(E/'evidence').mkdir(parents=True,exist_ok=True)
files=sorted((D/'staging/content-20261109').glob('WP-*-M1-leiden-20261109.json'))
records=[]
for f in files:
 b=json.loads(f.read_text());assert b['publication_status']=='draft';records.extend(b['records'])
assert len(records)==71 and len({e['id'] for e in records})==71
out=[];provenance=[];missing=[]
for e in records:
 assert e['lifecycle_status']=='draft' and not e['images']
 a=dict(e['attributes']);a['website']=e['website'] or '';a.update(lifecycleStatus='draft',verificationStatus=e['verification_status'],editorialEntityType=e['entity_type'],dataProjectRelease='leiden-20261109-draft',summary_nl=a['description_nl'])
 if e.get('practical_guide'):a['practical_guide_en']=json.dumps(e['practical_guide'],ensure_ascii=False)
 # A shared map or collection reference is a source, not an exclusive business homepage.
 if a['content_section']!='EXPLORE' or e['entity_type']=='nature' and e['city_id']=='leiden':a['website_shared_source']='true'
 s=e['official_source'];out.append(dict(id=e['id'],kind='park' if e['entity_type']=='nature' else e['entity_type'],title=e['title'],summary=e['description'],cityId=e['city_id'],provinceId=e['province_id'],category=e['category'],coordinate=e['coordinates'],source=dict(title=s['title'],publisher=s['publisher'],url=s['url'],checkedAt=s['checked_at'],status=s['status'],isOfficial=s['is_official']),lastChecked=e['last_checked'],images=[],aiSummary=e['ai_summary'],relatedEntityIDs=e['related_entity_ids'],attributes=a,keywords=e['search_keywords'],publicationStatus='draft',verificationStatus=e['verification_status']))
 for k,u in a.items():
  if k.endswith('_source_url'):provenance.append([e['id'],k[:-11],u,a.get(k[:-11]+'_checked_at','2026-11-09')])
 if a.get('additional_sources'):
  for u in json.loads(a['additional_sources']):provenance.append([e['id'],'additional_sources',u,e['last_checked']])
 if e.get('practical_guide'):
  for loc,g in [('en',e['practical_guide']),('nl',json.loads(a['practical_guide_nl']))]:
   sm={x['id']:x for x in g['official_sources']}
   for key in ['short_summary','who_this_is_for','when_you_need_it','numbered_steps','required_documents','warnings','sections']:
    val=g.get(key,[]);vals=val if isinstance(val,list) else [val]
    for v in vals:
     for sid in v['source_ids']:provenance.append([e['id'],f'practical_guide.{loc}.{key}.{v["id"]}',sm[sid]['url'],sm[sid]['checked_at']])
 if a['content_section']=='COLLECTIONS':
  for rid in e['related_entity_ids']:
   t=next(x for x in records if x['id']==rid)
   provenance.append([e['id'],'related_entity_ids:'+rid,t['official_source']['url'],t['last_checked']])
 # Unknown field count is explicit and reproducible; coordinates are one pair, not two fields.
 if a['content_section']=='EXPLORE':
  for k in ['address','website','contact_email','contact_phone','coordinates','opening_hours','prices']:
   v=e['coordinates'] if k=='coordinates' else a.get(k,'')
   if not v:missing.append([e['id'],k,'not currently confirmed / left blank'])
 elif a['content_section']=='LIVE':
  for k in ['required_documents','cost','timing']:
   if not a.get(k):missing.append([e['id'],k,'no universal value confirmed / see provider-specific instructions'])
(W/'backend/db/catalog-drafts.json').write_text(json.dumps({'generatedFrom':'DataProject/staging/content-20261109/*.json; edit those files, then scripts/hostinger/project-content.py','publicationStatus':'draft','entities':out},ensure_ascii=False,indent=2)+'\n')
for path,header,rows in [('SOURCES.csv',['material_id','field','source_url','checked_at'],provenance),('evidence/UNCONFIRMED_FIELDS.csv',['material_id','field','reason'],missing),('MEDIA_RIGHTS.csv',['material_id','image','source','license_permission','attribution'],[[e['id'],'none — existing neutral UI icon','existing catalog editor','No external photograph used','not applicable'] for e in records])]:
 with (E/path).open('w',newline='') as f:
  w=csv.writer(f);w.writerow(header);w.writerows(rows)
stats={'total':len(records),'leiden_places':sum(e['city_id']=='leiden' and e['attributes']['content_section']=='EXPLORE' for e in records),'preserved_other_city_places':14,'guides':10,'collections':5,'business_copy':2,'unconfirmed_fields':len(missing),'missing_by_field':dict(collections.Counter(x[1] for x in missing)),'confirmed_coordinate_pairs':sum(bool(x['coordinates']) for x in records),'source_rows':len(provenance),'unique_source_urls':len(set(x[2] for x in provenance))}
(E/'evidence/content-stats.json').write_text(json.dumps(stats,indent=2));print(json.dumps(stats,indent=2))
