# How Codex Was Used

Evidence cutoff: 21 July 2026  
Document status: repository-backed Build Week narrative

## Evidence standard

The repository contains implementation and reports consistent with the documented
Codex-assisted workflow.

That is the strongest repository-backed wording currently supported. The local
history does not contain a complete exported Codex conversation, a task ledger
that attributes every change, or commit co-author metadata that proves who wrote a
specific line. This document therefore describes the documented workflow and its
repository outcomes without claiming “Codex wrote” a particular file or that a
specific model authored a commit.

The human-directed workflow recorded in repository reports is:

1. The owner defines the product problem, priorities, visual direction, and
   acceptance constraints.
2. Codex is used as an engineering collaborator for inspection, implementation,
   refactoring, debugging, test execution, and evidence preparation.
3. Automated checks and simulator evidence are used to challenge the result.
4. Failures remain visible; assertions and user functionality are not removed to
   manufacture a pass.
5. The owner retains product, rights, distribution, and final acceptance
   decisions.

User-supplied visual references and iterative review are recorded in
[strict_visual_audit.md](../strict_visual_audit.md) and
[design-qa.md](../design-qa.md). Those files support a human-directed review
process; the submission owner should still confirm personal attribution before
publishing it.

## 1. Premium image pipeline

| Field | Repository-backed account |
|---|---|
| Problem | Image-heavy surfaces needed consistent crops, readable overlays, predictable loading states, and bounded remote-image behavior. |
| Owner requirement | Preserve the premium dark visual direction and content while improving hierarchy, readability, and runtime resilience. |
| Codex-assisted work | The documented workflow is consistent with consolidating image behavior into shared role-aware views and loaders, then auditing their use across the app. |
| Key files | [AppContentImageView.swift](../YouNew/Core/Imaging/AppContentImageView.swift), [ImageLoader.swift](../YouNew/Core/Imaging/ImageLoader.swift), [NLDesignSystem.swift](../YouNew/Core/DesignSystem/Components/NLDesignSystem.swift) |
| Verification | [MediaRegistryTests.swift](../YouNewTests/MediaRegistryTests.swift), [PriorityCityHeroMediaTests.swift](../YouNewTests/PriorityCityHeroMediaTests.swift), and the image checks invoked by [run-static-qa.sh](../scripts/run-static-qa.sh). Final execution status belongs in `FINAL_VALIDATION.md`. |
| Measurable result | The source contains typed image roles and focal points, a 12-second remote request timeout, a 160-object/80 MB content-image memory cache, a separate 100-object/200 MB loader cache, target-pixel downsampling, disk thumbnails, and in-flight request coalescing. These are implementation bounds, not measured performance gains. |
| Owner review | The tracked visual audits compare the supplied reference direction with Home, Guide, Map, Saved, More, Government, and partner surfaces. |
| Limitation | No current Instruments trace proves a memory or decode-latency improvement. The shipped 170-asset catalog passes its rights gate; screenshots, recordings, audio, and public-site media remain separate review scopes. |

Supporting packet:
[EVIDENCE_PREMIUM_IMAGE_PIPELINE.md](../BuildWeekFix/EVIDENCE_PREMIUM_IMAGE_PIPELINE.md).

## 2. Interactive Netherlands map

| Field | Repository-backed account |
|---|---|
| Problem | Newcomer discovery needed a recognizable, interactive Netherlands surface rather than fragile rectangular province targets or a static illustration. |
| Owner requirement | Keep province and city exploration, map gestures, selected state, and typed navigation while meeting the premium visual direction. |
| Codex-assisted work | The documented workflow is consistent with building and refining a SwiftUI/vector map, deterministic hit testing, typed map models, accessibility activation points, and navigation checks. |
| Key files | [NetherlandsInteractiveMapView.swift](../YouNew/Views/NetherlandsInteractiveMapView.swift), [PremiumProvinceHitTesting.swift](../YouNew/Core/Interaction/PremiumProvinceHitTesting.swift), [PremiumNetherlandsMapModel.swift](../YouNew/Models/PremiumNetherlandsMapModel.swift), [AppRouter.swift](../YouNew/App/Navigation/AppRouter.swift) |
| Verification | [PremiumProvinceHitTestingTests.swift](../YouNewTests/PremiumProvinceHitTestingTests.swift), [PremiumNetherlandsMapModelTests.swift](../YouNewTests/PremiumNetherlandsMapModelTests.swift), and map/navigation UI suites. Final UI status is intentionally not stated here. |
| Measurable result | The model contract covers all 12 provinces. The hit-testing suite generates exactly 100 seed-driven interior samples and checks missed and wrong-province selections. |
| Owner review | The reference audit records iterative review of province hierarchy, selected state, and the Map visual surface. |
| Limitation | Geometry tests do not prove root-tab event delivery, physical-device gestures, VoiceOver order, or frame-rate performance. Those remain final runtime gates. |

Supporting packet:
[EVIDENCE_INTERACTIVE_MAP.md](../BuildWeekFix/EVIDENCE_INTERACTIVE_MAP.md).

## 3. Governed content and import platform

| Field | Repository-backed account |
|---|---|
| Problem | Bundled practical information needed stable identifiers, lifecycle state, official-source metadata, deduplication, migrations, and predictable delivery to multiple app surfaces. |
| Owner requirement | Use explicit release gates and deterministic imports; do not silently auto-publish incomplete content. |
| Codex-assisted work | The documented workflow is consistent with schema and validator work, importer hardening, runtime payload generation, migration handling, corrupt-input rejection, and report generation. |
| Key files | [DataProject README](../DataProject/README.md), [releases.json](../DataProject/releases/releases.json), [import-data-project.py](../scripts/import-data-project.py), [DataProjectRuntimeLoader.swift](../YouNew/Services/DataProjectRuntimeLoader.swift), [ContentRepository.swift](../YouNew/Services/ContentRepository.swift) |
| Verification | DataProject schema, release, import, duplicate, relation, migration, and content-governance checks are present. Their final execution status belongs in `FINAL_VALIDATION.md`. |
| Measurable result | The current source tree defines 17 work packages, 27 batch JSON files, and seven release entries. The bundled production payload declares schema version 1 and contains 188 entities, two included releases, and 15 migration mappings. |
| Owner review | Release state and public scope remain explicit approval decisions rather than importer side effects. |
| Limitation | Structural validity is not external-source health. The current network-health report separately records 18 confirmed broken URLs, so no all-links-healthy or publication-ready claim is made. |

Supporting packet:
[EVIDENCE_CONTENT_PLATFORM.md](../BuildWeekFix/EVIDENCE_CONTENT_PLATFORM.md).

## 4. `cities-v0.1.0`

| Field | Repository-backed account |
|---|---|
| Problem | Priority cities needed canonical IDs and one governed release that could replace legacy records without duplicate search, assistant, home, places, or map identities. |
| Owner requirement | Release Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven through the same lifecycle and QA gates as the wider content platform. |
| Codex-assisted work | The documented workflow is consistent with creating the five-record batch, canonical migration mappings, a versioned release definition, runtime projection, and focused release tests. |
| Key files | [releases.json](../DataProject/releases/releases.json), [M1-priority-cities-001.json](../DataProject/batches/WP-06/M1-priority-cities-001.json), [younew-runtime-data.json](../YouNew/Resources/Data/younew-runtime-data.json), [PublishedCitiesDataReleaseTests.swift](../YouNewTests/PublishedCitiesDataReleaseTests.swift) |
| Verification | Focused tests check canonical replacement, duplicate absence, indexed discovery, city coordinates and media presence, consumer data, typed guide routing, and corrupt-dataset rejection. |
| Measurable result | The release definition records five published records. The generated preview selects one release, accepts five records, excludes zero, removes zero technical duplicates, and reports zero broken relations. |
| Owner review | The owner must confirm that a five-city identity release is the intended public scope and that “published” is described as an internal content lifecycle state. |
| Limitation | The preview is structural and generated locally. It does not prove equal content depth, current live links, App Store publication, or independent approver identity. |

Supporting packet:
[EVIDENCE_CITIES_RELEASE.md](../BuildWeekFix/EVIDENCE_CITIES_RELEASE.md).

## 5. QA, accessibility, and release automation

| Field | Repository-backed account |
|---|---|
| Problem | A broad SwiftUI app needed repeatable independent gates instead of historical totals or visual spot checks. |
| Owner requirement | Preserve tests and assertions, classify failures by root cause, avoid artificial sleeps, and retain evidence for build, unit, static, UI, accessibility, content, privacy, and release behavior. |
| Codex-assisted work | The documented workflow is consistent with expanding test coverage, aggregating static checks, recording remediation decisions, running focused diagnostics, and separating bounded evidence from aggregate release status. |
| Key files | [run-static-qa.sh](../scripts/run-static-qa.sh), [YouNewTests](../YouNewTests), [YouNewUITests](../YouNewUITests), [TEST_REMEDIATION.md](../BuildWeekFix/TEST_REMEDIATION.md) |
| Verification | Shared schemes and independent build, unit, UI, static, and DataProject checks are present. Result bundles and final totals are intentionally delegated to `FINAL_VALIDATION.md`. |
| Measurable result | The current aggregate script enumerates 44 command invocations spanning source, accessibility, routing, media, content, privacy, data, and release checks. This is an inventory count, not a claim that all 44 currently pass. |
| Owner review | The owner retains the decision about acceptable remaining limitations and the required physical-device, accessibility, and performance matrix. |
| Limitation | Repository automation does not prove GitHub CI, physical-device certification, complete VoiceOver coverage, or production readiness. |

Supporting packet:
[EVIDENCE_QA_AUTOMATION.md](../BuildWeekFix/EVIDENCE_QA_AUTOMATION.md).

## What this evidence does not prove

- It does not prove that GPT-5.6 powers the in-app assistant.
- It does not prove that Codex authored a particular line or commit.
- It does not prove that all tests pass on the final candidate.
- It does not prove that every external link is healthy.
- It does not prove that all media is cleared for submission.
- It does not prove that a TestFlight or App Store binary matches the repository.

## Evidence still required before submission

- An owner-approved Codex session export or dated task record if stronger
  authorship wording is desired.
- Final preserved build and test artifacts linked to the submitted snapshot.
- Owner confirmation of the human-role wording.
- Owner confirmation of media rights, distribution status, and final acceptance.
