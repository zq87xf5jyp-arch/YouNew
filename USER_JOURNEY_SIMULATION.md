# User Journey Simulation

Date: 2026-06-10
Scope: Home-screen access for first-time newcomer, refugee, international student, expat worker, and tourist journeys.

## Method

- Simulated navigation from the Home screen using the SwiftUI route graph and visible Home entry points.
- Counted taps only for user actions that open a destination. Horizontal scrolling is not counted as a tap.
- Runtime tap-through on Simulator is still blocked in this environment by CoreSimulator availability, so this report is based on static route verification plus Swift parse validation.

## Summary

TOTAL JOURNEYS TESTED: 5
TOTAL PASSING UNDER 3 TAPS: 5
TOTAL FAILING UNDER 3 TAPS: 0
MAXIMUM TAP COUNT FROM HOME: 1

## Finding Fixed

Before this audit, the destination content for these personas already existed, but Home did not expose the five requested user journeys as clear first-class entry points. A new "Start by situation" section now appears immediately after city pills on Home and gives each persona a direct one-tap route.

Fixed in:

- `YouNew/Views/HomeView.swift:306` inserts `personaJourneySection` into the Home screen.
- `YouNew/Views/HomeView.swift:594` renders the "Start by situation" section.
- `YouNew/Views/HomeView.swift:2086` defines the five persona journeys and their destinations.
- `YouNew/Views/HomeView.swift:2718` defines the compact Home persona card.

## Journey Matrix

| Persona | Home entry | Route | Needed information verified | Tap count | Result |
| --- | --- | --- | --- | ---: | --- |
| First-time newcomer | Start by situation > First-time newcomer | Home -> FirstStepsView | Address setup, gemeente registration, BSN context, DigiD, healthcare, huisarts, banking, transport, housing, official sources | 1 | PASS |
| Refugee | Start by situation > Refugee | Home -> StatusDirectionView(.refugee) | Status/residence documents, gemeente process, health insurance, integration/inburgering, benefits/toeslagen, legal/support organizations, COA/IND/Juridisch Loket sources | 1 | PASS |
| International student | Start by situation > International student | Home -> StatusDirectionView(.student) | Enrollment, BSN for longer stay, DUO eligibility, health insurance, housing, transport, IND/Government.nl sources | 1 | PASS |
| Expat worker | Start by situation > Expat worker | Home -> StatusDirectionView(.expat) | BSN, DigiD, employer and residence documents, tax, health insurance, housing contract, 30% ruling, Belastingdienst/IND/Government.nl sources | 1 | PASS |
| Tourist | Start by situation > Tourist | Home -> StatusDirectionView(.tourist) | Stay length and visa, travel/medical insurance, accommodation address, transport, emergency contacts, fines/letter rules, IND/Government.nl/Nederlandwereldwijd sources | 1 | PASS |

## Route Evidence

- `YouNew/Views/AppDestinationView.swift:61` routes `AppDestination.statusDirection` to `StatusDirectionView`.
- `YouNew/Views/AppDestinationView.swift:112` routes `AppDestination.firstSteps` to `FirstStepsView`.
- `YouNew/Views/StatusDirectionView.swift:20` displays primary needs, first actions, documents, sources, and warnings for each status.
- `YouNew/Models/StatusDirection.swift:17` defines tourist guidance.
- `YouNew/Models/StatusDirection.swift:77` defines international student guidance.
- `YouNew/Models/StatusDirection.swift:90` defines expat guidance.
- `YouNew/Models/StatusDirection.swift:103` defines refugee guidance.
- `YouNew/Views/FirstStepsView.swift:792` defines the first-time newcomer first actions.

## Verification Result

PASS: Every requested user can reach relevant information from the Home screen in fewer than 3 taps.

Current measured tap counts:

- First-time newcomer: 1 tap
- Refugee: 1 tap
- International student: 1 tap
- Expat worker: 1 tap
- Tourist: 1 tap

## Remaining Runtime Risk

Manual device verification is still recommended on a live Simulator or physical device because CoreSimulator is unavailable in this execution environment. Static routing confirms that the journeys are present and connected; runtime QA should confirm gesture behavior, scrolling visibility, and accessibility focus order on device.
