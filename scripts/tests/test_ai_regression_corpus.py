import json
import subprocess
import sys
import unittest
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class AIRegressionCorpusTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        subprocess.run(
            [sys.executable, "scripts/generate_ai_regression_corpus.py"],
            cwd=ROOT,
            check=True,
            capture_output=True,
            text=True,
        )
        cls.manifest = json.loads(
            (ROOT / "DataProject/ai-evaluation/manifest.json").read_text(encoding="utf-8")
        )
        cls.cases = [
            json.loads(line)
            for line in (ROOT / "DataProject/ai-evaluation/corpus-v1.jsonl")
            .read_text(encoding="utf-8")
            .splitlines()
        ]

    def test_exact_composition(self):
        self.assertEqual(len(self.cases), 1000)
        for field, expected in (
            ("group", self.manifest["groups"]),
            ("language", self.manifest["languages"]),
            ("partition", self.manifest["partitions"]),
        ):
            self.assertEqual(Counter(case[field] for case in self.cases), Counter(expected))

    def test_ai_generated_cases_are_not_release_eligible(self):
        self.assertTrue(all(case["contentOrigin"] == "ai_generated_draft" for case in self.cases))
        self.assertTrue(all(case["publicationStatus"] == "draft" for case in self.cases))
        self.assertTrue(all(case["humanApproved"] is False for case in self.cases))
        self.assertTrue(all(case["releaseEligible"] is False for case in self.cases))

    def test_every_case_has_machine_gradable_expected_contract(self):
        required = {"sourceIDs", "jurisdiction", "requiredWarnings", "behavior", "forbiddenClaims"}
        for case in self.cases:
            self.assertEqual(set(case["expected"]), required)


if __name__ == "__main__":
    unittest.main()
