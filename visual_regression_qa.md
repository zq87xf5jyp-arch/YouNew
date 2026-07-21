# Strict visual regression QA — YouNew Guide

Date: 2026-07-11  
Compared states: populated legacy screenshots (`after-*`), broken regression screenshots (`regression-root-*`), current restored screenshots (`final-*`, using `final-map-fixed` and `final-more-fixed`).  
Verdict: **REJECTED**

## Automatic rejection gate

The current version is rejected because Map displays the mixed-language string `26 results in Лейден`. The other automatic rejection conditions were not reproduced in the current build: the five-tab bar is attached through a bottom `safeAreaInset`, there is no obsolete `Places` or `Сохран.` tab label, Home contains more than three useful blocks, and the AI launcher is an overlay rather than a layout participant.

The screenshots prove only the standard-iPhone configuration. Accessibility and final-card clearance therefore remain conditional until bottom-of-scroll checks run on SE, standard and Pro Max with Accessibility XXXL.

## Summary table

| screen | layout_pass | content_density_pass | navigation_pass | localization_pass | safe_area_pass | accessibility_pass | remaining_issues |
|---|---|---|---|---|---|---|---|
| Главная | PARTIAL | PASS | PASS | PASS | PASS_STATIC | PARTIAL | AI overlay visually covers the category grid; first viewport is dense and the search/emergency controls are oversized. Bottom-of-scroll not runtime-proven. |
| Гид | PARTIAL | PASS | PASS | PASS | PASS_STATIC | PARTIAL | All eight canonical categories exist, but two-column cards are tall and the AI overlay covers part of a category card. Bottom-of-scroll and Accessibility XXXL not proven. |
| Карта | PASS | PASS | PASS | **FAIL** | PASS_STATIC | PARTIAL | `26 results in Лейден` mixes English and Russian. Last horizontal filter is intentionally clipped as a scroll affordance, but needs VoiceOver/XXXL validation. |
| Избранное | PARTIAL | PARTIAL | PASS | PASS | PASS_STATIC | PARTIAL | Empty-state hero is too large and pushes actionable rows down. Screenshot shows content behind the translucent tab bar; safe-area code should allow scrolling past it, but final-card clearance is not runtime-proven. |
| Ещё | PASS | PASS | PASS | PASS | PASS_STATIC | PARTIAL | Clear grouping and compact rows. The lower Information group continues below the viewport; bottom-of-scroll and long-string validation remain unproven. |

## Per-screen answers

### Главная

1. Tab bar at bottom safe area: **Yes, statically and visually**.
2. Empty area below it: **No unintended area**; only the system home-indicator inset.
3. Last card overlap: **Not proven**. The captured mid-scroll categories sit behind the floating bar, but `safeAreaInset` should keep the scroll endpoint clear.
4. AI button participates in layout: **No**; it is a bottom-trailing overlay. It does, however, visually cover a category card.
5. Enough content: **Yes** — city, search, urgent help, next actions, categories, with later recent/saved/recommendation sections in the view.
6. Chaotic: **Borderline, not failed**. Hierarchy is understandable, but the first viewport is visually heavy.
7. Categories preserved: **Yes globally**; Home intentionally shows six major shortcuts rather than the full catalogue.
8. Russian/English mixing: **No current visible mixing**.
9. Cards too large: **Partly** — search and urgent action are taller than necessary.
10. Block purpose clear: **Yes**.

### Гид

1. Tab bar at bottom safe area: **Yes**.
2. Empty area below it: **No unintended area**.
3. Last card overlap: **Not proven at scroll end**.
4. AI in layout: **No**, overlay only; visual overlap remains.
5. Enough content: **Yes**.
6. Chaotic: **No**; one catalogue hierarchy is clear.
7. Categories preserved: **Yes**; the grid is driven by all canonical categories sorted by display order.
8. Language mixing: **No visible UI mixing**; `YouNew` is a brand name.
9. Cards too large: **Slightly**; two-column cards consume substantial height.
10. Block purpose clear: **Yes**.

### Карта

1. Tab bar at bottom safe area: **Yes**.
2. Empty area below it: **No unintended area**.
3. Last content overlap: **Not proven at map/list scroll end**.
4. AI in layout: **No**, overlay only.
5. Enough content: **Yes**; search, filters, map/list mode and MapKit annotations are immediately available.
6. Chaotic: **No**, though controls are dense.
7. Categories preserved: **Yes for map filters; thematic catalogue remains in Guide**.
8. Language mixing: **Fail** — `26 results in Лейден`.
9. Cards too large: **No**; the map appropriately owns most of the screen.
10. Block purpose clear: **Yes**.

### Избранное

1. Tab bar at bottom safe area: **Yes**.
2. Empty area below it: **No unintended area**.
3. Last card overlap: **Not proven**; current screenshot visibly cuts a lower row at the bar.
4. AI in layout: **No**, and it is intentionally hidden on Saved.
5. Enough content: **Yes for an empty state**, but actionable density is only partial.
6. Chaotic: **No**.
7. Categories preserved: **Yes** through filters for all supported saved types.
8. Language mixing: **No visible mixing**.
9. Cards too large: **Yes** — the empty-state hero dominates the viewport.
10. Block purpose clear: **Yes**.

### Ещё

1. Tab bar at bottom safe area: **Yes**.
2. Empty area below it: **No unintended area**.
3. Last row overlap: **Not proven at scroll end**.
4. AI in layout: **No**, and it is hidden on More.
5. Enough content: **Yes**.
6. Chaotic: **No**; Profile, App and Information responsibilities are distinct.
7. Categories preserved: **Not applicable**; thematic categories correctly do not live in More.
8. Language mixing: **No visible mixing**.
9. Cards too large: **No material issue**.
10. Block purpose clear: **Yes**.

## Comparison with earlier states

- Populated legacy: visually rich, but navigation included Places and a separate AI tab, More mixed thematic content with settings, and information architecture was diffuse.
- Broken regression: Home retained some content but used `Places` and `Сохран.`; Guide, Map, Saved and More captures were effectively blank/unusable prototypes.
- Current restored: content density and clear five-tab responsibilities are restored without returning the old six-tab structure. The remaining visual regression is localized rather than architectural: mixed Map language, AI overlap, oversized Saved empty state, and missing runtime proof for scroll-end/accessibility layouts.

## Point changes proposed — not applied

1. Localize `resultSummary` in Map for Russian, Dutch and English instead of interpolating the English phrase.
2. Move the AI overlay to a collision-aware anchor or add a visual avoidance region without making it participate in the main content flow.
3. Reduce Home search and urgent-action vertical padding by approximately 12–20%, retaining 44-point minimum touch targets.
4. Reduce the Saved empty-state hero height and surface the first two suggested destinations in the initial viewport.
5. Add automated scroll-to-bottom assertions for all five roots to prove the final element clears the tab bar.
6. Run screenshot tests on iPhone SE, standard iPhone and Pro Max at default and Accessibility XXXL, plus long Russian/Dutch strings and VoiceOver reading order.
7. Keep all useful content in canonical storage; only change projections and placement. Do not remove content to satisfy visual density.
