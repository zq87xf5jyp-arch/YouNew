# Home and Leiden content — 2026-11-15

## Scope and baseline

PRs #65, #66 and #67 were all OPEN and Draft at inspection. This branch is based on #67 (a5b75f6); none were merged. The existing field approval remains exactly four photos, five coordinates and six ticket links. No review manifests, source packages, approval hashes, photo files or published web records were changed.

The connected Xcode workspace builds the older iCloud checkout, not `/Users/ivan/YouNew`. Its BuildProject attempt failed at CodeSign. This is a concrete checkout mismatch and a possible explanation for the reported old screen, not proof of which binary produced the unavailable screenshot. A publication gate is not excluding the seven approved places in the current exported artifact. The current resolver supports the approved bundled images and the place fallback is already a photo symbol, not the Netherlands map.

## Changes

- Home previews prioritize approved bundled images, so Leiden starts with Hortus, Rijksmuseum van Oudheden and Boerhaave without needing network access. All four approved local images remain available in their respective detail pages, including Wereldmuseum.
- Each Leiden preview has its own existing place-detail navigation, a visible name and an 88-point image. Preview links are outside the card's parent navigation link, avoiding nested links.
- Shared Home information cards use opaque adaptive surfaces. The former fixed navy gradient behind adaptive dark text caused poor contrast in light mode. Feature touch targets are at least 44 points; text is no longer shrunk to 78 percent. Checklist storage/progress is unchanged.
- A new batch of five existing, owner-approved shared-catalog restaurants is projected through the existing exporter. The same records feed canonical details and the Food & Drink list, with EN/NL descriptions, addresses, official websites, Save, Share and address-based Apple Maps directions. No new independent content database.

| Existing shared ID | Venue | Official source rechecked |
| --- | --- | --- |
| restaurant.leiden-bikini | Bikini Bikini | https://caferestaurantbikini.nl/contact/ |
| restaurant.leiden-in-den-doofpot | Restaurant In den Doofpot | https://www.indendoofpot.nl/contact |
| restaurant.leiden-verboden-toegang | Restaurant Verboden Toegang | https://www.verbodentoegang.nl/ |
| restaurant.leiden-prentenkabinet | Het Prentenkabinet | https://www.prentenkabinet.nl/reserveren/ |
| restaurant.leiden-oudt-leyden | Oudt Leyden | https://oudtleyden.nl/ |

These are five newly connected iOS cards, not five newly approved or production-published records. Their original approved source/check dates remain unchanged. No new photos, coordinate pins, ticket/menu/booking-specific buttons, prices or hours were added for this batch. Website for Het Prentenkabinet opens its already-approved reservation page; no reservation was submitted.

De Engelenbak was considered but excluded: its official contact page contains unrelated online-casino promotional text. Investigate source integrity separately; no upstream publication status was changed.

## Existing sections checked without rewriting

Official Services already routes Municipality, IND, DigiD, Taxes and Healthcare through typed category/institution/guide destinations. Housing Rent, Buy, Student Housing and Social Housing already has guide destinations. Transport routes to existing train/OV-chipkaart guides and Transport Basics, which includes NS, 9292 and OVpay. These shared cards benefit from the surface/contrast change. No claim of runtime link navigation testing is made.

Today uses the Europe/Amsterdam calendar and includes only event dates overlapping today. The live Leiden snapshot filters ended events. No literal Jul 13/July 13 was found in Swift sources. No event dates or counts were fabricated or changed.

## Validation

- Final explicit iOS Simulator arm64 `build-for-testing`: **TEST BUILD SUCCEEDED**; app and test targets compiled. Log: `/tmp/younew-home-content-final-build.log`. 0 warning(s): none. Swift tests were compiled, not executed.
- Governed export `--check`: passed; all approval/source/media hash gates retained.
- Existing Node governance/content suite: 20 passed, 0 failed.
- Bundled JSON: exactly 12 records, byte-identical to the generated repository projection.
- Four bundled WebP files: each SHA-256 matches the approved source; 871,710 bytes total. No images redownloaded.
- Seven attraction cards retain seven coordinates and six ticket actions; Burcht has no ticket URL.
- HTTP GET checks: 12 official websites and six ticket URLs return 200 after redirects. Results in `HOME_LEIDEN_LINK_CHECKS_2026-11-15.json`. HTTP success is not evidence of completing ticket purchase flows.
- Added Swift regression coverage for five restaurant identities, Food & Drink exposure, address-based directions, absence of unapproved images/coordinates/tickets. Existing seven attraction and image/license tests retained.
- Native ImageIO: all four files decoded from the built app (1200x798, 1200x800, 1200x1883, 1200x900); this is not UI validation.
- Runtime unit-test attempt: unavailable iPhone 16 destination; no installed Simulator runtime. A connected physical iPhone is visible. DeviceInteraction discovery explicitly returned "None of the available devices are supported for Device Interaction" (only Simulator 27+ is supported). No session or installation was performed.
- Runtime UI, photo rendering, Save persistence, Apple Maps handoff, Tickets handoff, EN/NL layouts, small screens, light/dark appearance and VoiceOver remain release QA requirements. Visually verified in running app: **0 photos**. Bundled and hash-verified: **4 photos**; three older licensed attraction images remain remote.

## Files and follow-up

Implementation: `HomePremiumInformationCard.swift`, `RootHomeView.swift`, `HomeExploreListView.swift`, `MockDashboardDiscoveryData.swift`, existing exporter and generated `younew-approved-places.json`. Regression coverage: `CityPlacesCalendarRegressionTests.swift`, `scripts/tests/approved-ios-places.test.mjs`.

Next: run the correct checkout on a suitable runtime, then review licensed media for these five restaurants. Parks and additional review-package fields remain unapproved. Production, signing configuration, TestFlight, App Store Connect and user storage were not modified.
