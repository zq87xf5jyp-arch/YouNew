#!/usr/bin/env bash
# generate-app-icons.sh
# Converts Design/AppIcon/source.svg into all required PNG icon sizes for iOS and macOS.
#
# Source SVG design: deep-navy radial background, subtle city grid/canal lines,
# cyan-to-orange route spine, strong white YN monogram, orange endpoint nodes,
# and cyan centre nexus. See Design/AppIcon/source.svg for full artwork.
#
# Requirements (macOS built-in, no Homebrew needed):
#   qlmanage  — SVG → PNG rendering via Quick Look
#   sips      — PNG resizing and format conversion
#   python3   — alpha-channel compositing (stdlib only, no Pillow required)
#
# Usage:
#   chmod +x scripts/generate-app-icons.sh
#   ./scripts/generate-app-icons.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SVG="$REPO_ROOT/Design/AppIcon/source.svg"
ICON_DIR="$REPO_ROOT/YouNew/Assets.xcassets/AppIcon.appiconset"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if command -v python3 >/dev/null 2>&1; then
    echo "Using deterministic stdlib Python AppIcon renderer."
    python3 "$REPO_ROOT/scripts/generate-app-icons.py"
    exit 0
fi

# Background fill colour used to composite over transparent SVG corners.
# Must match the solid base rect in source.svg (currently #030C1A).
BG_R=3; BG_G=12; BG_B=26

echo "==> Source: $SVG"
echo "==> Output: $ICON_DIR"
echo ""

# ── 1. Render SVG → 1024×1024 RGBA PNG via Quick Look ────────────────────────
echo "[1/3] Rendering SVG via qlmanage…"
if ! qlmanage -t -s 1024 -o "$TMP_DIR" "$SVG" >/dev/null 2>&1; then
    echo "qlmanage SVG rendering failed; using Swift/AppKit vector renderer fallback."
    swift "$REPO_ROOT/scripts/generate-app-icons.swift"
    exit 0
fi
RGBA_PNG="$TMP_DIR/$(basename "$SVG").png"

if [[ ! -f "$RGBA_PNG" ]]; then
    echo "ERROR: qlmanage did not produce output. Make sure source.svg is valid."
    exit 1
fi

# ── 2. Composite RGBA over solid background → RGB PNG ────────────────────────
echo "[2/3] Compositing RGBA over #$(printf '%02X%02X%02X' $BG_R $BG_G $BG_B) base…"
RGB_PNG="$TMP_DIR/icon-1024-rgb.png"

python3 - "$RGBA_PNG" "$RGB_PNG" "$BG_R" "$BG_G" "$BG_B" <<'PYEOF'
import struct, zlib, sys

src, dst, bg_r, bg_g, bg_b = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5])

def paeth(a, b, c):
    p = a + b - c
    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
    return a if pa <= pb and pa <= pc else (b if pb <= pc else c)

with open(src, 'rb') as f:
    data = f.read()

pos = 8; idat = b''; w = h = 0
while pos < len(data):
    ln = struct.unpack('>I', data[pos:pos+4])[0]
    ctype = data[pos+4:pos+8]; cdata = data[pos+8:pos+8+ln]; pos += 12 + ln
    if ctype == b'IHDR':
        w, h = struct.unpack('>II', cdata[:8])
        assert cdata[8] == 8 and cdata[9] == 6, "Expected 8-bit RGBA input"
    elif ctype == b'IDAT':
        idat += cdata

raw = bytearray(zlib.decompress(idat)); stride = w * 4; prev = bytearray(stride); recon = bytearray()
for y in range(h):
    ftype = raw[y * (stride + 1)]; row = bytearray(raw[y * (stride + 1) + 1:y * (stride + 1) + 1 + stride])
    if   ftype == 1:
        for x in range(4, stride): row[x] = (row[x] + row[x - 4]) & 0xFF
    elif ftype == 2:
        for x in range(stride):    row[x] = (row[x] + prev[x]) & 0xFF
    elif ftype == 3:
        for x in range(stride):    row[x] = (row[x] + ((row[x - 4] if x >= 4 else 0) + prev[x]) // 2) & 0xFF
    elif ftype == 4:
        for x in range(stride):
            a = row[x - 4] if x >= 4 else 0; b = prev[x]; c = prev[x - 4] if x >= 4 else 0
            row[x] = (row[x] + paeth(a, b, c)) & 0xFF
    recon.extend(row); prev = bytearray(row)

rgb = bytearray(w * h * 3)
for i in range(w * h):
    r, g, b, a = recon[i*4:i*4+4]; af = a / 255.0
    rgb[i*3]   = int(r * af + bg_r * (1 - af) + 0.5)
    rgb[i*3+1] = int(g * af + bg_g * (1 - af) + 0.5)
    rgb[i*3+2] = int(b * af + bg_b * (1 - af) + 0.5)

def chunk(ctype, cdata):
    body = ctype + cdata; return struct.pack('>I', len(cdata)) + body + struct.pack('>I', zlib.crc32(body) & 0xFFFFFFFF)

raw_out = bytearray()
for y in range(h): raw_out.append(0); raw_out.extend(rgb[y*w*3:(y+1)*w*3])

with open(dst, 'wb') as f:
    f.write(b'\x89PNG\r\n\x1a\n')
    f.write(chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)))
    f.write(chunk(b'IDAT', zlib.compress(bytes(raw_out), 9)))
    f.write(chunk(b'IEND', b''))
print(f"  Composited {w}x{h} RGB PNG → {dst}")
PYEOF

# ── 3. Copy 1024 and resize to all required sizes ────────────────────────────
echo "[3/3] Resizing to all required sizes…"

cp "$RGB_PNG" "$ICON_DIR/icon-1024.png"
echo "  icon-1024.png ✓  (iOS universal, dark, tinted)"

for SIZE in 16 32 64 128 256 512; do
    sips -z $SIZE $SIZE "$RGB_PNG" --out "$ICON_DIR/icon-${SIZE}.png" >/dev/null 2>&1
    echo "  icon-${SIZE}.png ✓"
done

echo ""
echo "Done. All icons written to:"
echo "  $ICON_DIR"
echo ""
echo "Next: open Xcode → Assets.xcassets → AppIcon and verify all slots are filled."
echo "iOS 16+ uses icon-1024.png for all sizes; macOS slots use the smaller PNGs."
