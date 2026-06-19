# Final iOS Runtime QA

Last prepared: 2026-06-01

Runtime visual QA:
Not performed. CoreSimulatorService is unavailable in this environment. Visual acceptance must be completed locally on iOS Simulator or physical iPhone.

Static QA and build are passing for this handoff. Do not mark runtime visual QA as passed until this checklist is completed on a large iPhone and a small iPhone with screenshots.

## Accepted Static Status

- `python3 scripts/user-visible-completeness-static-qa.py`: passed
- `python3 scripts/content-static-qa.py`: passed
- `python3 scripts/knm-static-qa.py`: passed
- `python3 scripts/dutch-course-static-qa.py`: passed
- `python3 scripts/place-media-static-qa.py`: passed
- `scripts/run-static-qa.sh`: passed
- Xcode diagnostics for changed Swift files: clean
- Xcode build: passed

## Local QA Steps

Complete these steps on your Mac before capturing screenshots.

**A. Open project**

Open `YouNew.xcodeproj` in Xcode.

**B. Select scheme**

In the scheme selector at the top of Xcode, choose: `YouNew`

**C. Select device**

Run on a large iPhone first, then repeat key screens on a small iPhone:

- Large: iPhone 17 Pro, iPhone 16 Pro, or iPhone 15 Pro (physical or simulator)
- Small: iPhone SE or the smallest available iPhone simulator

**D. Run app locally**

Press the Run button (▶) or use `Cmd+R`. Wait for the app to launch fully on the selected device.

**E. Check required locales**

In the app or in iOS Settings → Language & Region, verify the following locales:

- Russian
- English
- Dutch (if the build declares Dutch support)

## Required Devices

- Large iPhone simulator or physical iPhone (iPhone 17 Pro / 16 Pro / 15 Pro)
- Small iPhone simulator, for example iPhone SE

## Required Locales

- Russian
- English
- Dutch, if supported by the build

## Required Screens

- Home
- Right-side menu
- Information Hub
- Help nearby / Map
- Search
- Saved
- Cities
- Provinces
- Leiden city page
- Amsterdam city page
- KNM
- Dutch A1-A2
- Practical guide detail
- Transport guide
- Healthcare guide
- Municipality registration guide
- DigiD guide
- Official Sources
- History of the Netherlands
- Culture & Attractions
- About / Settings

## Required Screenshots

- `ios_home_screen_app_icon.png` - iOS Home Screen with app icon
- `home_ru.png` - Home RU
- `home_en.png` - Home EN
- `right_side_menu_ru.png` - right-side menu RU
- `right_side_menu_en.png` - right-side menu EN
- `help_nearby_map_ru.png` - Help nearby / Map RU
- `information_hub_ru.png` - Information Hub RU
- `knm_ru_module_list.png` - KNM RU module list
- `knm_ru_practice_question.png` - KNM RU practice question
- `dutch_a1_a2_ru_module_list.png` - Dutch A1-A2 RU module list
- `dutch_a1_a2_ru_lesson_mini_dialogue.png` - Dutch A1-A2 RU lesson with mini-dialogue
- `transport_ru.png` - Transport RU
- `healthcare_ru.png` - Healthcare RU
- `official_sources_ru.png` - Official Sources RU
- `leiden_city_ru.png` - Leiden city page RU
- `amsterdam_city_en.png` - Amsterdam city page EN
- `search_ru_results.png` - Search RU results
- `saved_empty_state_ru.png` - Saved empty state RU
- `history_ru_expanded_card.png` - History RU expanded card
- `culture_attractions_ru.png` - Culture & Attractions RU
- `iphone_se_home_ru.png` - iPhone SE Home RU
- `iphone_se_side_menu_ru.png` - iPhone SE side menu RU
- `iphone_se_knm_ru.png` - iPhone SE KNM RU
- `iphone_se_dutch_a1_a2_ru.png` - iPhone SE Dutch A1-A2 RU

## Runtime Pass Criteria

The app passes runtime QA only if all of the following are true.

### Launch

- App opens without crash.
- App icon is visible and not black or blank.
- App name/brand is correct.

### Navigation

- Bottom tabs work.
- More opens the right-side menu.
- Every visible menu item opens a real screen.
- Back buttons work.
- Close buttons work.
- No dead buttons.

### Layout

- No horizontal overflow.
- No clipped text.
- No bottom nav overlap.
- Russian text wraps correctly.
- Small iPhone layout is usable.
- Cards fit viewport.
- Images do not shift layout.

### Content

- No empty visible blocks except intentional user-data empty states.
- No TODO/debug text.
- No raw localization keys.
- No mixed-language screens.
- KNM modules render.
- KNM questions work.
- Dutch A1-A2 lessons render.
- Mini-dialogues render.
- Practical guide common mistakes render.
- Useful Dutch words render.
- What to do first flows render.

### Media

- Official city flags/coats of arms are not fake.
- Images load or show clean fallback.
- App logo is not used as official city media.
- Source/attribution sections are reachable.

### Search

- Search `KNM` opens KNM.
- Search `DigiD` finds guide or KNM topic.
- Search `huisarts` finds healthcare or Dutch module.
- Search `NS` or `OVpay` finds transport.
- No search result opens a dead route.

## Screen Checklist

| Area | Pass/Fail | Notes |
|---|---|---|
| iOS Home Screen app icon |  |  |
| Home RU |  |  |
| Home EN |  |  |
| Right-side menu RU |  |  |
| Right-side menu EN |  |  |
| Bottom navigation |  |  |
| Information Hub RU |  |  |
| Help nearby / Map RU |  |  |
| Search RU |  |  |
| Saved empty state RU |  |  |
| Cities screen RU |  |  |
| Provinces screen RU |  |  |
| Leiden city page RU |  |  |
| Amsterdam city page EN |  |  |
| KNM RU module list |  |  |
| KNM RU practice question |  |  |
| Dutch A1-A2 RU module list |  |  |
| Dutch A1-A2 RU lesson with mini-dialogue |  |  |
| Practical guide detail RU |  |  |
| Transport RU |  |  |
| Healthcare RU |  |  |
| Municipality registration guide RU |  |  |
| DigiD guide RU |  |  |
| Official Sources RU |  |  |
| History RU expanded card |  |  |
| Culture & Attractions RU |  |  |
| About / Settings RU |  |  |
| Small iPhone Home RU |  |  |
| Small iPhone side menu RU |  |  |
| Small iPhone KNM RU |  |  |
| Small iPhone Dutch A1-A2 RU |  |  |

## Search Checks

| Query | Expected Result | Pass/Fail |
|---|---|---|
| `KNM` | KNM opens |  |
| `DigiD` | DigiD guide or KNM government/safety topic opens |  |
| `huisarts` | Healthcare guide or Dutch healthcare module opens |  |
| `NS` | Transport result opens |  |
| `OVpay` | Transport result opens |  |
| `gemeente` | Municipality/practical/Dutch result opens |  |
| `BSN` | BSN/municipality result opens |  |
| `afspraak` | Dutch A1-A2 municipality/time module result opens |  |

## Intentional Empty States

These empty states are acceptable:

- Saved is empty until the user saves items.
- Documents are empty until the user adds documents, if this feature exists.
- Search history is empty until the user searches.
- User-data arrays may be optional/default-empty.
- Relationship arrays may be optional when no related content exists.

Every intentionally empty user-facing screen must have:

- localized title,
- short explanation,
- useful action where possible,
- no TODO/debug text,
- no raw localization keys,
- no mixed-language UI.

## Route/Action Sanity

Use `QA/ROUTE_ACTION_SANITY_REPORT.md` during runtime QA. Every visible route/action listed there must open the stated destination. Static QA must fail if the report is missing or contains `destination exists: no`.

## Fail Conditions

Mark runtime QA as failed if any of these occur:

- Crash on launch or navigation.
- Any visible button does nothing.
- Any visible menu item opens `Content not found`.
- Raw localization key is visible.
- TODO/debug/placeholder text is visible.
- Russian UI shows English cards or headings unexpectedly.
- Text clips or overlaps on small iPhone.
- Bottom nav covers quiz controls, source buttons, or final content.
- Image area is blank without a clean fallback.
- App icon is black, blank, transparent-cornered, or old artwork.
- Official city symbol is wrong or replaced with fake media.

## Launch Decision

Current recommendation:

Internal TestFlight only after local runtime QA passes.

External TestFlight only after runtime visual bugs are fixed.

App Store is not ready yet.

Do not mark App Store ready until:

- runtime visual QA passes,
- screenshots are captured,
- app icon is verified on Home Screen,
- signing/archive is verified,
- privacy policy URL exists,
- support URL exists,
- App Store metadata is prepared,
- final media/license attribution is checked.
