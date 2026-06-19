# City Release Report

Date: 2026-06-11

## Result

Status: PASS static, RUNTIME SCREENSHOTS NOT AVAILABLE

## Cities Checked

| City | Data Present | Media QA | Municipality/Official Link | Places/Transport/Services | Status |
| --- | --- | --- | --- | --- | --- |
| Amsterdam | Yes | Pass | Present | Present | Pass static |
| Rotterdam | Yes | Pass | Present | Present | Pass static |
| Den Haag | Yes | Pass | Present | Present | Pass static |
| Leiden | Yes | Pass | Present | Present | Pass static |
| Utrecht | Yes | Pass | Present | Present | Pass static |
| Groningen | Yes | Pass | Present | Present | Pass static |
| Maastricht | Yes | Pass | Present | Present | Pass static |
| Eindhoven | Yes | Pass | Present | Present | Pass static |
| Arnhem | Yes | Pass | Present | Present | Pass static |
| Nijmegen | Yes | Pass | Present | Present | Pass static |
| Zwolle | Yes | Pass for province city cards | Present | Basic present | Pass static |
| Haarlem | Yes | Pass | Present | Present | Pass static |

## Media QA Results

`image-runtime-data-qa.py` passed:
- Curated place images checked: 42
- Province city cards checked: 21
- Historical figure portraits checked: 10

Also passed:
- `media-static-qa.py`
- `place-media-static-qa.py`
- `history-media-static-qa.py`

## Gate Impact

No static duplicate/wrong-image blocker remains. Runtime screenshots still required before public release, especially for previously reported city image regressions.
