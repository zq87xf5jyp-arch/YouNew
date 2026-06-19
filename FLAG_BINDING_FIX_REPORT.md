# Flag Binding Fix Report

Date: 2026-06-11

## Root Cause

Priority city screens were still using simplified stripe-only `CityFlagView` data in several NLCity surfaces, even though verified local city flag assets already existed in `Assets.xcassets`. This could make city flags look generic, incomplete, or visually incorrect in runtime cards.

## Fix Applied

- Added asset-backed `CityOfficialFlagView` with `CityFlagView` as fallback.
- Replaced visible NLCity flag widgets on Home, featured city card, city detail hero, city flag section, and sidebar city cards.
- Existing province/city catalog `CityItem` badge logic already uses local city flag assets and remains unchanged.

## File References

- `YouNew/Components/NetherlandsCityViews.swift`: `CityOfficialFlagView` added at line 43.
- `YouNew/Components/NetherlandsCityViews.swift`: city detail hero uses asset-backed flag at line 198.
- `YouNew/Components/NetherlandsCityViews.swift`: city flag section uses asset-backed flag at line 260.
- `YouNew/Components/NetherlandsCityViews.swift`: sidebar city card uses asset-backed flag at line 786.
- `YouNew/Views/HomeView.swift`: city pills use asset-backed flag at line 574.
- `YouNew/Views/HomeView.swift`: featured city card uses asset-backed flag at line 881.

## Requested City Flag Assets

| City | Asset | Status |
|---|---|---|
| Amsterdam | `city_amsterdam_flag` | OK |
| Rotterdam | `city_rotterdam_flag` | OK |
| Den Haag | `city_den_haag_flag` | OK |
| Leiden | `city_leiden_flag` | OK |
| Utrecht | `city_utrecht_flag` | OK |
| Groningen | `city_groningen_flag` | OK |
| Maastricht | `city_maastricht_flag` | OK |
| Arnhem | `city_arnhem_flag` | OK |
| Nijmegen | `city_nijmegen_flag` | OK |
| Zwolle | `city_zwolle_flag` | OK |
| Haarlem | `city_haarlem_flag` | OK |

## Verification

- Static asset existence check: passed for all requested cities.
- Remaining fallback use: only inside `CityOfficialFlagView` if a future city asset is missing.

Status: Fixed statically. Runtime visual confirmation still requires a physical-device pass.
