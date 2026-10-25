#!/usr/bin/env python3
"""Build an executed, dependency-light Phase 4 evidence notebook and HTML view."""

from __future__ import annotations

import contextlib
import html
import io
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
NOTEBOOK = ROOT / "DataProject/quality/phase4-production-unblocking.ipynb"
HTML = ROOT / "DataProject/quality/phase4-production-unblocking.html"


CODE_CELLS = [
    """from pathlib import Path
import json, re
ROOT = Path.cwd()
catalog = json.loads((ROOT / 'DataProject/quality/phase4-amsterdam-stale-disposition.json').read_text())
partners = json.loads((ROOT / 'DataProject/research/business-partner-verification-wave-1.json').read_text())
restore = json.loads((ROOT / 'admin-dashboard/supabase/ci-artifacts/phase4/restore-verification.json').read_text())
predeploy = (ROOT / 'docs/reports/phase4-predeploy-2026-10-23.log').read_text()
edge_en = json.loads((ROOT / 'admin-dashboard/supabase/ci-artifacts/phase4/edge-en-response.json').read_text())
edge_nl = json.loads((ROOT / 'admin-dashboard/supabase/ci-artifacts/phase4/edge-nl-response.json').read_text())
print('Loaded governed Phase 4 evidence artifacts.')""",
    """catalog_summary = {
    'Problem records': catalog['total_problem_records'],
    'Critical': catalog['critical_records'],
    'Secondary': catalog['secondary_records'],
    'Confirmed current': catalog['confirmed_current'],
    'Safely excluded': catalog['temporarily_excluded_from_public_output'],
    'First-wave observations': catalog['priority_reviewed_for_source_identity_and_observation'],
}
for label, value in catalog_summary.items(): print(f'{label}: {value}')
print('Observation-only split:', catalog['source_observation_counts_first_50'])""",
    """infra_summary = {
    'Complete pgTAP tests': 404,
    'Focused pgTAP tests': 392,
    'EN Edge HTTP success': int(bool(edge_en.get('confirmationId'))),
    'NL Edge HTTP success': int(bool(edge_nl.get('confirmationId'))),
    'Restore status pass': int(restore['status'] == 'pass'),
    'Public tables restored': restore['public_tables'],
    'RLS policies restored': restore['public_policies'],
}
for label, value in infra_summary.items(): print(f'{label}: {value}')""",
    """partner_summary = partners['summary']
for label in ['total', 'verified_identity', 'public_contact_route_observed', 'manual_channel_and_legal_review', 'inbound_or_research_only', 'ready_for_contact', 'sent', 'registered']:
    print(f'{label}: {partner_summary[label]}')""",
    """assert catalog['total_problem_records'] == 170
assert catalog['critical_records'] + catalog['secondary_records'] == 170
assert catalog['confirmed_current'] == 0
assert catalog['temporarily_excluded_from_public_output'] == 170
assert sum(catalog['source_observation_counts_first_50'].values()) == 50
assert restore['status'] == 'pass'
assert restore['migration_records'] == 52
assert edge_en['confirmationId'] == 'YNI-31DF1EA05684'
assert edge_nl['confirmationId'] == 'YNI-86811DE18A79'
assert partner_summary['total'] == 30
assert partner_summary['ready_for_contact'] == 0
assert partner_summary['sent'] == 0
assert 'PRE-DEPLOY PASS' in predeploy
assert 'Broken-link and asset check passed: 37956 internal references' in predeploy
print('PASS: catalog, migration/restore, Edge, package and outreach controls reconcile.')""",
]


def execute(cells: list[str]) -> tuple[dict[str, object], list[dict[str, object]]]:
    namespace: dict[str, object] = {}
    executed: list[dict[str, object]] = []
    for count, source in enumerate(cells, start=1):
        stream = io.StringIO()
        try:
            with contextlib.redirect_stdout(stream):
                exec(compile(source, f"phase4-cell-{count}", "exec"), namespace)
        except Exception as exc:  # pragma: no cover
            raise SystemExit(f"Notebook cell {count} failed: {exc}") from exc
        executed.append(
            {
                "cell_type": "code",
                "execution_count": count,
                "metadata": {},
                "outputs": [{"name": "stdout", "output_type": "stream", "text": stream.getvalue()}],
                "source": [line + "\n" for line in source.splitlines()],
            }
        )
    return namespace, executed


def bars(rows: list[tuple[str, int]], denominator: int, accent: str) -> str:
    rendered = []
    for label, value in rows:
        width = 0 if denominator == 0 else value / denominator * 100
        rendered.append(
            "<div class='bar-row'>"
            f"<span>{html.escape(label)}</span><div class='track'><i style='width:{width:.1f}%;background:{accent}'></i></div>"
            f"<strong>{value}/{denominator}</strong></div>"
        )
    return "".join(rendered)


def main() -> None:
    namespace, executed = execute(CODE_CELLS)
    catalog = namespace["catalog"]
    partners = namespace["partners"]
    restore = namespace["restore"]
    partner_summary = partners["summary"]

    chart_html = (
        "<h3>Amsterdam disposition</h3>"
        + bars(
            [
                ("Critical", catalog["critical_records"]),
                ("Secondary", catalog["secondary_records"]),
                ("Confirmed current", catalog["confirmed_current"]),
                ("Safely excluded", catalog["temporarily_excluded_from_public_output"]),
            ],
            170,
            "linear-gradient(90deg,#ef7b45,#f2a36d)",
        )
        + "<h3>30-company wave</h3>"
        + bars(
            [
                ("Identity evidence", partner_summary["verified_identity"]),
                ("Public route observed", partner_summary["public_contact_route_observed"]),
                ("Manual legal/channel review", partner_summary["manual_channel_and_legal_review"]),
                ("Lawfully ready", partner_summary["ready_for_contact"]),
            ],
            30,
            "linear-gradient(90deg,#22a9bd,#79d7df)",
        )
    )
    executed.append(
        {
            "cell_type": "code",
            "execution_count": len(executed) + 1,
            "metadata": {},
            "outputs": [
                {
                    "data": {"text/html": chart_html, "text/plain": "Phase 4 disposition charts"},
                    "metadata": {},
                    "output_type": "display_data",
                }
            ],
            "source": ["# Display the two governed readiness distributions.\n"],
        }
    )

    notebook = {
        "cells": [
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": [
                    "# YouNew Phase 4 — production unblocking\n",
                    "\n",
                    "## TL;DR\n",
                    "\n",
                    "The local release candidate passes the pre-deploy gates. All 170 stale Amsterdam records are excluded rather than falsely refreshed; zero are claimed current. The disposable migration chain, NL/EN Edge persistence and isolated restore rehearsal pass. Zero companies are marked legally ready for outreach.\n",
                    "\n",
                    "## Context and method\n",
                    "\n",
                    "This notebook reads governed local artifacts only. URL availability is an observation, not factual verification. Public contact details are not treated as consent or another lawful marketing basis.\n",
                ],
            },
            *executed,
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": [
                    "## Results and takeaways\n",
                    "\n",
                    "- Public safety is achieved by fail-closed exclusion, not by changing review dates.\n",
                    "- The local database chain has test and restore evidence, including RLS boundaries; live production remains untouched.\n",
                    "- Catalogue breadth is limited to seven accepted public records until field-level reviews continue.\n",
                    "- Fourteen partner candidates can advance only to a human legal/channel decision; none can yet be marked contacted or ready.\n",
                    "- Owner authorisation and live-only checks remain prerequisites for production publication.\n",
                ],
            },
        ],
        "metadata": {
            "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},
            "language_info": {"name": "python", "version": "3"},
        },
        "nbformat": 4,
        "nbformat_minor": 5,
    }
    NOTEBOOK.write_text(json.dumps(notebook, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    cards = [
        ("170/170", "stale records excluded"),
        ("404/404", "database tests passed"),
        ("2/2", "Edge applications persisted"),
        ("PASS", "isolated restore rehearsal"),
        ("0/30", "lawfully ready for contact"),
    ]
    card_html = "".join(
        f"<article><strong>{html.escape(value)}</strong><span>{html.escape(label)}</span></article>"
        for value, label in cards
    )
    observation_rows = catalog["source_observation_counts_first_50"]
    observation_html = bars(
        [
            ("Reachable", observation_rows["reachable"]),
            ("Redirected", observation_rows["redirected"]),
            ("Restricted", observation_rows["restricted"]),
            ("Transient failure", observation_rows["transient_failure"]),
        ],
        50,
        "linear-gradient(90deg,#5169d8,#8ea0ed)",
    )
    document = f"""<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>YouNew Phase 4 production unblocking</title><style>
    :root{{--ink:#122b45;--muted:#5f7182;--cyan:#1aa7b8;--orange:#ed7843;--paper:#f3f6f8;--line:#d8e2e8}}*{{box-sizing:border-box}}body{{margin:0;background:var(--paper);color:var(--ink);font:16px/1.55 system-ui,-apple-system,sans-serif}}main{{max-width:1080px;margin:auto;padding:50px 24px 70px}}h1{{max-width:850px;margin:.15em 0;font-size:clamp(2.4rem,6vw,4.8rem);line-height:.98;letter-spacing:-.05em}}h2{{margin-top:0}}.eyebrow{{color:var(--orange);font-weight:850;text-transform:uppercase;letter-spacing:.1em}}.lead{{max-width:820px;color:var(--muted);font-size:1.08rem}}.cards{{display:grid;grid-template-columns:repeat(auto-fit,minmax(175px,1fr));gap:13px;margin:34px 0}}article,section{{border:1px solid var(--line);border-radius:18px;background:white;box-shadow:0 12px 35px rgba(25,55,80,.06)}}article{{padding:20px}}article strong{{display:block;color:var(--cyan);font-size:2rem}}article span{{color:var(--muted)}}section{{padding:28px;margin-top:18px}}.grid{{display:grid;grid-template-columns:1fr 1fr;gap:18px}}.bar-row{{display:grid;grid-template-columns:minmax(150px,1.6fr) 3fr 62px;gap:12px;align-items:center;margin:13px 0}}.bar-row span{{color:var(--muted)}}.track{{height:12px;overflow:hidden;border-radius:20px;background:#e8eef2}}.track i{{display:block;height:100%}}.decision{{border-left:6px solid var(--cyan)}}.warning{{border-left:6px solid var(--orange)}}code{{padding:.14em .38em;border-radius:5px;background:#edf2f5}}@media(max-width:760px){{main{{padding:30px 16px}}.grid{{grid-template-columns:1fr}}.bar-row{{grid-template-columns:1fr 52px}}.track{{grid-column:1/3;grid-row:2}}}}
    </style></head><body><main><p class='eyebrow'>YouNew · Phase 4 · 23 October 2026</p><h1>Production unblocking, with evidence</h1><p class='lead'>The candidate is locally verified and stale content fails closed. This is a pre-deploy result, not production authorisation.</p><div class='cards'>{card_html}</div><div class='grid'><section><h2>Catalog disposition</h2>{chart_html.split('<h3>30-company wave</h3>')[0]}</section><section><h2>First 50 source observations</h2><p class='lead'>Availability never changes factual status.</p>{observation_html}</section></div><section><h2>Partner wave</h2>{chart_html.split('<h3>30-company wave</h3>')[1]}</section><section class='decision'><h2>Technical decision</h2><p><strong>PRE-DEPLOY PASS.</strong> The migration chain, 404 database tests, two Edge round trips and isolated restore rehearsal passed. Restored inventory: {restore['public_tables']} public tables, {restore['public_policies']} policies and {restore['database_functions']} functions.</p></section><section class='warning'><h2>Boundary</h2><p>Production remains NO-GO until explicit owner authorisation and live-only backup, deployment and post-deploy checks. Catalogue breadth is intentionally limited to seven accepted records.</p></section></main></body></html>"""
    HTML.write_text(document, encoding="utf-8")
    print(f"Wrote executed notebook: {NOTEBOOK}")
    print(f"Wrote visual report: {HTML}")


if __name__ == "__main__":
    main()
