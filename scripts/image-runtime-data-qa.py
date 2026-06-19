#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from typing import Optional
from urllib.parse import unquote, urlparse

ROOT = Path(__file__).resolve().parents[1]
CURATED = ROOT / "YouNew" / "Data" / "CuratedPlaceHeroMediaRegistry.swift"
VERIFIED = ROOT / "YouNew" / "Data" / "VerifiedPlaceMediaRegistry.swift"
NETHERLANDS_DATA = ROOT / "YouNew" / "Data" / "NetherlandsData.swift"
ROOT_TAB = ROOT / "YouNew" / "App" / "AppTabView.swift"
CONTENT_MEDIA = ROOT / "YouNew" / "Data" / "ContentMediaRegistry.swift"
PROVINCE_DIRECTORY = ROOT / "YouNew" / "Views" / "ProvinceDirectoryView.swift"

BAD_LANDSCAPE_TOKENS = (
    "kinderdijk",
    "windmill",
    "windmills",
    "molen",
    "dom_tower",
    "erasmusbrug",
    "oudegracht",
    "john_frost",
    "haarlem",
    "martinitoren",
    "magisch_maastricht",
    "waalbrug",
)

WINDMILL_TOKENS = ("kinderdijk", "windmill", "windmills", "molen", "the_windmills_of_kinderdijk")
REQUIRED_CITY_VISUAL_ROLES = ("hero", "landmark", "culture", "night", "thumbnail", "card")
REQUIRED_PROVINCE_VISUAL_ROLES = ("landscape", "culture", "nature", "architecture", "tourism")
REQUIRED_TOURISM_CATEGORIES = (
    "topAttractions",
    "museums",
    "castles",
    "nature",
    "beaches",
    "parks",
    "historicCentres",
    "unescoSites",
    "hiddenGems",
    "dayTrips",
)
FORBIDDEN_VISUAL_MARKERS = (
    "placeholder",
    "todo",
    "generic",
    "stock",
    "unsplash",
    "pexels",
    "shutterstock",
    "getty",
    "screenshot",
    "screen shot",
    "screen-shot",
    "screen_capture",
    "screen capture",
    "logo",
    "watermark",
)
SAFE_AREA_DEFAULT = (
    "Aspect fill with focal subject centered; protect full towers, bridges, windmill sails, "
    "castle facades, monuments, waterfront edges, and skyline."
)
LEGACY_SAFE_AREA_DEFAULT = "Aspect fill with landmark center protected."

REQUIRED_CITY_TOKENS = {
    "nl-city-noord_holland-amsterdam": ("canal", "oude", "kerk", "damrak", "rijksmuseum"),
    "nl-city-zuid_holland-rotterdam": ("erasmusbrug", "skyline", "markthal"),
    "nl-city-zuid_holland-den_haag": ("den_haag", "friedenspalast", "peace", "binnenhof", "scheveningen"),
    "nl-city-zuid_holland-leiden": ("leiden", "canal", "oude_vest"),
    "nl-city-utrecht-utrecht": ("utrecht", "dom", "oudegracht"),
    "nl-city-groningen-groningen": ("groningen", "martinitoren", "grote_markt"),
    "nl-city-noord_brabant-eindhoven": ("eindhoven", "witte", "dame"),
    "nl-city-limburg-maastricht": ("maastricht", "vrijthof", "servaas", "magisch"),
    "nl-city-gelderland-nijmegen": ("nijmegen", "waalbrug", "stevenskerk", "valkhof"),
    "nl-city-gelderland-arnhem": ("arnhem", "john_frost", "sonsbeek"),
    "nl-city-noord_holland-haarlem": ("haarlem", "grotemarkt", "bavo", "grote"),
}

ALLOWED_DUPLICATE_CITY_KEYS = {
    frozenset(("nl-city-noord_brabant-s_hertogenbosch", "nl-city-noord_brabant-den_bosch")),
}


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def normalize_url(url: str) -> str:
    parsed = urlparse(url.strip())
    path = unquote(parsed.path).lower().replace(" ", "_")
    path = re.sub(r"/thumb/", "/", path)
    path = re.sub(r"/(?:\d+px-|[0-9]+px_)[^/]+$", "", path)
    query = parsed.query.lower()
    if "special:filepath" in path:
        query = ""
    return f"{parsed.netloc.lower()}{path}?{query}".rstrip("?")


def url_is_valid_https(url: str) -> bool:
    parsed = urlparse(url)
    return parsed.scheme == "https" and bool(parsed.netloc)


def place_id_for_city(name: str, province: str) -> str:
    return f"nl-city-{normalized_place_token(province)}-{normalized_place_token(name)}"


def normalized_place_token(value: str) -> str:
    return (
        value.lower()
        .replace("'", "")
        .replace("-", "_")
        .replace(" ", "_")
        .replace("é", "e")
        .replace("ë", "e")
        .replace("á", "a")
    )


def curated_media() -> dict[str, str]:
    text = read(CURATED)
    pattern = re.compile(
        r'"(?P<place>nl-(?:city|province)-[^"]+)":\s*media\([^)]*?remote:\s*"(?P<url>https?://[^"]+)"',
        re.S,
    )
    return {match.group("place"): match.group("url") for match in pattern.finditer(text)}


def province_catalog_city_ids() -> list[str]:
    text = read(PROVINCE_DIRECTORY)
    results = []
    pattern = re.compile(
        r'city\(\s*"(?P<name>[^"]+)",\s*"[^"]+",\s*"[^"]+",\s*"(?P<province>[^"]+)"',
        re.S,
    )
    for match in pattern.finditer(text):
        results.append(place_id_for_city(match.group("name"), match.group("province")))
    return results


def province_ids() -> list[str]:
    text = read(NETHERLANDS_DATA)
    pattern = re.compile(
        r'NLProvince\(\s*id:\s*"(?P<id>[^"]+)"',
        re.S,
    )
    return [f"nl-province-{normalized_place_token(match.group('id'))}" for match in pattern.finditer(text)]


def city_role_visuals() -> dict[str, dict[str, str]]:
    text = read(CURATED)
    entries: dict[str, dict[str, str]] = {}
    entry_pattern = re.compile(
        r'"(?P<place>nl-city-[^"]+)":\s*\[(?P<body>.*?)(?=\n\s*\],\n\s*"|\n\s*\]\n\s*\])',
        re.S,
    )
    visual_pattern = re.compile(
        r'\.(?P<role>hero|landmark|culture|night|thumbnail|card):\s*visual\([^)]*?remote:\s*"(?P<url>https?://[^"]+)"',
        re.S,
    )
    for match in entry_pattern.finditer(text):
        entries[match.group("place")] = {
            visual.group("role"): visual.group("url")
            for visual in visual_pattern.finditer(match.group("body"))
        }
    return entries


def province_role_visuals() -> dict[str, dict[str, str]]:
    text = read(CURATED)
    entries: dict[str, dict[str, str]] = {}
    entry_pattern = re.compile(
        r'"(?P<place>nl-province-[^"]+)":\s*\[(?P<body>.*?)(?=\n\s*\],\n\s*"|\n\s*\]\n\s*\])',
        re.S,
    )
    visual_pattern = re.compile(
        r'\.(?P<role>landscape|culture|nature|architecture|tourism):\s*visual\([^)]*?remote:\s*"(?P<url>https?://[^"]+)"',
        re.S,
    )
    for match in entry_pattern.finditer(text):
        entries[match.group("place")] = {
            visual.group("role"): visual.group("url")
            for visual in visual_pattern.finditer(match.group("body"))
        }
    return entries


def tourism_catalog_records() -> list[dict[str, str]]:
    text = read(NETHERLANDS_DATA)
    pattern = re.compile(
        r'record\(\s*"(?P<id>[^"]+)",\s*\.(?P<category>\w+),\s*"(?P<name>[^"]+)",\s*"(?P<location>[^"]+)",\s*"(?P<description>[^"]+)",\s*"(?P<why>[^"]+)",\s*"(?P<season>[^"]+)",\s*"(?P<url>https?://[^"]+)"\s*\)',
        re.S,
    )
    return [match.groupdict() for match in pattern.finditer(text)]


def runtime_attractions() -> list[dict[str, str]]:
    text = read(NETHERLANDS_DATA)
    pattern = re.compile(
        r'Attraction\(id:\s*"(?P<id>[^"]+)".*?name:\s*"(?P<name>[^"]+)".*?imageURL:\s*"(?P<url>https?://[^"]+)"',
        re.S,
    )
    return [match.groupdict() for match in pattern.finditer(text)]


def attraction_metadata_records() -> dict[str, dict[str, str]]:
    text = read(NETHERLANDS_DATA)
    pattern = re.compile(
        r'"(?P<id>[^"]+)":\s*meta\(\s*\.(?P<category>\w+),\s*"(?P<location>[^"]+)",\s*"(?P<why>[^"]+)",\s*"(?P<season>[^"]+)",\s*"(?P<photo>[^"]+)"\s*\)',
        re.S,
    )
    return {match.group("id"): match.groupdict() for match in pattern.finditer(text)}


def visual_records(prefix: str, roles: tuple[str, ...]) -> dict[str, dict[str, dict[str, object]]]:
    text = read(CURATED)
    entries: dict[str, dict[str, dict[str, object]]] = {}
    role_pattern = "|".join(roles)
    entry_pattern = re.compile(
        rf'"(?P<place>nl-{prefix}-[^"]+)":\s*\[(?P<body>.*?)(?=\n\s*\],\n\s*"|\n\s*\]\n\s*\])',
        re.S,
    )
    visual_pattern = re.compile(
        rf'\.(?P<role>{role_pattern}):\s*visual\(\s*"(?P<place>[^"]+)",\s*"(?P<role_arg>[^"]+)",\s*"(?P<title>[^"]+)",\s*"(?P<why>[^"]+)",\s*"(?P<asset>[^"]+)",(?P<tail>.*?)\)',
        re.S,
    )
    remote_pattern = re.compile(r'remote:\s*"(?P<url>https?://[^"]+)"')
    min_width_pattern = re.compile(r'minimumPixelWidth:\s*(?P<width>\d+)')
    safe_area_pattern = re.compile(r'safeArea:\s*"(?P<safe>[^"]+)"')

    for match in entry_pattern.finditer(text):
        place_id = match.group("place")
        role_records: dict[str, dict[str, object]] = {}
        for visual in visual_pattern.finditer(match.group("body")):
            tail = visual.group("tail")
            remote = remote_pattern.search(tail)
            if not remote:
                continue
            min_width = min_width_pattern.search(tail)
            safe_area = safe_area_pattern.search(tail)
            role_records[visual.group("role")] = {
                "url": remote.group("url"),
                "title": visual.group("title"),
                "why": visual.group("why"),
                "asset": visual.group("asset"),
                "minimumPixelWidth": int(min_width.group("width")) if min_width else 1200,
                "safeArea": safe_area.group("safe") if safe_area else SAFE_AREA_DEFAULT,
            }
        entries[place_id] = role_records
    return entries


def historical_figures() -> list[tuple[str, str, str]]:
    text = read(ROOT_TAB)
    pattern = re.compile(
        r'HistoricalFigure\(\s*id:\s*"(?P<id>[^"]+)".*?name:\s*"(?P<name>[^"]+)".*?imageURL:\s*"(?P<url>https?://[^"]*)"',
        re.S,
    )
    return [(m.group("id"), m.group("name"), m.group("url")) for m in pattern.finditer(text)]


def image_urls_in_files() -> list[tuple[str, str]]:
    files = [CURATED, VERIFIED, NETHERLANDS_DATA, ROOT_TAB, CONTENT_MEDIA, PROVINCE_DIRECTORY]
    urls = []
    pattern = re.compile(r'(?:imageURL|thumbnailURL|url|remote|originalFile|sourcePage):\s*(?:URL\(string:\s*)?"(https?://[^"]*)"', re.S)
    for path in files:
        for match in pattern.finditer(read(path)):
            urls.append((str(path.relative_to(ROOT)), match.group(1)))
    return urls


def assert_duplicate_city_urls(media: dict[str, str], failures: list[str]) -> None:
    city_entries = {key: normalize_url(url) for key, url in media.items() if key.startswith("nl-city-")}
    grouped: dict[str, list[str]] = {}
    for key, url in city_entries.items():
        grouped.setdefault(url, []).append(key)

    for url, keys in grouped.items():
        if len(keys) < 2:
            continue
        key_set = frozenset(keys)
        if key_set in ALLOWED_DUPLICATE_CITY_KEYS:
            continue
        failures.append(f"Duplicate city hero URL: {url} -> {', '.join(keys)}")


def assert_province_city_card_duplicates(media: dict[str, str], failures: list[str]) -> None:
    city_ids = province_catalog_city_ids()
    urls: dict[str, list[str]] = {}
    for city_id in city_ids:
        url = media.get(city_id)
        if not url:
            failures.append(f"Missing curated media for province city card: {city_id}")
            continue
        urls.setdefault(normalize_url(url), []).append(city_id)

    for url, ids in urls.items():
        if len(ids) > 1 and frozenset(ids) not in ALLOWED_DUPLICATE_CITY_KEYS:
            failures.append(f"Duplicate province city-card URL: {url} -> {', '.join(ids)}")


def assert_province_catalog_city_role_coverage(failures: list[str]) -> None:
    visuals = city_role_visuals()
    for city_id in province_catalog_city_ids():
        roles = visuals.get(city_id, {})
        missing_roles = [role for role in REQUIRED_CITY_VISUAL_ROLES if role not in roles]
        if missing_roles:
            failures.append(
                "Missing full city visual role coverage for province catalog city: "
                f"{city_id} missing {', '.join(missing_roles)}"
            )
            continue

        normalized_by_role = {
            role: normalize_url(url)
            for role, url in roles.items()
            if role in REQUIRED_CITY_VISUAL_ROLES
        }
        seen: dict[str, str] = {}
        for role in REQUIRED_CITY_VISUAL_ROLES:
            normalized_url = normalized_by_role[role]
            if normalized_url in seen:
                failures.append(
                    "City visual role reuses the same source file inside province catalog city: "
                    f"{city_id} {seen[normalized_url]} and {role} -> {normalized_url}"
                )
            else:
                seen[normalized_url] = role


def assert_province_role_coverage(failures: list[str]) -> None:
    visuals = province_role_visuals()
    seen_global: dict[str, str] = {}

    for province_id in province_ids():
        roles = visuals.get(province_id, {})
        missing_roles = [role for role in REQUIRED_PROVINCE_VISUAL_ROLES if role not in roles]
        if missing_roles:
            failures.append(
                "Missing full province visual role coverage: "
                f"{province_id} missing {', '.join(missing_roles)}"
            )
            continue

        seen_inside_province: dict[str, str] = {}
        for role in REQUIRED_PROVINCE_VISUAL_ROLES:
            normalized_url = normalize_url(roles[role])
            if normalized_url in seen_inside_province:
                failures.append(
                    "Province visual role reuses the same source file inside province: "
                    f"{province_id} {seen_inside_province[normalized_url]} and {role} -> {normalized_url}"
                )
            else:
                seen_inside_province[normalized_url] = role

            owner = f"{province_id} {role}"
            if normalized_url in seen_global:
                failures.append(
                    "Province visual role reuses source file across provinces: "
                    f"{owner} and {seen_global[normalized_url]} -> {normalized_url}"
                )
            else:
                seen_global[normalized_url] = owner


def assert_visual_subject_uniqueness(failures: list[str]) -> None:
    for label, prefix, roles in (
        ("city", "city", REQUIRED_CITY_VISUAL_ROLES),
        ("province", "province", REQUIRED_PROVINCE_VISUAL_ROLES),
    ):
        title_owners: dict[str, str] = {}
        asset_owners: dict[str, str] = {}
        for place_id, role_records in visual_records(prefix, roles).items():
            for role, record in role_records.items():
                owner = f"{place_id} {role}"
                title = str(record.get("title", "")).strip().casefold()
                asset = str(record.get("asset", "")).strip().casefold()

                if title:
                    if title in title_owners:
                        failures.append(
                            f"Duplicate {label} visual subject title: {owner} and {title_owners[title]} -> {title}"
                        )
                    else:
                        title_owners[title] = owner

                if asset:
                    if asset in asset_owners:
                        failures.append(
                            f"Duplicate {label} visual asset identity: {owner} and {asset_owners[asset]} -> {asset}"
                        )
                    else:
                        asset_owners[asset] = owner


def requested_pixel_width(url: str) -> Optional[int]:
    width_match = re.search(r"[?&]width=(\d+)", url)
    if width_match:
        return int(width_match.group(1))

    px_match = re.search(r"/(\d+)px[-_]", url)
    if px_match:
        return int(px_match.group(1))

    return None


def assert_tourism_catalog_contracts(failures: list[str]) -> None:
    records = tourism_catalog_records()
    if not records:
        failures.append("Tourism catalog has no records.")
        return

    categories = {record["category"] for record in records}
    missing_categories = [category for category in REQUIRED_TOURISM_CATEGORIES if category not in categories]
    if missing_categories:
        failures.append(f"Tourism catalog missing categories: {', '.join(missing_categories)}")

    seen_ids: set[str] = set()
    seen_urls: dict[str, str] = {}
    for record in records:
        label = f"tourism catalog {record['id']}"
        for key in ("id", "category", "name", "location", "description", "why", "season", "url"):
            if not record[key].strip():
                failures.append(f"{label} missing {key}")

        if record["id"] in seen_ids:
            failures.append(f"Duplicate tourism catalog id: {record['id']}")
        seen_ids.add(record["id"])

        normalized_url = normalize_url(record["url"])
        if normalized_url in seen_urls:
            failures.append(
                "Duplicate tourism catalog source file: "
                f"{record['id']} and {seen_urls[normalized_url]} -> {normalized_url}"
            )
        seen_urls[normalized_url] = record["id"]

        if not url_is_valid_https(record["url"]):
            failures.append(f"{label} has invalid URL: {record['url']}")
        if any(marker in " ".join(record.values()).lower() for marker in FORBIDDEN_VISUAL_MARKERS):
            failures.append(f"{label} contains forbidden placeholder/stock/generic marker.")
        width = requested_pixel_width(record["url"])
        if width is not None and width < 1200:
            failures.append(f"{label} requests too-small image width: {width}px")
        if len(record["description"].strip()) < 32:
            failures.append(f"{label} has weak description text.")
        if len(record["why"].strip()) < 32:
            failures.append(f"{label} has weak why-visit text.")


def assert_runtime_attraction_contracts(failures: list[str]) -> None:
    attractions = runtime_attractions()
    metadata = attraction_metadata_records()
    if not attractions:
        failures.append("Runtime city attractions are missing.")
        return

    seen_ids: set[str] = set()
    seen_urls: dict[str, str] = {}
    for attraction in attractions:
        label = f"runtime attraction {attraction['id']} / {attraction['name']}"
        if attraction["id"] in seen_ids:
            failures.append(f"Duplicate runtime attraction id: {attraction['id']}")
        seen_ids.add(attraction["id"])

        normalized_url = normalize_url(attraction["url"])
        if normalized_url in seen_urls:
            failures.append(
                "Duplicate runtime attraction source file: "
                f"{label} and {seen_urls[normalized_url]} -> {normalized_url}"
            )
        seen_urls[normalized_url] = label

        if attraction["id"] not in metadata:
            failures.append(f"{label} lacks explicit location/why/best-season/photo-purpose metadata.")
            continue

        meta = metadata[attraction["id"]]
        if meta["category"] not in REQUIRED_TOURISM_CATEGORIES:
            failures.append(f"{label} has unknown tourism category: {meta['category']}")
        for key in ("location", "why", "season", "photo"):
            if len(meta[key].strip()) < 8:
                failures.append(f"{label} has weak {key} metadata.")
        if any(marker in " ".join([*attraction.values(), *meta.values()]).lower() for marker in FORBIDDEN_VISUAL_MARKERS):
            failures.append(f"{label} contains forbidden placeholder/stock/generic marker.")
        width = requested_pixel_width(attraction["url"])
        if width is not None and width < 1200:
            failures.append(f"{label} requests too-small image width: {width}px")


def assert_visual_metadata_contracts(failures: list[str]) -> None:
    city_records = visual_records("city", REQUIRED_CITY_VISUAL_ROLES)
    province_records = visual_records("province", REQUIRED_PROVINCE_VISUAL_ROLES)

    for city_id, roles in city_records.items():
        for role in REQUIRED_CITY_VISUAL_ROLES:
            record = roles.get(role)
            if not record:
                continue
            label = f"{city_id} {role}"
            assert_visual_record(label, role, record, 2400 if role == "hero" else 1200, failures)

    for province_id, roles in province_records.items():
        for role in REQUIRED_PROVINCE_VISUAL_ROLES:
            record = roles.get(role)
            if not record:
                continue
            label = f"{province_id} {role}"
            assert_visual_record(label, role, record, 2400 if role == "landscape" else 1200, failures)


def assert_visual_record(label: str, role: str, record: dict[str, object], required_width: int, failures: list[str]) -> None:
    title = str(record.get("title", "")).strip()
    why = str(record.get("why", "")).strip()
    asset = str(record.get("asset", "")).strip()
    url = str(record.get("url", "")).strip()
    safe_area = str(record.get("safeArea", "")).strip()
    minimum_pixel_width = int(record.get("minimumPixelWidth", 0))
    searchable = " ".join([title, why, asset, url, safe_area]).lower()

    if not title:
        failures.append(f"Visual metadata missing title: {label}")
    if len(why) < 24:
        failures.append(f"Visual metadata has weak why text: {label}")
    if not asset:
        failures.append(f"Visual metadata missing asset name: {label}")
    if not url_is_valid_https(url):
        failures.append(f"Visual metadata has invalid URL: {label} -> {url}")
    if minimum_pixel_width < required_width:
        failures.append(f"Visual metadata declares too-low minimum width for {label}: {minimum_pixel_width} < {required_width}")
    if len(safe_area) < 20:
        failures.append(f"Visual metadata has weak safe-area note: {label}")
    if safe_area == LEGACY_SAFE_AREA_DEFAULT:
        failures.append(f"Visual metadata still uses legacy weak safe-area default: {label}")
    if not any(token in safe_area.lower() for token in ("protect", "aspect", "tower", "bridge", "castle", "windmill", "monument", "facade", "skyline", "waterfront", "harbor", "harbour")):
        failures.append(f"Visual metadata safe-area note does not express crop protection: {label} -> {safe_area}")
    for marker in FORBIDDEN_VISUAL_MARKERS:
        if marker in searchable:
            failures.append(f"Visual metadata contains forbidden marker '{marker}': {label}")
            break
    if role == "culture" and "culture" not in why.lower() and "museum" not in title.lower():
        failures.append(f"Culture visual lacks culture/museum purpose wording: {label}")
    if role in {"night"} and not any(token in searchable for token in ("night", "evening", "lights", "lit")):
        failures.append(f"Night visual lacks night/evening purpose wording: {label}")


def assert_figures(media: dict[str, str], failures: list[str]) -> None:
    place_urls = {normalize_url(url) for key, url in media.items() if key.startswith(("nl-city-", "nl-province-"))}
    for figure_id, name, url in historical_figures():
        normalized = normalize_url(url)
        lower = unquote(url).lower()
        if not url_is_valid_https(url):
            failures.append(f"Invalid figure portrait URL for {name}: {url}")
        if normalized in place_urls:
            failures.append(f"Figure thumbnail uses place/province image for {name}: {url}")
        if any(token in lower for token in BAD_LANDSCAPE_TOKENS):
            failures.append(f"Figure thumbnail contains place-landscape token for {name}: {url}")


def assert_windmill_media_not_used_as_runtime_fallback(media: dict[str, str], failures: list[str]) -> None:
    """Kinderdijk/windmill media is allowed as culture content, not as a generic runtime fallback."""
    content_text = read(CONTENT_MEDIA)
    if not re.search(
        r'id:\s*"content-culture-kinderdijk-windmills".*?type:\s*\.cultureHero',
        content_text,
        re.S,
    ):
        failures.append("Culture windmill media asset missing or not marked as cultureHero.")

    legacy_kinderdijk_token = "kinderdijk_windmills.jpg"
    for place_id, url in media.items():
        lower = unquote(url).lower()
        if legacy_kinderdijk_token in lower:
            failures.append(f"Legacy Kinderdijk runtime place media still assigned to {place_id}: {url}")

    for figure_id, name, url in historical_figures():
        lower = unquote(url).lower()
        if legacy_kinderdijk_token in lower:
            failures.append(f"Historical figure thumbnail still uses legacy Kinderdijk media for {name}: {url}")


def assert_specific_regressions(media: dict[str, str], failures: list[str]) -> None:
    haarlem = unquote(media.get("nl-city-noord_holland-haarlem", "")).lower()
    if not haarlem:
        failures.append("Haarlem city hero missing from curated registry.")
    if "cloud" in haarlem or "sky" in haarlem:
        failures.append(f"Haarlem uses sky/cloud image: {haarlem}")

    for city_id, tokens in REQUIRED_CITY_TOKENS.items():
        url = unquote(media.get(city_id, "")).lower().replace("%20", "_").replace(" ", "_")
        if not url:
            failures.append(f"Required city hero missing: {city_id}")
            continue
        if not any(token in url for token in tokens):
            failures.append(f"Required city hero may not match landmark for {city_id}: {url}")

    for province_id in ("nl-province-utrecht", "nl-province-drenthe"):
        url = unquote(media.get(province_id, "")).lower()
        if not url:
            failures.append(f"{province_id} hero missing from curated registry.")
        elif any(token in url for token in WINDMILL_TOKENS):
            failures.append(f"{province_id} uses generic windmill fallback: {url}")

    nl_data = read(NETHERLANDS_DATA).lower()
    for place in ("binnenhof", "peacepalace", "scheveningen", "mauritshuis"):
        match = re.search(rf'attraction\(id:\s*"{place}".*?imageurl:\s*"([^"]+)"', nl_data, re.S)
        if not match:
            failures.append(f"Den Haag attraction missing: {place}")
            continue
        url = unquote(match.group(1)).lower()
        if any(token in url for token in WINDMILL_TOKENS):
            failures.append(f"Den Haag attraction {place} uses windmill image: {url}")


def assert_urls_and_metadata(media: dict[str, str], failures: list[str]) -> None:
    for file_name, url in image_urls_in_files():
        if not url_is_valid_https(url):
            failures.append(f"Invalid or non-HTTPS image URL in {file_name}: {url}")

    verified_text = read(VERIFIED)
    for place_id in media:
        if place_id.startswith("nl-city-") or place_id.startswith("nl-province-"):
            if place_id == "nl-city-noord_brabant-den_bosch":
                continue
            if place_id not in verified_text:
                failures.append(f"Curated place lacks verified metadata entry: {place_id}")


def main() -> int:
    failures: list[str] = []
    media = curated_media()

    assert_duplicate_city_urls(media, failures)
    assert_province_city_card_duplicates(media, failures)
    assert_province_catalog_city_role_coverage(failures)
    assert_province_role_coverage(failures)
    assert_visual_metadata_contracts(failures)
    assert_visual_subject_uniqueness(failures)
    assert_tourism_catalog_contracts(failures)
    assert_runtime_attraction_contracts(failures)
    assert_figures(media, failures)
    assert_windmill_media_not_used_as_runtime_fallback(media, failures)
    assert_specific_regressions(media, failures)
    assert_urls_and_metadata(media, failures)

    if failures:
        print("IMAGE RUNTIME DATA QA FAILED")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("IMAGE RUNTIME DATA QA PASSED")
    print(f"Curated place images checked: {len(media)}")
    print(f"Province city cards checked: {len(province_catalog_city_ids())}")
    print(f"Province catalog city role sets checked: {len(province_catalog_city_ids())}")
    print(f"Province visual role sets checked: {len(province_ids())}")
    print(f"Tourism catalog records checked: {len(tourism_catalog_records())}")
    print(f"Runtime city attractions checked: {len(runtime_attractions())}")
    print(f"Historical figure portraits checked: {len(historical_figures())}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
