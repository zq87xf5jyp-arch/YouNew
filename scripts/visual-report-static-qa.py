#!/usr/bin/env python3
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_REPORTS = {
    "IMAGE_REPLACEMENT_REPORT.md": [
        "## Executive Decision",
        "## Replacement Policy",
        "## QA Result",
        "294 visible assignments",
        "0 duplicate source groups",
        "CoreSimulatorService",
    ],
    "CITY_VISUAL_MAP.md": [
        "Hero | Landmark | Culture | Night | Thumbnail | Card",
        "Amsterdam",
        "Rotterdam",
        "Den Haag",
        "Leiden",
        "Utrecht",
        "Groningen",
        "Maastricht",
        "29 province catalog city role sets",
        "Default safe-area policy",
    ],
    "PROVINCE_VISUAL_MAP.md": [
        "Landscape | Culture | Nature | Architecture | Tourism",
        "Noord-Holland",
        "Zuid-Holland",
        "Friesland",
        "Limburg",
        "12 complete province visual role sets",
        "Default safe-area policy",
    ],
    "TOURISM_VISUAL_MAP.md": [
        "Top Attractions",
        "Museums",
        "Castles",
        "Nature",
        "Beaches",
        "Parks",
        "Historic Centres",
        "UNESCO Sites",
        "Hidden Gems",
        "Day Trips",
        "photo, location, description, why visit, and best season",
        "23 tourism catalog records",
    ],
    "DUPLICATE_IMAGE_REPORT.md": [
        "0 exact normalized source-file duplicate groups",
        "Visible source consistency",
        "Same subject title or same asset identity reused inside the city visual system: none",
        "Same subject title or same asset identity reused inside the province visual system: none",
        "Stretch-prone rendering paths",
        "Remaining Manual QA",
        "CoreSimulatorService",
    ],
}

GALLERY = ROOT / "VISUAL_AUDIT_GALLERY.html"

FORBIDDEN_STALE_CLAIMS = [
    "21 province city cards",
    "unproven due DNS failure",
    "Runtime image data QA | FAIL",
    "scripts/image-runtime-data-qa.py` still fails",
    "Not passed; culture reuse remains",
]


def fail(message: str) -> None:
    print(f"Visual report static QA failed: {message}")
    sys.exit(1)


def main() -> None:
    runner = (ROOT / "scripts" / "run-static-qa.sh").read_text(encoding="utf-8")
    for command in [
        "python3 scripts/visible-image-remote-qa.py --offline",
        "python3 scripts/image-runtime-data-qa.py",
        "python3 scripts/image-render-static-qa.py",
        "python3 scripts/generate-visual-audit-gallery.py",
        "python3 scripts/visual-report-static-qa.py",
    ]:
        if command not in runner:
            fail(f"Static QA runner missing visual-system gate: {command}")

    for report, required_fragments in REQUIRED_REPORTS.items():
        path = ROOT / report
        if not path.is_file():
            fail(f"Missing required report: {report}")
        text = path.read_text(encoding="utf-8")
        for fragment in required_fragments:
            if fragment not in text:
                fail(f"{report} missing required evidence: {fragment}")
        for stale in FORBIDDEN_STALE_CLAIMS:
            if stale in text:
                fail(f"{report} contains stale visual-system claim: {stale}")

    if not GALLERY.is_file():
        fail("Missing generated visual audit gallery: VISUAL_AUDIT_GALLERY.html")
    gallery_text = GALLERY.read_text(encoding="utf-8")
    for fragment in [
        "YouNew Visual Audit Gallery",
        "257 rendered audit cards",
        "visible-image QA covers 294 app assignments",
        "object-fit: cover",
        "Aspect fill with focal subject centered",
    ]:
        if fragment not in gallery_text:
            fail(f"VISUAL_AUDIT_GALLERY.html missing required gallery evidence: {fragment}")

    print("Visual report static QA passed")


if __name__ == "__main__":
    main()
