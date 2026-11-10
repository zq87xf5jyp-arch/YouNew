#!/usr/bin/env python3
"""One-time QA wiring after the synthetic restore; no production or DB changes."""
import argparse
import base64
import datetime
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import secrets
import subprocess

ROOT = Path('/home/u246392949/domains/qa-catalog.younew.nl')
PRIVATE = ROOT / 'younew-private/hp1'
ENV = Path('/home/u246392949/domains/qa-admin.younew.nl/younew-private/launch.env')
SOURCE = ROOT / 'younew-private/launch-source'
RESTORE = PRIVATE / 'backups/2026-11-09T16-58-15-988Z-a78d2763-68f9-43d1-a320-190a55d10a16/restore-preserved/report.private.json'


def regular_private(path):
    if path.is_symlink() or not path.is_file() or path.stat().st_mode & 0o077:
        raise ValueError('Regular private file required: ' + str(path))
    return path.read_bytes()


def install(ref):
    os.umask(0o077)
    original = regular_private(ENV)
    restored = json.loads(regular_private(RESTORE))
    if restored.get('status') != 'PASS':
        raise ValueError('Verified synthetic restore required')
    seed = json.loads(regular_private(PRIVATE / 'synthetic-users.json'))
    if len(seed['users']) != 8 or seed['users']['owner']['email'] != 'owner@example.invalid':
        raise ValueError('Initial synthetic fixture required')
    lines = original.decode().splitlines()
    names = {line.partition('=')[0].strip() for line in lines if '=' in line}
    if any(name.startswith('R4_') and not name.startswith('R4_DB_') for name in names):
        raise ValueError('Initial configuration only; existing runtime settings preserved')
    for name, expected in [('R4_DB_HOST', '127.0.0.1'), ('R4_DB_NAME', 'u246392949_younq1'), ('R4_DB_USER', 'u246392949_younq1')]:
        if sum(line == name + '=' + expected for line in lines) != 1:
            raise ValueError('Exact QA database settings required')
    if not any(line.startswith('R4_DB_PASSWORD=') and len(line.split('=', 1)[1]) > 0 for line in lines):
        raise ValueError('Owner-saved database password required')
    spec = importlib.util.spec_from_file_location('packager', SOURCE / 'hostinger/deployment/package.py')
    packager = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(packager)
    commit, entries = packager.committed_tree(SOURCE, ref)
    package = packager.package_entries(entries)['php-site']
    blob_reader = packager.Blobs(SOURCE)
    files = {}
    try:
        for entry in package:
            files[ROOT / entry['destination']] = blob_reader.read(entry['oid'])
    finally:
        blob_reader.close()
    basic_password = secrets.token_hex(32)
    hashed = subprocess.run(['/usr/bin/php', '-r', 'echo password_hash(stream_get_contents(STDIN), PASSWORD_BCRYPT, ["cost"=>10]);'], input=basic_password.encode(), capture_output=True, check=True).stdout.decode()
    if not hashed.startswith('$2y$10$') or len(hashed) != 60:
        raise ValueError('Basic authentication hash generation failed')
    ingest, files_key, catalog = [secrets.token_hex(32) for _ in range(3)]
    values = {
        'R4_LOCAL': 'false', 'R4_ORIGIN': 'https://qa-runtime.younew.nl',
        'R4_INGEST_WORKSPACE': '11111111-1111-4111-8111-111111111111',
        'R4_INGEST_KEY': ingest, 'R4_FILES_KEY': files_key,
        'R4_FILES_URL': 'https://qa-catalog.younew.nl/private-files.php',
        'R4_DUMMY_PASSWORD_HASH': seed['dummyHash'], 'R4_CATALOG_BUILD_KEY': catalog,
        'R4_CATALOG_PUBLIC_ORIGIN': 'https://qa-catalog.younew.nl',
        'R4_CATALOG_STATUS_AUTH': 'Basic ' + base64.b64encode(('qa:' + basic_password).encode()).decode(),
        'YOUNEW_LOCAL_CATALOG_API': 'https://qa-runtime.younew.nl/api/r4/editorial/approved',
        'YOUNEW_PUBLICATION_ROOT': str(PRIVATE / 'publication'),
    }
    # Preserve the owner's password line byte for byte, including quoting.
    files[ENV] = original.rstrip(b'\n') + b'\n' + ''.join(k + '=' + json.dumps(v) + '\n' for k, v in values.items()).encode()
    def php(value):
        return ("<?php\nreturn json_decode(base64_decode('" + base64.b64encode(json.dumps(value).encode()).decode() + "'), true, 32, JSON_THROW_ON_ERROR);\n").encode()
    forms = PRIVATE / 'kit/backend/php/private/forms'
    files[forms / 'sync-config.php'] = php({'url': values['R4_ORIGIN'], 'ingestKey': ingest, 'documentRoot': str(ROOT / 'public_html'), 'local': False})
    files[forms / 'origins.php'] = php(['https://qa-catalog.younew.nl'])
    files[PRIVATE / 'kit/backend/php/private/files/config.php'] = php({'key': files_key})
    files[PRIVATE / 'access.htpasswd'] = ('qa:' + hashed + '\n').encode()
    files[PRIVATE / 'qa-http.private.json'] = json.dumps({'user': 'qa', 'password': basic_password}).encode()
    # Complete intent and every existing-file backup before the first mutation.
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    backup = PRIVATE / 'backups' / ('initial-config-' + stamp + '-' + secrets.token_hex(4))
    backup.mkdir(mode=0o700)
    inventory = []
    for i, (path, data) in enumerate(files.items()):
        if path.is_symlink():
            raise ValueError('Refusing symlink target: ' + str(path))
        record = {'path': str(path), 'existed': path.exists(), 'new_sha256': hashlib.sha256(data).hexdigest()}
        if path.exists():
            if not path.is_file():
                raise ValueError('Regular target required')
            prior = path.read_bytes()
            saved = backup / (str(i) + '.original')
            saved.write_bytes(prior)
            record.update(backup=saved.name, old_mode=path.stat().st_mode & 0o777, old_sha256=hashlib.sha256(prior).hexdigest())
        inventory.append(record)
    intent = {'source_commit': commit, 'scope': 'isolated QA only', 'files': inventory}
    (backup / 'intent.private.json').write_text(json.dumps(intent, indent=2))
    # Install private code/config, then the gated router, then route all requests to it.
    order = sorted(files, key=lambda p: (0 if ROOT / 'public_html' not in p.parents else 2 if p.name == '.htaccess' else 1))
    for path in order:
        path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        temporary = path.with_name(path.name + '.new-' + secrets.token_hex(6))
        with temporary.open('xb') as stream:
            stream.write(files[path])
            stream.flush()
            os.fsync(stream.fileno())
        temporary.chmod(0o644 if ROOT / 'public_html' in path.parents else 0o600)
        os.replace(temporary, path)
    for path, data in files.items():
        if path.read_bytes() != data:
            raise ValueError('Post-write verification failed')
    report = {'status': 'PASS', 'source_commit': commit, 'configured_files': len(files), 'backup': str(backup), 'production_changed': False, 'app_restart_required': True}
    (backup / 'report.private.json').write_text(json.dumps(report, indent=2))
    print(json.dumps(report))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply-initial-qa', action='store_true', required=True)
    parser.add_argument('--ref', required=True)
    args = parser.parse_args()
    install(args.ref)
