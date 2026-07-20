# Owner Actions Before Build Week Submission

Audit window: 2026-07-19–2026-07-20 (Europe/Amsterdam); finalized 2026-07-20
No action below was executed automatically.

## P0 — submission blockers

1. **Freeze the intended product state in Git.** Review the 119 modified, 2 deleted, and hundreds of untracked paths. Commit only the intended source, DataProject runtime payload, tests, reports and CI. Do not publish local caches/diagnostics.
   - Current portability trap: `.gitignore:40` matches `BuildWeekAudit/TECHNICAL_AUDIT.md` and `BuildWeekAudit/REPOSITORY_SECURITY_AUDIT.md`; explicitly include or narrowly exempt the intended audit package during the later repository-curation phase.
   - Expected evidence: final commit hash; `git status --short` clean; current app files visible from `git ls-files`.

2. **Create/configure the judge repository.** Add a GitHub remote, select public/private visibility deliberately, and provide judges access.
   - Expected evidence: sanitized remote URL, visibility screenshot, judge access test from a separate account/session.

3. **Make the repository reproducible.** Clone the final remote into a new directory/machine and execute documented package resolution, build, unit/static and UI commands.
   - Expected evidence: clean-clone transcript and artifacts tied to the final commit.

4. **Remove publication-risk artifacts.** Exclude/review `TestArtifacts/`, `*.xcresult`, device logs, archives, provisioning/certificate files and `.env*`; replace tracked machine-specific paths with portable placeholders.
   - Review the untracked `DataProject/staging/amsterdam-01-cache.json` staging cache and every project-domain contact address; publish only intentional, reproducible data and mailboxes whose public ownership is confirmed.
   - Expected evidence: updated `.gitignore`, final status, targeted+dedicated secret scan, privacy review of Git history.

5. **Resolve licensing.** Add repository LICENSE/NOTICE and complete image/source/license/creator/redistribution metadata. Replace assets whose rights cannot be proven.
   - Expected evidence: license files, complete asset manifest, zero unresolved items in the image-rights audit.

6. **Fix current quality gates.** Resolve four unit failures and five failing static commands representing four distinct issues:
   - `KnowledgeDataGovernanceTests.partnerVerificationRequiresRealWebsiteAndStatus`
   - `KnowledgeIndexTests.netherlandsKnowledgeDatabaseProvidesUnifiedDataPlatform`
   - `KnowledgeIndexTests.allGuideArticlesCitiesAndProvincesAreIndexedForAI`
   - `KnowledgeIndexTests.localPartnersAreIndexedForEverySupportedCityAndCoreCategory`
   - ambient background motion wiring (reported by both base and brand gates)
   - global AI launcher visibility rule
   - missing persona route filters
   - Home Transport tile route
   - Expected evidence: fresh 450/450 unit `.xcresult` and aggregate `scripts/run-static-qa.sh` exit 0 on final commit. The current performance static gate already passes; a separate runtime profile is still required for performance claims.

7. **Choose and state the AI product truth.** Current assistant is local deterministic MOCK/PARTIAL. Either submit it honestly as a local guided knowledge assistant, or implement and verify an actual backend/model path.
   - Expected evidence for local claim: README/demo language matching `AI_ASSISTANT_ARCHITECTURE.md`.
   - Expected evidence for live claim: reachable proxy, compatible schema, server-held key, provider/model log, privacy disclosure, failure tests, uncut demo.
   - Privacy prerequisite in either mode: evaluate/redact sensitive input before persistence, define whether “clear chat” also removes the answer cache, and add retention tests.

8. **Do not claim GPT-5.6 without evidence.** If GPT-5.6 is a Build Week requirement/claim, provide repository/runtime or ChatGPT evidence showing the exact model and date.
   - Expected evidence: visible model selection/badge or backend provider log, tied to the demonstrated request.

9. **Implement and test the exact demo story.** The address/newcomer one-shot prompt must reliably cover gemeente registration, BSN, DigiD, insurance, huisarts and basic administration, with correct in-app routes and sources.
   - Expected evidence: exact unit/integration/UI test plus three cold-launch recordings. Until then use only the two narrower BSN/health flows described in the AI report.

10. **Repair and complete current runtime QA.** The full frozen UI suite is complete but red at 80/86. Repair the six recorded failures, then rerun it alongside VoiceOver, Dynamic Type, offline, device matrix, memory/performance and navigation soak.
    - Expected evidence: green current `.xcresult`, screenshots, video, Instruments trace and memory graph; no historical-only substitution.

## P1 — App Store/TestFlight and judge package

11. **Create a valid distribution archive.** Use Release with correct distribution signing/entitlements and validate in Organizer.
    - Expected evidence: archive validation, entitlements and signing summary with sensitive identifiers redacted.

12. **Verify TestFlight/App Store externally.** Repository reports cannot prove upload/publication.
    - Provide: App Store Connect app record; TestFlight build processing/group; public listing if any; review/submission state.

13. **Reconcile metadata.** Update stale `APP_STORE_PACKAGE.md` identity/version, add real release notes, support/privacy URLs and final App Privacy answers.
    - Expected evidence: metadata matching bundle `nl.younew.app`, version 1.1 (5), or the intentionally bumped final version.

14. **Write a judge-grade README.** Include product story, honest AI architecture/status, Xcode/runtime, package resolution, required/optional config names, build/test commands, clean-clone result, exact demo script, limitations, license/credits and owner role.
    - Expected evidence: a judge can build and run from README alone without private coaching.

15. **Commit CI.** Add iOS build/unit/static gates; keep DataProject health; do not auto-publish canonical content.
    - Expected evidence: green CI URL on final commit with retained result artifacts.

16. **Reconcile DataProject reports.** Commit intended manifests/runtime payload; update milestone/status/dashboard so five-versus-188 publication counts are not contradictory.
    - Expected evidence: regenerated reports from final inputs, clean diff on repeat generation, stable release fingerprint retained privately.

17. **Run a fresh live link and semantic-source audit.** Stored data-health evidence is not a current live crawl and HTTPS syntax is not semantic grounding.
    - Expected evidence: timestamped result statuses plus sampled human source-to-claim review.

## P2 — narrative and submission polish

18. **Collect ChatGPT workflow evidence.** Export/screenshoot dated conversations showing founder requirements, reference choices, rejected results, iteration, Codex report analysis and submission preparation. Redact unrelated/private information.

19. **Describe the owner accurately.** Recommended wording:

    > Human founder, product owner, requirements author, reviewer, and final decision-maker working with AI as a product and engineering team.

    The repository supports product-owner/reviewer iteration; conversation evidence should substantiate personal authorship of specific requirements and final decisions. Do not claim the owner personally wrote code without evidence.

20. **Use the authorship-safe Codex statement.**

    > The repository contains implementation and reports consistent with the documented Codex-assisted workflow.

21. **Record the demo video.** No video file exists now. Record an uncut cold-launch flow after the final build is frozen, show privacy/source behavior, and avoid unsupported GPT/live claims.
    - Expected evidence: video file, script, final commit/build displayed, three-repeat rehearsal log.

22. **Prepare final submission checklist.** Record repository URL/visibility, build hash, TestFlight/public status, demo URL/file, test totals, known limitations and owner/AI role statement.

## Stop/go criteria

Submission is technically safe only when all are true:

- final tree/remote is reproducible;
- no secret/PII/artifact/license blockers remain;
- unit and static suites are green;
- a current UI/runtime matrix covers the demo;
- AI claims match the actual runtime/model;
- README and demo need no hidden manual setup;
- external distribution status is either proven or honestly marked absent;
- video and ChatGPT/Codex evidence are attached.
