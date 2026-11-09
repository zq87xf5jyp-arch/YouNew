#!/usr/bin/env python3
"""Targeted isolated HTTP + real staged-build acceptance; never a scheduler test."""
from pathlib import Path
import shutil,json,urllib.request,urllib.error,http.cookiejar,subprocess,os,hashlib,time,datetime,concurrent.futures
R=Path(__file__).resolve().parents[1];B=R/'backend';A='http://127.0.0.1:4354';W='http://127.0.0.1:4358';E=R.parent/'evidence';E.mkdir(exist_ok=True)
node=os.environ.get('NODE_BINARY') or shutil.which('node');checks=[];users=json.loads((B/'private/users.json').read_text());times={}
def check(n,ok):
 checks.append({'name':n,'status':'PASS' if ok else 'FAIL'});print(n,checks[-1]['status'],flush=True)
 (E/'publication-checks.json').write_text(json.dumps({'status':'RUNNING','checks':checks,'timings':times},indent=2));assert ok,n
def client():return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
def req(c,url,method='GET',body=None):
 q=urllib.request.Request(url,method=method,headers={'Origin':A,'Content-Type':'application/json'},data=None if body is None else json.dumps(body).encode())
 try:r=c.open(q,timeout=20)
 except urllib.error.HTTPError as e:r=e
 return r.status,r.read().decode(),dict(r.headers)
def api(c,path,method='GET',body=None):
 s,b,h=req(c,A+'/api/r4/'+path,method,body);return s,json.loads(b)
def login(role):
 c=client();s,b=api(c,'login','POST',{k:users[role][k] for k in ['email','password']});check(role+'_login',s==200);return c
anon=client();admin=login('admin');ed=login('editor');other=login('other')
row=next(x for x in api(admin,'catalog')[1] if x['document']['title']=='[SYNTHETIC] Integration hotel');path='catalog/'+row['id'];publicId=row['publicId'];slug=publicId.removeprefix('place.')
# Add explicitly synthetic coordinates so removal tests cover a real map entry.
s,row=api(admin,path,'PATCH',{'revision':row['revision'],'coordinate':{'latitude':52.0907,'longitude':5.1214,'sourceUrl':'https://example.invalid/synthetic','checkedAt':'2026-11-03'}});check('synthetic_coordinate_edit',s==200)
for action in ['submit','approve']:s,row=api(admin,path+'/transition','POST',{'action':action,'revision':row['revision']});check(action,s==200)
before=api(admin,'catalog/publication-status')[1];check('approved_revision_not_live_before_build',not before.get('available') or not any(x['publicId']==publicId and x['revision']==row['revision'] for x in before.get('revisions',[])))
check('status_route_requires_session',api(anon,'catalog/publication-status')[0]==401)
check('editorial_snapshot_private',api(anon,'editorial/approved')[0]==401)
# One workspace must never observe another workspace's publication metadata.
# Current status is only identifiers of public synthetic records, no private fields.
check('editor_withdraw_denied',api(ed,path+'/transition','POST',{'action':'withdraw','revision':row['revision']})[0]==403)
check('cross_workspace_withdraw_denied',api(other,path+'/transition','POST',{'action':'withdraw','revision':row['revision']})[0]==404)
def build(name,failure=False,parallel=False):
 env=dict(os.environ);env['PATH']=str(Path(node).parent)+':'+env['PATH']
 if failure:env['YOUNEW_TEST_BUILD_FAILURE']='1'
 log=(E/(name+'.log')).open('w');p=subprocess.Popen([node,str(R/'tools/publish-catalog.mjs')],env=env,stdout=log,stderr=subprocess.STDOUT)
 if parallel:
  for _ in range(200):
   if (R/'publication/build.lock').exists():break
   time.sleep(.02)
  q=subprocess.run([node,str(R/'tools/publish-catalog.mjs')],env=env,capture_output=True,text=True)
  check('parallel_builder_refused',q.returncode==75)
 rc=p.wait();log.close();check(name+'_expected_exit',rc==(1 if failure else 0));return rc
build('publish-approved',parallel=True)
current=json.loads((R/'publication/current.json').read_text());prior=(R/'publication/current.json').read_bytes();active=R/'publication/releases'/current['releaseId']/'out'
check('approval_active_after_success',req(anon,W+'/places/'+slug+'/')[0]==200)
status=api(admin,'catalog/publication-status')[1];check('status_observes_active_revision',status['available'] and any(x['publicId']==publicId and x['revision']==row['revision'] for x in status['revisions']))
for route in ['/places/'+slug+'/','/api/catalog.json','/data/search-index.json','/map/','/sitemap.xml','/data/younew-runtime-data.json']:
 s,body,h=req(anon,W+route);check('approved_surface:'+route,s==200 and (slug in body or publicId in body));check('no_store:'+route,'no-store' in h.get('Cache-Control',''))
check('network_only_SW','caches.' not in req(anon,W+'/sw.js')[1])
(E/'approved-publication.json').write_text(json.dumps(current,indent=2))
# Deliberately fail the next build after withdrawal. The serving pointer and pages must survive.
s,withdrawn=api(admin,path+'/transition','POST',{'action':'withdraw','revision':row['revision']});times['withdrawAcknowledgedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();t0=time.monotonic();check('withdraw',s==200 and withdrawn['state']=='draft')
check('public_API_retains_actual_active_snapshot_until_build',publicId in json.dumps(api(anon,'public/catalog')[1]))
check('static_withdrawal_not_instant',req(anon,W+'/places/'+slug+'/')[0]==200)
build('failed-after-withdraw',failure=True)
check('failed_build_preserves_pointer',(R/'publication/current.json').read_bytes()==prior)
check('failed_build_preserves_page',req(anon,W+'/places/'+slug+'/')[0]==200)
status=api(admin,'catalog/publication-status')[1];check('withdraw_pending_old_revision_observed',any(x['publicId']==publicId for x in status['revisions']))
build('publish-withdrawn')
times['withdrawVisibleAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();times['withdrawDelaySeconds']=round(time.monotonic()-t0,3)
nextManifest=json.loads((R/'publication/current.json').read_text());out=R/'publication/releases'/nextManifest['releaseId']/'out'
for route in ['/places/'+slug+'/']:
 check('withdraw_404:'+route,req(anon,W+route)[0]==404)
for route in ['/api/catalog.json','/data/search-index.json','/map/','/sitemap.xml','/data/younew-runtime-data.json']:
 s,body,h=req(anon,W+route);check('withdraw_surface:'+route,s==200 and slug not in body and publicId not in body)
leaks=[];drafts=json.loads((B/'db/catalog-drafts.json').read_text())['entities']
for p in out.rglob('*'):
 if p.is_file() and p.suffix in ['.html','.json','.js','.xml','.txt']:
  txt=p.read_text();
  if slug in txt or publicId in txt or any(d['id'] in txt for d in drafts):leaks.append(str(p.relative_to(out)))
check('no_withdrawn_or_real_draft_in_any_output',not leaks)
check('all_14_real_places_still_draft',sum(not x['synthetic'] and x['state']=='draft' for x in api(admin,'catalog')[1])==14)
check('retained_release_not_public',req(anon,W+'/publication/releases/'+current['releaseId']+'/out/places/'+slug+'/')[0]==404)
check('private_files_not_public',req(anon,W+'/backend/private/env.json')[0]==404)
status=api(admin,'catalog/publication-status')[1];check('backend_public_API_confirms_removal',publicId not in json.dumps(api(anon,'public/catalog')[1]));check('status_confirms_removal',status['available'] and all(x['publicId']!=publicId for x in status['revisions']))
# No-op polling cannot change the release or invoke a new build.
pointer=(R/'publication/current.json').read_bytes();p=subprocess.run([node,str(R/'tools/publish-catalog.mjs'),'--if-changed'],capture_output=True,text=True);check('unchanged_snapshot_skips_build',p.returncode==0 and 'UNCHANGED' in p.stdout and (R/'publication/current.json').read_bytes()==pointer)
result={'status':'PASS','checks':checks,'timings':times,'withdrawnPublicId':publicId,'previousRelease':current['releaseId'],'activeRelease':nextManifest['releaseId'],'scheduler':'NOT TESTED: these are explicit local builds, not Hostinger cron','cacheSemantics':'Dedicated isolated origin, no-store HTTP and network-only SW; an already rendered page needs reload. No instantaneous withdrawal promise.'}
(E/'publication-checks.json').write_text(json.dumps(result,indent=2));print('PASS',len(checks),'delay',times['withdrawDelaySeconds'],flush=True)
