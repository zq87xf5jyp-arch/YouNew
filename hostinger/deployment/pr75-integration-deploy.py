"""PR75/76 static publication of 43 exactly owner-approved place revisions. Private data are never replaced."""
from pathlib import Path
import ctypes, datetime, hashlib, json, os, shutil, sqlite3, sys, tarfile, urllib.request, urllib.error
os.umask(0o077)
BASE=Path('/home/u246392949/domains/younew.nl')
ROOT=BASE/'younew-private/pr75-integration-production-20261116'
LIVE=BASE/'public_html'
SLOT=BASE/'public-pr75-integration-20261116-rollback'
OUT=ROOT/'candidate/out'
COMMIT=json.loads((ROOT/'candidate-meta.json').read_text())['commit'] if (ROOT/'candidate-meta.json').exists() else 'pending'
LAUNCH=BASE/'younew-private/launch-production'
QA=Path('/home/u246392949/domains/qa-catalog.younew.nl/younew-private')
CONFIGS=[LAUNCH/n for n in ['production-active-release.json','editorial-active-release.json','editorial-drafts.json','business-sync-config.php','migration.env','health-config.json']]+[Path('/home/u246392949/domains/admin.younew.nl/younew-private/launch.env')]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,v): p.write_text(json.dumps(v,indent=2)+'\n');p.chmod(0o600)
def manifest(root):
 result={}
 for p in sorted(root.rglob('*')):
  assert not p.is_symlink(), str(p)
  if p.is_file(): result[str(p.relative_to(root))]=sha(p)
 return result
def check(root,expected): assert manifest(root)==expected, 'File manifest mismatch: '+str(root)
def exchange(a,b):
 lib=ctypes.CDLL(None,use_errno=True)
 if lib.renameat2(-100,os.fsencode(a),-100,os.fsencode(b),2): raise OSError(ctypes.get_errno(),'Atomic exchange failed')
def request(origin,path):
 headers={'Cache-Control':'no-cache'}
 if path.startswith('/api/submit-'): headers['Origin']=origin
 try: r=urllib.request.urlopen(urllib.request.Request(origin+path,headers=headers),timeout=30)
 except urllib.error.HTTPError as error: r=error
 return r.status,r.read(),r.headers
def snapshot():
 assert not (ROOT/'backup.json').exists() and not SLOT.exists(), 'Never overwrite previous release evidence'
 ROOT.mkdir(mode=0o700,exist_ok=True)
 before=manifest(LIVE);dump(ROOT/'before-files.json',before)
 with tarfile.open(ROOT/'public-before.tar.gz','w:gz') as t:t.add(LIVE,arcname='public_html')
 restore=ROOT/'restore-verification';restore.mkdir()
 with tarfile.open(ROOT/'public-before.tar.gz') as t:t.extractall(restore)
 check(restore/'public_html',before)
 # Rehearse forward and backward atomic exchange on restored copies only.
 a=ROOT/'exchange-a';b=ROOT/'exchange-b';a.mkdir();b.mkdir()
 (a/'probe').write_text('before');(b/'probe').write_text('after')
 exchange(a,b);assert (a/'probe').read_text()=='after'
 exchange(a,b);assert (a/'probe').read_text()=='before'
 shutil.rmtree(a);shutil.rmtree(b);shutil.rmtree(restore)
 config_hashes={}
 for i,p in enumerate(CONFIGS):
  config_hashes[str(p)]=sha(p);shutil.copy2(p,ROOT/('config-'+str(i)+'.private'));(ROOT/('config-'+str(i)+'.private')).chmod(0o600)
 queue=BASE/'younew-private/forms-data/submissions.sqlite'
 with sqlite3.connect('file:'+str(queue)+'?mode=ro',uri=True) as src,sqlite3.connect(ROOT/'queue-before.sqlite') as dst:
  src.backup(dst);assert dst.execute('pragma integrity_check').fetchone()[0]=='ok'
 dump(ROOT/'backup.json',{'commit':COMMIT,'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':len(before),'archiveSha256':sha(ROOT/'public-before.tar.gz'),'restoreAllFilesVerified':True,'atomicExchangeRehearsed':True,'configHashes':config_hashes,'queueSnapshotIntegrity':'ok','rollbackRestoresDatabase':False})
 print(json.dumps({'backup':'PASS','files':len(before),'path':str(ROOT),'restoreVerified':True}))
def configurations_unchanged():
 b=json.loads((ROOT/'backup.json').read_text())
 assert all(sha(Path(p))==v for p,v in b['configHashes'].items()),'Private configuration changed'
def stage():
 meta=json.loads((ROOT/'candidate-meta.json').read_text())
 assert len(COMMIT)==40 and sha(ROOT/'candidate.tar.gz')==meta['archiveSha256']
 qa=json.loads((QA/'pr75-integration-20261116-approved-r1/result.json').read_text())
 assert qa['status']=='PASS' and qa['previousQaRestored'] and qa['g01EnNlUnchanged']
 assert qa['archiveSha256']==meta['archiveSha256']
 assert any(x.get('real404') and x['http']==404 for x in qa['checks'])
 assert not OUT.exists()
 with tarfile.open(ROOT/'candidate.tar.gz') as t:
  for m in t.getmembers():assert (m.name=='out' or m.name.startswith('out/')) and '..' not in Path(m.name).parts and (m.isfile() or m.isdir())
  t.extractall(ROOT/'candidate')
 check(LIVE,json.loads((ROOT/'before-files.json').read_text()));configurations_unchanged()
 expected=json.loads((ROOT/'files.json').read_text())
 check(OUT,expected)
 assert sha(OUT/'data/status.json')==meta['statusSha256']
 assert not (OUT/'PRIVATE-REVIEW.json').exists() and not (OUT/'images/place-review').exists()
 status=json.loads((OUT/'data/status.json').read_text())
 assert status['content']['counts']=={'total':106,'places':84,'summaryGuides':17,'cities':5,'fullGuides':0}
 assert status['liveMonitoring'] is False and status['assessment'].startswith('PARTIAL')
 provenance=json.loads((OUT/'data/content-provenance.json').read_text())
 assert status['content']['datasetFingerprint']==provenance['datasetFingerprint']
 revisions=provenance['editorialRelease']['revisions']
 assert len(revisions)==7
 for expected in meta['approvedBatches']:
  revision=next(r for r in revisions if r['id']==expected['id'])
  assert revision['approvalSha256']==expected['approvalSha256'] and revision['count']==expected['count'] and revision['reviewerId']=='owner.ivan'
 assert len(next(r for r in revisions if r['id']=='amsterdam-museums-20261115')['addedIds'])==20
 assert len(next(r for r in revisions if r['id']=='pr75-integration-20261116')['addedIds'])==10
 assert not (OUT/'review').exists()
 # Existing server directives and all PHP endpoint code must stay identical.
 for p in LIVE.rglob('*'):
  if p.is_file() and (p.name=='.htaccess' or p.suffix=='.php'):
   other=OUT/p.relative_to(LIVE)
   if other.exists(): assert sha(p)==sha(other),'Runtime file changed: '+str(p.relative_to(LIVE))
 shutil.copytree(OUT,SLOT)
 for p in LIVE.rglob('*'):
  if not p.is_file():continue
  rel=p.relative_to(LIVE);name=str(rel)
  if not (name.startswith('_next/static/') or name.startswith('.well-known/') or (p.parent==LIVE and p.name.startswith('static-shell.') and p.suffix=='.js') or p.name=='.htaccess' or p.suffix=='.php'):continue
  q=SLOT/rel
  if q.exists():assert sha(q)==sha(p),name
  else:q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
 for p in [SLOT,*SLOT.rglob('*')]:p.chmod(0o755 if p.is_dir() else 0o644)
 # Rehearse the actual candidate/backup exchange in isolated directories.
 candidate_hashes=manifest(SLOT)
 restored=ROOT/'rollback-rehearsal';restored.mkdir()
 with tarfile.open(ROOT/'public-before.tar.gz') as t:t.extractall(restored)
 old=restored/'public_html'
 check(old,json.loads((ROOT/'before-files.json').read_text()))
 exchange(SLOT,old)
 try:
  check(SLOT,json.loads((ROOT/'before-files.json').read_text()))
  check(old,candidate_hashes)
 finally:exchange(SLOT,old)
 check(SLOT,candidate_hashes)
 shutil.rmtree(restored)
 dump(ROOT/'candidate-files.json',candidate_hashes)
 dump(ROOT/'stage.json',{'status':'STAGED','commit':COMMIT,'qa':qa,'preservedRuntime':True,'actualCandidateRollbackRehearsed':True,'approvedPlaceRevisions':43,'rollbackDirectory':str(SLOT)})
 print(json.dumps({'stage':'PASS','files':len(manifest(SLOT))}))
def probes(root):
 checks=[]
 routes=json.loads((ROOT/'release-routes.json').read_text())
 for path in routes:
  code,body,h=request('https://younew.nl',path)
  local=root/path.lstrip('/')
  if path.endswith('/'):local=local/'index.html'
  if not local.is_file():
   assert code==404,(path,code,'rollback must withhold new page');checks.append({'path':path,'http':404});continue
  assert code==200 and hashlib.sha256(body).hexdigest()==sha(local),(path,code,'response does not match artifact')
  if path.endswith('.json'):assert 'application/json' in h.get('Content-Type','')
  checks.append({'path':path,'http':code,'exact':True})
 for path,expected in [('/api/submit-business-inquiry.php',405),('/api/submit-public-feedback.php',405),('/api/private-files.php',404)]:
  code,_,h=request('https://younew.nl',path);assert code==expected and 'no-store' in h.get('Cache-Control',''),(path,code)
  checks.append({'path':path,'http':code,'noStore':True})
 for path in ['/.env','/.git/config','/younew-private/launch-production/migration.env','/places-release-missing-20261115/','/review/guides/leiden-bsn/en/']:
  code,_,_=request('https://younew.nl',path);assert code in [403,404],(path,code)
  checks.append({'path':path,'http':code})
 cfg=json.loads((LAUNCH/'health-config.json').read_text())
 for item in cfg['urls']:
  url=item['url'];from urllib.parse import urlsplit
  if urlsplit(url).hostname!='admin.younew.nl':continue
  u=urlsplit(url);code,_,h=request(u.scheme+'://'+u.netloc,u.path)
  expected=item.get('expectedStatus',item.get('status',200))
  assert code==expected,(u.path,code,expected)
  if code==401:assert 'no-store' in h.get('Cache-Control','')
  checks.append({'origin':'admin','path':u.path,'http':code})
 return checks
def activate():
 meta=json.loads((ROOT/'candidate-meta.json').read_text())
 # A separate owner deployment decision must bind the exact checked artifact.
 authorization=json.loads((ROOT/'production-authorization.json').read_text())
 assert authorization['status']=='approved' and authorization['reviewerId']=='owner.ivan'
 assert authorization['scope']=='production-deploy-and-merge-pr75-pr76'
 assert authorization['commit']==COMMIT and authorization['archiveSha256']==meta['archiveSha256']
 assert authorization['editorialRequestSha256']=='58bc2fefa694ac31b4f3558a283e8d2b3c7b5997f7bb4598d278e52b2fbf6e11'
 assert len(authorization['ownerConfirmation'])>20 and authorization['questionItemId']
 assert len(meta.get('mergedCommit',''))==40 and meta.get('pullRequests')==[75,76], 'Verified PR75/76 merge required'
 ci=json.loads((ROOT/'ci-result.json').read_text())
 assert ci['commit']==COMMIT and ci['status']=='PASS' and ci['allApplicableWorkflowsPassed'] is True
 browser=json.loads((QA/'pr75-integration-20261116-approved-r1/browser-result.json').read_text())
 assert browser['archiveSha256']==meta['archiveSha256'] and browser['status']=='PASS' and browser['previousQaRestored'] is True
 assert json.loads((ROOT/'stage.json').read_text())['commit']==COMMIT
 assert not (ROOT/'production-result.json').exists()
 check(LIVE,json.loads((ROOT/'before-files.json').read_text()))
 check(SLOT,json.loads((ROOT/'candidate-files.json').read_text()));configurations_unchanged()
 changed=False
 try:
  exchange(LIVE,SLOT);changed=True
  checks=probes(LIVE);configurations_unchanged()
  check(SLOT,json.loads((ROOT/'before-files.json').read_text()))
  dump(ROOT/'production-result.json',{'status':'ACTIVE','commit':COMMIT,'mergedCommit':meta['mergedCommit'],'activatedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'backup':str(ROOT/'public-before.tar.gz'),'rollbackDirectory':str(SLOT),'privateConfigurationUnchanged':True,'approvedPlaceRevisions':43,'rollbackCommand':'python3 '+str(ROOT/'pr75-integration-deploy.py')+' rollback'})
  print(json.dumps({'status':'ACTIVE','commit':COMMIT,'mergedCommit':meta['mergedCommit'],'checks':len(checks)}))
 except:
  if changed:exchange(LIVE,SLOT)
  check(LIVE,json.loads((ROOT/'before-files.json').read_text()))
  dump(ROOT/'activation-failed.json',{'status':'ROLLED_BACK','at':datetime.datetime.now(datetime.timezone.utc).isoformat()})
  raise
def rollback():
 assert json.loads((ROOT/'production-result.json').read_text())['status']=='ACTIVE'
 check(LIVE,json.loads((ROOT/'candidate-files.json').read_text()))
 check(SLOT,json.loads((ROOT/'before-files.json').read_text()))
 exchange(LIVE,SLOT)
 try:checks=probes(LIVE)
 except:exchange(LIVE,SLOT);raise
 dump(ROOT/'rollback-result.json',{'status':'ROLLED_BACK','at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'databaseRestored':False})
 print('ROLLBACK PASS — private data and queues retained')
if __name__=='__main__':
 assert len(sys.argv)==2
 {'backup':snapshot,'stage':stage,'activate':activate,'rollback':rollback}[sys.argv[1]]()
