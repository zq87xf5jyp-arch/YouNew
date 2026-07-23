# YouNew content readiness matrix

Evidence date: **2026-07-23**. This is a read-only local audit; no live URL check was performed.

## Outcome

**NOT PRODUCTION READY for the attached 100%-content brief.** The repository has substantial governed summary inventory, but no practical guide passes the fail-closed production contract.

- Governed records: **450**; effectively published: **188**.
- Guide-capable material records: **277**; effectively published material records: **15**.
- Material lifecycle states: **{"published": 15, "qa": 262}**.
- Public guides: **15 summary / 0 full**.
- Editorial scaffolds: **20 draft/review**; production-ready guides: **0**.
- Published FAQ: **0/300**; staged draft FAQ: **0**; staged search questions (not FAQ): **21**.
- Governed topic families with zero inventory records: **0**.
- Governed topic families with zero effective published records: **36/36**.
- Repository content-target coverage: **262/3000 (8.7%)**; production-ready: **0/3000 (0.0%)**.
- Stale governed records: **10**; stale guide-capable records: **0**.
- Audit integrity/reconciliation: **PASSED**.

## Denominators and interpretation

Coverage is not an invented score. Target-level coverage uses `DataProject/coverage-targets.json`; topic-family coverage uses the minimum-per-family values in `DataProject/coverage-dimensions.json`. Percentages are capped at 100%, so surplus in one family cannot hide an empty family. Production readiness uses the stricter brief contract listed in the JSON `definitions.production_ready` field.

## Repository target coverage

| Target | Materials | Target denominator | Coverage | Published | Ready full guides | Production ready |
| --- | --- | --- | --- | --- | --- | --- |
| government | 102 | 1000 | 10.2% | 0 | 0 | 0.0% |
| housing | 40 | 500 | 8.0% | 0 | 0 | 0.0% |
| healthcare | 40 | 500 | 8.0% | 0 | 0 | 0.0% |
| transport | 40 | 500 | 8.0% | 0 | 0 | 0.0% |
| education | 40 | 500 | 8.0% | 0 | 0 | 0.0% |

## Proposed priority coverage

P1/P2/P3 is a report-only editorial proposal over existing topic-family keys. The brief supplies examples but no canonical priority field, so this audit does not write the classification into content.

| Priority | Covered families | Family coverage | Covered slots | Slot coverage | Ready slots | Production ready |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | 22/22 | 100.0% | 160/160 | 100.0% | 0/160 | 0.0% |
| P2 | 10/10 | 100.0% | 70/70 | 100.0% | 0/70 | 0.0% |
| P3 | 4/4 | 100.0% | 30/30 | 100.0% | 0/30 | 0.0% |

## Governed topic-family matrix

| P | Target | Family | Materials | Minimum | Coverage | Published | Full | Ready | Ready % | Draft associations |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2 | education | schools | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | education | higher-education | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | education | duo | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | education | civic-integration | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | transport | rail-travel | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | transport | public-transport-payment | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 2 | transport | cycling | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 3 | transport | parking | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | healthcare | primary-care | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | healthcare | health-insurance | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 2 | healthcare | hospitals-specialists | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | healthcare | emergency-care | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | housing | renting | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 3 | housing | home-buying | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | housing | tenant-rights | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 2 |
| 2 | housing | utilities | 10 | 10 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | government | identity-registration | 6 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 3 |
| 1 | government | digital-government | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | immigration-residency | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | citizenship-integration | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | taxes | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 2 |
| 1 | government | benefits-allowances | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | employment-unemployment | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 2 | government | business-entrepreneurship | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | health-insurance | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 2 |
| 2 | government | family-parenthood | 6 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | government | education-finance | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 2 | government | driving-transport | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 2 | government | documents-certificates | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 2 | government | pensions-social-security | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 1 | government | housing-local-services | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | justice-legal-aid | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 1 | government | safety-emergencies | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 1 |
| 3 | government | voting-democracy | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 2 | government | consumer-privacy | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |
| 3 | government | death-inheritance | 5 | 5 | 100.0% | 0 | 0 | 0 | 0.0% | 0 |

## Observed canonical material categories

This table uses the observed category count as the denominator for summary-field completeness; it does not claim that the observed count is the desired topic coverage target.

| WP | Category | Denominator | Base complete | Completeness | Published | Ready | No image | No steps | No FAQ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| WP-01 | benefits | 5 | 5/5 | 100.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | business | 5 | 5/5 | 100.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | certificates | 3 | 3/3 | 100.0% | 0 | 0 | 3 | 3 | 3 |
| WP-01 | citizenship | 3 | 3/3 | 100.0% | 0 | 0 | 3 | 3 | 3 |
| WP-01 | civil_status | 4 | 4/4 | 100.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | consumer_rights | 4 | 4/4 | 100.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | death | 2 | 2/2 | 100.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | democracy | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | digital_government | 4 | 4/4 | 100.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | digital_identity | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | document_legalisation | 2 | 2/2 | 100.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | driving_documents | 4 | 4/4 | 100.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | driving_licence | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | education_finance | 5 | 5/5 | 100.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | elections | 4 | 4/4 | 100.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | emergencies | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | employment | 5 | 5/5 | 100.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | family_leave | 2 | 2/2 | 100.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | healthcare | 4 | 4/4 | 100.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | healthcare_registration | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | housing | 3 | 3/3 | 100.0% | 0 | 0 | 3 | 3 | 3 |
| WP-01 | identification_documents | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | identity | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | immigration | 5 | 5/5 | 100.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | inheritance | 3 | 3/3 | 100.0% | 0 | 0 | 3 | 3 | 3 |
| WP-01 | integration | 2 | 2/2 | 100.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | justice | 4 | 4/4 | 100.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | legal_aid | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | local_services | 2 | 2/2 | 100.0% | 0 | 0 | 2 | 2 | 2 |
| WP-01 | municipal_registration | 4 | 4/4 | 100.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | privacy_data | 1 | 1/1 | 100.0% | 0 | 0 | 1 | 1 | 1 |
| WP-01 | safety | 4 | 4/4 | 100.0% | 0 | 0 | 4 | 4 | 4 |
| WP-01 | social_security | 5 | 5/5 | 100.0% | 0 | 0 | 5 | 5 | 5 |
| WP-01 | taxes | 5 | 5/5 | 100.0% | 0 | 0 | 5 | 5 | 5 |
| WP-02 | home_buying | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-02 | renting | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-02 | tenant_rights | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-02 | utilities | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-03 | emergency_care | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-03 | health_insurance | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-03 | hospitals_specialists | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-03 | primary_care | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-04 | cycling | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-04 | parking | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-04 | public_transport_payment | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-04 | rail_travel | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-05 | civic_integration | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-05 | duo | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-05 | higher_education | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-05 | schools | 10 | 10/10 | 100.0% | 0 | 0 | 10 | 10 | 10 |
| WP-06 | civil-affairs | 2 | 2/2 | 100.0% | 2 | 0 | 0 | 2 | 2 |
| WP-06 | civil-status | 2 | 2/2 | 100.0% | 2 | 0 | 0 | 2 | 2 |
| WP-06 | driving-documents | 1 | 1/1 | 100.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | identity-documents | 1 | 1/1 | 100.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | municipal-housing-information | 2 | 2/2 | 100.0% | 2 | 0 | 0 | 2 | 2 |
| WP-06 | municipal-housing-service | 1 | 1/1 | 100.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | municipal-taxes | 1 | 1/1 | 100.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | parking | 1 | 1/1 | 100.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | public-space | 1 | 1/1 | 100.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | social-housing-platform | 1 | 1/1 | 100.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | tenant-support | 1 | 1/1 | 100.0% | 1 | 0 | 0 | 1 | 1 |
| WP-06 | waste-recycling | 1 | 1/1 | 100.0% | 1 | 0 | 0 | 1 | 1 |

## Quality gaps

- Material records without an official parent source: **0/277**.
- Material records without a verified image: **262/277**.
- Material records without published steps: **277/277**.
- Material records without published FAQ: **277/277**.
- Staged guides without reviewer, verified date, official guide sources, steps and FAQ: **20/20**, **20/20**, **20/20**, **20/20**, **20/20**.
- Staged guides with no canonical source entity IDs: **3** (guide.finding-work, guide.opening-a-dutch-bank-account, guide.student-housing).
- Conservative placeholder hits: canonical **0**, staged guides **0**.
- Missing canonical source IDs referenced by scaffolds: **0** (none).
- Stale governed records under `freshness-policy.json`: **10** (event.worldpride-amsterdam-2026-pride-walk, event.worldpride-amsterdam-2026-pride-park, event.worldpride-amsterdam-2026-open-air-film-festival, event.worldpride-amsterdam-2026-senior-pride-concert, event.worldpride-amsterdam-2026-canal-parade, event.worldpride-amsterdam-2026-unity-concert, event.worldpride-amsterdam-2026-human-rights-conference, event.worldpride-amsterdam-2026-worldpride-village, event.worldpride-amsterdam-2026-worldpride-march, event.worldpride-amsterdam-2026-closing-concert).
- Scenario interpretation: The canonical guide schema has no separate scenario field. numbered_steps is used as the auditable procedural/scenario proxy; no published material has numbered steps.

## Duplicates

- Canonical ID exact groups / near pairs: **0 / 0**.
- Canonical title exact groups / near pairs: **0 / 0**.
- Staged guide ID exact groups / near pairs: **0 / 0**.
- Staged guide title exact groups / near pairs: **0 / 0**.
- Staged guide slug exact groups / near pairs: **0 / 0**.

Candidate pairs are evidence for editorial review, not automatic deletion. Full pair details are in the JSON output.

## Runtime reconciliation

- Effective published → runtime: **0 missing / 0 unexpected**.
- Runtime → public web: **0 missing / 0 unexpected**.
- Practical guides in runtime/public: **0 / 0**.

## Existing link-health evidence

The repository's existing link report checked **2560** URLs at **2026-07-22T08:24:03.047474+00:00**: **0 confirmed broken**, **596 access-restricted**, and **29 transient failures**. This audit imported those counts but did not perform a new network check.

## Audience-path gap

Production-ready explicit audience coverage is **0/6 (0.0%)**. All six brief paths are supported by the current audience_profiles enum, but no published practical guide carries audience metadata.

## Smallest useful remediation

1. Keep the 20 scaffolds in draft; assign canonical source entities to every scaffold before factual writing.
2. Complete and review one P1 guide end-to-end, including official source IDs for every fact, reviewer, verification date, verified media, steps and FAQ; publish only through the existing release pipeline.
3. Repeat P1 family by family. Do not interpret the 100% minimum-family summary inventory as 100% public or production readiness.
4. Assign and review explicit audience profiles before claiming full user-path coverage.
5. Run the existing live link/data-health check alongside this audit before any release; this script intentionally performs no network mutations or requests.

## Reproduction

```bash
python3 scripts/content-readiness-audit.py --as-of 2026-07-23 --check
```
