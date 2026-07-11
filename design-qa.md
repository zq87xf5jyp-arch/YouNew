# YouNew reference redesign — design QA

## Evidence

- Reference: `Фото 1.jpg` / `Фото 2.jpg`, supplied by the user on 11 July 2026.
- Baseline: `IA_Audit_Screenshots/final-visual-spec-home-3.png`.
- Final render: `IA_Audit_Screenshots/reference-redesign-home-final.png` on the iPhone 17 Pro simulator.

## Visible comparison

| Area | Baseline | Reference target | Final result | Status |
|---|---|---|---|---|
| Brand | Small serif wordmark; weak Dutch identity | Bold YouNew lockup with orange emphasis and Dutch flag | Large rounded You/New lockup, orange emphasis, Dutch flag, compact guide tagline | Pass |
| Density | Large stacked blocks delayed the primary catalog | Dense, useful dashboard visible immediately | City, search and all eight canonical categories fit before secondary content | Pass |
| City context | Oversized city hero dominated the screen | Compact city/weather context | Hero reduced to 126 pt while keeping the real city image and city route | Pass |
| Categories | Only four categories visible; large cards | Eight compact colored feature tiles | Eight canonical Guide categories in a two-column grid with distinct gradients | Pass |
| Hierarchy | Urgent and checklist rows displaced core discovery | Features lead; support actions remain available | Guide catalog leads, followed by next actions and urgent help | Pass |
| Navigation | Five tabs, but visually detached from sparse content | Fixed compact five-item bottom navigation | Existing canonical five-tab bar retained; last content reserves tab-bar space | Pass |
| Interaction | Working but visually heavy | Responsive premium cards | Existing spring press, stagger, navigation links, search, profile and city actions retained | Pass |
| Localization | Localized data but long English strings could dominate | Compact readable labels | Canonical localized titles; two-line limits and flexible cards preserve long strings | Pass |

## Severity review

- P0: none remaining. The first captured white frame was a transient simulator launch frame; the settled app render is valid.
- P1: none remaining in the redesigned Home viewport.
- P2: other root screens retain their current visual language and can receive the same denser brand treatment in a separate pass; no functional inconsistency was introduced here.

## Guardrails verified

- No content was removed from Guide or Search.
- Personalization continues to affect ordering only.
- All eight canonical categories remain reachable from Home and Guide.
- AI remains a text action and does not create a sixth tab or move layout content.
- The bottom bar remains at the safe-area edge and the scroll reserve prevents the final content from being covered.
- Dynamic Type continues to use SwiftUI semantic typography and wrapping; touch controls keep 44 pt targets.

## Final result

Passed for the requested Home redesign against the supplied reference.

## Amsterdam background follow-up

- Source: user-supplied Amsterdam canal photograph, 1280 × 853.
- Final render: `IA_Audit_Screenshots/amsterdam-background-home-final-settled.png`.
- The photograph is installed as a real asset and rendered full-bleed behind the application chrome.
- A navy-to-black readability veil preserves white-text contrast while retaining the sunset, canal houses, bridge and reflections.
- Scroll surfaces remain transparent, while cards and the fixed tab bar keep their existing high-contrast materials.
- Reduce Transparency receives a stronger veil instead of removing content.

Final result: passed.
