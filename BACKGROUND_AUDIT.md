# Background Audit

Date: 2026-06-13

Scope: static audit of the YouNew SwiftUI background system after the premium visual-system cleanup. Runtime screenshots were not captured in this pass, so this report verifies source routing and compile health, not pixel-perfect device output.

## Executive Summary

Status: PASS for static background routing.

The app previously had multiple visual worlds: root app backgrounds, style-specific screen backgrounds, onboarding-specific flag backgrounds, older Dutch flag wave backgrounds, and screen-level fallback colors. These could create visible seams, duplicated layers, and different moods between Home, Map, City, Province, More, AI, Onboarding, and guide screens.

The app now routes all screen backgrounds through one source of truth:

- `GlobalBackgroundView` in `YouNew/Components/AppAtmosphereBackground.swift`
- `.appSceneBackground(_:)` in `YouNew/Resources/AppShadows.swift`
- root app shell in `YouNew/NavigateNLApp.swift`

Legacy wrappers remain only as compatibility aliases and all return `GlobalBackgroundView`.

## Findings

| Area | Previous Risk | Fix | Status |
| --- | --- | --- | --- |
| Root app shell | Root could layer a separate Netherlands background under child screens. | Root now uses `GlobalBackgroundView`. | PASS |
| Home | Used semantic `.home` background style that previously could differ from other screens. | `.appSceneBackground(.home)` now resolves to the global background. | PASS |
| Search | Used semantic `.search` style. | Style parameter retained for API compatibility, visual output unified. | PASS |
| Map | Map and province flows used separate map/province styling. | All `.appSceneBackground(.map/.province)` calls resolve to the global background. | PASS |
| Saved | Saved route used separate saved styling. | Unified through global background. | PASS |
| AI Assistant | Had an explicit assistant background. | Replaced with `GlobalBackgroundView`. | PASS |
| More | Sidebar and More screens could render their own styled background. | Sidebar uses `GlobalBackgroundView` with a light material overlay for hierarchy. | PASS |
| Province | Province pages and sheets used style-specific province background. | Unified through global background. | PASS |
| City | City pages used style-specific city background. | Unified through global background. | PASS |
| History | History screens use semantic document/more styles. | Style calls resolve to global background. | PASS |
| Guide/Journey/Help | Multiple guide views used direct scene backgrounds. | All audited direct background bypasses now use `.appSceneBackground()` or global background. | PASS |
| Settings | Settings navigation bar and scene background could feel flatter than app body. | Scene background unified; nav bar uses `AppSurface.base.opacity(0.94)`. | PASS |
| Old visual layers | `CityMapBackground`, `PremiumAtmosphereLayer`, `AppAmbientMotionLayer`, and route overlays could revive the old mixed style. | Removed from the active background file. | PASS |
| Unused flag backgrounds | Old `DutchFlagPremiumBackground` and onboarding-specific flag background created an alternate visual language. | Removed unused definitions. | PASS |

## Search Evidence

Search completed for deprecated or duplicate background routes:

- `AppColors.background.ignoresSafeArea()`
- `AppColors.background)`
- `YouNewScreenBackground(`
- `NetherlandsBackground(`
- `CityMapBackground`
- `PremiumAtmosphereLayer`
- `AppAmbientMotionLayer`
- `RouteLineBackground`
- `DutchFlagPremiumBackground(`
- `OnboardingDutchFlagPremiumBackground(`

Result: no active project matches.

There are 90 expected references to either `GlobalBackgroundView()` or `.appSceneBackground(...)`. This is expected because `.appSceneBackground(...)` is now a semantic wrapper around the global background rather than a visual branch.

## Remaining Non-Background Visual Layers

Some screens still use gradients, image overlays, and internal card surfaces. These are content surfaces, not screen backgrounds. Examples include hero image overlays, map drawing, transport graphics, navigation icons, and card accents.

Status: acceptable for this pass, because the primary requirement was to remove competing screen backgrounds and establish a single global environment.

## Verification

Static checks performed:

- Swift type-check passed for all app Swift files.
- Existing warning remains in `YouNew/Services/LocationService.swift` about `CLLocationManagerDelegate` actor isolation. This warning is unrelated to the visual-system work.
- Deprecated background constructors and removed old atmosphere layers no longer appear in active source search.

Runtime verification:

- RUNTIME SCREENSHOT VERIFICATION NOT PERFORMED in this pass.
- Device review is still required to confirm there are no visible seams, flashes, or color jumps during real navigation and scrolling.

