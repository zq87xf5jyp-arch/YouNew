# PERFORMANCE_REPORT

Date: 2026-06-11  
Scope: Pre-TestFlight release blockers only. Static inspection performed; Instruments/runtime profiling was not available in this pass.

## Verdict

Status: NO CONFIRMED PERFORMANCE BLOCKER FOUND BY STATIC INSPECTION

There is no obvious code-level performance blocker that should stop a TestFlight beta by itself. Runtime profiling on iPhone SE-class hardware is still required before public release because the app is image-heavy and map-heavy.

## Image Loading

| Area | Finding | Risk |
| --- | --- | --- |
| `DirectImageLoader` | Uses URL-keyed memory cache, in-flight task dedupe, request timeout, content-type validation, and downsampling. See `YouNew/Components/ImageLoader.swift:5-168`. | Low |
| Image memory cache | `ImageMemoryCache` allows 100 images and 200 MB. See `YouNew/Components/ImageLoader.swift:5-10`. | Medium on small devices |
| Shared image network cache | `NetworkConfig.imageSession` uses 50 MB memory cache and 200 MB disk cache. See `YouNew/NetworkConfig.swift:3-21`. | Medium |
| Content images | `AppContentImageView` uses a separate 80 MB `NSCache` and `URLSession.shared.data(from:)`. See `YouNew/Components/AppContentImageView.swift:230-312`. | Medium |
| Duplicate requests | `DirectImageLoader` dedupes in-flight URL loads. `AppContentImageView` does not appear to dedupe simultaneous in-flight requests for the same URL. | Should fix before public release if repeated content images remain common |

## Asset Size

`Assets.xcassets` is 23 MB. This is acceptable for TestFlight, but home-screen visual assets are large enough to monitor on iPhone SE devices.

Largest bundled assets:

- `premium_home_housing.png`: 2.7 MB
- `premium_home_documents.png`: 2.3 MB
- `premium_home_work.png`: 2.3 MB
- `premium_home_emergency.png`: 2.2 MB
- `home_work_zuidas.jpg`: 2.2 MB
- `premium_home_healthcare.png`: 1.9 MB
- `premium_home_language.png`: 1.8 MB
- `premium_home_background.png`: 1.6 MB

## Map

The map model uses static mock place data and local filtering. No network map tile pressure or unbounded data source was found in static inspection. Runtime scroll responsiveness still needs physical-device QA because the user previously reported sticky map scrolling.

## Search

Search appears to run over local data sets through `SearchViewModel`. No network dependency or obvious expensive background work was found. Risk is low for the current data volume.

## AI Assistant

The AI request path is bounded:

- user message is limited before backend send in `AIClient`
- recent conversation context is limited
- request timeout is present
- hourly usage limiting exists in `AIUsageLimiter`
- connectivity monitor is cancelled in `AIViewModel.deinit`

Performance risk is low. Privacy and product-expectation risks are covered in `PRIVACY_REVIEW.md` and `APP_STORE_REVIEW_SIMULATION.md`.

## Large City Pages

The image path uses downsampling and caching, which lowers memory pressure. The remaining risk is cumulative: large hero images, multiple cards, maps, and cached images can combine to push memory on older devices.

## Required TestFlight Device Checks

1. iPhone SE: cold launch, Home scroll, Map drag/zoom, Search typing, AI prompt, large city page open/close.
2. iPhone 15 Pro Max: rapid tab switching across Home, Map, Search, Saved, AI Assistant, More.
3. iPad: map interaction, split-width layout, city/province page scroll.
4. Poor network: remote images loading, fallback behavior, AI backend timeout.
5. Memory pressure: repeated open/close of city pages and province modals for 5 minutes.

## Performance Blockers

No confirmed performance blocker was found statically. Runtime profiling is still required before claiming App Store readiness.
