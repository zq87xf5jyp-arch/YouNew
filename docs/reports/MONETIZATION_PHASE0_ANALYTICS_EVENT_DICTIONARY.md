# Monetization Phase 0: analytics event dictionary

Date: 2026-08-18  
Source commit: `60accbcb8f8c169e1ef6e09cd7b56824bea6d08e`

The web client sends analytics only after explicit consent. Events are batched to the Supabase `analytics-ingest` Edge Function with credentials omitted and `no-referrer`. Free-form form data is not part of the event contract. Search text is normalized to the controlled public vocabulary or redacted before transmission.

## Implemented event contract

| Event | Producer | Allowed properties | Status / gap |
|---|---|---|---|
| `page_view` | consent-aware route observer | none; sanitized path is stored as `screen` | Implemented. |
| `search` | search submission and filter changes | normalized safe query, intent IDs, type/city/province/category/profile filters, result count, `zero_result`, fallback tier | Implemented; this also represents empty-result measurement. |
| `search_result_opened` | search result link | content ID, position, normalized safe query | Implemented. |
| `official_source_click` | tracked source link | content ID | Implemented. |
| `partner_click` | no producer found | content ID | Declared but not emitted. |
| `item_saved` | planner and generic Save buttons | content ID | Implemented for successful save actions; removals intentionally do not emit this event. |
| `app_cta_click` | App Store CTA | bounded location label | Implemented. |
| `profile_selected` | homepage and search profile selectors | none | Implemented; selected profile is intentionally not sent. |
| `business_mailto_prepared` | validated business-form fallback | organization type | Implemented only after API storage fails and a valid user-controlled mail draft is prepared. It does not claim that an email was sent. |
| `lead_start` | first meaningful business-form input | none | Implemented locally once per mounted form; honeypot input is excluded. Delivery remains behind an unapplied forward migration. |
| `lead_submit` | API-first business form | none | Implemented locally only after the repository returns a valid safe receipt. It counts receipt-return events, not unique leads or payments; delivery remains behind an unapplied forward migration. |
| `analytics_consent_granted` | consent control | none | Implemented. |

Every envelope also contains random event/app-instance/session IDs, sanitized screen, platform, app version, language, timestamp, consent version, schema version and production/staging environment. Browser-tab identifiers are session-scoped; the contract excludes raw search text, form contents, saved-item text, exact location, advertising IDs, IP addresses and user-agent values.

## Required monetization measurement map

| Required signal | Current evidence | Decision |
|---|---|---|
| Page view | `page_view` | Ready. |
| Search | `search` | Ready. |
| Empty result | `search.zero_result=true` | Ready as a property; document this as the canonical representation. |
| Guide start | No event | Missing. Add `guide_started` with guide ID and entry surface only. |
| Guide completion | No event | Missing. Add `guide_completed` with guide ID and completion method only. |
| Official source click | `official_source_click` | Ready. |
| Save | `item_saved` | Ready for planner and generic content saves. An explicit remove event remains intentionally undefined. |
| Report outdated | Feedback form exists; no analytics event | Missing. Add an intent event without message, email or free text. |
| Partner CTA | `partner_click` type exists; no producer | Missing wiring. |
| Lead start | Property-free `lead_start` producer and pending ingest migration | Ready locally; first meaningful interaction only, consent-aware provider, no form fields. Not in production. |
| Lead submit | Property-free `lead_submit` after safe receipt plus pending Admin aggregate | Ready locally; receipt-return event, not a unique-lead or payment count. Not in production. |
| Pilot request | No distinct approved offer or event; ingest rejects `pilot_request` | Intentionally blocked. Define only after the 90-day pilot offer and CTA are approved. |

## Data and funnel caveats

- Production currently contains consented product events, but Data Observability reports usage coverage as 0.0; event existence is not yet a reliable KPI dashboard.
- The business inquiry path stores a validated receipt in Supabase and exposes it in Admin. A local consent-safe lead funnel is prepared behind an unapplied migration, but there is no automated notification step in repository evidence.
- The public media-kit copy still describes a mailto-only handoff while the configured form first calls `submit-business-inquiry`; copy and behavior must be reconciled.
- Do not use page views, social reach or the existence of events as evidence that the B2B pilot hypothesis is validated.
