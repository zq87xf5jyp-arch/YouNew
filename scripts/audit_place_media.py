#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from urllib.parse import quote, urlparse

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "YouNew" / "Views" / "ProvinceDirectoryView.swift"
REGISTRY = ROOT / "YouNew" / "Data" / "VerifiedPlaceMediaRegistry.swift"

ALLOWED_EXTENSIONS = {".svg", ".png", ".jpg", ".jpeg", ".webp"}
TRUSTED_HOST_MARKERS = ("wikimedia.org", "wikidata.org")
BLOCKED_MARKERS = (
    "ai-generated",
    "placeholder",
    "fake",
    "generated_placeholder",
    "dummy",
    "generic_shield",
    "sample_flag",
)
DEBUG_MARKERS = (
    "add licensed photo",
    "flag & coat",
    "hero photo:",
)


def normalize(value: str) -> str:
    return (
        value.lower()
        .replace("'", "")
        .replace("-", "_")
        .replace(" ", "_")
    )


def city_place_id(name: str, province: str) -> str:
    return f"nl-city-{normalize(province)}-{normalize(name)}"


def province_place_id(name: str) -> str:
    return f"nl-province-{normalize(name)}"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def find_places(catalog_text: str):
    province_ids = re.findall(r'ProvinceItem\(id:\s*"([^"]+)"', catalog_text)
    cities = re.findall(r'city\("([^"]+)",\s*"[^"]*",\s*"[^"]*",\s*"([^"]+)"', catalog_text)
    return province_ids, cities


def registry_blocks(registry_text: str):
    pattern = re.compile(r'"([^"]+)":\s*CityMedia\((.*?)(?=\n\s*\),\n\s*"|\n\s*\)\n\s*\])', re.S)
    blocks = {match.group(1): match.group(2) for match in pattern.finditer(registry_text)}
    if blocks:
        return blocks

    factory_pattern = re.compile(
        r'(?:cityMedia|provinceMedia)\("([^"]+)",\s*hero:\s*(nil|"[^"]+"),\s*flag:\s*(nil|"[^"]+"),\s*coat:\s*(nil|"[^"]+"),',
        re.S
    )
    return {
        match.group(1): f'hero: {match.group(2)}, flag: {match.group(3)}, coat: {match.group(4)}'
        for match in factory_pattern.finditer(registry_text)
    }


def asset_urls(block: str):
    urls = re.findall(r'url:\s*"([^"]+)"', block)
    if urls:
        return urls

    filenames = re.findall(r'(?:hero|flag|coat):\s*"([^"]+)"', block)
    return [
        f"https://commons.wikimedia.org/wiki/Special:FilePath/{quote(filename)}?width=1600"
        for filename in filenames
    ]


def has_asset(block: str, slot: str) -> bool:
    if re.search(rf'{slot}:\s*CityMediaAsset\(', block) is not None:
        return True

    factory_slot = {
        "heroImage": "hero",
        "flag": "flag",
        "coatOfArms": "coat",
    }.get(slot, slot)
    return re.search(rf'{factory_slot}:\s*"[^"]+"', block) is not None


def validate_url(place_id: str, url: str):
    problems = []
    parsed = urlparse(url)
    lower = url.lower()
    suffix = Path(parsed.path).suffix.lower()

    if parsed.scheme not in {"https", "http"} or not parsed.netloc:
        problems.append(f"{place_id}: invalid URL {url}")
    if suffix not in ALLOWED_EXTENSIONS:
        problems.append(f"{place_id}: unsupported file type {url}")
    if not any(marker in parsed.netloc.lower() for marker in TRUSTED_HOST_MARKERS):
        problems.append(f"{place_id}: untrusted remote host {parsed.netloc}")
    if any(marker in lower for marker in BLOCKED_MARKERS):
        problems.append(f"{place_id}: blocked placeholder/generated marker in {url}")

    return problems


def production_text_files():
    for base in (ROOT / "YouNew").rglob("*"):
        if base.is_file() and base.suffix in {".swift", ".strings", ".json"}:
            yield base


def main() -> int:
    catalog_text = read(CATALOG)
    registry_text = read(REGISTRY)
    province_ids, cities = find_places(catalog_text)
    blocks = registry_blocks(registry_text)
    if not blocks:
        errors = ["Verified place media registry parser found zero entries"]
    else:
        errors = []

    expected_city_ids = {city_place_id(name, province) for name, province in cities}
    expected_province_ids = {province_place_id(province) for province in province_ids}
    expected_ids = expected_city_ids | expected_province_ids

    urls_by_place = {place_id: asset_urls(block) for place_id, block in blocks.items()}
    all_urls = [url for urls in urls_by_place.values() for url in urls]
    duplicate_urls = sorted({url for url in all_urls if all_urls.count(url) > 1})

    warnings = []

    for place_id, urls in urls_by_place.items():
        for url in urls:
            errors.extend(validate_url(place_id, url))

    for place_id, block in blocks.items():
        factory_backed = 'commonsAsset(' in registry_text and re.search(r'(?:hero|flag|coat):\s*(nil|"[^"]+")', block)
        if not factory_backed and not re.search(r'sourceType:\s*\.(official|wikimedia|wikidata|local|otherVerified)', block):
            errors.append(f"{place_id}: verified media is missing a trusted sourceType")
        if not factory_backed and "verified: true" in block and not re.search(r'(license|attribution):\s*"[^"]+"', block):
            errors.append(f"{place_id}: verified media is missing license/attribution metadata")

    if duplicate_urls:
        errors.extend(f"duplicate verified media URL reused: {url}" for url in duplicate_urls)

    for path in production_text_files():
        text = read(path).lower()
        for marker in DEBUG_MARKERS:
            if marker in text:
                errors.append(f"{path.relative_to(ROOT)} contains production debug marker: {marker}")

    missing_hero = [place_id for place_id in sorted(expected_ids) if not has_asset(blocks.get(place_id, ""), "heroImage")]
    missing_flag = [place_id for place_id in sorted(expected_ids) if not has_asset(blocks.get(place_id, ""), "flag")]
    missing_coat = [place_id for place_id in sorted(expected_ids) if not has_asset(blocks.get(place_id, ""), "coatOfArms")]
    orphan_registry = sorted(set(blocks) - expected_ids)

    warnings.extend(f"orphan registry entry not present in catalog: {place_id}" for place_id in orphan_registry)

    schema_match = re.search(r"mediaSchemaVersion\s*=\s*(\d+)", registry_text)
    schema_version = schema_match.group(1) if schema_match else "unknown"

    print("Place media audit")
    print(f"- mediaSchemaVersion: {schema_version}")
    print(f"- provinces in catalog: {len(province_ids)}")
    print(f"- cities in catalog: {len(cities)}")
    print(f"- registry entries: {len(blocks)}")
    print(f"- places with hero image: {sum(has_asset(block, 'heroImage') for block in blocks.values())}")
    print(f"- places with flag: {sum(has_asset(block, 'flag') for block in blocks.values())}")
    print(f"- places with coat of arms: {sum(has_asset(block, 'coatOfArms') for block in blocks.values())}")
    print(f"- missing hero image: {len(missing_hero)}")
    print(f"- missing flag: {len(missing_flag)}")
    print(f"- missing coat of arms: {len(missing_coat)}")

    if warnings:
        print("\nWarnings:")
        for warning in warnings:
            print(f"- {warning}")

    if errors:
        print("\nErrors:")
        for error in errors:
            print(f"- {error}")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
