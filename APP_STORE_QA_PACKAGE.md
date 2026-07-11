# YouNew App Store QA Package

Date: 2026-07-11
Version: 1.1 (5)
Bundle ID: `nl.younew.app`
Verdict: **NOT READY TO SUBMIT**

## Executive summary

The native Release archive builds and is structurally valid. The complete unit suite passes. Search no longer hides cross-profile content, dead deep links are rejected, repeated search work was reduced, and the Swift 6 connectivity warning was fixed.

Submission is still blocked because the archive is signed with an Apple Development certificate and device provisioning profile, the Xcode UI-test launcher is broken in this environment, and physical-device VoiceOver/microphone testing has not been completed.

## Verification matrix

| Check | Result | Evidence |
| --- | --- | --- |
| Static QA | PASS | All localization, route, privacy, accessibility, performance, search, content, AI, media and visual gates passed |
| Localization | PASS | 582/582 keys in EN, NL and RU |
| Unit tests | PASS | 378 passed, 0 failed, 0 skipped; `/tmp/YouNewAppStoreReady-Unit-Green.xcresult` |
| Canonical content access | PASS | Profile metadata ranks content and no longer blocks Search/Saved routes |
| Dead-route validation | PASS | Missing KNM/Dutch modules and missing entity-backed destinations are rejected |
| Local search budget | PASS | Targeted performance test passes after precomputed keyword/source normalization |
| Swift concurrency build warning | PASS | `NWPathMonitor` callback no longer captures the mutable weak variable across concurrency domains |
| Release archive | PASS | `/tmp/YouNew-AppStoreReady.xcarchive`; arm64, Release, hardened runtime |
| Archive structure | PASS | `codesign --verify`, Info.plist lint and embedded privacy manifest pass |
| App Store distribution signature | FAIL | Signed by Apple Development; `get-task-allow=true`; device provisioning profile |
| UI automation | BLOCKED | Xcode reports `DebuggerLLDB.DebuggerVersionStore: no debugger version` before app launch |
| Simulator launch memory smoke | PASS WITH LIMITATION | 59.2 MB footprint, 61.3 MB peak, 0 leaks; launch-only flow, not a navigation stress run |
| Instruments trace | BLOCKED | App Launch recording is created but export fails with `Document Missing Template Error` |
| Physical microphone | NOT TESTED | Connected iPhone is listed offline |
| Physical VoiceOver | NOT TESTED | Connected iPhone is listed offline |
| App Store metadata | INCOMPLETE | Privacy policy URL, support URL, screenshots, age rating and privacy nutrition labels are not verified |

## Fixes completed

1. Full XCTest execution now uses the dedicated sequential `YouNewUnitTests` scheme rather than the combined parallel app scheme.
2. Updated tests that incorrectly required profile-based content blocking, the obsolete `Places`/`Сохран.` labels, and the former Assistant tab alias.
3. `RelatedContentEngine` now keeps audience-independent access while verifying that entity-backed routes resolve to real canonical objects.
4. Search shows every category and every relevant item regardless of profile; persona remains a ranking signal only.
5. `KnowledgeIndex` caches normalized keyword and source strings instead of rebuilding them for every search.
6. Fixed the Swift 6 concurrency warning in `ConnectivityStatus`.

## Confirmed blockers

### High — Distribution signing

- Expected: Apple Distribution certificate, App Store provisioning, `get-task-allow=false`.
- Actual: Apple Development certificate, team provisioning profile tied to one device, `get-task-allow=true`.
- Required action: install/select the App Store distribution credentials, create a new archive, export or upload it, and run `scripts/validate-release-archive.sh` against that archive.

### High — Physical device QA

- Required flows: microphone allow/deny/re-enable, live speech transcription, leaving Assistant while recording, VoiceOver focus order, accessibility Dynamic Type, camera permission, offline recovery and notification permission.
- Actual: the registered iPhone is offline; none of these checks can be truthfully marked PASS.

### High — UI automation environment

- Expected: root-navigation and Accessibility XXXL UI tests launch and finish.
- Actual: Xcode fails before launch with `DebuggerVersionStore: no debugger version` under both LLDB and attempted non-LLDB scheme configuration.
- Required action: repair/reinstall the active Xcode debugger components or run the UI suite on a clean CI/Xcode host and retain the `.xcresult`.

### Medium — Performance evidence

- Static performance and the local-search budget pass.
- Launch-only memory smoke reports 59.2 MB footprint, 61.3 MB peak and zero detected leaks.
- App Launch trace export is invalid because Instruments reports a missing template. FPS >55, launch <3 s and navigation-heavy leak behavior remain unproven.

### Medium — Store metadata

The repository explicitly says that privacy policy URL, support URL, screenshots, localized store copy, age rating and privacy nutrition labels still require review. `contact@younew.nl` appears only as a network User-Agent contact and is not proof of a working support channel.

## Physical-device checklist

- [ ] Fresh install on a supported iPhone running iOS 17.6 or later
- [ ] VoiceOver: five tabs, Home blocks, Search results, Map markers, Saved, More and Assistant composer
- [ ] Accessibility Dynamic Type and Reduce Motion
- [ ] Microphone permission allow, deny and Settings recovery
- [ ] Speech recognition in EN, NL and RU
- [ ] Leave Assistant during recording; verify the microphone indicator stops
- [ ] Camera permission and document scan flow
- [ ] Location permission allow/deny and Map fallback
- [ ] Offline launch, cached content, Search, Saved and reconnect
- [ ] Notification permission and local reminder delivery
- [ ] Background/foreground, memory warning and repeated tab switching

## App Store Connect checklist

- [ ] Apple Distribution certificate and App Store provisioning profile
- [ ] Distribution archive passes `scripts/validate-release-archive.sh`
- [ ] Upload validation succeeds in Xcode Organizer/App Store Connect
- [ ] Privacy Policy URL and Support URL are live
- [ ] App privacy answers match the final binary and `PrivacyInfo.xcprivacy`
- [ ] Localized description, keywords and screenshots are supplied
- [ ] Age rating, copyright and review contact are complete
- [ ] Review notes explain microphone, speech recognition, location and camera flows
- [ ] No submission until the physical-device checklist and clean-host UI suite are attached

## Final decision

The software-quality gate is substantially improved and the unit suite is fully green, but the binary is not App Store-submittable with its current development signature. Do not tag or push a release as “App Store Ready” until distribution signing, physical-device QA, UI automation, performance traces and store metadata are complete.
