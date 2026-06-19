#!/usr/bin/env python3
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message):
    print(f"Place media QA failed: {message}")
    sys.exit(1)


def read(path):
    target = ROOT / path
    if not target.is_file():
        fail(f"Missing file: {path}")
    return target.read_text(encoding="utf-8")


def expect(condition, message):
    if not condition:
        fail(message)


def main():
    registry = read("YouNew/Data/VerifiedPlaceMediaRegistry.swift")
    lower = registry.lower()

    for forbidden in ["google.com", "images.google", "pinterest", "instagram", "stock.adobe", "shutterstock", "gettyimages", "appicon", "younewlogo"]:
        expect(forbidden not in lower, f"Verified place registry contains forbidden marker: {forbidden}")

    for city_id in [
        "nl-city-noord_holland-amsterdam",
        "nl-city-zuid_holland-rotterdam",
        "nl-city-zuid_holland-den_haag",
        "nl-city-zuid_holland-leiden",
        "nl-city-zuid_holland-delft",
        "nl-city-utrecht-utrecht",
        "nl-city-noord_brabant-eindhoven",
        "nl-city-limburg-maastricht",
        "nl-city-groningen-groningen",
    ]:
        pattern = rf'cityMedia\("{re.escape(city_id)}",\s*hero:\s*"[^"]+"'
        expect(re.search(pattern, registry), f"{city_id} is missing a verified hero photo")

    expect('"Canal houses and Oude Kerk at blue hour with water reflection in Damrak Amsterdam Netherlands.jpg"' in registry, "Amsterdam verified canal-house hero is missing")
    expect("Wikimedia Commons file license" in registry, "Generic Wikimedia hero license label is missing")

    for needle in [
        "sourcePageURL = \"https://commons.wikimedia.org/wiki/File:",
        "thumbnailURL = \"https://commons.wikimedia.org/wiki/Special:FilePath/",
        "renderStatus(type: type, localAssetName:",
        "type == .flag || type == .coatOfArms",
    ]:
        expect(needle in registry, f"Verified place media guard missing {needle}")

    app_image = read("YouNew/Models/AppImageAsset.swift")
    for needle in ["sourcePageURL.flatMap", "thumbnailURL.flatMap", "localAssetName: localAssetName"]:
        expect(needle in app_image, f"City media to AppImageAsset conversion missing {needle}")

    print("Place media static QA passed")


if __name__ == "__main__":
    main()
