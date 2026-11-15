#!/usr/bin/env python3
"""Single bounded, cached read-only Overpass request; evidence only, no runtime writes."""
import importlib.util,json,re,urllib.request,urllib.parse
from pathlib import Path
s=importlib.util.spec_from_file_location('prep',Path(__file__).with_name('prepare-travel-expansion.py'));p=importlib.util.module_from_spec(s);s.loader.exec_module(p)
output=p.DIR/'coordinate-candidates.json'
if not output.exists():
 index=json.loads((p.DIR/'index.json').read_text());names=[];legacy=[]
 for ref in index['records']:
  if ref['id'].startswith('guide.'):continue
  r=next(r for r in json.loads((p.ROOT/ref['recordFile']).read_text())['records'] if r['id']==ref['id']);names.append(r['title'])
 old=json.loads((p.ROOT/'DataProject/batches/WP-06/M2-amsterdam-001.json').read_text())['records']
 ids={r['id'] for r in index['records']}
 for r in old:
  if r['id'] in ids:
   m=re.search(r'(node|way|relation) (\d+)',r['attributes'].get('coordinate_source',''))
   if m:legacy.append(f'{m[1]}({m[2]});')
 pattern='^('+ '|'.join(re.escape(n) for n in names)+')$'
 query='[out:json][timeout:25][maxsize:16777216];('+''.join(legacy)+'nwr["name"~'+json.dumps(pattern)+',i](50.7,3.2,53.7,7.3););out center tags;'
 endpoint='https://overpass-api.de/api/interpreter'
 evidence={'checkedAt':p.TODAY,'publicationAuthorized':False,'query':query,'license':'ODbL 1.0','licenseURL':'https://opendatacommons.org/licenses/odbl/1-0/','attribution':'© OpenStreetMap contributors','copyrightURL':'https://www.openstreetmap.org/copyright','status':'unavailable','elements':[]}
 try:
  permitted,h,state=p.permission(endpoint);evidence['robotsSHA256']=h
  assert permitted,'robots unavailable or disallowed'
  req=urllib.request.Request(endpoint,data=urllib.parse.urlencode({'data':query}).encode(),headers={'User-Agent':p.UA,'Content-Type':'application/x-www-form-urlencoded'})
  with urllib.request.urlopen(req,timeout=40) as r:b=r.read(2_000_001)
  assert len(b)<2_000_000,'response cap exceeded'
  result=json.loads(b);assert not result.get('remark'),result.get('remark')
  evidence['responseSHA256']=p.sha(b);evidence['status']='candidates_only_identity_review_required'
  for e in result['elements']:
   tags=e.get('tags',{});evidence['elements'].append({'osmType':e['type'],'osmID':e['id'],'coordinate':{'latitude':e.get('lat',e.get('center',{}).get('lat')),'longitude':e.get('lon',e.get('center',{}).get('lon'))},'pointKind':'mapped_node' if e['type']=='node' else 'geometry_bounding_box_center_not_entrance','tags':{k:v for k,v in tags.items() if k in ['name','name:en','name:nl','official_name','website','contact:website','wikidata','addr:street','addr:housenumber','addr:city','addr:postcode']}})
 except Exception as ex:evidence['limitation']=str(ex)[:300]
 p.write(output,evidence)
print(json.dumps(json.loads(output.read_text()),ensure_ascii=False)[:200])
