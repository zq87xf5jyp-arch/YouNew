"""Code-only production switch with verified backup; mutable data are never replaced."""
from pathlib import Path
import ctypes,datetime,hashlib,json,os,shutil,sqlite3,subprocess,time,urllib.request,urllib.error
os.umask(0o077)
base=Path('/home/u246392949/domains/younew.nl');root=base/'younew-private/launch-production'
live=base/'public_html';candidate=base/'public-release-5e0b3e1'
commit='0c583ef093ae57863df7f7ea938d3c1dd32ff995';payload='5e0b3e152c7619f967fc7b518854bd6d8c9cb374'
backup=base/'younew-private/launch-backups/production-pre-switch-20261110T144758Z'
assert json.loads((backup/'result.json').read_text())['status']=='PASS'
assert (root/'PRODUCTION_BUSINESS_PAUSED').is_file()
assert not (root/'production-active-release.json').exists()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(live/'index.html')=='640029346dbd00c7fd626acc65bbd2badbd5560f340d6629681a1babd8a2d254'
manifest=json.loads((root/'production-candidate-files-5e0b3e1.json').read_text())
for row in manifest:assert sha(candidate/row['path'])==row['sha256']
assert len(manifest)==1215
forms=base/'younew-private/forms-v1';prepared=root/'php-prepared-5e0b3e1/forms-v1'
change=root/'activation-20261110';change.mkdir(mode=0o700)
shutil.copytree(forms,change/'forms-v1-before')
queue=base/'younew-private/forms-data/submissions.sqlite'
with sqlite3.connect('file:'+str(queue)+'?mode=ro',uri=True) as source,sqlite3.connect(change/'queue-before.sqlite') as target:
 source.backup(target);assert target.execute('pragma integrity_check').fetchone()[0]=='ok'
 baseline=target.execute('select id,kind,payload,dedupe,created_at,consent_version,status from submissions order by id').fetchall()
 counts=dict(target.execute('select kind,count(*) from submissions group by kind'))
(change/'queue-before.sqlite').chmod(0o600)
old_hash=sha(live/'index.html');new_hash=sha(candidate/'index.html');changed=False;installed=[];checks=[]
libc=ctypes.CDLL(None,use_errno=True)
def exchange():
 rc=libc.renameat2(-100,os.fsencode(live),-100,os.fsencode(candidate),2)
 if rc!=0:raise OSError(ctypes.get_errno(),'atomic directory exchange failed')
def request(url,method='GET',body=None,headers=None):
 q=urllib.request.Request(url,data=body,method=method,headers=headers or {})
 try:r=urllib.request.urlopen(q,timeout=15)
 except urllib.error.HTTPError as e:r=e
 return r.status,r.read(),r.headers
try:
 for name in ['origins.php','sync-config.php','service.php','sync.php']:
  dst=forms/name;tmp=forms/(name+'.release-tmp');shutil.copy2(prepared/name,tmp);tmp.chmod(0o600);os.replace(tmp,dst);installed.append(name)
 exchange();changed=True
 for path,file in [('/','index.html'),('/nl/','nl/index.html'),('/search/','search/index.html'),('/map/','map/index.html'),('/for-business/local/apply/','for-business/local/apply/index.html'),('/nl/voor-bedrijven/aanmelden/','nl/voor-bedrijven/aanmelden/index.html')]:
  status,body,h=request('https://younew.nl'+path+'?launch=5e0b3e1')
  ok=status==200 and hashlib.sha256(body).hexdigest()==sha(live/file)
  checks.append({'path':path,'status':status,'exact':ok});assert ok,path
 status,body,h=request('https://younew.nl/release-check-does-not-exist-20261110/')
 checks.append({'path':'404','status':status,'bodyMatches':hashlib.sha256(body).hexdigest()==sha(live/'404.html')});assert status==404
 assert hashlib.sha256(body).hexdigest()==sha(live/'404.html')
 for name in ['submit-business-inquiry.php','submit-public-feedback.php']:
  status,body,h=request('https://younew.nl/api/'+name,headers={'Origin':'https://younew.nl'})
  assert status==405 and 'no-store' in h.get('Cache-Control','')
  checks.append({'path':'/api/'+name,'status':status,'noStore':True})
 status,body,h=request('https://younew.nl/api/private-files.php');assert status==404 and 'no-store' in h.get('Cache-Control','')
 for path in ['/younew-private/launch-production/migration.env','/.env','/api/submissions.sqlite']:
  status,body,h=request('https://younew.nl'+path);assert status in [403,404];checks.append({'path':path,'status':status})
 with sqlite3.connect('file:'+str(queue)+'?mode=ro',uri=True) as db:
  after=db.execute('select id,kind,payload,dedupe,created_at,consent_version,status from submissions order by id').fetchall()
  assert set(baseline)<=set(after)
 report={'status':'ACTIVE','commit':commit,'payloadCommit':payload,'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'backup':str(backup),'codeRollbackDirectory':str(candidate),'activationBackup':str(change),'beforeRootSha256':old_hash,'afterRootSha256':new_hash,'files':len(manifest),'queueBaselineCounts':counts,'queueBaselineRowsPreserved':True,'cronPaused':True,'checks':checks}
 (root/'production-active-release.json').write_text(json.dumps(report,indent=2)+'\n')
except Exception as error:
 if changed:exchange()
 for name in installed:
  old=change/'forms-v1-before'/name
  if old.exists():shutil.copy2(old,forms/name)
  else:os.replace(forms/name,change/(name+'.failed-new'))
 report={'status':'ROLLED_BACK','errorType':type(error).__name__,'checks':checks,'queueUntouched':True,'rootRestored':sha(live/'index.html')==old_hash}
 (root/'production-activation-result.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps(report));raise SystemExit(1)
(root/'production-activation-result.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
