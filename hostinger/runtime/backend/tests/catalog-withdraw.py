from pathlib import Path
import json,urllib.request,urllib.error,http.cookiejar,subprocess,getpass
R=Path(__file__).resolve().parents[1];U='http://127.0.0.1:4404';users=json.loads((R/'private/users.json').read_text());checks=[]
c=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
def req(path,method='GET',body=None):
 q=urllib.request.Request(U+'/api/r4/'+path,method=method,headers={'Authorization':'Bearer '+json.loads((R/'private/env.json').read_text())['R4_CATALOG_BUILD_KEY'],'Origin':U,'Content-Type':'application/json'},data=None if body is None else json.dumps(body).encode())
 try:r=c.open(q)
 except urllib.error.HTTPError as e:r=e
 return r.status,json.loads(r.read())
def check(n,condition):assert condition,n;checks.append({'name':n,'pass':True})
check('admin_login',req('login','POST',{k:users['admin'][k] for k in ['email','password']})[0]==200)
row=next(r for r in req('catalog')[1] if r['document']['title']=='[SYNTHETIC] Integration hotel');p='catalog/'+row['id']
s,edited=req(p,'PATCH',{'revision':row['revision'],'summary':row['document']['summary']});check('approved_edit_resets_draft',s==200 and edited['state']=='draft')
check('withdrawal_immediate_public_API',not any(e['id']==row['publicId'] for e in req('editorial/approved')[1]['entities']))
check('repeat_review',req(p+'/transition','POST',{'action':'submit','revision':edited['revision']})[0]==200)
check('repeat_authorized_approval',req(p+'/transition','POST',{'action':'approve','revision':edited['revision']})[0]==200)
rt=json.loads((R/'private/runtime.json').read_text())
def sql(value):
 q="UPDATE profiles SET is_blocked="+str(value)+" WHERE id='"+users['admin']['id']+"';"
 r=subprocess.run([rt['prefix']+'/bin/mariadb','--no-defaults','--socket='+rt['socket'],'--user='+getpass.getuser(),'r4_candidate'],input=q,text=True,capture_output=True);assert r.returncode==0
sql(1)
try:check('approval_revalidated_on_public_read',req('editorial/approved')[1]['entities']==[])
finally:sql(0)
check('14_originals_still_draft',sum(r['state']=='draft' and not r['synthetic'] for r in req('catalog')[1])==14)
(R/'evidence/catalog-withdraw.json').write_text(json.dumps({'status':'PASS','checks':checks,'static_semantics':'Public API updates immediately; static snapshot requires explicit rebuild, never a claimed automatic deployment.'},indent=2));print('PASS',len(checks),'withdrawal checks')
