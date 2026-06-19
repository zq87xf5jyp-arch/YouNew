# YouNew Fact Accuracy Audit

Audit date: 2026-06-13  
Scope: static source review of high-risk factual content. Runtime link opening was not performed. Facts involving law, benefits, tax, immigration, healthcare, fines, and emergency services must be treated as time-sensitive.

## Source Standard

Official or recognized-source baseline used for this audit:

- BSN / BRP: https://www.rijksoverheid.nl/onderwerpen/persoonsgegevens/burgerservicenummer-bsn and https://www.rijksoverheid.nl/onderwerpen/privacy-en-persoonsgegevens/basisregistratie-personen-brp
- DigiD: https://www.digid.nl/en
- Municipalities: https://www.government.nl/topics/municipalities
- Immigration and work: https://ind.nl/en/work, https://www.uwv.nl/en/work-permit, https://www.government.nl/topics/immigration-to-the-netherlands/question-and-answer/coming-to-the-netherlands-to-work
- Taxes and benefits: https://www.belastingdienst.nl, https://www.toeslagen.nl, https://www.government.nl/topics/minimum-wage
- Rent and tenant disputes: https://www.huurcommissie.nl
- Transport: https://www.ns.nl/en, https://9292.nl/en, https://www.ovpay.nl/en, https://www.ov-chipkaart.nl
- Emergency: https://www.112.nl, https://www.politie.nl/en/contact, https://www.113.nl, https://veiligthuis.nl, https://www.fraudehelpdesk.nl
- Integration and education: https://www.inburgeren.nl/en and https://www.duo.nl
- Legal help: https://www.juridischloket.nl

## High-Risk Findings

| Severity | Screen / Content | Evidence | Risk | Required Fix |
|---|---|---|---|---|
| Critical | Documents > BSN | `GuideContentView.swift:167` says EU citizens can use expat centers and get BSN the same day | Too broad. Expat center access is city/program-specific and not a national default | Reword as city-specific option; require municipality/expat-center source per city |
| Critical | Documents > BSN | `GuideContentView.swift:169` says BSN is not issued without a permanent Dutch address | Too absolute. BRP registration and RNI/non-resident registration paths differ by stay/status | Replace with source-backed distinction: BRP for residents, RNI for non-residents/short stay where applicable |
| High | Housing > Huurtoeslag | `GuideContentView.swift:273` uses 2025 rent threshold | Date-sensitive and stale for a 2026 release | Pull current Toeslagen threshold or remove amount and link to official calculator |
| High | Healthcare > Insurance | `GuideContentView.swift:420` and `GuideContentView.swift:425` include 4 months and 2025 eigen risico | Core rule is likely stable, but amount/date are release-sensitive | Verify against Government.nl/CAK and update review date to 2026 or remove amount |
| High | Work > Salary and Taxes | `GuideContentView.swift:638` uses 2024 Box 1 tax figures | Stale for current 2026 release context | Replace numeric rates with Belastingdienst link or update with current-year values |
| High | Work > Permits | `GuideContentView.swift:596` mentions highly skilled migrant salary threshold without amount | Better than stale numeric values, but still status-sensitive | Keep non-specific wording and point to IND recognized sponsor and current threshold pages |
| Medium | Emergency > Contacts | `GuideContentView.swift:840` lists 0800-0113, Veilig Thuis, Fraudehelpdesk | Contacts must be periodically verified | Add `lastVerified` metadata and official link per contact |
| Medium | Transport articles | `GuideContentView.swift:345`, `GuideContentView.swift:393` source OV/NS routes | Some product pages and subscriptions change | Keep official links and avoid exact product pricing unless refreshed |
| Medium | Fines articles | `GuideContentView.swift:518`, `GuideContentView.swift:566` link OM/CJIB | Fine amounts can change yearly | Keep amount-free summaries unless backed by current OM table |
| Medium | Culture/history | Netherlands history/culture screens | Educational content is lower risk but still needs source separation | Separate fact sources from media credits |

## Fact Ownership Map

| Domain | Canonical Content Owner | Official Source Requirement |
|---|---|---|
| BSN, DigiD, BRP | DOCUMENTS | Rijksoverheid, municipality pages, DigiD |
| Municipality registration | GOVERNMENT + DOCUMENTS reference | Government.nl municipalities and local gemeente |
| Residence/work permits | WORK | IND, UWV, Government.nl |
| Payroll, tax, benefits | MONEY | Belastingdienst, Toeslagen, Government.nl |
| Rent, deposits, tenant rights | HOUSING | Huurcommissie, Rijksoverheid, Juridisch Loket |
| Health insurance, huisarts, urgent care | HEALTHCARE | Government.nl, CAK, health insurer official pages, huisarts/huisartsenpost official pages |
| Emergency numbers | EMERGENCIES | 112.nl, Politie, 113, Veilig Thuis |
| Public transport | TRANSPORT | NS, 9292, OVpay, OV-chipkaart |
| Education, inburgering, KNM | EDUCATION / LANGUAGE | DUO, Inburgeren.nl |
| City/province facts | CITIES / PROVINCES | Municipality, province, CBS where numeric |
| LGBTQ+ support | SUPPORT | COC, municipality support pages, official emergency/safety links |
| History/culture | HISTORY / CULTURE | Museum, archive, official tourism/cultural institutions |

## Metadata Gaps

`GuideArticle` supports `updatedDate`, `readingMinutes`, and `isOfficial`, but older articles do not consistently use those fields. The following sections must be normalized before a public release:

- Documents articles at `GuideContentView.swift:159`, `GuideContentView.swift:181`, `GuideContentView.swift:204`.
- Housing articles at `GuideContentView.swift:242`, `GuideContentView.swift:266`, `GuideContentView.swift:289`.
- Transport articles at `GuideContentView.swift:327`, `GuideContentView.swift:351`, `GuideContentView.swift:375`.
- Healthcare articles at `GuideContentView.swift:414`, `GuideContentView.swift:438`, `GuideContentView.swift:462`.
- Fines articles at `GuideContentView.swift:501`, `GuideContentView.swift:524`, `GuideContentView.swift:548`.

Later Work, Integration, and Emergency articles already include metadata around `GuideContentView.swift:611`, `GuideContentView.swift:653`, `GuideContentView.swift:754`, and `GuideContentView.swift:855`.

## Trust Rules

1. Do not show outdated numeric thresholds inline unless they include a current-year official source.
2. Do not imply a city-specific process is national.
3. Do not let AI answer final legal, medical, tax, immigration, or benefits decisions.
4. Every article must show one official or recognized source link before public release.
5. Every article with date-sensitive content must have an updated date no older than the current release cycle.

## Fact Accuracy Verdict

Current status: FAIL for public release, WARNING for internal TestFlight.

The app has many official links, but several high-risk statements are too absolute or date-sensitive. Internal TestFlight can proceed if testers are told that factual content is under review. Public release requires a 2026 official-source refresh.
