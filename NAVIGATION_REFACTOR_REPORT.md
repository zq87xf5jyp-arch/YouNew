# YouNew navigation refactor report

Date: 2026-07-11

## Changed screens and components

- `RootTabView` / `AppTabView`: one five-tab shell, one item specification for compact and regular layouts, independent navigation paths.
- `TabRouter`: canonical Home, Guide, Map, Saved, More states; Search and AI are no longer tab states.
- `RootHomeView`: current city/weather entry, global search, urgent help, next actions, eight category shortcuts, recent, saved and ranked recommendations.
- `RootGuideView`: complete eight-category thematic catalog and global search.
- `NetherlandsMapHubView`: direct Map root; Places/Search aggregation is no longer the Map tab.
- `FavoritesView`: Saved root no longer filters content by persona.
- `RootMoreView`: only profile, city, language, notifications, appearance, sources/updates, feedback, privacy and about.
- `AIContextBuilder`: understands the five canonical roots.
- `PersonaContentPolicy` and `RelatedContentEngine`: audience metadata no longer blocks content.
- `RootNavigationUITests`: screenshot, stable-tab, safe-area and Accessibility XXXL coverage.

## Before → after navigation

| Before | After |
|---|---|
| Home | Home |
| Places combining Guide/Search/Map | Guide and Map have separate responsibilities |
| AI Assistant tab | Floating global AI action and Search context action |
| Saved | Saved |
| More plus duplicate side-menu catalog | More contains settings/product controls only |
| Legacy Search/Map states mapped internally to Places | Search is an action; Map is a real tab |

Final order everywhere: **Home → Guide → Map → Saved → More**.

## Content moves

- Weather → Home current-city card; city pages remain the detailed local owner.
- Emergency → Home urgent action and Guide → Health and safety.
- Documents → Home next actions and Guide → Getting started / Official services.
- Learning → Guide → Study.
- Guide and support → Guide.
- All former More content categories remain reachable through Guide/Search; they were not deleted.

## Safe-area and adaptive layout

- Root scroll views use top safe-area padding.
- Every new root ends with `AppSpacing.tabBarScrollReserve`.
- Compact tab content reserves the floating bar height at the shell level.
- Category grids use adaptive columns rather than fixed horizontal card widths.
- Long titles use vertical fixed sizing instead of aggressive truncation.
- Touch targets remain at least 44×44 points.

## Test evidence

- App build: passed on iOS 26.5 simulator destination.
- Navigation unit suite: 28/28 passed.
- Full static QA suite: passed, including accessibility, route/action, localization, search, performance, Apple review and persona IA checks.
- Root UI suite on standard simulator:
  - five stable tabs/no Search or AI tab: passed;
  - Accessibility XXXL Home actions: passed;
  - multi-root screenshot test found test-identifier ambiguity; ambiguity was fixed, but subsequent simulator runners stalled before a clean rerun.
- iPhone SE and Pro Max runners stalled during deployment/launch and were stopped; no visual PASS is claimed for those devices.

## Remaining problems

1. Re-run screenshot tests on iPhone SE and Pro Max after resetting their simulator/test-runner state.
2. Re-run the five-root screenshot test after Xcode's recurring `DebuggerVersionStore` runner issue is resolved.
3. Landscape is supported by project orientation settings, but runtime verification remains pending because secondary runners stalled.
4. Several legacy screen-specific arrays and old side-menu implementation remain in source for migration safety; they are no longer root navigation owners.
