# Google Search Console submission runbook

No live submission was made. Execute only after an approved production deployment.

## Before submission

1. Confirm `https://younew.nl/robots.txt` returns 200 and names `https://younew.nl/sitemap.xml`.
2. Confirm the sitemap returns 200, contains only canonical 200 pages and excludes noindex form/success routes.
3. Sample at least one EN/NL pair from home, category, organization and each city guide. Each page must self-canonicalize and expose reciprocal `en`, `nl` and `x-default` alternates.
4. Confirm redirects resolve in one hop to the canonical trailing-slash URL.
5. Confirm the five city guides still show their reviewed official source and date.
6. Run mobile Lighthouse or PageSpeed checks for `/nl/`, `/nl/zoeken/`, one organization, one city guide and `/nl/voor-bedrijven/aanmelden/`.

## Submission

1. Use the existing verified Search Console property for `https://younew.nl/`. Do not create a duplicate property.
2. Submit `https://younew.nl/sitemap.xml` once.
3. Use URL Inspection for the home page, `/nl/`, the five EN guides and the five NL guides. Request indexing only after the live canonical and rendered HTML are confirmed.
4. Record submission time, operator and screenshots/receipts in the launch log.

## First 30 days

- Review Page indexing and Sitemaps daily for days 1–7, then twice weekly.
- Classify exclusions; do not treat “Discovered — currently not indexed” as a technical error without page-level evidence.
- Compare Search Console clicks/impressions with consented first-party page views; the systems measure different populations.
- Do not upload automatically generated or unverified content to increase page count.

References:

- https://support.google.com/webmasters/answer/12817956?hl=en
- https://support.google.com/webmasters/answer/7440203?hl=en
- https://support.google.com/webmasters/answer/7474347?hl=en

