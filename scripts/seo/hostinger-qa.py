#!/usr/bin/env python3
"""Install ONLY the private SEO review artifact in existing authenticated Hostinger QA."""
import argparse,base64,hashlib,json,os,tarfile,urllib.request,urllib.error
from pathlib import Path
os.umask(0o077)
BASE=Path('/home/u246392949/domains/qa-catalog.younew.nl/younew-private')
ROOT=BASE/'seo-20261111-r4'; STORE=BASE/'hp1/publication'; POINTER=STORE/'current.json'
RELEASE='hp-seo-review-20261111-r4'; ORIGIN='https://qa-catalog.younew.nl'
def sha(data):return hashlib.sha256(data).hexdigest()
def save(path,value):path.write_text(json.dumps(value,indent=2)+'\n');path.chmod(0o600)
def get(path,authenticated=True):
 headers={'Cache-Control':'no-cache'}
 if authenticated:
  auth=json.loads((BASE/'hp1/qa-http.private.json').read_text())
  headers['Authorization']='Basic '+base64.b64encode((auth['user']+':'+auth['password']).encode()).decode()
 try:r=urllib.request.urlopen(urllib.request.Request(ORIGIN+path,headers=headers),timeout=30)
 except urllib.error.HTTPError as e:r=e
 return r.status,r.read(),r.headers

def main():
 a=argparse.ArgumentParser();a.add_argument('action',choices=['install','rollback']);a.add_argument('--sha256');args=a.parse_args();ROOT.mkdir(exist_ok=True)
 backup=ROOT/'qa-pointer-before.json'
 def point(data):
  temp=ROOT/'pointer.tmp';temp.write_bytes(data);temp.chmod(0o600);os.replace(temp,POINTER)
 if args.action=='rollback':
  assert backup.exists();point(backup.read_bytes());save(ROOT/'rollback.json',{'status':'RESTORED','release':json.loads(backup.read_text())});print('QA rollback complete');return
 archive=ROOT/'review.tar.gz';assert args.sha256 and sha(archive.read_bytes())==args.sha256
 target=STORE/'releases'/RELEASE;assert not target.exists(),'Refusing to replace an existing QA release'
 before=POINTER.read_bytes();assert not backup.exists(),'Backup already exists; inspect rather than overwrite'
 backup.write_bytes(before);backup.chmod(0o600)
 prior=get('/');assert prior[0]==200
 target.mkdir()
 with tarfile.open(archive) as t:
  for m in t.getmembers():assert (m.name=='out' or m.name.startswith('out/')) and '..' not in Path(m.name).parts and (m.isfile() or m.isdir())
  t.extractall(target)
 out=target/'out';assert (out/'PRIVATE_REVIEW_ONLY').is_file()
 expected=json.loads((ROOT/'files.json').read_text())
 for name,digest in expected.items():assert sha((out/name).read_bytes())==digest,name
 candidate=(json.dumps({'releaseId':RELEASE})+'\n').encode()
 checks=[]
 try:
  point(candidate)
  for path in ['/review/guides/']+json.loads((ROOT/'routes.json').read_text())+['/leiden/','/nl/leiden/']:
   code,body,h=get(path);assert code==200 and sha(body)==sha((out/path.lstrip('/')/'index.html').read_bytes()),(path,code)
   assert 'noindex' in h.get('X-Robots-Tag','') and 'no-store' in h.get('Cache-Control',''),path
   checks.append({'path':path,'status':code,'exact':True,'noindex':True,'noStore':True})
  assert get('/review/guides/',False)[0]==401
  point(before);restored=get('/');assert restored[0]==prior[0] and sha(restored[1])==sha(prior[1])
  point(candidate);assert get('/review/guides/')[0]==200
  save(ROOT/'result.json',{'status':'PASS','artifactSha256':args.sha256,'anonymousDenied':True,'rollbackRehearsed':True,'productionChanged':False,'checks':checks})
  print(json.dumps({'status':'PASS','checks':len(checks),'anonymousDenied':True,'rollbackRehearsed':True}))
 except:
  point(before);raise
if __name__=='__main__':main()
