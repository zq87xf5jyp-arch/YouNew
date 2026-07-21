# YouNew Public Web — pre-deploy checklist

This checklist prepares the static package for Hostinger. It does **not** publish files, change DNS, or modify domain email.

## Latest local evidence — 21 July 2026

- Automated gate: **BLOCKED at step 10/10** — build, TypeScript, ESLint, 45 tests, smoke, 14,953 internal link/asset/fragment checks, security, true HTTP 404, package invariants and upstream guide governance pass; current external source health fails on 18 released-runtime URLs.
- Package: 232 static-generation entries, 229 HTML files, 224 sitemap URLs; `out/` and `dist/client/` are byte-identical.
- Browser: guide save reached `/saved/`; journey state persisted and reset atomically; map filter/URL/marker/list stayed synchronized; media-kit labels and application fallback were present; representative console log was empty.
- Responsive: home, guide summary, journeys, map, media kit and 404 passed at 320×568, 390×844, 430×932, 768×1024, 1280×800 and 1440×900: 36/36 combinations, one H1 and no horizontal overflow.
- Lighthouse: home mobile 93/100/100/100 and desktop 97/100/100/100; mobile guide, journeys, map and media kit are all 99/100/100/100 for Performance/Accessibility/Best Practices/SEO.
- Offline guide runtime: **PASS in Chromium for worker `3e435bc55d98`** — after two online openings in a clean profile, the origin server was stopped and `/guides/woon/` rendered from cache; warm/offline screenshots are byte-identical. Manifest/SW/offline-fallback static checks also pass. Real iPhone Safari remains unchecked. Print output: tagged A4 guide 2 pages, media kit 7 pages.
- Production deployment: **not performed**. Live Hostinger and real iPhone Safari checks remain unchecked below.
- External source/media health: **BLOCKED** — the fresh 2,494-URL check found 18 confirmed 404 responses in the immutable released runtime after two mutable Transport QA links and one current Swift media URL were fixed. Do not deploy until an approved patch release/verification override clears `python3 scripts/data-health-gate.py --require-network`.

## 1. Content governance

- [ ] `DataProject/staging/practical-guides-wave-1.json` still contains only `draft` scaffolds.
- [ ] Every practical guide intended for publication has a published parent release, a verified parent record, at least one opened official source, fact-level `source_ids`, a registered human reviewer, matching local QA evidence, and `verified_at`/`updated_at` dates.
- [ ] Every full guide has an explicit supported `attributes.publicWebCategory`, at least one sourced emergency-information block, and a verified local `/images/...` asset with authored alt text.
- [ ] Municipal instructions name their city applicability and explain local variation.
- [ ] Legal, medical and administrative copy has received the appropriate human review.
- [ ] No advertiser or partner record is used as editorial or emergency evidence.

## 2. Local automated gate

From `admin-dashboard/public-site` with Node 24 and the locked dependencies available:

```bash
NODE_BINARY=/absolute/path/to/node bash scripts/pre-deploy.sh
```

The command must finish with:

```text
PRE-DEPLOY PASS — package is locally verified; no public deployment was performed.
```

It verifies the production build, TypeScript, ESLint, all tests, HTML smoke flows, links/fragments/assets, security headers, canonical/sitemap parity, PWA files, a real HTTP 404, absence of drafts/secrets/local paths, a byte-identical `out/`/`dist/client/` package, and the currently generated governed/released source-health report. It does not refresh URLs or enforce the 36-hour network-evidence window. Before release, regenerate link evidence and run `python3 scripts/data-health-gate.py --require-network` from the repository root. At present both commands fail closed with `governed_broken_links=18`.

The repository-wide `scripts/run-static-qa.sh` also fails at the same Data Health gate after its preceding checks pass; because the script uses `set -e`, checks after that gate are not represented as executed in the latest aggregate run.

## 3. Manual browser checks

- [ ] `/guides/woon/`: source-summary label, save, share, print, source link and outdated-information report.
- [ ] `/journeys/`: three local states persist after reload; clearing local web data removes progress; no account/iOS-sync claim.
- [ ] `/search/`: all ten control queries match the recorded search QA outcome.
- [ ] `/map/`: keyboard-select a marker, filter by city/type/category, share the query URL, and use the complete list without the SVG.
- [ ] `/business/media-kit/`: DEMO labels remain visible; print/PDF contains no fixed price or measured-data claim.
- [ ] `/business/apply/`: validation works and the page says that nothing is submitted automatically.
- [ ] Offline: open a guide online, activate the service worker, go offline, and reload the same guide; emergency remains network-first and never receives permanent cache treatment.
- [ ] Unknown URL returns HTTP 404 and the YouNew 404 page.
- [ ] Console has no errors and Network has no unexpected 404/500 responses.

Required viewports:

- [ ] 320×568
- [ ] 390×844
- [ ] 430×932
- [ ] 768×1024
- [ ] 1280×800
- [ ] 1440×900

## 4. Lighthouse evidence

- [ ] Run Lighthouse against the local production preview, not `next dev`.
- [ ] Capture mobile reports for `/`, `/guides/woon/`, `/journeys/`, `/map/`, and `/business/media-kit/`.
- [ ] Capture at least one desktop report.
- [ ] Targets: Performance ≥90, Accessibility ≥95, Best Practices ≥95, SEO ≥95.
- [ ] Store the reports/screenshots outside `out/` so the upload package remains deterministic.

## 5. Owner/legal confirmations

- [ ] Confirm the current iOS/App Store URL before adding or exposing it.
- [ ] Confirm the legal controller identity and approved retention period for business-support email.
- [ ] Confirm any pricing before replacing “Request a quote”.
- [ ] Confirm whether Nederlands content is reviewed enough to publish; do not expose an incomplete locale.

## 6. Hostinger publication — only after all blockers are cleared and explicit approval is given

1. Keep the currently deployed `public_html` package as a dated, recoverable backup.
2. Upload the **contents** of `admin-dashboard/public-site/out/` to `public_html/` (not the `out` directory itself).
3. Preserve the generated `.htaccess`; verify that hidden files are included by the upload method.
4. Do not edit DNS, MX records, mailboxes, SSL settings, or domain forwarding.
5. Verify HTTPS and these production URLs: `/`, `/search/`, `/guides/woon/`, `/journeys/`, `/map/`, `/status/`, `/business/media-kit/`, `/privacy/`, `/terms/`, `/support/`, `/sitemap.xml`, `/robots.txt`, `/manifest.webmanifest`, `/sw.js`, and a missing URL.
6. Check response headers for CSP, `X-Content-Type-Options`, `Referrer-Policy`, `X-Frame-Options`, and `Permissions-Policy`.
7. If any critical check fails, restore the dated backup and investigate locally; do not patch production files by hand.

## Current known release blockers

- The first 20 national practical guides are governed draft scaffolds: 0 are approved full guides today.
- Official research dossiers cover 18/20 first-wave topics; Dutch integration exams and Reporting discrimination still lack a dedicated dossier. Finding work, Opening a Dutch bank account and Student housing still lack a governed canonical procedural source record suitable for publication.
- `DataProject/operations/reviewer-registry.json` and `guide-evidence-registry.json` are intentionally empty; no full guide can pass publication until a real human reviewer and matching evidence artifact are registered.
- The current network health gate fails on 18 immutable-runtime URLs (dead media/licence links and the BREDA source). Create a patch release; never edit the published Amsterdam batch in place.
- The public production content remains concentrated in Amsterdam; the coordinate map must not be described as complete national coverage.
- Business inquiry delivery is an honest user-controlled email draft, not a backend submission workflow.
- Partner accounts/dashboard, billing and measured campaign analytics remain feature-flagged or unimplemented pending a secure backend.
