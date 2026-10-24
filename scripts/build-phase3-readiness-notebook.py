#!/usr/bin/env python3
"""Create and execute a dependency-light Phase 3 readiness notebook."""

from __future__ import annotations

import contextlib
import html
import io
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "DataProject/quality/phase3-readiness-analysis.ipynb"
HTML = ROOT / "DataProject/quality/phase3-readiness-analysis.html"

code_cells = [
    """from pathlib import Path\nimport csv, json\nROOT = Path.cwd()\nqueue = json.loads((ROOT / 'DataProject/operations/source-verification-queue.json').read_text())\nwave2 = json.loads((ROOT / 'DataProject/quality/freshness-review-wave-2.json').read_text())\npartners = json.loads((ROOT / 'DataProject/research/business-partner-verification-wave-1.json').read_text())\nprint('Inputs loaded:', queue['pending_total'], wave2['selection_size'], partners['summary']['total'])""",
    """summary = {\n    'Audited stale baseline': queue['audited_stale_baseline'],\n    'Confirmed current': queue['confirmed_current_excluded'],\n    'Pending factual review': queue['pending_total'],\n    'Phase 3 wave prepared': wave2['selection_size'],\n    'Partner identities verified': partners['summary']['verified_identity'],\n    'Public business contact routes observed': partners['summary']['public_contact_route_observed'],\n    'Partners ready for contact': partners['summary']['ready_for_contact'],\n    'Messages sent': partners['summary']['sent'],\n}\nfor label, value in summary.items(): print(f'{label}: {value}')""",
    """assert queue['audited_stale_baseline'] == 415\nassert queue['confirmed_current_excluded'] == 5\nassert queue['pending_total'] == 410\nassert queue['phase_counts'] == {'backlog': 315, 'wave_1_pending': 45, 'wave_2': 50}\nassert wave2['verification_status_counts'] == {'awaiting_fact_review': 50}\nassert all(row['verification_status'] == 'awaiting_fact_review' for row in wave2['records'])\nassert partners['summary']['ready_for_contact'] == 0\nassert partners['summary']['sent'] == 0\nassert partners['summary']['registered'] == 0\nprint('PASS: counts reconcile and no URL reachability was promoted to factual verification.')""",
    """coverage = {\n    'verified_identity': partners['summary']['verified_identity'],\n    'identity_needs_manual_review': partners['summary']['total'] - partners['summary']['verified_identity'],\n    'public_contact_route_observed': partners['summary']['public_contact_route_observed'],\n    'contact_route_needs_manual_review': partners['summary']['total'] - partners['summary']['public_contact_route_observed'],\n}\nfor label, value in coverage.items(): print(f'{label}: {value}/30')""",
]


def execute(cells: list[str]):
    namespace: dict[str, object] = {}
    executed = []
    for count, source in enumerate(cells, start=1):
        stream = io.StringIO()
        try:
            with contextlib.redirect_stdout(stream):
                exec(compile(source, f"phase3-cell-{count}", "exec"), namespace)
            outputs = [{"name": "stdout", "output_type": "stream", "text": stream.getvalue()}]
        except Exception as exc:  # pragma: no cover - generation must stop on failure
            raise SystemExit(f"Notebook cell {count} failed: {exc}") from exc
        executed.append({
            "cell_type": "code",
            "execution_count": count,
            "metadata": {},
            "outputs": outputs,
            "source": [line + "\n" for line in source.splitlines()],
        })
    return namespace, executed


def main() -> None:
    namespace, executed = execute(code_cells)
    summary = namespace["summary"]
    coverage = namespace["coverage"]
    notebook = {
        "cells": [
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": [
                    "# YouNew Phase 3 readiness analysis\n",
                    "\n",
                    "Executed on the governed local artifacts. HTTP reachability is never treated as factual confirmation, and public business contact routes are never treated as marketing consent.\n",
                ],
            },
            *executed,
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": [
                    "## Interpretation\n",
                    "\n",
                    "The next 50 catalog records are prepared, not verified. Twenty-seven of 30 supplied businesses had observable identity evidence, but only 17 exposed a public business contact route in this bounded check. Zero are marked ready for outreach because a legal basis was not established.\n",
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
    OUT.write_text(json.dumps(notebook, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    cards = "".join(
        f"<article><strong>{value}</strong><span>{html.escape(label)}</span></article>"
        for label, value in summary.items()
    )
    bars = "".join(
        f"<div class='bar-row'><span>{html.escape(label.replace('_', ' '))}</span><div><i style='width:{value / 30 * 100:.1f}%'></i></div><b>{value}/30</b></div>"
        for label, value in coverage.items()
    )
    document = f"""<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>YouNew Phase 3 readiness analysis</title><style>
    :root{{--ink:#17324d;--muted:#617383;--cyan:#16a6b6;--orange:#ec6f3b;--paper:#f5f7f8}}*{{box-sizing:border-box}}body{{margin:0;font:16px/1.5 system-ui,sans-serif;color:var(--ink);background:var(--paper)}}main{{max-width:1050px;margin:auto;padding:48px 24px}}h1{{font-size:clamp(2rem,5vw,3.7rem);line-height:1.02;margin:.2em 0}}.eyebrow{{color:var(--orange);font-weight:800;text-transform:uppercase;letter-spacing:.08em}}.note{{max-width:760px;color:var(--muted)}}.cards{{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:14px;margin:32px 0}}article{{background:white;border:1px solid #dce5e8;border-radius:16px;padding:20px}}article strong{{display:block;font-size:2rem;color:var(--cyan)}}article span{{color:var(--muted)}}section{{background:white;border-radius:18px;padding:24px;margin-top:20px;border:1px solid #dce5e8}}.bar-row{{display:grid;grid-template-columns:minmax(180px,1.7fr) 3fr 52px;gap:12px;align-items:center;margin:14px 0}}.bar-row div{{height:12px;background:#e8eef0;border-radius:20px;overflow:hidden}}.bar-row i{{display:block;height:100%;background:linear-gradient(90deg,var(--cyan),#69ccd5)}}.warning{{border-left:5px solid var(--orange)}}code{{background:#edf2f4;padding:.15em .35em;border-radius:5px}}@media(max-width:640px){{main{{padding:28px 16px}}.bar-row{{grid-template-columns:1fr 52px}}.bar-row div{{grid-row:2;grid-column:1 / 3}}}}
    </style></head><body><main><p class='eyebrow'>YouNew · Phase 3 · 23 October 2026</p><h1>Readiness evidence, not vanity counts</h1><p class='note'>This report reconciles the governed source-verification queue and the supplied 30-company wave. A reachable URL is not a factual confirmation, and a public contact page is not marketing consent.</p><div class='cards'>{cards}</div><section><h2>Partner verification coverage</h2>{bars}</section><section class='warning'><h2>Decision</h2><p>The next 50 catalog records are prepared for review but remain stale. No prospect is ready for outreach. Production launch still requires the complete disposable database chain, release approval and live post-deploy checks.</p></section></main></body></html>"""
    HTML.write_text(document, encoding="utf-8")
    print(f"Wrote executed notebook: {OUT}")
    print(f"Wrote visual report: {HTML}")


if __name__ == "__main__":
    main()
