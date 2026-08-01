import importlib.util
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "amsterdam-data-production.py"
SPEC = importlib.util.spec_from_file_location("amsterdam_data_production", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class AmsterdamSourceVerificationTests(unittest.TestCase):
    def test_successful_exact_url_is_verified(self):
        result = MODULE.classify_source_verification({"opened": True, "status_code": 200})

        self.assertTrue(result["reachable"])
        self.assertEqual(result["status"], "verified_opened")
        self.assertEqual(result["method"], "direct request")

    def test_restricted_response_requires_manual_review(self):
        for status_code in (401, 403, 405, 429):
            with self.subTest(status_code=status_code):
                result = MODULE.classify_source_verification({"opened": False, "status_code": status_code})

                self.assertFalse(result["reachable"])
                self.assertEqual(result["status"], "access_restricted")
                self.assertIn("manual review required", result["method"])

    def test_non_success_cannot_inherit_an_opened_flag(self):
        result = MODULE.classify_source_verification({"opened": True, "status_code": 500})

        self.assertFalse(result["reachable"])
        self.assertEqual(result["status"], "access_restricted")


if __name__ == "__main__":
    unittest.main()
