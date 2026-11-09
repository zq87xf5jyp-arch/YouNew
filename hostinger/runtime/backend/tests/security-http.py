#!/usr/bin/env python3
from pathlib import Path
import urllib.request,urllib.error,json,http.cookiejar,hashlib,subprocess,getpass,base64,time,concurrent.futures
R=Path(__file__).resolve().parents[1]; URL='http://127.0.0.1:4404';users=json.loads((R/'private/users.json').read_text());fixtures=json.loads((R/'private/fixtures.json').read_text());runtime=json.loads((R/'private/runtime.json').read_text());env=json.loads((R/'private/env.json').read_text());checks=[];responses=[]
def sql(s):
 p=subprocess.run([runtime['prefix']+'/bin/mariadb','--no-defaults','--protocol=socket','--socket='+runtime['socket'],'--user='+getpass.getuser(),'--batch','--skip-column-names','r4_candidate'],input=s,text=True,capture_output=True);assert not p.returncode,'Fixture SQL failed';return p.stdout.strip()
def client():return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
def req(c,path,method='GET',data=None,origin=URL,headers=None):
 h={'Origin':origin};h.update(headers or {})
 if data is not None:h['Content-Type']='application/json'
 request=urllib.request.Request(URL+path,data=None if data is None else json.dumps(data).encode(),headers=h,method=method)
 try:r=c.open(request,timeout=15)
 except urllib.error.HTTPError as e:r=e
 text=r.read().decode(errors='replace');responses.append(text+'\n'+str(r.headers));
 try:body=json.loads(text)
 except:body=text
 return r.code,body,r.headers

def check(name,ok,detail=''):
 checks.append({'name':name,'pass':bool(ok),'detail':detail});print(name,'PASS' if ok else 'FAIL',flush=True)
 (R/'evidence/security-http.json').write_text(json.dumps({'status':'IN_PROGRESS','checks':checks},indent=2))
 if not ok:raise AssertionError(name)
def auth(name):
 c=client();s,b,h=req(c,'/api/r4/login','POST',{k:users[name][k] for k in ['email','password']});return c,s,b

def update(row,**extra):return dict(schema='pipeline-v2',id=row['id'],updated_at=row['updated_at'],status='qualified',internalNote='Synthetic R4 processing proof',contactRole='',offerInterest='not_specified',lostReason='',lostReasonDetail='',wonEvidenceType='',wonEvidenceDate='',**extra)
try:
 anon=client()
 for path in ['/api/r4/me','/api/r4/inquiries','/api/r4/notifications','/api/r4/audit','/business-inquiries/export','/api/r4/files/'+fixtures['owner']]:check('anonymous:'+path,req(anon,path)[0]==401)
 check('forged_bearer_denied',req(anon,'/api/r4/inquiries',headers={'Authorization':'Bearer owner','X-Role':'owner','X-User-Id':users['owner']['id']})[0]==401)
 check('forged_cookie_denied',req(anon,'/api/r4/inquiries',headers={'Cookie':'younew_hostprep_session='+'f'*64})[0]==401)
 for n in ['pending','blocked']:check(n+'_login',auth(n)[1]==403)
 clients={}
 for n in ['owner','admin','editor','qa','viewer','other']:
  c,s,b=auth(n);check(n+'_login',s==200);clients[n]=c
  check(n+'_identity',req(c,'/api/r4/me')[1]['id']==users[n]['id'])
  check(n+'_CRM_policy',req(c,'/api/r4/inquiries')[0]==(200 if n in ['owner','admin','other'] else 403))
 owner=clients['owner'];s,row,_=req(owner,'/api/r4/inquiries/'+fixtures['owner']);check('owner_read_own_object',s==200)
 for n in ['viewer','editor','qa']:check(n+'_write_denied',req(clients[n],'/api/r4/inquiries/'+fixtures['owner'],'PATCH',update(row))[0]==403)
 check('A_reads_B_denied',req(owner,'/api/r4/inquiries/'+fixtures['other'])[0]==404)
 otherrow=req(clients['other'],'/api/r4/inquiries/'+fixtures['other'])[1]
 check('A_updates_B_denied',req(owner,'/api/r4/inquiries/'+fixtures['other'],'PATCH',update(otherrow))[0]==404)
 check('B_list_scoped',all(x['id']!=fixtures['owner'] for x in req(clients['other'],'/api/r4/inquiries?workspace_id='+users['owner']['workspace'])[1]))
 for field in ['role','workspace_id','owner_id','handled_by']:
  check('spoof_'+field,req(owner,'/api/r4/inquiries/'+row['id'],'PATCH',update(row,**{field:users['other']['id']}))[0]==400)
 check('csrf_origin_denied',req(owner,'/api/r4/inquiries/'+row['id'],'PATCH',update(row),origin='https://evil.invalid')[0]==403)
 check('sql_injection_id_denied',req(owner,"/api/r4/inquiries/%27%20OR%201%3D1--")[0]==404)
 for path in ['/api/public/articles','/api/workspace/status','/api/mobile/sync','/rest/v1/business_inquiries','/api/r4/sql','/api/r4/profiles']:
  s,b,h=req(owner,path,method='POST',data={'query':'SELECT * FROM profiles','role':'owner'});check('alternate_closed:'+path,s in [400,403,404,405])
 # Existing sessions must consult current account state at each request.
 for column in ['is_approved','is_blocked']:
  sql("UPDATE profiles SET "+column+'='+('0' if column=='is_approved' else '1')+" WHERE id='"+users['admin']['id']+"';")
  check('existing_session_'+column,req(clients['admin'],'/api/r4/me')[0]==403)
  sql("UPDATE profiles SET "+column+'='+('1' if column=='is_approved' else '0')+" WHERE id='"+users['admin']['id']+"';")
 sql("UPDATE sessions SET expires_at=DATE_SUB(UTC_TIMESTAMP(3),INTERVAL 1 SECOND) WHERE profile_id='"+users['admin']['id']+"';")
 check('expired_session',req(clients['admin'],'/api/r4/inquiries')[0]==401)
 sql("UPDATE sessions SET revoked_at=UTC_TIMESTAMP(3) WHERE profile_id='"+users['other']['id']+"';")
 check('revoked_session',req(clients['other'],'/api/r4/inquiries')[0]==401)
 # Private file requests and object scope use the same actor checks.
 s,f,_=req(owner,'/api/r4/files','POST',{'inquiryId':row['id'],'data':base64.b64encode(b'SYNTHETIC PRIVATE R4 FILE').decode()});check('file_upload_owner',s==200)
 check('file_download_owner',req(owner,'/api/r4/files/'+f['id'])[1]=='SYNTHETIC PRIVATE R4 FILE')
 check('file_viewer_denied',req(clients['viewer'],'/api/r4/files/'+f['id'])[0]==403)
 other,s,_=auth('other');check('file_other_scope_denied',req(other,'/api/r4/files/'+f['id'])[0]==404)
 check('file_attach_B_denied',req(owner,'/api/r4/files','POST',{'inquiryId':fixtures['other'],'data':'QQ=='})[0]==404)
 check('file_owner_spoof_denied',req(owner,'/api/r4/files','POST',{'inquiryId':row['id'],'data':'QQ==','owner_id':users['other']['id']})[0]==400)
 # No credential appears in serialized responses or browser chunks.
 secrets=[env[k] for k in ['R4_DB_PASSWORD','R4_INGEST_KEY','R4_FILES_KEY']]
 check('response_secrets_absent',all(secret not in '\n'.join(responses) for secret in secrets))
 leak=[]
 for fpath in (R/'source/admin-dashboard/.next/static').rglob('*'):
  if fpath.is_file():
   b=fpath.read_bytes()
   if any(s.encode() in b for s in secrets):leak.append(str(fpath.relative_to(R)))
 check('client_bundle_secrets_absent',not leak)
 check('logout_revokes',req(owner,'/api/r4/logout','POST',{})[0]==200 and req(owner,'/api/r4/me')[0]==401)
 result={'status':'PASS','checks':checks,'scope':'Real Next.js HTTP routes, live MariaDB and PHP private storage; no ingest executed at this stage','finished':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime())}
except Exception as e:result={'status':'FAIL','checks':checks,'failure':str(e)};raise
finally:(R/'evidence/security-http.json').write_text(json.dumps(result,indent=2))
