import importlib.util
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
SPEC = importlib.util.spec_from_file_location(
    "check_external_links",
    ROOT / "scripts/check-external-links.py",
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class LinkCheckPolicyTests(unittest.TestCase):
    def test_error_classification_is_explicit(self):
        self.assertEqual(MODULE.classify_outcome("https://example.nl", 200, "https://example.nl", ""), "reachable")
        self.assertEqual(MODULE.classify_outcome("https://example.nl", 301, "https://example.nl/new", ""), "redirected")
        self.assertEqual(MODULE.classify_outcome("https://example.nl", 403, "", "HTTPError"), "restricted")
        self.assertEqual(MODULE.classify_outcome("https://example.nl", 404, "", "HTTPError"), "hard_failure")
        self.assertEqual(MODULE.classify_outcome("https://example.nl", 503, "", "HTTPError"), "transient_failure")
        self.assertEqual(MODULE.classify_outcome("https://example.nl", "", "", "SSLCertVerificationError"), "invalid_tls")

    def test_effective_release_location_preserves_record_id(self):
        self.assertEqual(
            MODULE.record_id_from_location(
                "effective-release:government-v1.0.0:government.brp-registration:official_source.url"
            ),
            "government.brp-registration",
        )
        self.assertIsNone(MODULE.record_id_from_location("YouNew/Data/File.swift:12"))


if __name__ == "__main__":
    unittest.main()
