#!/usr/bin/env python3
"""Static performance guardrails for release-critical SwiftUI code."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP_ROOT = ROOT / "YouNew"


ALLOWED_TASK_SLEEP = {
    ("YouNew/Views/AIAssistantView.swift", 192),
    ("YouNew/Views/AIAssistantView.swift", 2460),
    ("YouNew/Views/NearbyMapView.swift", 254),
    ("YouNew/Views/HomeMapComponents.swift", 305),
    ("YouNew/Views/HomeView.swift", 474),
    ("YouNew/Views/HomeView.swift", 846),
    ("YouNew/Views/HomeView.swift", 6229),
    ("YouNew/Views/SearchView.swift", 486),
    ("YouNew/ViewModels/AppStateViewModel.swift", 251),
    ("YouNew/ViewModels/SearchViewModel.swift", 267),
    ("YouNew/Views/PlacesDiscoveryView.swift", 1900),
    ("YouNew/Core/DesignSystem/Components/NLDesignSystem.swift", 1693),
}

ALLOWED_SYNC_DATA_READS = {
    ("YouNew/Core/Imaging/ImageLoader.swift", 38),
    ("YouNew/ViewModels/DocumentStore.swift", 152),
    # One-time, memory-mapped read of the bundled canonical dataset. The
    # loader has no network path and falls back safely if decoding fails.
    ("YouNew/Services/DataProjectRuntimeLoader.swift", 30),
}

ALLOWED_ASYNC_IMAGE = {
    ("YouNew/Core/Imaging/AppContentImageView.swift", 492),
    ("YouNew/Views/NetherlandsInteractiveMapView.swift", 1527),
}

ALLOWED_SCREEN_BOUNDS = {
    ("YouNew/Views/ProvinceDirectoryView.swift", 2434),
}


def swift_files() -> list[Path]:
    return sorted(APP_ROOT.rglob("*.swift"))


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def line_number(source: str, index: int) -> int:
    return source.count("\n", 0, index) + 1


def collect(pattern: str, allowed: set[tuple[str, int]], label: str, failures: list[str]) -> None:
    regex = re.compile(pattern)
    for path in swift_files():
        text = path.read_text(encoding="utf-8")
        rel = relative(path)
        for match in regex.finditer(text):
            line = line_number(text, match.start())
            if (rel, line) not in allowed:
                failures.append(f"{rel}:{line}: unexpected {label}: `{match.group(0)}`")


def require_absent(pattern: str, label: str, failures: list[str]) -> None:
    regex = re.compile(pattern)
    for path in swift_files():
        text = path.read_text(encoding="utf-8")
        rel = relative(path)
        for match in regex.finditer(text):
            line = line_number(text, match.start())
            failures.append(f"{rel}:{line}: forbidden {label}: `{match.group(0)}`")


def main() -> int:
    failures: list[str] = []

    require_absent(r"\bThread\.sleep\s*\(", "blocking sleep", failures)
    require_absent(r"\bDispatchQueue\.main\.sync\s*\{", "main-thread synchronous dispatch", failures)
    require_absent(r"\btry!", "force try", failures)
    require_absent(r"\bas!\s+[A-Za-z_]", "force cast", failures)

    collect(r"\bTask\.sleep\s*\(", ALLOWED_TASK_SLEEP, "Task.sleep outside approved animation/debounce sites", failures)
    collect(r"\bData\s*\(\s*contentsOf\s*:", ALLOWED_SYNC_DATA_READS, "synchronous data read", failures)
    collect(r"\bAsyncImage\s*\(", ALLOWED_ASYNC_IMAGE, "raw AsyncImage usage", failures)
    collect(r"\bUIScreen\.main\.bounds\b", ALLOWED_SCREEN_BOUNDS, "UIScreen.main.bounds usage", failures)

    runner = (ROOT / "scripts/run-static-qa.sh").read_text(encoding="utf-8")
    if "python3 scripts/performance-static-qa.py" not in runner:
        failures.append("scripts/run-static-qa.sh: performance-static-qa.py is not wired into the release gate")

    if failures:
        print("Performance static QA failed:")
        for failure in failures:
            print(f" - {failure}")
        return 1

    print("Performance static QA passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
