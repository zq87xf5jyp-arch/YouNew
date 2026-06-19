# Release Checklist

## App Store Review

- Confirm app name, subtitle, privacy policy URL, support URL, and age rating.
- Confirm App Store Connect privacy nutrition labels match the final binary.
- Confirm `PrivacyInfo.xcprivacy` is included in the app target.
- Confirm no official government affiliation is implied.
- Confirm all legal content says educational information only and not legal advice.
- Confirm no claims of live fine accuracy unless backed by maintained official data.

## Device QA

- Required static gate: run `python3 scripts/static-qa.py` before release or handoff.
- Required static gate: run `python3 scripts/history-media-static-qa.py` before accepting any history media registry, source attribution, or image rendering metadata change.
- Required static gate: run `python3 scripts/brand-static-qa.py` before release. This includes the history media static QA.
- Static media QA must remain independent of iOS Simulator, CoreSimulator, macOS runtime QA, UI test runner provisioning, and physical devices.
- iPhone SE
- Current Pro-size iPhone
- iPad full screen
- iPad split view
- macOS window resize if distributing on macOS
- Light mode
- Dark mode
- Dynamic Type through accessibility sizes
- Landscape where supported
- Offline mode
- Fresh install
- Delete all data
- Export data
- Import, view, and delete documents
- Corrupted document metadata recovery
- Rapid tab switching
- Repeated modal presentation

## Buyer Handover

- Provide source project and Xcode version used for validation.
- Provide known limitations and mock-content notes.
- Provide screenshots checklist and demo script.
- Provide privacy/security notes.
- Provide legal disclaimer requirements.
- Do not include fake users, fake revenue, or unverified App Store claims.

## Demo Flow

1. Fresh launch and onboarding.
2. Home dashboard and status selection.
3. Fines & Rules card hierarchy and official-source reminders.
4. Documents local-first organizer.
5. Privacy & Data Control export.
6. Delete all personal data.
7. Legal Disclaimer screen.
8. Offline navigation through saved/static content.
