# YouNew public web release checklist

Use this checklist for the static public website. It does not authorize or publish an iOS build.

## 1. Source and scope

- [ ] Branch is based on current `origin/main`.
- [ ] Worktree contains no unrelated iOS, Admin or canonical DataProject changes.
- [ ] Generated content reports production releases only.
- [ ] Draft, review and archived content are absent from the search index and routes.
- [ ] Coverage claims match the generated city routes and guide depth.

## 2. Required commands

From `admin-dashboard/public-site`:

```sh
pnpm typecheck
pnpm lint
pnpm test
pnpm build
pnpm test:smoke
pnpm check:links
pnpm check:security
CI=true pnpm predeploy:check
```

Every command must exit 0. Do not waive a failed content-integrity, security, static-reference or route check.

## 3. User flows

- [ ] Homepage primary CTA opens `/start/`.
- [ ] Homepage secondary CTA opens `/search/`.
- [ ] Header active state, visible focus and Emergency route work.
- [ ] Mobile menu opens, closes with Escape, restores focus and does not trap page scrolling.
- [ ] Theme is readable in dark and light modes at 320, 390, 768 and 1440 px.
- [ ] Start supports task, situation, national/city, result, Back, Reset and direct link.
- [ ] Start does not request an account, email or precise location.
- [ ] Search covers exact match, typo, empty state, keyboard navigation and deep link.
- [ ] Search result types are visible and unpublished content is absent.
- [ ] Save, Unsave, reload persistence, empty state and Clear all confirmation work.
- [ ] Map loads without a location permission prompt and has a list alternative.
- [ ] App page describes the currently released app only.
- [ ] Privacy Decline/Allow/change-choice work using keyboard and screen reader semantics.
- [ ] 404 and invalid content slugs return an honest missing route.

## 4. Accessibility and content

- [ ] One H1 per page and ordered headings.
- [ ] Landmarks and accessible names are unique and descriptive.
- [ ] Keyboard focus remains visible.
- [ ] Images have useful alt text, intrinsic dimensions and responsive sizing.
- [ ] Light-mode text and controls meet contrast expectations.
- [ ] Reduced motion and forced-colors behavior remains usable.
- [ ] No technical release evidence, internal status or B2B acquisition copy appears on the homepage.
- [ ] Footer exposes English as the only available website language.

## 5. Privacy and security

- [ ] No analytics provider or request exists before explicit consent.
- [ ] Search text, profile details, precise location and form contents are absent from analytics events.
- [ ] Analytics referrer policy is `no-referrer` and credentials are omitted.
- [ ] Session identifiers remain in `sessionStorage`; consent remains in `localStorage`.
- [ ] No service-role, admin or private Supabase credential exists in the public bundle.
- [ ] External `_blank` links include `rel="noreferrer"` or `noopener`.
- [ ] Production headers include CSP, HSTS, Referrer-Policy, Permissions-Policy and `X-Content-Type-Options: nosniff` as defined by the hosting worker.
- [ ] `/.well-known/apple-app-site-association` returns HTTP 200 and `Content-Type: application/json`.

## 6. Deployment and rollback

- [ ] Draft PR contains screenshots, command results and known limitations.
- [ ] Required CI checks are green on the exact merge commit.
- [ ] Merge approval is recorded.
- [ ] Production deployment uses the repository’s Sites packaging workflow.
- [ ] Run post-deploy HTTP, media, navigation, privacy and AASA checks.
- [ ] If a release gate fails, restore the previous known-good Sites deployment according to `ROLLBACK_RUNBOOK.md`.

Release decision is `GO` only when every blocking item above is verified on the exact production candidate.

## Candidate evidence — 3 August 2026

- `CI=true pnpm predeploy:check`: PASS (10/10 stages).
- Tests: 116 passed, 0 failed, 0 skipped.
- Export: 581 pages; 571 sitemap routes; 578 HTML files.
- Link/static asset references: 38,441 checked; 0 broken.
- Lighthouse mobile: Performance 94; Accessibility 100; Best Practices 100; SEO 100; CLS 0; TBT 0 ms; LCP 3.08 s.
- Live canonical/AASA check before candidate deployment: homepage and critical routes HTTP 200, missing route HTTP 404, AASA HTTP 200 with valid JSON and `application/json`.
- Candidate production deployment: not performed; post-deploy checks remain mandatory on the merge commit.
