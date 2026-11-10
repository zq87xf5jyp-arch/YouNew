"""Replace only managed Node application code, preserving hosting config and data."""
from pathlib import Path
import argparse,ctypes,datetime,hashlib,json,os,re,shutil,tarfile,time,urllib.request,urllib.error
os.umask(0o077)
p=argparse.ArgumentParser();p.add_argument('environment',choices=['qa','production']);p.add_argument('--commit',required=True);a=p.parse_args();assert re.fullmatch('[a-f0-9]{40}',a.commit)
base=Path('/home/u246392949/domains');root=base/'qa-catalog.younew.nl/younew-private/editorial-20261110'
host='qa-runtime.younew.nl' if a.environment=='qa' else 'admin.younew.nl';deployment=(base/host/'hbuilds/current').resolve();live=deployment/'nodejs';candidate=deployment/'nodejs-editorial-20261110'
assert live.is_dir() and (live/'server.js').is_file() and not candidate.exists()
manifest=json.loads((root/'node-payload-files.json').read_text());payload=root/'node-payload'
for x in manifest:assert hashlib.sha256((payload/x['path']).read_bytes()).hexdigest()==x['sha256']
assert json.loads((root/'node-build.json').read_text())['commit']==a.commit
if a.environment=='production':assert json.loads((root/'node-qa-result.json').read_text())['status']=='PASS'
backup=root/('node-'+a.environment+'-backup');backup.mkdir()
shutil.copytree(deployment/'public_html',backup/'public_html')
shutil.copytree(base/host/'hbuilds/config',backup/'config')
with tarfile.open(backup/'code-before.tar.gz','w:gz') as t:t.add(live,arcname='nodejs')
with tarfile.open(backup/'code-before.tar.gz') as t:assert t.extractfile('nodejs/server.js').read()==(live/'server.js').read_bytes()
shutil.copytree(payload,candidate,symlinks=True)
for old in (live/'.next/static').rglob('*'):
 if old.is_file():
  rel=old.relative_to(live);new=candidate/rel
  if new.exists():assert old.read_bytes()==new.read_bytes()
  else:new.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(old,new)
(candidate/'tmp').mkdir(exist_ok=True)
for f in candidate.rglob('*'):
 if not f.is_symlink():f.chmod(0o755 if f.is_dir() else 0o644)
candidate.chmod(0o755)
lib=ctypes.CDLL(None,use_errno=True)
def exchange():
 if lib.renameat2(-100,os.fsencode(live),-100,os.fsencode(candidate),2):raise OSError(ctypes.get_errno(),'Node exchange failed')
 (live/'tmp').mkdir(exist_ok=True);(live/'tmp/restart.txt').write_text(str(time.time()))
def req(path):
 try:r=urllib.request.urlopen('https://'+host+path,timeout=20)
 except urllib.error.HTTPError as e:r=e
 return r.status,r.read(),r.headers
before=req('/login')[1];checks=[];active=False
try:
 exchange();active=True
 expected=(live/'.next/BUILD_ID').read_text().strip()
 for n in range(12):
  code,body,h=req('/login?editorial='+a.commit[:12]);
  if code==200 and b'/_next/' in body and expected.encode() in body:break
  time.sleep(1)
 else:raise AssertionError('Managed restart did not serve the candidate build')
 for path in ['/api/r4/me','/api/r4/catalog','/api/r4/inquiries']:
  c,b,h=req(path);assert c==401 and 'no-store' in h.get('Cache-Control','') and 'noindex' in h.get('X-Robots-Tag','');checks.append({'path':path,'status':c,'noStore':True})
 if a.environment=='qa':
  exchange();active=False
  oldid=(live/'.next/BUILD_ID').read_text().strip()
  for n in range(12):
   c,b,h=req('/login?rollback=editorial');
   if c==200 and oldid.encode() in b:break
   time.sleep(1)
  else:raise AssertionError('QA rollback did not restore old build')
  exchange();active=True
  for n in range(12):
   c,b,h=req('/login?reactivate=editorial')
   if c==200 and expected.encode() in b:break
   time.sleep(1)
  else:raise AssertionError('QA reactivation failed')
 result={'status':'PASS','commit':a.commit,'environment':a.environment,'buildId':expected,'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'rollbackDirectory':str(candidate),'backup':str(backup),'managedDeployment':str(deployment),'rollbackRehearsed':a.environment=='qa','databaseChanged':False,'hostingConfigChanged':False}
 (root/('node-'+a.environment+'-result.json')).write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
except:
 if active:exchange()
 raise
