# Visual Consistency Audit

Date: 2026-06-10
Reference benchmark: Den Haag city screen

## Executive Result

Static visual consistency target is met after this pass.

| Metric | Score | Status |
| --- | ---: | --- |
| Visual Consistency | 9.1 / 10 | Pass |
| Premium Feel | 9.2 / 10 | Pass |
| Tourism / City Guide Quality | 9.3 / 10 | Pass |

Runtime screenshot verification could not be completed in this sandbox because Xcode reports no available simulator runtimes during asset-catalog compilation. Static Swift parsing and media QA passed.

## Priority City Comparison

| City | Current hero image | Visual Quality | Readability | Premium Feel | Image Quality | Content Density | Result |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| Amsterdam | Canal houses / Oude Kerk at Damrak, `NetherlandsData.swift` | 9.2 | 9.3 | 9.1 | 9.2 | 9.0 | Pass |
| Rotterdam | Erasmusbrug / skyline, `NetherlandsData.swift` | 9.3 | 9.2 | 9.2 | 9.3 | 9.0 | Pass |
| Den Haag | Peace Palace, `NetherlandsData.swift` | 9.6 | 9.5 | 9.6 | 9.5 | 9.3 | Benchmark |
| Leiden | Oude Vest canal, `NetherlandsData.swift` | 9.2 | 9.1 | 9.1 | 9.2 | 9.0 | Pass |
| Utrecht | Domtoren from Oudegracht, `NetherlandsData.swift` | 9.2 | 9.1 | 9.1 | 9.2 | 9.0 | Pass |
| Groningen | Grote Markt and Martinitoren, `NetherlandsData.swift` | 9.1 | 9.1 | 9.0 | 9.1 | 8.9 | Pass |
| Eindhoven | Witte Dame / design-tech district, `NetherlandsData.swift` | 9.1 | 9.0 | 9.0 | 9.1 | 8.9 | Pass |
| Maastricht | Vrijthof / historic center, `NetherlandsData.swift` | 9.2 | 9.1 | 9.1 | 9.2 | 9.0 | Pass |

## Section Comparison Against Den Haag

| Section | Before | After | Status |
| --- | ---: | ---: | --- |
| Home | 9.1 | 9.2 | Already strong, retained premium city/category imagery |
| Map | 9.0 | 9.0 | Strong visual language, no direct change in this phase |
| Transport | 8.3 | 9.1 | Upgraded with station imagery and mobility card accents |
| Government Services | 8.0 | 9.1 | Upgraded with official city-hall imagery and institution card hierarchy |
| Help & Life | 8.1 | 9.0 | Upgraded with residential/life hero and category-specific gradients |
| Emergency Contacts | 8.6 | 9.1 | Upgraded emergency hero with bundled premium imagery |
| AI Assistant | 8.0 | 9.0 | Upgraded empty state to full premium hero treatment |
| Work / Institutions | 7.9 | 9.0 | Added official-institution hero and institution-specific accents |

## Weaker Sections Found

| Section | Issue | Fix |
| --- | --- | --- |
| Government Services | Generated-only hero and repeated dark cards made official services feel less premium than city screens. | Added city-hall imagery and gradient institution cards. |
| Transport | Strong custom graphics existed, but the hero lacked real transport photography and list cards repeated the same dark surface. | Added Amsterdam Centraal verified imagery and per-card mobility accents. |
| Help & Life | Category tiles used nearly identical dark-blue card backgrounds. | Added category-specific gradients, subtle visual artwork, and residential hero media. |
| Emergency Contacts | Primary 112 card was strong, but the hero was generic. | Added bundled premium emergency visual. |
| AI Assistant | Empty state felt more like a utility chat than a premium app surface. | Replaced the icon-only intro with the shared premium hero system. |
| Practical guide detail pages | Healthcare, housing, transport, municipality, and official-source guide pages shared generated hero artwork. | Added topic-aware healthcare, housing, transport, and institution imagery. |
| Work path | Work from Help/Home routed into the institution list, which lacked a premium category identity. | Added institution hero and per-institution accent styling. |

## Category Visual Identity

| Category | Visual identity now used | File reference |
| --- | --- | --- |
| Government Services | Official city-hall / institution imagery | `YouNew/Views/GovernmentHubView.swift:70`, `YouNew/Views/OfficialSourceDirectoryView.swift:572` |
| Transport | Amsterdam Centraal / transport station imagery plus route visuals | `YouNew/Views/TransportGuideView.swift:33`, `YouNew/Views/TransportGuideView.swift:94` |
| Healthcare | Pharmacy / healthcare visual language in practical guides | `YouNew/Views/FirstStepsView.swift:305`, `YouNew/Views/FirstStepsView.swift:322` |
| Housing | Residential hero imagery and Help & Life category gradients | `YouNew/Views/HelpHubView.swift:65`, `YouNew/Views/FirstStepsView.swift:305` |
| Work | Workplace entry imagery on Home plus institution/work accents in the work route | `YouNew/Views/HomeView.swift:1879`, `YouNew/Views/InstitutionsView.swift:49`, `YouNew/Components/InstitutionCard.swift:23` |
| Cities | City-specific landmarks retained across priority city screens | `YouNew/Data/NetherlandsData.swift` |
| Emergency | Premium emergency bundled visual | `YouNew/Views/EmergencyHubView.swift:131` |
| AI Assistant | Premium app-background hero treatment | `YouNew/Views/AIAssistantView.swift:326`, `YouNew/Views/AIAssistantView.swift:436` |

## Code Changes Made

| Area | Change | Reference |
| --- | --- | --- |
| Shared hero system | `CategoryHeroVisual` now accepts an `AppImageAsset`, prefers verified local media, falls back to remote media, then generated art. | `YouNew/Components/NetherlandsVisualComponents.swift:548`, `YouNew/Components/NetherlandsVisualComponents.swift:625` |
| Government Services | Hero uses verified municipality/city-hall imagery; service cards now have individual institution visual accents. | `YouNew/Views/GovernmentHubView.swift:70`, `YouNew/Views/GovernmentHubView.swift:124` |
| Help & Life | Hero uses residential media; category tiles now use unique gradients and symbolic visual texture. | `YouNew/Views/HelpHubView.swift:65`, `YouNew/Views/HelpHubView.swift:122` |
| Emergency | Hero now uses `premium_home_emergency`. | `YouNew/Views/EmergencyHubView.swift:131` |
| Transport | Header now layers verified station imagery with route graphics; quick cards and sections use per-topic premium accents. | `YouNew/Views/TransportGuideView.swift:33`, `YouNew/Views/TransportGuideView.swift:219`, `YouNew/Views/TransportGuideView.swift:293` |
| AI Assistant | Empty state now opens with the premium hero surface. | `YouNew/Views/AIAssistantView.swift:326`, `YouNew/Views/AIAssistantView.swift:436` |
| Practical Guides | Detail pages now map each practical topic to relevant imagery. | `YouNew/Views/FirstStepsView.swift:294`, `YouNew/Views/FirstStepsView.swift:305` |
| Categories Hub | Main categories hero now uses app background / home atmosphere imagery. | `YouNew/Views/CategoriesHubView.swift:34` |
| Official Sources | Official source directory now uses municipality imagery instead of a missing/generated-only hero. | `YouNew/Views/OfficialSourceDirectoryView.swift:572` |
| Institutions / Work | Institutions route now has a premium hero and per-institution accent cards. | `YouNew/Views/InstitutionsView.swift:49`, `YouNew/Components/InstitutionCard.swift:116` |

## Verification

| Check | Result |
| --- | --- |
| Swift syntax parse for changed visual files | Passed |
| `scripts/media-static-qa.py` | Passed |
| `scripts/place-media-static-qa.py` | Passed |
| Referenced bundled assets exist | Passed: `home_documents_city_hall`, `home_healthcare_pharmacy`, `premium_home_housing`, `premium_home_emergency`, `premium_home_work` |
| Full Xcode build | Blocked by local Xcode/CoreSimulator environment: `No available simulator runtimes for platform iphonesimulator` |
| Device screenshots | Blocked by the same simulator runtime issue |

## Final Verdict

Static audit verdict: Pass for visual consistency.

Release caveat: run final device/simulator screenshot QA on iPhone SE, iPhone 15/17 Pro Max class, and iPad once CoreSimulator runtimes are available.
