#!/usr/bin/env python3
from __future__ import annotations

import csv
import re
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "route_content_audit.csv"

SURFACES = [
    "YouNew/Views/RootHomeView.swift",
    "YouNew/Views/RootGuideView.swift",
    "YouNew/Views/PlacesDiscoveryView.swift",
    "YouNew/Views/ProvinceDirectoryView.swift",
    "YouNew/Views/LocalPartnersView.swift",
    "YouNew/Views/FavoritesView.swift",
    "YouNew/Views/RootMoreView.swift",
    "YouNew/Views/TransportGuideView.swift",
    "YouNew/Features/More/View/GovernmentHubView.swift",
    "YouNew/App/Navigation/AppDestinationView.swift",
]

ROUTE_PATTERN = re.compile(r"NavigationLink\s*\(\s*value:\s*([^\n\)]+)")
TEXT_PATTERN = re.compile(r'Text\(\s*"([^"\\]*(?:\\.[^"\\]*)*)"')
LOCALIZED_PATTERN = re.compile(r'localized\(\s*en:\s*"([^"]+)"')
IDENTIFIER_PATTERN = re.compile(r'accessibilityIdentifier\(\s*"([^"]+)')


def normalize(value: str) -> str:
    return " ".join(re.findall(r"[a-z0-9]+", value.lower()))


def expected_kind(title: str) -> str:
    if title.startswith("\\(") or title.startswith("dynamic-card@"):
        return "content"
    value = normalize(title)
    words = set(value.split())
    rules = [
        (("museum", "museums"), "museum"),
        (("restaurant", "restaurants"), "restaurant"),
        (("cafe", "cafes", "coffee"), "cafe"),
        (("hotel", "hotels", "stay"), "hotel"),
        (("municipality", "gemeente"), "government-service"),
        (("housing", "rent", "tenant", "mortgage"), "housing"),
        (("transport", "train", "tram", "bus", "bike", "parking", "airport", "ov"), "transport"),
        (("education", "study", "university", "duo", "school"), "education"),
        (("health", "doctor", "hospital", "dentist", "pharmacy"), "healthcare"),
        (("province",), "province"),
        (("city", "cities"), "city"),
        (("partner",), "partner"),
        (("official", "government", "ind", "uwv", "svb", "digid"), "government-service"),
        (("saved",), "saved"),
    ]
    for terms, kind in rules:
        if any((term in words) if " " not in term else (term in value) for term in terms):
            return kind
    return "content"


def actual_kind(destination: str) -> str:
    value = normalize(destination)
    rules = [
        (("localpartnerdetail",), "partner"),
        (("provincedetail", "mapfocus province"), "province"),
        (("nlcitydetail", "citydetail", "mapfocus city"), "city"),
        (("governmenthub", "officialsources", "institutiondetail"), "government-service"),
        (("housingbasics", "guide section housing"), "housing"),
        (("transportbasics", "transportguide", "guide section transport"), "transport"),
        (("healthcarebasics", "guide section health"), "healthcare"),
        (("institutionslist", "guide section study"), "education"),
        (("mapfocus place", "nearbyplacedetail", "placedetail"), "place"),
        (("favorites", "saved"), "saved"),
        (("searchlist",), "search"),
        (("assistant",), "assistant"),
    ]
    for terms, kind in rules:
        if any(term in value for term in terms):
            return kind
    if any(term in value for term in ("categorieshub", "maphub", "guidecontent")):
        return "generic-hub"
    return "content"


def source_dataset(path: str) -> str:
    if "Places" in path: return "MockNearbyPlacesData / ProvinceCatalog"
    if "Partner" in path: return "MockLocalPartnersData"
    if "Province" in path: return "ProvinceCatalog"
    if "Government" in path: return "KnowledgeIndex / official sources"
    if "Guide" in path: return "ContentRepository / Category.canonical"
    if "Favorites" in path: return "SavedItemsStore canonical IDs"
    if "Home" in path: return "ContentRepository / canonical categories"
    return "AppDestination / KnowledgeIndex"


rows = []
for relative in SURFACES:
    path = ROOT / relative
    if not path.exists():
        continue
    lines = path.read_text(encoding="utf-8").splitlines()
    for index, line in enumerate(lines):
        match = ROUTE_PATTERN.search(line)
        if not match:
            continue
        destination = match.group(1).strip()
        context = "\n".join(lines[max(0, index - 16): min(len(lines), index + 24)])
        titles = TEXT_PATTERN.findall(context) or LOCALIZED_PATTERN.findall(context)
        title = titles[-1] if titles else f"dynamic-card@{index + 1}"
        identifiers = IDENTIFIER_PATTERN.findall(context)
        entity_id = identifiers[-1] if identifiers else destination
        expected = expected_kind(title)
        actual = actual_kind(destination)
        if actual == "generic-hub" and expected not in ("content", "saved"):
            status = "generic"
        elif expected in ("museum", "restaurant", "cafe", "hotel") and actual not in (expected, "place", "search"):
            status = "wrong"
        elif expected == "government-service" and actual != "government-service":
            status = "wrong"
        elif expected not in ("content", actual) and actual not in ("content", "place", "search"):
            status = "wrong"
        else:
            status = "correct"
        rows.append({
            "screen": Path(relative).stem,
            "section": f"line:{index + 1}",
            "card_title": title,
            "expected_destination": expected,
            "actual_destination": destination,
            "content_entity_id": entity_id,
            "source_dataset": source_dataset(relative),
            "duplicate_content_found": "",
            "status": status,
        })

title_counts = Counter(normalize(row["card_title"]) for row in rows if not row["card_title"].startswith("dynamic-card@"))
for row in rows:
    key = normalize(row["card_title"])
    if key and title_counts[key] > 1:
        row["duplicate_content_found"] = f"repeated visible title x{title_counts[key]}"

fieldnames = [
    "screen", "section", "card_title", "expected_destination", "actual_destination",
    "content_entity_id", "source_dataset", "duplicate_content_found", "status",
]
with OUTPUT.open("w", encoding="utf-8", newline="") as handle:
    writer = csv.DictWriter(handle, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

counts = Counter(row["status"] for row in rows)
print(f"Wrote {OUTPUT.name}")
print(f"routes={len(rows)} correct={counts['correct']} wrong={counts['wrong']} generic={counts['generic']}")
