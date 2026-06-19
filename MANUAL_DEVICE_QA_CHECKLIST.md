# Manual Device QA Checklist

Generated: 2026-06-10
Reason: simulator runtimes are unavailable in this environment, so final release QA must be completed on a physical device or a working local simulator.

## Required Devices

Run the checklist on:

- iPhone SE size class
- iPhone 15/17 Pro Max size class
- iPad regular width

Run at least one pass with:

- Fresh install
- Relaunch after onboarding
- Airplane mode enabled for fallback checks
- VoiceOver spot check enabled
- Large Dynamic Type enabled

## Global Pass Criteria

Every screen must meet these criteria:

- No crash or freeze.
- No blank image container.
- No broken navigation.
- No hidden or unreachable primary button.
- Text does not overlap controls.
- Bottom tab bar does not cover final content.
- Back navigation works.
- Empty states are readable.
- Loading/error states do not trap the user.
- VoiceOver can identify primary controls.

## 1. Onboarding

Steps:

1. Delete the app from the device.
2. Install and launch the app.
3. Confirm onboarding appears on first launch.
4. Tap Continue from the welcome step.
5. Select a profile type.
6. Continue through time in Netherlands.
7. Select at least one priority.
8. Select a city.
9. Toggle document basics.
10. Finish onboarding.
11. Confirm Home appears.
12. Force quit and relaunch the app.
13. Confirm onboarding does not appear again.
14. Open Settings -> Privacy & Data Control.
15. Delete personal data.
16. Relaunch the app.
17. Confirm onboarding appears again.

Expected result:

- Completion persists across relaunch.
- Only explicit personal data reset brings onboarding back.
- Back, skip, disabled/enabled Continue, and final CTA all work.

## 2. Home

Steps:

1. Launch after onboarding.
2. Confirm Home loads without blocking loaders.
3. Inspect hero city image and overlay readability.
4. Swipe or tap featured city controls if present.
5. Tap Government quick action.
6. Go back.
7. Tap Transport quick action.
8. Go back.
9. Tap Emergency quick action.
10. Go back.
11. Tap each persona journey visible on Home.

Expected result:

- Needed newcomer paths are reachable in fewer than 3 taps.
- City images load or fallback cleanly.
- Home remains scrollable to the bottom without tab overlap.

## 3. Search

Steps:

1. Open Search tab.
2. Confirm empty state and suggested searches are visible.
3. Search for `BSN`.
4. Open a result.
5. Go back.
6. Clear the query.
7. Search for nonsense text such as `zzzxxy`.
8. Confirm no-result state appears.
9. Search for `gemeente`.
10. Confirm map suggestion appears.
11. Tap map suggestion.

Expected result:

- Keyboard does not cover the active input or submit button.
- Search results route correctly.
- No-result state is helpful and not blank.
- Map suggestion routes to the correct map focus.

## 4. Map

Steps:

1. Open Map tab.
2. Tap a visible province.
3. Confirm province selection card appears.
4. Tap Cities or Explore from the card.
5. Go back.
6. Tap a visible city dot.
7. Confirm correct province/city preview.
8. Pinch zoom and drag map.
9. Dismiss selected province.
10. Rotate device if supported by app settings.

Expected result:

- No incorrect province imagery.
- No cropped or empty map preview.
- Hit zones feel reliable.
- Map controls do not hide under the bottom tab bar.

## 5. Cities

Steps:

1. Open Cities from Home or More.
2. Confirm list loads.
3. Search for Amsterdam.
4. Open Amsterdam.
5. Verify hero image, title, flag, coat of arms, and content.
6. Go back.
7. Repeat for Rotterdam, Den Haag, Leiden, Utrecht, Eindhoven, Groningen, and Maastricht.

Expected result:

- Every priority city has a unique city-specific image or fallback.
- No blank sky, wrong-city photo, or duplicated hero is visible.
- Titles match the image and content.

## 6. Provinces

Steps:

1. Open Provinces.
2. Open Noord-Holland.
3. Open city list from the province page.
4. Go back.
5. Repeat for Zuid-Holland, Utrecht, Noord-Brabant, Groningen, Limburg, and Drenthe.

Expected result:

- Province cards render correctly.
- Province images are not reused from the wrong province.
- City cards inside province pages are readable.

## 7. Bookmarks / Saved

Steps:

1. Open Saved tab with no saved items.
2. Confirm empty state appears.
3. Open a city or guide article.
4. Save/bookmark an item where available.
5. Return to Saved.
6. Confirm the item appears under the correct category.
7. Remove the item.
8. Force quit and relaunch after saving another item.

Expected result:

- Empty state is not blank.
- Saved items persist across relaunch.
- Remove action works and does not crash.

## 8. AI Assistant

Steps:

1. Open AI Assistant tab.
2. Confirm empty assistant state appears.
3. Tap a quick prompt.
4. Send the prompt.
5. Confirm loading indicator appears.
6. Confirm response or safe fallback appears.
7. Enter a restricted legal-guarantee prompt.
8. Confirm safety response appears.
9. Enable Airplane mode.
10. Send a simple prompt.

Expected result:

- No infinite loading.
- Offline or fallback state is visible.
- Safety disclaimer remains visible.
- Keyboard and input bar do not overlap the bottom tab bar.

## 9. Settings

Steps:

1. Open More -> Settings.
2. Change app language.
3. Confirm visible text updates.
4. Change profile type.
5. Change selected city.
6. Change menu position.
7. Open Privacy & Data Control.
8. Export data.
9. Delete personal data.

Expected result:

- Settings changes persist where expected.
- Data export succeeds or shows a clear error.
- Delete personal data resets onboarding eligibility.
- Cache reset does not unexpectedly reset onboarding completion.

## 10. Government Services

Steps:

1. Open Government Services.
2. Confirm hero image and official-source badge/disclaimer.
3. Open Gemeente.
4. Go back.
5. Open IND.
6. Go back.
7. Open Belastingdienst.
8. Open source links where available.

Expected result:

- Institution cards route correctly.
- External links open or show a safe system prompt.
- No service card is blank or unresponsive.

## 11. Transport

Steps:

1. Open Transport.
2. Inspect hero and visual reference cards.
3. Open each visible transport section.
4. Open official source links.
5. Return to Home.
6. Search for `transport`.
7. Confirm transport content is discoverable from Search.

Expected result:

- Transport cards do not repeat as blank dark blocks.
- Official source links work.
- Content is readable on iPhone SE.

## 12. Healthcare

Steps:

1. Open Healthcare from Home, Search, or More.
2. Confirm huisarts, insurance, pharmacy, and urgent-care content is reachable.
3. Open any official source links.
4. Search for `huisarts`.
5. Confirm relevant content or map focus appears.

Expected result:

- Healthcare guidance is discoverable in fewer than 3 taps from Home.
- Urgent-care wording is clear.
- Official-source links are available for important claims.

## 13. Emergency

Steps:

1. Open Emergency from Home.
2. Confirm 112 primary card is visible immediately.
3. Confirm 112 guidance says to call for immediate danger.
4. Tap official source link.
5. Return.
6. Inspect non-emergency police, huisarts/huisartsenpost, and GGD cards.
7. Tap available call buttons.

Expected result:

- 112 is prominent and not hidden below the fold.
- Call links use the phone prompt and do not crash.
- Non-emergency guidance does not conflict with 112 guidance.

## 14. Accessibility Spot Check

Steps:

1. Enable VoiceOver.
2. Navigate Home tabs.
3. Open Search and focus the search field.
4. Open Map and verify the map has understandable controls or fallback navigation.
5. Open Emergency and focus 112.
6. Open Settings and focus Delete personal data.
7. Enable Large Dynamic Type.
8. Recheck Home, Search, Emergency, and Onboarding.

Expected result:

- Critical controls have meaningful labels.
- Destructive actions are announced.
- Large text does not overlap primary actions.

## Final Manual Sign-Off

Record results here before TestFlight upload:

| Area | Device | Pass/Fail | Notes |
| --- | --- | --- | --- |
| Onboarding persistence |  |  |  |
| Home |  |  |  |
| Search |  |  |  |
| Map |  |  |  |
| Cities |  |  |  |
| Provinces |  |  |  |
| Saved |  |  |  |
| AI Assistant |  |  |  |
| Settings |  |  |  |
| Government Services |  |  |  |
| Transport |  |  |  |
| Healthcare |  |  |  |
| Emergency |  |  |  |
| Accessibility |  |  |  |
