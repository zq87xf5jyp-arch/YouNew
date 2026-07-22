# Build Week public claims register

Evidence cutoff: 2026-07-21, Europe/Amsterdam  
Repository snapshot inspected: branch `main`, HEAD `7a1f6bc8fcffac84e5798338380bb97aca815b3d`
Document status: **judge-safe wording register; final packaging uses bounded preserved evidence**

Media-rights status updated: 2026-07-22. The 170-asset shipped catalog now has
complete deterministic records and zero unresolved assets. Non-catalog release
media remains outside that PASS.

## How to use this register

Statuses:

- **VERIFIED** — supported directly by the inspected repository snapshot.
- **VERIFIED WITH BOUNDARY** — the implementation/fact is supported, but a nearby broader interpretation is not.
- **BOUNDED EVIDENCE** — a preserved targeted or historical result may be stated only with its exact scope.
- **OWNER CONFIRMATION REQUIRED** — repository evidence alone cannot establish the personal, legal, rights, or distribution fact.
- **FORBIDDEN / NOT PROVED** — available evidence does not support the wording.

Every public use should keep the stated boundary. A source file proves implementation; a test result proves only the tested snapshot and environment; a manifest proves an internal release state, not external distribution.

## 1. Native iOS and SwiftUI

**Status:** VERIFIED.

**Evidence:** [`AppEntry.swift`](../YouNew/App/AppEntry.swift), [`AppTabView.swift`](../YouNew/App/AppTabView.swift), and [`YouNew.xcodeproj/project.pbxproj`](../YouNew.xcodeproj/project.pbxproj).

**Safe wording:**

> YouNew is a native iOS application built with Swift and SwiftUI.

**Forbidden wording:** “Cross-platform production app”, “App Store-ready native app”, or any minimum-device/support claim not copied from the final candidate build settings.

## 2. Human-directed Codex-assisted workflow

**Status:** VERIFIED WITH BOUNDARY.

**Evidence:** [`CODEX_EVIDENCE.md`](../BuildWeekAudit/CODEX_EVIDENCE.md), [`HOW_CODEX_WAS_USED.md`](../BuildWeekSubmission/HOW_CODEX_WAS_USED.md), the five evidence packets in [`BuildWeekFix`](../BuildWeekFix), and tracked human review documents such as [`strict_visual_audit.md`](../strict_visual_audit.md). The repository does not contain a complete session export or commit co-author trail assigning every line to Codex.

**Safe wording:**

> The repository contains implementation and reports consistent with the documented human-directed Codex-assisted workflow.

**Forbidden wording:** “Codex autonomously built the entire app”, “Codex authored every line/commit”, “GPT-5.6 wrote this repository”, or attribution of a specific file to a specific Codex session without exported session evidence.

## 3. Repository history and remote state

**Status:** VERIFIED as a point-in-time local fact.

**Evidence:** At the current cutoff, `git rev-list --count HEAD` returned **66** and `git rev-parse HEAD` returned `7a1f6bc8fcffac84e5798338380bb97aca815b3d`. Branch `main` tracks `origin/main`, and `origin` is configured. The owner working tree is not clean. Reflog records the branch rename and commit at 2026-07-21 13:36 +02:00; this validation pass did not perform them.

**Safe wording:**

> At the evidence cutoff, the local YouNew repository contained 66 commits on `main`; an `origin` remote was configured.

**Forbidden wording:** “Approximately 56 commits” as a current number, “verified public GitHub repository”, “clean repository”, “clone-ready repository”, or “the current documentation changes have been pushed”. A configured remote is not proof of public visibility or synchronized working-tree changes. Recalculate if HEAD changes.

## 4. Local guided assistant

**Status:** VERIFIED WITH BOUNDARY.

**Evidence:** [`AIWorkflowEngine.swift`](../YouNew/Services/AIWorkflowEngine.swift), [`AIResponseComposer.swift`](../YouNew/Services/AIResponseComposer.swift), [`KnowledgeIndex.swift`](../YouNew/Services/KnowledgeIndex.swift), local-origin rendering in [`AIAssistantView.swift`](../YouNew/Views/AIAssistantView.swift), and assistant unit/UI contracts in [`KnowledgeIndexTests.swift`](../YouNewTests/KnowledgeIndexTests.swift) and [`YouNewUITests.swift`](../YouNewUITests/YouNewUITests.swift).

**Safe wording:**

> YouNew includes a deterministic local guided assistant backed by structured workflows and indexed YouNew knowledge. Local answers are explicitly labelled “Local guide mode”.

Alternative short form:

> A structured YouNew knowledge assistant guides practical journeys such as BSN, address registration, and DigiD.

**Forbidden wording:** “Powered by GPT-5.6”, “live OpenAI assistant”, “generative AI answer”, “the assistant always uses AI inference”, or “verified live model response”. Optional client/backend contract code is not runtime proof of a deployed or configured live service.

## 5. Interactive Netherlands map

**Status:** VERIFIED WITH BOUNDARY; targeted blocker fix is preserved, aggregate UI evidence remains bounded.

**Evidence:** [`PlacesDiscoveryView.swift`](../YouNew/Views/PlacesDiscoveryView.swift), [`PremiumProvinceHitTesting.swift`](../YouNew/Core/Interaction/PremiumProvinceHitTesting.swift), [`PremiumNetherlandsMapModel.swift`](../YouNew/Models/PremiumNetherlandsMapModel.swift), [`PremiumProvinceHitTestingTests.swift`](../YouNewTests/PremiumProvinceHitTestingTests.swift), and [`MapChipUITests.swift`](../YouNewUITests/MapChipUITests.swift). [`UI_BASELINE.md`](UI_BASELINE.md) records the pre-fix Map → Home first-tap blocker. [`MAP_TAB_BLOCKER_FIX.md`](MAP_TAB_BLOCKER_FIX.md) records the post-fix finalized targeted bundle: 3/3 PASS, including 10/10 first-tap Map ↔ Home transitions, Leiden, and Middelburg routes.

**Safe wording:**

> YouNew includes an interactive Netherlands map with province and city exploration and verified root-tab return on the tested candidate build.

**Forbidden wording:** “The map is fully stable”, “all UI tests pass”, “all map interactions pass on every device”, or “physical-device map behavior is certified”. The current proof is bounded to the preserved simulator artifact and tested paths.

## 6. Premium image system

**Status:** VERIFIED implementation / shipped catalog rights gate PASS.

**Evidence:** [`AppContentImageView.swift`](../YouNew/Core/Imaging/AppContentImageView.swift), [`ImageLoader.swift`](../YouNew/Core/Imaging/ImageLoader.swift), [`MediaRegistryTests.swift`](../YouNewTests/MediaRegistryTests.swift), [`EVIDENCE_PREMIUM_IMAGE_PIPELINE.md`](../BuildWeekFix/EVIDENCE_PREMIUM_IMAGE_PIPELINE.md), and the bounded demo review in [`MEDIA_RIGHTS_FINAL.md`](MEDIA_RIGHTS_FINAL.md).

**Safe wording:**

> YouNew contains a role-aware image pipeline with bounded caches, request timeouts, downsampling, placeholders, and fallback behavior.

> The shipped 170-asset catalog has a deterministic source/rights ledger with zero unresolved records: 58 public-domain city symbols, 36 documented project-owned assets, and 76 attribution-ready third-party assets.

> Required third-party credits and modification notices remain in force. Screenshots, recordings, audio, and public-site media require separate review.

**Forbidden wording:** “All repository or release media is cleared”, “the repository license relicenses third-party images”, “municipalities endorse YouNew”, “every remote image is reachable”, “zero image duplication everywhere”, or measured performance-improvement claims without a current network run and Instruments evidence.

## 7. Governed content and import platform

**Status:** VERIFIED WITH BOUNDARY.

**Evidence:** [`DataProject/README.md`](../DataProject/README.md), [`releases.json`](../DataProject/releases/releases.json), [`release-transition-policy.json`](../DataProject/operations/release-transition-policy.json), [`import-data-project.py`](../scripts/import-data-project.py), [`DataProjectRuntimeLoader.swift`](../YouNew/Services/DataProjectRuntimeLoader.swift), [`ContentRepository.swift`](../YouNew/Services/ContentRepository.swift), and [`EVIDENCE_CONTENT_PLATFORM.md`](../BuildWeekFix/EVIDENCE_CONTENT_PLATFORM.md).

**Safe wording:**

> The YouNew content platform supports schema-governed releases, explicit lifecycle gates, deterministic imports, migrations, relation checks, and runtime validation.

**Forbidden wording:** “All content is complete”, “content is automatically safe to publish”, “every category is populated”, “all external sources are current”, or “the platform proves production editorial readiness”.

## 8. `cities-v0.1.0`

**Status:** VERIFIED as an internal governed content release.

**Evidence:** [`cities-v0.1.0.json`](../DataProject/reports/release-manifests/cities-v0.1.0.json) records five governed, published, and verified city records; [`M1-priority-cities-001.json`](../DataProject/batches/WP-06/M1-priority-cities-001.json) contains the records; [`PublishedCitiesDataReleaseTests.swift`](../YouNewTests/PublishedCitiesDataReleaseTests.swift) and [`PublishedCitiesRuntimeUITests.swift`](../YouNewUITests/PublishedCitiesRuntimeUITests.swift) define the structural/runtime contracts.

**Safe wording:**

> The internal governed content release `cities-v0.1.0` imported five cities: Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven.

**Forbidden wording:** “Five cities were released on the App Store”, “all five cities have complete/equal coverage”, “all city links are currently healthy”, or “published” without clarifying that it is the internal content lifecycle state.

## 9. Data/import validation and URL health

**Status:** VERIFIED WITH AN OPEN NETWORK-HEALTH BLOCKER.

**Evidence:** Structural/import checks and manifests are documented in [`EVIDENCE_CONTENT_PLATFORM.md`](../BuildWeekFix/EVIDENCE_CONTENT_PLATFORM.md), [`DataProjectRuntimeBaselineTests.swift`](../YouNewTests/DataProjectRuntimeBaselineTests.swift), and [`data-project-import-static-qa.py`](../scripts/data-project-import-static-qa.py). The latest [`data-health.json`](../DataProject/reports/data-health.json) is separately `attention_required`: **2,494** URLs checked, **1,821** reachable, **18** confirmed broken governed URLs, **623** access-restricted, and **32** transient failures.

**Safe wording before the final rerun:**

> The repository has reproduced structural DataProject/import validation, while external-source health remains a separate open gate: the latest report records 18 confirmed broken governed URLs.

If the final structural/import rerun passes, retain the limitation in the same paragraph:

> Final structural DataProject/import validation passed for the tested candidate snapshot. External link health is separate and remains `attention_required`, with 18 confirmed broken governed URLs in the latest point-in-time report.

**Forbidden wording:** “All data validation passes”, “all links pass”, “all official sources are reachable”, “18 failures are only harmless restrictions”, or combining structural validation and live URL health into one green status.

## 10. QA and validation automation

**Status:** VERIFIED for the presence and breadth of automation; **CURRENT BOUNDED EVIDENCE** for recorded results.

**Evidence:** [`run-static-qa.sh`](../scripts/run-static-qa.sh) currently enumerates 44 command invocations; [`YouNewTests`](../YouNewTests), [`YouNewUITests`](../YouNewUITests), accessibility scripts/tests, content validators, release validators, and the current artifacts summarized in [`../BuildWeekSubmission/FINAL_VALIDATION.md`](../BuildWeekSubmission/FINAL_VALIDATION.md).

**Safe wording:**

> The project includes extensive unit, UI, static, accessibility, content, data, privacy, routing, media, and release-validation automation.

> For the audited candidate, clean build passed, unit tests passed 460/460,
> static QA passed 43/44 known gates, and the finalized UI suite passed 79/87.
> An isolated rerun of the eight UI failures passed 5/8; three failures remain
> reproducible.

Exact totals may be appended only with their snapshot, simulator, date, and artifact boundary. The final Build Week package intentionally does not claim an all-green current aggregate.

**Forbidden wording:** “All tests pass”, “446/450 unit”, “35/40 static QA”, “80/86 UI”, `17/20`, or `84/87` as current final results. Those are historical or partial baselines. Also forbidden: “44/44 pass” merely because the script contains 44 invocations.

## 11. Codex use across engineering work

**Status:** VERIFIED WITH ATTRIBUTION BOUNDARY.

**Evidence:** Repository reports document five strongest workstreams: [`EVIDENCE_PREMIUM_IMAGE_PIPELINE.md`](../BuildWeekFix/EVIDENCE_PREMIUM_IMAGE_PIPELINE.md), [`EVIDENCE_INTERACTIVE_MAP.md`](../BuildWeekFix/EVIDENCE_INTERACTIVE_MAP.md), [`EVIDENCE_CONTENT_PLATFORM.md`](../BuildWeekFix/EVIDENCE_CONTENT_PLATFORM.md), [`EVIDENCE_CITIES_RELEASE.md`](../BuildWeekFix/EVIDENCE_CITIES_RELEASE.md), and [`EVIDENCE_QA_AUTOMATION.md`](../BuildWeekFix/EVIDENCE_QA_AUTOMATION.md).

**Safe wording:**

> The documented project workflow used Codex as an engineering collaborator for implementation, debugging, refactoring, testing, and technical auditing. The repository contains implementation and reports consistent with that workflow.

**Forbidden wording:** “Codex independently made all product decisions”, “a specific model authored these five systems”, or “repository history cryptographically proves Codex authorship”.

## 12. Human owner role

**Status:** OWNER CONFIRMATION REQUIRED before publication.

**Evidence:** [`OWNER_ACTIONS.md`](../BuildWeekAudit/OWNER_ACTIONS.md), [`CODEX_EVIDENCE.md`](../BuildWeekAudit/CODEX_EVIDENCE.md), and tracked visual/product review reports support an owner-directed review process. Repository contents alone cannot prove personal authorship of every requirement or acceptance decision.

**Safe wording after the owner confirms it:**

> The human owner defined the product vision, requirements, priorities, visual direction, and final acceptance decisions; Codex supported the engineering workflow.

**Forbidden wording:** “The owner personally wrote all code”, “the owner was the only author”, or publishing the role statement without the owner’s factual confirmation.

## 13. Current repository availability

**Status:** VERIFIED local-only; public availability not proved.

**Evidence:** A local `origin` is configured and `main` tracks `origin/main`; no push, publish, deploy, App Store upload, or release action was performed by this validation pass. Remote visibility and content were not independently verified.

**Safe wording:**

> The audited repository is currently local. Public repository creation and push remain owner-approved manual steps.

**Forbidden wording:** “Source available on GitHub”, “judges can clone the repository”, “clean-clone setup is verified”, or “the submitted repository matches this workspace” until those owner actions and a clean-clone validation are completed.

## Claims that must remain explicitly negative

| Proposed claim | Status | Evidence / reason | Safe replacement | Forbidden wording |
|---|---|---|---|---|
| GPT-5.6 powers the in-app assistant. | FORBIDDEN / NOT PROVED | No deployed endpoint, configured live environment, provider request ID, or captured runtime model proof. | “The demo uses a deterministic local guided assistant. Live LLM integration is future work unless separately verified.” | “Powered by GPT-5.6”; “live OpenAI assistant”. |
| All tests pass. | FORBIDDEN / CONTRADICTED | Current unit is 460/460, but static QA is 43/44 and finalized UI is 79/87; three UI failures reproduce in isolation. | Publish exact results from `FINAL_VALIDATION.md`, separated by gate. | “All green”; historical or targeted totals presented as the aggregate. |
| The app is production ready. | FORBIDDEN / NOT PROVED | Open UI, URL-health, non-catalog release-media, distribution, and owner-review gates remain. | “Build Week candidate focused on a bounded demo flow,” after final candidate validation. | “Production ready”; “App Store ready”. |
| All content is complete. | FORBIDDEN / NOT PROVED | Coverage depth is uneven and external source health has open issues. | “The app contains governed practical content with documented scope and limitations.” | “Complete Netherlands guide”; “all categories complete”. |
| All images are fully licensed. | FORBIDDEN as an unscoped claim | The shipped catalog passes with zero unresolved records, but third-party conditions still apply and screenshots, recordings, audio, and public-site media are separate scopes. | “The shipped 170-asset catalog has complete rights records and in-app attribution; non-catalog release media is reviewed separately.” | “Fully licensed”; “all repository/release media cleared”. |
| Latest TestFlight build is verified. | FORBIDDEN / NOT PROVED | No owner-provided current distribution artifact/screenshot links the binary to this snapshot. | “TestFlight status requires owner confirmation.” | Any build number or availability claim without evidence. |
| Current App Store version matches the audited repository. | FORBIDDEN / NOT PROVED | No source-to-store provenance or binary match is available. | “App Store correspondence has not been verified.” | “The App Store build is this audited build.” |
| All external links are healthy. | FORBIDDEN / CONTRADICTED | Latest `data-health.json` records 18 confirmed broken governed URLs. | State structural validation and URL health separately with the 18-link limitation. | “Zero broken links”; “all official sources verified live”. |

## Pre-publication update checklist

- [ ] Recalculate commit count and record final HEAD.
- [x] Copy only completed current build/unit/static/UI/data results from `BuildWeekSubmission/FINAL_VALIDATION.md`.
- [ ] Link each numeric claim to a preserved log or `.xcresult` summary.
- [ ] Keep the 18-link network-health limitation unless a reviewed remediation and fresh report supersede it.
- [x] Add only bounded map/root-tab wording backed by `YouNewBuildWeekMapOverlayFix.xcresult` and `MAP_TAB_BLOCKER_FIX.md`.
- [ ] Obtain owner confirmation for role, selected non-catalog release media, TestFlight/App Store status, repository visibility, and final submission wording. Catalog ownership evidence is already recorded in the rights ledger/attestation.
- [ ] Do not replace bounded wording with marketing superlatives during Devpost editing.
