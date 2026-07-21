# Final QA report — YouNew Guide

Date: 2026-07-11  
Release verdict: **NOT READY**

## Executive summary

The information architecture is substantially cleaner and profile-based hiding has been removed. The five-tab shell and root responsibilities are statically consistent. However, the canonical repository is not yet the single runtime source for Guide, Search, Map and Saved navigation. Consequently, zero lost/orphaned/unsearchable content cannot be proven, and canonical deep links are confirmed unsupported.

## Gate results

| Gate | Result |
|---|---|
| `lost_content = 0` | Not proven — runtime metrics unavailable |
| `orphaned_content = 0` | Fail — canonical Guide projection is not rendered by RootGuideView |
| `unsearchable_content = 0` | Fail — canonical search exists but is not the SearchView result source |
| `profile_blocked_content = 0` | Static pass |
| One five-tab system | Static pass |
| Search is not a tab | Pass |
| AI does not create a sixth tab | Pass |
| All canonical deep links work | Fail |
| Saved returns to canonical item | Fail for IDs without legacy destination |
| Map covers coordinate items | Not proven in UI |
| Last cards clear the tab bar | Static pass for new roots; device matrix incomplete |

## Screen responsibilities

- Home: PASS. It shows summary/action sections and eight top-level shortcuts, not the full subcategory catalogue.
- Guide: PARTIAL. It owns the thematic entry points but does not display the canonical ContentItem collection.
- Map: PARTIAL. The root now opens a live MapKit surface with annotations immediately, but it still does not project `ContentRepository.mapItems()`.
- Saved: PARTIAL. Persistence contains only ID and timestamp, but not every ID resolves to an actionable row.
- More: PASS. RootMoreView contains only profile, city, language, notifications, appearance, sources, feedback, privacy and about.
- AI Assistant: PARTIAL. Canonical IDs/deep links can be returned by `answerContentContext`, but generated content deep links are not handled by navigation.

## UI and accessibility

- Static accessibility, performance, localization, route/action, image and Apple-review checks passed.
- New roots use scroll containers, safe-area padding, adaptive grids and bottom tab reserve.
- Runtime smoke coverage passed on the standard iPhone simulator for all five roots. Map opens MapKit directly, More opens its canonical grouped settings screen, and the shared tab bar clears the final visible content.
- The full iOS 26.5 automated test run produced an incomplete `.xcresult` during the build/test handoff, so it is not counted as a passing test run.
- No current PASS is claimed for SE, Pro Max, landscape, offline, VoiceOver, Reduce Motion or all long-content screens.

## External links

- 788 unique URLs were requested.
- 44 returned HTTP 404; one returned HTTP 500.
- 396 returned HTTP 429 and 13 returned HTTP 403, so their availability remains unverified rather than automatically broken.
- Full evidence is recorded in `broken_links.csv`.

## Evidence

- `scripts/run-static-qa.sh`: PASS.
- `ContentRepositoryTests`: build attempted on iOS 26.5; runner stalled before results and was terminated.
- Static source tracing: canonical repository, root Guide, Search, Map and Saved implementations.
- Live HTTP check: `scripts/check-external-links.py`.
- Standard-iPhone screenshots: `IA_Audit_Screenshots/final-home.png`, `final-guide.png`, `final-map-fixed.png`, `final-saved.png`, `final-more-fixed.png`.

## Required decision

Do not label the refactor complete. The next implementation phase must connect all discovery surfaces and navigation to the canonical repository, then rerun the complete coverage and device matrix.
