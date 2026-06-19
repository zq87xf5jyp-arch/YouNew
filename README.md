# YouNew

YouNew is a local-first SwiftUI app for newcomers in the Netherlands. It organizes practical guidance around rules, fines, documents, official sources, nearby help, checklists, saved items, and privacy-safe personal preparation.

## Product Scope

- Home dashboard for newcomer priorities
- Fines & Rules guidance with official-source reminders
- Official source directory
- Personal checklist and saved items
- Local document organizer
- Search, assistant, map, and translator utilities
- Privacy & Data Control screen for export and deletion
- Educational legal safety disclaimers throughout sensitive flows

## Privacy Position

- Local-first by default
- No analytics SDKs
- No advertising SDKs
- No hidden server sync
- Imported documents stay in local app storage
- User can export a JSON privacy dossier
- User can delete local personal data and app documents

The export intentionally includes document metadata, not the document file contents.

## Legal Safety

The app provides educational information only. It is not legal advice and does not replace a lawyer, gemeente, IND, CJIB, Belastingdienst, RDW, healthcare provider, or any official institution. Fine amounts, deadlines, and procedures can change. Users should verify important decisions through official sources.

## Setup

1. Open `YouNew.xcodeproj` in Xcode.
2. Select the app target and a simulator or device.
3. Build and run.
4. Use `-uiTesting -launchLanguage en -uiTestingStartTab home` for UI-test launches.

## QA Checklist

- Run static gates before accepting content or media changes:
  - `python3 scripts/static-qa.py`
  - `python3 scripts/history-media-static-qa.py`
  - `python3 scripts/brand-static-qa.py`
- `history-media-static-qa.py` is intentionally simulator-free. It must not require iOS Simulator, CoreSimulator, macOS app runtime, UI test runner provisioning, or a physical device.
- iPhone SE layout
- Modern iPhone Pro layout
- iPad split view
- macOS resize behavior
- Light and dark mode
- Dynamic Type, including accessibility sizes
- Fresh install onboarding
- Export/delete data flow
- Document import and delete
- Navigation stress across tabs
- Offline usage
- Corrupted local metadata recovery

## Known Limitations

- Guidance content is mock/static MVP content and must be reviewed before public launch.
- The assistant is currently mock/local behavior, not a verified legal expert.
- App Store privacy nutrition labels still need final review against the shipping binary.
- Screenshots, App Store copy, privacy policy URL, support URL, and legal review are required before submission.

## Buyer Handover Notes

- Do not market the app as legal advice.
- Do not claim official government affiliation.
- Do not claim live fine accuracy unless a maintained official-data pipeline is added.
- Review all localized copy before commercial release.
- Replace placeholder/demo content only with licensed, verified, and source-attributed content.
