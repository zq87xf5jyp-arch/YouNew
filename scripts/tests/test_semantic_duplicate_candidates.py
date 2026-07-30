import importlib.util
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "semantic_duplicate_candidates",
    ROOT / "scripts/semantic_duplicate_candidates.py",
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def record(record_id, title, city=None, entity_type="government_service", governance=None):
    value = {
        "id": record_id,
        "title": title,
        "description": f"Long enough description for {title}",
        "entity_type": entity_type,
        "city_id": city,
    }
    if governance:
        value["governance"] = governance
    return value


class SemanticDuplicateCandidateTests(unittest.TestCase):
    def test_filters_incompatible_type_and_municipality(self):
        records = [
            record("a.one", "Register with the municipality", "amsterdam"),
            record("a.two", "Gemeentelijke registratie", "amsterdam"),
            record("a.three", "Register in Rotterdam", "rotterdam"),
            record("a.four", "Registration museum", "amsterdam", "museum"),
        ]
        self.assertEqual(list(MODULE.compatible_pairs(records)), [(0, 1)])

    def test_national_non_dependent_record_can_pair_with_municipal_record(self):
        national = record(
            "a.national",
            "National registration rules",
            governance={
                "jurisdiction": {
                    "level": "national",
                    "municipalityDependent": False,
                    "municipalityName": None,
                }
            },
        )
        local = record("a.local", "Amsterdam registration", "amsterdam")
        self.assertTrue(MODULE.compatible_pair(national, local))

    def test_threshold_creates_review_only_candidate(self):
        records = [
            record("a.one", "BRP registration", "amsterdam"),
            record("a.two", "Register in the BRP", "amsterdam"),
            record("a.three", "Apply for DigiD", "amsterdam"),
        ]
        embeddings = [[1.0, 0.0], [0.95, 0.1], [0.0, 1.0]]
        candidates = MODULE.candidate_rows(records, embeddings, 0.90)
        self.assertEqual(len(candidates), 1)
        self.assertEqual(candidates[0]["reviewTaskReason"], "possible_duplicate")
        self.assertEqual(candidates[0]["automaticAction"], "none")

    def test_exact_text_is_left_to_exact_duplicate_gate(self):
        records = [
            record("a.one", "Same title", "amsterdam"),
            record("a.two", "Same title", "amsterdam"),
        ]
        self.assertEqual(list(MODULE.compatible_pairs(records)), [])


if __name__ == "__main__":
    unittest.main()
