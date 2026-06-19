# Manual Runtime QA Checklist

Last prepared: 2026-06-01

Use this checklist on iOS Simulator or a physical iPhone. Do not mark the app ready based on build success alone. Runtime screenshots are required before design acceptance.

macOS runtime is not accepted as a substitute for iOS runtime QA.

Current handoff state: runtime visual QA is pending because CoreSimulatorService is unavailable in the sandbox. No iOS runtime screenshots are available from this pass.

## Setup

- Build and run the `YouNew` scheme from Xcode.
- Use the same language for the full pass: English, Dutch, or Russian.
- Start from a clean launch if possible.
- Use an iPhone-sized device first, because the floating tab bar risk is highest there.
- Capture screenshots after each screen has fully loaded.

## Required Screenshots

- iOS Home Screen with new app icon
- Home EN
- Home RU
- Right-side menu EN
- Right-side menu RU
- Right-side menu scrolled
- bottom nav RU
- Leiden city page RU
- Amsterdam city page EN
- History page RU
- Culture & Attractions page RU if present
- iPhone SE right-side menu RU
- Cities screen opened from the right-side menu
- Official sources opened from the right-side menu
- Помощь рядом top RU
- Помощь рядом with search section RU
- Help nearby EN
- iPhone SE Помощь рядом RU
- Right-side menu after returning from Map
- Transport guide RU
- Transport guide EN
- Transport guide official sources
- Search NS transport result
- Search OVpay transport result
- New app icon on iOS Home Screen
- In-app YouNew logo on Home
- In-app YouNew logo in right-side menu
- In-app YouNew logo on About
- Primary and secondary button states
- Icon-only back and close buttons
- Source/open-link buttons

## Global Checks

- Theme is stable before and after opening Map / Help nearby.
- Home does not open in a white/light style if the global theme is dark.
- No screen switches to a different visual system after visiting Map.
- Floating tab bar does not cover the last visible content on any screen.
- Tab labels and screen text use the selected language consistently.
- Navigation works between Home, Map, Search, Saved, Explain, and More.
- Tapping More opens a right-side menu panel without changing the visible underlying screen.
- Right-side menu closes with the close button, dim overlay tap, and rightward drag.
- Right-side menu width stays inside the viewport on large and small iPhone sizes.
- Right-side menu uses the city-command-center design: dark navy base, glass panel, subtle route lines, canal/tram-style paths, and glowing nodes without fake map labels.
- Right-side menu quick cards open Map, Cities, First steps, and Official sources.
- Right-side menu scrolls to the bottom without hiding content behind the home indicator.
- Map / Помощь рядом top card is readable, compact, and does not show blurred title overlap.
- Map / Помощь рядом quick routes are not clipped; route chips remain tappable and readable.
- Map / Помощь рядом search section scrolls fully above the floating bottom nav.
- Map / Помощь рядом city selector is full-width and usable.
- Map / Помощь рядом location/privacy card is compact and the location button is visible.
- Transport chip from Help nearby opens the full transport guide, not only a map filter.
- Right-side menu Transport opens the full transport guide.
- Search queries `NS`, `OVpay`, and `Транспорт` open the transport guide result.
- Transport guide source buttons open official source URLs.
- New app icon appears on the iOS Home Screen with no transparent corners or old placeholder art.
- In-app YouNew logo matches the app icon concept and is not used as any city/province symbol.
- Primary, secondary, ghost, icon, tab, menu, card, source, and quick-route buttons show visible pressed states.
- Icon-only back, close, More, source, and saved buttons have localized accessibility labels and 44x44pt hit targets.
- Selecting History from the right-side menu closes the menu and opens History of the Netherlands.
- Selecting Cities from the right-side menu closes the menu and opens the cities screen.
- Selecting Official sources from the right-side menu closes the menu and opens official sources.
- Selecting the current visible tab from the right-side menu closes the menu without duplicate navigation.
- City fallback labels are documented if real city hero, flag, or coat-of-arms assets are missing.

## City Bottom Screenshot Checks

For both Amsterdam and Leiden bottom screenshots, verify all of the following:

- Useful information is fully visible.
- Public transport / GVB is fully visible where applicable.
- Open on map is visible.
- Short history is visible.
- Local highlights are visible.
- Official sources are visible.
- Nothing is hidden behind the floating tab bar.

## Screenshot Log

| Screen | Pass/Fail | Notes |
|---|---|---|
| iOS Home Screen with new app icon |  |  |
| Home EN |  |  |
| Home RU |  |  |
| Map / Help nearby |  |  |
| Amsterdam city page EN |  |  |
| Leiden city page RU |  |  |
| Search |  |  |
| Saved |  |  |
| Explain |  |  |
| More |  |  |
| Right-side menu EN |  |  |
| Right-side menu RU |  |  |
| Right-side menu scrolled |  |  |
| Bottom nav RU |  |  |
| History page RU |  |  |
| Culture & Attractions page RU if present |  |  |
| City detail after closing menu |  |  |
| iPhone SE right-side menu RU |  |  |
| Cities from menu |  |  |
| Official sources from menu |  |  |
| Помощь рядом top RU |  |  |
| Помощь рядом search section RU |  |  |
| Help nearby EN |  |  |
| iPhone SE Помощь рядом RU |  |  |
| Right-side menu after Map |  |  |
| Transport guide RU |  |  |
| Transport guide EN |  |  |
| Transport guide sources |  |  |
| Search NS transport result |  |  |
| Search OVpay transport result |  |  |
| New app icon on iOS Home Screen |  |  |
| In-app logo Home |  |  |
| In-app logo right-side menu |  |  |
| In-app logo About |  |  |
| Primary and secondary button states |  |  |
| Icon-only back and close buttons |  |  |
| Source/open-link buttons |  |  |
| Home visual atmosphere RU |  |  |
| Home visual atmosphere EN |  |  |
| Amsterdam city hero photo |  |  |
| Leiden city hero photo |  |  |
| Province detail hero/fallback |  |  |
| History image source buttons |  |  |
| Transport guide hero photo |  |  |
| Dutch A1-A2 opens from right-side Practical menu |  |  |
| Dutch A1-A2 opens from Information Hub |  |  |
| Dutch A1-A2 module opens |  |  |
| Dutch A1-A2 lesson detail opens |  |  |
| Dutch A1-A2 mini test answer feedback appears |  |  |
| Dutch A1-A2 search for afspraak opens course/module result |  |  |
| KNM related Dutch vocabulary link opens Dutch A1-A2 module |  |  |
| Dutch A1-A2 Russian UI has no raw keys or English module titles |  |  |
| Dutch A1-A2 small iPhone layout has no clipped text or bottom nav overlap |  |  |
| KNM opens from right-side Practical menu |  |  |
| KNM module, lesson, practice, and source sections are visible |  |  |
| Information Hub has no empty visible sections |  |  |
| Cities list and core city detail pages open: Leiden, Amsterdam, Rotterdam, Den Haag, Utrecht, Delft, Haarlem, Groningen, Maastricht, Eindhoven |  |  |
| Province list and present province detail pages open without empty visible sections |  |  |
| Practical guides open: municipality registration, DigiD, healthcare, huisarts, health insurance, transport, housing, banking, official sources checklist |  |  |
| Home scam/safety card opens a real safety guide, not Content not found |  |  |
| Right-side menu visible items all navigate to real screens |  |  |
| Search queries `gemeente`, `BSN`, `DigiD`, `huisarts`, `OVpay`, `NS`, `KNM`, `Dutch A1-A2`, `afspraak` open real destinations |  |  |
| About and Settings have no placeholder, TODO, or mixed-language text |  |  |
| Official Sources background |  |  |
| Search empty state background |  |  |
| Saved empty state background |  |  |
| Image unavailable fallback |  |  |
| Wikimedia source opens from image caption |  |  |

## Final Verdict Rules

If screenshots show overlap:

Final verdict: Not ready for TestFlight. Blocking issue: floating tab bar overlaps content.

If screenshots pass but real city assets are missing:

Final verdict: Conditionally ready for internal TestFlight after final city asset review.

If screenshots pass, navigation works, localization is consistent, and theme is stable:

Final verdict: Ready for internal TestFlight only.

## Required Evidence

Keep the screenshots with filenames that identify the screen and language, for example:

- `home_ru.png`
- `ios_home_screen_app_icon.png`
- `home_en.png`
- `map_ru.png`
- `amsterdam_city_en.png`
- `leiden_city_ru.png`
- `search_ru.png`
- `saved_ru.png`
- `explain_ru.png`
- `more_ru.png`
- `right_menu_en.png`
- `right_menu_ru.png`
- `right_menu_scrolled.png`
- `bottom_nav_ru.png`
- `history_ru.png`
- `culture_attractions_ru.png`
- `city_detail_after_menu_ru.png`
- `iphone_se_right_menu_ru.png`
- `cities_from_menu.png`
- `official_sources_from_menu.png`
- `help_nearby_top_ru.png`
- `help_nearby_search_ru.png`
- `help_nearby_en.png`
- `iphone_se_help_nearby_ru.png`
- `right_menu_after_map.png`
- `transport_guide_ru.png`
- `transport_guide_en.png`
- `transport_guide_sources.png`
- `search_ns_transport.png`
- `search_ovpay_transport.png`
- `dutch_a1_a2_menu_ru.png`
- `dutch_a1_a2_hub_en.png`
- `dutch_a1_a2_module_ru.png`
- `dutch_a1_a2_lesson_en.png`
- `dutch_a1_a2_quiz_feedback.png`
- `dutch_a1_a2_search_afspraak.png`
- `knm_related_dutch_words.png`
- `iphone_se_dutch_a1_a2_ru.png`
- `ios_home_screen_new_app_icon.png`
- `logo_home.png`
- `logo_right_menu.png`
- `logo_about.png`
- `button_states.png`
- `back_close_buttons.png`
- `source_buttons.png`
- `home_atmosphere_ru.png`
- `home_atmosphere_en.png`
- `amsterdam_city_hero_photo.png`
- `leiden_city_hero_photo.png`
- `province_detail_media_fallback.png`
- `history_image_source_buttons.png`
- `transport_hero_photo.png`
- `official_sources_background.png`
- `search_empty_state_background.png`
- `saved_empty_state_background.png`
- `image_unavailable_fallback.png`
- `image_source_open.png`
