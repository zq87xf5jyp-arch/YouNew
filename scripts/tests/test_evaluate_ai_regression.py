import importlib.util
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "evaluate_ai_regression",
    ROOT / "scripts/evaluate_ai_regression.py",
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class AIEvaluationTests(unittest.TestCase):
    def test_deterministic_grader_requires_governed_trace(self):
        case = {
            "expected": {
                "sourceIDs": ["government.digid"],
                "jurisdiction": {"countryCode": "NL", "municipalityName": None},
                "requiredWarnings": ["never_share_digid_credentials"],
                "behavior": "answer_with_governed_sources",
                "forbiddenClaims": [],
            }
        }
        result = {
            "selectedRecordIDs": ["government.digid"],
            "citations": [{"recordID": "government.digid", "url": "https://www.digid.nl/"}],
            "selectedStatuses": ["verified"],
            "jurisdiction": {"countryCode": "NL", "municipalityName": None},
            "warnings": ["never_share_digid_credentials"],
            "behavior": "answer_with_governed_sources",
            "decisionTrace": {
                "rankingFactors": ["jurisdiction_match"],
                "excludedCandidateReasons": {"wrong_municipality": 1},
                "policyVersion": "1",
                "modelVersion": "candidate",
                "contextVersion": "1",
            },
            "subjectiveGrade": {
                "grounded": True,
                "graderKind": "independent",
                "blinded": True,
                "humanCalibrated": True,
                "graderID": "reviewer-fixture",
            },
        }
        self.assertTrue(all(value is True for value in MODULE.grade_result(case, result).values()))

    def test_candidate_cannot_pass_without_human_approved_cases(self):
        cases = {
            "case-1": {
                "id": "case-1",
                "humanApproved": False,
                "critical": True,
                "expected": {
                    "sourceIDs": [],
                    "jurisdiction": {"countryCode": "NL", "municipalityName": None},
                    "requiredWarnings": [],
                    "behavior": "refuse",
                    "forbiddenClaims": [],
                },
            }
        }
        run = {
            "run": {
                "runID": "fixture-baseline",
                "candidateKind": "baseline",
                "corpusVersion": "draft",
                "environmentDigest": "sha256:" + "a" * 64,
            },
            "results": [],
        }
        candidate = {
            "run": {**run["run"], "runID": "fixture-candidate", "candidateKind": "candidate"},
            "results": [],
        }
        manifest = {
            "blockingRules": {
                "maximumObjectiveDropPercentagePoints": 1,
                "groundednessCitationJurisdictionRefusalMinimum": 0.98,
                "latencyOrCostRegressionExceptionThreshold": 0.2,
            }
        }
        report = MODULE.compare(cases, run, candidate, manifest)
        self.assertEqual(report["releaseGate"], "BLOCK")
        self.assertIn("groundedness_not_established", report["blockers"])


if __name__ == "__main__":
    unittest.main()
