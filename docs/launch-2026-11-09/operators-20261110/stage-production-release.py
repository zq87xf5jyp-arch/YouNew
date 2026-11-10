"""Prepare code/config only; do not switch public_html, change live forms, DB or cron."""
from pathlib import Path
import datetime,hashlib,json,os,shutil,subprocess
os.umask(0o077)
base=Path('/home/u246392949/domains/younew.nl');root=base/'younew-private/launch-production'
source=Path('/home/u246392949/domains/qa-catalog.younew.nl/younew-private/launch-source')
commit='5e0b3e152c7619f967fc7b518854bd6d8c9cb374'
assert subprocess.check_output(['git','-C',str(source),'rev-parse','HEAD'],text=True).strip()==commit
out=root/'public-build-5e0b3e1/admin-dashboard/public-site/out';target=base/'public-release-5e0b3e1'
assert not target.exists()
expected=json.loads((root/'public-build-5e0b3e1-files.json').read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for row in expected:assert sha(out/row['path'])==row['sha256']
assert sha(base/'public_html/index.html')=='640029346dbd00c7fd626acc65bbd2badbd5560f340d6629681a1babd8a2d254'
backup=base/'younew-private/launch-backups/production-pre-switch-20261110T144758Z'
assert json.loads((backup/'result.json').read_text())['status']=='PASS'
shutil.copytree(out,target)
# Retain only old hashed JS/CSS resources for already-open clients, never old catalog/search/page data.
preserved=[]
for p in (base/'public_html/_next/static').rglob('*'):
 if p.is_file():
  assert not p.is_symlink();relative=p.relative_to(base/'public_html');q=target/relative
  if q.exists():assert sha(p)==sha(q)
  else:q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q);preserved.append(str(relative))
for p in (base/'public_html').glob('static-shell.*.js'):
 q=target/p.name
 if q.exists():assert sha(p)==sha(q)
 else:shutil.copy2(p,q);preserved.append(p.name)
for p in (base/'public_html/.well-known').rglob('*'):
 if p.is_file():
  assert not p.is_symlink();q=target/p.relative_to(base/'public_html')
  if q.exists():assert sha(p)==sha(q)
  else:q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q);preserved.append(str(p.relative_to(base/'public_html')))
wrapper=target/'api/private-files.php';assert not wrapper.exists()
wrapper.write_text("<?php declare(strict_types=1); require '/home/u246392949/domains/younew.nl/younew-private/launch-production/file-service-cf6ab6f/public/private-files.php';\n")
subprocess.run(['php','-l',str(wrapper)],capture_output=True,check=True)
for p in [target,*target.rglob('*')]:
 assert not p.is_symlink();p.chmod(0o755 if p.is_dir() else 0o644)
php=root/'php-prepared-5e0b3e1';php.mkdir(mode=0o700);forms=php/'forms-v1';forms.mkdir(mode=0o700)
for name in ['service.php','sync.php']:
 p=source/'hostinger/runtime/backend/php/private/forms'/name;shutil.copy2(p,forms/name);(forms/name).chmod(0o600)
assert '/rest/v1/' not in (forms/'sync.php').read_text() and '/api/r4/ingest/business' in (forms/'sync.php').read_text()
(forms/'origins.php').write_text("<?php return ['https://younew.nl','https://www.younew.nl'];\n");(forms/'origins.php').chmod(0o600)
shutil.copy2(root/'business-sync-config.php',forms/'sync-config.php');(forms/'sync-config.php').chmod(0o600)
for p in forms.iterdir():subprocess.run(['php','-l',str(p)],capture_output=True,check=True)
logs=root/'logs';logs.mkdir(mode=0o700,exist_ok=True)
paused=root/'PRODUCTION_BUSINESS_PAUSED';assert not paused.exists();paused.write_text('Prepared; no production worker has been activated.\n')
cron=root/'cron-business-production.sh'
cron.write_text('''#!/bin/sh
set -eu
umask 077
STATE=/home/u246392949/domains/younew.nl/younew-private/launch-production
[ ! -f "$STATE/PRODUCTION_BUSINESS_PAUSED" ] || exit 0
[ -f "$STATE/production-active-release.json" ] || exit 0
PATH=/usr/bin:/bin
export PATH
exec >> "$STATE/logs/business-cron.jsonl" 2>&1
printf '{"event":"cron_start","at":"%s"}\\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
/usr/bin/php /home/u246392949/domains/younew.nl/younew-private/forms-v1/sync.php
printf '{"event":"cron_end","at":"%s"}\\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
''');cron.chmod(0o700);subprocess.run(['sh','-n',str(cron)],check=True)
files=[{'path':str(p.relative_to(target)),'bytes':p.stat().st_size,'sha256':sha(p)} for p in sorted(target.rglob('*')) if p.is_file()]
(root/'production-candidate-files-5e0b3e1.json').write_text(json.dumps(files,indent=2)+'\n')
result={'status':'STAGED_NOT_ACTIVE','commit':commit,'candidate':str(target),'baseFiles':len(expected),'files':len(files),'preservedHashedAssets':len(preserved),'preservedPaths':preserved,'privateFileBootstrapSha256':sha(wrapper),'phpPrepared':str(php),'backup':str(backup),'productionChanged':False,'at':datetime.datetime.now(datetime.timezone.utc).isoformat()}
(root/'production-candidate-5e0b3e1.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:v for k,v in result.items() if k!='preservedPaths'}))
