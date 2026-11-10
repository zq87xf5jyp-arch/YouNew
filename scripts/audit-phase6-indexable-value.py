#!/usr/bin/env python3
"""Audit every sitemap URL for technical indexability and standalone user value."""

from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
from collections import Counter, defaultdict
from datetime import date
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse
from xml.etree import ElementTree


ROOT = Path(__file__).resolve().parents[1]
PUBLIC = ROOT / "admin-dashboard" / "public-site"
OUT = PUBLIC / "out"
SITEMAP = OUT / "sitemap.xml"
REPORT_JSON = ROOT / "DataProject" / "quality" / "phase6-indexable-value-audit.json"
REPORT_MD = ROOT / "DataProject" / "quality" / "phase6-indexable-value-audit.md"
CANONICAL_ORIGIN = "https://younew.nl"
TOKEN_RE = re.compile(r"[\wÀ-ÖØ-öø-ÿ'-]+", re.UNICODE)
SPACE_RE = re.compile(r"\s+")
UNVERIFIED_MARKERS = (
    "record-level verification not established",
    "governed verification date not established",
    "confidence evidence not established",
)


class PageParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.stack: list[str] = []
        self.in_main = False
        self.skip_depth = 0
        self.main_text: list[str] = []
        self.title_text: list[str] = []
        self.h1_text: list[str] = []
        self.main_links: list[str] = []
        self.controls = 0
        self.canonical: str | None = None
        self.robots: str | None = None
        self.lang: str | None = None

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        self.stack.append(tag)
        if tag == "html":
            self.lang = values.get("lang")
        if tag == "main":
            self.in_main = True
        if tag in {"script", "style", "noscript", "svg"}:
            self.skip_depth += 1
        if tag == "link" and values.get("rel") == "canonical":
            self.canonical = values.get("href")
        if tag == "meta" and values.get("name", "").lower() == "robots":
            self.robots = values.get("content")
        if self.in_main and not self.skip_depth:
            if tag == "a" and values.get("href"):
                self.main_links.append(values["href"] or "")
            if tag in {"button", "input", "select", "textarea"}:
                self.controls += 1

    def handle_endtag(self, tag: str) -> None:
        if tag in {"script", "style", "noscript", "svg"} and self.skip_depth:
            self.skip_depth -= 1
        if tag == "main":
            self.in_main = False
        if self.stack:
            self.stack.pop()

    def handle_data(self, data: str) -> None:
        if self.skip_depth:
            return
        if self.in_main:
            self.main_text.append(data)
        if "title" in self.stack:
            self.title_text.append(data)
        if "h1" in self.stack:
            self.h1_text.append(data)


def clean(value: str) -> str:
    return SPACE_RE.sub(" ", html.unescape(value)).strip()


def tokens(value: str) -> list[str]:
    return [token.casefold() for token in TOKEN_RE.findall(value)]


def html_path(url: str) -> Path:
    path = urlparse(url).path
    if path == "/":
        return OUT / "index.html"
    return OUT / path.strip("/") / "index.html"


def route_group(url: str) -> str:
    path = urlparse(url).path.strip("/")
    return path.split("/", 1)[0] if path else "home"


def expected_canonical(url: str) -> str:
    path = urlparse(url).path
    return f"{CANONICAL_ORIGIN}{path}"


def external_links(links: list[str]) -> list[str]:
    result = []
    for link in links:
        parsed = urlparse(link)
        if parsed.scheme in {"http", "https"} and parsed.netloc not in {"younew.nl", "www.younew.nl", "127.0.0.1:4173"}:
            result.append(link)
    return result


def page_specific_checks(path: str, text: str, link_count: int, external_count: int) -> list[str]:
    reasons: list[str] = []
    is_detail = path.strip("/").count("/") == 1
    if path.startswith("/municipalities/") and is_detail:
        if not re.search(r"\bGM\d{4}\b", text) or "official settlement" not in text.casefold():
            reasons.append("municipality page lacks its administrative code or official-settlement evidence")
        if external_count == 0:
            reasons.append("municipality page has no external official action/source link")
    elif path.startswith("/provinces/") and is_detail:
        if "Complete 2026 directory" not in text or link_count < 5:
            reasons.append("province page lacks a substantial dated municipality directory")
    elif path.startswith("/categories/") and is_detail:
        if external_count == 0 and link_count < 5:
            reasons.append("category page lacks both a source action and a substantial directory")
    elif (path.startswith("/city-guides/") and is_detail) or path.startswith("/nl/stadsgidsen/"):
        if not re.search(r"2026-\d{2}-\d{2}", text) or external_count == 0:
            reasons.append("city guide lacks a visible check date or official source")
    return reasons


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--require-all-pass", action="store_true")
    args = parser.parse_args()

    root = ElementTree.parse(SITEMAP).getroot()
    namespace = {"s": "http://www.sitemaps.org/schemas/sitemap/0.9"}
    urls = [node.text for node in root.findall("s:url/s:loc", namespace) if node.text]
    pages: list[dict] = []
    shingle_docs: list[set[tuple[str, ...]]] = []

    for url in urls:
        file = html_path(url)
        record: dict = {"url": url, "path": urlparse(url).path, "group": route_group(url)}
        if not file.is_file():
            record.update({"status": "fail", "reasons": ["rendered HTML file is missing"]})
            pages.append(record)
            shingle_docs.append(set())
            continue
        source = file.read_text(encoding="utf-8")
        page = PageParser()
        page.feed(source)
        main_text = clean(" ".join(page.main_text))
        page_tokens = tokens(main_text)
        shingles = {tuple(page_tokens[index:index + 5]) for index in range(max(0, len(page_tokens) - 4))}
        links = [link for link in page.main_links if link and not link.startswith(("#", "mailto:", "tel:"))]
        externals = external_links(links)
        record.update({
            "title": clean(" ".join(page.title_text)),
            "h1": clean(" ".join(page.h1_text)),
            "lang": page.lang,
            "canonical": page.canonical,
            "robots": page.robots,
            "main_word_count": len(page_tokens),
            "main_link_count": len(links),
            "external_link_count": len(externals),
            "control_count": page.controls,
            "main_sha256": hashlib.sha256(main_text.casefold().encode()).hexdigest(),
            "unverified_marker": any(marker in main_text.casefold() for marker in UNVERIFIED_MARKERS),
            "main_text": main_text,
            "linked_paths": sorted({urlparse(link).path for link in links if urlparse(link).path.startswith("/")}),
        })
        pages.append(record)
        shingle_docs.append(shingles)

    frequencies: Counter[tuple[str, ...]] = Counter()
    for shingles in shingle_docs:
        frequencies.update(shingles)
    body_groups: defaultdict[str, list[str]] = defaultdict(list)
    for record in pages:
        if record.get("main_sha256"):
            body_groups[record["main_sha256"]].append(record["path"])
    duplicates = [paths for paths in body_groups.values() if len(paths) > 1]
    unverified_paths = {
        record["path"] for record in pages if record.get("unverified_marker")
    }

    reason_counts: Counter[str] = Counter()
    for record, shingles in zip(pages, shingle_docs):
        if record.get("status") == "fail":
            reason_counts.update(record["reasons"])
            continue
        failures: list[str] = []
        reviews: list[str] = []
        path = record["path"]
        if record["canonical"] != expected_canonical(record["url"]):
            failures.append("canonical does not match the sitemap URL")
        if not record["h1"]:
            failures.append("H1 is missing")
        if record["robots"] and "noindex" in record["robots"].casefold():
            failures.append("indexable sitemap URL declares noindex")
        if record["main_word_count"] < 25:
            failures.append("main content has fewer than 25 words")
        if any(path in group for group in duplicates):
            failures.append("main content is an exact duplicate of another indexable page")

        unique_shingles = sum(1 for shingle in shingles if frequencies[shingle] == 1)
        record["unique_five_word_shingle_ratio"] = round(unique_shingles / len(shingles), 4) if shingles else 0.0
        if record["main_word_count"] < 50 and record["control_count"] == 0 and record["main_link_count"] < 3:
            reviews.append("thin main content without an interactive task or link directory")
        if record["main_link_count"] == 0 and record["control_count"] == 0:
            reviews.append("no next action in main content")
        if len(shingles) >= 20 and record["unique_five_word_shingle_ratio"] < 0.02:
            reviews.append("main content is overwhelmingly shared template language")
        if record["unverified_marker"]:
            reviews.append("page openly lacks record-level verification evidence")
        if path.startswith("/categories/") and unverified_paths.intersection(record["linked_paths"]):
            reviews.append("category presents links to records that lack record-level verification evidence")
        reviews.extend(
            page_specific_checks(
                path,
                record["main_text"],
                record["main_link_count"],
                record["external_link_count"],
            )
        )

        record["status"] = "fail" if failures else "review" if reviews else "pass"
        record["reasons"] = failures or reviews
        reason_counts.update(record["reasons"])
        record.pop("main_text", None)
        record.pop("linked_paths", None)

    counts = Counter(record["status"] for record in pages)
    groups: dict[str, dict[str, int]] = {}
    for group in sorted({record["group"] for record in pages}):
        group_pages = [record for record in pages if record["group"] == group]
        groups[group] = {
            "total": len(group_pages),
            "pass": sum(record["status"] == "pass" for record in group_pages),
            "review": sum(record["status"] == "review" for record in group_pages),
            "fail": sum(record["status"] == "fail" for record in group_pages),
        }

    report = {
        "schema_version": 1,
        "audited_at": date.today().isoformat(),
        "artifact": "admin-dashboard/public-site/out",
        "grain": "one sitemap URL",
        "policy": {
            "pass": "technical indexability plus sufficient standalone text, action and route-specific evidence",
            "review": "page works but usefulness or record-level evidence needs human confirmation",
            "fail": "technical indexability, minimum content, canonical or exact-duplicate requirement failed",
        },
        "summary": {
            "sitemap_urls": len(urls),
            "pass": counts["pass"],
            "review": counts["review"],
            "fail": counts["fail"],
            "all_pages_independently_useful": counts["review"] == 0 and counts["fail"] == 0,
            "exact_duplicate_groups": len(duplicates),
        },
        "reason_counts": dict(reason_counts.most_common()),
        "route_groups": groups,
        "exact_duplicate_groups": duplicates,
        "pages": pages,
    }
    REPORT_JSON.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    rows = ["| Route group | Total | PASS | REVIEW | FAIL |", "|---|---:|---:|---:|---:|"]
    rows.extend(
        f"| `{group}` | {values['total']} | {values['pass']} | {values['review']} | {values['fail']} |"
        for group, values in groups.items()
    )
    review_rows = [record for record in pages if record["status"] != "pass"]
    details = ["| Status | URL | Reason |", "|---|---|---|"]
    details.extend(
        f"| {record['status'].upper()} | `{record['path']}` | {'; '.join(record['reasons'])} |"
        for record in review_rows
    )
    markdown = f"""# Phase 6 indexable-page value audit

Date: {report['audited_at']}. Grain: one URL from the generated sitemap. Input: the locally built `out/` package.

## Verdict

- Sitemap URLs: **{len(urls)}**
- PASS: **{counts['pass']}**
- REVIEW: **{counts['review']}**
- FAIL: **{counts['fail']}**
- All pages proven independently useful: **{'yes' if report['summary']['all_pages_independently_useful'] else 'no'}**
- Exact duplicate main-content groups: **{len(duplicates)}**

`REVIEW` is not called a pass. It means the route is technically usable but a human must confirm standalone value or record-level evidence before the whole sitemap can be represented as independently useful.

## Route groups

{chr(10).join(rows)}

## Pages requiring action

{chr(10).join(details) if review_rows else 'None.'}

## Method

Each sitemap URL was reconciled to a rendered HTML file and checked for matching canonical, indexability, H1, minimum main text, exact duplicate main content, actionable links/controls, five-word-shingle uniqueness and route-specific evidence. The thresholds are conservative heuristics; they detect risk but do not replace editorial review.
"""
    REPORT_MD.write_text(markdown, encoding="utf-8")
    print(json.dumps(report["summary"], ensure_ascii=False))
    if args.require_all_pass and not report["summary"]["all_pages_independently_useful"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
