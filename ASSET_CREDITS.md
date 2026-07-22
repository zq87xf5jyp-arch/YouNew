# Asset Credits

Last reviewed: 2026-07-22

Province flag and Netherlands map assets are original simplified SVG vector
renditions created for YouNew. City flags and coats of arms are now exact current
Wikimedia Commons files whose pages identify them as public domain; they are used
for informational identification without an endorsement claim.

| Asset names | Source | License | Modification note |
| --- | --- | --- | --- |
| `noord_holland_flag`, `zuid_holland_flag`, `utrecht_flag`, `gelderland_flag`, `noord_brabant_flag`, `limburg_flag`, `overijssel_flag`, `flevoland_flag`, `groningen_flag`, `friesland_flag`, `drenthe_flag`, `zeeland_flag` | Self-created SVG vectors for this project | Project-owned | Simplified province flag-style vectors using broad public visual motifs and colors; not official assets |
| `netherlands_map_base`, `netherlands_map_provinces` | Self-created SVG vectors for this project | Project-owned | Simplified Netherlands province layout for in-app navigation |
| `map_noord_holland`, `map_zuid_holland`, `map_utrecht`, `map_gelderland`, `map_noord_brabant`, `map_limburg`, `map_overijssel`, `map_flevoland`, `map_groningen`, `map_friesland`, `map_drenthe`, `map_zeeland` | Self-created SVG vectors for this project | Project-owned | Template province overlays aligned to the simplified base map |
| 58 `city_*_flag` / `city_*_coat_of_arms` SVGs | Exact Wikimedia Commons originals recorded in `BuildWeekFix/CITY_SYMBOL_RIGHTS.json` | Public domain on each recorded source page | No local visual modification; local SHA-1 equals the Commons revision SHA-1 checked 2026-07-22. Independent rules for official municipal symbols may still apply; no endorsement is implied. |
| `AppIcon` | `Design/AppIcon/source.svg` and deterministic generators under `scripts/generate-app-icons.*` | Project-owned; owner-confirmed | Generated PNG sizes and source hashes are recorded in `BuildWeekFix/MEDIA_RIGHTS_OWNER_ATTESTATION.md`. |
| Six `premium_home_*` PNGs | OpenAI-generated for YouNew with embedded C2PA/JUMBF structure and generator metadata | Project-owned; owner-confirmed | File identity and structural metadata are recorded in `BuildWeekFix/C2PA_MEDIA_EVIDENCE.json`; the offline gate does not claim cryptographic signature-chain validation. Redistribution scope is recorded in the owner confirmation. |
| `home_emergency_ambulance`, `home_language_classroom`, `home_work_zuidas` | Exact byte aliases of the corresponding confirmed `premium_home_*` assets | Project-owned; owner-confirmed | Compatibility asset IDs retained without re-encoding, preserving the source bytes and embedded provenance container. |

## Third-party photography

The 72 Netherlands-pack photographs plus four in-app context images have creator,
source, license, credit line, and modification records in
`YouNew/Resources/MediaAttributions.json`. The same records are visible in the app
through **More → About YouNew → Media and licenses**.
