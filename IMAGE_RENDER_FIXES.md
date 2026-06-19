# IMAGE RENDER FIXES
## YouNew - iOS Rendering, Caching, Crop, and Asset Pipeline Fix Plan

Version: 1.0
Date: 2026-06-16
Owner: Senior SwiftUI Engineering / Asset Pipeline Engineering
Status: Canonical implementation plan

---

## 1. Current Rendering Foundation

The current implementation already includes important fixes:

- `CanonicalPlaceImageResolver` centralizes city, province, figure, and attraction image resolution.
- `CityImageView` uses `DirectImageLoader`.
- `DirectImageLoader` uses ImageIO downsampling through `CGImageSourceCreateThumbnailAtIndex`.
- `ImageMemoryCache` uses count and memory limits.
- In-flight URL tasks are deduplicated.
- Runtime debug overlay can show screen/entity/source/fallback/cache data.
- `AppContentImageView` supports verified content images, captions, source links, local assets, remote fallback URLs, and cached remote rendering.

These should be preserved.

---

## 2. Required Fixes

| Priority | Fix | Current Gap | Implementation Target |
|---|---|---|---|
| P0 | Add `ImageRegistry` | No single rich asset registry | One canonical registry record per image asset |
| P0 | Add `ImageLicenseRegistry` | Place hero licenses incomplete | Release gate blocks ambiguous assets |
| P0 | Add crop-safe-zone model | Crops are not art-directed | Per-image safe zones for 16:9, 4:3/5:4, 4:5, 1:1 |
| P0 | Add approved variants | Remote URL is reused for all contexts | Hero/card/tall/square/thumbnail variants |
| P0 | Add production placeholder gate | Fallback can render silently | Release screenshots fail if fallback visible |
| P1 | Consolidate registries | Curated and verified registries overlap | Resolver reads one canonical image asset contract |
| P1 | Add official source support | Official tourism/city libraries are not first-class | Source type + terms review in registry |
| P1 | Add visual identity QA | Token tests are not enough | Manual and screenshot QA checklist per destination |
| P1 | Improve Culture & Attractions imagery | Several topics share broad images | Destination/topic-specific secondary imagery |
| P2 | Add On-Demand Resource plan | Future galleries may inflate bundle | Keep essentials bundled/cacheable; load galleries on demand |

---

## 3. Target Rendering Contract

```swift
enum ImageVariant: String, Codable {
    case hero16x9
    case card4x3
    case card5x4
    case tall4x5
    case square1x1
    case thumbnail
}

struct ImageVariantAsset: Codable, Equatable {
    let variant: ImageVariant
    let localAssetName: String?
    let remoteURL: URL?
    let pixelWidth: Int
    let pixelHeight: Int
    let cropSafeZone: CropSafeZone
    let colorSpace: ImageColorSpace
    let compressionQuality: Double
    let status: ImageQAStatus
}

struct CropSafeZone: Codable, Equatable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let keyObjectDescription: String
}
```

---

## 4. Renderer Rules

All image renderers must:

- choose a variant based on screen slot, not arbitrary URL size
- use `scaledToFill + clipped` only after an approved crop exists
- downsample remote images to target pixel width
- keep cache keys per actual resolved URL and variant
- expose debug context in DEBUG builds
- avoid dark overlays that destroy image identity
- show fallback only when no approved image can load
- report fallback visibility to QA/debug logs

---

## 5. Screen Slot Mapping

| Screen Slot | Variant | Target Width |
|---|---|---:|
| Home hero | `hero16x9` | 2400 |
| City detail hero | `hero16x9` | 2400 |
| Province detail hero | `hero16x9` | 2400 |
| City directory card | `card5x4` or `card4x3` | 1600 |
| Horizontal card carousel | `card5x4` | 1400-1600 |
| Tall recommendation card | `tall4x5` | 1600 |
| Search result thumbnail | `square1x1` | 1000-1200 |
| Saved card thumbnail | `square1x1` or `card4x3` | 1000-1200 |
| Map preview | `thumbnail` | 800-1200 |
| AI related card | `square1x1` or `card4x3` | 1000-1200 |

---

## 6. Code-Level Fix List

### `CuratedPlaceHeroMediaRegistry.swift`

Replace current thin model:

```swift
struct CuratedPlaceHeroMedia {
    let placeId: String
    let assetName: String
    let license: String?
    let sourceURL: URL?
    let remoteURL: URL?
}
```

with a richer registry or adapter into:

```swift
DestinationImageAsset
ImageLicenseRecord
ImageVariantAsset
```

### `VerifiedPlaceMediaRegistry.swift`

- Stop using generic `Wikimedia Commons file license` as a final license label.
- Store exact license name and URL per asset.
- Preserve source page URL separately from render URL.
- Mark assets as blocked when exact license is unknown.

### `CanonicalPlaceImageResolver.swift`

- Resolve by destination + requested image slot.
- Return `ResolvedPlaceImage` with `variant`, `licenseRecordID`, `qaStatus`, and `cropSafeZone`.
- Keep existing debug context and duplicate assertions.

### `ImageLoader.swift`

- Keep ImageIO downsampling.
- Include variant in cache key.
- Log placeholder/fallback display as a QA event.
- Add target pixel width from selected variant, not just height-derived heuristics.

### `AppContentImageView.swift`

- Continue using verified metadata and source buttons.
- Add optional crop-safe-zone awareness.
- Fail DEBUG assertion if a verified image is rendered in a slot that is not in `approvedScreens`.

---

## 7. Variant Generator

Create `ImageVariantGenerator` as a build-time/offline tool:

```text
Input: master image, crop-safe zones, destination record
Output:
- hero16x9
- card4x3
- card5x4
- tall4x5
- square1x1
- thumbnail
- metadata JSON or Swift registry update
```

Rules:

- master image minimum: 2400 px on short side
- preserve sRGB or Display P3 intentionally
- no upscaling beyond source quality
- no excessive compression
- output dimensions stored in registry

---

## 8. QA Validator

Create `ImageQAValidator`:

```text
[ ] destination identity token exists
[ ] source license approved
[ ] original resolution meets minimum
[ ] all required variants exist
[ ] crop-safe zones exist for all variants
[ ] approved screens present
[ ] no duplicate thumbnails outside allowed alias rules
[ ] no placeholder/fallback in release snapshots
[ ] no low-res URL used in hero slot
```

---

## 9. Immediate Fix Order

1. Backfill exact source/license metadata for all curated city and province heroes.
2. Create first-class destination records for Kinderdijk, Keukenhof/Flower Region, Wadden Sea, Giethoorn, and Zaanse Schans.
3. Add crop-safe-zone fields and approved screen slots to the registry.
4. Generate variants for priority destinations: Amsterdam, Rotterdam, Den Haag, Utrecht, Leiden, Delft, Groningen, Maastricht, Kinderdijk, Keukenhof, Wadden Sea.
5. Replace shared Culture & Attractions thumbnails with destination/topic-specific images.
6. Add screenshot QA for requested screens.
7. Add release gate that fails on unresolved license, missing crop, duplicate thumbnail, low-res hero, or visible fallback.

---

## 10. Definition of Done

The render system is done only when:

- every screen uses registry-approved variants
- every shipped image has complete license metadata
- every destination has hero, secondary, list, square, and fallback assets
- every crop-safe zone is tested
- screenshots prove no blur, stretch, wrong city image, generic repeat, lost hero, broken crop, low-res hero, placeholder, or license ambiguity

Until then, the current work is a strong foundation, not the final production image system.
