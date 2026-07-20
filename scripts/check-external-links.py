#!/usr/bin/env python3
import csv, datetime, json, re, ssl, sys, urllib.error, urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
URL = re.compile(r'https?://[^\s"<>\\]+')
INCOMPLETE_URL_SUFFIXES = ("/wiki/File:", "/wiki/Special:FilePath/")
urls = {}
scan_roots = [ROOT / "YouNew", ROOT / "DataProject" / "batches"]
for scan_root in scan_roots:
    if not scan_root.exists():
        continue
    for path in scan_root.rglob("*"):
        if path.suffix not in {".swift", ".json", ".strings", ".plist"}: continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        for match in URL.finditer(text):
            url = match.group(0).rstrip(".,;]")
            if url.endswith(INCOMPLETE_URL_SUFFIXES):
                continue
            line = text.count("\n", 0, match.start()) + 1
            urls.setdefault(url, f"{path.relative_to(ROOT)}:{line}")

ctx = ssl.create_default_context()
def check(pair):
    url, location = pair
    req = urllib.request.Request(url, method="HEAD", headers={"User-Agent":"YouNew-QA/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=10, context=ctx) as response:
            code = response.status
            final = response.geturl()
        return url, location, code, final, "" if code < 400 else "http_error"
    except urllib.error.HTTPError as exc:
        if exc.code in {403, 405, 429}:
            try:
                req = urllib.request.Request(url, method="GET", headers={"User-Agent":"Mozilla/5.0","Range":"bytes=0-0"})
                with urllib.request.urlopen(req, timeout=10, context=ctx) as response:
                    return url, location, response.status, response.geturl(), "restricted_head" if response.status < 400 else "http_error"
            except Exception as retry:
                return url, location, getattr(retry, "code", exc.code), "", type(retry).__name__
        return url, location, exc.code, "", "http_error"
    except Exception as exc:
        return url, location, "", "", type(exc).__name__

with ThreadPoolExecutor(max_workers=16) as pool:
    results = list(pool.map(check, urls.items()))

confirmed_failures = [r for r in results if r[2] in {404, 410}]
restricted = [r for r in results if r[2] in {401, 403, 429}]
transient = [r for r in results if (not isinstance(r[2], int) or r[2] >= 500)]
failures = confirmed_failures + restricted + transient
with (ROOT / "broken_links.csv").open("w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["severity","screen","steps_to_reproduce","expected_behavior","actual_behavior","proposed_fix","url","http_status","final_url","evidence"])
    for url, location, status, final, evidence in sorted(failures):
        severity = "high" if status in {404,410} else "low" if status in {401,403,429} else "medium"
        proposed_fix = "Replace or re-verify URL" if severity == "high" else "Retry in scheduled QA; keep an in-app failure state"
        writer.writerow([severity,location,f"Open external link {url}","Official source opens successfully",f"HTTP {status or 'no response'} ({evidence})",proposed_fix,url,status,final,evidence])

report = {
    "schemaVersion": 1,
    "checkedAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "totalURLs": len(results),
    "reachableURLs": len(results) - len(failures),
    "confirmedBrokenURLs": len(confirmed_failures),
    "accessRestrictedURLs": len(restricted),
    "transientFailures": len(transient),
    "confirmedBroken": [
        {"url": url, "location": location, "status": status, "finalURL": final, "evidence": evidence}
        for url, location, status, final, evidence in sorted(confirmed_failures)
    ],
}
with (ROOT / "knowledge_data_health.json").open("w", encoding="utf-8") as f:
    json.dump(report, f, ensure_ascii=False, indent=2)
    f.write("\n")

print(
    f"checked={len(results)} confirmed_broken={len(confirmed_failures)} "
    f"restricted={len(restricted)} transient={len(transient)}"
)
sys.exit(1 if confirmed_failures else 0)
