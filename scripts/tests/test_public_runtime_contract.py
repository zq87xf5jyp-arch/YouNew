import copy
import unittest
from scripts.public_runtime_contract import validate_public_partition


class PublicPartitionTests(unittest.TestCase):
    def setUp(self):
        self.runtime = {"entities": [{"id": "current"}, {"id": "stale"}]}
        self.public = {"entities": [{"id": "current"}]}
        self.exclusions = {
            "policy": "fail_closed_until_field_level_reverification",
            "source": "DataProject/quality/phase4-amsterdam-stale-disposition.json",
            "count": 1,
            "records": [{"id": "stale", "reason": "freshness_sla_expired"}],
        }
        self.disposition = {"records": [{"entity_id": "stale", "disposition": "temporarily_exclude_from_public_output"}]}

    def check(self):
        return validate_public_partition(self.runtime, self.public, self.exclusions, self.disposition)

    def test_explicit_reviewed_exclusion_is_valid(self):
        self.assertEqual(self.check(), [])

    def test_unexplained_drop_and_foreign_record_are_rejected(self):
        self.public["entities"] = []
        self.assertTrue(self.check())
        self.public["entities"] = [{"id": "foreign"}]
        self.assertTrue(self.check())

    def test_excluded_record_cannot_be_republished(self):
        self.public["entities"].append({"id": "stale"})
        self.assertTrue(self.check())

    def test_forged_exclusion_without_disposition_is_rejected(self):
        self.disposition["records"] = []
        self.assertTrue(self.check())

    def test_duplicate_exclusion_is_not_a_valid_count(self):
        self.exclusions["records"].append(copy.deepcopy(self.exclusions["records"][0]))
        self.exclusions["count"] = 2
        self.assertTrue(self.check())


if __name__ == "__main__":
    unittest.main()
