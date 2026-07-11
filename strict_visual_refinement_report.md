# YouNew strict visual refinement report

## Design tokens changed

- Added explicit semantic tokens for primary/secondary backgrounds, card background, orange primary accent, blue/cyan secondary accent, AI violet and dividers.
- Rebased shared surfaces on deep midnight navy.
- Standard card radius reduced to 18 pt; modal radius reduced to 24 pt.
- Card and floating shadows shortened to reduce haze and rendering cost.
- Shared card gradients now use lower white/accent opacity for controlled depth.

## Shared components updated

- `GlobalBackgroundView`: navy is again the dominant floor; the Amsterdam image is retained only as a low-opacity atmospheric texture.
- `AppGlassCardModifier` and `AppCardStyleModifier`: inherit the tighter surface, radius, border and shadow tokens.
- `AppCardContourOverlay`: continuous per-card animation removed and replaced by a static edge highlight.
- Brand QA now enforces that ambient background motion remains shared while card contours remain static.

## Screens migrated or materially affected

- Home: inherits the refined background and card system; existing compact reference-driven layout retained.
- Guide: transparent root background, two-column compact grid, tighter spacing and controlled long-text wrapping.
- Map/Places: restored existing premium Netherlands map as the first level; city filters and real MapKit view remain downstream.
- Saved: inherits darker shared cards and reduced depth effects.
- More: transparent root background, unified shared group cards and 58 pt rows.
- Government services, AI surfaces, partners, onboarding and remaining shared-card screens inherit updated tokens without route changes.

## Old styles removed or superseded

- Removed the continuously animated glow loop from every shared card.
- Superseded 22 pt default card radius with the 18 pt shared token.
- Superseded the full-strength photographic application background with a navy-dominant atmospheric treatment.
- No content arrays, canonical IDs, saved data or navigation routes were removed.

## Images and effects

- The user-supplied Amsterdam image remains in the asset catalog and is now used as subtle atmosphere, not as a competing content layer.
- City hero photography remains semantic and city-specific; Leiden does not use an Amsterdam hero fallback.
- Retained restrained ambient background motion, selected marker glow, tap scale and existing stagger transitions.
- Reduced card blur/shadow work and eliminated per-card timeline refreshes.

## Content and structure

- No useful block was hidden because of profile state.
- The premium Netherlands map now follows Country → Province → City → real map/navigation.
- Nearby, local partners and today's events are restored below the map from existing data sources.
- No fake partner, official-service or map data was introduced.

## Runtime and QA

- Build: PASS on iPhone 17 Pro simulator.
- Full static QA: PASS, including 582/582 localization keys, navigation, accessibility, performance, search, canonical route IDs, media and AI subsystem checks.
- Runtime screenshots captured for Home, Guide, Map, Saved, More, Government services and Local Partners.
- Confirmed device: iPhone 17 Pro simulator, portrait, dark mode.

## Not confirmed

- AI debug deep-link runtime route: launch argument returned to Home; static AI checks pass, but a dedicated UI-test repair is still needed.
- iPhone SE, iPhone 15, Pro Max, iPad and landscape.
- Physical-device VoiceOver and maximum Dynamic Type.
- Instruments FPS, allocations, memory and energy metrics.

The navigation remains `Home / Guide / Map / Saved / More`. AI remains a global contextual action instead of replacing Guide or Map, preserving the established information architecture.
