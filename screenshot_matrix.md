# Screenshot matrix

Folders:

- `QA_Baseline_Screenshots/` — five pre-change captures; initial automation also documented onboarding/launch timing limitations.
- `Runtime_Screenshots/` — generated iPhone 15 RU/NL Default/Accessibility XXXL filenames.

Validated captures:

| Device | Language | Text | Screens | Status |
|---|---|---|---|---|
| iPhone 15 QA | Russian | Default | Home, Guide, Map, Saved, More | PASS |
| iPhone 15 QA | Dutch | Default | five files generated | NOT TESTED |
| iPhone 15 QA | Russian | Accessibility XXXL | five files generated | NOT TESTED |
| iPhone 15 QA | Dutch | Accessibility XXXL | five files generated | NOT TESTED |
| iPhone SE QA | RU/NL | Default/AXXXL | none | NOT TESTED |
| iPhone 17 Pro | RU/NL | Default/AXXXL | none | NOT TESTED |
| iPhone 17 Pro Max | RU/NL | Default/AXXXL | none | NOT TESTED |

Generated files are not automatically treated as valid evidence: early captures showed blank launch frames when taken before root rendering. Only the five Russian default captures were re-captured after a full launch wait and visually inspected.

