"""Scoped, reversible deployment of the owner-approved 71-item editorial batch.
Run over the existing pinned SSH connection. Never changes mail, DNS, DB or cron.
"""
from pathlib import Path
import argparse,base64,ctypes,datetime,hashlib,json,os,re,shutil,sqlite3,tarfile,urllib.request,urllib.error
os.umask(0o077)
BASE=Path('/home/u246392949/domains')
BATCH='4010ebb033f399c0807bd2dca43b66c8ae03ba4ac0cfdc0e632fe718ee6293ea'
ROOT=BASE/'qa-catalog.younew.nl/younew-private/editorial-20261110'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,v):p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n');p.chmod(0o600)
def exchange(a,b):
 lib=ctypes.CDLL(None,use_errno=True)
 if lib.renameat2(-100,os.fsencode(a),-100,os.fsencode(b),2):raise OSError(ctypes.get_errno(),'Atomic exchange failed')
def request(origin,path,auth=None):
 headers={'Cache-Control':'no-cache'}
 if auth:headers['Authorization']='Basic '+base64.b64encode((auth['user']+':'+auth['password']).encode()).decode()
 try:r=urllib.request.urlopen(urllib.request.Request(origin+path,headers=headers),timeout=30)
 except urllib.error.HTTPError as e:r=e
 return r.status,r.read(),r.headers

def verify_files(out,manifest):
 assert len(manifest)>1000
 assert {str(p.relative_to(out)) for p in out.rglob('*') if p.is_file()}=={x['path'] for x in manifest}
 for x in manifest:assert sha(out/x['path'])==x['sha256'],x['path']
 p=json.loads((out/'data/content-provenance.json').read_text())
 assert p['editorialRelease']['batchSha256']==BATCH and p['editorialRelease']['count']==71
 return p

def check_public(origin,out,auth=None):
 checks=[]
 routes=['/','/nl/','/leiden/','/nl/leiden/','/search/','/nl/zoeken/','/map/','/for-business/local/']
 routes+=json.loads((ROOT/'routes.json').read_text())
 for route in dict.fromkeys(routes):
  code,body,headers=request(origin,route+'?editorial='+args.commit[:12],auth)
  assert code==200 and hashlib.sha256(body).hexdigest()==sha(out/(route.strip('/')+'/index.html' if route!='/' else 'index.html')),(route,code,hashlib.sha256(body).hexdigest(),body[:80] if code!=200 else '')
  if auth:assert 'noindex' in headers.get('X-Robots-Tag','') and 'no-store' in headers.get('Cache-Control','')
  checks.append({'path':route,'status':code,'exact':True})
 for route in ['/.env','/younew-private/launch-production/migration.env','/.git/config','/editorial-missing-20261110/']:
  code,_,_=request(origin,route,auth);assert code in [403,404],route
  checks.append({'path':route,'status':code})
 return checks

def stage():
 assert not (ROOT/'out').exists()
 archive=ROOT/'public.tar.gz';assert sha(archive)==args.archive_sha
 with tarfile.open(archive) as t:
  for m in t.getmembers():
   assert not m.name.startswith('/') and '..' not in Path(m.name).parts and (m.isfile() or m.isdir())
  t.extractall(ROOT)
 verify_files(ROOT/'out',json.loads((ROOT/'files.json').read_text()))
 dump(ROOT/'stage.json',{'status':'STAGED','commit':args.commit,'archiveSha256':args.archive_sha})

def qa():
 # The existing authenticated PHP router reads its JSON pointer on every request.
 # Keep its code/config intact, avoiding delayed PHP opcode-cache invalidation.
 store=BASE/'qa-catalog.younew.nl/younew-private/hp1/publication';pointer=store/'current.json'
 before=pointer.read_bytes();backup=ROOT/'qa-pointer-before.json'
 if backup.exists():assert backup.read_bytes()==before
 else:backup.write_bytes(before)
 release=store/'releases/hp-editorial-20261110'
 if not release.exists():
  release.mkdir();shutil.copytree(ROOT/'out',release/'out')
 verify_files(release/'out',json.loads((ROOT/'files.json').read_text()))
 auth=json.loads((BASE/'qa-catalog.younew.nl/younew-private/hp1/qa-http.private.json').read_text())
 prior=request('https://qa-catalog.younew.nl','/',auth)
 def activate_pointer():
  temp=store/'editorial-pointer.tmp';dump(temp,{'releaseId':'hp-editorial-20261110'});os.replace(temp,pointer)
 try:
  activate_pointer();checks=check_public('https://qa-catalog.younew.nl',ROOT/'out',auth)
  assert request('https://qa-catalog.younew.nl','/')[0]==401
  pointer.write_bytes(before)
  restored=request('https://qa-catalog.younew.nl','/',auth)
  assert restored[0]==prior[0] and restored[1]==prior[1]
  activate_pointer()
  assert request('https://qa-catalog.younew.nl','/leiden/',auth)[0]==200
  dump(ROOT/'qa-result.json',{'status':'PASS','commit':args.commit,'checks':checks,'anonymousDenied':True,'rollbackRehearsed':True})
 except:
  pointer.write_bytes(before);raise

def stageprod():
 assert json.loads((ROOT/'qa-result.json').read_text())['status']=='PASS'
 assert json.loads((ROOT/'isolated-node-result.json').read_text())['status']=='PASS'
 base=BASE/'younew.nl';live=base/'public_html';candidate=base/'public-editorial-20261110';backup=base/'younew-private/editorial-backup-20261110'
 assert not candidate.exists() and not backup.exists();backup.mkdir()
 verify_files(ROOT/'out',json.loads((ROOT/'files.json').read_text()))
 with tarfile.open(backup/'public-before.tar.gz','w:gz') as t:t.add(live,arcname='public_html')
 with tarfile.open(backup/'public-before.tar.gz') as t:
  assert hashlib.sha256(t.extractfile('public_html/index.html').read()).hexdigest()==sha(live/'index.html')
 queue=base/'younew-private/forms-data/submissions.sqlite'
 with sqlite3.connect('file:'+str(queue)+'?mode=ro',uri=True) as s,sqlite3.connect(backup/'queue-before.sqlite') as d:
  s.backup(d);assert d.execute('pragma integrity_check').fetchone()[0]=='ok'
 for name in ['production-active-release.json','editorial-drafts.json']:
  shutil.copy2(base/'younew-private/launch-production'/name,backup/name)
 shutil.copytree(ROOT/'out',candidate)
 # Preserve immutable assets for already-open clients and existing private-file bootstrap.
 for p in live.rglob('*'):
  rel=p.relative_to(live);s=str(rel)
  if not (s.startswith('_next/static/') or (p.parent==live and p.name.startswith('static-shell.') and p.suffix=='.js') or s.startswith('.well-known/') or s=='api/private-files.php'):continue
  if not p.is_file():continue
  assert not p.is_symlink();q=candidate/rel
  if q.exists():assert sha(q)==sha(p)
  else:q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
 for p in [candidate,*candidate.rglob('*')]:
  assert not p.is_symlink();p.chmod(0o755 if p.is_dir() else 0o644)
 manifest=[{'path':str(p.relative_to(candidate)),'sha256':sha(p)} for p in sorted(candidate.rglob('*')) if p.is_file()]
 dump(ROOT/'production-files.json',manifest)
 dump(ROOT/'production-staged.json',{'status':'STAGED','commit':args.commit,'beforeRootSha256':sha(live/'index.html'),'backup':str(backup),'backupSha256':sha(backup/'public-before.tar.gz')})

def activate():
 stage=json.loads((ROOT/'production-staged.json').read_text());assert stage['commit']==args.commit
 live=BASE/'younew.nl/public_html';candidate=BASE/'younew.nl/public-editorial-20261110'
 assert sha(live/'index.html')==stage['beforeRootSha256']
 for x in json.loads((ROOT/'production-files.json').read_text()):assert sha(candidate/x['path'])==x['sha256']
 assert json.loads((ROOT/'node-production-result.json').read_text())['status']=='PASS'
 changed=False
 try:
  exchange(live,candidate);changed=True
  checks=check_public('https://younew.nl',live)
  for path,expected in [('/api/submit-business-inquiry.php',405),('/api/submit-public-feedback.php',405),('/api/private-files.php',404)]:
   code,_,h=request('https://younew.nl',path);assert code==expected and 'no-store' in h.get('Cache-Control','');checks.append({'path':path,'status':code,'noStore':True})
  queue=BASE/'younew.nl/younew-private/forms-data/submissions.sqlite'
  with sqlite3.connect('file:'+str(Path(stage['backup'])/'queue-before.sqlite')+'?mode=ro',uri=True) as before, sqlite3.connect('file:'+str(queue)+'?mode=ro',uri=True) as after:
   query='select id,kind,payload,dedupe,created_at,consent_version from submissions'
   assert set(before.execute(query))<=set(after.execute(query))
  old=BASE/'younew.nl/younew-private/launch-production/editorial-drafts.json'
  approved=json.loads((ROOT/'approved-admin-documents.json').read_text())
  policy=json.loads((ROOT/'admin-approval.json').read_text())
  assert hashlib.sha256(json.dumps(approved['entities'],sort_keys=True,ensure_ascii=False,separators=(',',':')).encode()).hexdigest()==policy['documentsSha256']
  approved['publication']={**policy,'status':'active','sourceCommit':args.commit,'activatedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'publicProvenanceSha256':sha(live/'data/content-provenance.json')}
  tmp=old.with_suffix('.editorial-tmp');dump(tmp,approved);os.replace(tmp,old)
  result={'status':'ACTIVE','commit':args.commit,'batchSha256':BATCH,'at':approved['publication']['activatedAt'],'count':71,'languagePages':142,'checks':checks,'codeRollbackDirectory':str(candidate),'backup':stage['backup'],'rootSha256':sha(live/'index.html'),'provenanceSha256':sha(live/'data/content-provenance.json')}
  dump(ROOT/'production-result.json',result)
  dump(BASE/'younew.nl/younew-private/launch-production/editorial-active-release.json',result)
 except:
  if changed:exchange(live,candidate)
  shutil.copy2(Path(stage['backup'])/'editorial-drafts.json',BASE/'younew.nl/younew-private/launch-production/editorial-drafts.json')
  raise

p=argparse.ArgumentParser();p.add_argument('action',choices=['stage','qa','stageprod','activate']);p.add_argument('--commit',required=True);p.add_argument('--archive-sha');args=p.parse_args();assert re.fullmatch('[a-f0-9]{40}',args.commit)
ROOT.mkdir(exist_ok=True)
{'stage':stage,'qa':qa,'stageprod':stageprod,'activate':activate}[args.action]()
print(json.dumps({'status':'PASS','action':args.action,'commit':args.commit}))
