# Flag Audit

Generated: 2026-06-13

## Province Flags

| Province | Asset | Exists | Status | Notes |
|---|---|---:|---|---|
| Noord-Holland | `noord_holland_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Zuid-Holland | `zuid_holland_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Utrecht | `utrecht_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Zeeland | `zeeland_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Gelderland | `gelderland_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Noord-Brabant | `noord_brabant_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Limburg | `limburg_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Flevoland | `flevoland_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Drenthe | `drenthe_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Friesland | `friesland_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Overijssel | `overijssel_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |
| Groningen | `groningen_flag` | YES | PASS | Official province flag asset; symbol renderer uses `scaledToFit`. |

## City Flags And Coats

| City | Province | Flag Asset | Coat Asset | Status | Notes |
|---|---|---|---|---|---|
| Amsterdam | Noord-Holland | `city_amsterdam_flag` | `city_amsterdam_coat_of_arms` | PASS | Both local symbol assets available. |
| Haarlem | Noord-Holland | `city_haarlem_flag` | `city_haarlem_coat_of_arms` | PASS | Both local symbol assets available. |
| Alkmaar | Noord-Holland | `city_alkmaar_flag` | `city_alkmaar_coat_of_arms` | PASS | Both local symbol assets available. |
| Hoorn | Noord-Holland | `city_hoorn_flag` | `city_hoorn_coat_of_arms` | PASS | Both local symbol assets available. |
| Zaanstad | Noord-Holland | `city_zaanstad_flag` | `city_zaanstad_coat_of_arms` | PASS | Both local symbol assets available. |
| Amstelveen | Noord-Holland | `city_amstelveen_flag` | `city_amstelveen_coat_of_arms` | PASS | Both local symbol assets available. |
| Purmerend | Noord-Holland | `city_purmerend_flag` | `city_purmerend_coat_of_arms` | PASS | Both local symbol assets available. |
| Heerhugowaard | Noord-Holland | `city_heerhugowaard_flag` | `city_heerhugowaard_coat_of_arms` | PASS | Both local symbol assets available. |
| Rotterdam | Zuid-Holland | `city_rotterdam_flag` | `city_rotterdam_coat_of_arms` | PASS | Both local symbol assets available. |
| Den Haag | Zuid-Holland | `city_den_haag_flag` | `city_den_haag_coat_of_arms` | PASS | Both local symbol assets available. |
| Leiden | Zuid-Holland | `city_leiden_flag` | `city_leiden_coat_of_arms` | PASS | Both local symbol assets available. |
| Delft | Zuid-Holland | `city_delft_flag` | `city_delft_coat_of_arms` | PASS | Both local symbol assets available. |
| Utrecht | Utrecht | `city_utrecht_flag` | `city_utrecht_coat_of_arms` | PASS | Both local symbol assets available. |
| Amersfoort | Utrecht | `city_amersfoort_flag` | `city_amersfoort_coat_of_arms` | PASS | Both local symbol assets available. |
| Arnhem | Gelderland | `city_arnhem_flag` | `city_arnhem_coat_of_arms` | PASS | Both local symbol assets available. |
| Nijmegen | Gelderland | `city_nijmegen_flag` | `city_nijmegen_coat_of_arms` | PASS | Both local symbol assets available. |
| Eindhoven | Noord-Brabant | `city_eindhoven_flag` | `city_eindhoven_coat_of_arms` | PASS | Both local symbol assets available. |
| Tilburg | Noord-Brabant | `city_tilburg_flag` | `city_tilburg_coat_of_arms` | PASS | Both local symbol assets available. |
| Breda | Noord-Brabant | `city_breda_flag` | `city_breda_coat_of_arms` | PASS | Both local symbol assets available. |
| 's-Hertogenbosch | Noord-Brabant | `city_s_hertogenbosch_flag` | `city_s_hertogenbosch_coat_of_arms` | PASS | Both local symbol assets available. |
| Maastricht | Limburg | `city_maastricht_flag` | `city_maastricht_coat_of_arms` | PASS | Both local symbol assets available. |
| Venlo | Limburg | `city_venlo_flag` | `city_venlo_coat_of_arms` | PASS | Both local symbol assets available. |
| Zwolle | Overijssel | `city_zwolle_flag` | `city_zwolle_coat_of_arms` | PASS | Both local symbol assets available. |
| Almere | Flevoland | `city_almere_flag` | `city_almere_coat_of_arms` | PASS | Both local symbol assets available. |
| Lelystad | Flevoland | `city_lelystad_flag` | `city_lelystad_coat_of_arms` | PASS | Both local symbol assets available. |
| Groningen | Groningen | `city_groningen_flag` | `city_groningen_coat_of_arms` | PASS | Both local symbol assets available. |
| Leeuwarden | Friesland | `city_leeuwarden_flag` | `city_leeuwarden_coat_of_arms` | PASS | Both local symbol assets available. |
| Assen | Drenthe | `city_assen_flag` | `city_assen_coat_of_arms` | PASS | Both local symbol assets available. |
| Middelburg | Zeeland | `city_middelburg_flag` | `city_middelburg_coat_of_arms` | PASS | Both local symbol assets available. |

## Issues And Fixes

| Severity | Screen | Asset | Root Cause | Fix |
|---|---|---|---|---|
| High | City identity / province city cards | `city_zaanstad_flag` | Zaanstad had no local flag asset and metadata flag was nil. | Added local SVG asset and registry flag metadata. |
| High | City identity / province city cards | `city_purmerend_flag` | Purmerend had no local flag asset and metadata flag was nil. | Added local SVG asset and registry flag metadata. |
| Medium | City identity | `city_amstelveen_coat_of_arms` | Amstelveen coat-of-arms metadata was nil and local asset was absent. | Added local SVG asset and registry coat metadata. |
| Medium | City identity | `city_purmerend_coat_of_arms` | Purmerend coat-of-arms imageset existed without files. | Added local SVG asset. |

## Gate

- Province flags: PASS for 12/12 bundled assets present.
- City symbol assets: PASS for 29/29 catalog cities.
- Stretch/crop risk: low; symbol renderer uses `scaledToFit`.
