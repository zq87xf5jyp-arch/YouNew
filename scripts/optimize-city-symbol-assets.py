#!/usr/bin/env python3
"""Rasterize governed city coat-of-arms SVGs for reliable Xcode compilation.

The exact Wikimedia Commons source files live outside the asset catalog under
BuildWeekFix/CitySymbolSources. This script verifies each source SHA-1, renders
the catalog PNG with macOS sips, and updates the byte-linked evidence registry.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE_PATH = ROOT / "BuildWeekFix" / "CITY_SYMBOL_RIGHTS.json"
SOURCE_DIRECTORY = ROOT / "BuildWeekFix" / "CitySymbolSources"
CATALOG = ROOT / "YouNew" / "Assets.xcassets"
SIPS_VERSION = "sips-316"
MAX_PIXEL_DIMENSION = 1024


def sha1(path: Path) -> str:
    digest = hashlib.sha1()  # noqa: S324 - Commons revision identity uses SHA-1.
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def sips_dimensions(path: Path) -> tuple[int, int]:
    result = subprocess.run(
        ["sips", "-g", "pixelWidth", "-g", "pixelHeight", str(path)],
        check=True,
        capture_output=True,
        text=True,
    )
    values: dict[str, int] = {}
    for line in result.stdout.splitlines():
        key, separator, value = line.strip().partition(":")
        if separator and key in {"pixelWidth", "pixelHeight"}:
            values[key] = int(value.strip())
    return values["pixelWidth"], values["pixelHeight"]


def render(source: Path, output: Path) -> None:
    subprocess.run(
        ["sips", "-s", "format", "png", str(source), "--out", str(output)],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["sips", "-Z", str(MAX_PIXEL_DIMENSION), str(output)],
        check=True,
        capture_output=True,
        text=True,
    )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Render city-symbol PNGs and update their evidence SHA-1 values."
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Validate the existing outputs and evidence without writing files.",
    )
    args = parser.parse_args()

    actual_sips_version = subprocess.run(
        ["sips", "--version"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    if actual_sips_version != SIPS_VERSION:
        raise RuntimeError(
            f"unsupported sips version: expected {SIPS_VERSION}, got {actual_sips_version}"
        )

    payload = json.loads(EVIDENCE_PATH.read_text(encoding="utf-8"))
    records = payload.get("records")
    if not isinstance(records, list):
        raise RuntimeError("CITY_SYMBOL_RIGHTS.json has no records array")

    derived_count = 0
    for evidence in records:
        asset_id = evidence.get("assetID")
        if not isinstance(asset_id, str):
            raise RuntimeError("city-symbol evidence record has no assetID")
        source = SOURCE_DIRECTORY / f"{asset_id}.svg"
        if not source.is_file():
            continue

        source_digest = sha1(source)
        if source_digest != evidence.get("commonsSHA1"):
            raise RuntimeError(f"{asset_id}: source SVG does not match Commons SHA-1")

        output = CATALOG / f"{asset_id}.imageset" / f"{asset_id}.png"
        if not args.check:
            render(source, output)
        if not output.is_file():
            raise RuntimeError(f"{asset_id}: catalog PNG is missing")

        width, height = sips_dimensions(output)
        output_digest = sha1(output)
        expected_local_path = output.relative_to(ROOT).as_posix()
        expected_source_path = source.relative_to(ROOT).as_posix()
        derivation = {
            "kind": "rasterized_copy",
            "tool": "macOS sips",
            "toolVersion": SIPS_VERSION,
            "command": "sips -s format png SOURCE --out OUTPUT; sips -Z 1024 OUTPUT",
            "maxPixelDimension": MAX_PIXEL_DIMENSION,
            "sourceSHA1": source_digest,
            "outputSHA1": output_digest,
        }
        expected = {
            "sourceLocalPath": expected_source_path,
            "sourceLocalSHA1": source_digest,
            "localPath": expected_local_path,
            "localSHA1": output_digest,
            "localMimeType": "image/png",
            "localWidth": width,
            "localHeight": height,
            "derivation": derivation,
        }
        if args.check:
            for key, value in expected.items():
                if evidence.get(key) != value:
                    raise RuntimeError(f"{asset_id}: evidence field {key} is stale")
        else:
            evidence.update(expected)
        derived_count += 1

    if derived_count != 27:
        raise RuntimeError(f"expected 27 derived city symbols, found {derived_count}")
    if not args.check:
        EVIDENCE_PATH.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    print(f"City-symbol optimization passed: {derived_count} derived assets")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
