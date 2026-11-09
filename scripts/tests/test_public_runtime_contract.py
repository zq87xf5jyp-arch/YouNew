import copy
import unittest
from datetime import date
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

    def dynamic_check(self):
        return validate_public_partition(self.runtime, self.public, self.exclusions,
                                         self.disposition, self.freshness, date(2026, 11, 9))

    def use_dynamic(self):
        self.exclusions.update(source="scripts/generate-public-freshness-exclusions.py", asOf="2026-11-09")
        self.exclusions["records"][0]["reviewDue"] = "2026-11-08"
        self.freshness = [
            {"id": key, "lifecycle_status": "published", "entity_type": "place",
             "last_checked": checked, "review_frequency_days": 1}
            for key, checked in [("current", "2026-11-08"), ("stale", "2026-11-07")]
        ]

    def test_new_expiry_is_valid_without_changing_old_review_disposition(self):
        self.use_dynamic()
        self.disposition["records"] = []
        self.assertEqual(self.dynamic_check(), [])

    def test_dynamic_exclusions_cannot_hide_current_content(self):
        self.use_dynamic()
        self.public["entities"] = []
        self.exclusions["records"].append({"id": "current", "reason": "freshness_sla_expired", "reviewDue": "2026-11-09"})
        self.exclusions["count"] = 2
        self.assertTrue(self.dynamic_check())

    def test_dynamic_exclusions_reject_stale_evaluation_and_forged_deadline(self):
        self.use_dynamic()
        self.exclusions["asOf"] = "2026-11-08"
        self.assertTrue(self.dynamic_check())
        self.exclusions["asOf"] = "2026-11-09"
        self.exclusions["records"][0]["reviewDue"] = "2026-11-07"
        self.assertTrue(self.dynamic_check())

    def test_expired_event_is_excluded_before_review_deadline(self):
        self.use_dynamic()
        self.freshness[1].update(entity_type="event", last_checked="2026-11-09", attributes={"start_date": "2026-11-08"})
        self.exclusions["records"][0]["reviewDue"] = "2026-11-10"
        self.assertEqual(self.dynamic_check(), [])


if __name__ == "__main__":
    unittest.main()
