import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('qa_configure', Path(__file__).parents[1] / 'configure-initial-qa.py')
configure = importlib.util.module_from_spec(spec)
spec.loader.exec_module(configure)
REPO = Path(__file__).resolve().parents[3]
REF = '852413130f3bc190128e53bebdc997fef7d30d1e'


class InitialQAConfigTests(unittest.TestCase):
    def test_preserves_password_and_existing_files_before_enabling_router(self):
        with tempfile.TemporaryDirectory(prefix='younew-qa-config-') as temp:
            root = Path(temp)
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
            with patch.multiple(configure, ROOT=root, PRIVATE=private, ENV=env, SOURCE=REPO, RESTORE=restore), patch.object(subprocess, 'run', run), patch.object(os, 'replace', replace):
                configure.install(REF)
                self.assertTrue(env.read_bytes().startswith(original))
                self.assertEqual(env.stat().st_mode & 0o777, 0o600)
                self.assertEqual((root / 'public_html/default.php').read_bytes(), b'prior default page')
                self.assertLess(mutations.index(root / 'public_html/.htaccess'), mutations.index(root / 'public_html/index.php'))
                before = env.read_bytes()
                with self.assertRaisesRegex(ValueError, 'Initial configuration only'):
                    configure.install(REF)
                self.assertEqual(env.read_bytes(), before)


if __name__ == '__main__':
    unittest.main()
