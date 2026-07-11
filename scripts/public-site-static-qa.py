#!/usr/bin/env python3
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
PUBLIC_SITE = ROOT / "admin-dashboard" / "public-site" / "src"


def fail(message: str) -> None:
    print(f"Public site static QA failed: {message}")
    sys.exit(1)


def read_sources() -> dict[Path, str]:
    if not PUBLIC_SITE.exists():
        fail("admin-dashboard/public-site/src is missing")

    return {
        path: path.read_text(encoding="utf-8")
        for path in sorted(PUBLIC_SITE.rglob("*"))
        if path.suffix in {".ts", ".tsx"}
    }


def main() -> int:
    sources = read_sources()
    combined = "\n".join(sources.values()).lower()

    for forbidden in [
        "placeholder links",
        "coming soon",
        "dummy link",
        "testflight while release channels are prepared",
    ]:
        if forbidden in combined:
            fail(f"forbidden unfinished public-site copy found: {forbidden}")

    for path, text in sources.items():
        relative = path.relative_to(ROOT)

        for match in re.finditer(r"const\s+\w*(?:url|link)\w*\s*=\s*['\"]#['\"]", text, re.IGNORECASE):
            fail(f"{relative}:{text.count(chr(10), 0, match.start()) + 1}: release/link constant points to #")

        for match in re.finditer(r"href=\{[^}]*\?\s*[^:}]+:\s*['\"]#['\"]", text):
            fail(f"{relative}:{text.count(chr(10), 0, match.start()) + 1}: conditional href falls back to #")

    print("Public site static QA passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
