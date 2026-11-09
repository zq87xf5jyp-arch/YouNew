#!/usr/bin/env python3
from pathlib import Path
import json,urllib.request,urllib.error,http.cookiejar,secrets
R=Path(__file__).resolve().parents[1];U='http://127.0.0.1:4404';users=json.loads((R/'private/users.json').read_text());fixtures=json.loads((R/'private/fixtures.json').read_text());manifest=json.loads((R/'source/admin-dashboard/.next/server/server-reference-manifest.json').read_text());actions={v['exportedName']:k for k,v in manifest['node'].items()};checks=[]
def request(op,path,body=None,headers=None):
 q=urllib.request.Request(U+path,data=body,headers=headers or {})
 try:r=op.open(q,timeout=15)
 except urllib.error.HTTPError as e:r=e
 return r.code,r.read().decode(errors='replace')
def login(name):
 op=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()));s,b=request(op,'/api/r4/login',json.dumps({k:users[name][k] for k in ['email','password']}).encode(),{'Content-Type':'application/json','Origin':U});assert s==200,'Login failed';return op

def action(op,values,origin=U,route='/business-inquiries',name='updateBusinessInquiry'):
 boundary='r4-'+secrets.token_hex(12);parts=[]
 for k,v in [('_1_'+k,v) for k,v in values.items()]+[('0','["$K1"]')]:parts.append('--'+boundary+'\r\nContent-Disposition: form-data; name="'+k+'"\r\n\r\n'+v+'\r\n')
 body=(''.join(parts)+'--'+boundary+'--\r\n').encode();return request(op,route,body,{'Origin':origin,'Next-Action':actions[name],'Accept':'text/x-component','Content-Type':'multipart/form-data; boundary='+boundary})

def check(n,p):checks.append({'name':n,'pass':bool(p)});print(n,'PASS' if p else 'FAIL',flush=True);assert p,n

def form(row):return dict(schema='pipeline-v2',id=row['id'],updated_at=row['updated_at'],status='qualified',internalNote='Synthetic real Server Action proof',contactRole='',offerInterest='not_specified',lostReason='',lostReasonDetail='',wonEvidenceType='',wonEvidenceDate='')
try:
 owner=login('owner');viewer=login('viewer');other=login('other');anon=urllib.request.build_opener();row=json.loads(request(owner,'/api/r4/inquiries/'+fixtures['owner'])[1]);brow=json.loads(request(other,'/api/r4/inquiries/'+fixtures['other'])[1]);values=form(row)
 s,b=action(anon,values);check('action_anonymous',('authentication_required' in b or s==401) and '"ok":true' not in b)
 s,b=action(viewer,values);check('action_viewer',('forbidden' in b or s==403) and '"ok":true' not in b)
 s,b=action(owner,form(brow));check('action_cross_object','not_found' in b and '"ok":true' not in b)
 s,b=action(owner,{**values,'handled_by':users['other']['id']});check('action_actor_spoof','invalid_update' in b and '"ok":true' not in b)
 s,b=action(owner,{**values,'role':'owner'});check('action_role_spoof','invalid_update' in b and '"ok":true' not in b)
 s,b=action(owner,values,origin='https://evil.invalid');check('action_wrong_origin',s in [400,403,500] and '"ok":true' not in b)
 s,b=action(viewer,values,route='/login');check('action_alternative_route_denied','"ok":true' not in b)
 s,b=action(owner,values);check('action_legitimate_mutation','"ok":true' in b)
 after=json.loads(request(owner,'/api/r4/inquiries/'+fixtures['owner'])[1]);check('action_saved_to_database',after['admin_notes']==values['internalNote'] and after['handled_by']==users['owner']['id'])
 s,b=action(owner,values);check('action_stale_version','stale_version' in b and '"ok":true' not in b)
 result={'status':'PASS','transport':'Real Next Server Actions multipart POST; production build','checks':checks}
except Exception as e:result={'status':'FAIL','checks':checks,'failure':str(e)};raise
finally:(R/'evidence/server-actions-http.json').write_text(json.dumps(result,indent=2))
