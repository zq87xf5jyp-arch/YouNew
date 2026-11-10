"""Consistent scoped production file/SQLite backup and isolated restore; no mutation of sources."""
from pathlib import Path
import datetime,hashlib,json,os,shutil,sqlite3,stat,tarfile
os.umask(0o077)
base=Path('/home/u246392949/domains')
site=base/'younew.nl'
private=site/'younew-private'
assert site.is_dir() and not (site/'public_html').is_symlink()
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
dest=private/'launch-backups'/('production-pre-switch-'+stamp)
dest.mkdir(mode=0o700)
snapshot=dest/'snapshot';snapshot.mkdir(mode=0o700)
restore=dest/'restore-check';restore.mkdir(mode=0o700)
# Actual inventory is guarded, so a new data directory cannot silently disappear from scope.
known={'analytics-data','analytics-qa-data','analytics-v1','forms-data','forms-v1','launch-backups','launch-production','qa-data','.htaccess','qa-token.php','README.txt','younew-analytics-private-v1.zip'}
assert {p.name for p in private.iterdir()}==known
sources=[site/'public_html']+[p for p in private.iterdir() if p.name not in {'launch-backups','launch-production'}]
admin=base/'admin.younew.nl'
assert not (admin/'public_html').is_symlink()
admin_expected={'younew-public-html-pre-go-live-20260729T0830Z.zip','public_html','DO_NOT_UPLOAD_HERE','nodejs','private-finance','private-operations','younew-private','.builds','hbuilds'}
assert {p.name for p in admin.iterdir()}==admin_expected
sources += [p for p in admin.iterdir() if p.name!='hbuilds']
assert (admin/'hbuilds/config').is_dir()
sources.append(admin/'hbuilds/config')
# Prepared but disconnected private files are backed up without build caches or source worktrees.
prepared=private/'launch-production'
for rel in ['migration.env','editorial-drafts.json','business-sync-config.php','file-service-cf6ab6f']:
 p=prepared/rel;assert p.exists();sources.append(p)
manifest={'startedAt':stamp,'sources':[str(p.relative_to(base)) for p in sources],'entries':[],'sqlite':[],'productionChanged':False,'mariadb':'Separate verified backup production-db-prelaunch-2026-11-10T13-39-28-735Z; originals retained.'}
def digest(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return h.hexdigest()
def capture(p):
 rel=p.relative_to(base);target=snapshot/rel;st=p.lstat()
 target.parent.mkdir(parents=True,exist_ok=True,mode=0o700)
 entry={'path':str(rel),'mode':stat.S_IMODE(st.st_mode)}
 if stat.S_ISLNK(st.st_mode):
  value=os.readlink(p);target.symlink_to(value);entry.update(type='symlink',target=value)
 elif stat.S_ISDIR(st.st_mode):
  target.mkdir(exist_ok=True,mode=0o700);entry['type']='directory';manifest['entries'].append(entry)
  for child in sorted(p.iterdir()):capture(child)
  return
 elif stat.S_ISREG(st.st_mode):
  if p.name.endswith(('-wal','-shm')) and p.with_name(p.name[:-4]).exists():return
  with p.open('rb') as f:isdb=f.read(16)==b'SQLite format 3\x00'
  if isdb:
   conn=sqlite3.connect(p.as_uri()+'?mode=ro',uri=True,timeout=30);copy=sqlite3.connect(target)
   try:
    conn.backup(copy);assert copy.execute('PRAGMA integrity_check').fetchone()[0]=='ok'
   finally:copy.close();conn.close()
   manifest['sqlite'].append(str(rel))
  else:shutil.copyfile(p,target)
  target.chmod(0o600);entry.update(type='file',bytes=target.stat().st_size,sha256=digest(target),sqlite=isdb)
 else:raise ValueError('Unsupported source file type: '+str(rel))
 manifest['entries'].append(entry)
try:
 for source in sources:capture(source)
 archive=dest/'files.tar.gz'
 with tarfile.open(archive,'w:gz',compresslevel=3,dereference=False) as bundle:
  for child in sorted(snapshot.iterdir()):bundle.add(child,arcname=child.name,recursive=True)
 with tarfile.open(archive) as bundle:
  for member in bundle.getmembers():
   path=Path(member.name);assert not path.is_absolute() and '..' not in path.parts
  bundle.extractall(restore)
 for entry in manifest['entries']:
  p=restore/entry['path']
  if entry['type']=='symlink':assert p.is_symlink() and os.readlink(p)==entry['target']
  elif entry['type']=='file':
   assert not p.is_symlink() and digest(p)==entry['sha256']
   if entry['sqlite']:
    c=sqlite3.connect(p.as_uri()+'?mode=ro',uri=True)
    try:assert c.execute('PRAGMA integrity_check').fetchone()[0]=='ok'
    finally:c.close()
  else:assert p.is_dir() and not p.is_symlink()
 queue=restore/'younew.nl/younew-private/forms-data/submissions.sqlite'
 c=sqlite3.connect(queue.as_uri()+'?mode=ro',uri=True)
 try:queue_counts=dict(c.execute('SELECT kind,COUNT(*) FROM submissions GROUP BY kind').fetchall())
 finally:c.close()
 manifest.update(status='PASS',archiveSha256=digest(archive),archiveBytes=archive.stat().st_size,queueCounts=queue_counts,finishedAt=datetime.datetime.now(datetime.timezone.utc).isoformat())
except Exception as error:manifest.update(status='FAIL',errorType=type(error).__name__)
finally:
 (dest/'manifest.private.json').write_text(json.dumps(manifest,indent=2)+'\n')
 result={k:v for k,v in manifest.items() if k not in {'entries','sources'}};result['directory']=str(dest);result['entries']=len(manifest['entries']);result['sqlite']=len(manifest['sqlite'])
 (dest/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
