import importlib.util
import json
import os
import shutil
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('qa_configure', Path(__file__).parents[1] / 'configure-initial-qa.py')
configure = importlib.util.module_from_spec(spec)
spec.loader.exec_module(configure)
REPO = Path(__file__).resolve().parents[3]


class InitialQAConfigTests(unittest.TestCase):
    def test_preserves_password_and_existing_files_before_enabling_router(self):
        with tempfile.TemporaryDirectory(prefix='younew-qa-config-') as temp:
            root = Path(temp)
            repo = root / 'source'
            repo.mkdir()
            # A small real committed tree keeps this test independent of history.
            package_spec = importlib.util.spec_from_file_location('qa_package_fixture', REPO / 'hostinger/deployment/package.py')
            package = importlib.util.module_from_spec(package_spec)
            package_spec.loader.exec_module(package)
            sources = ['hostinger/deployment/package.py', 'hostinger/runtime/tools/integration-router.php',
                       'hostinger/runtime/backend/db/catalog-drafts.json']
            sources += ['hostinger/deployment/' + x for x in package.OPS + package.DEPLOYMENT + ['index.php', 'htaccess.template']]
            sources += ['hostinger/runtime/tools/' + x for x in package.TOOLS]
            sources += ['hostinger/runtime/backend/php/' + x for x in package.PHP]
            for source in sources:
                destination = repo / source
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(REPO / source, destination)
            def git(*args):
                return subprocess.check_output(['git', '-C', str(repo), *args], stderr=subprocess.DEVNULL)
            git('init', '-q')
            git('add', '.')
            git('-c', 'user.name=Synthetic Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'fixture')
            private = root / 'younew-private/hp1'
            private.mkdir(parents=True)
            (private / 'backups').mkdir()
            (root / 'public_html').mkdir()
            (root / 'public_html/default.php').write_bytes(b'prior default page')
            env = root / 'launch.env'
            original = b'R4_DB_HOST=127.0.0.1\nR4_DB_NAME=u246392949_younq1\nR4_DB_USER=u246392949_younq1\nR4_DB_PASSWORD="synthetic # quote $ fixture"\n'
            env.write_bytes(original)
            env.chmod(0o600)
            restore = private / 'restore.json'
            restore.write_text('{"status":"PASS"}')
            restore.chmod(0o600)
            seed = private / 'synthetic-users.json'
            seed.write_text(json.dumps({'users': {name: {'email': name + '@example.invalid'} for name in ['owner', 'admin', 'editor', 'viewer', 'qa', 'pending', 'blocked', 'other']}, 'dummyHash': 'synthetic$dummy'}))
            seed.chmod(0o600)
            real_run, real_replace = subprocess.run, os.replace
            mutations = []
            def run(args, **kwargs):
                if args[0] == '/usr/bin/php':
                    self.assertNotIn(kwargs['input'].decode(), ' '.join(args))
                    return subprocess.CompletedProcess(args, 0, stdout=b'$2y$10$' + b'a' * 53)
                return real_run(args, **kwargs)
            def replace(source, destination):
                backups = list((private / 'backups').glob('*/intent.private.json'))
                self.assertEqual(len(backups), 1)
                intent = json.loads(backups[0].read_text())
                saved = next(item for item in intent['files'] if item['path'] == str(env))
                self.assertEqual((backups[0].parent / saved['backup']).read_bytes(), original)
                mutations.append(destination)
                return real_replace(source, destination)
            with patch.multiple(configure, ROOT=root, PRIVATE=private, ENV=env, SOURCE=repo, RESTORE=restore), patch.object(subprocess, 'run', run), patch.object(os, 'replace', replace):
                configure.install('HEAD')
                self.assertTrue(env.read_bytes().startswith(original))
                self.assertEqual(env.stat().st_mode & 0o777, 0o600)
                self.assertEqual((root / 'public_html/default.php').read_bytes(), b'prior default page')
                self.assertLess(mutations.index(root / 'public_html/index.php'), mutations.index(root / 'public_html/.htaccess'))
                before = env.read_bytes()
                with self.assertRaisesRegex(ValueError, 'Initial configuration only'):
                    configure.install('HEAD')
                self.assertEqual(env.read_bytes(), before)


if __name__ == '__main__':
    unittest.main()
