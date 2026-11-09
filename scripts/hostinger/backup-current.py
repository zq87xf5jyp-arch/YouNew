#!/usr/bin/env python3
"""Create a private, non-destructive Hostinger backup and verify an isolated restore.

Run from domains/younew.nl. No database rows, credentials, or cron values are printed.
This covers files and SQLite. MariaDB needs a separate consistent dump when configured.
"""
import datetime
import hashlib
import json
import os
from pathlib import Path
import shutil
import sqlite3
import subprocess
import tarfile

os.umask(0o077)
site = Path.cwd().resolve()
if site.name != 'younew.nl' or site.parent.name != 'domains':
    raise SystemExit('Run from the Hostinger younew.nl domain directory')
stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
destination = site / 'younew-private' / 'launch-backups' / stamp
destination.mkdir(parents=True, exist_ok=False, mode=0o700)
domains = site.parent
sources = ['younew.nl/public_html', 'younew.nl/younew-private',
           'admin.younew.nl', 'qa-admin.younew.nl', 'qa-catalog.younew.nl']
manifest = {'createdAt': stamp, 'sources': sources, 'sqlite': [], 'files': [],
            'mariadb': 'not included; check configured databases separately',
            'productionChanged': False}

def excluded(path):
    return 'launch-backups' in path.parts or '.trash' in path.parts

for source in sources:
    for path in sorted((domains / source).rglob('*')):
        if excluded(path) or path.is_symlink() or not path.is_file():
            continue
        relative = path.relative_to(domains).as_posix()
        manifest['files'].append({'path': relative, 'bytes': path.stat().st_size,
                                  'sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
        with path.open('rb') as stream:
            sqlite_header = stream.read(16) == b'SQLite format 3\x00'
        if not sqlite_header:
            continue
        snapshot = destination / 'sqlite' / relative
        snapshot.parent.mkdir(parents=True, exist_ok=True)
        original = sqlite3.connect(path.as_uri() + '?mode=ro', uri=True, timeout=30)
        target = sqlite3.connect(snapshot)
        try:
            original.backup(target)
            assert target.execute('PRAGMA integrity_check').fetchone()[0] == 'ok'
        finally:
            target.close()
            original.close()
        manifest['sqlite'].append(relative)

if shutil.which('crontab'):
    cron = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
    (destination / 'crontab.private.txt').write_text(cron.stdout)
    manifest['cronCaptured'] = cron.returncode == 0
else:
    manifest['cronCaptured'] = False
    manifest['cronNote'] = 'crontab unavailable in SSH; capture scheduling through hPanel'

def tar_filter(info):
    return None if excluded(Path(info.name)) else info

archive = destination / 'files.tar.gz'
with tarfile.open(archive, 'w:gz') as bundle:
    for source in sources:
        bundle.add(domains / source, arcname=source, filter=tar_filter)
manifest['archiveSha256'] = hashlib.sha256(archive.read_bytes()).hexdigest()
manifest['archiveBytes'] = archive.stat().st_size
restore = destination / 'restore-check'
restore.mkdir(mode=0o700)
with tarfile.open(archive) as bundle:
    # This archive was generated locally from explicit account-owned paths.
    # Links may remain in the snapshot but are never followed during verification.
    bundle.extractall(restore)

for relative in manifest['sqlite']:
    target = restore / relative
    shutil.copy2(destination / 'sqlite' / relative, target)
    connection = sqlite3.connect(target.as_uri() + '?mode=ro', uri=True)
    try:
        assert connection.execute('PRAGMA integrity_check').fetchone()[0] == 'ok'
    finally:
        connection.close()

sqlite_set = set(manifest['sqlite'])
changed_during_backup = []
for entry in manifest['files']:
    if entry['path'] in sqlite_set or entry['path'].endswith(('-wal', '-shm')):
        continue
    restored = restore / entry['path']
    actual = hashlib.sha256(restored.read_bytes()).hexdigest()
    if actual != entry['sha256']:
        changed_during_backup.append(entry['path'])
manifest['changedDuringBackup'] = changed_during_backup
manifest['isolatedRestore'] = 'passed' if not changed_during_backup else 'review required'
(destination / 'manifest.private.json').write_text(json.dumps(manifest, indent=2))
print(json.dumps({'backup': str(destination), 'files': len(manifest['files']),
                  'sqlite': len(manifest['sqlite']), 'archiveBytes': manifest['archiveBytes'],
                  'sha256': manifest['archiveSha256'], 'restore': manifest['isolatedRestore'],
                  'cronCaptured': manifest['cronCaptured']}))
