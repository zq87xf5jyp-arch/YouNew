import importlib.util
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "generate_brp_amsterdam_candidate",
    ROOT / "scripts/generate_brp_amsterdam_candidate.py",
)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(MODULE)


class BRPAmsterdamCandidateTests(unittest.TestCase):
    def test_candidate_is_fail_closed_and_source_backed(self):
        candidate = MODULE.generate()
        governance = candidate["governance"]
        self.assertFalse(candidate["publicationAuthorized"])
        self.assertEqual(candidate["status"], "draft")
        self.assertEqual(governance["publicationStatus"], "draft")
        self.assertEqual(governance["verificationStatus"], "unverified")
        self.assertEqual(governance["reviewState"], "needs_review")
        self.assertIsNone(governance["reviewedBy"])
        self.assertEqual(governance["contentOrigin"], "migrated")
        self.assertEqual(governance["confidenceScore"], 40)
        self.assertEqual(len(candidate["nationalFacts"]), 5)
        self.assertEqual(len(candidate["municipalityVariations"]["Amsterdam"]), 2)

    def test_checked_in_candidate_is_reproducible(self):
        expected = MODULE.generate()
        actual = json.loads(
            (ROOT / "DataProject/staging/brp-amsterdam-governance-candidate.json").read_text()
        )
        self.assertEqual(actual, expected)


if __name__ == "__main__":
    unittest.main()
