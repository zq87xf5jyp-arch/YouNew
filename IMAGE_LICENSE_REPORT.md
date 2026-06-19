# IMAGE LICENSE REPORT
## YouNew - Source and Licensing Control for Destination Images

Version: 1.0
Date: 2026-06-16
Owner: Content Operations / Legal Review / Asset Pipeline
Status: Canonical license audit

---

## 1. Rule

No image may ship unless its source, license, credit requirement, photographer/creator, retrieval date, and approved use are known.

An image without complete license metadata is not production-ready, even if it is visually correct.

---

## 2. Source Priority

Use sources in this order:

1. Official tourism or city media libraries when license permits in-app usage.
2. Commercially safe licensed stock or open-license sources.
3. Existing internal curated assets with complete rights metadata.
4. No low-quality random images as fallback.

Current implementation is mostly Wikimedia/local. That is acceptable only when each file page and license are stored precisely.

---

## 3. Current License Evidence

| Registry | License Metadata Quality | Current Risk |
|---|---|---|
| `ContentMediaRegistry` | Stronger: stores source page, source name, creator/author, license, license URL, attribution, dimensions, verified state, retrieved date. | Needs ongoing review but structurally close to production. |
| `VerifiedPlaceMediaRegistry` | Medium: stores source, source type, license string, attribution, verified, updated date, pixel size. | License often generic: "Wikimedia Commons file license"; exact license/author not always stored. |
| `CuratedPlaceHeroMediaRegistry` | Weak: stores optional license/source URL plus remote URL. Most current entries pass no license/source metadata into the curated record. | Not production-complete for shipped hero images. |
| Asset catalog local images | Mixed: local assets exist, but local image rights are not all tied to a first-class license registry. | Needs mapping from local asset to license record. |

---

## 4. Required License Registry

```swift
struct ImageLicenseRecord {
    let imageAssetID: String
    let sourceName: String
    let sourceType: ImageSourceType
    let sourcePageURL: URL
    let renderURL: URL?
    let originalFileURL: URL?
    let licenseType: ImageLicenseType
    let licenseName: String
    let licenseURL: URL?
    let creditRequired: Bool
    let creditLine: String
    let photographer: String?
    let copyrightOwner: String?
    let permittedUses: Set<ImageUse>
    let prohibitedUses: Set<ImageUse>
    let retrievedAt: Date
    let reviewedAt: Date
    let reviewer: String
    let status: LicenseReviewStatus
}
```

---

## 5. Source Types

```swift
enum ImageSourceType {
    case officialTourismBoard
    case officialCityMediaLibrary
    case officialVenuePressKit
    case wikimediaCommons
    case museumOpenData
    case commercialStock
    case openLicenseStock
    case internalCreatedAsset
    case generatedFallback
}
```

---

## 6. License Status Categories

| Status | Meaning | Production Behavior |
|---|---|---|
| approved | Source and license verified for app usage | Can ship |
| approvedWithCredit | Can ship only with visible or accessible credit | Can ship if credit UI exists |
| editorialOnly | May not be used for broad commercial/product promotion without review | Block from app unless legal approves |
| needsReview | Incomplete metadata or ambiguous use | Block |
| rejected | Not allowed | Remove |
| fallbackOnly | Generated/internal fallback, approved only when no destination asset loads | Hide from normal content |

---

## 7. Current Risk Register

| Risk | Evidence | Impact | Required Action |
|---|---|---|---|
| Curated hero license ambiguity | `CuratedPlaceHeroMediaRegistry.media(...)` calls usually omit `license` and `source`. | Fails "0 unresolved licensing ambiguity" pass criterion. | Backfill exact file page, author, license name, license URL, attribution, and retrieved date for every curated hero. |
| Wikimedia generic license label | `VerifiedPlaceMediaRegistry.licenseName(for:)` returns "Wikimedia Commons file license". | Too vague for audit and attribution. | Parse/store exact license per file. |
| Local asset provenance incomplete | Asset catalog files are scanned visually but not fully tied to license records. | App can ship local images without rights trace. | Map every local raster/vector asset to `ImageLicenseRecord`. |
| Official media-library usage not encoded | No first-class official tourism/city media source records found in current registries. | Misses preferred source strategy and use restrictions. | Add official source records only after reviewing terms. |
| Generated fallback may appear in production | Fallback asset exists and renderers can show fallback if remote fails. | Could violate "0 production placeholders" if visible. | Treat fallback visibility as QA failure on release screenshots. |

---

## 8. Recommended Source Policy

### Official Destination Sources

Use official destination media libraries for visual direction and source candidates, but do not assume broad app rights. Each asset needs explicit review.

Examples to review:

- NBTC / Holland.com destination pages
- Amsterdam & Partners media library
- Rotterdam Partners image bank
- The Hague image database
- Utrecht Beeldbank / Toolkit
- Keukenhof press media
- Kinderdijk press/media material
- UNESCO file pages for Wadden Sea / Kinderdijk, per-file only

### Open and Commercial Sources

Use open/commercially safe photo sources only when official licensing is unsuitable or slow. These assets still require:

- destination identity QA
- exact URL/source record
- creator metadata when available
- license terms captured at review date
- duplicate and crop QA

---

## 9. Release Gate

Before a destination image can ship:

```text
[ ] imageAssetID exists in ImageRegistry
[ ] sourcePageURL exists
[ ] licenseName exists
[ ] licenseURL or public-domain proof exists
[ ] photographer/creator captured, or explicitly "unknown"
[ ] creditRequired captured
[ ] approvedScreens captured
[ ] retrievedAt and reviewedAt captured
[ ] status is approved or approvedWithCredit
[ ] credit appears where required
```

Any image failing this gate must be excluded from production Home, Search, Map, AI, Saved, and destination detail surfaces.

---

## 10. Verdict

License posture is **not yet final**.

`ContentMediaRegistry` is close to the required model. City/place hero media must be upgraded before the pass criterion "0 unresolved licensing ambiguity for shipped assets" can be claimed.
