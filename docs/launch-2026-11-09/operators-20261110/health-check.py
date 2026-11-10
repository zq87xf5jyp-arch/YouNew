"""Low-cost read-only service and outbox health, without credentials or contact data."""
from pathlib import Path
import datetime,fcntl,json,os,sqlite3,sys,time,urllib.request,urllib.error
os.umask(0o077)
config=Path(sys.argv[1]);assert config.is_file() and not config.is_symlink() and config.stat().st_mode&0o077==0
c=json.loads(config.read_text());output=Path(c['output']);assert '/younew-private/' in str(output) and not output.is_symlink();output.mkdir(mode=0o700,exist_ok=True)
lock=open(output/'health.lock','a')
try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
except BlockingIOError:raise SystemExit(0)
checks=[]
for target in c['urls']:
 try:
  q=urllib.request.Request(target['url'],method='HEAD',headers={'User-Agent':'YouNew-Health/1.0'})
  try:r=urllib.request.urlopen(q,timeout=8)
  except urllib.error.HTTPError as e:r=e
  ok=r.status==target['status'] and (not target.get('private') or 'no-store' in r.headers.get('Cache-Control',''))
  checks.append({'name':target['name'],'pass':ok,'http':r.status})
 except Exception as e:checks.append({'name':target['name'],'pass':False,'error':type(e).__name__})
try:
 with sqlite3.connect(Path(c['queue']).as_uri()+'?mode=ro',uri=True,timeout=5) as db:
  n,oldest=db.execute("SELECT COUNT(*),MIN(s.created_at) FROM submissions s LEFT JOIN delivery_receipts d ON d.submission_id=s.id WHERE s.kind='business' AND d.submission_id IS NULL").fetchone()
  age=0 if not oldest else max(0,time.time()-datetime.datetime.fromisoformat(oldest.replace('Z','+00:00')).timestamp())
  checks.append({'name':'business_outbox','pass':age<c['maxPendingSeconds'],'pending':n,'oldestSeconds':int(age)})
except Exception as e:checks.append({'name':'business_outbox','pass':False,'error':type(e).__name__})
try:
 p=Path(c['cronLog'])
 with p.open('rb') as f:
  f.seek(max(0,p.stat().st_size-65536));lines=f.read().decode().splitlines()
 events=[]
 for line in lines:
  try:
   e=json.loads(line)
   if e.get('event')=='cron_end':events.append(e)
  except ValueError:pass
 last=events[-1]['at'];age=time.time()-datetime.datetime.fromisoformat(last.replace('Z','+00:00')).timestamp()
 checks.append({'name':'business_scheduler','pass':age<c['maxCronSeconds'],'lastCompletedAt':last,'ageSeconds':int(age)})
except Exception as e:checks.append({'name':'business_scheduler','pass':False,'error':type(e).__name__})
result={'status':'OK' if all(x['pass'] for x in checks) else 'DEGRADED','at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'externalNotificationsConfigured':False}
latest=output/'health-latest.json';prior=json.loads(latest.read_text()) if latest.exists() else {}
tmp=output/'health-latest.tmp';tmp.write_text(json.dumps(result,indent=2)+'\n');os.replace(tmp,latest)
if prior.get('status')!=result['status']:
 with (output/'health-transitions.jsonl').open('a') as f:f.write(json.dumps(result)+'\n')
print(json.dumps(result));raise SystemExit(0 if result['status']=='OK' else 1)
