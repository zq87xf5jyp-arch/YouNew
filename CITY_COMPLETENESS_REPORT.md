# City Completeness Report

Date: 2026-06-11

Static sources checked: `YouNew/Data/NetherlandsData.swift`, `YouNew/Views/ProvinceDirectoryView.swift`, media QA scripts, image runtime data QA script.

## City Matrix

| City | Hero | Unique Media QA | Facts/History | Places | Municipality/Official Link | Transport/Housing/Services | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Amsterdam | Present | Pass | Present | Present | Amsterdam / amsterdam.nl | Present | Pass static |
| Rotterdam | Present | Pass | Present | Present | Rotterdam / rotterdam.nl | Present | Pass static |
| Den Haag | Present | Pass | Present | Binnenhof/Peace Palace/Scheveningen/Mauritshuis expected in data QA | Den Haag / denhaag.nl | Present | Pass static |
| Leiden | Present | Pass | Present | Present | Leiden / leiden.nl | Present | Pass static |
| Utrecht | Present | Pass | Present | Present | Utrecht / utrecht.nl | Present | Pass static |
| Groningen | Present | Pass | Present | Martinitoren present | Groningen / gemeente.groningen.nl | Present | Pass static |
| Maastricht | Present | Pass | Present | Vrijthof/St. Servatius present | Maastricht / maastricht.nl | Present | Pass static |
| Eindhoven | Present | Pass | Present | Philips/technology/design content present | Eindhoven / eindhoven.nl | Present | Pass static |
| Nijmegen | Present | Pass | Present | Waalbrug/Valkhof present | Nijmegen / nijmegen.nl | Present | Pass static |
| Arnhem | Present | Pass | Present | John Frost Bridge present | Arnhem / arnhem.nl | Present | Pass static |
| Zwolle | Present in province catalog | Pass for province city cards | Basic province catalog present | Requires runtime detail review | Zwolle / zwolle.nl | Basic present | Pass static, runtime needed |
| Haarlem | Present | Pass | Present | Grote Markt/Sint-Bavokerk present | Haarlem / haarlem.nl | Present | Pass static |

## Fixes Applied

| Issue | Fix |
| --- | --- |
| Haarlem/cloud and duplicate-image regressions were previously guarded by image runtime data QA | Re-ran `image-runtime-data-qa.py`; it passed with 42 curated place images and 21 province city cards checked |
| Missing city-related onboarding/assistant image assets | Replaced missing landmark asset names with bundled category assets |

## Verification

Passed:
- `media-static-qa.py`
- `place-media-static-qa.py`
- `history-media-static-qa.py`
- `image-runtime-data-qa.py`

Runtime screenshots were not captured in this pass.
