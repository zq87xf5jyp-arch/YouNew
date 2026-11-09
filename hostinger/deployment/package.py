#!/usr/bin/env python3
"""Package a committed Git tree into a new private directory; never contact a host."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[2]
SKIP = {'node_modules', '.next', 'out', 'dist', '.git', 'private', 'publication',
        'DerivedData', 'evidence', '__pycache__'}
BACKEND = 'hostinger/runtime/backend/source/admin-dashboard/'
TOOLS = ['publish-catalog.mjs', 'export-approved.mjs', 'source-worktree.mjs']
OPS = ['host-preflight.mjs', 'init-qa.mjs', 'backup-qa.mjs', 'restore-qa.mjs']
PHP = ['public/submit-business-inquiry.php', 'public/api/submit-business-inquiry.php',
       'public/private-files.php', 'private/forms/service.php', 'private/forms/sync.php']
DEPLOYMENT = ['cron-business.sh', 'cron-catalog.sh', 'cron-initialize.sh',
              'php-preflight.php', 'qa-access.php', 'sync-config.php.example', 'origins.php.example']


def git(repo, *args):
    return subprocess.check_output(['git', '-C', str(repo), *args])


def committed_tree(repo, ref):
    commit = git(repo, 'rev-parse', '--verify', '--end-of-options', ref + '^{commit}').decode().strip()
    entries = {}
    for record in git(repo, 'ls-tree', '-rz', '--full-tree', commit).split(b'\0'):
        if not record:
            continue
        metadata, raw_path = record.split(b'\t', 1)
        mode, kind, oid = metadata.decode().split()
        if kind == 'blob' and mode in {'100644', '100755'}:
            entries[raw_path.decode()] = {'oid': oid, 'mode': int(mode[-3:], 8)}
    return commit, entries


def permitted(path):
    p = PurePosixPath(path)
    return not any(part in SKIP for part in p.parts) and p.name not in {
        '.DS_Store', 'tsconfig.tsbuildinfo'} and not p.name.startswith('.env')


def package_entries(entries):
    node, php = [], []

    def add(target, source, destination):
        if source not in entries:
            raise ValueError('Required committed source is missing: ' + source)
        target.append({'source': source, 'destination': destination, **entries[source]})

    for source in sorted(entries):
        if source.startswith(BACKEND) and permitted(source[len(BACKEND):]):
            add(node, source, source[len(BACKEND):])
        elif PurePosixPath(source).parts[0] not in {'hostinger', 'docs'} and permitted(source):
            add(node, source, 'catalog-builder/source/' + source)
    for name in TOOLS:
        add(node, 'hostinger/runtime/tools/' + name, 'catalog-builder/tools/' + name)
    add(node, 'hostinger/runtime/backend/db/catalog-drafts.json', 'catalog-builder/backend/db/catalog-drafts.json')
    for name in OPS:
        add(node, 'hostinger/deployment/' + name, 'ops/' + name)
    for source in sorted(entries):
        if source.startswith('hostinger/runtime/backend/db/migrations/') and source.endswith('.sql'):
            add(node, source, 'ops/migrations/' + PurePosixPath(source).name)
    for rel in PHP:
        add(php, 'hostinger/runtime/backend/php/' + rel, 'younew-private/hp1/kit/backend/php/' + rel)
    add(php, 'hostinger/runtime/tools/integration-router.php', 'younew-private/hp1/kit/tools/integration-router.php')
    for name in DEPLOYMENT:
        add(php, 'hostinger/deployment/' + name, 'younew-private/hp1/deployment/' + name)
    for source, destination in [('index.php', 'index.php'), ('htaccess.template', '.htaccess')]:
        add(php, 'hostinger/deployment/' + source, 'public_html/' + destination)
    for items in (node, php):
        destinations = [item['destination'] for item in items]
        if len(set(destinations)) != len(destinations):
            raise ValueError('Duplicate archive destination')
    return {'node-app': node, 'php-site': php}


class Blobs:
    def __init__(self, repo):
        self.process = subprocess.Popen(['git', '-C', str(repo), 'cat-file', '--batch'],
                                        stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    def read(self, oid):
        self.process.stdin.write((oid + '\n').encode())
        self.process.stdin.flush()
        actual_oid, kind, size = self.process.stdout.readline().split()
        if actual_oid.decode() != oid or kind != b'blob':
            raise ValueError('Unexpected Git object')
        value = self.process.stdout.read(int(size))
        if len(value) != int(size) or self.process.stdout.read(1) != b'\n':
            raise ValueError('Incomplete Git blob')
        return value

    def close(self):
        self.process.stdin.close()
        self.process.stdout.close()
        if self.process.wait() != 0:
            raise ValueError('Git object reader failed')


def file_hash(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def build(repo, ref, output, archive=False):
    commit, entries = committed_tree(repo, ref)
    packages = package_entries(entries)
    epoch = int(git(repo, 'show', '-s', '--format=%ct', commit))
    output.mkdir(mode=0o700)  # New directory only; preserve existing release artifacts.
    release = {'schema_version': 1, 'source_commit': commit, 'archives_requested': archive, 'packages': {}}
    blobs = Blobs(repo)
    try:
        for label, items in packages.items():
            manifest = []
            archive_path = output / (label + '.tar.gz')
            raw = archive_path.open('xb') if archive else None
            compressed = gzip.GzipFile(filename='', mode='wb', fileobj=raw, mtime=epoch) if raw else None
            tar = tarfile.open(fileobj=compressed, mode='w|', format=tarfile.PAX_FORMAT) if compressed else None
            try:
                for item in sorted(items, key=lambda x: x['destination']):
                    data = blobs.read(item['oid'])
                    manifest.append({key: item[key] for key in ('source', 'destination')} | {
                        'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data), 'mode': item['mode']})
                    if tar:
                        info = tarfile.TarInfo(item['destination'])
                        info.size, info.mode, info.mtime = len(data), item['mode'], epoch
                        info.uid = info.gid = 0
                        tar.addfile(info, io.BytesIO(data))
            finally:
                if tar:
                    tar.close()
                if compressed:
                    compressed.close()
                if raw:
                    raw.close()
                    archive_path.chmod(0o600)
            manifest_path = output / (label + '-files.json')
            manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
            manifest_path.chmod(0o600)
            record = {'files': len(manifest), 'bytes': sum(x['bytes'] for x in manifest),
                      'manifest_sha256': file_hash(manifest_path)}
            if archive:
                record['archive_sha256'] = file_hash(archive_path)
                record['archive_bytes'] = archive_path.stat().st_size
            release['packages'][label] = record
    finally:
        blobs.close()
    # A completed manifest exists only after every requested artifact is written.
    release_path = output / 'release.json'
    release_path.write_text(json.dumps(release, indent=2) + '\n')
    release_path.chmod(0o600)
    return release


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ref', default='HEAD', help='Committed source revision; working files are ignored')
    parser.add_argument('--output-dir', type=Path, required=True, help='New directory outside the source checkout')
    parser.add_argument('--archive', action='store_true')
    args = parser.parse_args()
    if args.output_dir.resolve().is_relative_to(ROOT):
        parser.error('Output must be outside the source checkout')
    print(json.dumps(build(ROOT, args.ref, args.output_dir, args.archive), indent=2))
