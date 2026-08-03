# YouNew public web: user-first audit

Date: 3 August 2026  
Scope: `admin-dashboard/public-site` only. The iOS app, Admin and canonical DataProject content were inspected for consistency but not modified.

## Confirmed baseline

- Production homepage title: `YouNew — A clearer start in the Netherlands`.
- Previous desktop primary navigation exposed eight product areas and separate search/app actions.
- Previous homepage contained 12 direct main sections, 853 visible main-content words, 89 links and 23 footer links.
- The production DOM had no duplicate IDs, missing image alt text or horizontal overflow at 1440×900 and 390×844.
- Generated public content contains 182 published entities, 15 summary-depth guides and 5 detailed city routes: Amsterdam, Rotterdam, Den Haag, Utrecht and Eindhoven.
- No full practical guide is currently published. The interface must label summary-depth content honestly.
- The current iPhone preview shows Leiden. Leiden is labelled as app local context, not as one of the five detailed web city guides.
- The main iOS target declares iOS 17.6. Other project targets have different deployment settings, so the website claim is limited to the public app availability surface.

## Problems found

| Area | Before | Risk | Resolution |
| --- | --- | --- | --- |
| Homepage | Technical evidence, AI and B2B competed with the main task | Users could not understand the product in five seconds | Rebuilt as eight user sections with one H1 and two hero actions |
| Navigation | Eight primary destinations plus utilities | Duplicate and unclear entry points | Reduced to Start, Guides, Cities and Map; Saved, Search and Emergency are utilities |
| Mobile menu | Manual tab loop on a non-modal disclosure | Scroll/focus trap behavior | Removed the tab loop; Escape closes and restores trigger focus |
| Profiles | Copy did not explain the effect; selected profile was sent to analytics | Misleading personalization and privacy mismatch | Four explicit browsing preferences, real recommendations, clear/reset, local-only storage, action-only analytics |
| Start | All choices visible at once; result preselected | Not a guided decision flow | Task → situation → national/city → result, with Back, Reset and direct links |
| Search | Generic empty state | Weak recovery | Exact published-content empty state with a Guides route |
| Saved | No selective clear-all flow | Hard to manage local data | Added inline confirmation and a repository method that clears only saved shortcuts |
| Coverage | Broad product language and Leiden screenshot could imply equivalent web coverage | Overclaiming | Five web city guides are named; national/municipality directory scope and Leiden app context are separate |
| Languages | Footer advertised pending locales | Incomplete locales could appear available | Footer now says only `Website language: English` |
| Privacy | Profile event contained the selected value | Contradicted banner and policy | Event schema now records only `profile_selected` with empty properties |

## Implemented information architecture

1. Header
2. Hero
3. Popular tasks
4. Choose your situation
5. How YouNew works
6. Website and iPhone app
7. Current coverage
8. Trust and sources
9. Final CTA and concise footer

The eight numbered content sections are separate from the global header and footer.

## Current product boundaries

- Public web content is generated at build time from approved production releases.
- Search reads the generated public index and excludes draft/unpublished content.
- Web profile, route and saved-item preferences stay in browser local storage.
- Web and app state do not sync.
- The public web map does not request location permission on load.
- YouNew explains published information; responsible institutions remain the authority for current procedures.

## Visual fidelity ledger

The implemented UI was compared with the five accepted generated concepts and the exported build:

1. The hero keeps the exact promise, two-action hierarchy, source-check line and route motif.
2. Popular tasks remain a six-item desktop grid and become a horizontal, scrollable mobile rail.
3. Tourist, Student, Expat and Refugee cards preserve the concept hierarchy while adding real, distinct recommendations and an explicit clear action.
4. The three-step explanation and Amsterdam registration example retain the source-first structure without presenting summary content as a full practical guide.
5. Web and iPhone surfaces remain visually distinct; the Leiden app preview is explicitly separated from the five detailed web city guides.
6. Trust, final CTA, compact navigation and the English-only footer keep the accepted hierarchy in both themes.

## Candidate verification

- Full `CI=true pnpm predeploy:check`: passed all 10 stages.
- Unit/schema tests: 116 passed, 0 failed, 0 skipped.
- Static package: 581 generated pages, 571 sitemap/indexable routes and 578 HTML files.
- Internal references, fragments and assets: 38,441 checked, 0 broken.
- Lighthouse 13.4.1 mobile candidate: Performance 94, Accessibility 100, Best Practices 100, SEO 100; CLS 0 and TBT 0 ms.
- Candidate Lighthouse LCP was 3.08 s in the local throttled run, above the 2.5 s target. The score remains a release optimization item, not a hidden pass.
- Browser QA covered the homepage, mobile menu, themes, profile selection/reset, Start, Search, Saved, App, Business and consent focus behavior with no console messages observed.
- Current production AASA response: HTTP 200, valid JSON and `Content-Type: application/json`.
- The candidate has not been deployed by this audit; production state must be rechecked after merge and deployment.

## Known limitations

- The published dataset has 15 summary guides and no full practical guide; content gaps remain for finding work, bank account and student housing.
- Practical-guide production authorization and a human reviewer are not established, so draft scaffolds remain unpublished.
- Homepage CSS remains a shared global stylesheet; the local mobile LCP result shows that CSS splitting is still worthwhile.
- Web state is local to a browser and does not sync with the iPhone app.

Run the commands in `WEB_RELEASE_CHECKLIST.md`, complete browser QA on the exported build, and confirm the hosting response headers after deployment. Production state is not inferred from a local build.
