import urllib.request,urllib.error,json,hashlib,datetime,gzip,re
from pathlib import Path
rows=[]
def req(url,method='GET',data=None,headers={}):
 try:r=urllib.request.urlopen(urllib.request.Request(url,method=method,data=data,headers=headers),timeout=15)
 except urllib.error.HTTPError as e:r=e
 b=r.read(); h=dict(r.headers);return r.status,b,h
try:
 for p in ['/','/nl/','/start/','/guides/','/city-guides/amsterdam/','/for-business/','/search/','/map/','/municipalities/leiden/','/privacy/','/terms/','/status/','/robots.txt','/sitemap.xml','/.well-known/mta-sts.txt','/.well-known/apple-app-site-association']:
  s,b,h=req('https://younew.nl'+p,headers={'Accept-Encoding':'gzip'})
  if h.get('Content-Encoding')=='gzip':b=gzip.decompress(b)
  assert s==200,(p,s)
  rows.append({'path':p,'status':s,'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'cache':h.get('Cache-Control'),'encoding':h.get('Content-Encoding'),'server':h.get('Server'),'hsts':bool(h.get('Strict-Transport-Security'))})
  if p=='/':
   assert b'https://younew.nl/' in b and b'hreflang="nl"' in b.lower()
   assets=re.findall(rb'(?:src|href)="([^"<>]+\.(?:js|css))"',b)
 for asset in assets[:3]:
  p=asset.decode();s,b,h=req('https://younew.nl'+p,headers={'Accept-Encoding':'gzip'});assert s==200
  rows.append({'path':p,'status':s,'cache':h.get('Cache-Control'),'encoding':h.get('Content-Encoding')})
 for endpoint in ['submit-business-inquiry.php','submit-public-feedback.php']:
  s,b,h=req('https://younew.nl/api/'+endpoint,'POST',b'{}',{'Content-Type':'application/json','Origin':'https://younew.nl'});assert s==400 and json.loads(b)['error']=='validation_failed' and 'no-store' in h.get('Cache-Control','')
  rows.append({'path':'/api/'+endpoint,'status':s,'invalidPayloadRejected':True,'noStore':True})
 s,b,h=req('https://admin.younew.nl/api/r4/login','POST',b'{}',{'Content-Type':'application/json','Origin':'https://admin.younew.nl'});assert s==401 and json.loads(b)['error']=='invalid_credentials' and 'no-store' in h.get('Cache-Control','')
 rows.append({'path':'Admin malformed login','status':s,'cache':h.get('Cache-Control')})
 report={'status':'PASS','at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':rows,'fakeProductionRecordsCreated':False}
except Exception as error:report={'status':'FAIL','errorType':type(error).__name__,'error':str(error),'checks':rows}
p=Path('/Users/ivan/YouNew-Launch-Evidence-2026-11-10/production-http-checks.json');p.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
