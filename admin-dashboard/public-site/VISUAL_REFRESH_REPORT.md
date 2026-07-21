# YouNew Public Web — visual refresh report

Date: 21 July 2026  
Scope: `admin-dashboard/public-site`  
Public deployment: **not performed**

## 1. Status

**PARTIAL overall.** The visual implementation, local static export, browser flows,
responsive checks and Lighthouse targets are ready. Public deployment remains
blocked by upstream content/media governance rather than the visual layer:

- the production release still contains 0 approved full practical guides;
- the required live source-health gate finds 18 confirmed broken URLs in the
  immutable released runtime;
- the two iOS captures used by the site still require owner media-rights clearance
  described in `BuildWeekFix/MEDIA_RIGHTS.md`;
- real iPhone Safari PWA/install testing and live Hostinger header checks require a
  release device or an explicitly approved deployment.

The fail-closed content and deployment gates were not bypassed.

## 2. Visual direction

The site now uses a coherent premium-dark product language derived from the current
iOS recording: midnight navy and graphite surfaces, cyan trust/system accents,
orange primary actions, restrained violet depth, stronger typography and varied
editorial compositions. Decorative depth is limited to the hero and narrative
transitions; core content remains calm and scan-friendly.

The home hero is now an asymmetric product composition with a real current YouNew
screen capture, visible source/web-fallback callouts, current released-content
figures, direct web/search actions and honest iOS availability language.

## 3. Implementation

### Design system and shared UI

- Normalized colors, surfaces, text levels, borders, shadows, radii, spacing,
  container widths, typography, motion durations/easing, focus rings and states.
- Unified primary, secondary, ghost and icon actions; content/guide/profile/journey/
  source/status/statistic cards; badges, chips, warnings and success states.
- Replaced one-size-fits-all card grids with editorial splits, feature panels,
  staggered content, compact data strips, journey timelines and a dedicated map
  composition.
- Rebuilt the brand mark and navigation around the current YouNew icon and palette.

### Navigation and accessibility

- Compact sticky header with active-route state and stable dimensions.
- Mobile menu uses correct expanded semantics, focus containment, Escape close and
  focus restoration. Primary targets remain usable at 320 px.
- Skip link remains the first focusable item. Interactive controls that need
  hydration are disabled fail-safe before JavaScript is ready.
- Strong visible focus, forced-colors support, improved orange CTA contrast and
  reduced-motion behavior were added without hiding critical feedback.

### Product routes

- Home: new hero, current app captures, clearer value narrative, profiles, AI/search,
  map/city preview, trust cues, partner CTA and varied section transitions.
- Guide summary: stronger working-tool hierarchy, progress strip, verified metadata,
  actions, next steps, source card and print treatment. No fake full-guide state was
  created because none has passed the publication gate.
- Journeys: path-like cards, explicit released/closed states, animated local progress
  and an atomic accessible reset that preserves every other journey.
- Map: clearer filters, selected/focus marker states, synchronized detail/list panel,
  mobile composition and dependency-free accessible fallback.
- Business media kit: commercial hero, format catalogue, transparent sponsored rules,
  editorial independence, clearly labelled demo card/report, Request a quote and
  print-ready layout.
- Saved, support, privacy, terms, status and 404 now share the same hierarchy,
  surfaces and responsive rhythm.

### Motion and transitions

- 120–180 ms interface feedback and 180–280 ms component transitions using transform
  and opacity.
- Small IntersectionObserver-based reveal groups that default to visible content.
- Native View Transitions API as progressive enhancement only; normal navigation,
  browser back and Safari fallback stay intact.
- Card/action press states, nav underline, FAQ/details, saved/share/copy feedback,
  journey progress, filter changes, map/list selection and mobile-menu transitions.
- `prefers-reduced-motion: reduce` disables page/reveal/spatial movement, preserves
  essential state feedback and shortens remaining durations.

Not adopted: Framer Motion, GSAP, parallax, a loading-screen transition, a heavy map
SDK and constant neon/glass effects. They were unnecessary for the requested value
and would add runtime, accessibility or static-hosting risk.

## 4. Images and print

- Added two current English YouNew captures derived from the governed app references:
  `public/images/app-home-en.webp` (206,008 bytes) and
  `public/images/app-map-en.webp` (115,470 bytes).
- Hero image loading is prioritized; non-critical images remain responsive/lazy and
  have authored roles/alt text.
- The guide print proof is a tagged 2-page A4 PDF. The media kit is a tagged 7-page
  A4 PDF. Dark-screen surfaces, review cards and page breaks were corrected for print.

Media-rights approval remains an owner/legal pre-deploy requirement; visual use in
the local package is not presented as that approval.

## 5. Browser and interaction QA

Runtime checks against the local production preview confirmed:

- journey progress persists after reload; reset produces 4/4 `not-started` states,
  a zero progress value and a disabled reset without touching other journeys;
- map city filter updates `/map/?city=rotterdam`, reduces both map and list to one
  Rotterdam result, and marker activation opens the matching detail panel;
- saving `!WOON` produces its removable card on `/saved/`;
- the mobile menu, status banner, guide actions and source links remain semantic;
- console log across journeys, map and saved flows is empty.

Responsive DOM QA covered home, guide summary, journeys, map, media kit and 404 at:

- 320×568
- 390×844
- 430×932
- 768×1024
- 1280×800
- 1440×900

Result: **36/36 combinations passed**, with no horizontal overflow and exactly one H1.
Desktop/mobile visual captures additionally cover guides index, saved, support,
privacy and terms.

## 6. Lighthouse

Lighthouse 13.4.0, local production preview:

| Route/profile | Performance | Accessibility | Best Practices | SEO | LCP | CLS | TBT |
|---|---:|---:|---:|---:|---:|---:|---:|
| Home mobile | 93 | 100 | 100 | 100 | 1.6 s | 0 | 300 ms |
| Guide mobile | 99 | 100 | 100 | 100 | 2.0 s | 0.003 | 40 ms |
| Journeys mobile | 99 | 100 | 100 | 100 | 2.0 s | 0 | 50 ms |
| Map mobile | 99 | 100 | 100 | 100 | 2.2 s | 0 | 10 ms |
| Media kit mobile | 99 | 100 | 100 | 100 | 2.1 s | 0 | 20 ms |
| Home desktop | 97 | 100 | 100 | 100 | 0.5 s | 0 | 130 ms |

INP is not reported from this short lab run and is not claimed. All requested score
thresholds and the CLS ≤0.1 target pass in the available evidence.

## 7. Build and automated checks

- Clean locked install: PASS, 351 packages.
- Production build: PASS, Next.js 15.5.19, 232/232 static entries.
- TypeScript: PASS.
- ESLint (`src` and `scripts`): PASS, zero warnings.
- Unit/schema tests: 45/45 PASS.
- Smoke: PASS, 224 indexable URLs.
- Internal links/assets/fragments: PASS, 14,953 references across 229 HTML files.
- Security package scan: PASS, required Hostinger headers and no known secret patterns.
- Production dependency audit: PASS, no known vulnerabilities.
- Package invariant check: PASS, 224 sitemap routes, real HTTP 404, no drafts,
  localhost paths or secrets; `out/` and `dist/client/` are byte-identical.
- Full pre-deploy wrapper: steps 1–9 PASS, step 10 FAIL-CLOSED as designed because
  `governed_broken_links=18`.
- External evidence at `2026-07-20T23:29:35Z`: 2,494 URLs checked; 1,821 reachable,
  18 confirmed broken, 623 access-restricted and 32 transient.

PWA manifest, service worker, offline fallback, generated CSS shell cache and stable
assets pass the static/smoke package checks. The final `3e435bc55d98` worker also
passes a fresh Chromium runtime check: after two online openings with one clean
profile, the local server was stopped and `/guides/woon/` rendered from cache. The
warm/offline screenshots are byte-identical and show the complete `!WOON` summary,
not a network error. Physical iPhone Safari install/offline behavior remains a
release-device check.

## 8. Package impact

- Static upload package: 28,172 KiB; `out/` and `dist/client/` match.
- 525 generated files.
- Shared first-load JavaScript: 102 kB.
- Route first load: home 112 kB, guide 117 kB, journeys 116 kB, map 116 kB,
  media kit 112 kB, search 120 kB.
- Main stylesheet: 135,390 bytes raw / 24,844 bytes gzip.
- New current-app WebP captures: 321,478 bytes combined.
- No animation or map dependency was added.

## 9. Principal changed files

- `src/app/globals.css`
- `src/app/layout.tsx`
- `src/app/page.tsx`
- `src/app/business/media-kit/page.tsx`
- `src/components/brand.tsx`
- `src/components/site-header.tsx`
- `src/components/site-header-enhancements.tsx`
- `src/components/page-shell.tsx`
- `src/components/status-banner.tsx`
- `src/components/motion-enhancer.tsx`
- `src/components/guide-detail.tsx`
- `src/components/guide-checklist.tsx`
- `src/components/reading-progress.tsx`
- `src/components/journey-explorer.tsx`
- `src/components/coverage-map.tsx`
- `src/components/profile-selector.tsx`
- `src/components/saved-items.tsx`
- `src/components/local-data-controls.tsx`
- `src/components/save-button.tsx`
- `src/components/share-button.tsx`
- `src/components/copy-text-button.tsx`
- `src/components/print-button.tsx`
- `src/components/media-kit-print-button.tsx`
- `src/lib/storage/local-content.ts`
- `tests/journeys.test.ts`
- `public/static-shell.js`
- `public/sw.js`
- `public/manifest.webmanifest`
- `public/images/app-home-en.webp`
- `public/images/app-map-en.webp`
- `scripts/build.sh`
- `scripts/version-service-worker.mjs`
- `scripts/finalize-service-worker.mjs`
- `scripts/smoke-test.mjs`
- `scripts/check-pre-deploy.mjs`

## 10. Evidence

Evidence root:

`/Users/ivan/.codex/visualizations/2026/07/20/019f7e59-d156-7093-89db-85be4b7f0adb/younew-visual-refresh`

- Before screenshots: `before/`
- After screenshots: `after/`
- Exact responsive metrics: `after/responsive-qa-final.json`
- Lighthouse summary and full HTML/JSON reports: `after/lighthouse-summary.json` and
  `after/lighthouse-*.report.{html,json}`
- Reduced-motion proof: `after/reduced-motion-home-1440x900.png`
- Final-worker offline proof: `after/offline-guide-current-sw.{png,json}`
- Print proofs: `after/guide-print.pdf`, `after/media-kit-print.pdf`
- Visual direction concept: `design-concept.png`

No upload, DNS, Hostinger, mail or public production change was performed.
