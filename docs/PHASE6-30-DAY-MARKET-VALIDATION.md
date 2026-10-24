# YouNew Phase 6 — 30-day Amsterdam validation plan

This is an operating target, not a forecast. Promotion starts only after a separately authorised deployment passes production smoke and the Amsterdam pilot no longer relies on unverified indexable records. Budget for new services: €0.

## Measurement contract

| Outcome | Proof | Test-data handling |
|---|---|---|
| Real organic visit | Search Console click to a valid landing page | Search Console's own bot/filter rules; no synthetic query counted |
| On-site visit | Consented first-party session/page view | Mark internal/staging traffic and exclude known smoke markers |
| Card engagement | Consented governed-card view or official-source click | Never send query text, email, company name or free text |
| Started application | `lead_start` after consent | Tagged E2E events excluded |
| Saved application | Persisted `business_inquiries` row plus receipt | Tagged test rows excluded and removed by exact ID only |
| Confirmed company | Human identity and authority check with audit evidence | Availability of a website alone is not confirmation |
| Activated company | Published governed card plus release/audit trail | QA record is not activation |
| Revenue | Settled accounting/payment record | Interest or a pricing-page view is not revenue |

If a source is not connected, show `—`/“unavailable”. Never replace missing production data with demo values.

## Days 1–3: launch truth

- Confirm production SHA, post-deploy smoke receipt and zero unapproved records.
- Verify Search Console domain ownership, submit `https://younew.nl/sitemap.xml`, inspect the EN/NL home and Amsterdam guide URLs, and record Google status without claiming indexing early.
- Verify analytics requests are absent before consent and inspect real production payloads after consent for PII minimisation.
- Submit and reconcile one marked NL and one marked EN application; exclude both from KPI counts.
- Stop promotion immediately if forms, NL routes, consent, canonical or freshness boundaries fail.

## Days 4–10: earn the first useful visits

Prepare one NL and one EN post for each useful Amsterdam guide. Each post answers one concrete newcomer question, links to the guide and its official source, and is manually adapted to the community's rules.

Free channels:

- founder and team LinkedIn profiles;
- Amsterdam newcomer, neighbourhood and expat communities only where helpful links are permitted;
- relevant Reddit or Facebook discussions where the guide directly answers the question;
- voluntary sharing by people who have used the guide;
- the project's own profiles and email signatures.

Do not post the same text repeatedly, do not scrape members and do not promote pages carrying an unverified warning.

## Days 11–20: convert trust into inbound business

- Make “Gratis bedrijfsprofiel” the primary business CTA in NL and “Free business listing” in EN.
- Ask the owner's existing network to share the public inbound link; do not transfer personal contact lists to YouNew.
- Reply manually only to businesses that initiate contact or to channels whose terms and legal basis were separately verified.
- Process each saved application within two working days: receipt → identity/authority check → facts/sources → approve or reject with reason → separate data release → activation.
- Give an activated company its canonical URL and an optional neutral sharing text. Sharing remains voluntary.

## Days 21–30: amplify measured demand only

- Compare Search Console queries and landing pages with consented card views and saved applications.
- Improve titles, descriptions and internal links only on useful pages that show impressions or user demand.
- Redistribute the two best-performing guides with a genuinely new useful excerpt.
- Interview willing applicants about which available listing capabilities matter; log requested unavailable features without promising delivery.
- Do not add product features unless repeated user evidence identifies a concrete problem.

## Validation targets

The target of 100 real visits is a checkpoint, not a guarantee. A planning mix is 25 organic-search clicks, 30 visits from ten compliant community contributions, 15 from the owner's network, 20 from voluntary business referrals and 10 from a second useful distribution cycle.

The target of 10 activated companies uses this capacity model: 100 business-page visits → 25 form starts → 15 saved applications → 12 identity/authority confirmations → 10 activated governed cards. These ratios are hypotheses; report the actual funnel and the drop-off instead of treating them as expected revenue.

## Stop and learn conditions

- any incorrect or unverified fact appears in a promoted route;
- production application persistence fails;
- NL route, canonical, hreflang or sitemap is wrong;
- analytics sends PII or starts before consent;
- a community disallows the post;
- repeated visits do not reach a useful card/source;
- applicants request unavailable capabilities that the current offer implies.

When a condition fires, stop that channel, preserve the evidence and fix the underlying trust or conversion problem before adding features.

