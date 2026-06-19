# Category Asset Requirements

All category imagery must be local to `YouNew/Assets.xcassets`, user-provided, generated, public-domain, or properly licensed for app use. Do not hotlink remote images.

Recommended category hero size: 1200x800 PNG/JPG or vector PDF. Generated SwiftUI artwork is the runtime fallback when the named asset is absent.

| Category | Asset name | Purpose | Recommended file type | License requirement | Fallback used |
|---|---|---|---|---|---|
| BSN & Registration | `category_bsn_hero` | ID card / municipality hero | PNG/JPG/PDF | local/user-provided/generated/public-domain/properly licensed | `GeneratedCategoryArtwork` |
| Housing | `category_housing_hero` | House, key, contract hero | PNG/JPG/PDF | local/user-provided/generated/public-domain/properly licensed | `GeneratedCategoryArtwork` |
| Work | `category_work_hero` | Briefcase, contract, payslip hero | PNG/JPG/PDF | local/user-provided/generated/public-domain/properly licensed | `GeneratedCategoryArtwork` |
| Healthcare | `category_healthcare_hero` | Insurance card / healthcare hero | PNG/JPG/PDF | local/user-provided/generated/public-domain/properly licensed | `GeneratedCategoryArtwork` |
| Transport | `category_transport_hero` | Train, bike, OV-style hero | PNG/JPG/PDF | local/user-provided/generated/public-domain/properly licensed | `GeneratedCategoryArtwork` |
| Fines & Rules | `category_fines_hero` | Warning / letter / traffic hero | PNG/JPG/PDF | local/user-provided/generated/public-domain/properly licensed | `CategoryHeroVisual` |
| Documents | `category_documents_hero` | Folder / scanner / PDF hero | PNG/JPG/PDF | local/user-provided/generated/public-domain/properly licensed | `CategoryHeroVisual` |
| AI Explain | `category_ai_hero` | Source-check assistant hero | PNG/JPG/PDF | local/user-provided/generated/public-domain/properly licensed | `CategoryHeroVisual` |
| LGBTQ+ Support | `category_lgbtq_hero` | Support / shield / community hero | PNG/JPG/PDF | local/user-provided/generated/public-domain/properly licensed | `CategoryHeroVisual` |
| Official websites | `category_official_sources_hero` | Official-source directory hero | PNG/JPG/PDF | local/user-provided/generated/public-domain/properly licensed | `CategoryHeroVisual` |

## Runtime Behavior

If the asset exists, `CategoryHeroVisual` displays the local image. If the asset is absent, generated SwiftUI artwork is shown instead. User-facing screens must not display technical words such as missing asset, debug, fallback, or TODO.
