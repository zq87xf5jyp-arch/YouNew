import importlib.util
from datetime import date
from pathlib import Path
import sys
import unittest

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))
spec = importlib.util.spec_from_file_location('freshness', SCRIPTS / 'generate-public-freshness-exclusions.py')
freshness = importlib.util.module_from_spec(spec)
spec.loader.exec_module(freshness)


class PublicFreshnessTest(unittest.TestCase):
    def record(self, **changes):
        return dict(id='place.example', entity_type='place', last_checked='2026-11-01',
                    review_frequency_days=7, **changes)

    def test_due_day_remains_valid_but_next_day_is_withheld(self):
        record = self.record()
        self.assertIsNone(freshness.exclusion(record, date(2026, 11, 8)))
        self.assertEqual(freshness.exclusion(record, date(2026, 11, 9))['id'], record['id'])
        self.assertEqual(record['last_checked'], '2026-11-01')

    def test_expired_event_is_withheld_even_when_review_is_fresh(self):
        record = self.record(attributes={'start_date': '2026-11-01', 'end_date': '2026-11-03'})
        record['entity_type'] = 'event'
        self.assertIsNone(freshness.exclusion(record, date(2026, 11, 3)))
        self.assertIsNotNone(freshness.exclusion(record, date(2026, 11, 4)))


if __name__ == '__main__':
    unittest.main()
