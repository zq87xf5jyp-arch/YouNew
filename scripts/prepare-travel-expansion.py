#!/usr/bin/env python3
"""Non-publishing research queue; never writes runtime or human approvals.
Fetches are opt-in, cached, bounded and robots-aware. Outputs use existing entity schema.
"""
import argparse, csv, datetime, hashlib, json, re, time, urllib.request, urllib.parse, urllib.robotparser
from html.parser import HTMLParser
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
DIR=ROOT/'DataProject/research/travel-expansion-20261115'
UA='YouNewContentReview/1.0'
TODAY=datetime.datetime.now(datetime.timezone.utc).date().isoformat()
CITIES=['leiden','amsterdam','rotterdam','den-haag','utrecht','eindhoven']
PROVINCES={'leiden':'zuid-holland','amsterdam':'noord-holland','rotterdam':'zuid-holland','den-haag':'zuid-holland','utrecht':'utrecht','eindhoven':'noord-brabant'}
def sha(b):return hashlib.sha256(b).hexdigest()
def write(p,x):
 p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n')
class Text(HTMLParser):
 def __init__(self):super().__init__();self.depth=0;self.parts=[];self.links=[];self.intitle=False;self.title=[]
 def handle_starttag(self,t,a):
  if t in ('script','style','noscript'):self.depth+=1
  if t=='title':self.intitle=True
  if t=='a':self.links.extend([v for k,v in a if k=='href'])
 def handle_endtag(self,t):
  if t in ('script','style','noscript'):self.depth=max(0,self.depth-1)
  if t=='title':self.intitle=False
 def handle_data(self,d):
  if self.intitle:self.title.append(d)
  if not self.depth and d.strip():self.parts.append(d.strip())
robots={}
class Redirects(urllib.request.HTTPRedirectHandler):
 def redirect_request(self, req, fp, code, msg, headers, newurl):
  target=urllib.parse.urlsplit(newurl)
  if target.scheme!='https' or target.username or target.password:
   raise ValueError('Unsafe redirect rejected')
  # robots.txt may itself redirect; ordinary content redirects must pass the
  # destination policy before any content request is sent.
  if urllib.parse.urlsplit(req.full_url).path!='/robots.txt':
   allowed,_,_=permission(newurl)
   if not allowed:raise ValueError('Redirect destination robots disallowed or unavailable')
  return super().redirect_request(req,fp,code,msg,headers,newurl)
 def http_error_308(self, req, fp, code, msg, headers):
  return self.http_error_302(req,fp,302,msg,headers)
def request(url):
 with urllib.request.build_opener(Redirects()).open(urllib.request.Request(url,headers={'User-Agent':UA}),timeout=15) as r:
  b=r.read(3_000_001)
  if len(b)>3_000_000:raise ValueError('Response over 3 MB cap')
  return b,r.status,r.url,r.headers.get('content-type','')
def permission(url):
 origin=urllib.parse.urlsplit(url);host=f'{origin.scheme}://{origin.netloc}'
 if host not in robots:
  try:
   b,status,final,ct=request(host+'/robots.txt');p=urllib.robotparser.RobotFileParser();p.parse(b.decode('utf-8',errors='replace').splitlines());robots[host]=(p,sha(b),'fetched')
  except urllib.error.HTTPError as e:
   robots[host]=(None,None,'absent' if e.code==404 else 'unavailable')
  except Exception:robots[host]=(None,None,'unavailable')
 p,h,state=robots[host]
 return ((p.can_fetch(UA,url) if p else state=='absent'),h,state)
def fetch(row):
 path=DIR/'sources'/f'{sha(row["url"].encode())}.json'
 if path.exists():return json.loads(path.read_text())
 e={'url':row['url'],'checkedAt':TODAY,'status':'unavailable','contentReviewed':False}
 try:
  allowed,rhash,state=permission(row['url']);e.update(robotsSHA256=rhash,robotsStatus=state)
  if not allowed:e['status']='robots_disallowed_or_unavailable'
  else:
   b,status,final,ct=request(row['url']);p=Text();p.feed(b.decode('utf-8',errors='replace'))
   text=' '.join(p.parts)
   # Only a short quotation is retained; full text is transient research scratch.
   e.update(status='opened' if status==200 and len(text)>100 else 'insufficient_content',httpStatus=status,finalURL=final,sha256=sha(b),title=' '.join(p.title),excerpt=' '.join(text.split()[:20]))
   links=[urllib.parse.urljoin(final,u) for u in p.links]
   e['actionCandidates']=list(dict.fromkeys(u for u in links if re.search(r'ticket|reserv|booking|menu',u,re.I) and u.startswith('https:')))[:12]
   scratch=Path('/tmp/younew-travel-source-text');scratch.mkdir(exist_ok=True);(scratch/(sha(row['url'].encode())+'.txt')).write_text(text)
 except Exception as ex:e['error']=str(ex)[:180]
 write(path,e);return e

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--fetch',action='store_true');ap.add_argument('--city',choices=CITIES);ap.add_argument('--write',action='store_true');ap.add_argument('--check',action='store_true');args=ap.parse_args()
 rows=list(csv.DictReader((DIR/'curated.tsv').open(),delimiter='\t'))
 for city in CITIES:
  if args.city and city!=args.city:continue
  selected=[r for r in rows if r['city']==city]
  if args.fetch:
   for r in selected:
    e=fetch(r);print(city,r['id'],e['status'],e.get('title',''),flush=True);time.sleep(.25)
 if args.write or args.check:build(rows,check=args.check)


def build(rows,check=False):
 def emit(path,obj):
  encoded=json.dumps(obj,ensure_ascii=False,indent=2)+'\n'
  if check:assert path.read_text()==encoded,f'Stale output: {path}'
  else:path.parent.mkdir(parents=True,exist_ok=True);path.write_text(encoded)
 # Reuse immutable compact records by reference rather than duplicating their database.
 known={};base=[]
 for f in sorted((ROOT/'DataProject/batches').glob('*/*.json')):
  for r in json.loads(f.read_text()).get('records',[]):known[r['id']]=(r,f)
 for f in sorted((ROOT/'DataProject/staging/content-20261109').glob('*.json')):
  for r in json.loads(f.read_text())['records']:
   known[r['id']]=(r,f)
   if r['id'].startswith(('collection.','business.')) or r['id']=='restaurant.leiden-engelenbak':continue
   base.append({'id':r['id'],'city':r['city_id'],'recordFile':str(f.relative_to(ROOT)),'fileSHA256':sha(f.read_bytes()),'origin':'existing_compact_approval','sourceCheckedAt':r['last_checked'],'sourceContentChecked':True,'coordinate':r['coordinates'] is not None,'photo':False})
 decisions=json.loads((DIR/'content-inspection.json').read_text())
 staging=ROOT/'DataProject/staging/travel-expansion-20261115'
 allrows=base[:];batches=[]
 for city in CITIES:
  selected=[r for r in rows if r['city']==city];records=[];proofs=[]
  for row in selected:
   eid=row['id'];sourceFile=DIR/'sources'/f'{sha(row["url"].encode())}.json'
   source=json.loads(sourceFile.read_text()) if sourceFile.exists() else {'status':'not_checked'}
   inspected=eid in decisions['contentCheckedIDs'] and source['status']=='opened'
   old,oldpath=known.get(eid,({},None));kind=eid.split('.')[0]
   attrs={'description_nl':row['nl'],'content_language':'en','content_section':'EXPLORE','research_source_status':source['status'],'source_evidence_file':str(sourceFile.relative_to(ROOT)),'content_verification':'source_read_proposed_text_checked' if inspected else 'not_fact_checked_do_not_release','media_status':'no_new_runtime_photo','coordinate_status':'not_verified_no_marker'}
   if oldpath:attrs['revision_of']=str(oldpath.relative_to(ROOT));attrs['revision_base_sha256']=sha(oldpath.read_bytes())
   if eid=='museum.eindhoven-prehistorisch-dorp':attrs['former_names']='preHistorisch Dorp; Eindhoven Museum';attrs['identity_note']='Same historic venue lineage; new public name confirmed on official redirected page. Preserve ID.'
   r={'id':eid,'entity_type':old.get('entity_type',kind),'category':old.get('category',{'museum':'museum','place':'attraction','nature':'botanical-garden'}[kind]),'city_id':city,'province_id':PROVINCES[city],'coordinates':None,'title':row['title'],'description':row['en'],'images':[], 'official_source':{'title':row['title']+' — official information','publisher':row['title'],'url':row['url'],'is_official':True,'checked_at':source.get('checkedAt',TODAY),'status':'verified_opened' if inspected else 'access_restricted' if source['status'].startswith('robots') else 'pending'},'website':row['url'] if inspected else None,'related_entity_ids':[],'last_checked':source.get('checkedAt',TODAY),'review_frequency_days':30,'verification_status':'needs_review','ai_summary':row['en'],'search_keywords':[row['title'],city,r'culture' if kind=='museum' else 'visitor information'],'lifecycle_status':'draft','attributes':attrs}
   records.append(r);proofs.append({'id':eid,'sourceEvidenceSHA256':sha(sourceFile.read_bytes()) if sourceFile.exists() else None,'contentChecked':inspected,'missing':['photo','confirmed_coordinates']+([] if inspected else ['verified_primary_content'])})
  path=staging/f'{city}.json'
  batch={'schema_version':1,'batch_id':f'travel-{city}-20261115','work_package':'WP-06','milestone':'travel-content-review','target_release':'travel-review-20261115','publication_status':'draft','qa':{k:'pending' for k in ['build','static','duplicate','source','media','search','ai']},'records':records}
  emit(path,batch)
  manifest={'schemaVersion':1,'batchId':batch['batch_id'],'status':'needs_review','publicationAuthorized':False,'approvedAt':None,'reviewerId':None,'recordsSHA256':sha((json.dumps(batch,ensure_ascii=False,indent=2)+'\n').encode()),'ids':[r['id'] for r in records],'evidence':proofs}
  emit(staging/f'{city}-manifest.json',manifest)
  batches.append({'city':city,'records':len(records),'sourceContentChecked':sum(x['contentChecked'] for x in proofs),'status':'needs_review'})
  for r,proof in zip(records,proofs):allrows.append({'id':r['id'],'city':city,'recordFile':str(path.relative_to(ROOT)),'fileSHA256':manifest['recordsSHA256'],'origin':'revision' if r['id'] in known else 'new_draft','sourceCheckedAt':r['last_checked'],'sourceContentChecked':proof['contentChecked'],'coordinate':False,'photo':False})
 assert len({r['id'] for r in allrows})==len(allrows),'Duplicate IDs in effective review set'
 runtime=json.loads((ROOT/'YouNew/Resources/Data/younew-approved-places.json').read_text())
 for ref in allrows:
  active=next((r for r in runtime['entities'] if r['id']==ref['id']),None)
  if active:ref['coordinate']=active['coordinate'] is not None;ref['photo']=bool(active['images'])
 # Collection membership is editorial selection, never a claim of popularity or travel duration.
 collections=[]
 for city in CITIES:
  members=[r['id'] for r in allrows if r['city']==city and r['sourceContentChecked'] and r['id'].startswith(('museum.','place.'))]
  if len(members)>=3:collections.append({'id':f'collection.{city}-culture-review-20261115','city':city,'title':{'en':'Museums & Culture — '+city.replace('-',' ').title(),'nl':'Musea & Cultuur — '+city.replace('-',' ').title()},'entityIDs':members,'status':'needs_review','publicationAuthorized':False})
 emit(staging/'collections.json',{'schemaVersion':1,'publicationAuthorized':False,'collections':collections})
 media=[json.loads(f.read_text()) for f in sorted((DIR/'media-evidence').glob('*.json'))]
 for ref in allrows:
  evidence=next((m for m in media if m['id']==ref['id']),None)
  if evidence:
   path=DIR/'media-evidence'/f"{ref['id']}.json"
   ref['reviewMedia']={'evidenceFile':str(path.relative_to(ROOT)),'sha256':sha(path.read_bytes()),'optimizedCandidate':bool(evidence['files']),'visualIdentityChecked':evidence['visualIdentityChecked'],'publicationAuthorized':False}
 counts={'trackedObjects':len(allrows),'sourceContentChecked':sum(r['sourceContentChecked'] for r in allrows),'reusedCompactRecords':len(base),'newDrafts':sum(r['origin']=='new_draft' for r in allrows),'revisedExistingIDs':sum(r['origin']=='revision' for r in allrows),'draftRecords':len(rows),'draftPhotosActivated':0,'runtimeRecords':len(runtime['entities']),'runtimeBundledPhotos':len(runtime['mediaFiles']),'runtimeCoordinates':sum(r['coordinate'] is not None for r in runtime['entities']),'runtimeTickets':sum(bool(r['attributes'].get('iosTicketURL')) for r in runtime['entities']),'collectionsPrepared':len(collections),'unresolvedSources':sum(not r['sourceContentChecked'] for r in allrows)}
 counts.update(optimizedPhotoCandidates=sum(bool(m['files']) for m in media), optimizedImageFiles=sum(len(m['files']) for m in media), photoCandidatesVisuallyInspected=sum(m['visualIdentityChecked'] for m in media), newCoordinatesVerified=0, newMediaApproved=0)
 emit(DIR/'index.json',{'schemaVersion':1,'publicationAuthorized':False,'preparedAt':'2026-11-15','counts':counts,'batches':batches,'records':allrows,'excluded':[{'id':'restaurant.leiden-engelenbak','reason':'Previously observed unrelated casino promotion; investigate source integrity; no upstream status changed'}]})
 print(json.dumps(counts),flush=True)

if __name__=='__main__':main()
