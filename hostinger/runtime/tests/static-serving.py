from pathlib import Path
import json,urllib.request,urllib.error
R=Path(__file__).resolve().parents[1];m=json.loads((R/'publication/current.json').read_text());out=R/'publication/releases'/m['releaseId']/'out';checks=[]
def check(n,v):checks.append({'name':n,'status':'PASS' if v else 'FAIL'});assert v,n
def req(path,method='GET',headers={}):
 try:r=urllib.request.urlopen(urllib.request.Request('http://127.0.0.1:4358'+path,method=method,headers=headers))
 except urllib.error.HTTPError as e:r=e
 return r.status,dict(r.headers),r.read()
for ext,mime in [('.mp4','video/mp4'),('.pdf','application/pdf')]:
 p=next(out.rglob('*'+ext));route='/'+str(p.relative_to(out));s,h,b=req(route,'HEAD');check(ext+'_head',s==200 and h['Content-Type']==mime and int(h['Content-Length'])==p.stat().st_size)
 s,h,b=req(route,headers={'Range':'bytes=0-63'});check(ext+'_range',s==206 and b==p.read_bytes()[:64] and h['Content-Range'].startswith('bytes 0-63/'))
 s,h,b=req(route,headers={'Range':'bytes=999999999-'});check(ext+'_bad_range',s==416)
check('association_readable_without_Apple_change',req('/.well-known/apple-app-site-association')[0]==200)
for path in ['/.env','/.htaccess','/publication/current.json','/backend/private/env.json','/../backend/private/env.json']:
 check('private_denied:'+path,req(path)[0]==404)
check('business_page_preserved',req('/for-business/')[0]==200)
check('local_frontcontroller_still_serves_catalog',req('/map/')[0]==200 and req('/data/search-index.json')[0]==200)
(R.parent/'evidence/static-serving.json').write_text(json.dumps({'status':'PASS','checks':checks},indent=2));print('PASS',len(checks))
