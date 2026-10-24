#!/usr/bin/env python3
"""Prepare a local B2B pack from explicitly reviewed manual evidence.

This CLI does not verify a provider, send files, grant access or recognize revenue.
"""
from __future__ import annotations

import argparse
import csv
from datetime import date, datetime, timedelta, timezone
import fcntl
import hashlib
import html
import io
import json
import os
from pathlib import Path
import re
import shutil
import tempfile
from urllib.parse import quote, urlsplit


class GateError(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise GateError(message)


def text(value, name, limit=500):
    require(isinstance(value, str) and 0 < len(value.strip()) <= limit,
            f"invalid {name}")
    require(not any(ord(c) < 32 or ord(c) == 127 for c in value), f"invalid {name}")
    return value


def integer(value, name, minimum=0):
    require(type(value) is int and minimum <= value <= 10**12, f"invalid {name}")
    return value


def day(value, name):
    require(isinstance(value, str) and re.fullmatch(r"\d{4}-\d{2}-\d{2}", value),
            f"invalid {name}")
    try:
        return date.fromisoformat(value)
    except ValueError as exc:
        raise GateError(f"invalid {name}") from exc


def instant(value, name):
    require(isinstance(value, str) and re.fullmatch(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z", value),
            f"invalid {name}; UTC seconds required")
    try:
        return datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    except ValueError as exc:
        raise GateError(f"invalid {name}") from exc


def exact_keys(value, keys, name):
    require(isinstance(value, dict) and set(value) == set(keys), f"invalid {name} fields")


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, ensure_ascii=False,
                                     separators=(",", ":")).encode()).hexdigest()


def validate(order, payment, now):
    require(isinstance(now, datetime) and now.utcoffset() == timedelta(0), "UTC clock required")
    exact_keys(order, ["schema_version", "id", "mode", "organization", "region", "language",
                       "amount_minor", "currency", "start_date", "end_date", "contact",
                       "agreement", "guides"], "order")
    require(order["schema_version"] == 1 and type(order["schema_version"]) is int, "unsupported order schema")
    require(isinstance(order["id"], str) and re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_-]{0,79}", order["id"]), "invalid order id")
    require(order["mode"] in ["sandbox", "live"], "unknown order mode")
    require(order["language"] in ["en", "nl", "ru"], "unsupported pack language")
    for field in ["organization", "region"]:
        text(order[field], field, 160)
    integer(order["amount_minor"], "order amount", 1)
    require(order["currency"] == "EUR", "only EUR supported; do not infer exchange rates")
    start, end = day(order["start_date"], "start date"), day(order["end_date"], "end date")
    require(end == start + timedelta(days=89), "scope must be exactly 90 calendar days, inclusive")
    require(now.date() <= end, "service period already ended")
    exact_keys(order["contact"], ["name", "email"], "contact")
    text(order["contact"]["name"], "contact name", 120)
    email = text(order["contact"]["email"], "contact email", 254)
    require(re.fullmatch(r"[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}", email), "invalid contact email")
    agreement = order["agreement"]
    exact_keys(agreement, ["status", "reference", "accepted_at", "reviewed_by"], "agreement")
    require(agreement["status"] == "accepted", "agreement not accepted")
    text(agreement["reference"], "agreement reference")
    text(agreement["reviewed_by"], "agreement reviewer", 120)
    require(instant(agreement["accepted_at"], "agreement accepted_at") <= now, "future agreement")
    guides = order["guides"]
    require(isinstance(guides, list) and 3 <= len(guides) <= 5, "select 3 to 5 reviewed guides")
    ids, urls = set(), set()
    for guide in guides:
        exact_keys(guide, ["id", "title", "url", "language", "publisher", "checked_at",
                          "review_due_at", "approval_status", "approval_reference", "approved_at"], "guide")
        for field in ["id", "title", "publisher", "approval_reference"]:
            text(guide[field], f"guide {field}")
        require(guide["id"] not in ids and guide["url"] not in urls, "duplicate guide")
        ids.add(guide["id"])
        require(guide["language"] == order["language"], "guide language does not match pack")
        raw_url = text(guide["url"], "guide URL", 2000)
        require(not any(c.isspace() for c in raw_url), "invalid guide URL")
        try:
            url = urlsplit(raw_url)
            port = url.port
        except ValueError as exc:
            raise GateError("invalid guide URL") from exc
        require(url.scheme == "https" and bool(url.hostname) and url.username is None and url.password is None,
                "guide URL must be HTTPS without credentials")
        require(port in [None, 443], "unexpected guide URL port")
        urls.add(raw_url)
        checked = day(guide["checked_at"], "guide checked_at")
        due = day(guide["review_due_at"], "guide review_due_at")
        require(checked <= now.date(), "future source check")
        require((now.date() - checked).days <= 45, "source check older than 45 days")
        require(due >= checked and due >= now.date(), "source review overdue")
        require(guide["approval_status"] == "approved", "source approval pending")
        approved = instant(guide["approved_at"], "source approved_at")
        require(checked <= approved.date() <= now.date() and approved <= now, "invalid source approval date")
    exact_keys(payment, ["schema_version", "mode", "id", "order_id", "status", "amount_minor", "currency",
                         "refund_status", "refunded_amount_minor", "reference", "checked_at", "method", "reviewed_by"], "payment")
    require(payment["schema_version"] == 1 and type(payment["schema_version"]) is int, "unsupported payment schema")
    require(payment["mode"] == order["mode"], "payment environment mismatch")
    require(payment["order_id"] == order["id"], "payment order mismatch")
    require(payment["status"] == "confirmed_charge", "charge not confirmed")
    require(payment["method"] in ["manual_provider_charge_readback", "stripe_test_api_readback"], "unsupported evidence method")
    require(payment["method"] != "stripe_test_api_readback" or payment["mode"] == "sandbox", "API bridge is sandbox only")
    for field in ["id", "reference", "reviewed_by"]:
        text(payment[field], f"payment {field}")
    integer(payment["amount_minor"], "payment amount", 1)
    integer(payment["refunded_amount_minor"], "refund amount")
    require(payment["amount_minor"] == order["amount_minor"] and payment["currency"] == order["currency"],
            "payment amount or currency mismatch")
    require(payment["refund_status"] == "none_confirmed" and payment["refunded_amount_minor"] == 0,
            "refund or unknown refund status blocks preparation")
    checked = instant(payment["checked_at"], "payment checked_at")
    require(timedelta(0) <= now - checked <= timedelta(hours=24), "payment readback missing, future or older than 24 hours")
    return order, payment


COPY = {
    "en": {"title": "Your orientation pack", "sandbox": "SANDBOX — synthetic order; no real payment or delivery",
           "scope": "90-day support period", "links": "Selected starting points", "checked": "Source checked",
           "due": "Review this copy by", "contact": "Contact", "note": "This pack organizes links to responsible sources. Essential guidance remains free. It does not provide individual legal, medical, immigration or tax advice.",
           "service": "The agreed service includes manual source maintenance, one client revision round and a final summary of work performed. Usage, employee outcomes and ROI are not measured by this pack.",
           "offline": "This is a dated copy. After a source review date or the support period ends, confirm current information with the responsible source. Downloaded copies cannot be remotely recalled.",
           "local": "Prepared locally; sending this file and client acceptance are separate actions."},
    "nl": {"title": "Uw oriëntatiepakket", "sandbox": "SANDBOX — fictieve opdracht; geen echte betaling of levering",
           "scope": "Ondersteuning gedurende 90 dagen", "links": "Geselecteerde startpunten", "checked": "Bron gecontroleerd",
           "due": "Controleer deze kopie uiterlijk op", "contact": "Contact", "note": "Dit pakket ordent links naar verantwoordelijke bronnen. Essentiële informatie blijft gratis. Het bevat geen persoonlijk juridisch, medisch, immigratie- of belastingadvies.",
           "service": "De afgesproken dienst omvat handmatig brononderhoud, één correctieronde voor de klant en een eindoverzicht van het uitgevoerde werk. Gebruik, resultaten voor werknemers en ROI worden met dit pakket niet gemeten.",
           "offline": "Dit is een gedateerde kopie. Controleer actuele informatie bij de verantwoordelijke bron zodra een controledatum of de ondersteuningsperiode is verstreken. Gedownloade kopieën kunnen niet op afstand worden ingetrokken.",
           "local": "Lokaal voorbereid; verzending en acceptatie door de klant zijn afzonderlijke handelingen."},
    "ru": {"title": "Ваш пакет для первых шагов", "sandbox": "SANDBOX — вымышленный заказ; реальной оплаты и передачи нет",
           "scope": "90 дней сопровождения", "links": "Выбранные отправные точки", "checked": "Источник проверен",
           "due": "Перепроверить копию до", "contact": "Контакт", "note": "Пакет упорядочивает ссылки на ответственные источники. Основные инструкции остаются бесплатными. Индивидуальные юридические, медицинские, миграционные и налоговые консультации не предоставляются.",
           "service": "Услуга включает ручную проверку источников, один раунд правок клиента и итоговое описание выполненной работы. Пакет не измеряет использование, результаты сотрудников или ROI.",
           "offline": "Это копия на указанную дату. После срока пересмотра источника или окончания сопровождения уточняйте актуальную информацию у ответственного источника. Скачанную копию невозможно отозвать удалённо.",
           "local": "Подготовлено локально; отправка файла и приёмка клиентом — отдельные действия."},
}


def render(order, historical_replay=False):
    c = COPY[order["language"]]
    e = html.escape
    cards = "".join(f'<li><h2><a href="{e(g["url"], quote=True)}" rel="noreferrer">{e(g["title"])}</a></h2>'
                    f'<p>{e(g["publisher"])}</p><p class="meta">{c["checked"]}: {g["checked_at"]} · '
                    f'{c["due"]}: {min(day(g["review_due_at"], "review due"), day(g["checked_at"], "checked") + timedelta(days=45), day(order["end_date"], "end"))}</p></li>' for g in order["guides"])
    banner = f'<aside class="sandbox">{c["sandbox"]}</aside>' if order["mode"] == "sandbox" else ""
    if historical_replay:
        banner += '<aside class="sandbox">HISTORICAL SANDBOX REPLAY — not the current payment state</aside>'
    return f'''<!doctype html>
<html lang="{order['language']}"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'">
<meta name="robots" content="noindex,nofollow"><title>YouNew — {e(c['title'])}</title>
<style>*{{box-sizing:border-box}}body{{margin:0 auto;padding:32px 20px;max-width:850px;font:17px/1.55 system-ui,sans-serif;color:#102852;background:#fff}}h1{{font-size:2.15rem;line-height:1.15}}h2{{font-size:1.25rem}}a{{color:#164aa5;overflow-wrap:anywhere}}header{{border-bottom:3px solid #164aa5}}.brand{{font-weight:800;font-size:1.5rem}}.meta,footer{{font-size:.9rem}}li{{padding:12px 0;border-bottom:1px solid #b6c3d9}}ol{{padding-left:24px}}aside{{padding:14px 18px;background:#edf3ff}}.sandbox{{border:2px solid #894d00;background:#fff1d8;color:#593000;font-weight:700}}footer{{margin-top:32px}}@media print{{body{{max-width:none;padding:0;font-size:11pt}}a::after{{content:' (' attr(href) ')';font-size:9pt;font-weight:400}}li,aside{{break-inside:avoid}}header{{break-after:avoid}}}}</style></head>
<body>{banner}<header><p class="brand">YouNew</p><h1>{e(c['title'])}</h1><p>{e(order['organization'])} · {e(order['region'])}</p>
<p>{c['scope']}: {order['start_date']} – {order['end_date']}</p></header>
<main><h2>{c['links']}</h2><ol>{cards}</ol><aside><p>{c['note']}</p><p>{c['service']}</p></aside>
<h2>{c['contact']}</h2><p>{e(order['contact']['name'])} · <a href="mailto:{quote(order['contact']['email'], safe='@.')}">{e(order['contact']['email'])}</a></p></main>
<footer><p>{c['offline']}</p><p>{c['local']}</p><p>Order: {e(order['id'])}</p></footer></body></html>
'''


def file_sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def commercial_identity(order, payment, historical_replay):
    # A fresh provider read is mandatory on every call. Observation time, reviewer
    # and evidence URL can change without changing the paid order or its content.
    return digest({"order": order, "payment": {key: payment[key] for key in
                   ["mode", "id", "order_id", "amount_minor", "currency"]},
                   "historical_replay": historical_replay})


def prepare(order, payment, output_root, now, historical_replay=False):
    require(type(historical_replay) is bool and (not historical_replay or order.get("mode") == "sandbox"), "historical replay is sandbox only")
    validate(order, payment, now)
    root = Path(output_root)
    root.mkdir(parents=True, exist_ok=True)
    require(not root.is_symlink(), "output root must not be a symlink")
    request_hash = commercial_identity(order, payment, historical_replay)
    target = root / order["id"]
    with (root / ".prepare.lock").open("a+") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if target.exists() or target.is_symlink():
            require(target.is_dir() and not target.is_symlink(), "invalid existing output")
            receipt_path = target / "PREPARATION.json"
            require(receipt_path.is_file() and not receipt_path.is_symlink(), "invalid preparation receipt")
            receipt = read_json(receipt_path)
            exact_keys(receipt, ["schema_version", "status", "request_sha256", "historical_replay", "mode", "payment_id", "prepared_at", "immutable_files", "mutable_file"], "preparation receipt")
            require(receipt["schema_version"] == 1 and type(receipt["schema_version"]) is int
                    and receipt["status"] == "prepared_not_sent" and receipt["mode"] == order["mode"]
                    and type(receipt["historical_replay"]) is bool and receipt["historical_replay"] == historical_replay
                    and receipt["payment_id"] == payment["id"] and receipt["mutable_file"] == "maintenance-journal.csv",
                    "preparation receipt metadata mismatch")
            exact_keys(receipt["immutable_files"], ["pack.html", "ledger-entry.json", "approved-inputs.json"], "immutable file inventory")
            for name, sha in receipt["immutable_files"].items():
                f = target / name
                require(f.is_file() and not f.is_symlink() and file_sha(f) == sha, "prepared artifact integrity mismatch")
            original = read_json(target / "approved-inputs.json")
            # Supports old receipts without rewriting their immutable audit trail.
            original_hash = digest({"order": original["order"], "payment": original["payment"],
                                    "historical_replay": historical_replay})
            require(receipt["request_sha256"] in [original_hash,
                    commercial_identity(original["order"], original["payment"], historical_replay)],
                    "preparation receipt identity mismatch")
            require(commercial_identity(original["order"], original["payment"], historical_replay) == request_hash,
                    "order id already used with different inputs")
            return {"status": "already_prepared", "directory": str(target), "request_sha256": request_hash}
        # One provider payment cannot prepare two different orders.
        for previous in root.glob("*/PREPARATION.json"):
            require(not previous.is_symlink() and not previous.parent.is_symlink(), "invalid prior output")
            old = json.loads(previous.read_text())
            require((old["mode"], old["payment_id"]) != (payment["mode"], payment["id"]), "payment id already allocated")
        temp = Path(tempfile.mkdtemp(prefix=".preparing-", dir=root))
        try:
            (temp / "pack.html").write_text(render(order, historical_replay))
            # Mutable human work log: never claim that preparation is delivery.
            log = io.StringIO(newline="")
            csv.writer(log).writerow(["performed_at_utc", "action", "guide_id", "source_or_delivery_reference", "support_minutes", "direct_cost_minor", "currency", "reviewed_by", "outcome"])
            (temp / "maintenance-journal.csv").write_text(log.getvalue())
            ledger = {"schema_version": 1, "order_id": order["id"], "mode": order["mode"],
                      "financial_classification": "sandbox_test" if order["mode"] == "sandbox" else "manual_charge_readback",
                      "payment_id": payment["id"], "payment_reference": payment["reference"],
                      "payment_checked_at": payment["checked_at"], "payment_reviewed_by": payment["reviewed_by"],
                      "provider_verified_by_cli": False, "currency": "EUR", "order_gross_minor": order["amount_minor"],
                      "payment_evidence_method": payment["method"],
                      "live_received_minor": 0 if order["mode"] == "sandbox" else None,
                      "confirmed_gross_charge_minor": payment["amount_minor"],
                      "revenue_ex_vat_minor": None, "vat_minor": None, "fees_minor": None,
                      "support_cost_minor": None, "operating_result_minor": None,
                      "recurring": False, "mrr_minor": 0, "delivery_status": "prepared_not_sent",
                      "delivery_reference": None, "client_acceptance_reference": None,
                      "agreement_reference": order["agreement"]["reference"], "start_date": order["start_date"], "end_date": order["end_date"],
                      "note": "Manual charge evidence only; no provider authentication or bank settlement verification. Live cash, unknown costs and tax are null, not zero. Subsequent refunds require reconciliation; offline copies cannot be recalled."}
            (temp / "ledger-entry.json").write_text(json.dumps(ledger, ensure_ascii=False, indent=2) + "\n")
            (temp / "approved-inputs.json").write_text(json.dumps({"order": order, "payment": payment}, ensure_ascii=False, indent=2) + "\n")
            receipt = {"schema_version": 1, "status": "prepared_not_sent", "request_sha256": request_hash,
                       "historical_replay": historical_replay,
                       "mode": order["mode"], "payment_id": payment["id"], "prepared_at": now.isoformat(),
                       "immutable_files": {name: file_sha(temp / name) for name in ["pack.html", "ledger-entry.json", "approved-inputs.json"]},
                       "mutable_file": "maintenance-journal.csv"}
            (temp / "PREPARATION.json").write_text(json.dumps(receipt, indent=2) + "\n")
            os.rename(temp, target)
        except BaseException:
            shutil.rmtree(temp)
            raise
    return {"status": "prepared_not_sent", "directory": str(target), "request_sha256": request_hash}


def read_json(path):
    def pairs(items):
        result = {}
        for key, value in items:
            require(key not in result, "duplicate JSON key")
            result[key] = value
        return result
    return json.loads(Path(path).read_text(), object_pairs_hook=pairs)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--order", required=True)
    parser.add_argument("--payment", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--test-now", help="Fixed UTC clock for sandbox fixtures only")
    args = parser.parse_args()
    try:
        order, payment = read_json(args.order), read_json(args.payment)
        require(not args.test_now or order.get("mode") == payment.get("mode") == "sandbox", "clock override is sandbox only")
        now = instant(args.test_now, "test clock") if args.test_now else datetime.now(timezone.utc)
        print(json.dumps(prepare(order, payment, args.output, now, historical_replay=bool(args.test_now))))
    except (GateError, ValueError, KeyError, TypeError, OSError) as exc:
        parser.exit(2, f"NOT PREPARED: {exc}\n")


if __name__ == "__main__":
    main()
