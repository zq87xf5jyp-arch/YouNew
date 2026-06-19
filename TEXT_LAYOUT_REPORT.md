# Text Layout Report

Date: 2026-06-11

Devices requested: iPhone SE, iPhone 15 Pro, iPhone 15 Pro Max, iPad.

## Status

Runtime device inspection was not available in this environment. The Xcode build attempt failed during asset catalog compilation because CoreSimulator/ibtool reported no available iPhone simulator runtimes. Therefore this report is static-code-backed only and does not claim screenshot proof.

## Fixes Applied

| Screen | Problem | Fix | File Reference |
| --- | --- | --- | --- |
| Onboarding | Missing image references could produce empty/blank visual areas | Replaced old landmark asset names with bundled category assets | `YouNew/Views/OnboardingQuestionnaireView.swift:534` |
| AI Assistant | Missing image references could produce empty prompt-card imagery | Replaced old landmark asset names with bundled category assets | `YouNew/Views/AIAssistantView.swift:815` |
| Documents | Missing hero asset could produce weak/empty hero rendering | Switched to bundled documents hero | `YouNew/Views/DocumentOrganizerView.swift:101` |
| Fines | Missing hero asset could produce broken visual | Removed invalid asset reference so generated fallback is deliberate | `YouNew/Views/FinesInfoView.swift:53` |
| LGBTQ+ | Missing hero asset could produce broken visual | Removed invalid asset reference so generated fallback is deliberate | `YouNew/Views/LGBTQSupportView.swift:43` |

## 2026-06-18 Addendum

- Compact right-side menu quick-action pills now allow two-line labels with a taller stable touch target, covering long labels such as Municipality / Муниципалитет.
- Official services side widget title and subtitle now allow two lines, reducing clipped "Official sources" style labels.
- `user-visible-completeness-static-qa.py` now guards these compact side-menu label surfaces.

## Static Layout Findings

| Area | Result |
| --- | --- |
| Category grids | Use adaptive/flexible grids and fixed-size text on visible cards |
| Help hub | Category tiles use two-column flexible layout with stable minimums |
| Government hub | Services grid uses adaptive minimum width |
| Documents | Scroll actions now move to real sections instead of doing nothing |
| Bottom tab overlap | Major scroll screens reserve tab bar space with `tabBarScrollReserve` or clear bottom spacer |

## Required Manual QA

Must verify on physical/simulator devices:
- No title clipping in category cards on iPhone SE.
- No bottom content hidden by tab bar in city/province/detail screens.
- No card text overlap in Russian and Dutch.
- Landscape orientation on iPhone and iPad.
- Dynamic Type Large and Accessibility Large.

Result: Static pass, runtime unverified.
