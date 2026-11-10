#!/usr/bin/env python3
"""Package the local candidate only. Never deploys, changes a DB, or exports credentials."""
from pathlib import Path
import hashlib,json,difflib,tarfile,datetime,os
R=Path(__file__).resolve().parents[1]
BASES={'source':Path('/Users/ivan/YouNew-Catalog-R2-2026-11-03/source'),
       'backend':Path('/Users/ivan/YouNew-Catalog-R2-2026-11-03/backend-r4b-reference')}
OMIT_DIRS={'node_modules','.next','.git','dist','xcuserdata','__pycache__','.cache'}
HISTORY={'release-artifacts','BuildWeekFinal','BuildWeekVideo','QA_Baseline_Screenshots','Runtime_Screenshots','IA_Audit_Screenshots'}
def allowed(p,top,output=True):
    rel=p.as_posix();parts=p.parts
    if top=='evidence' and rel=='packaging-command.log':return False
    if any(x in OMIT_DIRS for x in parts):return False
    if not output and 'out' in parts:return False
    if top=='source' and parts and parts[0] in HISTORY:return False
    if top=='backend' and (rel.startswith('private/') or rel.startswith('php/private/forms-data/') or rel.startswith('php/private/files-data/') or rel.startswith('php/private/files/')):return False
    if top=='backend' and rel in ('php/private/forms/sync-config.php','php/private/forms/sync.lock'):return False
    if p.name.startswith('.env') and not p.name.endswith(('.example','.sample','.template')):return False
    if p.name in ('.DS_Store','tsconfig.tsbuildinfo') or p.suffix in ('.pyc','.sqlite','.db','.pem','.key','.p12','.mobileprovision','.zip','.gz'):return False
    return True
def inventory(folder,top,output=True):
    return {str(p.relative_to(folder)):p for p in folder.rglob('*') if p.is_file() and not p.is_symlink() and allowed(p.relative_to(folder),top,output)}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
(R/'diffs').mkdir(exist_ok=True);changes=[]
for top,base in BASES.items():
    a=inventory(base,top,False);b=inventory(R/top,top,False)
    if top=='backend':a={k:v for k,v in a.items() if not k.startswith('evidence/')};b={k:v for k,v in b.items() if not k.startswith('evidence/')}
    patch=[]
    for name in sorted(set(a)|set(b)):
        old=a[name].read_bytes() if name in a else b'';new=b[name].read_bytes() if name in b else b''
        if old==new:continue
        row={'component':top,'path':name,'change':'added' if name not in a else 'removed' if name not in b else 'modified','before':hashlib.sha256(old).hexdigest() if name in a else None,'after':hashlib.sha256(new).hexdigest() if name in b else None}
        try:
            oldtext=old.decode('utf-8');newtext=new.decode('utf-8')
            if '\x00' in oldtext+newtext:raise UnicodeError()
            patch.extend(difflib.unified_diff(oldtext.splitlines(True),newtext.splitlines(True),fromfile='a/'+name if name in a else '/dev/null',tofile='b/'+name if name in b else '/dev/null'))
            row['diff']='unified'
        except UnicodeError:row['diff']='binary; inspect supplied file and hashes'
        changes.append(row)
    (R/'diffs'/f'{top}.patch').write_text(''.join(patch))
(R/'diffs/CHANGES.json').write_text(json.dumps({'bases':{k:str(v) for k,v in BASES.items()},'changes':changes},indent=2)+'\n')
# The version fingerprints source code and package tooling, not mutable logs or DB state.
code=[]
for top in ['source','backend','tools']:
    for name,p in sorted(inventory(R/top,top,False).items()):
        if name.startswith('evidence/'):continue
        code.append(f'{sha(p)}  {top}/{name}\n')
fingerprint=hashlib.sha256(''.join(code).encode()).hexdigest()
version='younew-integration-20261103-'+fingerprint[:12]
release={'id':version,'createdAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'codeFingerprint':fingerprint,'baseCatalog':'younew-catalog-r2-20261103-f925e009189f','baseBackend':'younew-r4b-20261103-8fa3a9310d3b','localOnly':True,'realPlaces':14,'realPlacesStatus':'draft; server publication locked','gitCommitOfIntegration':None,'historicalBaseCommit':'484272957836615deb228d37c4e9d2ac0d9896a8','iosNativeBuild':'NOT TESTED','hostingerAcceptance':'NOT TESTED','hostingerCron':'NOT TESTED','privacy':'Runtime credentials, databases, queues and sessions excluded','excludedHistoricalArtifacts':sorted(HISTORY),'scope':'source+backend+tools+docs+evidence+diffs; static out is LOCAL SYNTHETIC DEMO only'}
(R/'RELEASE.json').write_text(json.dumps(release,indent=2)+'\n')
files={}
for top in ['source','backend','tools','docs','evidence','diffs']:
    for name,p in inventory(R/top,top).items():files[top+'/'+name]=p
for name in ['README_RU.md','ENTRYPOINTS.json','RELEASE.json']:files[name]=R/name
# Known generated credentials must never appear in any packaged file (no values printed).
secrets=[]
for priv in [R/'backend/private',R/'verification-clean/backend/private']:
    if (priv/'env.json').exists():secrets += [v for k,v in json.loads((priv/'env.json').read_text()).items() if ('PASSWORD' in k or 'KEY' in k) and len(v)>=16]
    if (priv/'users.json').exists():secrets += [u['password'] for u in json.loads((priv/'users.json').read_text()).values() if isinstance(u,dict) and 'password' in u]
hits=[]
for name,p in files.items():
    data=p.read_bytes()
    if any(s.encode() in data for s in secrets):hits.append(name)
if hits:raise SystemExit('Credential scan failed in files: '+repr(hits))
report={'status':'PASS','knownGeneratedSecretValues':len(secrets),'matchingFiles':0,'runtimePathsIncluded':False,'limits':'Pattern/known-value scan is not a legal or comprehensive historical-secret audit.'}
(R/'evidence/package-safety.json').write_text(json.dumps(report,indent=2)+'\n');files['evidence/package-safety.json']=R/'evidence/package-safety.json'
manifest=''.join(f'{sha(p)}  {name}\n' for name,p in sorted(files.items()))
(R/'SHA256SUMS.txt').write_text(manifest);files['SHA256SUMS.txt']=R/'SHA256SUMS.txt'
dest=R/'deliverable';dest.mkdir(exist_ok=True);archive=dest/(version+'.tar.gz')
if archive.exists():raise SystemExit('Refusing to overwrite existing archive; remove only your obsolete generated archive explicitly or choose new version')
with tarfile.open(archive,'w:gz',compresslevel=6) as tar:
    for name,p in sorted(files.items()):tar.add(p,arcname=version+'/'+name,recursive=False)
digest=sha(archive);(dest/(archive.name+'.sha256')).write_text(digest+'  '+archive.name+'\n')
with tarfile.open(archive,'r:gz') as tar:
    for line in manifest.splitlines():
        expected,name=line.split('  ',1);actual=hashlib.sha256(tar.extractfile(version+'/'+name).read()).hexdigest()
        if actual!=expected:raise RuntimeError('Archive mismatch: '+name)
(dest/'ARCHIVE_VERIFIED.json').write_text(json.dumps({'status':'PASS','id':version,'filesVerified':len(files)-1,'sha256':digest,'archive':archive.name},indent=2)+'\n')
print(json.dumps({'version':version,'archive':str(archive),'sha256':digest,'verifiedFiles':len(files)-1,'changes':len(changes)},indent=2))
