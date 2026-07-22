#!/usr/bin/env python3
"""Refresh bundled city symbols from their exact Wikimedia Commons originals.

The script accepts only files whose current Commons metadata reports Public
domain or CC0. It writes the original response bytes into the matching Xcode
imageset, verifies Wikimedia's SHA-1, and emits a machine-readable provenance
snapshot used by the release rights ledger.
"""

from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
import time
import urllib.parse
import urllib.request
from urllib.error import HTTPError
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "YouNew" / "Assets.xcassets"
SNAPSHOT = ROOT / "BuildWeekFix" / "CITY_SYMBOL_RIGHTS.json"
API = "https://commons.wikimedia.org/w/api.php"
USER_AGENT = "YouNewMediaRightsAudit/1.0 (https://github.com/zq87xf5jyp-arch/YouNew)"
ALLOWED_LICENSES = {"Public domain", "CC0"}


CITY_SYMBOLS = {
    "city_amsterdam_flag": "Flag of Amsterdam.svg",
    "city_amsterdam_coat_of_arms": "Wapen van Amsterdam.svg",
    "city_haarlem_flag": "Flag Haarlem.svg",
    "city_haarlem_coat_of_arms": "Wapen Haarlem.svg",
    "city_alkmaar_flag": "Alkmaar Flag.svg",
    "city_alkmaar_coat_of_arms": "Alkmaar wapen.svg",
    "city_hoorn_flag": "Flag of Hoorn.svg",
    "city_hoorn_coat_of_arms": "Hoorn wapen.svg",
    "city_zaanstad_flag": "Flag of Zaanstad.svg",
    "city_zaanstad_coat_of_arms": "Coat of arms of Zaanstad.svg",
    "city_amstelveen_flag": "Amstelveen vlag.svg",
    "city_amstelveen_coat_of_arms": "Coat of arms of Amstelveen.svg",
    "city_purmerend_flag": "Flag of Purmerend.svg",
    "city_purmerend_coat_of_arms": "Purmerend wapen.svg",
    "city_heerhugowaard_flag": "Flag of Heerhugowaard.svg",
    "city_heerhugowaard_coat_of_arms": "Heerhugowaard wapen.svg",
    "city_rotterdam_flag": "Flag of Rotterdam.svg",
    "city_rotterdam_coat_of_arms": "Rotterdam wapen.svg",
    "city_den_haag_flag": "Flag of The Hague.svg",
    "city_den_haag_coat_of_arms": "Den Haag wapen.svg",
    "city_leiden_flag": "Flag of Leiden.svg",
    "city_leiden_coat_of_arms": "Leiden wapen HRvA.svg",
    "city_delft_flag": "Flag of Delft.svg",
    "city_delft_coat_of_arms": "Coat of arms of Delft.svg",
    "city_utrecht_flag": "Flag of Utrecht city.svg",
    "city_utrecht_coat_of_arms": "Utrecht gemeente wapen.svg",
    "city_amersfoort_flag": "Amersfoort vlag.svg",
    "city_amersfoort_coat_of_arms": "Amersfoort wapen.svg",
    "city_arnhem_flag": "VlagArnhem.svg",
    "city_arnhem_coat_of_arms": "Coat of arms of Arnhem.svg",
    "city_nijmegen_flag": "Flag of Nijmegen.svg",
    "city_nijmegen_coat_of_arms": "Coat of arms of Nijmegen.svg",
    "city_eindhoven_flag": "Flag of Eindhoven.svg",
    "city_eindhoven_coat_of_arms": "Eindhoven wapen.svg",
    "city_tilburg_flag": "Flag of Tilburg.svg",
    "city_tilburg_coat_of_arms": "Tilburg wapen 1817.svg",
    "city_breda_flag": "Flag of Breda.svg",
    "city_breda_coat_of_arms": "Breda wapen.svg",
    "city_s_hertogenbosch_flag": "Flag of 's-Hertogenbosch.svg",
    "city_s_hertogenbosch_coat_of_arms": "S-Hertogenbosch wapen.svg",
    "city_maastricht_flag": "Flag of Maastricht.svg",
    "city_maastricht_coat_of_arms": "Wapen van Maastricht.svg",
    "city_venlo_flag": "Venlo vlag.svg",
    "city_venlo_coat_of_arms": "Coat of arms of Venlo.svg",
    "city_zwolle_flag": "Flag of Zwolle.svg",
    "city_zwolle_coat_of_arms": "Coat of arms of Zwolle.svg",
    "city_almere_flag": "Almere vlag.svg",
    "city_almere_coat_of_arms": "Almere wapen.svg",
    "city_lelystad_flag": "Flag of Lelystad.svg",
    "city_lelystad_coat_of_arms": "Lelystad wapen.svg",
    "city_groningen_flag": "Flag Groningen city.svg",
    "city_groningen_coat_of_arms": "Groningen stad wapen.svg",
    "city_leeuwarden_flag": "Flag of Leeuwarden.svg",
    "city_leeuwarden_coat_of_arms": "Coat of arms of Leeuwarden.svg",
    "city_assen_flag": "Flag of Assen.svg",
    "city_assen_coat_of_arms": "Assen wapen.svg",
    "city_middelburg_flag": "Middelburg vlag.svg",
    "city_middelburg_coat_of_arms": "Coat of arms of Middelburg.svg",
}


def open_with_retry(request: urllib.request.Request, timeout: int) -> bytes:
    for attempt in range(8):
        try:
            with urllib.request.urlopen(request, timeout=timeout) as response:
                return response.read()
        except HTTPError as error:
            if error.code != 429 or attempt == 7:
                raise
            retry_after = error.headers.get("Retry-After")
            delay = int(retry_after) if retry_after and retry_after.isdigit() else min(60, 5 * (2**attempt))
            print(f"Wikimedia rate limit; retrying in {delay}s")
            time.sleep(delay)
    raise RuntimeError("unreachable retry state")


def request_json(parameters: dict[str, str]) -> dict:
    url = f"{API}?{urllib.parse.urlencode(parameters)}"
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    return json.loads(open_with_retry(request, timeout=30))


def request_bytes(url: str) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    return open_with_retry(request, timeout=60)


def plain_text(value: str | None) -> str:
    if not value:
        return "Unknown creator"
    without_tags = re.sub(r"<[^>]+>", "", value)
    return " ".join(html.unescape(without_tags).split())


def commons_page(title: str) -> str:
    path = urllib.parse.quote(title.replace(" ", "_"), safe="()_',-.~")
    return f"https://commons.wikimedia.org/wiki/File:{path}"


def metadata_for(file_name: str) -> dict:
    payload = request_json(
        {
            "action": "query",
            "format": "json",
            "redirects": "1",
            "prop": "imageinfo",
            "iiprop": "url|extmetadata|sha1|size|mime",
            "titles": f"File:{file_name}",
        }
    )
    page = next(iter(payload["query"]["pages"].values()))
    if "missing" in page or not page.get("imageinfo"):
        raise RuntimeError(f"Commons file is missing: {file_name}")

    info = page["imageinfo"][0]
    ext = info.get("extmetadata", {})
    license_name = ext.get("LicenseShortName", {}).get("value")
    if license_name not in ALLOWED_LICENSES:
        raise RuntimeError(f"Unsupported license for {file_name}: {license_name}")

    canonical_title = page["title"].removeprefix("File:")
    return {
        "canonicalTitle": canonical_title,
        "sourcePageURL": commons_page(canonical_title),
        "originalFileURL": info["url"],
        "creator": plain_text(ext.get("Artist", {}).get("value")),
        "licenseName": license_name,
        "licenseURL": ext.get("LicenseUrl", {}).get("value") or "https://creativecommons.org/publicdomain/mark/1.0/",
        "commonsSHA1": info["sha1"],
        "mimeType": info.get("mime"),
        "width": info.get("width"),
        "height": info.get("height"),
    }


def write_asset(asset_id: str, metadata: dict) -> dict:
    directory = CATALOG / f"{asset_id}.imageset"
    target = directory / f"{asset_id}.svg"
    if target.is_file() and hashlib.sha1(target.read_bytes()).hexdigest() == metadata["commonsSHA1"]:  # noqa: S324
        data = target.read_bytes()
    else:
        data = request_bytes(metadata["originalFileURL"])

    digest = hashlib.sha1(data).hexdigest()  # noqa: S324 - matches Commons identity.
    if digest != metadata["commonsSHA1"]:
        raise RuntimeError(
            f"Downloaded SHA-1 mismatch for {asset_id}: {digest} != {metadata['commonsSHA1']}"
        )
    if not data.lstrip().startswith(b"<svg") and b"<svg" not in data[:1024]:
        raise RuntimeError(f"Expected SVG payload for {asset_id}")

    directory.mkdir(parents=True, exist_ok=True)
    for existing in directory.iterdir():
        if existing.is_file() and existing.name not in {"Contents.json", target.name}:
            existing.unlink()
    target.write_bytes(data)
    (directory / "Contents.json").write_text(
        json.dumps(
            {
                "images": [{"filename": target.name, "idiom": "universal"}],
                "info": {"author": "xcode", "version": 1},
                "properties": {"preserves-vector-representation": True},
            },
            separators=(",", ":"),
        )
        + "\n",
        encoding="utf-8",
    )
    return {
        "assetID": asset_id,
        **metadata,
        "localPath": target.relative_to(ROOT).as_posix(),
        "localSHA1": digest,
        "retrievedAt": "2026-07-22",
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="replace catalog payloads")
    args = parser.parse_args()

    records = []
    for index, (asset_id, file_name) in enumerate(sorted(CITY_SYMBOLS.items()), start=1):
        metadata = metadata_for(file_name)
        record = write_asset(asset_id, metadata) if args.write else {"assetID": asset_id, **metadata}
        records.append(record)
        print(f"[{index:02d}/{len(CITY_SYMBOLS)}] {asset_id}: {metadata['licenseName']}")
        time.sleep(1.0)

    if args.write:
        SNAPSHOT.write_text(
            json.dumps(
                {
                    "schemaVersion": 1,
                    "generatedAt": "2026-07-22",
                    "source": "Wikimedia Commons API",
                    "records": records,
                },
                indent=2,
                ensure_ascii=False,
            )
            + "\n",
            encoding="utf-8",
        )
        print(f"Wrote {SNAPSHOT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
