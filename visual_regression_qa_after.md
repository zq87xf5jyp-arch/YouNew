# Visual regression QA after stabilization

Date: 2026-07-11

Runtime evidence is limited to visually inspected iPhone 15 Russian default captures. The Xcode UI runner did not start test cases because `DebuggerLLDB.DebuggerVersionStore` reported `no debugger version`; therefore scroll-end and Accessibility XXXL criteria remain `NOT TESTED`.

| Screen | 1 Tab bar | 2 No gap below | 3 Last item clear | 4 AI placement | 5 Content density | 6 Hierarchy | 7 Categories | 8 Localization | 9 Component sizing | 10 Purpose |
|---|---|---|---|---|---|---|---|---|---|---|
| Home | PASS | PASS | NOT TESTED | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Guide | PASS | PASS | NOT TESTED | PASS | PASS | PASS | PASS | PASS | PARTIAL | PASS |
| Map | PASS | PASS | NOT TESTED | PARTIAL | PASS | PASS | PASS | PASS | PASS | PASS |
| Saved | PASS | PASS | NOT TESTED | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| More | PASS | PASS | NOT TESTED | PASS | PASS | PASS | PASS | PASS | PASS | PASS |

## Acceptance status

- AI no longer overlays Home or Guide cards: PASS (runtime initial viewport).
- Russian Map result summary: PASS (`26 мест в г. Лейден` runtime evidence).
- Compact Home Search/Urgent and Saved empty state: PASS (runtime initial viewport).
- Bottom-of-scroll clearance on five screens: NOT TESTED (runner infrastructure failure).
- Full device/language/text-size matrix: PARTIAL.

