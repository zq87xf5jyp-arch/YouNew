#!/usr/bin/env python3
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
SWIFT_ROOT = ROOT / "YouNew"


def fail(message: str) -> None:
    print(f"URL/source safety static QA failed: {message}")
    sys.exit(1)


def line_number(text: str, index: int) -> int:
    return text.count("\n", 0, index) + 1


def swift_files() -> list[Path]:
    return sorted(SWIFT_ROOT.rglob("*.swift"))


def check_dynamic_source_url_validation(path: Path, text: str, failures: list[str]) -> int:
    checked = 0
    risky_inputs = ("url", "website", "source.url", "link.urlString")
    for match in re.finditer(r"URL\(string:\s*([A-Za-z0-9_.$]+)\s*\)", text):
        argument = match.group(1)
        if argument not in risky_inputs:
            continue
        line_start = text.rfind("\n", 0, match.start()) + 1
        line_end = text.find("\n", match.end())
        if line_end == -1:
            line_end = len(text)
        line = text[line_start:line_end]
        checked += 1
        if "AppURL.validatedWebURL" not in line and "AppURL.make" not in line:
            failures.append(f"{path.relative_to(ROOT)}:{line_number(text, match.start())} validates dynamic source URL without AppURL")
    return checked


def check_direct_source_opening(path: Path, text: str, failures: list[str]) -> int:
    checked = 0
    blocked_patterns = [
        r"openURL\(source\.url\)",
        r"openURL\(answer\.officialSourceURL\)",
        r"openURL\(item\.officialSourceURL\)",
        r"openURL\(link\.url\)",
        r"openURL\(source\.officialURL\)",
    ]
    for pattern in blocked_patterns:
        for match in re.finditer(pattern, text):
            checked += 1
            failures.append(f"{path.relative_to(ROOT)}:{line_number(text, match.start())} opens source URL without AppURL validation")
    return checked


def check_source_model_assignment(path: Path, text: str, failures: list[str]) -> int:
    checked = 0
    blocked_patterns = [
        r"officialSourceURL:\s*URL\(string:\s*url\s*\)",
        r"municipalityWebsite:\s*URL\(string:\s*website\s*\)",
        r"let\s+parsedURL\s*=\s*URL\(string:\s*url\s*\)",
    ]
    for pattern in blocked_patterns:
        for match in re.finditer(pattern, text):
            checked += 1
            failures.append(f"{path.relative_to(ROOT)}:{line_number(text, match.start())} assigns dynamic source URL without AppURL validation")
    return checked


def check_maps_url_opening(path: Path, text: str, failures: list[str]) -> int:
    checked = 0
    for match in re.finditer(r'"http://maps\.apple\.com', text):
        checked += 1
        failures.append(f"{path.relative_to(ROOT)}:{line_number(text, match.start())} uses insecure Apple Maps URL")

    if path.name != "LGBTQSupportView.swift":
        return checked
    if 'URL(string: "https://maps.apple.com/?q=\\(query)")' in text:
        checked += 1
        maps_section = text.split("private func openMaps", 1)[-1].split("}\n}", 1)[0]
        if "openURL(AppURL.safeWebURL(url))" not in maps_section:
            failures.append(f"{path.relative_to(ROOT)} opens Apple Maps URL without AppURL safeWebURL guard")
    return checked


def check_dynamic_link_fallbacks(path: Path, text: str, failures: list[str]) -> int:
    checked = 0
    blocked_patterns = [
        r"Link\(destination:\s*AppURL\.make\((?:urlString|source\.urlString|\"https://\\\(province\.officialWebsite\)\")\)\)",
        r"let\s+url\s*=\s*AppURL\.make\(sourceURL\)",
        r"Link\(destination:\s*(?:topic|item|scenario)\.officialSourceURL\)",
        r"Link\(destination:\s*item\.sourceURL\)",
        r"if\s+let\s+url\s*=\s*item\.sourceURL\s*\{\s*Link\(destination:\s*url\)",
        r"Link\(destination:\s*item\.url\)",
        r"Link\(destination:\s*contact\.sourceURL\)",
        r"Link\(destination:\s*source\.url\)",
        r"Link\(destination:\s*sourceURL\)\s*\{\s*Label\(openSourceTitle",
        r"Link\(destination:\s*url\)\s*\{\s*Label\(L10n\.t\(\"resource\.open_source\"",
        r"openURL\(AppURL\.make\(\"https://www\.juridischloket\.nl\"\)\)",
    ]
    for pattern in blocked_patterns:
        for match in re.finditer(pattern, text):
            checked += 1
            failures.append(f"{path.relative_to(ROOT)}:{line_number(text, match.start())} uses an unvalidated source link destination")
    return checked


def main() -> None:
    failures: list[str] = []
    dynamic_checks = 0
    direct_open_checks = 0
    assignment_checks = 0
    maps_open_checks = 0
    dynamic_link_checks = 0

    for path in swift_files():
        text = path.read_text(encoding="utf-8", errors="ignore")
        dynamic_checks += check_dynamic_source_url_validation(path, text, failures)
        direct_open_checks += check_direct_source_opening(path, text, failures)
        assignment_checks += check_source_model_assignment(path, text, failures)
        maps_open_checks += check_maps_url_opening(path, text, failures)
        dynamic_link_checks += check_dynamic_link_fallbacks(path, text, failures)

    if failures:
        fail("; ".join(failures[:12]))

    print("URL/source safety static QA passed")
    print(f"- Dynamic source URL constructions checked: {dynamic_checks}")
    print(f"- Direct source open patterns checked: {direct_open_checks}")
    print(f"- Source URL assignments checked: {assignment_checks}")
    print(f"- Apple Maps URL opens checked: {maps_open_checks}")
    print(f"- Dynamic Link fallback patterns checked: {dynamic_link_checks}")


if __name__ == "__main__":
    main()
