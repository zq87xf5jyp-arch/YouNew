#!/usr/bin/env python3

import importlib.util
import sys
import unittest
from datetime import date, timedelta
from pathlib import Path


SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

SPEC = importlib.util.spec_from_file_location(
    "data_project_qa",
    SCRIPTS / "data-project-qa.py",
)
DATA_PROJECT_QA = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DATA_PROJECT_QA)


def expired_published_event():
    today = date.today()
    yesterday = today - timedelta(days=1)
    return {
        "id": "event.fixture-expired",
        "entity_type": "event",
        "category": "fixture",
        "city_id": "amsterdam",
        "province_id": "noord-holland",
        "coordinates": {"latitude": 52.37, "longitude": 4.89},
        "title": "Expired fixture event",
        "description": "A sufficiently long description for temporal publication-gate testing.",
        "images": [],
        "official_source": {
            "title": "Official fixture source",
            "publisher": "Fixture publisher",
            "url": "https://example.com/event",
            "is_official": True,
            "checked_at": today.isoformat(),
            "status": "verified_opened",
        },
        "website": "https://example.com/event",
        "related_entity_ids": [],
        "last_checked": today.isoformat(),
        "review_frequency_days": 30,
        "verification_status": "verified",
        "ai_summary": "A sufficiently long grounded summary for temporal release testing.",
        "search_keywords": ["fixture", "event", "expired"],
        "lifecycle_status": "published",
        "attributes": {
            "start_date": yesterday.isoformat(),
            "end_date": yesterday.isoformat(),
        },
    }


class DataProjectTemporalGateTests(unittest.TestCase):
    def test_current_published_release_rejects_expired_event(self):
        with self.assertRaises(SystemExit):
            DATA_PROJECT_QA.validate_record(
                expired_published_event(),
                "current release fixture",
                {},
                enforce_current_temporal=True,
            )

    def test_superseded_immutable_release_keeps_historical_record_valid(self):
        DATA_PROJECT_QA.validate_record(
            expired_published_event(),
            "superseded release fixture",
            {},
            enforce_current_temporal=False,
        )


if __name__ == "__main__":
    unittest.main()
