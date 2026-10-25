# YouNew practical-guide QA — mandatory 20-topic set

Date: 2026-08-18 (Europe/Amsterdam)  
Scope: source-only editorial preparation. No guide was published, projected to runtime, deployed or sent to an external system.

## Outcome

**PARTIAL for guide production; NO-GO for publication.** The staging collection now contains the exact 20 scenarios required by the monetization master prompt, each as a source-backed schema-v2 QA packet. Every packet has a short answer, audience and applicability context, prerequisites, documents, sourced time/cost handling, numbered steps, warnings, checklist, three answered FAQ records, escalation information, official sources, related guides, next actions, freshness metadata and SEO metadata.

The publication boundary remains closed. All 20 packets have `status: qa`, `reviewer: null`, medium confidence, a pending publication gate and no verified guide media. No reviewer or evidence-registry identity was invented.

## Canonical topic set

1. Getting a BSN and registering at a municipality.
2. Applying for DigiD.
3. Navigating residence permits.
4. Arranging Dutch health insurance.
5. Finding a huisarts.
6. Emergency numbers and urgent help.
7. Finding long-term housing.
8. Finding temporary housing.
9. Handling landlord problems and housing defects.
10. Finding work with limited Dutch.
11. Employment contract and payslip basics.
12. Taxes and allowances.
13. Getting help with debt.
14. Opening a Dutch bank account.
15. Choosing a SIM card and home internet.
16. Using public transport.
17. Getting a foreign diploma recognised.
18. Dutch language courses and civic integration.
19. Family, children and school registration.
20. Pets and veterinary care.

Six non-mandatory topics from the earlier Priority-1 queue remain available as legacy research but are no longer emitted by the canonical 20-guide staging builder: municipality registration as a separate duplicate, general study, student-only housing, moving municipality, discrimination reporting and starting a business.

## Evidence

| Check | Result |
|---|---:|
| Canonical QA packets | 20/20 |
| Research-backed canonical topics | 20/20 |
| Sourced fact assignments | 120 |
| Unique research source IDs | 71 |
| Numbered steps | 120 |
| Checklist records | 120 |
| Answered FAQ records | 60 |
| Guide official-source assignments | 91 |
| Unique guide source URLs | 69 |
| Packets with verified date | 20/20 |
| Packets with official sources | 20/20 |
| Named human reviewers | 0/20 |
| Verified guide media | 0/20 |
| Passed publication gates | 0/20 |
| Published staging guides | 0/20 |
| Production-ready full guides | 0/20 |

Commands:

```text
python3 scripts/priority-research-static-qa.py
python3 scripts/build-priority-1-editorial-handoff.py --check
python3 scripts/build-practical-guide-qa-packets.py --check
python3 scripts/practical-guide-static-qa.py
python3 scripts/content-readiness-audit.py --check
```

The checks validate exact topic identity and order, source/fact closure, approved official hostnames, HTTPS, date chronology, schema bounds, per-block source IDs, no fabricated reviewer, no passed gate, no public projection of QA content, locale fail-closed behaviour and importer rejection of a packet whose status alone is changed to `published`.

## Changed

- `DataProject/research/monetization-practical-guide-addendum-2026-08-18.json` adds official-source research for temporary housing, debt help, telecom, diploma recognition, family/school and pets/veterinary care.
- `scripts/build-priority-1-editorial-handoff.py` joins the existing research inventories with the addendum and emits one deterministic review queue.
- `scripts/build-practical-guide-qa-packets.py` emits the exact canonical topic set in prompt order and keeps every publication control fail-closed.
- `DataProject/staging/practical-guides-wave-1.json` contains the generated QA packets and remains outside runtime/publication inputs.
- `scripts/priority-research-static-qa.py` validates the addendum and separates canonical coverage from retained legacy research.
- `scripts/practical-guide-static-qa.py` validates the exact required topic set and the complete schema-v2 content contract.
- `DataProject/quality/priority-1-editorial-handoff.json` and `.md` provide deterministic editorial assignment evidence.
- `DataProject/quality/content-readiness-matrix.json` and `.md` continue to report zero production-ready guides.

## Metrics before → after

| Metric | Before correction | After correction |
|---|---:|---:|
| Exact mandatory topic coverage | 14/20 | 20/20 |
| Mandatory topics without a dedicated dossier | 6 | 0 |
| Source-backed canonical schema-v2 QA packets | 14 | 20 |
| Published full guides | 0 | 0 |
| Human-reviewed guides | 0 | 0 |

## Remaining gaps

1. A named human editor or qualified subject reviewer must validate every guide; medical, immigration, housing, employment, tax/debt and animal-entry wording need the relevant specialist.
2. Each guide needs a dedicated asset with verified provenance and authored alt text.
3. The reviewer and guide-evidence registries are empty, so no publication gate can pass.
4. Live fees, deadlines, provider availability, municipality routes and institution-specific branches must be rechecked during review.
5. QA packets are deliberately absent from the public runtime and cannot improve the production 50-query scorecard until review and publication are separately approved.

## Risks

- Treating automated source mapping as human approval would overstate legal, medical, financial and immigration confidence.
- Publishing the new telecom or veterinary routes with provider recommendations would introduce unverified commercial claims.
- Reusing one city's housing, debt or school procedure as a national answer would create an invisible location substitution.
- Copying time-sensitive fees or processing periods without live revalidation would create false precision.

## Decision

**PARTIAL.** The exact mandatory content set is now reviewable and mechanically complete. **NO-GO for runtime projection or publication** until named review, media, evidence registration and a passed publication gate exist.

## Next smallest useful action

Assign one named reviewer per risk domain, review the six addendum topics first, record corrections in the evidence registry and rerun the same fail-closed checks. In parallel, the QA packets may be used only as private search-evaluation candidates; they must not enter the public index.
