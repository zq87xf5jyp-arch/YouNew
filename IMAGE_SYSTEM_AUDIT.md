# IMAGE SYSTEM AUDIT
## YouNew - Dutch City and Place Image System

Version: 1.0
Date: 2026-06-16
Owner: iOS Visual Systems / Content Design / Asset QA
Status: Canonical audit. Image system is improved but not yet App Store final.

---

## 1. Mission

YouNew must treat city and place images as structured content assets, not decoration.

The image system must make the app feel:

- premium
- destination-accurate
- location-aware
- visually consistent
- legally controlled
- production-ready

Current evidence shows that YouNew already has a meaningful image foundation, but the system is not complete enough to satisfy the attached pass criteria.

---

## 2. Evidence Reviewed

| Evidence | What It Proves |
|---|---|
| `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift` | 42 curated city/province hero URLs exist and are used by canonical resolver paths. |
| `YouNew/Data/VerifiedPlaceMediaRegistry.swift` | A broader verified media layer exists for city/province hero, flag, and coat-of-arms metadata. |
| `YouNew/Data/CanonicalPlaceImageResolver.swift` | Major place image decisions route through a single resolver with debug context and runtime assertions. |
| `YouNew/Components/ImageLoader.swift` | City images use ImageIO downsampling, memory cache, in-flight request deduplication, and debug overlay support. |
| `YouNew/Components/AppContentImageView.swift` | Content images use verified metadata, captions, source buttons, fallback handling, and remote image caching. |
| `CITY_IMAGE_MAPPING.md` | 29 city heroes are currently mapped, with no disallowed duplicate city hero URLs in the latest static mapping. |
| `CITY_IMAGE_VALIDATION.md` | Remaining identity/ownership risks exist where city hero sources overlap attraction/province records. |
| `IMAGE_SOURCE_TRACE.md` | Main Home, city, province, map, nearby, and detail image paths now use `CanonicalPlaceImageResolver`. |
| `IMAGE_RUNTIME_VERIFICATION_REPORT.md` | Runtime screenshot verification was not performed because simulator/runtime was unavailable. |
| `VISUAL_ASSET_AUDIT.md` | 98 bundled assets scanned; no empty/broken local imagesets or byte-identical duplicates were reported. |
| `YouNewTests/PriorityCityHeroMediaTests.swift` | Priority city hero URLs are tested for presence, uniqueness, and landmark-specific tokens. |
| `scripts/image-runtime-data-qa.py` | Static QA checks curated media, province city cards, historical figure portraits, and known regressions. |
| `scripts/media-static-qa.py` | Static QA enforces metadata completeness for content media and blocks obvious forbidden stock/source markers. |

---

## 3. Current System Summary

### What Is Working

- A curated hero registry exists for Dutch cities and provinces.
- Priority cities such as Amsterdam, Rotterdam, Den Haag, Utrecht, Leiden, Groningen, Eindhoven, and Maastricht have destination-specific hero URLs.
- Major visible city/province screens use `CanonicalPlaceImageResolver`.
- Place images now carry runtime debug context with screen, entity, requested URL, resolved URL, fallback level, cache key, cache hit, registry source, and model ID.
- City image loading uses ImageIO downsampling instead of full-size `UIImage` resizing.
- Fallback cache behavior has been improved so failed primary URLs do not poison fallback cache entries.
- Content media has richer metadata than place hero media: source page, creator, license, dimensions, attribution, type, verified state, and retrieved date.

### What Is Not Yet Working

- `CuratedPlaceHeroMedia` is too thin for a production asset registry. It lacks category, visual theme, source type, license type, credit requirement, photographer, original resolution, orientation, crop-safe zones, approved screens, review date, and status.
- There is no explicit `ImageRegistry`, `DestinationImageMap`, `ImageLicenseRegistry`, `ImageVariantGenerator`, or `ImageQAValidator` implementation matching the requested model.
- Current place hero assets are mostly remote Wikimedia URLs, not art-directed app asset variants.
- There is no stored crop-safe-zone metadata for 16:9, 4:3/5:4, 4:5, and 1:1.
- There is no evidence of device screenshot verification for Home, Search, Cities, Provinces, Culture & Attractions, Places to Visit, Guides, AI Assistant related cards, Saved, Map previews, and destination detail screens.
- License metadata for curated place heroes is incomplete or generic. Some entries rely on "Wikimedia Commons file license" without exact license, author, and per-file attribution in the curated registry.
- Official tourism/city media libraries are not encoded as first-class source options. Current production data primarily uses Wikimedia and local assets.

---

## 4. Screen Coverage Audit

| Screen | Current Image Path | Status | Notes |
|---|---|---|---|
| Home | `CanonicalPlaceImageResolver.resolveCityHero` | Partial pass | Uses canonical resolver; needs runtime crop/overlay QA. |
| Search | Mixed content/search paths | Needs audit | Must verify result thumbnails use persona/content image metadata and no generic fallback dominates. |
| Cities | `resolveCityThumbnail` / `resolveCityHero` | Static pass | Current mapping says 29 cities mapped; runtime crop still unverified. |
| Provinces | `resolveProvinceHero` | Partial pass | Some province/city image ownership overlap remains documented. |
| Culture & Attractions | `ContentMediaRegistry.image(forContentID:)` and attractions | Needs fix | Content mappings reuse limited images across multiple themes; destination-specific culture variants are not complete. |
| Places to Visit | `resolvePlaceImage(place:)` for attractions | Partial pass | Den Haag windmill regression blocked; broader POI license/crop metadata incomplete. |
| Guides | `AppContentImageView` / content registry | Partial pass | Richer metadata exists; still no crop-safe-zone model. |
| AI Assistant related cards | Not fully proven | Needs audit | Must use same registry and persona/content context, not ad hoc thumbnails. |
| Saved | Not fully proven | Needs audit | Saved cards must preserve original approved image ID and variant. |
| Map previews | `resolveProvinceCityCard` / `resolveCityThumbnail` | Static pass | Duplicate visible image assertions exist; runtime screenshots missing. |
| Destination detail | `resolveCityHero` / `resolveProvinceHero` | Static pass | Needs 16:9 and tall layout crop QA. |

---

## 5. Architecture Gap

Current model:

```text
CuratedPlaceHeroMediaRegistry
VerifiedPlaceMediaRegistry
ContentMediaRegistry
CanonicalPlaceImageResolver
ImageLoader / AppContentImageView
```

Required model:

```text
ImageRegistry
DestinationImageMap
ImageLicenseRegistry
ImageVariantGenerator
ImageQAValidator
CanonicalPlaceImageResolver
Image renderers
```

The current resolver is useful and should remain, but it should resolve from a richer `ImageRegistry` record rather than from thin URL records and screen-level model fallbacks.

---

## 6. Required Canonical Data Model

Every city/place image must be represented as a structured asset:

```swift
struct DestinationImageAsset {
    let id: String
    let destination: String
    let city: String?
    let province: String?
    let category: DestinationImageCategory
    let visualTheme: String
    let source: ImageSource
    let licenseType: ImageLicenseType
    let creditRequired: Bool
    let photographer: String?
    let originalResolution: CGSize
    let orientation: ImageOrientation
    let cropSafeZones: [ImageVariant: CropSafeZone]
    let approvedScreens: Set<ImageApprovedScreen>
    let lastReviewDate: Date
    let status: ImageQAStatus
}
```

Approved variants:

- Hero: 16:9
- Card: 4:3 or 5:4
- Tall card: 4:5
- Square thumbnail: 1:1

---

## 7. Critical Findings

| Severity | Finding | Evidence | Required Fix |
|---|---|---|---|
| Critical | Curated place hero metadata is incomplete for production licensing and QA. | `CuratedPlaceHeroMedia` only stores `placeId`, `assetName`, `license`, `sourceURL`, `remoteURL`. | Replace or extend with `DestinationImageAsset`. |
| Critical | Crop-safe zones do not exist as data. | No crop metadata found in registry or renderer files. | Add variant crop records and QA snapshots. |
| High | Runtime image quality is unverified. | `IMAGE_RUNTIME_VERIFICATION_REPORT.md` says runtime verification was not performed. | Run device/simulator screenshot QA for all requested screens. |
| High | Culture/topic images can still repeat broad symbolic imagery. | `ContentMediaRegistry.image(forContentID:)` maps multiple culture IDs to a small set of images. | Create city/topic-specific secondary images. |
| High | License certainty is incomplete for shipped place heroes. | Curated registry lacks exact license, photographer, credit, retrieved date for most entries. | Build `ImageLicenseRegistry` and block unresolved assets. |
| Medium | Province heroes sometimes overlap city or attraction identity. | `CITY_IMAGE_VALIDATION.md` and `PROVINCE_IMAGE_VALIDATION.md` document reuse/overlap risks. | Separate province-wide visual identity from city/POI owners. |
| Medium | Official destination libraries are not first-class sources. | Current data is primarily Wikimedia/local. | Add source priority and license review workflow. |

---

## 8. Pass Criteria Status

| Criterion | Current Status |
|---|---|
| 0 blurred images | Unproven; no runtime screenshot sharpness QA. |
| 0 stretched images | Partially supported by fixed frames and aspect fill; unproven on device. |
| 0 wrong city images | Static priority-city checks pass; full app unproven. |
| 0 generic repeated thumbnails | Not passed; culture/topic reuse remains. |
| 0 visually lost hero images | Unproven; no overlay/crop screenshots. |
| 0 broken crops | Not passed; no crop-safe-zone data. |
| 0 low-resolution hero assets | Partially supported by 2400px curated URLs; remote/original metadata incomplete. |
| 0 production placeholders | Unproven; fallback can still render when remote media fails. |
| 0 unresolved licensing ambiguity | Not passed; curated place hero metadata is incomplete. |

---

## 9. Verdict

The current image system is structurally improved but not yet final.

Verdict: **STATIC FOUNDATION PRESENT, PRODUCTION IMAGE SYSTEM INCOMPLETE**.

Before App Store final, YouNew needs a richer registry, explicit license records, art-directed variants, crop-safe-zone metadata, screen-level screenshot QA, and a release gate that blocks unresolved licensing or visual identity ambiguity.
