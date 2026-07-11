# Localization report

Map result summary moved to `Map.xcstrings` with English, Dutch, and Russian templates. Russian count selection supports 0, 1, 2–4, 5+, 11–14, and 21-style endings without assembling a noun manually.

Evidence:

- Runtime Russian default: `26 мест в г. Лейден` — PASS.
- String Catalog presence and build: PASS.
- Existing localization static gate: PASS after explicit English/Dutch/Russian branches.
- Runtime cases 0, 1, 2, 4, 5, 11, and 21: NOT TESTED.
- Dutch runtime visual inspection: NOT TESTED.

