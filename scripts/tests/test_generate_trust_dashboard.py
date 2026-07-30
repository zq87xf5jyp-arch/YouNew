import importlib.util
import sys
import unittest
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
SPEC = importlib.util.spec_from_file_location(
    "generate_trust_dashboard",
    ROOT / "scripts/generate_trust_dashboard.py",
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class TrustDashboardTests(unittest.TestCase):
    def test_legacy_record_without_envelope_is_not_production_ready(self):
        record = {
            "id": "government.fixture",
            "lifecycle_status": "published",
            "verification_status": "verified",
            "official_source": {"is_official": True, "status": "verified_opened"},
        }
        self.assertFalse(MODULE.production_ready(record, datetime.fromisoformat("2026-07-30T12:00:00+00:00")))

    def test_dimension_is_not_established_when_component_denominator_is_missing(self):
        generated = "2026-07-30T12:00:00Z"
        established = MODULE.metric(95, 95, 100, "fixture", "fixture", generated)
        missing = MODULE.metric(None, None, None, "fixture", "fixture", generated)
        dimension = MODULE.readiness_dimension(
            [established, missing], "minimum fixture", generated, "fixture"
        )
        self.assertIsNone(dimension["value"])
        self.assertEqual(dimension["evidenceState"], "not_established")

    def test_minimum_does_not_hide_low_component(self):
        generated = "2026-07-30T12:00:00Z"
        high = MODULE.metric(99, 99, 100, "fixture", "fixture", generated)
        low = MODULE.metric(61, 61, 100, "fixture", "fixture", generated)
        dimension = MODULE.readiness_dimension(
            [high, low], "minimum fixture", generated, "fixture"
        )
        self.assertEqual(dimension["value"], 61)


if __name__ == "__main__":
    unittest.main()
