# YouNew Business Discovery — QA report

Date: 12 July 2026

## Delivered

- Home now contains a city-scoped **Discover near you** carousel backed by the canonical `DashboardPlacesData` repository.
- Cards expose one stable place ID, route to `placeDetail(id)`, support Save, and label canonical editorial results as Organic.
- Empty city results use a controlled city-guide fallback; no fake business is inserted.
- Home and More contain separate **Add your business** and **Business login** routes.
- The previous demo dashboard and pretend successful login were replaced by a local draft workspace.
- Business account/profile data is stored under a dedicated business snapshot and is not read from the personal profile.
- Six-step registration covers identity, location, details, media policy, plan, and review consent.
- Gallery supports unique draft assets, roles, alt text, cover selection, reorder, delete, and moderation state.
- Calendar supports event drafts with stable IDs, dates, city, location, booking URL, and moderation state.
- Offers are drafts and are hidden from user-facing discovery unless approved and within their validity window.
- Dashboard metrics, leads, messages, billing, secure authentication, upload and moderation are shown as unavailable when no backend exists.

## Commercial disclosure

- Canonical city places: Organic.
- Existing local partner records keep their explicit Free Listing / Verified Partner / Featured / Sponsored labels.
- Sponsored status is not treated as a quality claim.
- No new company, rating, address, opening hour, offer, event, price, or metric was invented.

## Validation

| Check | Result |
| --- | --- |
| iOS Simulator build before the final image-renderer cleanup | PASS |
| Full static QA after all changes | PASS |
| Localization static coverage | 582/582 EN, NL, RU |
| Route/action static QA | PASS |
| Accessibility static QA | PASS |
| Performance static QA | PASS |
| Media/image static QA | PASS |
| New business test bundle compilation | PASS |
| New business unit-test execution | INCOMPLETE — XCTest runner blocked while materializing workers |
| Final runtime Home/business traversal | NOT VERIFIED — execution approval became unavailable after build/test work |
| Physical device | NOT VERIFIED |

## Backend/business work still required

- Production authentication, account recovery and secure sessions.
- Role-based access and server-side separation of owners, reviewers and administrators.
- Encrypted storage for KvK and verification documents.
- Real media upload, compression, thumbnail creation, rights checks and moderation.
- Server-side publishing of approved events and offers into Home, Places, Search and AI.
- EventKit permission/runtime flow for Add to Apple Calendar.
- Billing and plan entitlements.
- Real analytics, leads and messages.
- Admin review actions and audit history.
- Public website entry and deep-link hosting.

The local implementation is a functional draft/review prototype. It is not described as a complete business platform.
