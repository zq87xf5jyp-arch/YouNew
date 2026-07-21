# Known limitations

Evidence cutoff: 21 July 2026  
Scope: bounded YouNew Build Week candidate, not production readiness

| Area | Current limitation | Safe demo handling |
|---|---|---|
| Live AI | No candidate artifact proves a configured OpenAI backend, successful provider request, or GPT-5.6 inference. | Call it a deterministic local guided assistant backed by structured workflows and indexed YouNew knowledge. |
| Full UI | Current finalized aggregate is 79/87, 8 failed, 0 skipped. | Never say all tests pass. Cite `FINAL_VALIDATION.md`. |
| Reproduced UI failures | Isolated rerun is 5/8. Guide later times out at Transport scroll/UI query; root latency records 191.158 ms against `<100 ms`; Assistant `Open Leiden` does not reach city detail. | Exclude the selected-city shortcut and long Guide-to-Transport composite path. Use the bounded demo flow. |
| Map/root | The original tab-delivery blocker is fixed, but performance is not universally below 100 ms and one preserved calibration was 99/100 before an unchanged 100/100 repeat. | Say delivery is fixed in the tested simulator configuration; disclose residual latency/startup sensitivity. |
| Static/link health | Static QA is 43/44 known gates. Current health report has 18 confirmed broken, 623 restricted, and 32 transient among 2,494 URLs. | Pre-check the exact source used in the recording. Do not claim all links work. |
| Content completeness | Content depth varies; governed records include drafts/review items and explicit gaps. | Demonstrate only the verified BSN/address/DigiD guide and one governed city. |
| Distribution | No evidence ties this workspace to the current TestFlight or App Store binary. The configured remote was not verified for visibility or synchronization. | Present a local candidate only. Owner must supply distribution evidence. |
| Media rights | Attribution infrastructure exists, but clearance is incomplete for all media and captures. | Owner must approve recording media or remove disputed assets. |
| Device/accessibility coverage | Current UI evidence uses one iPhone 17 Pro Simulator on iOS 26.5. No complete physical-device, VoiceOver, older-OS, thermal, memory, or offline matrix exists. | Describe the exact simulator environment; do not claim broad certification or full conformance. |
| Repository reproducibility | The worktree contains pre-existing and final modified/untracked files. The exact final dirty state has not been clean-clone reproduced. | Owner must review the handoff and approve any future commit/push. |
| External advice | Stored information can change and does not replace competent legal, medical, immigration, tax, or financial advice. | Keep the informational disclaimer and show official-source actions. |

## Explicitly unsupported claims

- GPT-5.6 powers the in-app assistant.
- The candidate uses a verified live OpenAI assistant.
- All tests or links pass.
- The app is production ready.
- All content is complete or all images are fully licensed.
- The audited source matches the latest TestFlight/App Store build.
- The exact candidate can be clean-cloned and built.

## Manual owner gates

- Provide App Store/TestFlight screenshots and parity evidence.
- Confirm media rights or remove disputed media.
- Review the dirty tree and existing GitHub remote.
- Explicitly approve a future commit and push.
- Record/upload the bounded demo video, paste the reviewed Devpost text, and submit.
