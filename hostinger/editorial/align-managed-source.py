"""Align hPanel's retained source with the checked Git archive after code deployment.
Preserve the existing catalog-builder and hosting-only files and retain full rollback.
"""
from pathlib import Path
import argparse,ctypes,hashlib,json,os,shutil,tarfile
os.umask(0o077)
p=argparse.ArgumentParser();p.add_argument('environment',choices=['qa','production']);a=p.parse_args()
base=Path('/home/u246392949/domains');r=base/'qa-catalog.younew.nl/younew-private/editorial-20261110'
result=json.loads((r/('node-'+a.environment+'-result.json')).read_text());assert result['status']=='PASS'
host='qa-runtime.younew.nl' if a.environment=='qa' else 'admin.younew.nl';h=base/host/'hbuilds';live=h/'last-source';candidate=h/'last-source-editorial-20261110'
assert live.is_dir() and not candidate.exists()
shutil.copytree(live,candidate,symlinks=True)
manifest=[]
with tarfile.open(r/'node-source.tar.gz') as t:
 for item in t.getmembers():
  assert not item.name.startswith('/') and '..' not in Path(item.name).parts and (item.isdir() or item.isfile())
  target=candidate/item.name
  if item.isdir():target.mkdir(exist_ok=True,parents=True);continue
  data=t.extractfile(item).read();assert not target.is_symlink();target.parent.mkdir(exist_ok=True,parents=True);target.write_bytes(data);target.chmod(item.mode)
  assert target.read_bytes()==data
  manifest.append({'path':item.name,'sha256':hashlib.sha256(data).hexdigest()})
lib=ctypes.CDLL(None,use_errno=True)
if lib.renameat2(-100,os.fsencode(live),-100,os.fsencode(candidate),2):raise OSError(ctypes.get_errno(),'Source exchange failed')
for item in manifest:assert hashlib.sha256((live/item['path']).read_bytes()).hexdigest()==item['sha256']
report={'status':'PASS','sourceCommit':result['commit'],'files':len(manifest),'environment':a.environment,'previousSourceDirectory':str(candidate),'hostingOnlyFilesPreserved':True,'runningCodeChanged':False}
(r/('managed-source-'+a.environment+'.json')).write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
