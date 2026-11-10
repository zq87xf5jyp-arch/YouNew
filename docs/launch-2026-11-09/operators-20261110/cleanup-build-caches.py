from pathlib import Path
import os,json,subprocess,shutil,hashlib,datetime
os.umask(0o077)
p=Path('/home/u246392949/domains/younew.nl/younew-private/launch-production')
e=p/'cleanup-20261110';e.mkdir(mode=0o700,exist_ok=True)
assert not (e/'result.json').exists(),'cleanup already recorded'
result={'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'deleted':[],'preserved':[],'realDataDeleted':False}
for name,head in [('public-build-cf6ab6f','cf6ab6f74f65a4c9c45c62c5c209090ab8960665'),('public-build-5e0b3e1','5e0b3e152c7619f967fc7b518854bd6d8c9cb374')]:
 b=p/name
 def git(*args):return subprocess.check_output(['git','-C',str(b),*args])
 assert git('rev-parse','HEAD').decode().strip()==head
 assert git('ls-files','--others','--exclude-standard')==b''
 patch=git('diff','--binary');(e/(name+'.patch')).write_bytes(patch)
 for proc in Path('/proc').iterdir():
  if not proc.name.isdigit():continue
  try:cwd=(proc/'cwd').resolve(strict=True)
  except (OSError,RuntimeError):continue
  assert not cwd.is_relative_to(b),'active process in build tree'
 for relative in ['admin-dashboard/public-site/node_modules','admin-dashboard/public-site/.next','admin-dashboard/public-site/tsconfig.tsbuildinfo','scripts/__pycache__']:
  target=b/relative
  if not target.exists():continue
  assert not target.is_symlink() and target.resolve().is_relative_to(b)
  assert git('ls-files',relative)==b''
  size=int(subprocess.check_output(['du','-sk',str(target)],text=True).split()[0])*1024
  result['deleted'].append({'path':str(target),'bytesAllocated':size,'reason':'reproducible dependency/build cache; tracked source and lockfile preserved','recoveryCommit':head})
  if target.is_dir():shutil.rmtree(target)
  else:target.unlink()
 result['preserved'].append({'build':str(b),'sourceCommit':head,'diffSha256':hashlib.sha256(patch).hexdigest(),'outAndReportsPreserved':True})
result['reclaimedAllocatedBytes']=sum(x['bytesAllocated'] for x in result['deleted'])
(e/'result.json').write_text(json.dumps(result,indent=2))
print(chr(27)+'[2J'+chr(27)+'[H'+json.dumps(result))
