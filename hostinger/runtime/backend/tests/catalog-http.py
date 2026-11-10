#!/usr/bin/env python3
from pathlib import Path
import json,uuid,urllib.request,urllib.error,http.cookiejar,concurrent.futures,subprocess,getpass,hashlib
R=Path(__file__).resolve().parents[1];URL='http://127.0.0.1:4404';users=json.loads((R/'private/users.json').read_text());runtime=json.loads((R/'private/runtime.json').read_text());checks=[];responses=[]
def sql(s):
 p=subprocess.run([runtime['prefix']+'/bin/mariadb','--no-defaults','--protocol=socket','--socket='+runtime['socket'],'--user='+getpass.getuser(),'--batch','--skip-column-names','r4_candidate'],input=s,text=True,capture_output=True);assert p.returncode==0,'Isolated fixture SQL failed';return p.stdout.strip()
def client():return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
def req(c,path,method='GET',data=None,origin=URL):
 h={'Authorization':'Bearer '+json.loads((R/'private/env.json').read_text())['R4_CATALOG_BUILD_KEY'],'Origin':origin,'Content-Type':'application/json'};q=urllib.request.Request(URL+'/api/r4/'+path,method=method,headers=h,data=json.dumps(data).encode() if data is not None else None)
 try:r=c.open(q,timeout=20)
 except urllib.error.HTTPError as e:r=e
 raw=r.read().decode();responses.append(raw)
 try:b=json.loads(raw)
 except:b=raw
 return r.code,b
def check(name,ok):
 checks.append({'name':name,'pass':bool(ok)});(R/'evidence/catalog-http.json').write_text(json.dumps({'status':'IN_PROGRESS','checks':checks},indent=2));print(name,'PASS' if ok else 'FAIL',flush=True)
 if not ok:raise AssertionError(name)
def login(n):
 c=client();s,b=req(c,'login','POST',{k:users[n][k] for k in ['email','password']});check('login_'+n,s==200);return c
anon=client();check('anonymous_read',req(anon,'catalog')[0]==401)
clients={n:login(n) for n in ['editor','owner','admin','viewer','qa','other']};ed=clients['editor'];admin=clients['admin']
original=req(ed,'catalog')[1];check('71_canonical_drafts',len(original)==71 and all(r['state']=='draft' and not r['synthetic'] for r in original))
seed=json.loads((R/'db/catalog-drafts.json').read_text())['entities']
check('IDs_contacts_coordinates_preserved',all(next(r['document'] for r in original if r['publicId']==d['id'])['attributes']==d['attributes'] and next(r['document'] for r in original if r['publicId']==d['id'])['coordinate']==d['coordinate'] for d in seed))
check('public_empty_before_approval',req(anon,'editorial/approved')[1]['entities']==[])
field=lambda s:{'value':s,'sourceUrl':'https://example.invalid/catalog','checkedAt':'2026-11-03'}
place={'title':'[SYNTHETIC] Integration hotel','summary':'Local fixture for editorial acceptance only.','kind':'hotel','category':'hotel','cityId':'utrecht','coordinate':None,'address':field('Synthetic avenue 1'),'website':field('https://hotel.example.invalid/'),'email':field('desk@example.invalid'),'phone':field('+31 20 0000000')}
body={'requestKey':str(uuid.uuid4()),'place':place}
for n in ['viewer','qa']:check(n+'_create_denied',req(clients[n],'catalog','POST',body)[0]==403)
check('anonymous_create',req(anon,'catalog','POST',body)[0]==401)
check('csrf_denied',req(ed,'catalog','POST',body,origin='https://evil.invalid')[0]==403)
check('role_owner_spoof',req(ed,'catalog','POST',{**body,'role':'owner','workspace_id':users['other']['workspace']})[0]==400)
s,row=req(ed,'catalog','POST',body);check('create_draft',s==200 and row['state']=='draft');key=row['id'];path='catalog/'+key
check('idempotent_create',req(ed,'catalog','POST',body)[1]['id']==key)
check('idempotency_conflict',req(ed,'catalog','POST',{**body,'place':{**place,'summary':'Changed request body'}})[0]==409)
for change in [{},{'title':'[SYNTHETIC] Another name'},{'title':'[SYNTHETIC] Other','address':field('Different synthetic address')}]:
 check('duplicate_'+str(len(checks)),req(ed,'catalog','POST',{'requestKey':str(uuid.uuid4()),'place':{**place,**change}})[0]==409)
check('cross_workspace_read',req(clients['other'],path)[0]==404)
check('cross_workspace_update',req(clients['other'],path,'PATCH',{'revision':1,'summary':'No'})[0]==404)
check('viewer_write',req(clients['viewer'],path,'PATCH',{'revision':1,'summary':'No'})[0]==403)
check('owner_spoof_edit',req(ed,path,'PATCH',{'revision':1,'created_by':users['owner']['id']})[0]==400)
check('javascript_url_rejected',req(ed,path,'PATCH',{'revision':1,'website':field('javascript:alert(1)')})[0]==400)
check('email_injection_rejected',req(ed,path,'PATCH',{'revision':1,'email':field('a@example.invalid\nBcc:x@example.invalid')})[0]==400)
check('coordinate_invalid_rejected',req(ed,path,'PATCH',{'revision':1,'coordinate':{'latitude':0,'longitude':0,'sourceUrl':'https://example.invalid','checkedAt':'2026-11-03'}})[0]==400)
s,row=req(ed,path,'PATCH',{'revision':1,'summary':'Edited synthetic hotel, no licensed photo and no verified map location.'});check('edit_save',s==200 and row['revision']==2)
check('preview_authenticated',req(ed,path)[1]['document']['summary'].startswith('Edited'))
check('draft_hidden_after_edit',req(anon,'editorial/approved')[1]['entities']==[])
check('stale_edit',req(ed,path,'PATCH',{'revision':1,'summary':'Stale'})[0]==409)
with concurrent.futures.ThreadPoolExecutor(2) as pool: result=list(pool.map(lambda _:req(ed,path,'PATCH',{'revision':2,'summary':'Concurrent synthetic revision.'})[0],range(2)))
check('concurrent_CAS',sorted(result)==[200,409]);row=req(ed,path)[1];revision=row['revision']
# Force an audit write failure using the isolated operator; runtime never gains DDL/GRANT authority.
sql("REVOKE INSERT ON r4_candidate.audit_events FROM 'r4_backend'@'localhost';")
try:check('transaction_failure',req(ed,path,'PATCH',{'revision':revision,'summary':'Must roll back'})[0]==503)
finally:sql("GRANT INSERT ON r4_candidate.audit_events TO 'r4_backend'@'localhost';")
check('transaction_rollback',req(ed,path)[1]['revision']==revision and req(ed,path)[1]['document']['summary']!='Must roll back')
s,row=req(ed,path,'PATCH',{'revision':revision,'summary':'Retry succeeded. Synthetic hotel for local testing.'});check('safe_retry',s==200);revision=row['revision']
check('editor_cannot_approve',req(ed,path+'/transition','POST',{'action':'approve','revision':revision})[0]==403)
check('cannot_skip_review',req(admin,path+'/transition','POST',{'action':'approve','revision':revision})[0]==409)
check('submit_review',req(ed,path+'/transition','POST',{'action':'submit','revision':revision})[1]['state']=='review')
check('review_not_public',req(anon,'editorial/approved')[1]['entities']==[])
check('canonical_real_edit_locked',req(admin,'catalog/'+original[0]['id'],'PATCH',{'revision':1,'summary':'Attempt to fork canonical data'})[0]==403)
check('real_publish_locked',req(admin,'catalog/'+original[0]['id']+'/transition','POST',{'action':'approve','revision':1})[0]==403)
with concurrent.futures.ThreadPoolExecutor(2) as pool: result=list(pool.map(lambda _:req(admin,path+'/transition','POST',{'action':'approve','revision':revision})[0],range(2)))
check('concurrent_approve_once',sorted(result)==[200,409])
public=req(anon,'editorial/approved')[1]['entities'];check('only_approved_synthetic_public',len(public)==1 and public[0]['id']==row['publicId'])
check('contacts_hotel_no_marker_no_photo',public[0]['kind']=='hotel' and public[0]['coordinate'] is None and public[0]['images']==[] and public[0]['attributes']['contact_email']=='desk@example.invalid')
check('editor_cannot_edit_published',req(ed,path,'PATCH',{'revision':revision,'summary':'Change published'})[0]==403)
# Current account state and session state are checked on each read/write.
for column,value in [('is_approved',0),('is_blocked',1)]:
 sql("UPDATE profiles SET "+column+'='+str(value)+" WHERE id='"+users['qa']['id']+"';")
 try:check('existing_session_'+column,req(clients['qa'],'catalog')[0]==403)
 finally:sql("UPDATE profiles SET "+column+'='+str(1-value)+" WHERE id='"+users['qa']['id']+"';")
sql("UPDATE sessions SET expires_at=DATE_SUB(UTC_TIMESTAMP(3),INTERVAL 1 SECOND) WHERE profile_id='"+users['viewer']['id']+"';");check('expired_session',req(clients['viewer'],'catalog')[0]==401)
req(clients['other'],'logout','POST',{});check('revoked_session',req(clients['other'],'catalog')[0]==401)
for alt in ['catalog/'+key+'/approve','content/'+key,'sql']:
 check('alternate_closed_'+alt,req(ed,alt,'POST',{'role':'owner'})[0]==404)
check('71_real_still_draft',all(r['state']=='draft' for r in req(ed,'catalog')[1] if not r['synthetic']))
check('no_SQL_secrets_in_responses',all(v not in '\n'.join(responses) for k,v in json.loads((R/'private/env.json').read_text()).items() if any(x in k for x in ['PASSWORD','KEY'])))
(R/'evidence/catalog-fixture.json').write_text(json.dumps({'id':key,'publicId':row['publicId'],'revision':revision},indent=2))
(R/'evidence/catalog-http.json').write_text(json.dumps({'status':'PASS','checks':checks},indent=2));print('PASS',len(checks),'catalog HTTP checks')
