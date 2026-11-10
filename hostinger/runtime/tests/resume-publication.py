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
saved=json.loads((E/'publication-before-resume.json').read_text());checks=[x for x in saved['checks'] if x['status']=='PASS'];times=saved['timings']
recoveryStarted=time.monotonic();elapsedBefore=(datetime.datetime.now(datetime.timezone.utc)-datetime.datetime.fromisoformat(times['withdrawAcknowledgedAt'])).total_seconds();t0=recoveryStarted-elapsedBefore
anon=client();admin=login('owner');row=next(x for x in api(admin,'catalog')[1] if x['document']['title']=='[SYNTHETIC] Integration hotel');publicId=row['publicId'];slug=publicId.removeprefix('place.')
current=json.loads((E/'approved-publication.json').read_text());prior=(R/'publication/current.json').read_bytes();check('ENOSPC_retained_previous_release',json.loads(prior)['releaseId']==current['releaseId']);check('still_withdrawn_before_resume',row['state']=='draft');check('failed_real_build_keeps_prior_page',req(anon,W+'/places/'+slug+'/')[0]==200)
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
