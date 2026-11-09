# ADR-017 — Reversible withdrawal of overdue content

- Status: accepted
- Date: 2026-11-09
- Draft author: Codex
- Human decision owner: @zq87xf5jyp-arch (explicit launch instruction to hide unconfirmed/stale records while preserving originals)
- Supersedes: none
- Related contracts: immutable release overlays; publication eligibility; runtime migration registry
- Related migrations: none

## Problem and context

All 172 published records in the effective Amsterdam 0.1.8 release are past their stored review deadlines. The website already withholds these records, but the canonical mobile/Admin artifact still labels them published. Strict publication checks correctly reject that state. Ten reverified records in the unapproved 0.1.9 candidate and the 71 new launch drafts have no publication approval.

## Considered options

1. Reverify and obtain publication acceptance for replacement content.
2. Preserve the entire historical release and withdraw overdue records through a new immutable patch.
3. Change verification dates or weaken strict publication checks.

## Decision

Apply option 2 under the owner's explicit instruction: “Устаревшие сведения перепроверь; неподтверждённые скрой из публичной выдачи с сохранением исходных данных.” Version 0.1.10 changes only the 172 records' lifecycle from published to retired. Every fact, source URL, verification date, coordinate and media reference stays byte-equivalent at the field level. This is suppression authorization, not editorial approval of new or reverified facts.

Preserve the unpublished 0.1.9 overlay and its replacement evidence as a retired review candidate for later rebase. Publish none of its changes. Keep all 71 new drafts unapproved. The canonical runtime carries explicit withheld IDs, so mapped legacy records cannot reappear when a canonical record is withdrawn. Keep strict CI checks enabled.

## Consequences and risks

The public governed catalog temporarily contains only the five current city records. The wider website still has its separate official-directory/navigation content. The reduced catalog must be reported honestly. Restoration requires an explicitly reviewed replacement release; reverting code alone must not make overdue content public again. Historical source files, release locks and Git history remain intact.

## Verification

Validate the overlay graph and original acceptance hashes; compare every field against the accepted base except lifecycle; assert zero newly published records and no changed verification dates. Rebuild the canonical, Admin and public artifacts; run strict Data Project and Data Health checks. Test that withdrawn IDs and mapped legacy aliases are absent from the shared mobile/search database, while independently testing a synthetic published place route. Run all required CI and Hostinger QA before production.
