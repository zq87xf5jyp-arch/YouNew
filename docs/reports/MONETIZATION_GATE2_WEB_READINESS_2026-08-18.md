# YouNew monetization readiness — Gate 2 web candidate

Date: 2026-08-18 (Europe/Amsterdam)  
Mode: local source and production-package candidate only. No deployment, publication, production write, external message or payment action occurred.

## Outcome

The local web candidate is **PARTIAL** against Gate 2. The measured homepage is materially stronger: local mobile Lighthouse is **90/100/100/100** and desktop is **100/100/100/100**; the 390 px browser check has no horizontal overflow, one `h1`, a visible task-first action, and no console warnings or errors. The analytics choice is now an explicit opt-in notice that does not take modal focus or trap keyboard navigation.

This is not a Gate 2 GO. The ≥90% search target exists only in the private, non-publishable 20-guide projection; the public-content candidate remains 32/50. Dutch and Russian public-web coverage, visible fallback behavior across all routes, and full production-like tablet/keyboard/screen-reader QA are still incomplete. Production is unchanged.

## Lighthouse before → local candidate

One-run local lab results against the exact generated static package; these are regression evidence, not a guarantee of field performance.

| Profile | Before | Local candidate | Key metrics |
|---|---:|---:|---|
| Mobile | 74 / 97 / 77 / 100 | **90 / 100 / 100 / 100** | FCP 1.879 s; LCP 3.352 s; TBT 100 ms; CLS 0; Speed Index 2.951 s |
| Desktop | 98 / 97 / 77 / 100 | **100 / 100 / 100 / 100** | FCP 0.311 s; LCP 0.691 s; TBT 0; CLS 0; Speed Index 0.576 s |

Category order is performance / accessibility / best practices / SEO. The previous mobile LCP was 5.198 s and Speed Index was 6.8 s. Mobile TBT moved from 0 to 100 ms but remains within Lighthouse's good range in this run.

## Confirmed changes

- Replaced the homepage's remote Wikimedia LCP request with the repository's governed local WebP alias. Attribution remains visible and links to the original CC BY-SA 4.0 source by Basile Morin.
- Corrected the primary orange and muted-text tokens. Calculated contrast ratios are 4.89:1 for white on the primary orange, 6.53:1 for white on the hover orange, and at least 5.23:1 for muted text on the tested light backgrounds.
- Kept the full consent disclosure and explicit Allow/Decline controls, but changed it from a modal focus trap to a non-modal labelled region. The primary page action remains keyboard-reachable before a privacy choice. Tracking still starts only after explicit consent.
- Wired successful generic saves to the existing allowlisted `item_saved` event. Removal intentionally emits no save event.
- Wired only the validated API-failure mail fallback to the existing `business_mailto_prepared` event. It records bounded organization type, no free text, and never claims the email was sent.
- Replaced URL pathname filesystem conversion in ten build/test scripts with `fileURLToPath`, allowing the production checks to run correctly from the iCloud path containing spaces and non-ASCII characters.

## Verification evidence

- Public web tests: **147/147 PASS**.
- Search regression matrix: **2,608/2,608 PASS**.
- Private search scorecard: **48/50 actionable**, 2 genuine content gaps, 0 invisible location substitutions.
- Final source candidate, resynchronised into an isolated `/private/tmp` copy after the business-copy regression test was added: build 605/605, TypeScript, ESLint, 147/147 tests, smoke, 47,060-reference link/asset audit and security scan passed (stages 1–7). Stage 8 could not open its ephemeral localhost port because the current sandbox rejected `listen(127.0.0.1)` with `EPERM`; stages 9–10 were therefore not reached. The same final source passed the upstream static/data gates separately in the canonical worktree. An immediately preceding candidate passed all 10 stages, but it is not substituted for this final-source run.
- Browser at 390 × 844: `innerWidth=390`, `scrollWidth=390`, one `h1`, local hero image loaded, no warning/error log entries.
- No new analytics event type, database schema or Supabase migration was added for this web slice. Existing server allowlists remain authoritative.

## Measurement status

Ready consent-safe signals are page view, search, empty result, official-source click, save, App Store CTA, profile selection and validated mail-fallback preparation. Guide start/completion, report-outdated intent, partner CTA producer, lead start/success and pilot request remain absent. They require one reviewed cross-consumer event contract and, for new event types, an approved forward migration; they were not improvised in the browser client.

## Remaining gaps

1. All 20 practical-guide packets remain private and fail-closed pending named human reviewers, verified media and publication gates.
2. Public search is 32/50; the 48/50 threshold result is an in-memory QA projection only. Dutch citizenship and pregnancy/midwife remain genuine zero-result gaps.
3. Dutch and Russian public-web layers, visible language fallback and reviewed critical-content translations are incomplete.
4. Tablet, full keyboard journey and screen-reader testing have not yet been completed against the final production-like package.
5. Production field data, Core Web Vitals and production event coverage are not established.
6. One private Supabase table still awaits the locally prepared RLS migration's disposable-database tests and separately approved production application.

## Decision

**PARTIAL — local web readiness improved and the measured UX defects are corrected. NO-GO for Gate 2 completion, deployment, publication or commercial launch.**

## Next smallest useful action

Repeat the runtime-404/package-identity tail of the production gate in an environment allowed to bind an ephemeral localhost port, then repeat mobile browser/Lighthouse verification from that final package. Phase 3 B2B pilot and lead-pipeline work remains local and approval-gated.
