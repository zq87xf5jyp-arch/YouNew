"""Protect historical content while the launch withdraws expired publication."""
import unittest
from pathlib import Path
from scripts.effective_release import resolve_release, effective_release_heads


class OperationalWithdrawalTests(unittest.TestCase):
    def test_withdrawal_changes_no_facts_dates_or_evidence(self):
        project = Path(__file__).resolve().parents[2] / "DataProject"
        old = {r["id"]: r for r in resolve_release(project, "amsterdam-v0.1.8").records}
        new = {r["id"]: r for r in resolve_release(project, "amsterdam-v0.1.10").records}
        self.assertEqual(set(old), set(new))
        changed = 0
        for key, original in old.items():
            replacement = new[key]
            self.assertEqual({k: v for k, v in original.items() if k != "lifecycle_status"},
                             {k: v for k, v in replacement.items() if k != "lifecycle_status"})
            if original != replacement:
                changed += 1
                self.assertEqual(original["lifecycle_status"], "published")
                self.assertEqual(replacement["lifecycle_status"], "retired")
        self.assertEqual(changed, 172)
        self.assertFalse(any(r["lifecycle_status"] == "published" for r in new.values()))
        heads = effective_release_heads(project, {"published"})
        self.assertIn("amsterdam-v0.1.10", heads)
        self.assertNotIn("amsterdam-v0.1.8", heads)
        self.assertNotIn("amsterdam-v0.1.9", heads)


if __name__ == "__main__":
    unittest.main()
