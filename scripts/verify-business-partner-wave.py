#!/usr/bin/env python3
"""Recheck the supplied 30-company wave without collecting personal contacts.

This is bounded enrichment of an existing governed list. It opens only the
already supplied official URL, records evidence, and finds same-site public
business contact routes. It never sends a message and never infers permission
to market from a reachable website or contact page.
"""

from __future__ import annotations

import csv
import html
import json
import re
import ssl
import unicodedata
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urljoin, urlparse, urlunparse
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "DataProject/research/business-partners-wave-1.json"
OUTPUT_JSON = ROOT / "DataProject/research/business-partner-verification-wave-1.json"
OUTPUT_CSV = ROOT / "DataProject/research/business-partner-status-tracker.csv"
OUTPUT_MD = ROOT / "DataProject/research/business-partner-offers-nl-phase3.md"
MAX_BYTES = 512_000
CONTACT_PATH_TOKENS = {"contact", "contacteer", "business", "zakelijk", "partnership", "partnerships", "partner", "partners"}
NON_PAGE_SUFFIXES = {".css", ".js", ".mjs", ".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp", ".woff", ".woff2"}
GENERIC_TOKENS = {"restaurant", "cafe", "coffee", "amsterdam", "hotel", "the", "and", "group", "bv", "b.v"}


def normalized(value: str) -> str:
    value = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode("ascii")
    return re.sub(r"[^a-z0-9]+", " ", value.casefold()).strip()


def identity_tokens(name: str) -> list[str]:
    return [token for token in normalized(name).split() if len(token) >= 3 and token not in GENERIC_TOKENS]


def title_from_html(source: str) -> str:
    match = re.search(r"<title[^>]*>(.*?)</title>", source, flags=re.IGNORECASE | re.DOTALL)
    return re.sub(r"\s+", " ", html.unescape(match.group(1))).strip()[:240] if match else ""


def contact_links(source: str, final_url: str) -> list[str]:
    links = []
    origin = urlparse(final_url)
    for match in re.finditer(r"href\s*=\s*['\"]([^'\"#]+)", source, flags=re.IGNORECASE):
        href = html.unescape(match.group(1)).strip()
        absolute = urljoin(final_url, href)
        parsed = urlparse(absolute)
        if parsed.scheme not in {"http", "https"} or parsed.netloc != origin.netloc:
            continue
        if any(parsed.path.casefold().endswith(suffix) for suffix in NON_PAGE_SUFFIXES):
            continue
        path_tokens = set(normalized(parsed.path).split())
        stable_url = urlunparse((parsed.scheme, parsed.netloc, parsed.path, "", "", ""))
        if path_tokens & CONTACT_PATH_TOKENS and stable_url not in links:
            links.append(stable_url[:500])
    return links[:3]


def classify_first_contact(routes: list[str]) -> tuple[str, str]:
    """Classify the channel without asserting a legal basis for outreach."""
    if not routes:
        return ("no_public_contact_route", "inbound_or_research_only")
    tokens = set()
    for route in routes:
        tokens.update(normalized(urlparse(route).path).split())
    if tokens & {"partnership", "partnerships", "partner", "partners", "advertising"}:
        return (
            "published_partnership_context_requires_manual_validation",
            "manual_channel_and_legal_review_before_any_contact",
        )
    if tokens & {"contact", "contacteer"}:
        return (
            "general_official_contact_route_requires_terms_review",
            "manual_channel_and_legal_review_before_any_contact",
        )
    return (
        "business_context_page_not_a_contact_permission",
        "inbound_or_research_only",
    )


def check(prospect: dict) -> dict:
    requested_url = prospect["public_business_channel"]
    request = Request(requested_url, headers={
        "User-Agent": "YouNew-source-review/1.0 (+https://younew.nl/)",
        "Accept": "text/html,application/xhtml+xml",
        "Accept-Language": "nl,en;q=0.8",
    })
    checked_at = datetime.now(timezone.utc).isoformat()
    try:
        with urlopen(request, timeout=12, context=ssl.create_default_context()) as response:
            body = response.read(MAX_BYTES + 1)
            if len(body) > MAX_BYTES:
                body = body[:MAX_BYTES]
            charset = response.headers.get_content_charset() or "utf-8"
            source = body.decode(charset, errors="replace")
            final_url = response.geturl()
            status = int(response.status)
            page_title = title_from_html(source)
            text_sample = normalized(re.sub(r"<[^>]+>", " ", source))[:30_000]
            tokens = identity_tokens(prospect["account_name"])
            matched = [token for token in tokens if token in text_sample or token in normalized(page_title)]
            identity_match = bool(matched) if tokens else False
            contacts = contact_links(source, final_url)
            legal_contact_segment, permitted_first_action = classify_first_contact(contacts)
            evidence_state = "identity_and_public_channel_observed" if identity_match and contacts else "identity_observed" if identity_match else "source_opened_identity_not_confirmed"
            pipeline_status = "verified" if identity_match else "found"
            return {
                **prospect,
                "pipeline_status": pipeline_status,
                "official_source_checked_at": checked_at,
                "official_source_http_status": status,
                "official_source_final_url": final_url,
                "official_source_page_title": page_title,
                "identity_tokens_matched": matched,
                "public_contact_routes": contacts,
                "legal_contact_segment": legal_contact_segment,
                "permitted_first_action": permitted_first_action,
                "evidence_state": evidence_state,
                "legal_basis_status": "not_established",
                "contact_readiness": "hold_do_not_contact",
                "message_sent_at": None,
                "reply_received_at": None,
                "registration_evidence": None,
            }
    except HTTPError as error:
        return {
            **prospect,
            "pipeline_status": "found",
            "official_source_checked_at": checked_at,
            "official_source_http_status": error.code,
            "official_source_final_url": error.geturl(),
            "official_source_page_title": "",
            "identity_tokens_matched": [],
            "public_contact_routes": [],
            "legal_contact_segment": "source_restricted_or_unavailable",
            "permitted_first_action": "inbound_or_research_only",
            "evidence_state": "source_restricted_or_unavailable",
            "legal_basis_status": "not_established",
            "contact_readiness": "hold_do_not_contact",
            "message_sent_at": None,
            "reply_received_at": None,
            "registration_evidence": None,
        }
    except (URLError, TimeoutError, ValueError, ssl.SSLError) as error:
        return {
            **prospect,
            "pipeline_status": "found",
            "official_source_checked_at": checked_at,
            "official_source_http_status": None,
            "official_source_final_url": requested_url,
            "official_source_page_title": "",
            "identity_tokens_matched": [],
            "public_contact_routes": [],
            "legal_contact_segment": "source_check_failed",
            "permitted_first_action": "inbound_or_research_only",
            "evidence_state": f"source_check_failed:{type(error).__name__}",
            "legal_basis_status": "not_established",
            "contact_readiness": "hold_do_not_contact",
            "message_sent_at": None,
            "reply_received_at": None,
            "registration_evidence": None,
        }


def segment_copy(segment: str) -> tuple[str, str, str]:
    if segment == "restaurants":
        return (
            "restaurant",
            "locatie, reserveringsroute, keuken en officiële website",
            "mensen die hun nieuwe stad nog leren kennen",
        )
    if segment == "shops_and_cafes":
        return (
            "winkel of café",
            "vestiging, aanbod, bereikbaarheid en officiële contactroute",
            "nieuwe inwoners en bezoekers die lokaal willen kopen",
        )
    return (
        "dienstverlener",
        "werkgebied, openbare voorwaarden en officiële contactroute",
        "internationals en nieuwe inwoners die betrouwbare praktische hulp zoeken",
    )


def write_offers(rows: list[dict]) -> None:
    lines = [
        "# Persoonlijke conceptvoorstellen — eerste 30 bedrijven",
        "",
        "Status: **concept, niet verzonden**. Hoofdaanbod: een gratis, brongecontroleerd profiel. Een openbare website of contactpagina is geen toestemming voor marketing. Gebruik een concept pas nadat toestemming of een aantoonbaar voor acquisitie gepubliceerd kanaal juridisch is beoordeeld.",
        "",
        "## Propositie per segment",
        "",
        "- Restaurants: gratis controle van locatie, reserveringsroute, keukenomschrijving en officiële bron; geen betaalde invloed op organische rangschikking.",
        "- Winkels en cafés: gratis controle van vestiging, aanbod, bereikbaarheid en officiële contactroute.",
        "- Dienstverleners: gratis controle van werkgebied, openbare voorwaarden en officiële contactroute; gereguleerde claims blijven bij de bevoegde bron.",
        "",
    ]
    for index, row in enumerate(rows, start=1):
        label, facts, audience = segment_copy(row["segment"])
        name = row["account_name"]
        contact_route = row["public_contact_routes"][0] if row["public_contact_routes"] else "Nog niet bevestigd"
        lines.extend([
            f"## {index}. {name}",
            "",
            f"- Bewijsstatus: `{row['pipeline_status']}` — {row['evidence_state']}",
            f"- Openbare zakelijke route: {contact_route}",
            f"- Kanaalclassificatie: `{row['legal_contact_segment']}`",
            f"- Toegestane volgende stap: `{row['permitted_first_action']}`",
            "- Verzendstatus: `niet_verzonden`",
            "",
            f"**Onderwerp:** Gratis brongecontroleerd YouNew-profiel voor {name}",
            "",
            f"**Concept:** Beste team van {name}, YouNew helpt {audience} om lokale organisaties in Amsterdam beter te begrijpen. We bieden {name} kosteloos een gecontroleerd profiel aan met uitsluitend openbare informatie over {facts}. Publicatie volgt pas na broncontrole; het profiel geeft geen betaalde voorkeur in zoekresultaten. Als dit relevant is en dit kanaal zulke zakelijke voorstellen accepteert, sturen we graag eerst de korte profielopzet ter beoordeling. Met vriendelijke groet, YouNew.",
            "",
        ])
    OUTPUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    prospects = json.loads(INPUT.read_text(encoding="utf-8"))["prospects"]
    if len(prospects) != 30:
        raise SystemExit(f"Expected the supplied 30-company list, found {len(prospects)}")

    rows: list[dict] = []
    with ThreadPoolExecutor(max_workers=8) as executor:
        futures = {executor.submit(check, prospect): prospect for prospect in prospects}
        for future in as_completed(futures):
            rows.append(future.result())
    order = {prospect["entity_id"]: index for index, prospect in enumerate(prospects)}
    rows.sort(key=lambda row: order[row["entity_id"]])

    summary = {
        "total": len(rows),
        "verified_identity": sum(row["pipeline_status"] == "verified" for row in rows),
        "public_contact_route_observed": sum(bool(row["public_contact_routes"]) for row in rows),
        "ready_for_contact": sum(row["contact_readiness"] == "ready_for_contact" for row in rows),
        "sent": sum(bool(row["message_sent_at"]) for row in rows),
        "registered": sum(bool(row["registration_evidence"]) for row in rows),
        "manual_channel_and_legal_review": sum(
            row["permitted_first_action"] == "manual_channel_and_legal_review_before_any_contact"
            for row in rows
        ),
        "inbound_or_research_only": sum(
            row["permitted_first_action"] == "inbound_or_research_only"
            for row in rows
        ),
    }
    payload = {
        "schema_version": 1,
        "checked_at": max(row["official_source_checked_at"] for row in rows),
        "scope": "Bounded recheck of the 30 supplied official business URLs; no discovery of personal contacts and no outreach.",
        "status_model": ["found", "verified", "ready_for_contact", "sent", "replied", "interested", "registered"],
        "proof_rules": {
            "verified": "A supplied official source opened and the company identity was observed on that page.",
            "ready_for_contact": "Requires separate evidence of consent or a channel consciously published for this type of commercial approach.",
            "channel_classification": "A general Contact or Business page is a review candidate, not proof of consent or a lawful unsolicited-marketing basis.",
            "sent_or_later": "Requires dated operational evidence; no row is advanced without it.",
        },
        "summary": summary,
        "prospects": rows,
    }
    OUTPUT_JSON.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    fieldnames = [
        "account_name", "entity_id", "segment", "city", "pipeline_status", "public_business_channel",
        "official_source_final_url", "official_source_http_status", "official_source_checked_at",
        "evidence_state", "public_contact_route", "legal_basis_status", "contact_readiness",
        "legal_contact_segment", "permitted_first_action",
        "message_sent_at", "reply_received_at", "registration_evidence",
    ]
    with OUTPUT_CSV.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({
                **{key: row.get(key) for key in fieldnames},
                "public_contact_route": row["public_contact_routes"][0] if row["public_contact_routes"] else "",
            })

    write_offers(rows)
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
