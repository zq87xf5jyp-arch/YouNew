# Image Audit

Date: 2026-06-16

## Scope

Audited app icon, media registry, place media, history media, city/province image mapping, placeholder risk, and runtime image-loading performance.

## Validation Performed

- App icon static QA: passed.
- Media static QA: passed.
- Place media static QA: passed.
- History media static QA: passed.
- Brand static QA: passed.
- Image-loader performance path reviewed and fixed.

## 2026-06-18 Addendum

- Shared `CategoryHeroVisual` now uses `AppContentImageView` instead of raw `AsyncImage`, so category hero banners use the app's cached image loader, contextual fallback URLs, and bundled local fallback image.
- `image-render-static-qa.py` now rejects raw `AsyncImage` inside `CategoryHeroVisual` and verifies contextual/bundled fallback coverage.
- Focused image QA and the full static QA suite pass after the change.

## Findings And Fixes

### P1: Image decode/downsample actor risk

- Screen: image-heavy city, province, map, and place screens.
- Problem: remote image decoding/downsampling could inherit the main actor.
- Root cause: `Task` created inside `@MainActor` image loader.
- Fix: remote image work now uses detached utility priority.
- Status: fixed.

## Current Status

- Broken image blockers from static QA: 0.
- Duplicate hero image blockers from static QA: 0.
- Wrong city/province image blockers from static QA: 0.
- Placeholder image blockers from static QA: 0.
