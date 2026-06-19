#!/usr/bin/env python3
import html
import importlib.util
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "VISUAL_AUDIT_GALLERY.html"


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


runtime_qa = load_module("image_runtime_data_qa", ROOT / "scripts" / "image-runtime-data-qa.py")
remote_qa = load_module("visible_image_remote_qa", ROOT / "scripts" / "visible-image-remote-qa.py")


def e(value: object) -> str:
    return html.escape(str(value), quote=True)


def visual_cards(prefix: str, roles: tuple[str, ...]) -> list[dict[str, object]]:
    records = runtime_qa.visual_records(prefix, roles)
    cards: list[dict[str, object]] = []
    for place_id in sorted(records):
        for role in roles:
            record = records[place_id].get(role)
            if not record:
                continue
            cards.append({
                "group": prefix.title(),
                "place": place_id,
                "role": role,
                "title": record["title"],
                "why": record["why"],
                "safe": record["safeArea"],
                "url": record["url"],
                "wide": role in {"hero", "landscape"},
            })
    return cards


def tourism_cards() -> list[dict[str, object]]:
    cards: list[dict[str, object]] = []
    for record in runtime_qa.tourism_catalog_records():
        cards.append({
            "group": "Tourism",
            "place": record["location"],
            "role": record["category"],
            "title": record["name"],
            "why": record["why"],
            "safe": f"Best season: {record['season']}",
            "url": record["url"],
            "wide": False,
        })
    return cards


def render_card(card: dict[str, object]) -> str:
    wide_class = " wide" if card["wide"] else ""
    return f"""
      <article class="card{wide_class}">
        <div class="imageWrap">
          <img src="{e(card['url'])}" alt="{e(card['title'])}" loading="lazy" />
        </div>
        <div class="meta">
          <div class="eyebrow">{e(card['group'])} / {e(card['role'])}</div>
          <h2>{e(card['title'])}</h2>
          <p class="place">{e(card['place'])}</p>
          <p>{e(card['why'])}</p>
          <p class="safe">{e(card['safe'])}</p>
        </div>
      </article>
    """


def main() -> None:
    cards = (
        visual_cards("city", runtime_qa.REQUIRED_CITY_VISUAL_ROLES)
        + visual_cards("province", runtime_qa.REQUIRED_PROVINCE_VISUAL_ROLES)
        + tourism_cards()
    )
    visible_count = len(remote_qa.visible_images())

    html_doc = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>YouNew Visual Audit Gallery</title>
  <style>
    :root {{
      color-scheme: dark;
      --bg: #071016;
      --panel: #101b23;
      --line: #29404c;
      --text: #edf7f8;
      --muted: #9eb2ba;
      --accent: #7ed6cf;
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: var(--bg);
      color: var(--text);
    }}
    header {{
      position: sticky;
      top: 0;
      z-index: 3;
      padding: 18px clamp(16px, 4vw, 44px);
      background: rgba(7, 16, 22, 0.94);
      border-bottom: 1px solid var(--line);
      backdrop-filter: blur(14px);
    }}
    h1 {{
      margin: 0 0 5px;
      font-size: 22px;
      letter-spacing: 0;
    }}
    header p {{
      margin: 0;
      color: var(--muted);
      font-size: 13px;
    }}
    main {{
      padding: 22px clamp(16px, 4vw, 44px) 44px;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 18px;
    }}
    .card {{
      border: 1px solid var(--line);
      background: var(--panel);
      border-radius: 8px;
      overflow: hidden;
    }}
    .card.wide {{
      grid-column: span 2;
    }}
    .imageWrap {{
      aspect-ratio: 4 / 3;
      background: #09131b;
      overflow: hidden;
    }}
    .wide .imageWrap {{
      aspect-ratio: 16 / 9;
    }}
    img {{
      width: 100%;
      height: 100%;
      object-fit: cover;
      object-position: center;
      display: block;
    }}
    .meta {{
      padding: 13px;
    }}
    .eyebrow {{
      color: var(--accent);
      font-size: 11px;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: 0;
    }}
    h2 {{
      margin: 6px 0 4px;
      font-size: 17px;
      letter-spacing: 0;
    }}
    p {{
      margin: 7px 0 0;
      color: var(--muted);
      font-size: 13px;
      line-height: 1.42;
    }}
    .place {{
      color: #c9dadf;
      font-weight: 700;
    }}
    .safe {{
      color: #d4c58c;
    }}
    @media (max-width: 720px) {{
      .card.wide {{
        grid-column: span 1;
      }}
    }}
  </style>
</head>
<body>
  <header>
    <h1>YouNew Visual Audit Gallery</h1>
    <p>{len(cards)} rendered audit cards from the current registry; visible-image QA covers {visible_count} app assignments. Images use aspect fill to expose crop risks for manual review.</p>
  </header>
  <main>
    {''.join(render_card(card) for card in cards)}
  </main>
</body>
</html>
"""
    OUTPUT.write_text(html_doc, encoding="utf-8")
    print(f"Wrote {OUTPUT.relative_to(ROOT)}")
    print(f"Audit cards: {len(cards)}")
    print(f"Visible assignments covered by QA: {visible_count}")


if __name__ == "__main__":
    main()
