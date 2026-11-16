"""Static publication cannot inherit editorial approval or a different build's QA/CI."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('pr75_deploy', Path(__file__).parents[1] / 'pr75-integration-deploy.py')
deploy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(deploy)


class ExactDeploymentAuthorizationTests(unittest.TestCase):
    def test_absent_or_mismatched_permission_never_touches_production(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            commit = 'a' * 40
            sha = 'b' * 64
            (root / 'candidate-meta.json').write_text(json.dumps({'commit': commit, 'archiveSha256': sha, 'mergedCommit': 'c' * 40, 'pullRequests': [75, 76]}))
            valid = dict(status='approved', reviewerId='owner.ivan', scope='production-deploy-and-merge-pr75-pr76', commit=commit, archiveSha256=sha, editorialRequestSha256='58bc2fefa694ac31b4f3558a283e8d2b3c7b5997f7bb4598d278e52b2fbf6e11', ownerConfirmation='Synthetic fixture only, never a real owner authorization', questionItemId='synthetic')
            with patch.object(deploy, 'ROOT', root), patch.object(deploy, 'COMMIT', commit), patch.object(deploy, 'exchange') as exchange:
                with self.assertRaises(FileNotFoundError):
                    deploy.activate()
                for key, value in [('status', 'needs_review'), ('reviewerId', 'automation'), ('scope', 'editorial-only'), ('commit', 'd' * 40), ('archiveSha256', 'e' * 64), ('editorialRequestSha256', 'f' * 64), ('ownerConfirmation', ''), ('questionItemId', '')]:
                    with self.subTest(key=key):
                        (root / 'production-authorization.json').write_text(json.dumps({**valid, key: value}))
                        with self.assertRaises(AssertionError):
                            deploy.activate()
                (root / 'production-authorization.json').write_text(json.dumps(valid))
                (root / 'ci-result.json').write_text(json.dumps({'commit': 'd' * 40, 'status': 'PASS', 'allApplicableWorkflowsPassed': True}))
                with self.assertRaises(AssertionError):
                    deploy.activate()
                exchange.assert_not_called()


if __name__ == '__main__':
    unittest.main()
