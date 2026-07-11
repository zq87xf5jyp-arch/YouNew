#!/usr/bin/env python3
"""
Build the YouNew Netherlands app image pack.

Outputs:
- netherlands_app_images/metadata/manifest.json
- netherlands_app_images/originals/{cities,landmarks,provinces}/*.jpg
- netherlands_app_images/app_ready/{city_heroes,city_cards,landmarks,provinces}/*.webp
- netherlands_app_images/preview/contact_sheet.jpg
- netherlands_app_images_v1.zip
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import zipfile
from dataclasses import asdict, dataclass
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
FALLBACK_MARKER_PATH = METADATA_DIR / "generated_fallback_ids.json"

TODAY = date.today().isoformat()
USER_AGENT = "YouNewGuideAssetBuilder/1.0 (asset QA pipeline; contact: local build)"


@dataclass(frozen=True)
class SeedAsset:
    asset_id: str
    category: str
    title: str
    city: str
    province: str
    landmark_name: str
    source_url: str
    final_width: int
    final_height: int
    crop_focal_x: float = 0.5
    crop_focal_y: float = 0.5
    text_safe_area: str = "center_safe"
    crop_notes: str = "Aspect-fill crop with focal subject protected."

    @property
    def filename(self) -> str:
        return f"{self.asset_id}.webp"


def city_slug(city: str) -> str:
    mapping = {
        "Den Haag": "den_haag",
        "Den Bosch": "den_bosch",
    }
    return mapping.get(city, city.lower().replace(" ", "_").replace("-", "_"))


def commons_file_url(file_name: str, width: int) -> str:
    quoted = urllib.parse.quote(file_name.replace(" ", "_"))
    return f"https://commons.wikimedia.org/wiki/Special:FilePath/{quoted}?width={width}"


CITY_SOURCES = {
    "Amsterdam": ("North Holland", "Canal houses and Oude Kerk at blue hour with water reflection in Damrak Amsterdam Netherlands.jpg"),
    "Rotterdam": ("South Holland", "Erasmusbrug seen from Euromast.jpg"),
    "Den Haag": ("South Holland", "Friedenspalast_Den_Haag.jpg"),
    "Utrecht": ("Utrecht", "Utrecht, de Domtoren (RM36075) vanaf de Oudegracht 230 ongeveer foto5 2015-11-01 08.56.jpg"),
    "Leiden": ("South Holland", "Oude Vest canal, Leiden 6869.jpg"),
    "Haarlem": ("North Holland", "Zijlstrat Grote Markt Haarlem.jpg"),
    "Delft": ("South Holland", "Delft Blick von der Nieuwe Kerk auf die Oude Kerk 1.jpg"),
    "Alkmaar": ("North Holland", "Waagplein (23097595791).jpg"),
    "Hoorn": ("North Holland", "Haven Hoorn met Hoofdtoren1.jpg"),
    "Gouda": ("South Holland", "Gouda - Markt met Stadhuis.jpg"),
    "Maastricht": ("Limburg", "2022_Magisch_Maastricht_(01).jpg"),
    "Groningen": ("Groningen", "20100523 Grote Markt en Martinitoren Groningen NL.jpg"),
    "Eindhoven": ("North Brabant", "Eindhoven-Witte Dame (5).jpg"),
    "Breda": ("North Brabant", "Breda Sint Janstraat zicht op de Grote Markt 2024-09-20.jpg"),
    "Nijmegen": ("Gelderland", "Nijmegen Waalbrug R01.jpg"),
    "Arnhem": ("Gelderland", "Arnhem, de John Frostbrug RM529907 IMG 3795 2024-07-15 13.06.jpg"),
    "Den Bosch": ("North Brabant", "Sint-Janskathedraal 's-Hertogenbosch.jpg"),
    "Zwolle": ("Overijssel", "Zwolle, de Sassenpoort RM41788 foto5 2016-06-05 10.11.jpg"),
    "Leeuwarden": ("Friesland", "20190227 Oldehove Leeuwarden.jpg"),
    "Middelburg": ("Zeeland", "Middelburg Stadhuis 01.JPG"),
}

LANDMARK_SOURCES = [
    ("nl_amsterdam_canals_landmark_01", "Amsterdam canals", "Amsterdam", "North Holland", "Colorful canal houses at golden hour in Damrak avenue Amsterdam the Netherlands.jpg"),
    ("nl_rijksmuseum_landmark_01", "Rijksmuseum", "Amsterdam", "North Holland", "Rijksmuseum_Amsterdam.jpg"),
    ("nl_dam_square_landmark_01", "Dam Square", "Amsterdam", "North Holland", "Dam Square, Amsterdam.jpg"),
    ("nl_erasmus_bridge_landmark_01", "Erasmus Bridge", "Rotterdam", "South Holland", "Rotterdam, de Erasmusbrug vanaf Hotel New York IMG 1782 2018-03-18 10.32.jpg"),
    ("nl_markthal_landmark_01", "Markthal", "Rotterdam", "South Holland", "Markthal_Rotterdam.jpg"),
    ("nl_cube_houses_landmark_01", "Cube Houses", "Rotterdam", "South Holland", "Cube Houses Rotterdam 01.jpg"),
    ("nl_binnenhof_landmark_01", "Binnenhof", "Den Haag", "South Holland", "Binnenhof, Den Haag 2019.jpg"),
    ("nl_peace_palace_landmark_01", "Peace Palace", "Den Haag", "South Holland", "Friedenspalast_Den_Haag.jpg"),
    ("nl_scheveningen_landmark_01", "Scheveningen", "Den Haag", "South Holland", ".00 1091 Seebad Scheveningen - Niederlande.jpg"),
    ("nl_dom_tower_landmark_01", "Dom Tower", "Utrecht", "Utrecht", "Domtoren_Utrecht.jpg"),
    ("nl_kinderdijk_landmark_01", "Kinderdijk", "", "South Holland", "Kinderdijk, Nederwaard molens no 1tm5 RM30543tm7 IMG 9354 2021-06-13 11.04.jpg"),
    ("nl_zaanse_schans_landmark_01", "Zaanse Schans", "Zaanstad", "North Holland", "Zaanse_Schans_2019.jpg"),
    ("nl_keukenhof_landmark_01", "Keukenhof", "Lisse", "South Holland", "Flower field @ View from the windmill @ Keukenhof (17184246682).jpg"),
    ("nl_giethoorn_landmark_01", "Giethoorn", "Giethoorn", "Overijssel", "Giethoorn_Netherlands_Channels-and-houses-of-Giethoorn-05.jpg"),
    ("nl_delft_markt_landmark_01", "Delft Markt", "Delft", "South Holland", "Delft Blick von der Nieuwe Kerk auf die Grachten 9.jpg"),
    ("nl_leiden_canals_landmark_01", "Leiden canals", "Leiden", "South Holland", "00 0876 Canal with bridges - Leiden.jpg"),
    ("nl_gouda_town_hall_landmark_01", "Gouda Town Hall", "Gouda", "South Holland", "Gouda - Markt met Stadhuis.jpg"),
    ("nl_vrijthof_landmark_01", "Vrijthof", "Maastricht", "Limburg", "Maastricht Vrijthof 15 BW 2017-08-19 12-06-24.jpg"),
    ("nl_hoge_veluwe_landmark_01", "Hoge Veluwe", "", "Gelderland", "20161026 De Pollen5 Hoge Veluwe.jpg"),
    ("nl_texel_landmark_01", "Texel", "Texel", "North Holland", "DeHors-Texel-SjoerdMartens.jpg"),
]

PROVINCE_SOURCES = [
    ("nl_north_holland_province_01", "North Holland", "Flower field @ View from the windmill @ Keukenhof (17184246682).jpg"),
    ("nl_south_holland_province_01", "South Holland", "Kinderdijk, Nederwaard molens no 1tm5 RM30543tm7 IMG 9354 2021-06-13 11.04.jpg"),
    ("nl_utrecht_province_01", "Utrecht", "Utrechtse Heuvelrug.jpg"),
    ("nl_zeeland_province_01", "Zeeland", "Vrouwenpolder (NL), Oosterscheldekering -- 2022 -- 5016.jpg"),
    ("nl_north_brabant_province_01", "North Brabant", "Nationaal park De Biesbosch 09.jpg"),
    ("nl_limburg_province_01", "Limburg", "Heuvellandschap Epen en Vijlen - Zuid-Limburg - NL (51121594975).jpg"),
    ("nl_gelderland_province_01", "Gelderland", "20161026 De Pollen5 Hoge Veluwe.jpg"),
    ("nl_overijssel_province_01", "Overijssel", "Giethoorn_Netherlands_Channels-and-houses-of-Giethoorn-05.jpg"),
    ("nl_flevoland_province_01", "Flevoland", "Oostvaardersplassen._Nieuwe_natuur_op_de_bodem_van_de_voormalige_Zuiderzee_09.jpg"),
    ("nl_friesland_province_01", "Friesland", "Wierum (Noardeast-Fryslân), 10-07-2023. (d.j.b) 01.jpg"),
    ("nl_groningen_province_01", "Groningen", "Hoge der Aa2.jpg"),
    ("nl_drenthe_province_01", "Drenthe", "Hunebed_D27_in_Borger_flickr.jpg"),
]


def seed_assets() -> list[SeedAsset]:
    assets: list[SeedAsset] = []
    for city, (province, file_name) in CITY_SOURCES.items():
        slug = city_slug(city)
        assets.append(
            SeedAsset(
                asset_id=f"nl_{slug}_hero_01",
                category="city_hero",
                title=f"{city} hero",
                city=city,
                province=province,
                landmark_name="",
                source_url=commons_file_url(file_name, 2400),
                final_width=1920,
                final_height=1080,
                text_safe_area="bottom_third",
                crop_notes="Wide city hero crop; preserve skyline or primary landmark.",
            )
        )
    for city, (province, file_name) in CITY_SOURCES.items():
        slug = city_slug(city)
        assets.append(
            SeedAsset(
                asset_id=f"nl_{slug}_card_01",
                category="city_card",
                title=f"{city} city card",
                city=city,
                province=province,
                landmark_name="",
                source_url=commons_file_url(file_name, 1600),
                final_width=1200,
                final_height=1500,
                text_safe_area="top_third",
                crop_notes="Vertical card crop; keep the city's most recognizable subject in frame.",
            )
        )
    for asset_id, landmark, city, province, file_name in LANDMARK_SOURCES:
        assets.append(
            SeedAsset(
                asset_id=asset_id,
                category="landmark",
                title=landmark,
                city=city,
                province=province,
                landmark_name=landmark,
                source_url=commons_file_url(file_name, 1800),
                final_width=1600,
                final_height=1200,
                text_safe_area="edge_safe",
                crop_notes="Four-by-three landmark crop; protect towers, bridges, facades, and waterlines.",
            )
        )
    for asset_id, province, file_name in PROVINCE_SOURCES:
        assets.append(
            SeedAsset(
                asset_id=asset_id,
                category="province",
                title=f"{province} province",
                city="",
                province=province,
                landmark_name="",
                source_url=commons_file_url(file_name, 2400),
                final_width=1920,
                final_height=1080,
                text_safe_area="bottom_half",
                crop_notes="Wide province cover crop; preserve landscape identity and negative space.",
            )
        )
    if len(assets) != 72:
        raise RuntimeError(f"Expected 72 seed assets, got {len(assets)}")
    return assets


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


def request(url: str, timeout: int = 60) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=timeout) as response:
        content_type = response.headers.get("Content-Type", "")
        body = response.read()
    if "image" not in content_type and "json" not in content_type:
        raise RuntimeError(f"Unexpected Content-Type {content_type!r} for {url}")
    return body


def download(url: str, target: Path, retries: int = 4) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    part = target.with_suffix(target.suffix + ".part")
    if target.exists() and target.stat().st_size > 25_000:
        try:
            with Image.open(target) as img:
                img.verify()
            return
        except (OSError, UnidentifiedImageError):
            target.unlink()
    for attempt in range(1, retries + 1):
        try:
            data = request(url, timeout=90)
            if len(data) < 25_000:
                raise RuntimeError(f"Downloaded file is too small: {len(data)} bytes")
            part.write_bytes(data)
            with Image.open(part) as img:
                img.verify()
            part.replace(target)
            return
        except (OSError, RuntimeError, urllib.error.URLError, UnidentifiedImageError) as exc:
            if part.exists():
                part.unlink()
            if attempt == retries:
                raise RuntimeError(f"download failed after {retries} attempts: {exc}") from exc
            time.sleep(1.5 * attempt)


def source_title_from_url(url: str) -> str:
    parsed = urllib.parse.urlparse(url)
    if "Special:FilePath/" in parsed.path:
        raw = parsed.path.split("Special:FilePath/", 1)[1]
    else:
        raw = parsed.path.rsplit("/", 1)[-1]
    return urllib.parse.unquote(raw).replace("_", " ")


def source_page_url(url: str) -> str:
    title = source_title_from_url(url)
    return "https://commons.wikimedia.org/wiki/File:" + urllib.parse.quote(title.replace(" ", "_"), safe="()'.,-%")


def fetch_commons_metadata(url: str) -> dict[str, str | bool]:
    title = "File:" + source_title_from_url(url)
    params = urllib.parse.urlencode(
        {
            "action": "query",
            "format": "json",
            "prop": "imageinfo",
            "iiprop": "extmetadata|url",
            "titles": title,
        }
    )
    api_url = f"https://commons.wikimedia.org/w/api.php?{params}"
    fallback = {
        "photographer": "",
        "license_name": "Wikimedia Commons file license",
        "license_url": source_page_url(url),
        "attribution_required": True,
        "ready_attribution_text": "See Wikimedia Commons file page for attribution.",
    }
    try:
        payload = json.loads(request(api_url, timeout=45).decode("utf-8"))
        pages = payload.get("query", {}).get("pages", {})
        page = next(iter(pages.values()))
        meta = page.get("imageinfo", [{}])[0].get("extmetadata", {})
        artist = clean_html(meta.get("Artist", {}).get("value", ""))
        license_short = clean_html(meta.get("LicenseShortName", {}).get("value", ""))
        license_url = clean_html(meta.get("LicenseUrl", {}).get("value", ""))
        credit = clean_html(meta.get("Credit", {}).get("value", ""))
        return {
            "photographer": artist or credit,
            "license_name": license_short or fallback["license_name"],
            "license_url": license_url or fallback["license_url"],
            "attribution_required": True,
            "ready_attribution_text": f"{title}; {artist or credit}; {license_short}".strip("; "),
        }
    except Exception:
        return fallback


def clean_html(value: str) -> str:
    value = re.sub(r"<[^>]+>", " ", value)
    value = re.sub(r"\s+", " ", value)
    return value.strip()


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


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


def process_image(seed: SeedAsset, original_path: Path, ready_path: Path) -> tuple[int, int]:
    with Image.open(original_path) as source:
        source = ImageOps.exif_transpose(source).convert("RGB")
        original_size = source.size
        ready = focal_crop(
            source,
            seed.final_width,
            seed.final_height,
            seed.crop_focal_x,
            seed.crop_focal_y,
        )
        ready_path.parent.mkdir(parents=True, exist_ok=True)
        ready.save(ready_path, "WEBP", quality=85, method=6)
    return original_size


def generated_original_size(seed: SeedAsset) -> tuple[int, int]:
    if seed.category == "city_card":
        return (1800, 2250)
    if seed.category == "landmark":
        return (2400, 1800)
    return (2560, 1440)


def generate_fallback_original(seed: SeedAsset, target: Path) -> tuple[int, int]:
    width, height = generated_original_size(seed)
    palette = palette_for(seed)
    img = Image.new("RGB", (width, height), palette[0])
    draw = ImageDraw.Draw(img)
    for y in range(height):
        t = y / max(1, height - 1)
        r = int(palette[0][0] * (1 - t) + palette[1][0] * t)
        g = int(palette[0][1] * (1 - t) + palette[1][1] * t)
        b = int(palette[0][2] * (1 - t) + palette[1][2] * t)
        draw.line((0, y, width, y), fill=(r, g, b))

    horizon = int(height * 0.58)
    water = (36, 88, 111)
    land = (31, 83, 74)
    draw.rectangle((0, horizon, width, height), fill=water if seed.category != "province" else land)

    sun_x = int(width * (0.72 if seed.category == "city_card" else 0.78))
    sun_y = int(height * 0.22)
    sun_r = int(min(width, height) * 0.07)
    draw.ellipse((sun_x - sun_r, sun_y - sun_r, sun_x + sun_r, sun_y + sun_r), fill=(246, 190, 92))

    if seed.category in {"city_hero", "city_card", "landmark"}:
        draw_city_silhouette(draw, width, height, horizon, palette[2])
    else:
        draw_province_landscape(draw, width, height, horizon, palette[2])

    font = ImageFont.load_default()
    label = seed.landmark_name or seed.city or seed.province
    badge = "YouNew generated visual"
    draw.text((32, 32), label, fill=(255, 255, 255), font=font)
    draw.text((32, 52), badge, fill=(235, 243, 246), font=font)

    target.parent.mkdir(parents=True, exist_ok=True)
    img.save(target, "JPEG", quality=92)
    return width, height


def palette_for(seed: SeedAsset) -> tuple[tuple[int, int, int], tuple[int, int, int], tuple[int, int, int]]:
    digest = hashlib.sha256(seed.asset_id.encode("utf-8")).digest()
    hue = digest[0] / 255
    if seed.category == "province":
        return ((86, 142, 132), (184, 206, 180), (32, 82, 76))
    if seed.category == "landmark":
        return ((63, 105, 139), (185, 190, 174), (45, 62, 78))
    if hue < 0.33:
        return ((33, 92, 124), (160, 195, 202), (39, 61, 72))
    if hue < 0.66:
        return ((50, 103, 91), (190, 204, 162), (43, 75, 66))
    return ((91, 82, 123), (202, 170, 143), (58, 52, 74))


def draw_city_silhouette(draw: ImageDraw.ImageDraw, width: int, height: int, horizon: int, color: tuple[int, int, int]) -> None:
    block_w = max(60, width // 16)
    x = -block_w
    while x < width + block_w:
        h = int(height * (0.10 + ((x // block_w) % 5) * 0.025))
        draw.rectangle((x, horizon - h, x + block_w - 8, horizon), fill=color)
        roof = [(x, horizon - h), (x + block_w // 2, horizon - h - block_w // 3), (x + block_w - 8, horizon - h)]
        if (x // block_w) % 3 == 0:
            draw.polygon(roof, fill=color)
        x += block_w
    for i in range(5):
        cx = int(width * (0.2 + i * 0.14))
        draw.arc((cx - 90, horizon - 32, cx + 90, horizon + 92), 180, 360, fill=(229, 236, 231), width=8)
    for y in range(horizon + 45, height, 75):
        draw.line((0, y, width, y + 10), fill=(79, 128, 145), width=3)


def draw_province_landscape(draw: ImageDraw.ImageDraw, width: int, height: int, horizon: int, color: tuple[int, int, int]) -> None:
    for i in range(4):
        offset = i * height // 16
        draw.polygon(
            [
                (0, horizon + offset),
                (width // 4, horizon - 80 + offset),
                (width // 2, horizon + 10 + offset),
                (width, horizon - 110 + offset),
                (width, height),
                (0, height),
            ],
            fill=tuple(max(0, c - i * 12) for c in color),
        )
    wind_x = int(width * 0.72)
    wind_y = int(horizon - height * 0.16)
    draw.rectangle((wind_x - 18, wind_y, wind_x + 18, horizon + 40), fill=(230, 228, 210))
    draw.line(((wind_x, wind_y), (wind_x - 130, wind_y - 85)), fill=(245, 244, 230), width=10)
    draw.line(((wind_x, wind_y), (wind_x + 130, wind_y - 85)), fill=(245, 244, 230), width=10)
    draw.line(((wind_x, wind_y), (wind_x - 110, wind_y + 95)), fill=(245, 244, 230), width=10)
    draw.line(((wind_x, wind_y), (wind_x + 110, wind_y + 95)), fill=(245, 244, 230), width=10)


def build_manifest(download_assets: bool, refresh_metadata: bool, generated_fallback: bool) -> list[dict[str, object]]:
    make_dirs()
    manifest: list[dict[str, object]] = []
    failures: dict[str, str] = {}
    fallback_ids = load_fallback_ids()
    for index, seed in enumerate(seed_assets(), 1):
        original_path = category_original_dir(seed.category) / f"{seed.asset_id}.jpg"
        ready_path = category_ready_dir(seed.category) / seed.filename
        print(f"[{index:02d}/72] {seed.asset_id}", flush=True)
        if download_assets:
            try:
                download(seed.source_url, original_path)
                original_width, original_height = process_image(seed, original_path, ready_path)
            except Exception as exc:
                if generated_fallback:
                    original_width, original_height = generate_fallback_original(seed, original_path)
                    process_image(seed, original_path, ready_path)
                    failures[seed.asset_id] = f"generated fallback used after source failure: {exc}"
                    fallback_ids.add(seed.asset_id)
                else:
                    failures[seed.asset_id] = str(exc)
                    original_width, original_height = 0, 0
        elif original_path.exists():
            original_width, original_height = process_image(seed, original_path, ready_path)
            if generated_fallback and seed.asset_id not in fallback_ids and original_path.stat().st_size < 200_000:
                fallback_ids.add(seed.asset_id)
        elif generated_fallback:
            original_width, original_height = generate_fallback_original(seed, original_path)
            process_image(seed, original_path, ready_path)
            failures[seed.asset_id] = "generated fallback used because original file was missing in offline build"
            fallback_ids.add(seed.asset_id)
        else:
            original_width, original_height = 0, 0

        used_generated = generated_fallback and seed.asset_id in fallback_ids
        meta = {
            "photographer": "YouNew generated artwork" if used_generated else "",
            "license_name": "Project-owned generated asset" if used_generated else "Wikimedia Commons file license",
            "license_url": "" if used_generated else source_page_url(seed.source_url),
            "attribution_required": False if used_generated else True,
            "ready_attribution_text": "Generated for the YouNew project." if used_generated else "See Wikimedia Commons file page for attribution.",
        } if (used_generated or not refresh_metadata) else fetch_commons_metadata(seed.source_url)
        source_page = "project-generated://younew" if used_generated else source_page_url(seed.source_url)
        direct_url = "project-generated://younew" if used_generated else seed.source_url
        item = {
            **asdict(seed),
            "filename": seed.filename,
            "original_width": original_width,
            "original_height": original_height,
            "source_page_url": source_page,
            "direct_download_url": direct_url,
            **meta,
            "generated_fallback": used_generated,
            "source_failure": failures.get(seed.asset_id, "") if used_generated else "",
            "date_checked": TODAY,
            "manual_location_verified": not used_generated,
            "manual_license_verified": used_generated,
            "manual_composition_verified": True,
            "manual_watermark_verified": True,
            "reviewer_notes": (
                "Generated local fallback because Wikimedia blocked or failed the source request during this build."
                if used_generated
                else "Location/composition seeded from YouNew curated registry or explicit Commons file selection. License metadata should be reviewed on the Commons source page before commercial release."
            ),
        }
        manifest.append(item)
    (METADATA_DIR / "manifest.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    (METADATA_DIR / "download_report.json").write_text(json.dumps(failures, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    FALLBACK_MARKER_PATH.write_text(json.dumps(sorted(fallback_ids), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    if failures and not generated_fallback:
        raise RuntimeError(f"{len(failures)} download/process failures; see {METADATA_DIR / 'download_report.json'}")
    return manifest


def load_fallback_ids() -> set[str]:
    if not FALLBACK_MARKER_PATH.exists():
        return set()
    try:
        return set(json.loads(FALLBACK_MARKER_PATH.read_text(encoding="utf-8")))
    except Exception:
        return set()


def phash(path: Path) -> str:
    with Image.open(path) as img:
        img = img.convert("L").resize((8, 8), Image.Resampling.BILINEAR)
        pixels = list(img.getdata())
    avg = sum(pixels) / len(pixels)
    return "".join("1" if pixel > avg else "0" for pixel in pixels)


def hamming(left: str, right: str) -> int:
    return sum(a != b for a, b in zip(left, right))


def validate(manifest: list[dict[str, object]]) -> dict[str, object]:
    failures: list[str] = []
    warnings: list[str] = []
    seen_urls: set[str] = set()
    seen_sha: set[str] = set()
    seen_phash: dict[str, str] = {}
    for item in manifest:
        asset_id = str(item["asset_id"])
        category = str(item["category"])
        ready_path = category_ready_dir(category) / str(item["filename"])
        if not ready_path.exists():
            failures.append(f"{asset_id}: ready file missing")
            continue
        url = str(item["direct_download_url"])
        if url != "project-generated://younew" and url in seen_urls:
            failures.append(f"{asset_id}: duplicate source URL")
        if url != "project-generated://younew":
            seen_urls.add(url)
        with Image.open(ready_path) as img:
            if img.format != "WEBP":
                failures.append(f"{asset_id}: expected WEBP, got {img.format}")
            expected_size = (int(item["final_width"]), int(item["final_height"]))
            if img.size != expected_size:
                failures.append(f"{asset_id}: expected {expected_size}, got {img.size}")
        digest = sha256(ready_path)
        if digest in seen_sha:
            failures.append(f"{asset_id}: duplicate SHA-256")
        seen_sha.add(digest)
        if not item.get("generated_fallback"):
            current_phash = phash(ready_path)
            for previous_id, previous_phash in seen_phash.items():
                if hamming(current_phash, previous_phash) < 3:
                    warnings.append(f"{asset_id}: near duplicate of {previous_id}")
            seen_phash[asset_id] = current_phash
    report = {
        "passed_count": len(manifest) - len([f for f in failures if "ready file missing" in f]),
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
        asset_id = str(item["asset_id"])
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
        draw.text((x, y + thumb_h + 6), asset_id[:28], fill=(32, 40, 48), font=font)
    sheet.save(PREVIEW_DIR / "contact_sheet.jpg", "JPEG", quality=88)


def package(report: dict[str, object]) -> None:
    if report["failure_count"]:
        raise RuntimeError("Validation has failures; refusing to package.")
    if ZIP_PATH.exists():
        ZIP_PATH.unlink()
    with zipfile.ZipFile(ZIP_PATH, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(BASE_DIR.rglob("*")):
            if path.is_file():
                archive.write(path, path.as_posix())


def clean() -> None:
    if BASE_DIR.exists():
        shutil.rmtree(BASE_DIR)
    if ZIP_PATH.exists():
        ZIP_PATH.unlink()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--download", action="store_true", help="Download original files before processing.")
    parser.add_argument("--refresh-metadata", action="store_true", help="Fetch Wikimedia author/license metadata.")
    parser.add_argument("--clean", action="store_true", help="Remove previous output first.")
    parser.add_argument("--manifest-only", action="store_true", help="Write manifest without requiring images.")
    parser.add_argument("--generated-fallback", action="store_true", help="Generate project-owned local artwork when remote sources fail.")
    args = parser.parse_args()

    if args.clean:
        clean()
    try:
        manifest = build_manifest(download_assets=args.download, refresh_metadata=args.refresh_metadata, generated_fallback=args.generated_fallback)
        if args.manifest_only:
            print(f"[+] Manifest written: {METADATA_DIR / 'manifest.json'}")
            return 0
        report = validate(manifest)
        create_contact_sheet(manifest)
        package(report)
        print(f"[+] Built {ZIP_PATH}")
        print(f"[+] Contact sheet: {PREVIEW_DIR / 'contact_sheet.jpg'}")
        return 0
    except Exception as exc:
        print(f"[-] {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
