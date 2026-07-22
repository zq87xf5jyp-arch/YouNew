#!/usr/bin/env python3
"""Check app links plus effective Data Project release heads."""

import argparse
import csv
import datetime
import json
import re
import ssl
import sys
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from effective_release import (
    EffectiveReleaseError,
    effective_release_heads,
    resolve_release,
)


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "DataProject"
URL = re.compile(r'https?://[^\s"<>\\]+')
INCOMPLETE_URL_SUFFIXES = ("/wiki/File:", "/wiki/Special:FilePath/")
NON_DEREFERENCEABLE_IDENTIFIERS = {
    # JSON Schema $id / runtime schema fingerprints, not user-facing links.
    "https://younew.nl/schemas/data-project/entity.schema.json",
    "https://younew.nl/schemas/data-project/effective-release-overlay.schema.json",
}
GENERATED_RUNTIME = ROOT / "YouNew" / "Resources" / "Data" / "younew-runtime-data.json"
SOURCE_REGISTRY = ROOT / "source_registry.json"
PUBLISHED_WEB_ARTIFACTS = (
    ROOT / "admin-dashboard" / "public-site" / "src" / "generated" / "public-content.json",
    ROOT / "admin-dashboard" / "public-site" / "public" / "data" / "search-index.json",
    ROOT / "admin-dashboard" / "public-site" / "public" / "data" / "content-provenance.json",
)
RESTRICTED_STATUSES = {401, 403, 429}


def add_urls(urls, text, location):
    for match in URL.finditer(text):
        url = match.group(0).rstrip(".,;)]")
        if url.endswith(INCOMPLETE_URL_SUFFIXES) or url in NON_DEREFERENCEABLE_IDENTIFIERS:
            continue
        urls.setdefault(url, location)


def strings_in(value, path=""):
    if isinstance(value, str):
        yield path, value
    elif isinstance(value, list):
        for index, item in enumerate(value):
            yield from strings_in(item, f"{path}[{index}]")
    elif isinstance(value, dict):
        for key, item in value.items():
            child = f"{path}.{key}" if path else key
            yield from strings_in(item, child)


def scan_path(urls, path):
    if not path.is_file():
        return
    text = path.read_text(encoding="utf-8", errors="ignore")
    for match in URL.finditer(text):
        line = text.count("\n", 0, match.start()) + 1
        add_urls(urls, match.group(0), f"{path.relative_to(ROOT)}:{line}")


def collect_urls(release_id=None):
    urls = {}
    # Resolve governed records first so a URL duplicated in generated runtime or
    # web artifacts keeps its stable effective-release source ID in reports.
    release_ids = [release_id] if release_id else effective_release_heads(PROJECT)
    for effective_id in release_ids:
        effective = resolve_release(PROJECT, effective_id)
        for record in effective.records:
            location = f"effective-release:{effective_id}:{record['id']}"
            official_url = (record.get("official_source") or {}).get("url")
            if isinstance(official_url, str):
                add_urls(urls, official_url, f"{location}:official_source.url")
            for field_path, value in strings_in(record):
                add_urls(urls, value, f"{location}:{field_path}")

    app_root = ROOT / "YouNew"
    if app_root.exists():
        for path in app_root.rglob("*"):
            if path.suffix not in {".swift", ".json", ".strings", ".plist"}:
                continue
            # An explicit candidate check validates the candidate rather than a
            # previously shipped runtime. Nightly production mode must scan it.
            if release_id and path == GENERATED_RUNTIME:
                continue
            scan_path(urls, path)

    scan_path(urls, SOURCE_REGISTRY)
    if not release_id:
        for path in PUBLISHED_WEB_ARTIFACTS:
            scan_path(urls, path)
    return urls, release_ids


def check(pair, context):
    url, location = pair
    request = urllib.request.Request(url, method="HEAD", headers={"User-Agent": "YouNew-QA/1.0"})
    try:
        with urllib.request.urlopen(request, timeout=10, context=context) as response:
            code = response.status
            final = response.geturl()
        return url, location, code, final, "" if code < 400 else "http_error"
    except urllib.error.HTTPError as error:
        # Some official/CDN endpoints reject HEAD while a normal browser GET is
        # valid. Retry every client error with a browser-like GET before it can
        # be classified as broken or access-restricted.
        if 400 <= error.code < 500:
            try:
                request = urllib.request.Request(url, method="GET", headers={"User-Agent": "Mozilla/5.0"})
                with urllib.request.urlopen(request, timeout=10, context=context) as response:
                    evidence = f"head_{error.code}_get_ok" if response.status < 400 else "http_error"
                    return url, location, response.status, response.geturl(), evidence
            except urllib.error.HTTPError as retry:
                return url, location, retry.code, retry.geturl(), type(retry).__name__
            except Exception as retry:
                # A failed GET transport cannot confirm the earlier HEAD status.
                # Preserve it as transient evidence for the scheduled retry.
                return url, location, "", "", type(retry).__name__
        return url, location, error.code, "", "http_error"
    except Exception as error:
        return url, location, "", "", type(error).__name__


def is_confirmed_failure(status):
    return isinstance(status, int) and 400 <= status < 500 and status not in RESTRICTED_STATUSES


def write_reports(results, release_ids):
    confirmed_failures = [result for result in results if is_confirmed_failure(result[2])]
    restricted = [result for result in results if result[2] in RESTRICTED_STATUSES]
    transient = [result for result in results if not isinstance(result[2], int) or result[2] >= 500]
    failures = confirmed_failures + restricted + transient
    with (ROOT / "broken_links.csv").open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["severity", "screen", "steps_to_reproduce", "expected_behavior", "actual_behavior", "proposed_fix", "url", "http_status", "final_url", "evidence"])
        for url, location, status, final, evidence in sorted(failures):
            severity = "high" if is_confirmed_failure(status) else "low" if status in RESTRICTED_STATUSES else "medium"
            proposed_fix = "Replace or re-verify URL" if severity == "high" else "Retry in scheduled QA; keep an in-app failure state"
            writer.writerow([severity, location, f"Open external link {url}", "Official source opens successfully", f"HTTP {status or 'no response'} ({evidence})", proposed_fix, url, status, final, evidence])

    report = {
        "schemaVersion": 2,
        "checkedAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "scope": "Published effective Data Project release heads, shipped app/runtime sources, source registry, and generated public web artifacts.",
        "effectiveReleases": release_ids,
        "totalURLs": len(results),
        "reachableURLs": len(results) - len(failures),
        "confirmedBrokenURLs": len(confirmed_failures),
        "accessRestrictedURLs": len(restricted),
        "transientFailures": len(transient),
        "confirmedBroken": [
            {"url": url, "location": location, "status": status, "finalURL": final, "evidence": evidence}
            for url, location, status, final, evidence in sorted(confirmed_failures)
        ],
    }
    with (ROOT / "knowledge_data_health.json").open("w", encoding="utf-8") as handle:
        json.dump(report, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
    return confirmed_failures, restricted, transient


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--release", help="check one exact effective Data Release ID")
    return parser.parse_args()


def main():
    args = parse_args()
    try:
        urls, release_ids = collect_urls(args.release)
    except EffectiveReleaseError as error:
        print(f"External link check failed before network access: {error}", file=sys.stderr)
        return 1
    context = ssl.create_default_context()
    with ThreadPoolExecutor(max_workers=16) as pool:
        results = list(pool.map(lambda pair: check(pair, context), urls.items()))
    confirmed, restricted, transient = write_reports(results, release_ids)
    print(
        f"checked={len(results)} confirmed_broken={len(confirmed)} "
        f"restricted={len(restricted)} transient={len(transient)}"
    )
    network_unavailable = bool(results) and len(transient) == len(results)
    if network_unavailable:
        print("external link check failed closed: every request was transient", file=sys.stderr)
    return 1 if confirmed or network_unavailable else 0


if __name__ == "__main__":
    raise SystemExit(main())
