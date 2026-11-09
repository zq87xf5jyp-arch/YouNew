from pathlib import Path
import json,urllib.request,urllib.error,http.cookiejar,secrets,subprocess,os
R=Path(__file__).resolve().parents[1];P='http://127.0.0.1:4408';U='http://127.0.0.1:4404';checks=[]
def req(url,method='GET',body=None,opener=None):
 origin=P if url.startswith(P) else U;q=urllib.request.Request(url,method=method,headers={'Origin':origin,'Content-Type':'application/json'},data=json.dumps(body).encode() if body is not None else None)
 try:r=(opener or urllib.request).open(q,timeout=15) if opener else urllib.request.urlopen(q,timeout=15)
 except urllib.error.HTTPError as e:r=e
 data=r.read().decode()
 try:data=json.loads(data)
 except:pass
 return r.status,data
def check(n,c):assert c,n;checks.append({'name':n,'pass':True})
check('web_home_same_PHP_origin',req(P+'/')[0]==200)
payload=json.loads((R/'tests/business.json').read_text());payload['companyName']='Synthetic unified router';payload['email']=secrets.token_hex(5)+'@example.invalid'
s,b=req(P+'/api/submit-business-inquiry.php','POST',payload);check('PHP_synthetic_accept',s==201);receipt=b['confirmationId']
p=subprocess.run([os.environ.get('R4_PHP_BIN','/opt/homebrew/opt/php@8.3/bin/php'),'-n',str(R/'php/private/forms/sync.php')],capture_output=True,text=True,timeout=60);check('manual_worker_success',p.returncode==0)
user=json.loads((R/'private/users.json').read_text())['admin'];c=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()));check('admin_login',req(U+'/api/r4/login','POST',{k:user[k] for k in ['email','password']},c)[0]==200)
check('same_origin_form_reaches_Admin',any(row.get('reference_code')==receipt for row in req(U+'/api/r4/inquiries',opener=c)[1]))
for path in ['/private/env.json','/private/forms/sync-config.php','/.env','/api/r4/catalog']:
 check('web_not_exposing_private:'+path,req(P+path)[0]==404)
(R/'evidence/unified-router.json').write_text(json.dumps({'status':'PASS','checks':checks,'worker':'MANUAL_LOCAL_ONLY','hostingerCron':'NOT_TESTED'},indent=2));print('PASS',len(checks),'unified router checks')
