#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from urllib.parse import parse_qsl, urlparse


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "YouNew/Data/HistoryMediaRegistry.swift"
IMAGE_VIEW = ROOT / "YouNew/Core/Imaging/AppContentImageView.swift"
HISTORY_VIEW = ROOT / "YouNew/Views/NetherlandsHistoryView.swift"
LOCALIZATIONS = {
    "en": ROOT / "YouNew/en.lproj/Localizable.strings",
    "nl": ROOT / "YouNew/nl.lproj/Localizable.strings",
    "ru": ROOT / "YouNew/ru.lproj/Localizable.strings",
}

EXPECTED_IMAGES = {
    "history-netherlands-map-1631": {
        "title": "Map of the Netherlands, 1631",
        "sourcePageURL": "https://commons.wikimedia.org/wiki/File:Kaart_van_de_Nederlanden_(1631)_by_Henricus_Hondius._Original_from_The_Rijksmuseum._Digitally_enhanced_by_rawpixel._(50623712477).jpg",
        "thumbnailURL": "https://commons.wikimedia.org/wiki/Special:FilePath/Kaart_van_de_Nederlanden_%281631%29_by_Henricus_Hondius._Original_from_The_Rijksmuseum._Digitally_enhanced_by_rawpixel._%2850623712477%29.jpg?width=1600",
        "imageURL": "https://commons.wikimedia.org/wiki/Special:FilePath/Kaart_van_de_Nederlanden_%281631%29_by_Henricus_Hondius._Original_from_The_Rijksmuseum._Digitally_enhanced_by_rawpixel._%2850623712477%29.jpg",
        "originalFileURL": "https://upload.wikimedia.org/wikipedia/commons/b/b1/Kaart_van_de_Nederlanden_%281631%29_by_Henricus_Hondius._Original_from_The_Rijksmuseum._Digitally_enhanced_by_rawpixel._%2850623712477%29.jpg",
        "licenseName": "Creative Commons Attribution 2.0 Generic",
        "licenseURL": "https://creativecommons.org/licenses/by/2.0/",
        "author": "Rijksmuseum; Henricus Hondius; rawpixel",
        "attribution": "Rijksmuseum / Henricus Hondius / rawpixel, via Wikimedia Commons",
        "width": "4476",
        "height": "3566",
        "aspectRatio": "4476.0 / 3566.0",
        "retrievedAt": "2026-05-31",
    },
    "history-amsterdam-westerkerk-1660": {
        "title": "View of the Westerkerk, Amsterdam, 1660",
        "sourcePageURL": "https://commons.wikimedia.org/wiki/File:View_of_the_Westerkerk_Amsterdam_1660_Jan_van_der_Heyden.jpg",
        "thumbnailURL": "https://commons.wikimedia.org/wiki/Special:FilePath/View_of_the_Westerkerk_Amsterdam_1660_Jan_van_der_Heyden.jpg?width=1400",
        "imageURL": "https://commons.wikimedia.org/wiki/Special:FilePath/View_of_the_Westerkerk_Amsterdam_1660_Jan_van_der_Heyden.jpg",
        "originalFileURL": "https://upload.wikimedia.org/wikipedia/commons/b/b2/View_of_the_Westerkerk_Amsterdam_1660_Jan_van_der_Heyden.jpg",
        "licenseName": "Public Domain Mark 1.0",
        "licenseURL": "https://creativecommons.org/publicdomain/mark/1.0/",
        "author": "Jan van der Heyden",
        "attribution": "Jan van der Heyden, via Wikimedia Commons",
        "width": "3575",
        "height": "2815",
        "aspectRatio": "3575.0 / 2815.0",
        "retrievedAt": "2026-05-31",
    },
    "history-afsluitdijk-aerial": {
        "title": "Aerial photograph of Afsluitdijk",
        "sourcePageURL": "https://commons.wikimedia.org/wiki/File:NIMH_-_2011_-_3550_-_Aerial_photograph_of_Afsluitdijk,_The_Netherlands.jpg",
        "thumbnailURL": "https://commons.wikimedia.org/wiki/Special:FilePath/NIMH_-_2011_-_3550_-_Aerial_photograph_of_Afsluitdijk%2C_The_Netherlands.jpg?width=1400",
        "imageURL": "https://commons.wikimedia.org/wiki/Special:FilePath/NIMH_-_2011_-_3550_-_Aerial_photograph_of_Afsluitdijk%2C_The_Netherlands.jpg",
        "originalFileURL": "https://upload.wikimedia.org/wikipedia/commons/1/1a/NIMH_-_2011_-_3550_-_Aerial_photograph_of_Afsluitdijk%2C_The_Netherlands.jpg",
        "licenseName": "Creative Commons Attribution-Share Alike 4.0 International",
        "licenseURL": "https://creativecommons.org/licenses/by-sa/4.0/",
        "author": "Unknown; Nederlands Instituut voor Militaire Historie",
        "attribution": "Nederlands Instituut voor Militaire Historie / Wikimedia Commons",
        "width": "3500",
        "height": "2630",
        "aspectRatio": "3500.0 / 2630.0",
        "retrievedAt": "2026-05-31",
    },
    "history-rembrandt-night-watch-1642": {
        "title": "The Night Watch, 1642",
        "sourcePageURL": "https://commons.wikimedia.org/wiki/File:De_Nachtwacht.jpg",
        "thumbnailURL": "https://commons.wikimedia.org/wiki/Special:FilePath/De_Nachtwacht.jpg?width=1600",
        "imageURL": "https://commons.wikimedia.org/wiki/Special:FilePath/De_Nachtwacht.jpg",
        "originalFileURL": "https://upload.wikimedia.org/wikipedia/commons/5/5a/De_Nachtwacht.jpg",
        "licenseName": "Public Domain — copyright expired",
        "licenseURL": "https://creativecommons.org/publicdomain/mark/1.0/",
        "author": "Rembrandt van Rijn (1642)",
        "attribution": "Rembrandt van Rijn (1642), Rijksmuseum Amsterdam — Public Domain via Wikimedia Commons",
        "width": "4299",
        "height": "3654",
        "aspectRatio": "4299.0 / 3654.0",
        "retrievedAt": "2026-06-01",
    },
    "history-rembrandt-anatomy-lesson-1632": {
        "title": "The Anatomy Lesson of Dr Nicolaes Tulp, 1632",
        "sourcePageURL": "https://commons.wikimedia.org/wiki/File:Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg",
        "thumbnailURL": "https://commons.wikimedia.org/wiki/Special:FilePath/Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg?width=1600",
        "imageURL": "https://commons.wikimedia.org/wiki/Special:FilePath/Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg",
        "originalFileURL": "https://upload.wikimedia.org/wikipedia/commons/4/4d/Rembrandt_-_The_Anatomy_Lesson_of_Dr_Nicolaes_Tulp.jpg",
        "licenseName": "Public Domain — copyright expired",
        "licenseURL": "https://creativecommons.org/publicdomain/mark/1.0/",
        "author": "Rembrandt van Rijn (1632)",
        "attribution": "Rembrandt van Rijn (1632), Mauritshuis, The Hague — Public Domain via Wikimedia Commons",
        "width": "3576",
        "height": "2808",
        "aspectRatio": "3576.0 / 2808.0",
        "retrievedAt": "2026-06-01",
    },
}


def fail(message):
    print(f"FAIL: {message}")
    sys.exit(1)


def expect(condition, message):
    if not condition:
        fail(message)


def read(path):
    expect(path.is_file(), f"Missing file: {path.relative_to(ROOT)}")
    return path.read_text(encoding="utf-8")


def string_field(entry, field):
    match = re.search(rf'{field}:\s*"([^"]*)"', entry)
    return match.group(1) if match else None


def url_field(entry, field):
    match = re.search(rf'{field}:\s*URL\(string:\s*"([^"]*)"\)', entry)
    return match.group(1) if match else None


def numeric_field(entry, field):
    match = re.search(rf'{field}:\s*([0-9]+(?:\.[0-9]+)?(?:\s*/\s*[0-9]+(?:\.[0-9]+)?)?)', entry)
    return match.group(1) if match else None


def parse_registry_entries():
    text = read(REGISTRY)
    entries = {}
    for chunk in text.split("        AppImageAsset(")[1:]:
        entry = chunk.split("\n        )", 1)[0]
        image_id = string_field(entry, "id")
        expect(image_id, "History image entry is missing id")
        expect(image_id not in entries, f"Duplicate history image id: {image_id}")
        entries[image_id] = entry
    return entries


def validate_exact_registry(entries):
    expect(set(entries) == set(EXPECTED_IMAGES), f"Unexpected curated image ids: {sorted(entries)}")

    for image_id, expected in EXPECTED_IMAGES.items():
        entry = entries[image_id]
        expect("type: .timeline" in entry, f"{image_id} must be type .timeline")
        expect("verified: true" in entry, f"{image_id} must be verified true")

        for field in ["title", "licenseName", "author", "attribution", "retrievedAt"]:
            value = string_field(entry, field)
            expect(value and value.strip(), f"{image_id} has empty {field}")
            expect(value == expected[field], f"{image_id} {field} mismatch: {value}")

        expect(string_field(entry, "sourceName") == "Wikimedia Commons", f"{image_id} sourceName must be Wikimedia Commons")

        for field in ["sourcePageURL", "thumbnailURL", "imageURL", "originalFileURL", "licenseURL"]:
            value = url_field(entry, field)
            expect(value and value.strip(), f"{image_id} has empty {field}")
            expect(value == expected[field], f"{image_id} {field} mismatch: {value}")

        source_url = url_field(entry, "sourceURL")
        expect(source_url == expected["sourcePageURL"], f"{image_id} legacy sourceURL must mirror sourcePageURL")

        for field in ["width", "height", "aspectRatio"]:
            value = numeric_field(entry, field)
            expect(value and value.strip(), f"{image_id} has missing {field}")
            expect(value == expected[field], f"{image_id} {field} mismatch: {value}")


def validate_source_pages(entries):
    forbidden_source_fragments = [
        "/wiki/Category:",
        "Special:Search",
        "Special:MediaSearch",
        "search=",
        "utm_",
        "google.",
        "images.google",
        "istockphoto",
        "shutterstock",
        "gettyimages",
        "stock.adobe",
        "placeholder",
    ]

    for image_id, entry in entries.items():
        source_page_url = url_field(entry, "sourcePageURL")
        parsed = urlparse(source_page_url)
        query_keys = {key.lower() for key, _ in parse_qsl(parsed.query)}

        expect(parsed.scheme == "https", f"{image_id} sourcePageURL must use https")
        expect(parsed.netloc == "commons.wikimedia.org", f"{image_id} sourcePageURL must be on Commons")
        expect(parsed.path.startswith("/wiki/File:"), f"{image_id} sourcePageURL must be an exact Commons File page")
        expect(not parsed.query, f"{image_id} sourcePageURL must not include query parameters")
        expect(not any(key.startswith("utm_") for key in query_keys), f"{image_id} sourcePageURL contains tracking params")

        values = [
            source_page_url,
            string_field(entry, "sourceName"),
            string_field(entry, "title"),
            string_field(entry, "attribution"),
            string_field(entry, "author"),
            url_field(entry, "thumbnailURL"),
            url_field(entry, "imageURL"),
            url_field(entry, "originalFileURL"),
        ]
        combined = "\n".join(value for value in values if value).lower()
        for fragment in forbidden_source_fragments:
            expect(fragment.lower() not in combined, f"{image_id} contains forbidden media source fragment: {fragment}")


def validate_rendering_separation(entries):
    image_view = read(IMAGE_VIEW)
    expect("asset.thumbnailURL ?? asset.imageURL ?? asset.url" in image_view, "AppContentImageView must render thumbnailURL, then imageURL, then legacy url")
    expect("AsyncImage(url: asset.sourcePageURL" not in image_view, "sourcePageURL must not be loaded as an image")
    expect("AsyncImage(url: asset.originalFileURL" not in image_view, "originalFileURL must not be loaded into cards")

    for image_id, entry in entries.items():
        source_page_url = url_field(entry, "sourcePageURL")
        render_urls = [url_field(entry, "thumbnailURL"), url_field(entry, "imageURL"), url_field(entry, "url")]
        expect(source_page_url not in render_urls, f"{image_id} sourcePageURL is used as a renderable URL")
        expect(url_field(entry, "originalFileURL") != url_field(entry, "thumbnailURL"), f"{image_id} originalFileURL is used as thumbnailURL")


def validate_forbidden_symbol_reuse(entries):
    forbidden_fragments = [
        "appicon",
        "younewbrandlogo",
        "younew_logo",
        "flag_of_the_netherlands",
        "flag_of_",
        "coat_of_arms",
        "wapen",
        "officialsymbol",
    ]

    for image_id, entry in entries.items():
        values = [
            image_id,
            string_field(entry, "title"),
            url_field(entry, "thumbnailURL"),
            url_field(entry, "imageURL"),
            url_field(entry, "originalFileURL"),
        ]
        combined = "\n".join(value for value in values if value).lower()
        for fragment in forbidden_fragments:
            expect(fragment not in combined, f"{image_id} appears to reuse an app logo, flag, or coat-of-arms: {fragment}")


def localization_value(text, key):
    match = re.search(rf'"{re.escape(key)}"\s*=\s*"([^"]*)";', text)
    return match.group(1) if match else None


def validate_source_details_and_titles(entries):
    history_view = read(HISTORY_VIEW)
    expect("HistorySourceDetails.textSource(for:" in history_view, "Source details must include text source helper")
    expect("HistorySourceDetails.imageSource(for:" in history_view, "Source details must include image source helper")
    expect("let sourcePageURL = image.sourcePageURL" in history_view, "Image source details must read sourcePageURL")
    expect("licenseName: licenseName" in history_view, "Image source details must expose licenseName")
    expect("attribution: attribution" in history_view, "Image source details must expose attribution")
    expect("detail.sourcePageURL.absoluteString" in history_view, "Source sheet must display sourcePageURL")
    expect("detail.licenseName" in history_view, "Source sheet must display licenseName")
    expect("detail.attribution" in history_view, "Source sheet must display attribution")

    title_keys = {
        image_id: string_field(entry, "titleKey")
        for image_id, entry in entries.items()
    }
    forbidden_title_fragments = ["file:", ".jpg", ".jpeg", ".png", ".webp", "_"]

    for lang, path in LOCALIZATIONS.items():
        text = read(path)
        for image_id, key in title_keys.items():
            expect(key, f"{image_id} is missing titleKey")
            value = localization_value(text, key)
            expect(value and value.strip(), f"{lang} localization missing title for {image_id}: {key}")
            lowered = value.lower()
            for fragment in forbidden_title_fragments:
                expect(fragment not in lowered, f"{lang} title for {image_id} exposes raw filename marker {fragment}: {value}")


def main():
    entries = parse_registry_entries()
    validate_exact_registry(entries)
    validate_source_pages(entries)
    validate_rendering_separation(entries)
    validate_forbidden_symbol_reuse(entries)
    validate_source_details_and_titles(entries)
    print(f"History media static QA passed ({len(entries)} curated images)")


if __name__ == "__main__":
    main()
