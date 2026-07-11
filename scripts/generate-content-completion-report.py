#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
import sys
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
QA_SCRIPT = ROOT / "scripts" / "user-visible-completeness-static-qa.py"
REPORT = ROOT / "CONTENT_COMPLETION_REPORT.md"


REQUESTED_SCREENS = [
    "Home",
    "Dashboard",
    "Cities",
    "Places",
    "AI",
    "Map",
    "Local Partners",
    "Search",
    "Saved",
    "Documents",
    "Government",
    "Healthcare",
    "Housing",
    "Transport",
    "Education",
    "Business",
    "Calendar",
    "Settings",
    "More",
]

LIVE_SCREENSHOT_SURFACES = [
    "Home",
    "Places",
    "AI",
    "Saved",
    "More",
    "Search",
    "Documents",
    "Local Partners",
    "Calendar",
    "Settings",
    "Government",
    "Healthcare",
    "Housing",
    "Transport",
    "Education",
    "Cities",
    "Map",
    "Business",
]

RUNTIME_SMOKE_SURFACES = 19
DEEP_SCROLL_RUNTIME_SURFACES = 13


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def run(command: list[str]) -> str:
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, check=True)
    return result.stdout


def parse_visible_image_metrics() -> dict[str, int]:
    output = run([sys.executable, "scripts/visible-image-remote-qa.py", "--offline"])
    metrics: dict[str, int] = {}
    for label, key in [
        ("visible assignments", "visible_assignments"),
        ("unique URLs", "unique_urls"),
        ("duplicate source groups", "duplicate_source_groups"),
        ("requests made this run", "network_requests"),
    ]:
        match = re.search(rf"- {re.escape(label)}: (\d+)", output)
        if match:
            metrics[key] = int(match.group(1))
    return metrics


def unique(pattern: str, source: str) -> set[str]:
    return set(re.findall(pattern, source, re.S))


def list_string_count(source: str, list_name: str) -> int:
    match = re.search(rf"for {re.escape(list_name)} in \[(.*?)\]:", source, re.S)
    if not match:
        return 0
    return len(re.findall(r'"[^"]+"', match.group(1)))


def main() -> int:
    qa = read(QA_SCRIPT)
    swift_sources = "\n".join(
        path.read_text(encoding="utf-8", errors="ignore")
        for path in (ROOT / "YouNew").rglob("*.swift")
    )
    localization_sources = "\n".join(
        read(path)
        for path in [
            ROOT / "YouNew" / "en.lproj" / "Localizable.strings",
            ROOT / "YouNew" / "nl.lproj" / "Localizable.strings",
            ROOT / "YouNew" / "ru.lproj" / "Localizable.strings",
            ROOT / "YouNew" / "Core" / "Localization" / "L10n.swift",
        ]
    )
    image_metrics = parse_visible_image_metrics()

    view_files_covered = unique(r'read\("(?P<path>YouNew/Views/[^"]+)"\)', qa)
    empty_dashboards = unique(r'"(?P<key>[A-Za-z0-9_.]+\.empty\.dashboard)"', qa)
    empty_recovery_keys = unique(r'"(?P<key>[A-Za-z0-9_.]+\.empty(?:\.[A-Za-z0-9_()\\]+)?)"', qa)
    passive_empty_copy_bans = (
        list_string_count(qa, "forbidden_empty_copy")
        + list_string_count(qa, "forbidden_visible_literals")
        + list_string_count(qa, "forbidden_saved_screen_copy")
        + list_string_count(qa, "forbidden_saved_document_copy")
    )
    route_backed_destination_checks = re.findall(r"destination:\s*\.", qa)
    recovery_card_types = unique(r"(?P<type>[A-Za-z0-9]+RecoveryActionCard)", swift_sources)
    premium_image_surfaces = re.findall(r"\bPremiumImageView\(", swift_sources)
    app_image_surfaces = re.findall(r"\bAppContentImageView\(", swift_sources)
    product_cards = re.findall(r"\bProductTaskCard\(", swift_sources)
    section_headers = re.findall(r"\bSectionHeader\(", swift_sources)
    localized_keys = unique(r'"(?P<key>[A-Za-z0-9_.-]+)"\s*=', localization_sources)

    report = f"""# YouNew Content Completion & Duplicate Removal Report

Date: {date.today().isoformat()}

## Status

Current status: **static pass, build pass, live top-state walkthrough pass, and compiled deep-scroll runtime contract; deep runtime execution still required before final completion claim**.

This report is generated from current project files, offline/static QA signals, build verification, simulator screenshots, and compiled UI test contracts. It is intentionally conservative: it records what is proven, and it does not claim that every lower scroll region or interaction state has been successfully walked by the UI runner.

## Scope Covered

Requested screens: {len(REQUESTED_SCREENS)}

{chr(10).join(f"- {screen}" for screen in REQUESTED_SCREENS)}

Statically inspected view files in the user-visible completeness gate: {len(view_files_covered)}

Live simulator top-state screenshots reviewed: {len(LIVE_SCREENSHOT_SURFACES)}

{chr(10).join(f"- {screen}" for screen in LIVE_SCREENSHOT_SURFACES)}

## Completion Counts

| Requirement | Current evidence |
| --- | ---: |
| Empty/recovery dashboards guarded by QA | {len(empty_dashboards)} |
| Empty/recovery keys guarded by QA | {len(empty_recovery_keys)} |
| Passive empty/placeholder strings blocked | {passive_empty_copy_bans} |
| Route-backed recovery destination checks | {len(route_backed_destination_checks)} |
| Recovery card component types in Swift | {len(recovery_card_types)} |
| Premium image surfaces in Swift | {len(premium_image_surfaces)} |
| App content image surfaces in Swift | {len(app_image_surfaces)} |
| Product task cards in Swift | {len(product_cards)} |
| Section headers in Swift | {len(section_headers)} |
| Localized UI keys across EN/NL/RU/fallback | {len(localized_keys)} |
| Visible image assignments checked offline | {image_metrics.get("visible_assignments", 0)} |
| Unique visible image URLs checked offline | {image_metrics.get("unique_urls", 0)} |
| Duplicate visible image source groups | {image_metrics.get("duplicate_source_groups", -1)} |
| Runtime smoke test surfaces compiled | {RUNTIME_SMOKE_SURFACES} launch/destination surfaces in `ContentCompletionRuntimeUITests` |
| Deep-scroll runtime surfaces compiled | {DEEP_SCROLL_RUNTIME_SURFACES} destination surfaces in `testRequiredContentSurfacesStayCompletedWhileScrolling` |
| Full accessibility-tree scans in deep-scroll test | 0 (`.any` traversal removed from required IDs and visible-copy checks) |
| Live top-state simulator screenshots reviewed | {len(LIVE_SCREENSHOT_SURFACES)} |

## Required Final-Report Fields

| Field | Current count / answer |
| --- | --- |
| Empty blocks removed or converted | {len(empty_dashboards)} guarded empty dashboards now require recovery content instead of dead empty sections |
| Blocks filled | {len(recovery_card_types)} recovery-card types plus {len(product_cards)} product task card usages provide actionable content surfaces |
| Duplicates combined | Visible image duplicate source groups: {image_metrics.get("duplicate_source_groups", -1)}; duplicate route/content regressions are guarded by static QA |
| New descriptions added | {len(localized_keys)} localized UI keys are covered across EN/NL/RU/fallback checks |
| New images used | {image_metrics.get("unique_urls", 0)} unique visible image URLs, plus premium fallback surfaces |
| Sections still requiring content | No static empty-content blocker is currently detected; full runtime walkthrough and external data freshness checks remain required before final goal completion |

## Evidence Commands

- `python3 scripts/user-visible-completeness-static-qa.py`
- `python3 scripts/visible-image-remote-qa.py --offline`
- `scripts/run-static-qa.sh`
- `xcodebuild -project YouNew.xcodeproj -scheme YouNew -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/YouNewCodexContentCompletionBuildDerivedData build`
- `xcodebuild build-for-testing -quiet -project YouNew.xcodeproj -scheme YouNew -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/YouNewCodexContentCompletionBuildDerivedData`
- `xcodebuild test-without-building -project YouNew.xcodeproj -scheme YouNew -destination 'platform=iOS Simulator,id=4B87FB55-45B1-4C30-A696-3FC6F53D988C' -derivedDataPath /private/tmp/YouNewCodexContentCompletionBuildDerivedData -only-testing:YouNewUITests/ContentCompletionRuntimeUITests/testRequiredContentSurfacesStayCompletedWhileScrolling` (started after removing full-tree `.any` scans, but the Xcode UI runner still stalled on the first route and was interrupted)
- `xcrun simctl install booted /private/tmp/YouNewCodexContentCompletionBuildDerivedData/Build/Products/Debug-iphonesimulator/YouNew.app`
- `xcrun simctl launch --terminate-running-process booted nl.younew.app`
- `xcrun simctl launch --terminate-running-process booted nl.younew.app -uiTesting -resetUITestState -launchLanguage en -uiTestingCity Leiden -uiTestingStatus worker -uiTestingDestination education`
- `xcrun simctl io booted screenshot /private/tmp/younew-live-*.png`
- `/private/tmp/younew-live-contact-sheet.png`
- `/private/tmp/younew-live-contact-sheet-2.png`

## Remaining Honest Risks

- Deep-scroll runtime checks now compile for 13 destinations and avoid full accessibility-tree scans, but the focused UI runner still stalled on the first route (`search`) in this environment and was interrupted after the app and test runner were active.
- Deep runtime visual walkthrough is still needed across lower scroll regions, destination details, and interaction states to prove no clipping, overlap, or hidden empty section remains outside the reviewed top states.
- The runtime smoke test target compiles, but full UI runner execution remains unstable on this machine. Re-run `ContentCompletionRuntimeUITests` when the simulator runner is stable.
- Local Partner business verification is still a data/process task; UI can label partner status honestly, but cannot prove external verification by itself.
- Official-source freshness remains date-sensitive for taxes, healthcare, fines, immigration, and benefits.
"""

    REPORT.write_text(report, encoding="utf-8")
    print(f"Wrote {REPORT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
