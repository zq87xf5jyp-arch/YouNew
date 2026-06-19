# IMAGE QA REPORT
## YouNew - Destination Image Quality and Identity QA

Version: 1.0
Date: 2026-06-16
Owner: QA Lead / Visual Design / iOS Engineering
Status: Canonical QA report

---

## 1. QA Standard

Every shipped image must pass four tests:

1. Identity test: a user can tell the city/place type without reading the label.
2. Crop test: the main landmark/object survives hero, card, tall card, and square thumbnail crops.
3. Clarity test: no blur, pixelation, noisy upscale, heavy compression, or oversharpening.
4. Contrast test: the image remains readable under YouNew's dark overlays and glass surfaces.

---

## 2. Static QA Evidence

| Check | Current Result |
|---|---|
| 29 city heroes mapped | PASS in `CITY_IMAGE_MAPPING.md` |
| Disallowed duplicate city hero URLs | PASS in latest city mapping |
| Bundled asset empty/broken scan | PASS in `VISUAL_ASSET_AUDIT.md` |
| Byte-identical duplicate local assets | PASS in `VISUAL_ASSET_AUDIT.md` |
| Priority city hero token tests | Covered by `PriorityCityHeroMediaTests.swift` |
| Den Haag windmill regression | Blocked by static assertions/tests |
| Figure thumbnails using place landscapes | Blocked by resolver/static QA |
| Runtime screenshot verification | NOT PERFORMED per `IMAGE_RUNTIME_VERIFICATION_REPORT.md` |

---

## 3. QA Matrix

| Area | Identity | Crop | Clarity | Overlay Contrast | License | Status |
|---|---|---|---|---|---|---|
| Priority city heroes | Static pass | Unproven | Unproven | Unproven | Incomplete | Partial |
| Non-priority city heroes | Needs manual review | Unproven | Unproven | Unproven | Incomplete | Partial |
| Province heroes | Mixed | Unproven | Unproven | Unproven | Incomplete | Needs work |
| POI / attraction images | Partial | Unproven | Unproven | Unproven | Incomplete | Needs work |
| Culture & Attractions | Mixed | Unproven | Unproven | Unproven | Better via content registry | Needs work |
| Content guide images | Better | Unproven | Unproven | Unproven | Stronger | Partial |
| Local asset catalog | Not all destination photos | N/A | Static dimensions pass | N/A | Mixed | Partial |
| Fallback imagery | Generic by design | N/A | Pass as fallback | Pass as fallback | Internal | Must not appear in production |

---

## 4. Known Open Issues

| Severity | Issue | Evidence | Required QA |
|---|---|---|---|
| Critical | No screenshot-proven crop safety. | Runtime report says screenshots were not captured. | Capture required screens on iPhone SE-size, standard iPhone, large iPhone, and iPad where supported. |
| Critical | No crop-safe-zone metadata. | Registry has no crop fields. | Add per-variant crop-safe zones and validate with generated snapshots. |
| High | Culture/topic cards can feel repetitive. | `ContentMediaRegistry.image(forContentID:)` maps many topics to limited shared imagery. | Add topic/city-specific secondary images. |
| High | License metadata incomplete for place heroes. | Curated registry lacks exact license data. | License QA before visual approval. |
| Medium | Province and city identity sometimes overlap. | Previous city/province validation reports note overlaps. | Establish ownership: province images must not simply duplicate city hero when avoidable. |
| Medium | Remote media can fail and show fallback. | Renderer supports fallback state. | Release screenshots must show no fallback placeholders in normal network conditions. |

---

## 5. Required Screen QA

Run manual or automated screenshot checks for:

- Home
- Search
- Cities
- Provinces
- Culture & Attractions
- Places to Visit
- Guides
- AI Assistant related cards
- Saved
- Map previews
- Destination detail screens

For each screen, verify:

```text
[ ] correct destination identity
[ ] correct crop
[ ] sharpness on device
[ ] no stretched image
[ ] no blurred image
[ ] no low-resolution hero
[ ] no repeated generic thumbnail group
[ ] no landmark hidden by overlay/gradient
[ ] no production placeholder
[ ] credit/source UI available when required
```

---

## 6. Device QA Targets

| Device Class | Why |
|---|---|
| Small iPhone | Most likely to expose bad square/tall crop and text-overlay collisions |
| Standard iPhone | Primary everyday layout |
| Large iPhone | Hero scale and card grids |
| iPad / wide layout, if supported | Wide hero composition and crop-safe zones |

---

## 7. Automated QA Requirements

Add or extend static and snapshot gates:

```text
scripts/image-runtime-data-qa.py
scripts/media-static-qa.py
scripts/place-media-static-qa.py
new: scripts/destination-image-registry-qa.py
new: scripts/image-license-registry-qa.py
new: scripts/image-crop-zone-qa.py
new: screenshot QA for Home/Search/Cities/Provinces/Culture/Places/Map/Saved/AI cards
```

The new gates must fail when:

- any shipped image lacks license status
- any destination lacks required variants
- any crop-safe-zone is missing
- any city thumbnail duplicates another city thumbnail outside explicit alias rules
- any hero uses a source below required resolution
- any production screen shows fallback imagery

---

## 8. Current Pass Criteria Audit

| Pass Criterion | Evidence Required | Current Evidence | Result |
|---|---|---|---|
| 0 blurred images | Device screenshots and/or image sharpness checks | Missing | Not proven |
| 0 stretched images | Screenshot + renderer constraints | Partial renderer evidence | Not proven |
| 0 wrong city images | Static map + screenshots | Static partial pass | Partial |
| 0 generic repeated thumbnails | Duplicate scan + visual review | Static city pass, culture reuse remains | Not passed |
| 0 visually lost hero images | Overlay contrast screenshot QA | Missing | Not proven |
| 0 broken crops | Crop-safe-zone QA | Missing | Not passed |
| 0 low-resolution hero assets | Metadata and network/render checks | Partial 2400px registry convention | Partial |
| 0 production placeholders | Runtime screenshots | Missing | Not proven |
| 0 unresolved licensing ambiguity | License registry | Missing for curated heroes | Not passed |

---

## 9. QA Verdict

YouNew cannot yet claim the attached image pass criteria.

Static foundations are in place, but production approval requires device/runtime screenshot evidence, exact license records, crop-safe-zone metadata, and destination-specific secondary image coverage.
