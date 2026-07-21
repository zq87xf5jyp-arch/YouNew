# Known Limitations

Evidence cutoff: 21 July 2026  
Scope: YouNew Build Week candidate, not a production-readiness assessment

## Submission boundary

The candidate should be judged on the implemented local demo flow and the final
preserved validation artifacts. Historical results, source-code capability, and
internal release metadata are not substitutes for a current end-to-end result.

| Area | Current limitation | Demo impact / safe handling | Evidence or owner action |
|---|---|---|---|
| Live AI | The repository contains optional bounded backend-client code, but no candidate artifact proves a configured backend, a successful OpenAI request, or GPT-5.6 inference. | Demonstrate only the local deterministic guided assistant. Do not use live-AI or generative-answer wording. | [AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md](AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md). A live claim would require separately reviewed backend, privacy, provider, model, and runtime evidence. |
| Content completeness | Content depth and completion vary by topic, city, and surface. Some non-demo content can be sparse or unfinished. | Keep the judge path to the reproduced BSN → address → DigiD journey, its guide, Map, and one governed city. Do not say all content is complete. | Final manual smoke test; owner editorial review. |
| External links | `DataProject/reports/data-health.json`, generated 20 July 2026, has status `attention_required`: 18 confirmed broken URLs, 1,821 reachable, 623 access-restricted, and 32 transient failures out of 2,494 checked URLs. | Pre-check the exact BSN/DigiD demo source. A visible stored source record does not prove current reachability. | [data-health.json](../DataProject/reports/data-health.json). Remediate or explicitly retain all remaining broken links. |
| Map/root-tab delivery | A finalized pre-fix artifact proved interception. The targeted post-fix simulator bundle now passes 3/3, including Leiden, Middelburg, and 10/10 first-tap Map ↔ Home transitions. This is not physical-device or all-map certification. | Use the tested path and repeat one manual first-tap smoke before recording. If it fails, stop the recording and reopen the blocker. | [UI_BASELINE.md](../BuildWeekFinal/UI_BASELINE.md), [MAP_TAB_BLOCKER_FIX.md](../BuildWeekFinal/MAP_TAB_BLOCKER_FIX.md), `/private/tmp/YouNewBuildWeekMapOverlayFix.xcresult`, and [FINAL_VALIDATION.md](FINAL_VALIDATION.md). |
| Current test totals | The latest HEAD control UI run was interrupted before its `.xcresult` finalized. Earlier counts are historical and cannot be presented as current. Unit, static, UI, and data totals are unresolved until the final candidate run closes. | Never say “all tests pass.” Use only the totals and artifact paths in `FINAL_VALIDATION.md`. | [UI_BASELINE.md](../BuildWeekFinal/UI_BASELINE.md); final build logs and `.xcresult` bundles. |
| Remaining failures | The Guide placeholder and search-focus defects have targeted fixes and PASS evidence; the city/category activation loss was not reproduced in four focused runs and was not changed. Aggregate confirmation remains pending. | Avoid the non-primary cafés route in the video. Do not hide or disable a failing test. | [REMAINING_FAILURES.md](../BuildWeekFinal/REMAINING_FAILURES.md) and [FINAL_VALIDATION.md](FINAL_VALIDATION.md). |
| Distribution | No evidence ties this checkout to a current TestFlight or App Store binary. The local Git repository has no configured remote. | Present a local candidate build only. Do not claim the submitted binary is in TestFlight, the App Store, or a public repository. | Owner must supply distribution screenshots and separately approve repository creation, commit, remote, and push. |
| Media rights | Media manifests and attribution metadata exist, but clearance is not complete for all media surfaces and captures. | Use only owner-reviewed demo media. Do not claim that every image is fully licensed. | Owner rights review; remove or replace disputed assets before publication. |
| Device coverage | The latest preserved UI evidence used an iPhone 17 Pro simulator on iOS 26.5. A final physical-device matrix and broader OS/device coverage are not yet evidenced. | Describe simulator validation precisely. Do not imply broad device certification. | Record final environment in `FINAL_VALIDATION.md`; owner may add physical-device evidence. |
| Accessibility | The repository has accessibility checks, but a complete manual VoiceOver pass on a physical device is not evidenced. The interrupted run also observed one large-text search focus failure. | Do not claim full accessibility conformance. Preserve labels, Dynamic Type behavior, and the final known failure status. | Final targeted accessibility tests plus owner VoiceOver/manual review. |
| External advice | Stored sources and structured guides can change and do not replace legal, medical, immigration, tax, or financial professionals. | Describe the app as practical navigation and source discovery, not official advice. | Re-check critical sources and dates before release. |
| Repository reproducibility | The owner workspace contains substantial pre-existing modified and untracked work. A current clean-clone build of the final candidate has not yet been established. | Provide the exact candidate commit/tree state and local artifacts. Do not claim clean-clone reproducibility until it is separately proved. | `REPOSITORY_HANDOFF.md` and `FINAL_VALIDATION.md`. |

## Explicitly unsupported claims

- GPT-5.6 powers the in-app assistant.
- The candidate uses a live OpenAI assistant.
- All tests pass.
- All content is complete or all external links are healthy.
- All images are fully licensed.
- The app is production ready.
- The audited source matches the latest TestFlight or App Store build.
- The repository can be clean-cloned and built, until that exact candidate is
  reproduced.

## Manual gates owned outside this engineering pass

- Confirm or remove media with unresolved rights.
- Provide App Store/TestFlight evidence if it is intended for the submission.
- Run and document a physical-device and VoiceOver review if those claims are
  desired.
- Approve the exact candidate commit, GitHub repository creation, remote, and
  push separately.
- Record and upload the demo video and submit the final application.
