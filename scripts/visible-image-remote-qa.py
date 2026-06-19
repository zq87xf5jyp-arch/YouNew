#!/usr/bin/env python3
import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Optional
from urllib.parse import parse_qs, quote, unquote, urlparse, urlencode


ROOT = Path(__file__).resolve().parents[1]
CURATED = ROOT / "YouNew" / "Data" / "CuratedPlaceHeroMediaRegistry.swift"
NETHERLANDS_DATA = ROOT / "YouNew" / "Data" / "NetherlandsData.swift"
DEFAULT_CACHE = ROOT / ".image-url-cache.json"
USER_AGENT = "YouNewVisualAudit/1.0 (Netherlands guide image validation; contact: local-build)"
RATE_LIMIT_STATUSES = {429}
FAIL_STATUSES = {403, 404, 410}
MAX_SAFE_SOURCE_RATIO = 2.8
ALLOWED_VISIBLE_IMAGE_HOSTS = {"commons.wikimedia.org", "upload.wikimedia.org"}
FORBIDDEN_VISIBLE_IMAGE_TOKENS = (
    "placeholder",
    "todo",
    "screenshot",
    "screen-shot",
    "screen_shot",
    "screen%20shot",
    "screen capture",
    "screen_capture",
    "logo",
    "watermark",
    "unsplash",
    "pexels",
    "shutterstock",
    "getty",
)


@dataclass(frozen=True)
class VisibleImage:
    surface: str
    url: str


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def normalized_source_url(url: str) -> str:
    parsed = urlparse(url.strip())
    path = unquote(parsed.path).lower().replace(" ", "_")
    path = re.sub(r"/thumb/", "/", path)
    path = re.sub(r"/(?:\d+px-|[0-9]+px_)[^/]+$", "", path)
    query = parsed.query.lower()
    if "special:filepath" in path:
        query = ""
    return f"{parsed.netloc.lower()}{path}?{query}".rstrip("?")


def normalized_commons_title(title: str) -> str:
    return unquote(title).removeprefix("File:").replace("_", " ").strip().casefold()


def commons_file_title(url: str) -> Optional[str]:
    parsed = urlparse(url.strip())
    host = parsed.netloc.lower()
    if "wikimedia.org" not in host:
        return None

    path = unquote(parsed.path)
    if "/wiki/Special:FilePath/" in path:
        return path.rsplit("/wiki/Special:FilePath/", 1)[-1]
    if "/wiki/File:" in path:
        return path.rsplit("/wiki/File:", 1)[-1]
    if "/wikipedia/commons/thumb/" in path:
        parts = path.split("/")
        if len(parts) >= 2:
            return parts[-2]
    if "/wikipedia/commons/" in path:
        return path.rsplit("/", 1)[-1]

    query_title = parse_qs(parsed.query).get("title", [None])[0]
    if query_title and query_title.startswith("File:"):
        return query_title.removeprefix("File:")
    return None


def visible_images() -> list[VisibleImage]:
    curated = read(CURATED)
    data = read(NETHERLANDS_DATA)
    images: list[VisibleImage] = []

    city_visual_pattern = re.compile(
        r'"(?P<place>nl-city-[^"]+)":\s*\[(?P<body>.*?)(?=\n\s*\],\n\s*"|\n\s*\]\n\s*\])',
        re.S,
    )
    province_visual_pattern = re.compile(
        r'"(?P<place>nl-province-[^"]+)":\s*\[(?P<body>.*?)(?=\n\s*\],\n\s*"|\n\s*\]\n\s*\])',
        re.S,
    )
    visual_pattern = re.compile(
        r'\.(?P<role>[a-zA-Z]+):\s*visual\([^)]*?remote:\s*"(?P<url>https?://[^"]+)"',
        re.S,
    )

    for collection, prefix in ((city_visual_pattern, "city role"), (province_visual_pattern, "province role")):
        for match in collection.finditer(curated):
            place = match.group("place")
            for visual in visual_pattern.finditer(match.group("body")):
                images.append(VisibleImage(f"{prefix} {place} {visual.group('role')}", visual.group("url")))

    attraction_pattern = re.compile(
        r'Attraction\(id:\s*"(?P<id>[^"]+)".*?name:\s*"(?P<name>[^"]+)".*?imageURL:\s*"(?P<url>https?://[^"]+)"',
        re.S,
    )
    for match in attraction_pattern.finditer(data):
        images.append(VisibleImage(f"city attraction {match.group('id')} / {match.group('name')}", match.group("url")))

    tourism_pattern = re.compile(
        r'record\(\s*"(?P<id>[^"]+)".*?"(?P<url>https?://[^"]+)"\s*\)',
        re.S,
    )
    for match in tourism_pattern.finditer(data):
        images.append(VisibleImage(f"tourism {match.group('id')}", match.group("url")))

    return images


def load_cache(path: Path) -> dict[str, dict[str, object]]:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}


def save_cache(path: Path, cache: dict[str, dict[str, object]]) -> None:
    path.write_text(json.dumps(cache, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def write_failure_report(path: Path, rows: list[dict[str, object]]) -> None:
    lines = [
        "# Visible Image Remote QA Failures",
        "",
        f"Generated: {time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}",
        "",
        f"Unresolved visible URLs: {len(rows)}",
        "",
        "| Surface | Commons title | Status | URL |",
        "|---|---|---|---|",
    ]
    for row in rows:
        surface = str(row["surface"]).replace("|", "\\|")
        title = str(row["title"]).replace("|", "\\|")
        status = str(row["status"]).replace("|", "\\|")
        url = str(row["url"]).replace("|", "\\|")
        lines.append(f"| {surface} | `{title}` | {status} | {url} |")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def source_size_requirement(surface: str) -> tuple[int, int]:
    if surface.startswith("city role ") and surface.endswith(" hero"):
        return 2400, 700
    if surface.startswith("province role ") and surface.endswith(" landscape"):
        return 2400, 700
    return 1200, 700


def dimension_failure(image: VisibleImage, result: dict[str, object]) -> Optional[str]:
    width = result.get("width")
    height = result.get("height")
    if not isinstance(width, int) or not isinstance(height, int):
        return "missing dimensions"

    min_long_edge, min_short_edge = source_size_requirement(image.surface)
    long_edge = max(width, height)
    short_edge = min(width, height)
    if long_edge < min_long_edge or short_edge < min_short_edge:
        return f"undersized {width}x{height}; requires long edge >= {min_long_edge}px and short edge >= {min_short_edge}px"
    return None


def aspect_ratio_failure(result: dict[str, object]) -> Optional[str]:
    width = result.get("width")
    height = result.get("height")
    if not isinstance(width, int) or not isinstance(height, int) or min(width, height) <= 0:
        return "missing dimensions"

    ratio = max(width, height) / min(width, height)
    if ratio > MAX_SAFE_SOURCE_RATIO:
        return f"unsafe source aspect ratio {ratio:.2f}:1; maximum allowed is {MAX_SAFE_SOURCE_RATIO:.1f}:1"
    return None


def validate_url(url: str, timeout: float) -> dict[str, object]:
    request = urllib.request.Request(
        url,
        headers={
            "User-Agent": USER_AGENT,
            "Range": "bytes=0-2047",
            "Accept": "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
        },
    )

    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            content_type = response.headers.get("Content-Type", "").lower()
            status = getattr(response, "status", 200)
            response.read(64)
            return {
                "status": status,
                "contentType": content_type,
                "ok": 200 <= status < 300 and content_type.startswith("image/"),
                "checkedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            }
    except urllib.error.HTTPError as error:
        return {
            "status": error.code,
            "contentType": error.headers.get("Content-Type", "").lower(),
            "ok": False,
            "error": str(error),
            "checkedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        }
    except Exception as error:
        return {
            "status": "error",
            "contentType": "",
            "ok": False,
            "error": f"{type(error).__name__}: {error}",
            "checkedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        }


def chunks(values: list[str], size: int) -> list[list[str]]:
    return [values[index:index + size] for index in range(0, len(values), size)]


def validate_commons_titles(titles: list[str], timeout: float, sleep: float) -> tuple[dict[str, dict[str, object]], bool]:
    results: dict[str, dict[str, object]] = {}
    rate_limited = False
    unique_titles = []
    for title in titles:
        if title and title not in unique_titles:
            unique_titles.append(title)

    for batch in chunks(unique_titles, 40):
        prefixed = [f"File:{title}" for title in batch]
        request_url = "https://commons.wikimedia.org/w/api.php?" + urlencode({
            "action": "query",
            "format": "json",
            "titles": "|".join(prefixed),
            "prop": "imageinfo",
            "iiprop": "mime|size|url",
        })
        request = urllib.request.Request(request_url, headers={"User-Agent": USER_AGENT})

        try:
            with urllib.request.urlopen(request, timeout=timeout) as response:
                payload = json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as error:
            if error.code in RATE_LIMIT_STATUSES:
                rate_limited = True
                break
            for title in batch:
                results[title] = {
                    "ok": False,
                    "status": error.code,
                    "error": str(error),
                    "checkedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                }
            continue
        except Exception as error:
            for title in batch:
                results[title] = {
                    "ok": False,
                    "status": "error",
                    "error": f"{type(error).__name__}: {error}",
                    "checkedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                }
            continue

        pages = payload.get("query", {}).get("pages", {})
        pages_by_title = {
            normalized_commons_title(page.get("title", "")): page
            for page in pages.values()
        }
        for title in batch:
            page = pages_by_title.get(normalized_commons_title(title))
            image_info = page.get("imageinfo", [{}])[0] if page else {}
            results[title] = {
                "ok": bool(page) and "missing" not in page and image_info.get("mime", "").startswith("image/"),
                "status": "missing" if page and "missing" in page else "ok",
                "mime": image_info.get("mime", ""),
                "width": image_info.get("width"),
                "height": image_info.get("height"),
                "checkedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            }

        time.sleep(sleep)

    return results, rate_limited


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate visible Netherlands guide image URLs without hammering remote hosts.")
    parser.add_argument("--cache", type=Path, default=DEFAULT_CACHE)
    parser.add_argument("--max-requests", type=int, default=20)
    parser.add_argument("--sleep", type=float, default=2.0)
    parser.add_argument("--timeout", type=float, default=10.0)
    parser.add_argument("--refresh", action="store_true", help="Re-check URLs even when cached.")
    parser.add_argument("--offline", action="store_true", help="Only run static duplicate checks and summarize cache state.")
    parser.add_argument("--commons-metadata", action="store_true", help="Validate exact Commons file titles through the Commons API instead of downloading images.")
    parser.add_argument("--enforce-dimensions", action="store_true", help="Fail Commons metadata validation when visible source files are below role-specific source-size floors.")
    parser.add_argument("--enforce-aspect-ratio", action="store_true", help="Fail Commons metadata validation when visible source files are too panoramic or too narrow for safe aspect-fill cropping.")
    parser.add_argument("--failure-report", type=Path, help="Write a Markdown report of all unresolved visible image URLs.")
    parser.add_argument("--surface-filter", help="Only validate visible surfaces containing this case-insensitive substring.")
    parser.add_argument("--limit", type=int, help="Only validate the first N unique URLs after filtering.")
    args = parser.parse_args()

    images = visible_images()
    if args.surface_filter:
        surface_filter = args.surface_filter.casefold()
        images = [image for image in images if surface_filter in image.surface.casefold()]
    duplicates: dict[str, list[VisibleImage]] = {}
    for image in images:
        duplicates.setdefault(normalized_source_url(image.url), []).append(image)
    duplicate_groups = {key: value for key, value in duplicates.items() if len(value) > 1}

    failures: list[str] = []
    if duplicate_groups:
        for key, group in sorted(duplicate_groups.items()):
            surfaces = ", ".join(image.surface for image in group)
            failures.append(f"Duplicate visible image source: {key} -> {surfaces}")

    for image in images:
        parsed = urlparse(image.url)
        host = parsed.netloc.lower()
        decoded_url = unquote(image.url).lower()
        if host not in ALLOWED_VISIBLE_IMAGE_HOSTS:
            failures.append(f"Visible image uses non-Wikimedia host: {image.surface} -> {image.url}")
        for token in FORBIDDEN_VISIBLE_IMAGE_TOKENS:
            if token in decoded_url:
                failures.append(f"Visible image URL contains forbidden visual token '{token}': {image.surface} -> {image.url}")
                break

    cache = load_cache(args.cache)
    unique_urls = []
    for image in images:
        if image.url not in unique_urls:
            unique_urls.append(image.url)
    if args.limit is not None:
        unique_urls = unique_urls[:args.limit]

    requests_made = 0
    rate_limited = False

    metadata_results: dict[str, dict[str, object]] = {}
    metadata_rate_limited = False
    metadata_failures: list[tuple[str, dict[str, object]]] = []
    metadata_missing: list[tuple[str, dict[str, object]]] = []
    metadata_unproven: list[tuple[str, dict[str, object]]] = []
    dimension_failures: list[tuple[VisibleImage, dict[str, object], str]] = []
    aspect_ratio_failures: list[tuple[VisibleImage, dict[str, object], str]] = []
    surface_by_url = {image.url: image.surface for image in images}

    if args.commons_metadata and not args.offline:
        titles = [title for title in (commons_file_title(url) for url in unique_urls) if title]
        metadata_results, metadata_rate_limited = validate_commons_titles(titles, args.timeout, args.sleep)
        title_by_url = {url: commons_file_title(url) for url in unique_urls}
        metadata_failures = [
            (url, metadata_results[title])
            for url, title in title_by_url.items()
            if title and title in metadata_results and metadata_results[title].get("ok") is not True
        ]
        metadata_missing = [
            (url, result)
            for url, result in metadata_failures
            if result.get("status") == "missing"
        ]
        metadata_unproven = [
            (url, result)
            for url, result in metadata_failures
            if result.get("status") != "missing"
        ]
        if args.enforce_dimensions:
            result_by_url = {
                url: metadata_results[title]
                for url, title in title_by_url.items()
                if title and title in metadata_results and metadata_results[title].get("ok") is True
            }
            for image in images:
                result = result_by_url.get(image.url)
                if not result:
                    continue
                failure = dimension_failure(image, result)
                if failure:
                    dimension_failures.append((image, result, failure))
                if args.enforce_aspect_ratio:
                    failure = aspect_ratio_failure(result)
                    if failure:
                        aspect_ratio_failures.append((image, result, failure))
        if args.failure_report:
            write_failure_report(args.failure_report, [
                {
                    "surface": surface_by_url.get(url, "unknown"),
                    "title": commons_file_title(url) or "",
                    "status": result.get("status", ""),
                    "url": url,
                }
                for url, result in metadata_missing
            ] + [
                {
                    "surface": image.surface,
                    "title": commons_file_title(image.url) or "",
                    "status": failure,
                    "url": image.url,
                }
                for image, _result, failure in dimension_failures
            ] + [
                {
                    "surface": image.surface,
                    "title": commons_file_title(image.url) or "",
                    "status": failure,
                    "url": image.url,
                }
                for image, _result, failure in aspect_ratio_failures
            ])
    elif not args.offline:
        for url in unique_urls:
            if not args.refresh and cache.get(url, {}).get("ok") is True:
                continue
            if requests_made >= args.max_requests:
                break

            result = validate_url(url, args.timeout)
            cache[url] = result
            requests_made += 1

            if result.get("status") in RATE_LIMIT_STATUSES:
                rate_limited = True
                break
            time.sleep(args.sleep)

        save_cache(args.cache, cache)

    checked = sum(1 for url in unique_urls if url in cache)
    ok = sum(1 for url in unique_urls if cache.get(url, {}).get("ok") is True)
    failed = [] if args.offline else [
        (url, cache[url])
        for url in unique_urls
        if url in cache and cache[url].get("ok") is not True and cache[url].get("status") not in RATE_LIMIT_STATUSES
    ]
    hard_failed = [
        (url, result)
        for url, result in failed
        if result.get("status") in FAIL_STATUSES
    ]
    transient_failed = [
        (url, result)
        for url, result in failed
        if result.get("status") not in FAIL_STATUSES
    ]

    print("Visible image remote QA")
    print(f"- visible assignments: {len(images)}")
    print(f"- unique URLs: {len(unique_urls)}")
    print(f"- duplicate source groups: {len(duplicate_groups)}")
    print(f"- cache: {args.cache}")
    print(f"- cached/checked URLs: {checked}")
    print(f"- cached OK URLs: {ok}")
    print(f"- requests made this run: {requests_made}")
    if args.commons_metadata:
        print(f"- Commons file titles checked: {len(metadata_results)}")

    if rate_limited or metadata_rate_limited:
        print("- stopped: remote host rate-limited validation")
    if metadata_missing:
        print("\nCommons metadata missing files:")
        for url, result in metadata_missing[:40]:
            print(f"- {result.get('status')}: {commons_file_title(url)} <- {url}")
        if len(metadata_missing) > 40:
            print(f"- ... {len(metadata_missing) - 40} more")
    if metadata_unproven:
        print(f"- transient/unproven Commons metadata checks: {len(metadata_unproven)}")
    if dimension_failures:
        print("\nDimension failures:")
        for image, _result, failure in dimension_failures[:40]:
            print(f"- {image.surface}: {failure} <- {commons_file_title(image.url)}")
        if len(dimension_failures) > 40:
            print(f"- ... {len(dimension_failures) - 40} more")
    if aspect_ratio_failures:
        print("\nAspect-ratio failures:")
        for image, _result, failure in aspect_ratio_failures[:40]:
            print(f"- {image.surface}: {failure} <- {commons_file_title(image.url)}")
        if len(aspect_ratio_failures) > 40:
            print(f"- ... {len(aspect_ratio_failures) - 40} more")
    if transient_failed:
        print(f"- transient/unproven URL checks: {len(transient_failed)}")
    if hard_failed:
        print("\nHard failures:")
        for url, result in hard_failed:
            print(f"- HTTP {result.get('status')}: {url}")
    if transient_failed:
        print("\nTransient or unproven checks:")
        for url, result in transient_failed[:10]:
            print(f"- {result.get('status')}: {url} ({result.get('error', 'not an image response')})")
        if len(transient_failed) > 10:
            print(f"- ... {len(transient_failed) - 10} more")

    if failures:
        print("\nStatic failures:")
        for failure in failures:
            print(f"- {failure}")
        return 1
    if metadata_missing:
        return 1
    if dimension_failures:
        return 1
    if aspect_ratio_failures:
        return 1
    if hard_failed:
        return 1
    if rate_limited or metadata_rate_limited or transient_failed or metadata_unproven:
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
