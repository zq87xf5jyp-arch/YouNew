# YouNew product gap audit — 2026-08-06

## Scope

Core newcomer flow on the published Sites deployment:

1. Choose a need on the homepage.
2. Review ranked search results.
3. Open a verified national guide.
4. Confirm the responsible official sources.

Evidence:

- `/Users/ivan/.codex/visualizations/2026/08/05/019fd1c2-51b1-7923-b9c3-7cc4304ddd07/younew-audit-2026-08-06/01-home.png`
- `/Users/ivan/.codex/visualizations/2026/08/05/019fd1c2-51b1-7923-b9c3-7cc4304ddd07/younew-audit-2026-08-06/02-search-results.png`
- `/Users/ivan/.codex/visualizations/2026/08/05/019fd1c2-51b1-7923-b9c3-7cc4304ddd07/younew-audit-2026-08-06/03-guide.png`
- `/Users/ivan/.codex/visualizations/2026/08/05/019fd1c2-51b1-7923-b9c3-7cc4304ddd07/younew-audit-2026-08-06/04-official-sources.png`

## Confirmed strengths

- The homepage exposes search, Naruto, emergency help, practical needs, cities and business without mixing advertisements into organic guidance.
- A broad need such as `daily life bank account` returns a relevant national guide first instead of an empty result.
- National guides publish scope, verification date, limitations, steps, problems, common mistakes and official sources.
- The inspected flow had no browser console warnings or errors.
- The published search index contains 585 documents: 342 municipalities, 131 places, 32 categories, 30 guides, 30 organizations, 12 provinces, 5 cities and 3 pages.

## Confirmed product gaps

1. The guide library is useful, but the journey layer is behind it. Four of eight journey definitions have no published steps. Existing newcomer, student, housing and refugee journeys are still dominated by Amsterdam-specific records instead of the new national guides.
2. Search accepts English, Dutch and Russian terms, but the public guide content and interface are English-only.
3. Saved materials, recent pages, planner state and journey progress stay only in one browser and are not synced to an optional account.
4. Guide steps are static text. Users cannot check off a step, attach a safe reminder, or continue directly to the next relevant step.
5. The homepage profile selector exists in the codebase but is not used on the current homepage, so the first screen does not adapt to user situation or municipality.
6. Naruto is a deterministic published-index matcher. It is safe and source-bounded, but it does not yet support a cited conversational follow-up flow.
7. The taxonomy contains important domains without a complete national guide pack, especially utilities and business. Consumer/legal help, mental health and move-in/move-out tasks also need more actionable coverage.
8. Feedback exists on the support page, but guide pages do not yet offer a short contextual `helpful / incorrect / missing` control tied to the content record.

## Priority roadmap

| Priority | Addition | User value | Complexity | Main risk |
|---|---|---:|---:|---|
| P0 | Rebuild journeys from national guides with local city overlays | Very high | Medium | Incorrect ordering for special cases |
| P0 | Interactive checklists and “next step” on every national guide | Very high | Medium | False sense of completion |
| P0 | EN/NL/RU interface and verified guide translations | Very high | High | Legal/medical translation errors |
| P0 | Optional account and Supabase sync for saved items and progress | High | High | Privacy, authentication and data migration |
| P1 | Utilities and moving-home guide pack | High | Medium | Provider and municipal differences |
| P1 | Consumer rights, scams, debt and legal-help guide pack | High | Medium | Avoiding personalised legal advice |
| P1 | Mental health, dentistry, medicines and pregnancy routes | High | High | Medical safety and emergency escalation |
| P1 | Starting a business / freelancer journey | High | Medium | Residence-status and tax differences |
| P1 | Homepage personalisation by situation and municipality | Medium-high | Low-medium | Hiding general guidance |
| P2 | Cited conversational Naruto with bounded follow-ups | High | High | Hallucination, privacy and emergency handling |
| P2 | Page-level feedback and source-expiry alerts | Medium-high | Medium | Moderation and alert fatigue |
| P2 | Verified organization profiles and user-safe contact actions | Medium | High | Fraud, stale data and commercial influence |

## Recommended first delivery

One focused release should:

1. Wire the new national guides into all eight journeys.
2. Add local checklist progress to national guide steps.
3. Put the existing situation selector on the homepage.
4. Add national guide packs for utilities, consumer/legal help, mental health and starting a business.
5. Add contextual guide feedback and feed it into the existing moderation workflow.

Account sync, full translations and generative Naruto should follow only after privacy, migration, content-review and safety gates are defined.

## Evidence limits

- This is a combined product and UX gap audit of the core discovery flow, not a full WCAG conformance audit.
- Keyboard order, screen-reader output, zoom reflow and all account/device migration states were not fully tested.
- Recommendations concerning Dutch procedures must continue to use current responsible sources and visible review dates.
