# YouNew — Visual Developer Specification

Status: implemented baseline with acceptance rules
Platform: SwiftUI, iOS 17.6+

## Product intent

YouNew is a premium visual information guide for the Netherlands. Information is consumed through text, imagery, maps and structured cards. Voice input and speech output are outside the product scope.

Canonical content remains the single source of truth. Visual surfaces may repeat links to an item, but must never copy its text payload into separate Home, Guide, Map or Saved arrays.

## Root navigation

The five persistent roots are always ordered as follows:

| Root | Inactive symbol | Active symbol | Responsibility |
| --- | --- | --- | --- |
| Home | `house` | `house.fill` | Information dashboard |
| Guide | `safari` | `safari.fill` | Complete thematic catalogue |
| Map | `map` | `map.fill` | Coordinate-backed content |
| Saved | `heart` | `heart.fill` | References to canonical items |
| More | `ellipsis.circle` | `ellipsis.circle.fill` | Profile and application settings |

The selected item uses the Dutch Orange accent, selected background and dot indicator. Every item retains a minimum 44-point touch target. The bar stays attached to the bottom safe area and cannot cover the final scroll item.

## Home composition

Home presents, in priority order:

1. YouNew identity, profile action and current city.
2. City hero/weather context.
3. Global text search.
4. Urgent help.
5. Next actions.
6. A compact highlight of the primary categories with an Open Guide action.
7. City/place discovery using verified imagery.
8. Useful information, recently viewed, saved and personalized recommendations when available.

Home is not the complete catalogue. Profile data may change ordering but cannot hide content.

## Guide

Guide is the complete thematic catalogue:

- Getting started
- Housing
- Official services
- Work and money
- Study
- Health and safety
- Transport
- Explore

Search and filter controls operate over canonical items. Geographic entities are not thematic categories. Long lists use lazy containers and stable canonical identity.

## Map

Map renders only coordinate-backed entities. Category chips and map/list switching must not create duplicate place records. Selecting a marker opens the canonical place or content detail. Map controls and selected-place cards respect the bottom safe area.

## Saved

Saved stores identifiers only. A populated row resolves its title, imagery, category and destination from the canonical repository. The empty state provides an explanatory message and a direct Open Guide action.

## More

More contains application-level destinations only: Profile, Current city, Language, Notifications, Appearance, Sources and updates, Feedback, Privacy and About. Thematic content remains in Guide.

## Place detail

A place detail may show:

- verified hero image and attribution;
- canonical/local title and category;
- address and coordinates;
- description;
- verified opening-hours/source link when available;
- save state;
- map location.

Ratings, prices, counts, travel times, opening hours and phone numbers must not be invented. Mutable facts require a source and verification date.

## Visual system

| Token | Dark reference |
| --- | --- |
| Background | deep navy atmosphere near `#0C1824` → `#1A2D3D` |
| Primary accent | Dutch Orange near `#E87A3E` |
| Gold accent | near `#D4A843` |
| Delft blue | near `#2A4A6E` |
| Primary text | warm white near `#F5F0E8` |
| Glass surface | translucent adaptive surface with material blur |

The implementation keeps adaptive Light/Dark colors rather than forcing dark-only literal values. Glass surfaces use a material layer, subtle contour and adequate solid fallback when Reduce Transparency is enabled.

## Typography

Use Dynamic Type-aware system fonts through `AppTypography`:

| Role | Reference size/weight |
| --- | --- |
| Screen title | 28–30 pt Bold |
| City title | 24 pt Semibold |
| Section title | 22–24 pt Semibold |
| Card title | 16–19 pt Semibold |
| Body | 14–16 pt Regular |
| Metadata | 11–13 pt Regular/Medium |

Text must wrap at accessibility sizes. Do not solve overflow with fixed heights or aggressive scaling below readable sizes.

## Interaction and motion

- Cards use spring press feedback around 0.96 scale without shifting surrounding layout.
- Section entry may use staggered opacity/translation/scale.
- Filter selection uses a clear selected fill and text contrast.
- Save state changes between outline and filled heart with a localized accessibility value.
- Reduce Motion disables decorative looping and replaces spatial transitions with restrained opacity changes.
- AI, search or floating actions must overlay safely and never become a sixth tab or participate in content layout.

## Acceptance checklist

- [ ] Exactly five root tabs with the specified order and symbols.
- [ ] Home remains an information dashboard, not the entire catalogue.
- [ ] Guide exposes every useful canonical item.
- [ ] Map contains coordinate-backed objects only.
- [ ] Saved persists IDs/references only.
- [ ] More contains no thematic catalogue.
- [ ] No voice/speech API, UI control or permission description exists.
- [ ] No `Places` or `Сохран.` label appears in Russian navigation.
- [ ] Last scroll content remains above the tab bar.
- [ ] All interactive controls are at least 44 points.
- [ ] Dynamic Type, VoiceOver, Reduce Motion and Reduce Transparency are supported.
- [ ] No mutable fact is displayed without real source-backed data.
