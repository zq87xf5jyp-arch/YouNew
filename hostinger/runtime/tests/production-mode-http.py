"""Credential values stay private; output contains only check names and booleans."""
import json,urllib.request,urllib.error,http.cookiejar,datetime,hashlib
from pathlib import Path
import argparse
parser=argparse.ArgumentParser(description='Synthetic loopback acceptance; no production credential use')
parser.add_argument('--fixtures',type=Path,required=True)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args()
users=json.loads(args.fixtures.read_text())
assert all(u['email'].endswith('@example.invalid') for u in users['users'].values());base='http://127.0.0.1:4404';checks=[]
def check(name,passed):
 checks.append({'name':name,'pass':bool(passed)})
 if not passed: raise AssertionError(name)
def client(): return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
def req(c,path,data=None,method=None):
 q=urllib.request.Request(base+path,headers={'Origin':base,'Content-Type':'application/json'},data=None if data is None else json.dumps(data).encode(),method=method)
 try:r=c.open(q,timeout=15)
 except urllib.error.HTTPError as e:r=e
 return r.status,r.read(),r.headers
asset='/api/r4/history-files/11111111-1111-4111-8111-111111111111'
try:
 anon=client();check('anonymous asset denied',req(anon,asset)[0]==401)
 for name,u in users['users'].items():
  c=client();check(name+' login',req(c,'/api/r4/login',{k:u[k] for k in ['email','password']})[0]==200)
  status,body,headers=req(c,'/history');check(name+' history role',status==(404 if name=='viewer' else 200));check(name+' history no-store','no-store' in headers.get('Cache-Control',''))
  if name=='owner':
   check('owner retained history',b'feedback' in body);check('invalid page rejected',req(c,'/history?table=public.feedback&page=-1')[0]==404)
   s,b,h=req(c,'/history?table=public.feedback');check('retained row render',s==200 and b'Saved feedback example' in b)
  if name=='other':check('workspace history isolated',b'feedback (1)' not in body and b'Saved feedback example' not in body and b'11111111-1111-4111-8111-111111111111' not in body)
  s,b,h=req(c,asset);check(name+' file access',s=={'owner':200,'viewer':403,'other':404}[name])
  if name=='owner':check('file byte identity',b==b'Synthetic preserved asset');check('file private download','attachment' in h.get('Content-Disposition','') and 'no-store' in h.get('Cache-Control',''))
  s,b,h=req(c,'/api/r4/inquiries');check(name+' crm access',s==(403 if name=='viewer' else 200))
  if name=='owner':check('original status retained',json.loads(b)[0]['legacy_status']=='test');check('legacy archived',json.loads(b)[0]['status']=='archived')
  if name=='other':check('workspace crm isolated',json.loads(b)==[])
  check(name+' audit page',req(c,'/audit-log')[0]==(404 if name=='viewer' else 200))
  check(name+' unsupported route absent',req(c,'/settings')[0]==404)
  check(name+' crm page',req(c,'/business-inquiries')[0]==(404 if name=='viewer' else 200))
  if name=='owner':
   s,b,h=req(c,'/api/r4/catalog');items=json.loads(b);check('71 real drafts read-only',s==200 and len(items)==71 and all(x['state']=='draft' and not x['synthetic'] for x in items))
   s,b,h=req(c,'/api/r4/catalog/11111111-1111-4111-8111-111111111111/transition',{'action':'approve','revision':1});check('publication denied',s==403 and json.loads(b)['error']=='publication_batch_review_required')
  check(name+' logout',req(c,'/api/r4/logout',{})[0]==200);check(name+' revoked',req(c,'/api/r4/me')[0]==401)
 report={'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'status':'PASS','checks':checks,'scope':'Synthetic local production-mode Admin, not Hostinger or real credentials'}
 args.output.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'status':'PASS','checks':len(checks)}))
except Exception:
 args.output.write_text(json.dumps({'status':'FAIL','checks':checks},indent=2));raise
