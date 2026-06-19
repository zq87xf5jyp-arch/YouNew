# Visual Completeness Audit

**Date:** 2026-05-29 21:55 Europe/Amsterdam  
**Project:** YouNew  
**Scope:** Static visual audit plus targeted component improvements. Runtime screenshots are still required.

## Summary

The app now has a consistent premium dark visual language, generated SwiftUI artwork, and local-asset fallback paths. The main remaining risk is not code structure but unverified runtime presentation: screenshots are missing because `CoreSimulatorService` is unavailable in this session.

## Screen Audit

| Screen | Current visual status | Missing visuals | Recommended component | Priority |
|---|---|---|---|---|
| Home | Stronger than baseline; hero and category tiles have generated Netherlands/category visuals | Runtime check for hero text fit, bottom clearance, chip length | `CategoryHeroVisual`, `GeneratedCityArtwork`, `GlassMetricCard` | P0 |
| Search | Previously text-heavy empty states; now upgraded with visual empty states | Runtime check for no-results and empty-query states | `VisualEmptyState` | P1 |
| Saved | Previously plain empty card; now upgraded with visual empty state | Runtime check for empty and populated states | `VisualEmptyState` | P1 |
| Map / Nearby Help | Has city spotlight, province chips, and support card visuals | Runtime check for map legibility and bottom clearance | `GeneratedCityArtwork`, `ProvinceMapMiniGraphic`, `GlassVisualBadge` | P0 |
| Province list | Improved cards with flag/map support | Needs runtime check for dense province rows and long localized province names | `GeneratedProvinceArtwork`, `ProvinceMapMiniGraphic` | P0 |
| Province detail | Has hero, metrics, map panel, city previews | Needs official/newcomer section visual QA | `GeneratedProvinceArtwork`, `GlassMetricCard` | P1 |
| Amsterdam city detail | Rich generated hero/fallbacks and landmark cards | Real assets missing; runtime top/bottom screenshots missing | `CityHeroVisual`, `LandmarkCard` | P0 |
| Leiden city detail | Rich generated hero/fallbacks and landmark cards | Real assets missing; runtime top/bottom screenshots missing | `CityHeroVisual`, `LandmarkCard` | P0 |
| Rotterdam city detail | Data exists and generated city fallback applies | Runtime top/bottom screenshots missing | `CityHeroVisual`, `LandmarkCard` | P1 |
| Fines & Rules | Upgraded with generated category hero | Needs runtime check for list density and chip wrapping | `CategoryHeroVisual`, `LandmarkCard` | P1 |
| Documents | Upgraded with generated category hero | Needs runtime check for action list and scanner flow | `CategoryHeroVisual`, `GlassVisualBadge` | P1 |
| LGBTQ+ Support | Upgraded with generated category hero | Needs runtime check for filters and section cards | `CategoryHeroVisual` | P1 |
| Official Sources | Upgraded with generated category hero and source cards | Needs runtime check for long institution names and URL wrapping | `CategoryHeroVisual`, `OfficialSourceVisualCard` | P1 |
| Explain / AI | Upgraded with source-check hero, visual source block, prompt badges | Needs fixed-input/tab-bar clearance screenshots | `CategoryHeroVisual`, `OfficialSourceVisualCard`, `GlassVisualBadge` | P0 |
| More | Upgraded with category-style hero | Needs runtime check for grouped rows and bottom clearance | `CategoryHeroVisual`, `PremiumSectionHeader` | P1 |
| Settings | Upgraded with settings hero and visual profile badge | Needs runtime check for one back button and language selector | `CategoryHeroVisual`, `GlassVisualBadge` | P0 |
| Category detail pages not yet individually upgraded | Mixed; Fines, Documents, LGBTQ, Official Sources are stronger | BSN, Housing, Work, Healthcare, Transport, Legal Help, Dutch Language still need dedicated heroes | `CategoryHeroVisual`, `GlassMetricCard`, `LandmarkCard` | P2 |

## Visual Language Notes

- Keep the dark navy base, subtle Dutch flag accents, cyan highlights, orange attention accents, and glass cards.
- Use generated vector-style artwork rather than plain SF Symbols where real assets are missing.
- Avoid repeated heavy blur in long lists. Prefer single generated artwork blocks per hero/card.
- Do not show technical asset status to users.

## Runtime QA Required

Screenshots still required before any TestFlight claim:

- Home top/bottom
- Search
- Saved
- Map
- Province list/detail
- Amsterdam city detail
- Leiden city detail
- Category detail
- Documents
- Fines
- Explain
- More
- Settings

## Verdict

Not ready for TestFlight. Runtime screenshots are missing.
