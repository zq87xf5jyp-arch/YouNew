# Priority-1 editorial handoff

Generated for: `2026-07-20`

> **Non-publishing evidence.** Every item is `research_draft` or `blocked`; publication is not authorized. Research facts are not converted into procedural steps by this handoff.

## Executive status

- Canonical guide scaffolds: **20**
- Research drafts: **18**
- Blocked without a matching dossier: **2**
- Schema v2 publication-ready guides: **0**
- Unique sourced facts available for drafting: **112**
- Unique official source IDs: **60**
- Answered FAQ records still missing: **60**
- Numbered steps still missing: **20**
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

- `guide.dutch-integration-exams` — Dutch integration exams: No matching official-source dossier exists in either research input.
- `guide.reporting-discrimination` — Reporting discrimination: No matching official-source dossier exists in either research input.

## Queue summary

| Guide | Status | Facts | Sources | Schema checks ready | FAQ missing | Steps missing | Assets missing |
|---|---:|---:|---:|---:|---:|---:|---:|
| `guide.registering-at-a-municipality` | research_draft | 10 | 5 | 7/40 | 3 | 1 | 1 |
| `guide.getting-a-bsn` | research_draft | 8 | 6 | 7/40 | 3 | 1 | 1 |
| `guide.applying-for-digid` | research_draft | 6 | 4 | 7/40 | 3 | 1 | 1 |
| `guide.finding-a-huisarts` | research_draft | 5 | 3 | 7/40 | 3 | 1 | 1 |
| `guide.dutch-health-insurance` | research_draft | 5 | 4 | 7/40 | 3 | 1 | 1 |
| `guide.renting-a-home` | research_draft | 6 | 3 | 7/40 | 3 | 1 | 1 |
| `guide.reporting-housing-defects` | research_draft | 5 | 3 | 7/40 | 3 | 1 | 1 |
| `guide.using-public-transport` | research_draft | 5 | 3 | 7/40 | 3 | 1 | 1 |
| `guide.finding-work` | research_draft | 4 | 4 | 7/40 | 3 | 1 | 1 |
| `guide.understanding-an-employment-contract` | research_draft | 5 | 3 | 7/40 | 3 | 1 | 1 |
| `guide.taxes-and-allowances` | research_draft | 9 | 4 | 7/40 | 3 | 1 | 1 |
| `guide.opening-a-dutch-bank-account` | research_draft | 4 | 2 | 7/40 | 3 | 1 | 1 |
| `guide.emergency-numbers-and-urgent-help` | research_draft | 5 | 3 | 7/40 | 3 | 1 | 1 |
| `guide.residence-permits` | research_draft | 10 | 4 | 7/40 | 3 | 1 | 1 |
| `guide.dutch-integration-exams` | blocked | 0 | 0 | 7/40 | 3 | 1 | 1 |
| `guide.studying-in-the-netherlands` | research_draft | 5 | 4 | 7/40 | 3 | 1 | 1 |
| `guide.student-housing` | research_draft | 5 | 4 | 7/40 | 3 | 1 | 1 |
| `guide.moving-to-another-municipality` | research_draft | 8 | 4 | 7/40 | 3 | 1 | 1 |
| `guide.reporting-discrimination` | blocked | 0 | 0 | 7/40 | 3 | 1 | 1 |
| `guide.starting-a-business` | research_draft | 11 | 5 | 7/40 | 3 | 1 | 1 |

## Per-guide audit

### Registering at a municipality

- Canonical ID: `guide.registering-at-a-municipality`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `topic.municipality-registration-brp-rni`
- Fact IDs (10): `REG-001`, `REG-002`, `REG-003`, `REG-004`, `REG-005`, `REG-006`, `REG-007`, `REG-008`, `REG-009`, `REG-010`
- Source IDs (5): `src.amsterdam.first-registration`, `src.amsterdam.rni`, `src.gov.brp-resident`, `src.nww.bsn-get`, `src.nww.rni-register`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - A human reviewer has not checked the source-to-step interpretation.
  - Only Amsterdam municipal execution has been researched; the guide must route other users to their own municipality.
  - Appointment availability and RNI desk eligibility are volatile.

### Getting a BSN

- Canonical ID: `guide.getting-a-bsn`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `topic.bsn`
- Fact IDs (8): `BSN-001`, `BSN-002`, `BSN-003`, `BSN-004`, `REG-005`, `REG-006`, `REG-008`, `REG-010`
- Source IDs (6): `src.amsterdam.first-registration`, `src.amsterdam.rni`, `src.gov.brp-resident`, `src.gov.bsn-overview`, `src.nww.bsn-get`, `src.nww.rni-register`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 6 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - The guide must first ask whether the user is becoming a resident, is a short-stay non-resident, or may already have a BSN.
  - No human reviewer is assigned.

### Applying for DigiD

- Canonical ID: `guide.applying-for-digid`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `topic.digid`
- Fact IDs (6): `DIG-001`, `DIG-002`, `DIG-003`, `DIG-004`, `DIG-005`, `DIG-006`
- Source IDs (4): `src.digid.abroad`, `src.digid.activate`, `src.digid.apply`, `src.nww.rni-register`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - Resident and abroad activation paths must be separated in the final guide.
  - The official application page contains two delivery-time phrasings; editorial review must retain the conservative maximum.
  - No human reviewer is assigned.

### Finding a huisarts

- Canonical ID: `guide.finding-a-huisarts`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.finding-a-huisarts.2026-07-20`
- Fact IDs (5): `gp.registration-recommended-not-mandatory`, `gp.finding-help`, `gp.choose-nearby`, `gp.care-mediation`, `gp.coverage-and-deductible`
- Source IDs (3): `gp.gov-moving-arrangements`, `gp.nza-care-mediation`, `gp.zin-gp-coverage`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - The permitted official sources do not provide one national registration form, universal document list, acceptance radius, processing time or guarantee that a practice has space.
  - A publishable guide needs a locality-aware method for finding actual practices and must make clear that availability and registration requirements are set by the practice and insurer.
  - No practice directory has been accepted into this dossier because the requested source set excludes commercial directories and provider-maintained listings.

### Dutch health insurance

- Canonical ID: `guide.dutch-health-insurance`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.dutch-health-insurance.2026-07-20`
- Fact IDs (5): `insurance.four-month-rule`, `insurance.basic-versus-supplementary`, `insurance.deductible-2026`, `insurance.cak-letter-actions`, `insurance.cak-fine-2026`
- Source IDs (4): `insurance.cak-uninsured-letter`, `insurance.gov-arrival-duty`, `insurance.gov-taking-out`, `insurance.zin-deductible-2026`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - No single rule covers every international student, cross-border worker, foreign employer, asylum seeker or residence-status scenario; these branches require separate reviewed source mappings.
  - Premiums, contracted providers, reimbursements and voluntary deductible choices are insurer- and policy-specific; no fixed price or best-policy recommendation is supported here.
  - Healthcare benefit eligibility is not included because it requires a separate Tax Administration evidence dossier.

### Renting a home

- Canonical ID: `guide.renting-a-home`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.renting-a-home.2026-07-20`
- Fact IDs (6): `renting.check-sector-and-rent`, `renting.deposit-contracts-after-2023`, `renting.written-contract`, `renting.contract-content`, `renting.mediation-fee`, `renting.municipal-permit-variation`
- Source IDs (3): `renting.gov-tenant-plan`, `renting.huurcommissie-rent-check`, `renting.rijk-contract-content`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - No official source in the permitted set provides a complete national inventory of available rentals or verifies individual listings and landlords.
  - Municipal housing permits, allocation rules and local reporting routes require city-specific sources before publication.
  - Annual rent thresholds, points and benefit eligibility are volatile; this dossier intentionally does not turn 2026 figures into evergreen copy.

### Reporting housing defects

- Canonical ID: `guide.reporting-housing-defects`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.reporting-housing-defects.2026-07-20`
- Fact IDs (5): `defects.notify-landlord-writing`, `defects.huurcommissie-after-six-weeks`, `defects.route-varies-by-sector`, `defects.municipal-building-control`, `defects.good-landlord-reporting-point`
- Source IDs (3): `defects.huurcommissie-procedure`, `defects.ministry-reporting-point`, `defects.rijk-maintenance`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - The correct escalation route depends on sector, contract date, defect type and municipality; these must be collected before generating personalised steps.
  - The dossier does not define emergency responses for gas leaks, fire, structural collapse or immediate health danger; dedicated official safety sources are required.
  - Court procedure, limitation periods and legal drafting are not expanded into advice here.

### Using public transport

- Canonical ID: `guide.using-public-transport`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.using-public-transport.2026-07-20`
- Fact IDs (5): `transport.plan-and-recheck`, `transport.accessible-planning`, `transport.ovpay-contactless`, `transport.same-operator`, `transport.ovpay-limitations`
- Source IDs (3): `transport.9292-planner-faq`, `transport.ns-check-in-out`, `transport.ns-debit-card`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - No fare is included because fares, supplements, discounts and products vary by operator, journey and date.
  - NS evidence is strongest for train travel; bus, tram, metro and ferry operator exceptions need their own primary-source checks before a comprehensive national guide is published.
  - A route planner result is advisory and can change; YouNew must not cache it as evergreen operational truth.

### Finding work

- Canonical ID: `guide.finding-work`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.finding-work.2026-07-20`
- Fact IDs (4): `work.eures-uwv`, `work.work-folder-functions`, `work.foreign-benefit-pdu2`, `work.ww-activities-context`
- Source IDs (4): `work.uwv-foreign-job-search`, `work.uwv-job-search-requirement`, `work.uwv-portals`, `work.uwv-working-netherlands`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 9 documented gaps remain unresolved.
- Unresolved gaps:
  - No governed QA record covers the end-to-end task of finding work.
  - Work-permit and employment-contract records are adjacent topics, not a substitute for a reviewed job-search guide.
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - The permitted sources do not establish one universal job-search sequence, response time or outcome guarantee.
  - Work-permit requirements depend on nationality, residence status and job; this dossier does not contain enough primary evidence to publish those branches.
  - Commercial job boards, recruitment agencies and salary advice are intentionally excluded.

### Understanding an employment contract

- Canonical ID: `guide.understanding-an-employment-contract`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.employment-contract.2026-07-20`
- Fact IDs (5): `contract.information-one-week`, `contract.information-one-month`, `contract.written-advisable`, `contract.fixed-versus-permanent`, `contract.cao-priority`
- Source IDs (3): `contract.rijk-cao`, `contract.rijk-content`, `contract.rijk-fixed-permanent`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - No individual contract, collective agreement or sector has been reviewed; publication must not label a clause lawful or unlawful for a specific person.
  - Probation, dismissal, notice, non-compete, agency work and zero-hours rules need their own sourced branches before deeper guidance.
  - Legislative news about future flex-work changes is not treated as law in force in this dossier.

### Taxes and allowances

- Canonical ID: `guide.taxes-and-allowances`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `topic.taxes-and-allowances`
- Fact IDs (9): `TAX-001`, `TAX-002`, `TAX-003`, `TAX-004`, `TAX-005`, `TAX-006`, `TAX-007`, `TAX-008`, `TAX-009`
- Source IDs (4): `src.gov.tax-return`, `src.taxadmin.filing-methods`, `src.toeslagen.how-benefits-work`, `src.toeslagen.report-changes`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 8 documented gaps remain unresolved.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - Tax-year-specific thresholds, dates and allowance conditions have not been modelled.
  - The guide must not determine eligibility or provide personalised tax advice.
  - The current operational filing source is Dutch and needs checked English editorial wording.
  - No tax-domain reviewer is assigned.

### Opening a Dutch bank account

- Canonical ID: `guide.opening-a-dutch-bank-account`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.opening-bank-account.2026-07-20`
- Fact IDs (4): `bank.ordinary-account-discretion`, `bank.identity-verification`, `bank.basic-account-fallback`, `bank.rejection-complaint`
- Source IDs (2): `bank.dnb-kyc`, `bank.rijk-rejected-account`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 9 documented gaps remain unresolved.
- Unresolved gaps:
  - No governed QA record covers opening a Dutch bank account.
  - The published ING partner record is commercial and must not be used as an editorial source.
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - The official sources do not provide one universal document checklist, opening time, fee or remote-onboarding route for all banks.
  - The evidence does not support the claim that a BSN is always required to open every ordinary Dutch account.
  - Business accounts, credit products, savings accounts and bank comparisons are outside this dossier.

### Emergency numbers and urgent help

- Canonical ID: `guide.emergency-numbers-and-urgent-help`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.emergency-urgent-help.2026-07-20`
- Fact IDs (5): `emergency.call-112`, `emergency.tell-operator`, `emergency.hap-before-ed`, `emergency.cost-routing`, `emergency.police-nonurgent`
- Source IDs (3): `emergency.gov-when-112`, `emergency.police-contact`, `emergency.rijk-hap-seh`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - Out-of-hours GP phone numbers are regional and are not supplied by the national sources in this dossier; a location-aware contact source is required.
  - This dossier does not provide symptom-by-symptom triage and must not be used to infer medical urgency beyond the official routing statements.
  - Other crisis lines, poison information, domestic violence and mental-health crisis contacts require separate primary-source verification before inclusion.

### Residence permits

- Canonical ID: `guide.residence-permits`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `topic.residence-permits-and-card`
- Fact IDs (10): `RES-001`, `RES-002`, `RES-003`, `RES-004`, `RES-005`, `RES-006`, `RES-007`, `RES-008`, `RES-009`, `RES-010`
- Source IDs (4): `src.ind.collect-document`, `src.ind.eu-registration`, `src.ind.lost-stolen-card`, `src.ind.residence-permits`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - The broad guide must remain a safe route selector; route-specific legal requirements cannot be collapsed into one checklist.
  - The lost-card flow should be a distinct section or guide and must not imply it applies to damaged or expired documents.
  - No qualified immigration reviewer is assigned.

### Dutch integration exams

- Canonical ID: `guide.dutch-integration-exams`
- Queue status: `blocked`
- Publication authorized: `false`
- Research input: none
- Fact IDs (0): none
- Source IDs (0): none
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `official_research_dossier_missing`: No matching official-source research dossier is present.
  - `unresolved_research_or_publication_gaps`: 4 documented gaps remain unresolved.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.

### Studying in the Netherlands

- Canonical ID: `guide.studying-in-the-netherlands`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.studying-netherlands.2026-07-20`
- Fact IDs (5): `study.verify-recognition`, `study.application-deadlines`, `study.admission-institution-specific`, `study.tuition-types-2026`, `study.finance-conditional`
- Source IDs (4): `study.duo-finance`, `study.duo-tuition`, `study.gov-higher-education`, `study.rijk-deadlines`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - A complete guide needs separate, verified branches for MBO, HBO, WO, bachelor, master, numerus fixus and February entry.
  - Residence permits, visas, foreign-diploma evaluation, language tests and institution-specific documents are not fully sourced in this dossier.
  - The dossier does not claim that every international student is eligible for statutory tuition or student finance.

### Student housing

- Canonical ID: `guide.student-housing`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `research.guide.student-housing.2026-07-20`
- Fact IDs (5): `student-housing.search-routes`, `student-housing.contract-and-address`, `student-housing.possible-permit`, `student-housing.room-rent-check`, `student-housing.standard-tenant-protections`
- Source IDs (4): `student-housing.gov-tenant-plan`, `student-housing.huurcommissie-rent-check`, `student-housing.rijk-moving-room`, `student-housing.rijk-study-checklist`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 9 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No governed QA record covers student-specific housing.
  - General renting records must not be presented as student-housing instructions without dedicated review.
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - There is no official national live inventory, universal waiting time or guaranteed student-housing route in the permitted source set.
  - Housing-association registration, campus housing, local allocation, housing permits and address-registration rules require city and institution sources.
  - Housing-benefit eligibility for a particular room is not established by this dossier.

### Moving to another municipality

- Canonical ID: `guide.moving-to-another-municipality`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `topic.moving-municipality`
- Fact IDs (8): `MOVE-001`, `MOVE-002`, `MOVE-003`, `MOVE-004`, `MOVE-005`, `MOVE-006`, `MOVE-007`, `MOVE-008`
- Source IDs (4): `src.amsterdam.change-address`, `src.gov.brp-resident`, `src.gov.change-address`, `src.gov.foreign-national-move`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - Only Amsterdam's local submission route has been researched.
  - Users receiving municipal support need a separate handoff to their new municipality.
  - No human reviewer is assigned.

### Reporting discrimination

- Canonical ID: `guide.reporting-discrimination`
- Queue status: `blocked`
- Publication authorized: `false`
- Research input: none
- Fact IDs (0): none
- Source IDs (0): none
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `official_research_dossier_missing`: No matching official-source research dossier is present.
  - `unresolved_research_or_publication_gaps`: 4 documented gaps remain unresolved.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.

### Starting a business

- Canonical ID: `guide.starting-a-business`
- Queue status: `research_draft`
- Publication authorized: `false`
- Research input: `topic.starting-business`
- Fact IDs (11): `BUS-001`, `BUS-002`, `BUS-003`, `BUS-004`, `BUS-005`, `BUS-006`, `BUS-007`, `BUS-008`, `BUS-009`, `BUS-010`, `BUS-011`
- Source IDs (5): `src.businessgov.register-kvk`, `src.businessgov.start-plan`, `src.ind.residence-permits`, `src.kvk.entrepreneur-criteria`, `src.kvk.registration-fee-2026`
- Schema v2 missing/unready fields (33): `schema_version`, `status`, `short_summary`, `audience_profiles`, `who_this_is_for`, `when_you_need_it`, `jurisdiction`, `prerequisites`, `required_documents`, `estimated_time`, `estimated_cost`, `numbered_steps`, `warnings`, `common_mistakes`, `tips`, `checklist`, `faqs`, `emergency_information`, `sections`, `official_sources`, `contact_options`, `related_guide_ids`, `next_actions`, `verified_at`, `updated_at`, `reviewer`, `reading_time_minutes`, `difficulty`, `confidence_level`, `tags`, `publication_gate`, `disclaimer`, `seo`
- Blockers:
  - `human_review_required`: No named human reviewer and review record are attached.
  - `guide_media_with_alt_required`: No dedicated guide asset with verified provenance and non-empty alt text is attached to this scaffold.
  - `schema_v2_incomplete`: 33 of 40 publication checks are not ready.
  - `unresolved_research_or_publication_gaps`: 7 documented gaps remain unresolved.
  - `locality_or_provider_branch_incomplete`: Local execution, provider availability, or institution-specific instructions remain outside a single national procedure.
- Unresolved gaps:
  - No sourced step-by-step content has been reviewed for publication.
  - Per-fact source IDs have not been mapped into the practical guide.
  - Verification date and reviewer have not been assigned.
  - Estimated time and cost have not been verified.
  - The final guide needs branching for legal structure, residence status, business location and regulated activity.
  - The 2026 fee must not be carried into 2027 without reverification.
  - No legal, tax or KVK-domain reviewer is assigned.

## Input evidence

- `DataProject/staging/practical-guides-wave-1.json` — SHA-256 `d2ce30c6711055d03f8eb9a1b80a777a394ff8d06bf7c18a2c1cde70a34df94e`
- `DataProject/research/priority-1-government/priority-1-government-sources-2026-07-20.json` — SHA-256 `06722f7cc36c829bde409eb43d4449cf65fd1184f9ebb20bdf6945405e5a58c4`
- `DataProject/research/priority-1-daily/priority-1-dossiers.json` — SHA-256 `6e5ef4d8cf10f1323574af853239171b6632b219f7989560c1a18c60b18987a3`
- `DataProject/schema/entity.schema.json` — SHA-256 `5ed5c1c2f10d9bfb211a5fad2635ee2c992f14f4941387b0444fe84da15463f2`

## Allowed next action

Editors may draft sourced schema v2 fields from the recorded facts, keeping every fact ID and source ID attached. No item may skip QA or named human review, and no status in this file is a publication status.
