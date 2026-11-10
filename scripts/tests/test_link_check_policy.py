import importlib.util
import contextlib
import io
import json
import sys
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from unittest import mock


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

    def test_transient_retry_recovers_and_preserves_both_observations(self):
        url = "https://example.invalid/recovery"
        response = mock.MagicMock(status=200)
        response.geturl.return_value = url
        response.__enter__.return_value = response
        unavailable = MODULE.urllib.error.HTTPError(url, 503, "fixture", None, io.BytesIO())
        with mock.patch.object(MODULE.urllib.request, "urlopen", side_effect=[unavailable, response]) as opener, mock.patch.object(MODULE.time, "sleep") as sleep:
            result, history = MODULE.check_with_history((url, "fixture:1"), None)
        self.assertEqual(len(result), 5)
        self.assertEqual(result[2], 200)
        self.assertEqual([row["httpStatus"] for row in history], [503, 200])
        self.assertEqual([row["method"] for row in history], ["HEAD", "HEAD"])
        self.assertEqual(history[0]["nextRequestReason"], "bounded_transient_retry")
        self.assertEqual(opener.call_count, 2)
        self.assertEqual(sleep.call_count, 1)
        self.assertLessEqual(sleep.call_args.args[0], 2)
        self.assertTrue(all(call.kwargs["timeout"] == 10 for call in opener.call_args_list))

    def test_persistent_transport_failure_stops_after_one_retry(self):
        error = MODULE.urllib.error.URLError("private fixture body must not be logged")
        with mock.patch.object(MODULE.urllib.request, "urlopen", side_effect=error) as opener, mock.patch.object(MODULE.time, "sleep"):
            result, history = MODULE.check_with_history(("https://example.invalid", "fixture:1"), None)
        self.assertEqual(opener.call_count, 2)
        self.assertEqual(result[2], "")
        self.assertEqual(history[-1]["outcome"], "transient_failure")
        self.assertEqual(history[-1]["retryStoppedReason"], "retry_limit")
        self.assertNotIn("private fixture body", json.dumps(history))

    def test_ambiguous_head_errors_keep_get_verification_without_transient_retry(self):
        url = "https://example.invalid"
        for status, classification in [(404, "hard_failure"), (405, "hard_failure")]:
            with self.subTest(status=status):
                errors = [MODULE.urllib.error.HTTPError(url, status, "fixture", None, io.BytesIO()) for _ in range(2)]
                with mock.patch.object(MODULE.urllib.request, "urlopen", side_effect=errors) as opener, mock.patch.object(MODULE.time, "sleep") as sleep:
                    result, history = MODULE.check_with_history((url, "fixture:1"), None)
                self.assertEqual(result[2], status)
                self.assertEqual([row["method"] for row in history], ["HEAD", "GET"])
                self.assertEqual(history[-1]["outcome"], classification)
                self.assertEqual(opener.call_count, 2)
                sleep.assert_not_called()

    def test_access_and_rate_limit_responses_do_not_trigger_get_or_retry(self):
        url = "https://example.invalid"
        for status in (401, 402, 403, 429):
            with self.subTest(status=status):
                error = MODULE.urllib.error.HTTPError(url, status, "fixture", {"Retry-After": "120"}, io.BytesIO())
                with mock.patch.object(MODULE.urllib.request, "urlopen", side_effect=error) as opener, mock.patch.object(MODULE.time, "sleep") as sleep:
                    result, history = MODULE.check_with_history((url, "fixture:1"), None)
                self.assertEqual(result[2], status)
                self.assertEqual(history[-1]["outcome"], "restricted")
                self.assertEqual([row["method"] for row in history], ["HEAD"])
                self.assertEqual(opener.call_count, 1)
                sleep.assert_not_called()

    def test_retry_after_outside_bound_is_not_ignored_or_slept(self):
        url = "https://example.invalid"
        error = MODULE.urllib.error.HTTPError(url, 503, "fixture", {"Retry-After": "120"}, io.BytesIO())
        with mock.patch.object(MODULE.urllib.request, "urlopen", side_effect=error) as opener, mock.patch.object(MODULE.time, "sleep") as sleep:
            result, history = MODULE.check_with_history((url, "fixture:1"), None)
        self.assertEqual(result[2], 503)
        self.assertEqual(opener.call_count, 1)
        self.assertEqual(history[-1]["retryStoppedReason"], "retry_after_outside_local_bound")
        sleep.assert_not_called()
        self.assertGreaterEqual(MODULE.retry_delay("1"), 1)
        self.assertIsNone(MODULE.retry_delay("not a date"))

    def test_real_loopback_http_flows_through_actual_main_and_report_files(self):
        calls = {}

        class Handler(BaseHTTPRequestHandler):
            def log_message(self, *_args):
                pass

            def respond(self):
                key = (self.command, self.path)
                calls[key] = calls.get(key, 0) + 1
                if self.path == "/recovery":
                    status = 503 if calls[key] == 1 else 200
                elif self.path == "/fallback-recovery":
                    status = 404 if self.command == "HEAD" else 503 if calls[key] == 1 else 200
                else:
                    status = {"/broken": 404, "/restricted": 403, "/transient": 503}[self.path]
                self.send_response(status)
                self.send_header("Content-Length", "0")
                self.end_headers()

            do_HEAD = respond
            do_GET = respond

        server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        origin = f"http://127.0.0.1:{server.server_port}"
        urls = {origin + path: f"effective-release:fixture-v1:fixture.{path[1:]}:official_source.url" for path in ["/recovery", "/fallback-recovery", "/broken", "/restricted", "/transient"]}
        try:
            with tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                with mock.patch.object(MODULE, "ROOT", root), mock.patch.object(MODULE, "PROJECT", root / "DataProject"), mock.patch.object(MODULE, "collect_urls", return_value=(urls, ["fixture-v1"])), mock.patch.object(MODULE, "parse_args", return_value=mock.Mock(release=None)), mock.patch.object(MODULE.time, "sleep"), contextlib.redirect_stdout(io.StringIO()):
                    exit_code = MODULE.main()
                report = json.loads((root / "knowledge_data_health.json").read_text())
                attempts = json.loads((root / "DataProject/reports/source-check-attempts.json").read_text())
                self.assertEqual(exit_code, 1)  # Actual 404 still fails the job.
                self.assertEqual([report[k] for k in ["totalURLs", "reachableURLs", "confirmedBrokenURLs", "accessRestrictedURLs", "transientFailures"]], [5, 2, 1, 1, 1])
                self.assertEqual(len(attempts["attempts"]), 5)  # Retries are not scheduled failures.
                self.assertEqual(attempts["operationalWriteback"], "disabled_requires_separate_approval")
                by_url = {row["url"]: row for row in attempts["attempts"]}
                recovered = by_url[origin + "/fallback-recovery"]
                self.assertEqual(recovered["outcome"], "reachable")
                self.assertEqual(recovered["recordKey"], "fixture.fallback-recovery")
                self.assertEqual([row["method"] for row in recovered["requestHistory"]], ["HEAD", "GET", "GET"])
                self.assertEqual([row["httpStatus"] for row in recovered["requestHistory"]], [404, 503, 200])
                self.assertEqual(sum(len(row["requestHistory"]) for row in attempts["attempts"]), 10)
                self.assertEqual(calls.get(("GET", "/restricted"), 0), 0)
                self.assertTrue(all(len(row["requestHistory"]) <= 3 for row in attempts["attempts"]))
                self.assertEqual(attempts["policy"]["sourceUnavailableAfterConsecutiveHardFailures"], 3)
                self.assertEqual(attempts["policy"]["minimumHardFailureSpanHours"], 24)
                self.assertIn(origin + "/broken", (root / "broken_links.csv").read_text())
        finally:
            server.shutdown()
            server.server_close()
            thread.join()


if __name__ == "__main__":
    unittest.main()
