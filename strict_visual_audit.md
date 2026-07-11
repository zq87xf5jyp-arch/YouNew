# YouNew strict reference visual audit

Date: 2026-07-11  
Reference: user-supplied YouNew premium-dark collage and Netherlands night photography.  
Runtime target: iPhone 17 Pro simulator, portrait.

## Captured flow

1. Home — initial automated capture rejected because it showed a white launch frame; accepted post-refinement evidence is `02-refined-home.png`.
2. Guide — `IA_Audit_Screenshots/strict-reference-pass/01-baseline-guide.png`
3. Map — `IA_Audit_Screenshots/strict-reference-pass/01-baseline-map.png`
4. Saved — `IA_Audit_Screenshots/strict-reference-pass/01-baseline-saved.png`
5. More — `IA_Audit_Screenshots/strict-reference-pass/01-baseline-more.png`

## Findings before refinement

| Severity | Surface | Finding | Reference gap | Required correction |
|---|---|---|---|---|
| P0 | Home UI-test launch | Automated Home capture can hit a white launch frame when launched repeatedly with UI-test arguments. A console-backed normal launch renders correctly. | Commercial product must not expose an indeterminate white state. | Keep as runtime issue; diagnose separately from visual styling and do not claim UI-test stability. |
| P1 | Global background | The full-strength Amsterdam photograph competes with titles and cards on Map and Saved. | Reference uses photography as hero content, with a controlled midnight-blue application floor. | Reduce photograph to atmospheric texture and restore navy as the dominant background. |
| P1 | Guide | Category cards are tall and visually equal; only a few items fit per viewport. | Reference is compact and information-rich. | Reduce card height, radius and internal spacing; preserve all eight categories. |
| P1 | Saved | Empty-state actions are oversized and visually louder than the empty-state message. | Reference uses one clear focus and compact secondary routes. | Inherit a tighter shared card system and reduce excessive glass/shadow weight. |
| P1 | More | Large grouped rows and black background feel disconnected from image-backed root screens. | All roots should share the same navy atmosphere and depth system. | Make the ScrollView transparent, use the global backdrop, and tighten rows. |
| P1 | Map | The map surface reads as a gray placeholder with grid and clustered dots. | Reference calls for a recognisable premium Netherlands/province visual. | Preserve the existing map flow but strengthen dark navy surface, borders and selected orange state; real Apple Map remains downstream. |
| P2 | Shared cards | Animated contour and multiple material/gradient layers run on every glass card. | Effects should be restrained and performant. | Replace continuously animated contour with a static edge highlight and reduce shadow radius. |
| P2 | Token consistency | Correct semantic colors exist, but old aliases and broad teal accents still dilute the orange/blue hierarchy. | Reference uses disciplined orange primary, blue/cyan secondary and purple AI accents. | Add explicit semantic aliases and drive shared surfaces from them. |
| P2 | Typography | Screen titles are strong, but category cards use large body blocks and inconsistent density. | Reference uses short labels and compact descriptions. | Tighten Guide card typography and line limits without hiding catalog access. |

## Accessibility limits

Screenshots confirm visible contrast and touch-target scale only. VoiceOver order, focus behavior, Dynamic Type overflow and Reduce Motion require runtime checks. No full accessibility-compliance claim is made from screenshots.

## Audit result

Core refinement completed and compared on the same iPhone 17 Pro simulator.

## After refinement

| Surface | Evidence | Result |
|---|---|---|
| Home | `02-refined-home.png` | Premium navy atmosphere, real Leiden hero, orange brand hierarchy and eight compact canonical categories retained. |
| Guide | `02-refined-guide.png` | Shared navy cards are denser; all categories remain reachable and long descriptions receive up to three lines. |
| Map | `02-refined-map.png` | The existing premium Netherlands map is restored as the visual centre, with province boundaries, Leiden selection and the Province → City map transition. |
| Saved | `02-refined-saved.png` | Empty-state routes inherit the unified darker surface, border, radius and shadow system. |
| More | `02-refined-more.png` | Root background and grouped rows now use the same navy atmosphere and compact shared card metrics. |
| Government | `02-refined-government.png` | Official hero, source-led institution cards and non-commercial hierarchy remain intact while inheriting shared tokens. |
| Partners | `02-refined-partners.png` | Verified labels, categories, city, imagery and actions remain present; the screen inherits the shared card system. |

## Remaining evidence limits

- AI could not be opened reliably through the debug deep-link launch argument; the argument returned to Home. AI static QA passes, but this runtime route needs a dedicated UI-test fix.
- iPhone SE, iPhone 15, Pro Max, iPad, landscape and physical-device tests were not run in this pass.
- VoiceOver, largest Dynamic Type, FPS and memory require separate device or Instruments sessions.

## Final result

Passed for the shared visual system and captured core surfaces. Full device/runtime matrix remains partially unconfirmed as listed above.
