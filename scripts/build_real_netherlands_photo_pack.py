#!/usr/bin/env python3
"""
Build a real-photo Netherlands image pack for YouNew.

This script intentionally does not generate AI or illustrative fallback images.
It resolves real Wikimedia Commons photo files, verifies permissive license
metadata, downloads originals, crops/converts app-ready WebP variants, writes
manifests/attribution, creates a contact sheet, validates, and packages a ZIP.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import html
import json
import re
import shutil
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import zipfile
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont, ImageOps, UnidentifiedImageError


BASE_DIR = Path("netherlands_app_images")
ORIGINALS_DIR = BASE_DIR / "originals"
READY_DIR = BASE_DIR / "app_ready"
METADATA_DIR = BASE_DIR / "metadata"
PREVIEW_DIR = BASE_DIR / "preview"
ZIP_PATH = Path("netherlands_app_images_v1.zip")
TODAY = date.today().isoformat()
USER_AGENT = "YouNewGuidePhotoCurator/1.0 (https://younew.nl; real-photo app asset build)"

ALLOWED_LICENSE_MARKERS = (
    "cc by",
    "cc-by",
    "cc0",
    "public domain",
    "pd",
)
BLOCKED_LICENSE_MARKERS = (
    "noncommercial",
    "non-commercial",
    "no derivatives",
    "no-derivatives",
    "fair use",
    "editorial",
)


@dataclass(frozen=True)
class AssetSpec:
    asset_id: str
    category: str
    city: str
    province: str
    landmark_name: str
    short_description: str
    final_width: int
    final_height: int
    queries: tuple[str, ...]
    focal_x: float = 0.5
    focal_y: float = 0.5

    @property
    def filename(self) -> str:
        return f"{self.asset_id}.webp"


def city_slug(city: str) -> str:
    return {
        "Den Haag": "den_haag",
        "Den Bosch": "den_bosch",
    }.get(city, city.lower().replace(" ", "_").replace("-", "_"))


CITY_DATA = [
    ("Amsterdam", "North Holland", "Damrak canal houses", ("Amsterdam canal houses Damrak blue hour", "Amsterdam canal houses Oude Kerk reflection")),
    ("Rotterdam", "South Holland", "Erasmus Bridge skyline", ("Rotterdam Erasmusbrug skyline", "Erasmusbrug Rotterdam Euromast")),
    ("Den Haag", "South Holland", "Peace Palace and diplomatic city", ("Peace Palace Den Haag exterior", "The Hague Peace Palace")),
    ("Utrecht", "Utrecht", "Dom Tower and Oudegracht", ("Utrecht Domtoren Oudegracht", "Utrecht Oudegracht Dom Tower")),
    ("Leiden", "South Holland", "Oude Vest canal", ("Leiden Oude Vest canal", "Leiden canals historic centre")),
    ("Haarlem", "North Holland", "Grote Markt Haarlem", ("Haarlem Grote Markt Sint Bavo", "Haarlem Grote Markt")),
    ("Delft", "South Holland", "Delft Markt and churches", ("Delft Markt Nieuwe Kerk", "Delft Oude Kerk canal")),
    ("Alkmaar", "North Holland", "Waagplein and cheese market", ("Alkmaar Waagplein Waag", "Alkmaar cheese market Waag")),
    ("Hoorn", "North Holland", "Historic harbor", ("Hoorn harbor Hoofdtoren", "Haven Hoorn Hoofdtoren")),
    ("Gouda", "South Holland", "Gouda Markt and town hall", ("Gouda Markt Stadhuis", "Gouda Town Hall Markt")),
    ("Maastricht", "Limburg", "Vrijthof and southern city", ("Maastricht Vrijthof", "Maastricht Maas Sint Servaasbrug")),
    ("Groningen", "Groningen", "Grote Markt and Martinitoren", ("Groningen Grote Markt Martinitoren", "Groningen Martinitoren")),
    ("Eindhoven", "North Brabant", "Witte Dame and design city", ("Eindhoven Witte Dame", "Eindhoven Strijp-S")),
    ("Breda", "North Brabant", "Grote Markt Breda", ("Breda Grote Markt", "Breda harbour")),
    ("Nijmegen", "Gelderland", "Waalbrug and river city", ("Nijmegen Waalbrug", "Nijmegen Waalkade")),
    ("Arnhem", "Gelderland", "John Frost Bridge and Rhine", ("Arnhem John Frost Bridge", "Arnhem city centre")),
    ("Den Bosch", "North Brabant", "Sint-Janskathedraal", ("Sint-Janskathedraal 's-Hertogenbosch", "Den Bosch Binnendieze")),
    ("Zwolle", "Overijssel", "Sassenpoort and Hanseatic city", ("Zwolle Sassenpoort", "Zwolle Grote Markt")),
    ("Leeuwarden", "Friesland", "Oldehove and Frisian capital", ("Leeuwarden Oldehove", "Leeuwarden Nieuwestad")),
    ("Middelburg", "Zeeland", "Middelburg town hall", ("Middelburg Stadhuis", "Middelburg canal")),
]

CITY_CARD_QUERY_OVERRIDES = {
    "Amsterdam": ("Amsterdam Keizersgracht Reguliersgracht bridge", "Amsterdam canal bridge"),
    "Rotterdam": ("Rotterdam Cube Houses", "Rotterdam skyline"),
    "Den Haag": ("Den Haag Binnenhof Hofvijver", "The Hague Hofvijver Binnenhof"),
    "Utrecht": ("Utrecht Oudegracht wharf", "Utrecht Centraal station"),
    "Leiden": ("Leiden Rapenburg university", "Leiden Molen de Valk"),
    "Haarlem": ("Haarlem hofje", "Teylers Museum Haarlem"),
    "Delft": ("Delft Oude Delft canal", "Prinsenhof Delft"),
    "Alkmaar": ("Alkmaar Molen van Piet", "Alkmaar Accijnstoren"),
    "Hoorn": ("Hoorn Oosterkerk", "Hoorn Roode Steen Waag"),
    "Gouda": ("Gouda Sint-Janskerk", "Gouda canals"),
    "Maastricht": ("Maastricht Sint Servaasbrug", "Maastricht Dominicanen bookstore exterior"),
    "Groningen": ("Groningen Academiegebouw", "Groninger Museum exterior"),
    "Eindhoven": ("Eindhoven Strijp-S", "Eindhoven Philips Museum"),
    "Breda": ("Breda haven", "Breda Kasteel"),
    "Nijmegen": ("Nijmegen Stevenskerk", "Nijmegen Valkhof"),
    "Arnhem": ("Arnhem Koepelkerk", "Arnhem Sonsbeek Park"),
    "Den Bosch": ("Den Bosch Binnendieze", "Jheronimus Bosch Art Center exterior"),
    "Zwolle": ("Zwolle Grote Markt", "Zwolle Peperbus"),
    "Leeuwarden": ("Leeuwarden Nieuwestad", "Leeuwarden Waag"),
    "Middelburg": ("Middelburg Lange Jan", "Middelburg canal"),
}

LANDMARK_DATA = [
    ("nl_amsterdam_canals_landmark_01", "Amsterdam canals", "Amsterdam", "North Holland", "Amsterdam canal houses", ("Amsterdam canal houses", "Amsterdam canals golden hour")),
    ("nl_rijksmuseum_landmark_01", "Rijksmuseum exterior", "Amsterdam", "North Holland", "Rijksmuseum exterior facade", ("Rijksmuseum Amsterdam exterior", "Rijksmuseum facade Amsterdam")),
    ("nl_dam_square_landmark_01", "Dam Square and Royal Palace", "Amsterdam", "North Holland", "Dam Square and Royal Palace", ("Dam Square Amsterdam Royal Palace", "Koninklijk Paleis Amsterdam Dam Square")),
    ("nl_erasmus_bridge_landmark_01", "Erasmus Bridge", "Rotterdam", "South Holland", "Erasmus Bridge", ("Erasmusbrug Rotterdam bridge", "Erasmus Bridge Rotterdam")),
    ("nl_markthal_landmark_01", "Markthal Rotterdam", "Rotterdam", "South Holland", "Markthal exterior", ("Markthal Rotterdam exterior", "Rotterdam Markthal")),
    ("nl_cube_houses_landmark_01", "Cube Houses Rotterdam", "Rotterdam", "South Holland", "Cube Houses", ("Cube Houses Rotterdam", "Kubuswoningen Rotterdam")),
    ("nl_binnenhof_landmark_01", "Binnenhof", "Den Haag", "South Holland", "Binnenhof parliament complex", ("Binnenhof Den Haag", "The Hague Binnenhof")),
    ("nl_peace_palace_landmark_01", "Peace Palace", "Den Haag", "South Holland", "Peace Palace exterior", ("Peace Palace Den Haag exterior", "Friedenspalast Den Haag")),
    ("nl_scheveningen_landmark_01", "Scheveningen beach or pier", "Den Haag", "South Holland", "Scheveningen pier and beach", ("Scheveningen pier", "Scheveningen beach")),
    ("nl_dom_tower_landmark_01", "Dom Tower Utrecht", "Utrecht", "Utrecht", "Dom Tower", ("Domtoren Utrecht", "Dom Tower Utrecht")),
    ("nl_kinderdijk_landmark_01", "Kinderdijk windmills", "", "South Holland", "Kinderdijk windmills", ("Kinderdijk windmills Nederwaard", "Kinderdijk molens")),
    ("nl_zaanse_schans_landmark_01", "Zaanse Schans", "Zaanstad", "North Holland", "Zaanse Schans windmills", ("Zaanse Schans windmills", "Zaanse Schans")),
    ("nl_keukenhof_landmark_01", "Keukenhof gardens", "Lisse", "South Holland", "Keukenhof gardens", ("Keukenhof tulips windmill", "Keukenhof flower fields")),
    ("nl_giethoorn_landmark_01", "Giethoorn canals", "Giethoorn", "Overijssel", "Giethoorn canals", ("Giethoorn canals houses", "Giethoorn Netherlands channels")),
    ("nl_delft_markt_landmark_01", "Delft Markt and Nieuwe Kerk", "Delft", "South Holland", "Delft Markt and Nieuwe Kerk", ("Delft Markt Nieuwe Kerk", "Delft Nieuwe Kerk Markt")),
    ("nl_leiden_canals_landmark_01", "Leiden canals", "Leiden", "South Holland", "Leiden canals", ("Leiden canals bridges", "Leiden Burcht Pieterskerk")),
    ("nl_gouda_town_hall_landmark_01", "Gouda Town Hall", "Gouda", "South Holland", "Gouda Town Hall", ("Gouda town hall Markt", "Gouda Stadhuis Markt")),
    ("nl_vrijthof_landmark_01", "Vrijthof Maastricht", "Maastricht", "Limburg", "Vrijthof square", ("Maastricht Vrijthof square", "Vrijthof Maastricht")),
    ("nl_hoge_veluwe_landmark_01", "De Hoge Veluwe National Park", "", "Gelderland", "Hoge Veluwe landscape", ("Hoge Veluwe National Park", "De Hoge Veluwe heathland")),
    ("nl_texel_landmark_01", "Texel dunes or Wadden Sea", "Texel", "North Holland", "Texel dunes", ("Texel dunes Wadden Sea", "De Hors Texel dunes")),
]

PROVINCE_DATA = [
    ("nl_north_holland_province_01", "North Holland", "Windmills, dunes, or historic cityscape", ("Zaanse Schans windmills North Holland", "Texel dunes North Holland", "Haarlem Grote Markt North Holland")),
    ("nl_south_holland_province_01", "South Holland", "Kinderdijk windmill landscape", ("South Holland Kinderdijk windmills", "Kinderdijk Nederwaard molens")),
    ("nl_utrecht_province_01", "Utrecht", "Utrechtse Heuvelrug landscape", ("Utrechtse Heuvelrug landscape", "Utrecht province landscape")),
    ("nl_zeeland_province_01", "Zeeland", "Oosterscheldekering and coast", ("Zeeland Oosterscheldekering", "Zeeland dunes beach")),
    ("nl_north_brabant_province_01", "North Brabant", "Biesbosch National Park", ("Biesbosch National Park", "North Brabant Biesbosch")),
    ("nl_limburg_province_01", "Limburg", "South Limburg hills", ("Limburg hills Vijlen", "South Limburg landscape")),
    ("nl_gelderland_province_01", "Gelderland", "Hoge Veluwe heathland", ("Gelderland Hoge Veluwe", "Veluwe heathland")),
    ("nl_overijssel_province_01", "Overijssel", "Giethoorn water village", ("Overijssel Giethoorn canals", "Giethoorn Overijssel")),
    ("nl_flevoland_province_01", "Flevoland", "Oostvaardersplassen reclaimed land", ("Flevoland Oostvaardersplassen", "Oostvaardersplassen nature")),
    ("nl_friesland_province_01", "Friesland", "Frisian coast and water", ("Friesland coast Wadden Sea", "Frisian lakes sunrise")),
    ("nl_groningen_province_01", "Groningen", "Groningen city canals", ("Groningen Hoge der Aa", "Groningen province landscape")),
    ("nl_drenthe_province_01", "Drenthe", "Hunebed or heathland", ("Drenthe Hunebed D27", "Dwingelderveld heath Drenthe")),
]


def asset_specs() -> list[AssetSpec]:
    specs: list[AssetSpec] = []
    for city, province, desc, queries in CITY_DATA:
        specs.append(AssetSpec(
            asset_id=f"nl_{city_slug(city)}_hero_01",
            category="city_hero",
            city=city,
            province=province,
            landmark_name="",
            short_description=desc,
            final_width=1920,
            final_height=1080,
            queries=queries,
        ))
    for city, province, _, _ in CITY_DATA:
        specs.append(AssetSpec(
            asset_id=f"nl_{city_slug(city)}_card_01",
            category="city_card",
            city=city,
            province=province,
            landmark_name="",
            short_description=f"{city} city card photograph",
            final_width=1200,
            final_height=1500,
            queries=CITY_CARD_QUERY_OVERRIDES[city],
        ))
    for asset_id, landmark, city, province, desc, queries in LANDMARK_DATA:
        specs.append(AssetSpec(
            asset_id=asset_id,
            category="landmark",
            city=city,
            province=province,
            landmark_name=landmark,
            short_description=desc,
            final_width=1600,
            final_height=1200,
            queries=queries,
        ))
    for asset_id, province, desc, queries in PROVINCE_DATA:
        specs.append(AssetSpec(
            asset_id=asset_id,
            category="province",
            city="",
            province=province,
            landmark_name="",
            short_description=desc,
            final_width=1920,
            final_height=1080,
            queries=queries,
        ))
    if len(specs) != 72:
        raise RuntimeError(f"Expected 72 assets, got {len(specs)}")
    return specs


def request_json(url: str, timeout: int = 45) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return json.loads(response.read().decode("utf-8"))


def download_bytes(url: str, timeout: int = 120) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=timeout) as response:
        return response.read()


def api(params: dict[str, object]) -> dict:
    query = urllib.parse.urlencode(params)
    return request_json(f"https://commons.wikimedia.org/w/api.php?{query}")


def clean_html(value: str) -> str:
    value = html.unescape(value or "")
    value = re.sub(r"<[^>]+>", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip()


def search_titles(query: str, limit: int = 15) -> list[str]:
    payload = api({
        "action": "query",
        "format": "json",
        "list": "search",
        "srnamespace": 6,
        "srlimit": limit,
        "srsearch": query,
    })
    return [item["title"] for item in payload.get("query", {}).get("search", [])]


def image_info(title: str, thumb_width: int) -> dict | None:
    payload = api({
        "action": "query",
        "format": "json",
        "prop": "imageinfo",
        "iiprop": "url|size|mime|extmetadata",
        "iiurlwidth": thumb_width,
        "titles": title,
    })
    pages = payload.get("query", {}).get("pages", {})
    page = next(iter(pages.values()), {})
    infos = page.get("imageinfo") or []
    if not infos:
        return None
    info = infos[0]
    info["title"] = page.get("title", title)
    return info


def license_allowed(info: dict) -> tuple[bool, str]:
    meta = info.get("extmetadata", {})
    license_short = clean_html(meta.get("LicenseShortName", {}).get("value", ""))
    usage_terms = clean_html(meta.get("UsageTerms", {}).get("value", ""))
    license_url = clean_html(meta.get("LicenseUrl", {}).get("value", ""))
    haystack = f"{license_short} {usage_terms} {license_url}".lower()
    if any(marker in haystack for marker in BLOCKED_LICENSE_MARKERS):
        return False, license_short or usage_terms or "blocked license"
    if any(marker in haystack for marker in ALLOWED_LICENSE_MARKERS):
        return True, license_short or usage_terms or "Permissive Commons license"
    return False, license_short or usage_terms or "unknown license"


def metadata_from_info(info: dict) -> dict[str, object]:
    meta = info.get("extmetadata", {})
    artist = clean_html(meta.get("Artist", {}).get("value", ""))
    credit = clean_html(meta.get("Credit", {}).get("value", ""))
    license_short = clean_html(meta.get("LicenseShortName", {}).get("value", "")) or "Wikimedia Commons file license"
    license_url = clean_html(meta.get("LicenseUrl", {}).get("value", ""))
    attribution = clean_html(meta.get("Attribution", {}).get("value", ""))
    photographer = attribution or artist or credit or "Wikimedia Commons contributor"
    ready = f"{info['title']}; {photographer}; {license_short}"
    return {
        "source_page_url": info.get("descriptionurl", ""),
        "direct_download_url": info.get("url", ""),
        "photographer": photographer,
        "license_name": license_short,
        "license_url": license_url,
        "attribution_required": "cc0" not in license_short.lower() and "public domain" not in license_short.lower(),
        "ready_attribution_text": ready,
    }


def make_dirs() -> None:
    for path in [
        ORIGINALS_DIR / "cities",
        ORIGINALS_DIR / "landmarks",
        ORIGINALS_DIR / "provinces",
        READY_DIR / "city_heroes",
        READY_DIR / "city_cards",
        READY_DIR / "landmarks",
        READY_DIR / "provinces",
        METADATA_DIR,
        PREVIEW_DIR,
    ]:
        path.mkdir(parents=True, exist_ok=True)


def category_original_dir(category: str) -> Path:
    if category in {"city_hero", "city_card"}:
        return ORIGINALS_DIR / "cities"
    if category == "landmark":
        return ORIGINALS_DIR / "landmarks"
    if category == "province":
        return ORIGINALS_DIR / "provinces"
    raise ValueError(category)


def category_ready_dir(category: str) -> Path:
    return {
        "city_hero": READY_DIR / "city_heroes",
        "city_card": READY_DIR / "city_cards",
        "landmark": READY_DIR / "landmarks",
        "province": READY_DIR / "provinces",
    }[category]


def original_extension(info: dict) -> str:
    mime = (info.get("mime") or "").lower()
    if "png" in mime:
        return ".png"
    if "webp" in mime:
        return ".webp"
    return ".jpg"


def focal_crop(img: Image.Image, width: int, height: int, fx: float, fy: float) -> Image.Image:
    src_w, src_h = img.size
    target_ratio = width / height
    source_ratio = src_w / src_h
    if source_ratio > target_ratio:
        new_w = int(src_h * target_ratio)
        left = max(0, min(int(src_w * fx) - new_w // 2, src_w - new_w))
        box = (left, 0, left + new_w, src_h)
    else:
        new_h = int(src_w / target_ratio)
        top = max(0, min(int(src_h * fy) - new_h // 2, src_h - new_h))
        box = (0, top, src_w, top + new_h)
    return img.crop(box).resize((width, height), Image.Resampling.LANCZOS)


def process_original(spec: AssetSpec, original_path: Path, ready_path: Path) -> tuple[int, int]:
    with Image.open(original_path) as img:
        img = ImageOps.exif_transpose(img).convert("RGB")
        original_size = img.size
        ready = focal_crop(img, spec.final_width, spec.final_height, spec.focal_x, spec.focal_y)
        ready_path.parent.mkdir(parents=True, exist_ok=True)
        ready.save(ready_path, "WEBP", quality=85, method=6)
    return original_size


def resolve_asset(spec: AssetSpec, used_titles: set[str]) -> tuple[dict, str]:
    min_width = 2000 if spec.category in {"city_hero", "province"} else 1200
    min_height = 900 if spec.category in {"city_hero", "province"} else 900
    reasons: list[str] = []
    thumb_width = max(spec.final_width, 1800)
    for query in spec.queries:
        titles = search_titles(query)
        time.sleep(0.25)
        for title in titles:
            if title in used_titles:
                reasons.append(f"{title}: duplicate title")
                continue
            info = image_info(title, thumb_width=thumb_width)
            time.sleep(0.25)
            if not info:
                reasons.append(f"{title}: no imageinfo")
                continue
            mime = (info.get("mime") or "").lower()
            if not any(kind in mime for kind in ("jpeg", "jpg", "png", "webp")):
                reasons.append(f"{title}: unsupported mime {mime}")
                continue
            width = int(info.get("width") or 0)
            height = int(info.get("height") or 0)
            if width < min_width or height < min_height:
                reasons.append(f"{title}: too small {width}x{height}")
                continue
            allowed, license_label = license_allowed(info)
            if not allowed:
                reasons.append(f"{title}: license rejected {license_label}")
                continue
            return info, query
    raise RuntimeError("; ".join(reasons[-8:]) or "no suitable Commons candidates")


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def phash(path: Path) -> str:
    with Image.open(path) as img:
        img = img.convert("L").resize((8, 8), Image.Resampling.BILINEAR)
        pixels = list(img.getdata())
    avg = sum(pixels) / len(pixels)
    return "".join("1" if pixel > avg else "0" for pixel in pixels)


def hamming(left: str, right: str) -> int:
    return sum(a != b for a, b in zip(left, right))


def download_original(url: str, target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    part = target.with_suffix(target.suffix + ".part")
    data = download_bytes(url)
    if len(data) < 25_000:
        raise RuntimeError(f"downloaded file too small: {len(data)} bytes")
    part.write_bytes(data)
    try:
        with Image.open(part) as img:
            img.verify()
    except UnidentifiedImageError as exc:
        part.unlink(missing_ok=True)
        raise RuntimeError(f"downloaded file is not a valid image: {exc}") from exc
    part.replace(target)


def build_pack(clean: bool) -> list[dict[str, object]]:
    if clean:
        if BASE_DIR.exists():
            shutil.rmtree(BASE_DIR)
        if ZIP_PATH.exists():
            ZIP_PATH.unlink()
    make_dirs()
    manifest: list[dict[str, object]] = []
    missing: list[str] = []
    used_titles: set[str] = set()
    for index, spec in enumerate(asset_specs(), 1):
        print(f"[{index:02d}/72] resolving {spec.asset_id}", flush=True)
        try:
            info, query = resolve_asset(spec, used_titles)
            used_titles.add(info["title"])
            ext = original_extension(info)
            original_path = category_original_dir(spec.category) / f"{spec.asset_id}{ext}"
            ready_path = category_ready_dir(spec.category) / spec.filename
            print(f"       {info['title']}", flush=True)
            download_original(str(info["url"]), original_path)
            original_width, original_height = process_original(spec, original_path, ready_path)
            meta = metadata_from_info(info)
            manifest.append({
                "asset_id": spec.asset_id,
                "filename": spec.filename,
                "category": spec.category,
                "city": spec.city,
                "province": spec.province,
                "landmark_name": spec.landmark_name,
                "short_description": spec.short_description,
                "original_width": original_width,
                "original_height": original_height,
                "final_width": spec.final_width,
                "final_height": spec.final_height,
                **meta,
                "date_downloaded": TODAY,
                "notes": f"Resolved from Wikimedia Commons search query: {query}. Commons title: {info['title']}. Original saved as {original_path.name}.",
            })
            time.sleep(0.6)
        except Exception as exc:
            message = f"{spec.asset_id}: {exc}"
            print(f"[-] {message}", file=sys.stderr, flush=True)
            missing.append(message)
    write_metadata(manifest, missing)
    report = validate(manifest)
    create_contact_sheet(manifest)
    package(report)
    return manifest


def write_metadata(manifest: list[dict[str, object]], missing: list[str]) -> None:
    json_path = METADATA_DIR / "manifest.json"
    csv_path = METADATA_DIR / "manifest.csv"
    attribution_path = METADATA_DIR / "attribution.md"
    missing_path = METADATA_DIR / "missing_or_replaced_assets.md"
    json_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    fields = [
        "asset_id", "filename", "category", "city", "province", "landmark_name",
        "short_description", "original_width", "original_height", "final_width",
        "final_height", "source_page_url", "direct_download_url", "photographer",
        "license_name", "license_url", "attribution_required",
        "ready_attribution_text", "date_downloaded", "notes",
    ]
    with csv_path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fields)
        writer.writeheader()
        for row in manifest:
            writer.writerow({field: row.get(field, "") for field in fields})
    lines = ["# Attribution", ""]
    for item in manifest:
        lines.append(f"- `{item['asset_id']}`: {item['ready_attribution_text']} — {item['source_page_url']}")
    attribution_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    if missing:
        missing_lines = ["# Missing Or Replaced Assets", "", "The strict real-photo build could not resolve these assets:", ""]
        missing_lines.extend(f"- {item}" for item in missing)
    else:
        missing_lines = ["# Missing Or Replaced Assets", "", "No missing assets. All 72 slots resolved to real Wikimedia Commons photo files."]
    missing_path.write_text("\n".join(missing_lines) + "\n", encoding="utf-8")


def validate(manifest: list[dict[str, object]]) -> dict[str, object]:
    failures: list[str] = []
    warnings: list[str] = []
    if len(manifest) != 72:
        failures.append(f"manifest contains {len(manifest)} entries, expected 72")
    seen_urls: set[str] = set()
    seen_sha: set[str] = set()
    seen_phash: dict[str, str] = {}
    for item in manifest:
        asset_id = str(item["asset_id"])
        ready_path = category_ready_dir(str(item["category"])) / str(item["filename"])
        if not ready_path.exists():
            failures.append(f"{asset_id}: ready file missing")
            continue
        url = str(item["direct_download_url"])
        if url in seen_urls:
            failures.append(f"{asset_id}: duplicate source URL")
        seen_urls.add(url)
        with Image.open(ready_path) as img:
            if img.format != "WEBP":
                failures.append(f"{asset_id}: expected WEBP, got {img.format}")
            expected = (int(item["final_width"]), int(item["final_height"]))
            if img.size != expected:
                failures.append(f"{asset_id}: expected {expected}, got {img.size}")
            if img.mode not in {"RGB", "RGBA"}:
                warnings.append(f"{asset_id}: unexpected color mode {img.mode}")
        digest = sha256(ready_path)
        if digest in seen_sha:
            failures.append(f"{asset_id}: duplicate SHA-256")
        seen_sha.add(digest)
        current_phash = phash(ready_path)
        for previous_id, previous_phash in seen_phash.items():
            if hamming(current_phash, previous_phash) < 3:
                warnings.append(f"{asset_id}: near duplicate of {previous_id}")
        seen_phash[asset_id] = current_phash
    report = {
        "passed_count": len(manifest),
        "expected_count": 72,
        "failure_count": len(failures),
        "failures": failures,
        "warning_count": len(warnings),
        "warnings": warnings,
    }
    (METADATA_DIR / "validation_report.json").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return report


def create_contact_sheet(manifest: Iterable[dict[str, object]]) -> None:
    cols, rows = 8, 9
    thumb_w, thumb_h = 200, 150
    label_h, pad = 32, 20
    sheet = Image.new("RGB", (cols * (thumb_w + pad) + pad, rows * (thumb_h + label_h + pad) + pad), (242, 244, 246))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for index, item in enumerate(manifest):
        ready_path = category_ready_dir(str(item["category"])) / str(item["filename"])
        if not ready_path.exists():
            continue
        row, col = divmod(index, cols)
        x = pad + col * (thumb_w + pad)
        y = pad + row * (thumb_h + label_h + pad)
        with Image.open(ready_path) as img:
            img = ImageOps.contain(img.convert("RGB"), (thumb_w, thumb_h), Image.Resampling.LANCZOS)
            bg = Image.new("RGB", (thumb_w, thumb_h), (226, 230, 235))
            bg.paste(img, ((thumb_w - img.width) // 2, (thumb_h - img.height) // 2))
            sheet.paste(bg, (x, y))
        draw.text((x, y + thumb_h + 6), str(item["asset_id"])[:28], fill=(32, 40, 48), font=font)
    sheet.save(PREVIEW_DIR / "contact_sheet.jpg", "JPEG", quality=88)


def package(report: dict[str, object]) -> None:
    if report["failure_count"]:
        raise RuntimeError("Validation has failures; refusing to package. See validation_report.json.")
    if ZIP_PATH.exists():
        ZIP_PATH.unlink()
    with zipfile.ZipFile(ZIP_PATH, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(BASE_DIR.rglob("*")):
            if path.is_file():
                archive.write(path, path.as_posix())


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--clean", action="store_true", help="Remove previous output before building.")
    args = parser.parse_args()
    try:
        manifest = build_pack(clean=args.clean)
        print(f"[+] Built {ZIP_PATH} with {len(manifest)} real-photo assets")
        return 0
    except Exception as exc:
        print(f"[-] {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
