import importlib.util
import json
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('hostinger_package', Path(__file__).parents[1] / 'package.py')
package = importlib.util.module_from_spec(spec)
spec.loader.exec_module(package)


class CommittedPackageTests(unittest.TestCase):
    def test_exact_commit_excludes_untracked_modified_ignored_and_symlink_inputs(self):
        with tempfile.TemporaryDirectory(prefix='younew-package-test-') as temp:
            root = Path(temp)
            repo = root / 'repo'
            repo.mkdir()
            def git(*args):
                return subprocess.check_output(['git', '-C', str(repo), *args], stderr=subprocess.DEVNULL)
            git('init', '-q')
            required = [package.BACKEND + 'package.json', 'tracked.txt', '.env',
                        'node_modules/not-code.js', 'private/not-code.json',
                        'hostinger/runtime/backend/db/catalog-drafts.json',
                        'hostinger/runtime/backend/db/migrations/0001_core.sql',
                        'hostinger/runtime/tools/integration-router.php']
            required += ['hostinger/runtime/tools/' + name for name in package.TOOLS]
            required += ['hostinger/deployment/' + name for name in package.OPS + package.DEPLOYMENT + ['index.php', 'htaccess.template']]
            required += ['hostinger/runtime/backend/php/' + name for name in package.PHP]
            for source in required:
                path = repo / source
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('committed synthetic fixture\n')
            (repo / 'link').symlink_to('tracked.txt')
            git('add', '.')
            git('-c', 'user.name=Synthetic Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'fixture')
            commit = git('rev-parse', 'HEAD').decode().strip()
            (repo / 'tracked.txt').write_text('uncommitted synthetic edit\n')
            (repo / 'untracked-secret.txt').write_text('must never be packaged\n')
            first = package.build(repo, commit, root / 'first', archive=True)
            second = package.build(repo, commit, root / 'second', archive=True)
            self.assertEqual(first, second, 'identical committed tree yields reproducible archives')
            self.assertEqual(first['source_commit'], commit)
            with tarfile.open(root / 'first/node-app.tar.gz') as archive:
                names = archive.getnames()
                self.assertEqual(archive.extractfile('catalog-builder/source/tracked.txt').read(), b'committed synthetic fixture\n')
                for forbidden in ['.env', 'node_modules/not-code.js', 'private/not-code.json', 'link', 'untracked-secret.txt']:
                    self.assertNotIn('catalog-builder/source/' + forbidden, names)
                self.assertIn('catalog-builder/tools/publish-catalog.mjs', names)
                self.assertIn('ops/backup-qa.mjs', names)
                self.assertIn('ops/restore-qa.mjs', names)
            self.assertEqual(json.loads((root / 'first/release.json').read_text()), first)
            with self.assertRaises(FileExistsError):
                package.build(repo, commit, root / 'first', archive=True)


if __name__ == '__main__':
    unittest.main()
