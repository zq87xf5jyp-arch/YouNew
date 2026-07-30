import json
import sys
import unittest
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))

from governance_contract import (  # noqa: E402
    ai_eligibility,
    confidence_breakdown,
    confidence_score,
    effective_status,
    rank_retrieval_candidates,
)


class GovernanceContractTests(unittest.TestCase):
    def test_status_policy_fixtures(self):
        fixture = json.loads(
            (ROOT / "DataProject/quality/governance-policy-fixtures.json").read_text(encoding="utf-8")
        )
        evaluated_at = datetime.fromisoformat(fixture["evaluatedAt"].replace("Z", "+00:00"))
        for case in fixture["cases"]:
            with self.subTest(case=case["id"]):
                self.assertEqual(effective_status(case["record"], evaluated_at), case["expectedStatus"])

    def test_confidence_is_evidence_index_not_mutable_claim(self):
        record = {
            "publicationStatus": "published",
            "verificationStatus": "verified",
            "officialSourceURL": "https://amsterdam.nl/brp",
            "lastVerifiedAt": "2026-07-29T12:00:00Z",
            "nextReviewAt": "2026-10-27T12:00:00Z",
            "reviewIntervalDays": 90,
            "reviewedBy": "reviewer-a",
            "reviewerHistory": ["reviewer-a", "reviewer-b"],
            "jurisdiction": {"applicabilityVerified": True},
            "confidenceScore": 3
        }
        evaluated_at = datetime.fromisoformat("2026-07-30T12:00:00+00:00")
        expected = {
            "officialSource": 40,
            "humanReviewer": 20,
            "independentReview": 15,
            "freshness": 10,
            "jurisdictionApplicability": 15,
        }
        self.assertEqual(confidence_breakdown(record, evaluated_at), expected)
        self.assertEqual(confidence_score(record, evaluated_at), 100)

    def test_overdue_is_secondary_and_disputed_is_excluded(self):
        evaluated_at = datetime.fromisoformat("2026-07-30T12:00:00+00:00")
        base = {
            "publicationStatus": "published",
            "officialSourceURL": "https://example.nl/source",
            "lastVerifiedAt": "2026-01-01T00:00:00Z",
            "nextReviewAt": "2026-01-02T00:00:00Z",
            "reviewIntervalDays": 1,
        }
        self.assertEqual(ai_eligibility({**base, "verificationStatus": "verified"}, evaluated_at), "secondary_only")
        self.assertEqual(ai_eligibility({**base, "verificationStatus": "disputed"}, evaluated_at), "excluded")

    def test_retrieval_ranking_is_jurisdiction_first_and_stable(self):
        evaluated_at = datetime.fromisoformat("2026-07-30T12:00:00+00:00")
        base = {
            "publicationStatus": "published",
            "verificationStatus": "verified",
            "officialSourceURL": "https://example.nl/source",
            "lastVerifiedAt": "2026-07-29T12:00:00Z",
            "nextReviewAt": "2026-10-27T12:00:00Z",
            "reviewIntervalDays": 90,
            "reviewedBy": "reviewer-a",
            "confidenceBreakdown": {"officialSource": 40},
        }
        records = [
            {
                **base,
                "id": "national",
                "jurisdiction": {
                    "level": "national",
                    "municipalityDependent": False,
                    "applicabilityVerified": True,
                },
            },
            {
                **base,
                "id": "amsterdam-z",
                "jurisdiction": {
                    "level": "municipal",
                    "municipalityDependent": True,
                    "municipalityName": "Amsterdam",
                    "applicabilityVerified": True,
                },
            },
            {
                **base,
                "id": "rotterdam",
                "jurisdiction": {
                    "level": "municipal",
                    "municipalityDependent": True,
                    "municipalityName": "Rotterdam",
                    "applicabilityVerified": True,
                },
            },
            {
                **base,
                "id": "disputed",
                "verificationStatus": "disputed",
                "jurisdiction": {
                    "level": "national",
                    "municipalityDependent": False,
                    "applicabilityVerified": True,
                },
            },
        ]
        ranked = rank_retrieval_candidates(records, "Amsterdam", evaluated_at)
        self.assertEqual([record["id"] for record in ranked["primary"]], ["amsterdam-z", "national"])
        self.assertEqual(ranked["excludedCandidateReasons"], {"disputed": 1, "wrong_municipality": 1})


if __name__ == "__main__":
    unittest.main()
