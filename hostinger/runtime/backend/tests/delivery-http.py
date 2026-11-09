#!/usr/bin/env python3
from pathlib import Path
import sys,os
import urllib.request,urllib.error,json,http.cookiejar,hashlib,hmac,secrets,subprocess,getpass,datetime,time,concurrent.futures,sqlite3,fcntl
R=Path(__file__).resolve().parents[1];U='http://127.0.0.1:4404';P='http://127.0.0.1:4408';env=json.loads((R/'private/env.json').read_text());rt=json.loads((R/'private/runtime.json').read_text());users=json.loads((R/'private/users.json').read_text());payload=json.loads((R/'tests/business.json').read_text());checks=[];runs=[];created=[]
assert json.loads((R/'evidence/security-http.json').read_text())['status']=='PASS','Security stage must pass first'
def sql(s):
 r=subprocess.run([rt['prefix']+'/bin/mariadb','--no-defaults','--protocol=socket','--socket='+rt['socket'],'--user='+getpass.getuser(),'--batch','--skip-column-names','r4_candidate'],input=s,text=True,capture_output=True);assert not r.returncode,'Fixture SQL failed';return r.stdout.strip()
def request(url,method='GET',body=None,headers=None,opener=None):
 data=body.encode() if isinstance(body,str) else None if body is None else json.dumps(body).encode();h=headers or {};q=urllib.request.Request(url,data=data,method=method,headers=h)
 try:r=(opener or urllib.request.build_opener()).open(q,timeout=20)
 except urllib.error.HTTPError as e:r=e
 raw=r.read().decode(errors='replace')
 try:b=json.loads(raw)
 except:b=raw
 return r.code,b,r.headers

def check(n,p,detail=''):
 checks.append({'name':n,'pass':bool(p),'detail':detail});print(n,'PASS' if p else 'FAIL',flush=True);(R/('evidence/delivery-retry.json' if '--retry-only' in sys.argv else 'evidence/delivery-http.json')).write_text(json.dumps({'status':'IN_PROGRESS','checks':checks,'worker_runs':runs},indent=2));assert p,n

def envelope(receipt=None,**extra):
 return dict(p_receipt=receipt or 'YNI-'+secrets.token_hex(6).upper(),p_kind='business',p_payload=payload,p_created_at=datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds').replace('+00:00','Z'),p_consent_version='2026-10-26-hostinger',**extra)
def signed(x,nonce=None,ts=None,key=None):
 body=json.dumps(x,separators=(',',':'));ts=str(ts or int(time.time()));nonce=nonce or secrets.token_hex(32);sig=hmac.new((key or env['R4_INGEST_KEY']).encode(),('POST\n/api/r4/ingest/business\n'+ts+'\n'+nonce+'\n'+hashlib.sha256(body.encode()).hexdigest()).encode(),hashlib.sha256).hexdigest();return body,{'Content-Type':'application/json','X-R4-Time':ts,'X-R4-Nonce':nonce,'X-R4-Signature':sig}
def ingest(x,**opts):
 body,h=signed(x,**opts);return request(U+'/api/r4/ingest/business','POST',body,h)
def counts(receipt):
 return sql("SELECT (SELECT COUNT(*) FROM business_inquiries WHERE receipt='"+receipt+"'),(SELECT COUNT(*) FROM ingest_receipts WHERE receipt='"+receipt+"'),(SELECT COUNT(*) FROM business_inquiry_notifications WHERE reference_code='"+receipt+"'),(SELECT COUNT(*) FROM audit_events WHERE event='inquiry.ingested' AND object_id IN(SELECT id FROM business_inquiries WHERE receipt='"+receipt+"')); ")
def worker():
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();p=subprocess.run([os.environ.get('R4_PHP_BIN','/opt/homebrew/opt/php@8.3/bin/php'),'-n',str(R/'php/private/forms/sync.php')],capture_output=True,text=True,timeout=65);log={'started':start,'ended':datetime.datetime.now(datetime.timezone.utc).isoformat(),'exit':p.returncode,'log':p.stdout+p.stderr};runs.append(log);return p.returncode,p.stdout+p.stderr

def submit(label):
 p={**payload,'companyName':label,'email':secrets.token_hex(4)+'@example.invalid'};s,b,h=request(P+'/api/submit-business-inquiry.php','POST',p,{'Origin':P,'Content-Type':'application/json'});check('PHP_accept_'+label,s==201);created.append(b['confirmationId']);return p,b['confirmationId']

def install_fault():
 existing=sql("SELECT GROUP_CONCAT(CONCAT(CHAR(39),id,CHAR(39))) FROM audit_events WHERE event='inquiry.ingested';")
 allowed=existing if existing and existing!='NULL' else "'00000000-0000-4000-8000-000000000000'"
 sql("ALTER TABLE audit_events ADD CONSTRAINT r4_test_failure CHECK (event <> 'inquiry.ingested' OR id IN ("+allowed+"));")

def login():
 op=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()));s,b,h=request(U+'/api/r4/login','POST',{k:users['owner'][k] for k in ['email','password']},{'Origin':U,'Content-Type':'application/json'},op);check('owner_login',s==200);return op
try:
 if '--retry-only' not in sys.argv:
  x=envelope();s,b,h=request(U+'/api/r4/ingest/business','POST',x,{'Content-Type':'application/json'});check('ingest_no_signature',s==401)
  check('ingest_wrong_key',ingest(x,key='e'*64)[0]==401);check('ingest_expired_signature',ingest(x,ts=int(time.time())-1000)[0]==401)
  check('ingest_role_spoof',ingest({**x,'role':'owner'})[0]==400);check('ingest_workspace_spoof',ingest({**x,'workspace_id':users['other']['workspace']})[0]==400)
  check('ingest_invalid_payload',ingest({**x,'p_payload':{**payload,'companyName':''}})[0]==400)
  # Real constraint failure after the record, receipt and notification statements; no test-only product route.
  fault='r4_test_failure';install_fault()
  f=envelope();s,b,h=ingest(f);check('transaction_error_visible',s==503);check('transaction_rollback_all_four',counts(f['p_receipt'])=='0\t0\t0\t0')
  sql('ALTER TABLE audit_events DROP CONSTRAINT '+fault+';')
  s,b,h=ingest(f);check('retry_after_rollback',s==200);check('atomic_four_records',counts(f['p_receipt'])=='1\t1\t1\t1')
  original=b[0]['remote_id'];check('lost_ACK_retry_same_id',ingest(f)[1][0]['remote_id']==original)
  check('receipt_payload_conflict',ingest({**f,'p_payload':{**payload,'companyName':'Changed synthetic payload'}})[0]==409)
  nonce=secrets.token_hex(32);check('fresh_nonce_delivery',ingest(f,nonce=nonce)[0]==200);check('nonce_replay_denied',ingest(f,nonce=nonce)[0]==409)
  parallel=envelope()
  with concurrent.futures.ThreadPoolExecutor(max_workers=12) as pool:results=list(pool.map(lambda _:ingest(parallel),range(12)))
  check('12_concurrent_deliveries',all(s==200 for s,b,h in results) and len({b[0]['remote_id'] for s,b,h in results})==1)
  check('concurrent_counts_one',counts(parallel['p_receipt'])=='1\t1\t1\t1')
  # Full ingress queue with unchanged public payload contract.
  p,receipt=submit('Synthetic PHP full path');s,b,h=request(P+'/api/submit-business-inquiry.php','POST',p,{'Origin':P,'Content-Type':'application/json'});check('public_duplicate_same_receipt',s==201 and b['confirmationId']==receipt)
  check('PHP_rejects_role',request(P+'/api/submit-business-inquiry.php','POST',{**p,'role':'owner'},{'Origin':P,'Content-Type':'application/json'})[0]==400)
  check('PHP_rejects_origin',request(P+'/api/submit-business-inquiry.php','POST',p,{'Origin':'https://evil.invalid','Content-Type':'application/json'})[0]==403)
  code,log=worker();check('worker_delivers',code==0 and counts(receipt)=='1\t1\t1\t1')
  code,log=worker();check('worker_repeat_no_duplicate',code==0 and counts(receipt)=='1\t1\t1\t1' and '"attempted":0' in log)
  op=login();s,listing,h=request(U+'/api/r4/inquiries',opener=op);r=next(v for v in listing if v['reference_code']==receipt);check('Admin_API_receives_PHP',r['company_name']==p['companyName'])
  form=dict(schema='pipeline-v2',id=r['id'],updated_at=r['updated_at'],status='qualified',internalNote='Synthetic processed through R4',contactRole='',offerInterest='not_specified',lostReason='',lostReasonDetail='',wonEvidenceType='',wonEvidenceDate='')
  with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:results=list(pool.map(lambda _:request(U+'/api/r4/inquiries/'+r['id'],'PATCH',form,{'Origin':U,'Content-Type':'application/json'},op),range(2)))
  check('concurrent_processing_CAS',sorted(s for s,b,h in results)==[200,409])
  request(U+'/api/r4/logout','POST',{}, {'Origin':U,'Content-Type':'application/json'},op);op=login();s,r2,h=request(U+'/api/r4/inquiries/'+r['id'],opener=op);check('processing_survives_relogin',s==200 and r2['status']=='qualified' and r2['admin_notes']==form['internalNote'] and r2['handled_by']==users['owner']['id'])
  # Queue acknowledgement failure after central COMMIT; queue must resend safely.
  p,ack=submit('Synthetic ACK recovery');sq=sqlite3.connect(R/'php/private/forms-data/submissions.sqlite');sq.execute("CREATE TRIGGER r4_ack_fault BEFORE INSERT ON delivery_receipts BEGIN SELECT RAISE(ABORT,'synthetic ack fault'); END");sq.commit();code,log=worker();check('ACK_failure_queue_retained',code==1 and counts(ack)=='1\t1\t1\t1' and sq.execute('SELECT COUNT(*) FROM delivery_receipts WHERE submission_id=?',(ack,)).fetchone()[0]==0);sq.execute('DROP TRIGGER r4_ack_fault');sq.commit();sq.close();check('ACK_retry_no_duplicate',worker()[0]==0 and counts(ack)=='1\t1\t1\t1')
  # Parallel workers: lock refusal plus multiple real worker processes.
  lock=open(R/'php/private/forms/sync.lock','a');fcntl.flock(lock,fcntl.LOCK_EX);code,log=worker();check('worker_lock_refusal',code==0 and 'worker_running' in log);fcntl.flock(lock,fcntl.LOCK_UN);lock.close()
  p,parallelQueue=submit('Synthetic worker race')
  with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:wr=list(pool.map(lambda _:worker(),range(4)))
  check('parallel_workers_one_record',all(c==0 for c,l in wr) and counts(parallelQueue)=='1\t1\t1\t1')
 # Retry must be scheduled, deferred and then delivered without edits to queue state.
 fault='r4_test_failure'
 if '--retry-only' in sys.argv:
  sq=sqlite3.connect(R/'php/private/forms-data/submissions.sqlite');pending=sq.execute('SELECT s.id FROM submissions s LEFT JOIN delivery_receipts d ON s.id=d.submission_id WHERE d.submission_id IS NULL').fetchall();sq.close();assert len(pending)==1;retryReceipt=pending[0][0]
 else:p,retryReceipt=submit('Synthetic delayed retry')
 install_fault()
 code,log=worker();check('temporary_error_scheduled',code==1 and 'retry_scheduled' in log and counts(retryReceipt)=='0\t0\t0\t0');sql('ALTER TABLE audit_events DROP CONSTRAINT '+fault+';')
 code,log=worker();check('backoff_deferred',code==0 and '"deferred":1' in log)
 time.sleep(31);code,log=worker();check('backoff_recovery',code==0 and counts(retryReceipt)=='1\t1\t1\t1')
 check('no_external_delivery_code',not any(x in (R/'php/private/forms/sync.php').read_text() for x in ['mail(', 'smtp:', 'stripe']))
 result={'status':'PASS','mode':'retry-only' if '--retry-only' in sys.argv else 'complete','checks':checks,'worker_runs':runs,'synthetic_receipts':created,'scheduled_hostinger_cron':'NOT_RUN','finished':datetime.datetime.now(datetime.timezone.utc).isoformat()}
except Exception as e:result={'status':'FAIL','failure':str(e),'checks':checks,'worker_runs':runs};raise
finally:(R/('evidence/delivery-retry.json' if '--retry-only' in sys.argv else 'evidence/delivery-http.json')).write_text(json.dumps(result,indent=2))
