import copy
from datetime import timedelta
import json
from pathlib import Path
import tempfile
import unittest
from html.parser import HTMLParser

from fulfill import GateError, digest, instant, prepare, read_json, render, validate


FIXTURES = Path(__file__).parent / "fixtures"
NOW = instant("2026-09-19T12:00:00Z", "clock")


class FulfillmentTests(unittest.TestCase):
    def setUp(self):
        self.order = read_json(FIXTURES / "sandbox-order.json")
        self.payment = read_json(FIXTURES / "sandbox-payment.json")
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.out = Path(self.temp.name)

    def run_pack(self, now=NOW):
        return prepare(self.order, self.payment, self.out, now)

    def test_real_artifacts_and_sandbox_not_revenue(self):
        result = self.run_pack()
        folder = Path(result["directory"])
        self.assertEqual(result["status"], "prepared_not_sent")
        ledger = read_json(folder / "ledger-entry.json")
        self.assertEqual(ledger["live_received_minor"], 0)
        self.assertEqual(ledger["mrr_minor"], 0)
        self.assertIsNone(ledger["revenue_ex_vat_minor"])
        self.assertIsNone(ledger["operating_result_minor"])
        self.assertFalse(ledger["provider_verified_by_cli"])
        self.assertIsNone(ledger["delivery_reference"])
        self.assertIn("SANDBOX", (folder / "pack.html").read_text())
        self.assertEqual(len((folder / "maintenance-journal.csv").read_text().splitlines()), 1)

    def test_identical_retry_preserves_journal(self):
        result = self.run_pack()
        journal = Path(result["directory"]) / "maintenance-journal.csv"
        journal.write_text(journal.read_text() + "manual work record\n")
        before = journal.read_bytes()
        self.assertEqual(self.run_pack()["status"], "already_prepared")
        self.assertEqual(journal.read_bytes(), before)

    def test_fresh_evidence_reuses_artifacts_without_overwriting_original_evidence(self):
        result = self.run_pack()
        folder = Path(result["directory"])
        before = {f.name: f.read_bytes() for f in folder.iterdir()}
        later = NOW + timedelta(days=1)
        self.payment.update(checked_at="2026-09-20T12:00:00Z", reference="new provider observation",
                            reviewed_by="new authorized reviewer")
        self.assertEqual(self.run_pack(later)["status"], "already_prepared")
        self.assertEqual(before, {f.name: f.read_bytes() for f in folder.iterdir()})

    def test_legacy_receipt_accepts_current_evidence_without_migration(self):
        result = self.run_pack()
        path = Path(result["directory"]) / "PREPARATION.json"
        receipt = read_json(path)
        receipt["request_sha256"] = digest({"order": self.order, "payment": self.payment,
                                           "historical_replay": False})
        path.write_text(json.dumps(receipt))
        before = path.read_bytes()
        self.payment["checked_at"] = "2026-09-20T12:00:00Z"
        self.assertEqual(self.run_pack(NOW + timedelta(days=1))["status"], "already_prepared")
        self.assertEqual(path.read_bytes(), before)

    def test_refreshed_refund_blocks_already_prepared_artifact(self):
        self.run_pack()
        self.payment.update(checked_at="2026-09-20T12:00:00Z", refund_status="refunded", refunded_amount_minor=150000)
        with self.assertRaisesRegex(GateError, "refund or unknown"):
            self.run_pack(NOW + timedelta(days=1))

    def test_changed_payment_id_cannot_reuse_same_order(self):
        self.run_pack()
        self.payment["id"] = "pi_other"
        with self.assertRaisesRegex(GateError, "metadata mismatch|different inputs"):
            self.run_pack()

    def test_fresh_readback_cannot_skip_original_integrity(self):
        result = self.run_pack()
        (Path(result["directory"]) / "approved-inputs.json").write_text("{}")
        self.payment["checked_at"] = "2026-09-20T12:00:00Z"
        with self.assertRaisesRegex(GateError, "integrity mismatch"):
            self.run_pack(NOW + timedelta(days=1))

    def test_changed_order_does_not_overwrite(self):
        result = self.run_pack()
        pack = Path(result["directory"]) / "pack.html"
        before = pack.read_bytes()
        self.order["organization"] = "Different organization"
        with self.assertRaisesRegex(GateError, "different inputs"):
            self.run_pack()
        self.assertEqual(pack.read_bytes(), before)

    def test_one_payment_cannot_fund_two_orders(self):
        self.run_pack()
        self.order["id"] = self.payment["order_id"] = "fixture-second-order"
        with self.assertRaisesRegex(GateError, "already allocated"):
            self.run_pack()

    def test_amount_currency_order_and_environment_mismatch(self):
        for key, value in [("amount_minor", 149999), ("currency", "USD"), ("order_id", "other"), ("mode", "live")]:
            with self.subTest(key=key):
                payment = dict(self.payment, **{key: value})
                with self.assertRaises(GateError):
                    prepare(self.order, payment, self.out, NOW)
        self.assertEqual(list(self.out.iterdir()), [])

    def test_unpaid_unknown_refund_and_partial_refund(self):
        for override in [{"status": "invoice_issued"}, {"status": "unknown"}, {"refund_status": "unknown"},
                         {"refund_status": "partial", "refunded_amount_minor": 1}]:
            with self.subTest(override=override):
                with self.assertRaises(GateError):
                    prepare(self.order, dict(self.payment, **override), self.out, NOW)

    def test_refund_blocks_retry_after_pack_was_prepared(self):
        result = self.run_pack()
        self.payment.update(refund_status="full", refunded_amount_minor=150000)
        with self.assertRaisesRegex(GateError, "refund"):
            self.run_pack()
        # Honest offline limitation: old bytes remain; this is not access control.
        self.assertTrue((Path(result["directory"]) / "pack.html").exists())

    def test_45_day_boundary_and_stale_source(self):
        g = self.order["guides"][0]
        g["checked_at"] = "2026-08-05"
        validate(self.order, self.payment, NOW)
        g["checked_at"] = "2026-08-04"
        with self.assertRaisesRegex(GateError, "45 days"):
            self.run_pack()

    def test_impossible_future_and_overdue_source_dates(self):
        for key, value in [("checked_at", "2026-02-30"), ("checked_at", "2026-09-20"),
                           ("review_due_at", "2026-09-18"), ("approved_at", "2026-09-20T00:00:00Z")]:
            order = copy.deepcopy(self.order)
            order["guides"][0][key] = value
            with self.subTest(key=key, value=value), self.assertRaises(GateError):
                prepare(order, self.payment, self.out, NOW)

    def test_approval_and_agreement_pending_block(self):
        self.order["agreement"]["status"] = "draft"
        with self.assertRaisesRegex(GateError, "agreement"):
            self.run_pack()
        self.order["agreement"]["status"] = "accepted"
        self.order["guides"][0]["approval_status"] = "pending"
        with self.assertRaisesRegex(GateError, "approval pending"):
            self.run_pack()

    def test_scope_requires_three_to_five_guides(self):
        for count in [0, 1, 2, 6]:
            order = copy.deepcopy(self.order)
            order["guides"] = [dict(order["guides"][0], id=f"test-{n}", url=f"https://example.invalid/{n}") for n in range(count)]
            with self.subTest(count=count), self.assertRaisesRegex(GateError, "3 to 5"):
                prepare(order, self.payment, self.out, NOW)

    def test_payment_evidence_freshness(self):
        for timestamp in ["2026-09-18T11:59:59Z", "2026-09-19T12:00:01Z", "2026-02-30T00:00:00Z"]:
            with self.subTest(timestamp=timestamp), self.assertRaises(GateError):
                prepare(self.order, dict(self.payment, checked_at=timestamp), self.out, NOW)

    def test_exact_90_day_inclusive_scope_and_expiry(self):
        self.order["end_date"] = "2026-12-18"
        with self.assertRaisesRegex(GateError, "90 calendar days"):
            self.run_pack()
        self.order["end_date"] = "2026-12-17"
        with self.assertRaisesRegex(GateError, "period already ended"):
            self.run_pack(NOW + timedelta(days=90))

    def test_html_escaping_and_no_remote_assets(self):
        self.order["organization"] = '<script>alert("x")</script>'
        self.order["guides"][0]["title"] = '<img src=x onerror=alert(1)>'
        markup = render(self.order)
        class Tags(HTMLParser):
            tags = []
            def handle_starttag(self, tag, attrs):
                self.tags.append(tag)
        parser = Tags()
        parser.feed(markup)
        self.assertNotIn("script", parser.tags)
        self.assertNotIn("img", parser.tags)
        self.assertIn("&lt;script&gt;", markup)
        self.order["guides"][0]["url"] = "javascript:alert(1)"
        with self.assertRaisesRegex(GateError, "HTTPS"):
            self.run_pack()

    def test_all_three_languages_and_no_silent_translation(self):
        for language in ["en", "nl", "ru"]:
            order = copy.deepcopy(self.order)
            order["language"] = language
            for guide in order["guides"]:
                guide["language"] = language
            validate(order, self.payment, NOW)
            self.assertIn(f'<html lang="{language}">', render(order))
        self.order["language"] = "ru"
        with self.assertRaisesRegex(GateError, "language"):
            self.run_pack()

    def test_live_receipt_is_one_time_and_tax_costs_remain_unknown(self):
        # Synthetic inputs exercise only classification; they are not a live provider proof.
        self.order["mode"] = self.payment["mode"] = "live"
        ledger = read_json(Path(self.run_pack()["directory"]) / "ledger-entry.json")
        self.assertIsNone(ledger["live_received_minor"])
        self.assertEqual(ledger["confirmed_gross_charge_minor"], 150000)
        self.assertEqual(ledger["mrr_minor"], 0)
        self.assertIsNone(ledger["vat_minor"])
        self.assertIsNone(ledger["fees_minor"])
        self.assertFalse(ledger["provider_verified_by_cli"])

    def test_tampered_output_does_not_silently_reuse(self):
        result = self.run_pack()
        (Path(result["directory"]) / "pack.html").write_text("corrupt")
        with self.assertRaisesRegex(GateError, "integrity mismatch"):
            self.run_pack()

    def test_historical_replay_is_marked_and_cannot_be_live(self):
        result = prepare(self.order, self.payment, self.out, NOW, historical_replay=True)
        folder = Path(result["directory"])
        self.assertIn("HISTORICAL SANDBOX REPLAY", (folder / "pack.html").read_text())
        self.assertTrue(read_json(folder / "PREPARATION.json")["historical_replay"])
        self.order["mode"] = self.payment["mode"] = "live"
        with self.assertRaisesRegex(GateError, "sandbox only"):
            prepare(self.order, self.payment, self.out, NOW, historical_replay=True)

    def test_displayed_review_date_obeys_freshness_and_service_end(self):
        self.order["guides"][0]["checked_at"] = "2026-09-01"
        self.order["guides"][0]["review_due_at"] = "2026-12-31"
        self.assertIn("Review this copy by: 2026-10-16", render(self.order))
        self.order["start_date"], self.order["end_date"] = "2026-06-23", "2026-09-20"
        validate(self.order, self.payment, NOW)
        self.assertIn("Review this copy by: 2026-09-20", render(self.order))

    def test_empty_receipt_inventory_cannot_skip_integrity(self):
        result = self.run_pack()
        p = Path(result["directory"]) / "PREPARATION.json"
        receipt = read_json(p)
        receipt["immutable_files"] = {}
        p.write_text(json.dumps(receipt))
        with self.assertRaisesRegex(GateError, "immutable file inventory"):
            self.run_pack()


if __name__ == "__main__":
    unittest.main(verbosity=2)
