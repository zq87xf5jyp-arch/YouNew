#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ICON_NAME="AppIcon"
ICON_DIR="$REPO_ROOT/YouNew/Assets.xcassets/${ICON_NAME}.appiconset"
SVG_SOURCE="$REPO_ROOT/Design/AppIcon/source.svg"
CONTENTS="$ICON_DIR/Contents.json"
PROJECT="$REPO_ROOT/YouNew.xcodeproj/project.pbxproj"

issues=0
_ok() { echo "  ✓ $*"; }
_fail() { echo "  ✗ $*"; issues=$((issues + 1)); }

echo ""
echo "═══════════════════════════════════════════════"
echo " YouNew AppIcon Static QA"
echo "═══════════════════════════════════════════════"

echo ""
echo "[ Active target icon ]"
if grep -q "ASSETCATALOG_COMPILER_APPICON_NAME = ${ICON_NAME};" "$PROJECT"; then
    _ok "iOS target build setting uses ${ICON_NAME}"
else
    _fail "ASSETCATALOG_COMPILER_APPICON_NAME does not point to ${ICON_NAME}"
fi

icon_sets="$(find "$REPO_ROOT/YouNew/Assets.xcassets" -name "*.appiconset" -type d | sort)"
icon_set_count="$(printf '%s\n' "$icon_sets" | sed '/^$/d' | wc -l | tr -d ' ')"
if [[ "$icon_set_count" == "1" && "$icon_sets" == "$ICON_DIR" ]]; then
    _ok "Only active app icon set found: ${ICON_DIR#$REPO_ROOT/}"
else
    _fail "Unexpected app icon sets: $icon_sets"
fi

echo ""
echo "[ Source and catalog ]"
[[ -f "$SVG_SOURCE" ]] && _ok "source logo exists: ${SVG_SOURCE#$REPO_ROOT/}" || _fail "missing source logo: ${SVG_SOURCE#$REPO_ROOT/}"
[[ -f "$CONTENTS" ]] && _ok "Contents.json exists" || _fail "missing Contents.json"
if [[ -f "$SVG_SOURCE" ]] && grep -qi "coat_of_arms\|city_flag\|wapen\|rijkswapen\|Flag_of_" "$SVG_SOURCE"; then
    _fail "source.svg references official symbol markers"
else
    _ok "source.svg does not reference official symbols"
fi

echo ""
echo "[ Referenced files and pixel metrics ]"
python3 - "$ICON_DIR" "$CONTENTS" <<'PY'
import json
import math
import struct
import sys
import zlib
from pathlib import Path

icon_dir = Path(sys.argv[1])
contents = Path(sys.argv[2])
required = {
    "icon-16.png": 16,
    "icon-32.png": 32,
    "icon-64.png": 64,
    "icon-128.png": 128,
    "icon-256.png": 256,
    "icon-512.png": 512,
    "icon-1024.png": 1024,
}
issues = 0

def fail(message):
    global issues
    print(f"  ✗ {message}")
    issues += 1

def ok(message):
    print(f"  ✓ {message}")

def read_png(path):
    data = path.read_bytes()
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("not png")
    pos = 8
    idat = b""
    width = height = color_type = None
    while pos < len(data):
        ln = struct.unpack(">I", data[pos:pos + 4])[0]
        kind = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + ln]
        pos += 12 + ln
        if kind == b"IHDR":
            width, height, bit_depth, color_type, _, _, interlace = struct.unpack(">IIBBBBB", chunk)
            if bit_depth != 8 or interlace != 0:
                raise ValueError("unsupported png format")
        elif kind == b"IDAT":
            idat += chunk
    channels = {0: 1, 2: 3, 4: 2, 6: 4}[color_type]
    bpp = channels
    raw = zlib.decompress(idat)
    stride = width * channels
    rows = []
    prev = [0] * stride
    cursor = 0
    for _ in range(height):
        filter_type = raw[cursor]
        cursor += 1
        scan = list(raw[cursor:cursor + stride])
        cursor += stride
        out = [0] * stride
        for i, value in enumerate(scan):
            left = out[i - bpp] if i >= bpp else 0
            up = prev[i]
            up_left = prev[i - bpp] if i >= bpp else 0
            if filter_type == 0:
                decoded = value
            elif filter_type == 1:
                decoded = value + left
            elif filter_type == 2:
                decoded = value + up
            elif filter_type == 3:
                decoded = value + ((left + up) // 2)
            elif filter_type == 4:
                p = left + up - up_left
                pa, pb, pc = abs(p - left), abs(p - up), abs(p - up_left)
                predictor = left if pa <= pb and pa <= pc else (up if pb <= pc else up_left)
                decoded = value + predictor
            else:
                raise ValueError(f"unsupported filter {filter_type}")
            out[i] = decoded & 255
        rows.append(out)
        prev = out
    return width, height, color_type, channels, rows

catalog = json.loads(contents.read_text(encoding="utf-8"))
referenced = {image.get("filename") for image in catalog.get("images", []) if image.get("filename")}
for filename in sorted(referenced):
    if not (icon_dir / filename).is_file():
        fail(f"Contents.json references missing file {filename}")
for filename in sorted(required):
    if filename not in referenced:
        fail(f"Contents.json does not reference {filename}")

for filename, expected in sorted(required.items(), key=lambda item: item[1]):
    path = icon_dir / filename
    if not path.is_file():
        fail(f"{filename} missing")
        continue
    try:
        width, height, color_type, channels, rows = read_png(path)
    except Exception as error:
        fail(f"{filename} unreadable: {error}")
        continue

    values = []
    alpha_values = []
    for row in rows:
        for i in range(0, len(row), channels):
            if channels >= 3:
                r, g, b = row[i], row[i + 1], row[i + 2]
                values.append(0.2126 * r + 0.7152 * g + 0.0722 * b)
            else:
                values.append(row[i])
            if channels == 4:
                alpha_values.append(row[i + 3])
    average = sum(values) / len(values)
    contrast = math.sqrt(sum((value - average) ** 2 for value in values) / len(values))
    has_alpha = bool(alpha_values and min(alpha_values) < 255)
    status = "OK"
    if width != expected or height != expected:
        fail(f"{filename} dimensions {width}x{height}; expected {expected}x{expected}")
        status = "FAIL"
    if has_alpha:
        fail(f"{filename} has transparent pixels")
        status = "FAIL"
    dark_count   = sum(1 for v in values if v < 30)
    bright_count = sum(1 for v in values if v > 150)
    pct_dark     = dark_count   / len(values) * 100 if values else 100
    pct_bright   = bright_count / len(values) * 100 if values else 0
    # Threshold reasoning:
    #   avg >= 75  — rules out near-black/placeholder icons while allowing
    #                premium deep-navy designs (background ~50, bright mark ~230)
    #   pct_dark < 60 — icon must not be overwhelmingly dark
    #   pct_bright >= 8 — icon must have clearly visible bright mark
    if average < 75:
        fail(f"{filename} averageBrightness={average:.2f} < 75 — icon appears too dark/black")
        status = "FAIL"
    if contrast < 36:
        fail(f"{filename} contrastScore={contrast:.2f} is too low")
        status = "FAIL"
    if pct_dark > 60:
        fail(f"{filename} {pct_dark:.1f}% of pixels are near-black — icon is too dark")
        status = "FAIL"
    if pct_bright < 8:
        fail(f"{filename} only {pct_bright:.1f}% bright pixels — no visible mark detected")
        status = "FAIL"
    print(f"  {filename}\t{width}x{height}\thasAlpha={has_alpha}\taverageBrightness={average:.2f}\tcontrastScore={contrast:.2f}\t%dark={pct_dark:.1f}%\t%bright={pct_bright:.1f}%\tstatus={status}")

sys.exit(1 if issues else 0)
PY
if [[ $? -ne 0 ]]; then
    issues=$((issues + 1))
fi

echo ""
echo "[ Placeholder and media separation ]"
if grep -rqi "placeholder\|template-icon\|default-icon\|black icon" "$ICON_DIR" 2>/dev/null; then
    _fail "placeholder/black icon marker found in AppIcon catalog"
else
    _ok "no placeholder/black icon markers in AppIcon catalog"
fi
if grep -Rqi "AppIcon\\|YouNewLogo" "$REPO_ROOT/YouNew/Data/VerifiedPlaceMediaRegistry.swift"; then
    _fail "official place media registry references app logo/icon"
else
    _ok "app icon/logo not used as official place media"
fi

echo ""
echo "═══════════════════════════════════════════════"
if [[ $issues -eq 0 ]]; then
    echo " PASS — all AppIcon QA checks passed"
    echo "═══════════════════════════════════════════════"
    echo ""
    exit 0
fi

echo " FAIL — $issues issue(s) found"
echo "═══════════════════════════════════════════════"
echo ""
exit 1
