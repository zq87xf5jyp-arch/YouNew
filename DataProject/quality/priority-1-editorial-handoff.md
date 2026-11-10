# Priority-1 editorial handoff

Generated for: `2026-08-18`

> **Non-publishing evidence.** Every item is `qa_packet` or `blocked`; publication is not authorized. The procedural interpretation remains subject to named human review.

## Executive status

- Canonical guide QA packets: **20**
- Source-backed QA packets: **20**
- Blocked without a matching dossier: **0**
- Schema v2 publication-ready guides: **0**
- Unique sourced facts available for drafting: **120**
- Unique official source IDs: **71**
- Answered FAQ records still missing: **0**
- Numbered steps still missing: **0**
- Guide assets with verified alt text still missing: **20**
- Human reviews still missing: **20**

Assignment counts can exceed unique counts because a sourced fact or source can support more than one guide.

## Workflow

`Draft→QA→Reviewer→Publish`

1. **Draft**
   - Entry: Canonical scaffold exists and research remains non-publishing.
   - Exit: All factual blocks retain fact IDs and official source IDs; required schema v2 fields are drafted; locality and volatility gaps are explicit.
2. **QA**
   - Entry: Draft exit criteria are met.
   - Exit: Schema, factual sources, links, language, media, duplicate-content, and accessibility checks all pass with recorded evidence.
3. **Reviewer**
   - Entry: QA gate passed; no unresolved factual or locality blocker remains.
   - Exit: A named human editor or relevant subject-matter reviewer records identity, role, review date, and approval.
4. **Publish**
   - Entry: Reviewer approval and a passed publication gate exist; verified dates and official links are current.
   - Exit: Importer accepts the guide without bypassing fail-closed checks.

## Missing official research

No guide is missing a matching research dossier.

## Queue summary

| Guide | Status | Facts | Sources | Schema checks ready | FAQ missing | Steps missing | Assets missing |
|---|---:|---:|---:|---:|---:|---:|---:|
| `guide.getting-a-bsn` | qa_packet | 8 | 6 | 36/40 | 0 | 0 | 1 |
| `guide.applying-for-digid` | qa_packet | 6 | 4 | 36/40 | 0 | 0 | 1 |
| `guide.residence-permits` | qa_packet | 10 | 4 | 36/40 | 0 | 0 | 1 |
| `guide.dutch-health-insurance` | qa_packet | 5 | 4 | 36/40 | 0 | 0 | 1 |
| `guide.finding-a-huisarts` | qa_packet | 5 | 3 | 36/40 | 0 | 0 | 1 |
| `guide.emergency-numbers-and-urgent-help` | qa_packet | 5 | 3 | 36/40 | 0 | 0 | 1 |
| `guide.renting-a-home` | qa_packet | 6 | 3 | 36/40 | 0 | 0 | 1 |
| `guide.temporary-housing` | qa_packet | 6 | 4 | 36/40 | 0 | 0 | 1 |
| `guide.reporting-housing-defects` | qa_packet | 5 | 3 | 36/40 | 0 | 0 | 1 |
| `guide.finding-work` | qa_packet | 4 | 4 | 36/40 | 0 | 0 | 1 |
| `guide.understanding-an-employment-contract` | qa_packet | 5 | 3 | 36/40 | 0 | 0 | 1 |
| `guide.taxes-and-allowances` | qa_packet | 9 | 4 | 36/40 | 0 | 0 | 1 |
| `guide.debt-help` | qa_packet | 6 | 3 | 36/40 | 0 | 0 | 1 |
| `guide.opening-a-dutch-bank-account` | qa_packet | 4 | 2 | 36/40 | 0 | 0 | 1 |
| `guide.sim-card-and-home-internet` | qa_packet | 6 | 3 | 36/40 | 0 | 0 | 1 |
| `guide.using-public-transport` | qa_packet | 5 | 3 | 36/40 | 0 | 0 | 1 |
| `guide.diploma-recognition` | qa_packet | 6 | 4 | 36/40 | 0 | 0 | 1 |
| `guide.dutch-integration-exams` | qa_packet | 6 | 5 | 36/40 | 0 | 0 | 1 |
| `guide.family-children-and-school-registration` | qa_packet | 7 | 3 | 36/40 | 0 | 0 | 1 |
| `guide.pets-and-veterinary-care` | qa_packet | 6 | 4 | 36/40 | 0 | 0 | 1 |

## Per-guide audit

### Getting a BSN and registering at a municipality

- Canonical ID: `guide.getting-a-bsn`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `topic.bsn`
- Fact IDs (8): `BSN-001`, `BSN-002`, `BSN-003`, `BSN-004`, `REG-005`, `REG-006`, `REG-008`, `REG-010`
- Source IDs (6): `src.amsterdam.first-registration`, `src.amsterdam.rni`, `src.gov.brp-resident`, `src.gov.bsn-overview`, `src.nww.bsn-get`, `src.nww.rni-register`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - The guide must first ask whether the user is becoming a resident, is a short-stay non-resident, or may already have a BSN.
  - No human reviewer is assigned.

### Applying for DigiD

- Canonical ID: `guide.applying-for-digid`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `topic.digid`
- Fact IDs (6): `DIG-001`, `DIG-002`, `DIG-003`, `DIG-004`, `DIG-005`, `DIG-006`
- Source IDs (4): `src.digid.abroad`, `src.digid.activate`, `src.digid.apply`, `src.nww.rni-register`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Resident and abroad activation paths must be separated in the final guide.
  - The official application page contains two delivery-time phrasings; editorial review must retain the conservative maximum.
  - No human reviewer is assigned.

### Navigating residence permits

- Canonical ID: `guide.residence-permits`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `topic.residence-permits-and-card`
- Fact IDs (10): `RES-001`, `RES-002`, `RES-003`, `RES-004`, `RES-005`, `RES-006`, `RES-007`, `RES-008`, `RES-009`, `RES-010`
- Source IDs (4): `src.ind.collect-document`, `src.ind.eu-registration`, `src.ind.lost-stolen-card`, `src.ind.residence-permits`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - The broad guide must remain a safe route selector; route-specific legal requirements cannot be collapsed into one checklist.
  - The lost-card flow should be a distinct section or guide and must not imply it applies to damaged or expired documents.
  - No qualified immigration reviewer is assigned.

### Arranging Dutch health insurance

- Canonical ID: `guide.dutch-health-insurance`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.guide.dutch-health-insurance.2026-07-20`
- Fact IDs (5): `insurance.four-month-rule`, `insurance.basic-versus-supplementary`, `insurance.deductible-2026`, `insurance.cak-letter-actions`, `insurance.cak-fine-2026`
- Source IDs (4): `insurance.cak-uninsured-letter`, `insurance.gov-arrival-duty`, `insurance.gov-taking-out`, `insurance.zin-deductible-2026`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - No single rule covers every international student, cross-border worker, foreign employer, asylum seeker or residence-status scenario; these branches require separate reviewed source mappings.
  - Premiums, contracted providers, reimbursements and voluntary deductible choices are insurer- and policy-specific; no fixed price or best-policy recommendation is supported here.
  - Healthcare benefit eligibility is not included because it requires a separate Tax Administration evidence dossier.

### Finding a huisarts

- Canonical ID: `guide.finding-a-huisarts`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.guide.finding-a-huisarts.2026-07-20`
- Fact IDs (5): `gp.registration-recommended-not-mandatory`, `gp.finding-help`, `gp.choose-nearby`, `gp.care-mediation`, `gp.coverage-and-deductible`
- Source IDs (3): `gp.gov-moving-arrangements`, `gp.nza-care-mediation`, `gp.zin-gp-coverage`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - The permitted official sources do not provide one national registration form, universal document list, acceptance radius, processing time or guarantee that a practice has space.
  - A publishable guide needs a locality-aware method for finding actual practices and must make clear that availability and registration requirements are set by the practice and insurer.
  - No practice directory has been accepted into this dossier because the requested source set excludes commercial directories and provider-maintained listings.

### Emergency numbers and urgent help

- Canonical ID: `guide.emergency-numbers-and-urgent-help`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.guide.emergency-urgent-help.2026-07-20`
- Fact IDs (5): `emergency.call-112`, `emergency.tell-operator`, `emergency.hap-before-ed`, `emergency.cost-routing`, `emergency.police-nonurgent`
- Source IDs (3): `emergency.gov-when-112`, `emergency.police-contact`, `emergency.rijk-hap-seh`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - Out-of-hours GP phone numbers are regional and are not supplied by the national sources in this dossier; a location-aware contact source is required.
  - This dossier does not provide symptom-by-symptom triage and must not be used to infer medical urgency beyond the official routing statements.
  - Other crisis lines, poison information, domestic violence and mental-health crisis contacts require separate primary-source verification before inclusion.

### Finding long-term housing

- Canonical ID: `guide.renting-a-home`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.guide.renting-a-home.2026-07-20`
- Fact IDs (6): `renting.check-sector-and-rent`, `renting.deposit-contracts-after-2023`, `renting.written-contract`, `renting.contract-content`, `renting.mediation-fee`, `renting.municipal-permit-variation`
- Source IDs (3): `renting.gov-tenant-plan`, `renting.huurcommissie-rent-check`, `renting.rijk-contract-content`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - No official source in the permitted set provides a complete national inventory of available rentals or verifies individual listings and landlords.
  - Municipal housing permits, allocation rules and local reporting routes require city-specific sources before publication.
  - Annual rent thresholds, points and benefit eligibility are volatile; this dossier intentionally does not turn 2026 figures into evergreen copy.

### Finding temporary housing

- Canonical ID: `guide.temporary-housing`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.temporary-housing`
- Fact IDs (6): `temporary-housing.contract-type`, `temporary-housing.written-contract`, `temporary-housing.cost-check`, `temporary-housing.end-notice`, `temporary-housing.registration-check`, `temporary-housing.urgent-shelter`
- Source IDs (4): `temporary-housing.gov-brp`, `temporary-housing.gov-tenant-plan`, `temporary-housing.gov-wmo`, `temporary-housing.rijk-contract-types`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - Live availability and provider suitability are local and cannot be represented as a national inventory.
  - A housing-law reviewer must confirm how the current contract exceptions apply before publication.

### Handling landlord problems and housing defects

- Canonical ID: `guide.reporting-housing-defects`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.guide.reporting-housing-defects.2026-07-20`
- Fact IDs (5): `defects.notify-landlord-writing`, `defects.huurcommissie-after-six-weeks`, `defects.route-varies-by-sector`, `defects.municipal-building-control`, `defects.good-landlord-reporting-point`
- Source IDs (3): `defects.huurcommissie-procedure`, `defects.ministry-reporting-point`, `defects.rijk-maintenance`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - The correct escalation route depends on sector, contract date, defect type and municipality; these must be collected before generating personalised steps.
  - The dossier does not define emergency responses for gas leaks, fire, structural collapse or immediate health danger; dedicated official safety sources are required.
  - Court procedure, limitation periods and legal drafting are not expanded into advice here.

### Finding work with limited Dutch

- Canonical ID: `guide.finding-work`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.guide.finding-work.2026-07-20`
- Fact IDs (4): `work.eures-uwv`, `work.work-folder-functions`, `work.foreign-benefit-pdu2`, `work.ww-activities-context`
- Source IDs (4): `work.uwv-foreign-job-search`, `work.uwv-job-search-requirement`, `work.uwv-portals`, `work.uwv-working-netherlands`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - The permitted sources do not establish one universal job-search sequence, response time or outcome guarantee.
  - Work-permit requirements depend on nationality, residence status and job; this dossier does not contain enough primary evidence to publish those branches.
  - Commercial job boards, recruitment agencies and salary advice are intentionally excluded.

### Employment contract and payslip basics

- Canonical ID: `guide.understanding-an-employment-contract`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.guide.employment-contract.2026-07-20`
- Fact IDs (5): `contract.information-one-week`, `contract.information-one-month`, `contract.written-advisable`, `contract.fixed-versus-permanent`, `contract.cao-priority`
- Source IDs (3): `contract.rijk-cao`, `contract.rijk-content`, `contract.rijk-fixed-permanent`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - No individual contract, collective agreement or sector has been reviewed; publication must not label a clause lawful or unlawful for a specific person.
  - Probation, dismissal, notice, non-compete, agency work and zero-hours rules need their own sourced branches before deeper guidance.
  - Legislative news about future flex-work changes is not treated as law in force in this dossier.

### Taxes and allowances

- Canonical ID: `guide.taxes-and-allowances`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `topic.taxes-and-allowances`
- Fact IDs (9): `TAX-001`, `TAX-002`, `TAX-003`, `TAX-004`, `TAX-005`, `TAX-006`, `TAX-007`, `TAX-008`, `TAX-009`
- Source IDs (4): `src.gov.tax-return`, `src.taxadmin.filing-methods`, `src.toeslagen.how-benefits-work`, `src.toeslagen.report-changes`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Tax-year-specific thresholds, dates and allowance conditions have not been modelled.
  - The guide must not determine eligibility or provide personalised tax advice.
  - The current operational filing source is Dutch and needs checked English editorial wording.
  - No tax-domain reviewer is assigned.

### Getting help with debt

- Canonical ID: `guide.debt-help`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.debt-help`
- Fact IDs (6): `debt-help.contact-municipality`, `debt-help.prepare-information`, `debt-help.response-times`, `debt-help.threatening-situation`, `debt-help.free-municipal-help`, `debt-help.escalation`
- Source IDs (3): `debt-help.gov-legal-aid`, `debt-help.rijk-apply`, `debt-help.rijk-what-municipality-does`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - Municipal intake channels and forms differ and require explicit location selection.
  - A qualified debt-support or legal reviewer must validate escalation wording before publication.

### Opening a Dutch bank account

- Canonical ID: `guide.opening-a-dutch-bank-account`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.guide.opening-bank-account.2026-07-20`
- Fact IDs (4): `bank.ordinary-account-discretion`, `bank.identity-verification`, `bank.basic-account-fallback`, `bank.rejection-complaint`
- Source IDs (2): `bank.dnb-kyc`, `bank.rijk-rejected-account`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - The official sources do not provide one universal document checklist, opening time, fee or remote-onboarding route for all banks.
  - The evidence does not support the claim that a BSN is always required to open every ordinary Dutch account.
  - Business accounts, credit products, savings accounts and bank comparisons are outside this dossier.

### Choosing a SIM card and home internet

- Canonical ID: `guide.sim-card-and-home-internet`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.sim-card-and-home-internet`
- Fact IDs (6): `telecom.compare-summary`, `telecom.mobile-coverage`, `telecom.address-availability`, `telecom.total-cost`, `telecom.cooling-off`, `telecom.end-or-complain`
- Source IDs (3): `telecom.acm-cancel`, `telecom.acm-fixed-choice`, `telecom.acm-mobile-choice`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - Provider prices, acceptance requirements, coverage and installation dates remain live provider data and are not copied into the guide.
  - No commercial provider is endorsed by this research packet.

### Using public transport

- Canonical ID: `guide.using-public-transport`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.guide.using-public-transport.2026-07-20`
- Fact IDs (5): `transport.plan-and-recheck`, `transport.accessible-planning`, `transport.ovpay-contactless`, `transport.same-operator`, `transport.ovpay-limitations`
- Source IDs (3): `transport.9292-planner-faq`, `transport.ns-check-in-out`, `transport.ns-debit-card`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - No fare is included because fares, supplements, discounts and products vary by operator, journey and date.
  - NS evidence is strongest for train travel; bus, tram, metro and ferry operator exceptions need their own primary-source checks before a comprehensive national guide is published.
  - A route planner result is advisory and can change; YouNew must not cache it as evergreen operational truth.

### Getting a foreign diploma recognised

- Canonical ID: `guide.diploma-recognition`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.diploma-recognition`
- Fact IDs (6): `diploma.choose-purpose`, `diploma.evaluation-scope`, `diploma.study-route`, `diploma.work-route`, `diploma.documents`, `diploma.live-time-cost`
- Source IDs (4): `diploma.idw-delays`, `diploma.idw-faq`, `diploma.idw-home`, `diploma.idw-study`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - Regulated professions and individual institutions require separate competent-authority checks.
  - Live fee and queue timing must be rechecked during human review.

### Dutch language courses and civic integration

- Canonical ID: `guide.dutch-integration-exams`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.guide.dutch-integration-exams.2026-08-05`
- Fact IDs (6): `integration.check-personal-route`, `integration.pip-and-municipality`, `integration.registration-routes`, `integration.register-and-confirm`, `integration.portal-requirements`, `integration.results-by-exam-type`
- Source IDs (5): `integration.duo-overview`, `integration.duo-portal`, `integration.duo-register`, `integration.duo-results`, `integration.duo-which-exams`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 8 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - The applicable act, route, level, exemptions and required components cannot be inferred safely without the person's DUO record and, where relevant, PIP.
  - PVT and MAP execution, appointments and support are municipality-specific; B1/B2 Nt2 administration follows a separate route.
  - Current fees, examination availability, accommodations and exceptional routes require action-time verification.
  - A named human reviewer must check the source-to-step interpretation before publication.

### Family, children and school registration

- Canonical ID: `guide.family-children-and-school-registration`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.family-children-school`
- Fact IDs (7): `family.register-household`, `family.school-age`, `family.local-admission`, `family.school-documents`, `family.school-support`, `family.child-benefit`, `family.child-insurance`
- Source IDs (3): `family.gov-brp`, `family.gov-school-registration`, `family.svb-child-benefit`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - School availability, newcomer classes and admission calendars require local research.
  - Benefits and cross-border family rights require case-specific official assessment.

### Pets and veterinary care

- Canonical ID: `guide.pets-and-veterinary-care`
- Queue status: `qa_packet`
- Publication authorized: `false`
- Research input: `research.pets-veterinary-care`
- Fact IDs (6): `pets.choose-origin-route`, `pets.eu-entry`, `pets.eu-timing`, `pets.third-country-entry`, `pets.dog-registration`, `pets.welfare-and-vet`
- Source IDs (4): `pets.nvwa-eu`, `pets.nvwa-registration`, `pets.nvwa-third-country`, `pets.nvwa-welfare`
- Schema v2 missing/unready fields (4): `status`, `reviewer`, `confidence_level`, `publication_gate`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached through a canonical entity.
  - `schema_v2_incomplete`: 4 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - A named human editor or subject-matter reviewer has not approved the source-to-step interpretation.
  - Dedicated guide media with verified provenance and authored alt text has not been attached through a canonical entity.
  - The publication gate remains pending and no guide-specific evidence registry record authorizes release.
  - Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
  - Origin-country details and non-dog-or-cat species require the live NVWA rules guide.
  - Veterinary practices, prices and emergency availability are local commercial data and require separate verification.

## Input evidence

- `DataProject/staging/practical-guides-wave-1.json` — SHA-256 `4a5f6c7b47cb9f036e88ab62188dc7de2dc008fb5eb31d2431664a81dbb2e8aa`
- `DataProject/research/priority-1-government/priority-1-government-sources-2026-07-20.json` — SHA-256 `06722f7cc36c829bde409eb43d4449cf65fd1184f9ebb20bdf6945405e5a58c4`
- `DataProject/research/priority-1-daily/priority-1-dossiers.json` — SHA-256 `35eef4576e95b52c72506cf63dad2ade1b5cd7ec3aeb1296d45b29e5c617dc1e`
- `DataProject/research/monetization-practical-guide-addendum-2026-08-18.json` — SHA-256 `b0dbfa2fe95d184bb0feff5cf71cd2d4a4f385516501ee049f3447299b176080`
- `DataProject/schema/entity.schema.json` — SHA-256 `b4536d7b7115c48d75539783eede556b5ff29bb1cdb89f9dec872abc3b1db87c`

## Allowed next action

A named editor or subject-matter reviewer may now review the sourced schema-v2 packets, request corrections, attach verified guide media, and record final QA evidence. No item may skip named human review, and no status in this file is a publication status.
