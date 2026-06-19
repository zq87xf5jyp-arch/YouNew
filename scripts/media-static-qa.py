#!/usr/bin/env python3
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message):
    print(f"Media QA failed: {message}")
    sys.exit(1)


def read(path):
    target = ROOT / path
    if not target.is_file():
        fail(f"Missing file: {path}")
    return target.read_text(encoding="utf-8")


def expect(condition, message):
    if not condition:
        fail(message)


def app_image_asset_entries(text):
    return text.split("AppImageAsset(")[1:]


def validate_registry(path, required_ids=()):
    text = read(path)
    lower = text.lower()
    for forbidden in [
        "google.com",
        "images.google",
        "pinterest",
        "instagram.com",
        "unsplash.com",
        "pexels.com",
        "shutterstock",
        "gettyimages",
        "stock.adobe",
        "placeholder",
        "todo",
    ]:
        expect(forbidden not in lower, f"{path} contains forbidden media marker: {forbidden}")

    for image_id in required_ids:
        expect(f'id: "{image_id}"' in text, f"{path} missing image id {image_id}")

    for entry in app_image_asset_entries(text):
        image_id = re.search(r'id:\s*"([^"]+)"', entry)
        if not image_id:
            continue
        image_id = image_id.group(1)
        for field in [
            "sourcePageURL:",
            "thumbnailURL:",
            "sourceName:",
            "license:",
            "licenseURL:",
            "attribution:",
            "width:",
            "height:",
            "aspectRatio:",
            "verified: true",
            "retrievedAt:",
        ]:
            expect(field in entry, f"{path} entry {image_id} missing {field}")
        expect("commons.wikimedia.org/wiki/File:" in entry, f"{path} entry {image_id} must use an exact Commons File page")


def main():
    validate_registry(
        "YouNew/Data/HistoryMediaRegistry.swift",
        required_ids=[
            "history-netherlands-map-1631",
            "history-amsterdam-westerkerk-1660",
            "history-afsluitdijk-aerial",
        ],
    )
    validate_registry(
        "YouNew/Data/ContentMediaRegistry.swift",
        required_ids=[
            "content-transport-amsterdam-bike-parking",
            "content-transport-ovchipkaart-card",
            "content-healthcare-dutch-pharmacy",
            "content-government-haarlem-city-hall",
            "content-housing-rijtjeshuizen",
            "content-home-amsterdam-canal-houses",
            "content-culture-kinderdijk-windmills",
        ],
    )

    image_view = read("YouNew/Core/Imaging/AppContentImageView.swift")
    for needle in [
        "asset.thumbnailURL ?? asset.imageURL ?? asset.url",
        "VisualAssetHelper.exists(localAssetName)",
        "image.unavailable",
        "image.openSource",
        "showsSourceButton",
    ]:
        expect(needle in image_view, f"AppContentImageView missing {needle}")
    expect("AsyncImage(url: asset.sourcePageURL" not in image_view, "sourcePageURL must not be rendered as an image")
    expect("AsyncImage(url: asset.originalFileURL" not in image_view, "originalFileURL must not be used for card rendering")

    app_background = read("YouNew/Core/DesignSystem/Components/AppAtmosphereBackground.swift")
    for component in ["AppBackground", "CityMapBackground", "RouteLineBackground", "GlassPanelBackground", "PhotoHeroBackground"]:
        expect(f"struct {component}" in app_background, f"Missing reusable background component {component}")

    official_sources = read("YouNew/Views/OfficialSourceDirectoryView.swift")
    expect(".appSceneBackground(.settings)" in official_sources, "Official Sources must use the shared scene background")
    expect(".background(AppColors.background.ignoresSafeArea())" not in official_sources, "Official Sources still uses a flat background")

    for locale in ["en", "ru", "nl"]:
        strings = read(f"YouNew/{locale}.lproj/Localizable.strings")
        for key in ["image.source", "image.license", "image.unavailable", "image.openSource"]:
            expect(f'"{key}"' in strings, f"{locale} localization missing {key}")

    print("Media static QA passed")


if __name__ == "__main__":
    main()
