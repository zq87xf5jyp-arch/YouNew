#!/usr/bin/env python3
"""One bounded Commons category lookup per existing review ID; no API/search bypass.
Discovery is only a candidate, never a license or visual-identity approval.
"""
import html,importlib.util,json,re,time,urllib.parse
from pathlib import Path
s=importlib.util.spec_from_file_location('prep',Path(__file__).with_name('prepare-travel-expansion.py'));p=importlib.util.module_from_spec(s);s.loader.exec_module(p)
index=json.loads((p.DIR/'index.json').read_text())
candidates=[];attempts=[]
previous=p.DIR/'media-discovery.json'
if previous.exists():
 old=json.loads(previous.read_text());attempts=old['attempts'];candidates=old['candidates']
done={a['id'] for a in attempts}
for ref in index['records']:
 eid=ref['id']
 if eid in done or eid.startswith('guide.') or (p.DIR/'media-evidence'/f'{eid}.json').exists():continue
 if eid in {'place.leiden-lakenhal','place.leiden-hortus','place.leiden-rmo','place.leiden-naturalis','museum.leiden-boerhaave','museum.leiden-wereldmuseum'}:continue
 batch=json.loads((p.ROOT/ref['recordFile']).read_text());r=next(x for x in batch['records'] if x['id']==eid)
 category=r['title'];url='https://commons.wikimedia.org/wiki/Category:'+urllib.parse.quote(category.replace(' ','_'))
 a={'id':eid,'categoryURL':url,'status':'unresolved','checkedAt':p.TODAY}
 try:
  allowed,h,state=p.permission(url);a['robotsSHA256']=h
  if not allowed:raise ValueError('robots disallowed or unavailable')
  b,status,final,ct=p.request(url);a['sourceSHA256']=p.sha(b);text=html.unescape(b.decode('utf8'))
  links=list(dict.fromkeys(re.findall(r'href="(/wiki/File:[^"]+\.(?:jpg|JPG|jpeg))"',text)))
  links=[u for u in links if not re.search(r'logo|map|kaart|signature|portret|portrait|document|ticket|poster',u,re.I)]
  words=[w for w in re.findall(r'[\w]+',category.lower()) if len(w)>3 and w not in {'museum','leiden','amsterdam','rotterdam','utrecht','eindhoven','haag'}]
  links.sort(key=lambda u:sum(w in urllib.parse.unquote(u).lower() for w in words),reverse=True)
  if links:
   c={'id':eid,'url':'https://commons.wikimedia.org'+links[0],'origin':url};candidates.append(c);a['status']='candidate_found';a['candidateURL']=c['url']
  else:a['status']='no_jpeg_candidate_on_category'
 except Exception as e:a['limitation']=str(e)[:160]
 attempts.append(a);p.write(previous,{'publicationAuthorized':False,'attempts':attempts,'candidates':candidates});print(eid,a['status'],flush=True);time.sleep(.3)
