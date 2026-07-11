#!/usr/bin/env python3
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "ZERO_COMPROMISE_AUDIT.md"


def fail(message: str) -> None:
    print(f"Zero compromise report static QA failed: {message}")
    sys.exit(1)


def section_body(report: str, heading: str) -> str:
    marker = f"### {heading}"
    start = report.find(marker)
    if start == -1:
        fail(f"section missing: {marker}")
    body_start = report.find("\n", start)
    if body_start == -1:
        fail(f"section has no body: {marker}")
    next_heading = re.search(r"^### .+$", report[body_start + 1 :], flags=re.MULTILINE)
    if next_heading:
        return report[body_start + 1 : body_start + 1 + next_heading.start()]
    return report[body_start + 1 :]


def h2_section_body(report: str, heading: str) -> str:
    marker = f"## {heading}"
    start = report.find(marker)
    if start == -1:
        fail(f"section missing: {marker}")
    body_start = report.find("\n", start)
    if body_start == -1:
        fail(f"section has no body: {marker}")
    next_heading = re.search(r"^## .+$", report[body_start + 1 :], flags=re.MULTILINE)
    if next_heading:
        return report[body_start + 1 : body_start + 1 + next_heading.start()]
    return report[body_start + 1 :]


def require_terms(body: str, heading: str, terms: list[str]) -> None:
    lowered = body.lower()
    missing = [term for term in terms if term.lower() not in lowered]
    if missing:
        fail(f"{heading} is missing required terms: {', '.join(missing)}")


def required_field_has_content(body: str, field: str) -> bool:
    match = re.search(rf"^{re.escape(field)}\s*(.*)$", body, flags=re.MULTILINE)
    if not match:
        return False
    if match.group(1).strip():
        return True

    remainder = body[match.end() :].splitlines()
    for line in remainder:
        if line.startswith("- "):
            return False
        if line.strip():
            return True
    return False


def required_field_value(body: str, field: str) -> str:
    match = re.search(rf"^{re.escape(field)}\s*(.*)$", body, flags=re.MULTILINE)
    if not match:
        return ""
    return match.group(1).strip()


def required_field_block(body: str, field: str) -> str:
    match = re.search(rf"^{re.escape(field)}\s*(.*)$", body, flags=re.MULTILINE)
    if not match:
        return ""
    block = [match.group(1).strip()]
    for line in body[match.end() :].splitlines():
        if line.startswith("- "):
            break
        block.append(line)
    return "\n".join(block).strip()


def main() -> None:
    if not REPORT.exists():
        fail("ZERO_COMPROMISE_AUDIT.md is missing")

    report = REPORT.read_text(encoding="utf-8", errors="ignore")

    forbidden_placeholder_patterns = [
        r"\bTBD\b",
        r"\bTODO\b",
        r"\bFIXME\b",
        r"\?\?\?",
        r"\bLorem ipsum\b",
        r"\binsert details here\b",
    ]
    for pattern in forbidden_placeholder_patterns:
        if re.search(pattern, report, flags=re.IGNORECASE):
            fail(f"unresolved placeholder marker is present: {pattern}")

    forbidden_numeric_rating_patterns = [
        r"\b\d+\s*/\s*10\b",
        r"\b10\s*/\s*10\b",
        r"Final score",
        r"Performance\s*/\s*10",
        r"Stability\s*/\s*10",
        r"UX\s*/\s*10",
        r"UI\s*/\s*10",
        r"Architecture\s*/\s*10",
        r"Accessibility\s*/\s*10",
        r"App Store Readiness\s*/\s*10",
    ]
    for pattern in forbidden_numeric_rating_patterns:
        if re.search(pattern, report, flags=re.IGNORECASE):
            fail(f"numeric app rating pattern is present: {pattern}")

    required_blocker_phrases = [
        "The app is not yet provably release-ready",
        "Release gate blocked",
        "full UI suite is not green",
    ]
    for phrase in required_blocker_phrases:
        if phrase.lower() not in report.lower():
            fail(f"release blocker phrase missing: {phrase}")

    forbidden_readiness_claims = [
        r"\bthe app is release-ready\b",
        r"\bapp is release-ready\b",
        r"\bready for public release\b",
        r"\bready for App Store\b",
        r"\bApp Store ready\b",
        r"\brelease gate is closed\b",
    ]
    for pattern in forbidden_readiness_claims:
        if re.search(pattern, report, flags=re.IGNORECASE):
            fail(f"premature release-readiness claim is present: {pattern}")

    required_sections = [
        "## Performance Findings",
        "## Stability Findings",
        "## UX Findings",
        "## UI Findings",
        "## Architecture Findings",
        "## Accessibility Findings",
        "## App Store Readiness Findings",
        "## Release Test Plan",
        "### Sprint 1: Release Blockers",
        "### Sprint 2: Performance and Architecture",
        "### Sprint 3: Product Polish",
        "### Performance Blockers",
        "### Stability Blockers",
        "### UX Blockers",
        "### UI Blockers",
        "### Architecture Blockers",
        "### Accessibility Blockers",
        "### App Store Readiness Blockers",
    ]
    for section in required_sections:
        if section not in report:
            fail(f"required section missing: {section}")

    if "No numeric rating is useful until the blockers below are closed." not in report:
        fail("release gate must explicitly avoid numeric ratings")

    blocker_minimums = {
        "Performance Blockers": 8,
        "Stability Blockers": 10,
        "UX Blockers": 6,
        "UI Blockers": 5,
        "Architecture Blockers": 8,
        "Accessibility Blockers": 6,
        "App Store Readiness Blockers": 8,
    }
    for heading, minimum_count in blocker_minimums.items():
        body = section_body(report, heading)
        bullets = re.findall(r"^- .+$", body, flags=re.MULTILINE)
        if len(bullets) < minimum_count:
            fail(f"{heading} is too thin: expected at least {minimum_count} bullets, found {len(bullets)}")

    blocker_required_terms = {
        "Performance Blockers": [
            "Time Profiler",
            "Main Thread",
            "scroll",
            "Image",
            "SearchViewModel",
            "DocumentStore",
        ],
        "Stability Blockers": [
            "full UI-suite",
            "Leaks",
            "Memory Graph",
            "race",
            "offline",
            "Saved",
            "CoreSimulator",
        ],
        "UX Blockers": [
            "Home",
            "Change",
            "AI",
            "Search",
            "Saved",
            "Emergency",
            "Route",
        ],
        "UI Blockers": [
            "Cards",
            "images",
            "Canvas",
            "localization",
            "Contrast",
        ],
        "Architecture Blockers": [
            "HomeView.swift",
            "AppTabView.swift",
            "AIViewModel.swift",
            "SearchViewModel.swift",
            "MapViewModel.swift",
            "DocumentStore.swift",
            "Image",
            "Saved",
        ],
        "Accessibility Blockers": [
            "VoiceOver",
            "Dynamic Type",
            "iPhone",
            "fixed frames",
            "Canvas",
            "Contrast",
            "44x44",
        ],
        "App Store Readiness Blockers": [
            "UI-suite",
            "privacy",
            "scanner",
            "logging",
            "Offline",
            "source",
            "city",
            "audience",
            "lastChecked",
            "Localization",
        ],
    }
    for heading, terms in blocker_required_terms.items():
        require_terms(section_body(report, heading), heading, terms)

    sprint_minimums = {
        "Sprint 1: Release Blockers": 12,
        "Sprint 2: Performance and Architecture": 8,
        "Sprint 3: Product Polish": 7,
    }
    for heading, minimum_count in sprint_minimums.items():
        body = section_body(report, heading)
        bullets = re.findall(r"^- .+$", body, flags=re.MULTILINE)
        if len(bullets) < minimum_count:
            fail(f"{heading} is too thin: expected at least {minimum_count} bullets, found {len(bullets)}")

    finding_matches = list(re.finditer(r"^### ([A-Z]+[0-9]+)\. .+$", report, flags=re.MULTILINE))
    if len(finding_matches) < 45:
        fail(f"expected at least 45 findings, found {len(finding_matches)}")

    finding_ids = [match.group(1) for match in finding_matches]
    finding_id_set = set(finding_ids)
    duplicate_finding_ids = sorted({finding_id for finding_id in finding_ids if finding_ids.count(finding_id) > 1})
    if duplicate_finding_ids:
        fail(f"duplicate finding IDs are present: {', '.join(duplicate_finding_ids)}")

    for heading in blocker_minimums:
        body = section_body(report, heading)
        for bullet in re.findall(r"^- .+$", body, flags=re.MULTILINE):
            referenced_ids = re.findall(r"\b[A-Z]+[0-9]+\b", bullet)
            if not referenced_ids:
                fail(f"{heading} blocker bullet has no finding ID reference: {bullet}")
            missing_ids = [finding_id for finding_id in referenced_ids if finding_id not in finding_id_set]
            if missing_ids:
                fail(f"{heading} blocker bullet references unknown finding IDs {', '.join(missing_ids)}: {bullet}")

    for heading in sprint_minimums:
        body = section_body(report, heading)
        for bullet in re.findall(r"^- .+$", body, flags=re.MULTILINE):
            referenced_ids = re.findall(r"\b[A-Z]+[0-9]+\b", bullet)
            if not referenced_ids:
                fail(f"{heading} roadmap bullet has no finding ID reference: {bullet}")
            missing_ids = [finding_id for finding_id in referenced_ids if finding_id not in finding_id_set]
            if missing_ids:
                fail(f"{heading} roadmap bullet references unknown finding IDs {', '.join(missing_ids)}: {bullet}")

    finding_prefix_counts: dict[str, int] = {}
    for finding_id in finding_ids:
        prefix = re.match(r"[A-Z]+", finding_id)
        if prefix:
            finding_prefix_counts[prefix.group(0)] = finding_prefix_counts.get(prefix.group(0), 0) + 1

    required_finding_prefixes = {
        "P": 10,
        "S": 10,
        "U": 8,
        "UI": 5,
        "A": 8,
        "AX": 6,
        "AS": 7,
    }
    unknown_finding_prefixes = sorted(set(finding_prefix_counts) - set(required_finding_prefixes))
    if unknown_finding_prefixes:
        fail(f"unexpected finding prefixes are present: {', '.join(unknown_finding_prefixes)}")

    for prefix, minimum_count in required_finding_prefixes.items():
        actual_count = finding_prefix_counts.get(prefix, 0)
        if actual_count < minimum_count:
            fail(f"finding group {prefix} is too thin: expected at least {minimum_count}, found {actual_count}")

    section_prefixes = {
        "Performance Findings": "P",
        "Stability Findings": "S",
        "UX Findings": "U",
        "UI Findings": "UI",
        "Architecture Findings": "A",
        "Accessibility Findings": "AX",
        "App Store Readiness Findings": "AS",
    }
    allowed_finding_sections = set(section_prefixes)
    actual_finding_sections = set(re.findall(r"^## (.+ Findings)$", report, flags=re.MULTILINE))
    unexpected_finding_sections = sorted(actual_finding_sections - allowed_finding_sections)
    if unexpected_finding_sections:
        fail(f"unexpected finding sections are present: {', '.join(unexpected_finding_sections)}")

    for heading, expected_prefix in section_prefixes.items():
        body = h2_section_body(report, heading)
        section_ids = re.findall(r"^### ([A-Z]+[0-9]+)\. .+$", body, flags=re.MULTILINE)
        if not section_ids:
            fail(f"{heading} contains no findings")
        unexpected = [finding_id for finding_id in section_ids if re.match(r"[A-Z]+", finding_id).group(0) != expected_prefix]
        if unexpected:
            fail(f"{heading} contains findings from the wrong group: {', '.join(unexpected)}")

    finding_section_required_terms = {
        "Performance Findings": [
            "Main Thread",
            "scroll",
            "image",
            "Image",
            "SearchViewModel",
            "MapViewModel",
            "DocumentStore",
            "Time Profiler",
        ],
        "Stability Findings": [
            "CoreSimulator",
            "race",
            "network",
            "privacy",
            "scanner",
            "Saved",
            "UI-suite",
        ],
        "UX Findings": [
            "Home",
            "Change",
            "AI",
            "Search",
            "Saved",
            "Emergency",
            "tap",
        ],
        "UI Findings": [
            "Cards",
            "image",
            "Canvas",
            "Transport",
            "Documents",
        ],
        "Architecture Findings": [
            "HomeView.swift",
            "AppTabView.swift",
            "Image",
            "ReleasableContent",
            "DocumentOrganizerView.swift",
            "SavedItemsStore",
        ],
        "Accessibility Findings": [
            "VoiceOver",
            "Dynamic Type",
            "Contrast",
            "44",
            "iPhone",
        ],
        "App Store Readiness Findings": [
            "Instruments",
            "privacy",
            "Localization",
            "lastChecked",
            "UI",
            "scanner",
            "logging",
        ],
    }
    for heading, terms in finding_section_required_terms.items():
        require_terms(h2_section_body(report, heading), heading, terms)

    required_fields = [
        "- Screen:",
        "- File:",
        "- Component:",
        "- Evidence:",
        "- Cause:",
        "- User impact:",
        "- Criticality:",
        "- How to fix:",
        "- Example fix:",
    ]
    allowed_status_markers = [
        "confirmed",
        "candidate",
        "fixed",
        "partially fixed",
        "runtime gates pending",
    ]
    allowed_criticality_prefixes = (
        "Critical",
        "High",
        "Medium-High",
        "Medium",
        "Low",
        "Previously Critical",
        "Previously High",
    )
    concrete_evidence_pattern = re.compile(
        r"(\.swift|\.xcodeproj|\.xcresult|\.sh|line[s]?\s+`?\d|:\d|"
        r"Verification matrix|Static|Xcode pipeline|UI test target|SwiftUI view files|privacy manifest)",
        flags=re.IGNORECASE,
    )
    actionable_fix_pattern = re.compile(
        r"(```|`[^`]+`|\b(add|create|replace|move|keep|cancel|generate|show|attach|launch|wrap|make|render|decode|run|assert|introduce)\b)",
        flags=re.IGNORECASE,
    )
    fixed_proof_pattern = re.compile(
        r"(passed|succeeded|0 failures|0 failure|static qa|unit-tested|ui-tested|green|"
        r"current code|covered|asserts|executing|result: passed|now)",
        flags=re.IGNORECASE,
    )
    residual_gap_pattern = re.compile(
        r"(still|missing|not completed|not green|needs|remain|remains|without|blocked|not yet|full|runtime|broader)",
        flags=re.IGNORECASE,
    )

    for index, match in enumerate(finding_matches):
        finding_id = match.group(1)
        heading = match.group(0)
        body_start = match.end()
        body_end = finding_matches[index + 1].start() if index + 1 < len(finding_matches) else len(report)
        body = report[body_start:body_end]

        if "[" not in heading or "]" not in heading:
            fail(f"{finding_id} heading must include an evidence status marker")
        if not any(marker in heading.lower() for marker in allowed_status_markers):
            fail(f"{finding_id} heading status is not normalized: {heading}")
        status_match = re.search(r"\[([^\]]+)\]", heading)
        status_text = status_match.group(1).lower() if status_match else ""

        for field in required_fields:
            if field not in body:
                fail(f"{finding_id} missing required field {field}")
            if not required_field_has_content(body, field):
                fail(f"{finding_id} empty required field {field}")

        criticality = required_field_value(body, "- Criticality:")
        if not criticality.startswith(allowed_criticality_prefixes):
            fail(f"{finding_id} has non-normalized criticality: {criticality}")

        evidence_anchor = f"{required_field_value(body, '- File:')} {required_field_value(body, '- Evidence:')}"
        if not concrete_evidence_pattern.search(evidence_anchor):
            fail(f"{finding_id} lacks a concrete file, line, artifact, or pipeline evidence anchor")

        example_fix = required_field_block(body, "- Example fix:")
        if not actionable_fix_pattern.search(example_fix):
            fail(f"{finding_id} lacks an actionable example fix")

        if "fixed" in status_text and not fixed_proof_pattern.search(body):
            fail(f"{finding_id} has a fixed status without proof terms in its finding body")
        if "partially fixed" in status_text and not residual_gap_pattern.search(body):
            fail(f"{finding_id} has a partially fixed status without a residual gap")

    test_case_rows = re.findall(
        r"^\| ([A-Z]+[0-9]{3}) \| ([^|]+) \| ([^|]+) \| ([^|]+) \|$",
        report,
        flags=re.MULTILINE,
    )
    test_case_count = len(test_case_rows)
    if test_case_count < 100:
        fail(f"expected at least 100 release test cases, found {test_case_count}")

    test_case_ids = [row[0] for row in test_case_rows]
    duplicate_test_case_ids = sorted({test_id for test_id in test_case_ids if test_case_ids.count(test_id) > 1})
    if duplicate_test_case_ids:
        fail(f"duplicate release test case IDs are present: {', '.join(duplicate_test_case_ids)}")

    duplicate_test_texts = sorted({row[2].strip() for row in test_case_rows if [other[2].strip() for other in test_case_rows].count(row[2].strip()) > 1})
    if duplicate_test_texts:
        fail(f"duplicate release test case descriptions are present: {', '.join(duplicate_test_texts[:3])}")

    for test_id, area, test_case, required_evidence in test_case_rows:
        if not area.strip() or not test_case.strip() or not required_evidence.strip():
            fail(f"{test_id} has an empty release test plan column")
        if test_case.strip() in {"-", "n/a", "N/A"} or required_evidence.strip() in {"-", "n/a", "N/A"}:
            fail(f"{test_id} has placeholder release test plan content")

    expected_test_ranges = {
        "C": (1, 45),
        "H": (41, 80),
        "M": (81, 110),
        "P": (111, 120),
    }
    for prefix, (minimum_id, maximum_id) in expected_test_ranges.items():
        numbers = sorted(int(test_id[len(prefix) :]) for test_id in test_case_ids if test_id.startswith(prefix))
        if not numbers:
            fail(f"release test group {prefix} is missing")
        if numbers[0] != minimum_id or numbers[-1] != maximum_id:
            fail(f"release test group {prefix} has unexpected range {numbers[0]:03d}-{numbers[-1]:03d}, expected {minimum_id:03d}-{maximum_id:03d}")
        expected_numbers = list(range(minimum_id, maximum_id + 1))
        if numbers != expected_numbers:
            missing = sorted(set(expected_numbers) - set(numbers))
            extra = sorted(set(numbers) - set(expected_numbers))
            fail(f"release test group {prefix} has gaps or extras; missing={missing[:5]}, extra={extra[:5]}")

    test_case_prefix_counts: dict[str, int] = {}
    for prefix in [re.match(r"[A-Z]+", test_id).group(0) for test_id in test_case_ids]:
        test_case_prefix_counts[prefix] = test_case_prefix_counts.get(prefix, 0) + 1

    required_test_prefixes = {
        "C": 40,
        "H": 30,
        "M": 25,
        "P": 8,
    }
    for prefix, minimum_count in required_test_prefixes.items():
        actual_count = test_case_prefix_counts.get(prefix, 0)
        if actual_count < minimum_count:
            fail(f"release test group {prefix} is too thin: expected at least {minimum_count}, found {actual_count}")

    release_test_plan = h2_section_body(report, "Release Test Plan")
    require_terms(
        release_test_plan,
        "Release Test Plan",
        [
            "Clean build",
            "Typecheck",
            "Static QA",
            "Unit Tests",
            "UI Tests",
            "Time Profiler",
            "Main Thread Checker",
            "Memory Graph",
            "Leaks",
            "source",
            "cityId",
            "audience",
            "lastChecked",
            "Privacy",
            "Search",
            "Map",
            "AI Assistant",
            "Documents",
            "Offline",
            "Dynamic Type",
            "VoiceOver",
            "Contrast",
            "Visual QA",
            "Archive build",
        ],
    )

    required_public_screens = [
        "Home",
        "Dashboard",
        "Search",
        "Map",
        "AI Assistant",
        "Saved",
        "More",
        "Places",
        "Calendar",
        "Transport",
        "Emergency",
        "Documents",
        "Settings",
    ]
    screen_field_text = "\n".join(re.findall(r"^- Screen:\s*(.+)$", report, flags=re.MULTILINE))
    for screen in required_public_screens:
        if screen not in screen_field_text:
            fail(f"public screen is not covered in finding Screen fields: {screen}")

    print("Zero compromise report static QA passed")
    print(f"- findings checked: {len(finding_matches)}")
    print(f"- release test cases checked: {test_case_count}")


if __name__ == "__main__":
    main()
