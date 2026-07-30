# My YouNew v19 fidelity ledger

Concept: `docs/design/v19/my-younew-concept.png`

QA captures:

- `/Users/ivan/.codex/visualizations/2026/07/29/younew-v19-qa/my-younew-desktop-1280x720-full.png`
- `/Users/ivan/.codex/visualizations/2026/07/29/younew-v19-qa/my-younew-mobile-390x844.png`
- `/Users/ivan/.codex/visualizations/2026/07/29/younew-v19-qa/my-younew-mobile-menu-390x844.png`

## Fidelity checkpoints

| Checkpoint | Result | Evidence |
|---|---|---|
| Information architecture | Match | `Start`, `My YouNew`, discovery routes, updates, business, search and app status remain in the intended hierarchy |
| Above-fold hierarchy | Match | H1, supporting line, saved-route panel and device summary appear before secondary content |
| Retention modules | Match | Route, journey progress, saved materials, recent pages and latest reviewed updates are present |
| Visual language | Match | Dark navy surface, cyan trust accents, orange primary actions, thin borders and large white headings |
| Privacy controls | Improved | Real local-only status, sanitized JSON export and complete clear-data action are implemented |
| Responsive behaviour | Match | 390 px layout reflows to one column, desktop navigation becomes a reachable mobile menu and horizontal overflow is zero |
| Content integrity | Improved | Cards use governed published records and real local state; missing user state renders honest empty states |
| Accessibility | Match | Semantic headings/regions, labelled navigation, native progress element, keyboard-operable controls and readable mobile order |

## Above-fold copy diff

| Element | Concept | Implementation |
|---|---|---|
| H1 | `Continue where you left off.` | Exact match |
| Supporting line | `Your route, saved materials and reading progress stay on this device.` | Exact match |
| Primary panel | `Your next step` | Exact match |
| Secondary panel | `This device` | Exact match |

## Intentional deviations

- Concept sample counts, time estimates and article claims were not copied. The implementation shows only sanitized local browser state and governed published records.
- Concept sample actions such as “Book an appointment” were replaced with honest continuation labels because full practical guides have not passed the publication gate.
- The production site’s existing YouNew logo, orange primary CTA and full legal footer were retained for system consistency.
- Desktop QA ran in the browser’s available 1280×720 viewport. Mobile QA used an isolated 390×844 iframe browsing context, which produced a true 390 px CSS viewport after the browser-level viewport override failed to apply.
