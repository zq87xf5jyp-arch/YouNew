# Public web privacy and analytics implementation

Date verified against code: 3 August 2026.

## Consent lifecycle

1. No analytics provider is created while the choice is absent or declined.
2. Global Privacy Control or Do Not Track becomes a decline when no choice was saved previously.
3. The accept/decline choice is stored in `localStorage` under a versioned consent key.
4. After acceptance, random app-instance and session identifiers are created in `sessionStorage` only.
5. Declining or withdrawing consent disposes the provider and removes the tab-scoped identifiers.
6. The privacy dialog receives initial focus, traps focus because it is modal, closes on Escape and restores trigger focus.

## Event allowlist

Allowed event names:

- `page_view` — path only, without query or fragment;
- `search` — result count and `has_results`; never the query;
- `official_source_click`, `partner_click`, `item_saved` — bounded content ID;
- `app_cta_click` — bounded placement name;
- `profile_selected` — empty properties; never the selected profile;
- `business_mailto_prepared` — bounded organization type;
- `analytics_consent_granted` — empty properties.

All strings are bounded and sanitized. Requests use `credentials: omit`, `referrerPolicy: no-referrer`, a fixed HTTPS Supabase Functions path and batches of at most 20 events.

## Data explicitly excluded

- search text;
- selected profile details;
- precise location;
- form bodies and feedback text;
- saved-item titles or lists;
- email, account or identity data;
- advertising IDs and cross-site identifiers;
- full URLs containing query parameters.

## Storage and retention

The configured production project is `pgdzdxsiagfjioxwuqxf` in Supabase `eu-west-1`, as recorded in `SUPABASE_PRODUCTION.md`. The public policy and consent banner state a 90-day analytics retention window. Retention enforcement remains an operational backend control and must be rechecked during the production release audit.

Browser-local product data uses versioned keys for saved shortcuts, recently viewed pages, optional search history, profile choice, journey/checklist progress and an optional planner route. These values do not imply cloud or app synchronization. `Saved` can clear only saved shortcuts; the broader local-data control clears all YouNew browser keys after confirmation.

## Verification

Automated tests cover event envelopes, batching, no-referrer requests, invalid configuration fail-closed behavior, action-only profile analytics, local-storage sanitization and selective saved-data clearing. Browser QA must additionally verify that no request to `analytics-ingest` occurs before consent and that changing the choice works without a reload.

## Operational caution

The publishable Supabase key is intentionally public and is not an administrator secret. The public bundle must never contain a service-role key. Backend RLS/function authorization, EU region and retention controls must be checked independently; the client cannot prove them by itself.
