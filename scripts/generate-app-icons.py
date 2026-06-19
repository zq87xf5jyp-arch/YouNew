#!/usr/bin/env python3
"""
YouNew.nl app icon generator — Gateway concept.

Concept: The Gateway (Option B — Open Gateway mark).
A semicircular arch supported by two bold vertical pillars, with an illuminated
orange path rising from the bottom (you, the newcomer) through the arch into a
teal glow (your new life in the Netherlands).

Design language:
  - Deep navy gradient background (clearly blue, never pure black)
  - Teal radial glow inside the arch  (new world opening before you)
  - White arch: two pillars + semicircle (bold, premium, architectural)
  - Orange path through the arch       (your journey, your new chapter)
  - Dutch-orange node at path base     (you — at the start of something new)
  - Nothing else — no grid, no clutter, no generic map pin

All rendering uses Python stdlib only (no Pillow/cairosvg required).
"""
import json
import math
import struct
import zlib
from pathlib import Path


ROOT     = Path(__file__).resolve().parents[1]
ICON_DIR = ROOT / "YouNew/Assets.xcassets/AppIcon.appiconset"
SIZES    = [16, 32, 64, 128, 256, 512, 1024]


# ── Maths helpers ─────────────────────────────────────────────────────────────

def clamp(v):
    return max(0, min(255, int(round(v))))


def mix(a, b, t):
    t = max(0.0, min(1.0, t))
    return tuple(a[i] * (1.0 - t) + b[i] * t for i in range(3))


def smoothstep(e0, e1, x):
    if e0 == e1:
        return 1.0 if x >= e1 else 0.0
    t = max(0.0, min(1.0, (x - e0) / (e1 - e0)))
    return t * t * (3.0 - 2.0 * t)


def blend(dst, src, alpha):
    alpha = max(0.0, min(1.0, alpha))
    return tuple(dst[i] * (1.0 - alpha) + src[i] * alpha for i in range(3))


def dist_seg(px, py, ax, ay, bx, by):
    dx, dy = bx - ax, by - ay
    len2 = dx * dx + dy * dy
    if len2 == 0:
        return math.hypot(px - ax, py - ay)
    t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / len2))
    return math.hypot(px - ax - t * dx, py - ay - t * dy)


def stroke_alpha(px, py, pts, half_w, feather=2.2):
    d = min(dist_seg(px, py, ax, ay, bx, by) for (ax, ay), (bx, by) in zip(pts, pts[1:]))
    return 1.0 - smoothstep(half_w - feather, half_w + feather, d)


def circle_alpha(px, py, cx, cy, r, feather=1.5):
    return 1.0 - smoothstep(r - feather, r + feather, math.hypot(px - cx, py - cy))


def build_arc(cx, cy, r, n=200):
    """Discretise a semicircle from left to right over the top into polyline points."""
    pts = []
    for i in range(n + 1):
        angle = math.pi * i / n          # 0 → π
        x = cx - r * math.cos(angle)    # left (cx-r) → top (cx) → right (cx+r)
        y = cy - r * math.sin(angle)    # cy → cy-r → cy  (goes up in screen coords)
        pts.append((x, y))
    return pts


# ── Icon renderer ─────────────────────────────────────────────────────────────

def render_icon(size):
    bg_top    = (13, 74, 132)
    bg_bottom = (6, 32, 74)
    glow_col  = (21, 146, 211)
    white     = (252, 255, 255)
    cyan      = (49, 215, 232)
    orange    = (255, 124, 10)
    orange_hi = (255, 220, 90)

    scale = size / 1024.0

    skyline_segments = [
        ((208, 772), (208, 540)), ((208, 540), (276, 500)), ((276, 500), (344, 540)), ((344, 540), (344, 772)),
        ((362, 772), (362, 398)), ((362, 398), (444, 330)), ((444, 330), (526, 398)), ((526, 398), (526, 772)),
        ((544, 772), (544, 486)), ((544, 486), (612, 444)), ((612, 444), (680, 486)), ((680, 486), (680, 772)),
        ((698, 772), (698, 566)), ((698, 566), (786, 566)), ((786, 566), (786, 772)),
    ]
    skyline_paths = [[a, b] for a, b in skyline_segments]
    route_pts = []
    for i in range(49):
        t = i / 48
        if t < 0.5:
            u = t / 0.5
            p0, p1, p2, p3 = (246, 842), (332, 774), (420, 812), (500, 754)
        else:
            u = (t - 0.5) / 0.5
            p0, p1, p2, p3 = (500, 754), (604, 678), (676, 820), (778, 842)
        x = (1-u)**3*p0[0] + 3*(1-u)**2*u*p1[0] + 3*(1-u)*u**2*p2[0] + u**3*p3[0]
        y = (1-u)**3*p0[1] + 3*(1-u)**2*u*p1[1] + 3*(1-u)*u**2*p2[1] + u**3*p3[1]
        route_pts.append((x, y))

    pixels = bytearray()
    for y in range(size):
        for x in range(size):
            nx = x / max(size - 1, 1)
            ny = y / max(size - 1, 1)
            base = mix(bg_top, bg_bottom, smoothstep(0.0, 1.0, ny))

            d_glow = math.hypot(nx - 0.500, ny - 0.352)
            glow_a = max(0.0, 0.381 - d_glow) / 0.381
            base = blend(base, glow_col, (glow_a ** 1.45) * 0.72)

            ux = x / scale
            uy = y / scale

            halo = 0.0
            for pts in skyline_paths:
                halo = max(halo, stroke_alpha(ux, uy, pts, 54, feather=24))
            base = blend(base, glow_col, halo * 0.16)

            for pts in skyline_paths:
                base = blend(base, white, stroke_alpha(ux, uy, pts, 27))

            for cx, cy in ((276, 626), (444, 626), (612, 626), (742, 626)):
                base = blend(base, cyan, circle_alpha(ux, uy, cx, cy, 14) * 0.88)

            base = blend(base, orange, stroke_alpha(ux, uy, route_pts, 22))
            a_node = circle_alpha(ux, uy, 246, 842, 68)
            base = blend(base, orange, a_node)
            base = blend(base, orange_hi, circle_alpha(ux, uy, 246, 842, 26) * 0.90)
            ring = circle_alpha(ux, uy, 246, 842, 88) - circle_alpha(ux, uy, 246, 842, 75)
            base = blend(base, white, max(0.0, ring) * 0.52)

            if size <= 64:
                base = blend(base, white, halo * 0.12)

            pixels.extend([clamp(base[0]), clamp(base[1]), clamp(base[2])])

    return bytes(pixels)


# ── PNG encoder ───────────────────────────────────────────────────────────────

def png_bytes(width, height, rgb):
    stride = width * 3

    def chunk(kind, data):
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

    rows = bytearray()
    for y in range(height):
        rows.append(0)
        rows.extend(rgb[y * stride:(y + 1) * stride])

    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(bytes(rows), 9))
        + chunk(b"IEND", b"")
    )


# ── Contents.json writer ──────────────────────────────────────────────────────

def write_contents():
    images = [
        {"filename": "icon-1024.png", "idiom": "universal", "platform": "ios",  "size": "1024x1024"},
        {"appearances": [{"appearance": "luminosity", "value": "dark"}],
         "filename": "icon-1024.png", "idiom": "universal", "platform": "ios",  "size": "1024x1024"},
        {"appearances": [{"appearance": "luminosity", "value": "tinted"}],
         "filename": "icon-1024.png", "idiom": "universal", "platform": "ios",  "size": "1024x1024"},
        {"filename": "icon-16.png",   "idiom": "mac", "scale": "1x", "size": "16x16"},
        {"filename": "icon-32.png",   "idiom": "mac", "scale": "2x", "size": "16x16"},
        {"filename": "icon-32.png",   "idiom": "mac", "scale": "1x", "size": "32x32"},
        {"filename": "icon-64.png",   "idiom": "mac", "scale": "2x", "size": "32x32"},
        {"filename": "icon-128.png",  "idiom": "mac", "scale": "1x", "size": "128x128"},
        {"filename": "icon-256.png",  "idiom": "mac", "scale": "2x", "size": "128x128"},
        {"filename": "icon-256.png",  "idiom": "mac", "scale": "1x", "size": "256x256"},
        {"filename": "icon-512.png",  "idiom": "mac", "scale": "2x", "size": "256x256"},
        {"filename": "icon-512.png",  "idiom": "mac", "scale": "1x", "size": "512x512"},
        {"filename": "icon-1024.png", "idiom": "mac", "scale": "2x", "size": "512x512"},
    ]
    (ICON_DIR / "Contents.json").write_text(
        json.dumps({"images": images, "info": {"author": "xcode", "version": 1}}, indent=2) + "\n",
        encoding="utf-8",
    )


def main():
    ICON_DIR.mkdir(parents=True, exist_ok=True)
    for size in SIZES:
        print(f"  Rendering {size}×{size}…", end=" ", flush=True)
        rgb = render_icon(size)
        (ICON_DIR / f"icon-{size}.png").write_bytes(png_bytes(size, size, rgb))
        print("done")
    write_contents()
    print(f"\nAll icons written to {ICON_DIR}")


if __name__ == "__main__":
    main()
