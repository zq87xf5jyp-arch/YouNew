# TESTFLIGHT_CHECKLIST

Date: 2026-06-11  
Scope: First TestFlight release package.

## Build Information

- App: YouNew.nl
- Version: 1.0
- Build: 1
- Bundle identifier in project: `com.company.younew`
- Minimum iOS target: 17.6
- Signing/upload status: not verified in this pass

## Pre-Upload Blocking Checklist

- [ ] Run successful Release archive in Xcode.
- [ ] Confirm App Store Connect app record and bundle identifier.
- [ ] Confirm signing team and provisioning profile.
- [ ] Resolve or retire failing `scripts/image-runtime-data-qa.py` gate.
- [ ] Confirm App Store Connect privacy labels match AI backend behavior.
- [ ] Confirm beta notes disclose AI, translation, OCR, and remote image limitations.
- [ ] Run manual smoke test on physical iPhone SE-class device.

## Draft TestFlight Release Notes

Initial beta for YouNew.nl, a newcomer guide for life in the Netherlands.

Included in this beta:

- Home dashboard for newcomer tasks
- Search across guide content
- Netherlands map, cities, and provinces
- Government, transport, housing, healthcare, and emergency information
- Saved items/bookmarks
- AI Assistant with safety guidance and official-source reminders
- Settings, privacy controls, and onboarding

## Known Issues For Testers

- AI Assistant may use a local fallback response if the backend proxy is not configured or unavailable.
- Translation and OCR flows may return local draft/unavailable responses rather than production service output.
- Some remote imagery depends on network availability and cache state.
- Apple Maps handoff should be checked from Map and nearby-place actions.
- Runtime image fixes are assumed manually verified on a physical device, but this pass did not capture fresh screenshots.

## Required Test Scenarios

### First Launch And Onboarding

1. Install fresh build.
2. Open app.
3. Complete onboarding.
4. Force quit and relaunch.
5. Verify onboarding does not appear again unless reset from Settings.

### Home

1. Open Home.
2. Scroll top to bottom.
3. Open each major category.
4. Return to Home without tab state corruption.

### Search

1. Search for `DigiD`, `housing`, `doctor`, `emergency`, and a city name.
2. Open result details.
3. Verify empty-state copy for a nonsense query.

### Map

1. Open Map.
2. Pan and zoom.
3. Open a province card.
4. Open a city card.
5. Tap directions/open-in-Maps actions.

### Cities And Provinces

1. Open Amsterdam, Rotterdam, Den Haag, Leiden, Utrecht, Groningen, Eindhoven, Maastricht, Haarlem, Arnhem, Nijmegen, and Zwolle.
2. Verify hero image loads.
3. Verify municipality/province labels match the selected city.
4. Open province modal and city card carousel.

### Government Services

1. Open Government Services from Home.
2. Open DigiD, municipality, tax, residence, and document guide flows.
3. Verify official-source links open.

### Transport, Housing, Healthcare, Emergency

1. Open each category from Home.
2. Open at least one detail item.
3. Verify no empty screen and no dead-end navigation.

### Saved Items

1. Save one city or guide item.
2. Open Saved tab.
3. Open saved detail.
4. Remove saved item.
5. Verify empty state.

### AI Assistant

1. Send a normal newcomer question.
2. Send a sensitive-data-like message and verify warning/block behavior.
3. Test backend unavailable/offline behavior.
4. Verify sources and safety note display.

### Settings And Privacy

1. Change language if available.
2. Reset onboarding.
3. Clear saved/privacy data if available.
4. Relaunch and verify state.

### Accessibility

1. Test Dynamic Type.
2. Test VoiceOver labels on primary tabs and action buttons.
3. Test Reduce Motion.
4. Test light and dark mode.

## Areas Requiring Tester Feedback

- Can newcomers find emergency, healthcare, housing, and government information within three taps from Home?
- Does map scrolling feel natural on physical devices?
- Are AI Assistant answers useful without feeling authoritative beyond official sources?
- Do city/province pages feel trustworthy and locally correct?
- Are privacy and disclaimer messages clear without overwhelming the user?
