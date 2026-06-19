# Image Size Audit

Minimum targets used:

- Hero images: 16:9 preferred, minimum 2400px on the long edge.
- Cards: 4:3 or 16:9 preferred, minimum 1200px on the long edge.
- Icons and flags: vector or Retina-quality raster with official proportions.

Remote files were not downloaded. Findings use local raster dimensions, SVG viewBoxes, declared metadata, and URL width hints.

## Findings

| Status | Source | Image / Record | Purpose | Resolution / Width Hint | Aspect Ratio | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| PASS | Bundled asset | YouNew/Assets.xcassets/AppIcon.appiconset/icon-1024.png | App icon required size variant | 1024 x 1024 | 1.00:1 | App icon sizes are intentionally provided in multiple raster sizes; not evaluated as content cards |
| PASS | Bundled asset | YouNew/Assets.xcassets/AppIcon.appiconset/icon-128.png | App icon required size variant | 128 x 128 | 1.00:1 | App icon sizes are intentionally provided in multiple raster sizes; not evaluated as content cards |
| PASS | Bundled asset | YouNew/Assets.xcassets/AppIcon.appiconset/icon-16.png | App icon required size variant | 16 x 16 | 1.00:1 | App icon sizes are intentionally provided in multiple raster sizes; not evaluated as content cards |
| PASS | Bundled asset | YouNew/Assets.xcassets/AppIcon.appiconset/icon-256.png | App icon required size variant | 256 x 256 | 1.00:1 | App icon sizes are intentionally provided in multiple raster sizes; not evaluated as content cards |
| PASS | Bundled asset | YouNew/Assets.xcassets/AppIcon.appiconset/icon-32.png | App icon required size variant | 32 x 32 | 1.00:1 | App icon sizes are intentionally provided in multiple raster sizes; not evaluated as content cards |
| PASS | Bundled asset | YouNew/Assets.xcassets/AppIcon.appiconset/icon-512.png | App icon required size variant | 512 x 512 | 1.00:1 | App icon sizes are intentionally provided in multiple raster sizes; not evaluated as content cards |
| PASS | Bundled asset | YouNew/Assets.xcassets/AppIcon.appiconset/icon-64.png | App icon required size variant | 64 x 64 | 1.00:1 | App icon sizes are intentionally provided in multiple raster sizes; not evaluated as content cards |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_alkmaar_coat_of_arms.imageset/city_alkmaar_coat_of_arms.png | Coat of arms asset | 1280 x 903 | 1.42:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_alkmaar_flag.imageset/city_alkmaar_flag.png | Flag asset | 1280 x 854 | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_almere_coat_of_arms.imageset/city_almere_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_almere_flag.imageset/city_almere_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_amersfoort_coat_of_arms.imageset/city_amersfoort_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_amersfoort_flag.imageset/city_amersfoort_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_amstelveen_coat_of_arms.imageset/city_amstelveen_coat_of_arms.svg | Coat of arms asset | 250 x 300 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_amstelveen_flag.imageset/city_amstelveen_flag.png | Flag asset | 1280 x 853 | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_amsterdam_coat_of_arms.imageset/city_amsterdam_coat_of_arms.svg | Coat of arms asset | 250 x 300 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_amsterdam_flag.imageset/city_amsterdam_flag.svg | Flag asset | 450 x 300 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_arnhem_coat_of_arms.imageset/city_arnhem_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_arnhem_flag.imageset/city_arnhem_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_assen_coat_of_arms.imageset/city_assen_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_assen_flag.imageset/city_assen_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_breda_coat_of_arms.imageset/city_breda_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_breda_flag.imageset/city_breda_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_delft_coat_of_arms.imageset/city_delft_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_delft_flag.imageset/city_delft_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_den_haag_coat_of_arms.imageset/city_den_haag_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_den_haag_flag.imageset/city_den_haag_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_eindhoven_coat_of_arms.imageset/city_eindhoven_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_eindhoven_flag.imageset/city_eindhoven_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_groningen_coat_of_arms.imageset/city_groningen_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_groningen_flag.imageset/city_groningen_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_haarlem_coat_of_arms.imageset/city_haarlem_coat_of_arms.png | Coat of arms asset | 1280 x 1105 | 1.16:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_haarlem_flag.imageset/city_haarlem_flag.png | Flag asset | 1280 x 853 | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_heerhugowaard_coat_of_arms.imageset/city_heerhugowaard_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_heerhugowaard_flag.imageset/city_heerhugowaard_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_hoorn_coat_of_arms.imageset/city_hoorn_coat_of_arms.png | Coat of arms asset | 1280 x 1511 | 0.85:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_hoorn_flag.imageset/city_hoorn_flag.png | Flag asset | 1280 x 854 | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_leeuwarden_coat_of_arms.imageset/city_leeuwarden_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_leeuwarden_flag.imageset/city_leeuwarden_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_leiden_coat_of_arms.imageset/city_leiden_coat_of_arms.svg | Coat of arms asset | 466.293 x 728.823 vector | 0.64:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_leiden_flag.imageset/city_leiden_flag.svg | Flag asset | 450 x 300 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_lelystad_coat_of_arms.imageset/city_lelystad_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_lelystad_flag.imageset/city_lelystad_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_maastricht_coat_of_arms.imageset/city_maastricht_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_maastricht_flag.imageset/city_maastricht_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_middelburg_coat_of_arms.imageset/city_middelburg_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_middelburg_flag.imageset/city_middelburg_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_nijmegen_coat_of_arms.imageset/city_nijmegen_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_nijmegen_flag.imageset/city_nijmegen_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_purmerend_coat_of_arms.imageset/city_purmerend_coat_of_arms.svg | Coat of arms asset | 250 x 300 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_purmerend_flag.imageset/city_purmerend_flag.svg | Flag asset | 450 x 300 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_rotterdam_coat_of_arms.imageset/city_rotterdam_coat_of_arms.svg | Coat of arms asset | 1189.61 x 738.399 vector | 1.61:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_rotterdam_flag.imageset/city_rotterdam_flag.svg | Flag asset | 450 x 300 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_s_hertogenbosch_coat_of_arms.imageset/city_s_hertogenbosch_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_s_hertogenbosch_flag.imageset/city_s_hertogenbosch_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_tilburg_coat_of_arms.imageset/city_tilburg_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_tilburg_flag.imageset/city_tilburg_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_utrecht_coat_of_arms.imageset/city_utrecht_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_utrecht_flag.imageset/city_utrecht_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_venlo_coat_of_arms.imageset/city_venlo_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_venlo_flag.imageset/city_venlo_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_zaanstad_coat_of_arms.imageset/city_zaanstad_coat_of_arms.png | Coat of arms asset | 1280 x 704 | 1.82:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_zaanstad_flag.imageset/city_zaanstad_flag.svg | Flag asset | 450 x 300 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_zwolle_coat_of_arms.imageset/city_zwolle_coat_of_arms.svg | Coat of arms asset | 200 x 240 vector | 0.83:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/city_zwolle_flag.imageset/city_zwolle_flag.svg | Flag asset | 300 x 200 vector | 1.50:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/drenthe_flag.imageset/drenthe_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/flevoland_flag.imageset/flevoland_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/friesland_flag.imageset/friesland_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/gelderland_flag.imageset/gelderland_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/groningen_flag.imageset/groningen_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| FAIL | Bundled asset | YouNew/Assets.xcassets/home_documents_city_hall.imageset/home_documents_city_hall.jpg | Home/category visual asset | 1920 x 1280 | 1.50:1 | Below 2400px hero target if rendered as hero |
| FAIL | Bundled asset | YouNew/Assets.xcassets/home_emergency_ambulance.imageset/home_emergency_ambulance.jpg | Home/category visual asset | 1920 x 1080 | 1.78:1 | Below 2400px hero target if rendered as hero |
| FAIL | Bundled asset | YouNew/Assets.xcassets/home_healthcare_pharmacy.imageset/home_healthcare_pharmacy.jpg | Home/category visual asset | 1920 x 1440 | 1.33:1 | Below 2400px hero target if rendered as hero |
| FAIL | Bundled asset | YouNew/Assets.xcassets/home_language_classroom.imageset/home_language_classroom.jpg | Home/category visual asset | 1920 x 1252 | 1.53:1 | Below 2400px hero target if rendered as hero |
| FAIL | Bundled asset | YouNew/Assets.xcassets/home_leiden_canals.imageset/home_leiden_canals.jpg | Home/category visual asset | 1920 x 1207 | 1.59:1 | Below 2400px hero target if rendered as hero |
| PASS | Bundled asset | YouNew/Assets.xcassets/home_work_zuidas.imageset/home_work_zuidas.jpg | Home/category visual asset | 1642 x 2500 | 0.66:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/limburg_flag.imageset/limburg_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_drenthe.imageset/map_drenthe.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_flevoland.imageset/map_flevoland.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_friesland.imageset/map_friesland.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_gelderland.imageset/map_gelderland.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_groningen.imageset/map_groningen.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_limburg.imageset/map_limburg.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_noord_brabant.imageset/map_noord_brabant.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_noord_holland.imageset/map_noord_holland.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_overijssel.imageset/map_overijssel.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_utrecht.imageset/map_utrecht.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_zeeland.imageset/map_zeeland.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/map_zuid_holland.imageset/map_zuid_holland.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/netherlands_map_base.imageset/netherlands_map_base.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/netherlands_map_provinces.imageset/netherlands_map_provinces.svg | Bundled image asset | 100 x 160 vector | 0.62:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/noord_brabant_flag.imageset/noord_brabant_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/noord_holland_flag.imageset/noord_holland_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/overijssel_flag.imageset/overijssel_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| FAIL | Bundled asset | YouNew/Assets.xcassets/premium_home_background.imageset/premium_home_background.png | Home/category visual asset | 941 x 1672 | 0.56:1 | Below 2400px hero target if rendered as hero |
| FAIL | Bundled asset | YouNew/Assets.xcassets/premium_home_documents.imageset/premium_home_documents.png | Home/category visual asset | 1586 x 992 | 1.60:1 | Below 2400px hero target if rendered as hero |
| FAIL | Bundled asset | YouNew/Assets.xcassets/premium_home_emergency.imageset/premium_home_emergency.png | Home/category visual asset | 1586 x 992 | 1.60:1 | Below 2400px hero target if rendered as hero |
| FAIL | Bundled asset | YouNew/Assets.xcassets/premium_home_healthcare.imageset/premium_home_healthcare.png | Home/category visual asset | 1586 x 992 | 1.60:1 | Below 2400px hero target if rendered as hero |
| FAIL | Bundled asset | YouNew/Assets.xcassets/premium_home_housing.imageset/premium_home_housing.png | Home/category visual asset | 1586 x 992 | 1.60:1 | Below 2400px hero target if rendered as hero |
| FAIL | Bundled asset | YouNew/Assets.xcassets/premium_home_language.imageset/premium_home_language.png | Home/category visual asset | 1586 x 992 | 1.60:1 | Below 2400px hero target if rendered as hero |
| FAIL | Bundled asset | YouNew/Assets.xcassets/premium_home_work.imageset/premium_home_work.png | Home/category visual asset | 1586 x 992 | 1.60:1 | Below 2400px hero target if rendered as hero |
| PASS | Bundled asset | YouNew/Assets.xcassets/premium_netherlands_emergency_fallback.imageset/premium_netherlands_emergency_fallback.svg | Fallback image asset | 2400 x 1350 vector | 1.78:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/utrecht_flag.imageset/utrecht_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/zeeland_flag.imageset/zeeland_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| PASS | Bundled asset | YouNew/Assets.xcassets/zuid_holland_flag.imageset/zuid_holland_flag.svg | Flag asset | 160 x 100 vector | 1.60:1 |  |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-noord_holland-amsterdam | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-noord_holland-haarlem | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-noord_holland-alkmaar | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-noord_holland-hoorn | City canonical hero | 3840 | Unknown | URL width hint 3840px |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-noord_holland-zaanstad | City canonical hero | 3840 | Unknown | URL width hint 3840px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-noord_holland-amstelveen | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-noord_holland-purmerend | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-noord_holland-heerhugowaard | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-zuid_holland-rotterdam | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-zuid_holland-den_haag | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-zuid_holland-leiden | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-zuid_holland-delft | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-utrecht-utrecht | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-utrecht-amersfoort | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-gelderland-arnhem | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-gelderland-nijmegen | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-noord_brabant-eindhoven | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-noord_brabant-tilburg | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-noord_brabant-breda | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-noord_brabant-s_hertogenbosch | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-noord_brabant-den_bosch | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-limburg-maastricht | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-limburg-venlo | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-overijssel-zwolle | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-flevoland-almere | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-flevoland-lelystad | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | CuratedPlaceHeroMediaRegistry | nl-city-groningen-groningen | City canonical hero | 2400 | Unknown | URL width hint 2400px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-friesland-leeuwarden | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-drenthe-assen | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-city-zeeland-middelburg | City canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-province-noord_holland | Province canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | CuratedPlaceHeroMediaRegistry | nl-province-zuid_holland | Province canonical hero | 2400 | Unknown | URL width hint 2400px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-province-utrecht | Province canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-province-gelderland | Province canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | CuratedPlaceHeroMediaRegistry | nl-province-noord_brabant | Province canonical hero | 2400 | Unknown | URL width hint 2400px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-province-limburg | Province canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-province-overijssel | Province canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-province-flevoland | Province canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | CuratedPlaceHeroMediaRegistry | nl-province-groningen | Province canonical hero | 2400 | Unknown | URL width hint 2400px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-province-friesland | Province canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | CuratedPlaceHeroMediaRegistry | nl-province-drenthe | Province canonical hero | 2400 | Unknown | URL width hint 2400px |
| WARNING | CuratedPlaceHeroMediaRegistry | nl-province-zeeland | Province canonical hero | Unknown | Unknown | No width hint; remote dimensions not fetched |
| PASS | NetherlandsData NLCity.imageURL | amsterdam | Legacy city hero/model image | 2400 | Unknown | URL width hint 2400px |
| PASS | NetherlandsData NLCity.imageURL | rotterdam | Legacy city hero/model image | 2400 | Unknown | URL width hint 2400px |
| PASS | NetherlandsData NLCity.imageURL | den_haag | Legacy city hero/model image | 2400 | Unknown | URL width hint 2400px |
| PASS | NetherlandsData NLCity.imageURL | leiden | Legacy city hero/model image | 2400 | Unknown | URL width hint 2400px |
| PASS | NetherlandsData NLCity.imageURL | utrecht | Legacy city hero/model image | 2400 | Unknown | URL width hint 2400px |
| PASS | NetherlandsData NLCity.imageURL | groningen | Legacy city hero/model image | 2400 | Unknown | URL width hint 2400px |
| FAIL | NetherlandsData NLCity.imageURL | nijmegen | Legacy city hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLCity.imageURL | arnhem | Legacy city hero/model image | 1280 | Unknown | Hero URL width hint 1280px below 2400px target |
| PASS | NetherlandsData NLCity.imageURL | maastricht | Legacy city hero/model image | 2400 | Unknown | URL width hint 2400px |
| PASS | NetherlandsData NLCity.imageURL | eindhoven | Legacy city hero/model image | 2400 | Unknown | URL width hint 2400px |
| FAIL | NetherlandsData NLCity.imageURL | delft | Legacy city hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| PASS | NetherlandsData NLCity.imageURL | haarlem | Legacy city hero/model image | 2400 | Unknown | URL width hint 2400px |
| FAIL | NetherlandsData NLProvince.imageURL | noord_holland | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | zuid_holland | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | utrecht | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | gelderland | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | noord_brabant | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | groningen | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | limburg | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | friesland | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | overijssel | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | drenthe | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | zeeland | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData NLProvince.imageURL | flevoland | Legacy province hero/model image | 960 | Unknown | Hero URL width hint 960px below 2400px target |
| FAIL | NetherlandsData Attraction.imageURL | rijks | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| FAIL | NetherlandsData Attraction.imageURL | vangogh | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| FAIL | NetherlandsData Attraction.imageURL | annefrank | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| FAIL | NetherlandsData Attraction.imageURL | markthal | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| PASS | NetherlandsData Attraction.imageURL | kubus | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| FAIL | NetherlandsData Attraction.imageURL | euromast | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| PASS | NetherlandsData Attraction.imageURL | erasmus | Attraction/place image | 2400 | Unknown | URL width hint 2400px |
| PASS | NetherlandsData Attraction.imageURL | binnenhof | Attraction/place image | 2400 | Unknown | URL width hint 2400px |
| FAIL | NetherlandsData Attraction.imageURL | peacepalace | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| PASS | NetherlandsData Attraction.imageURL | scheveningen | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| FAIL | NetherlandsData Attraction.imageURL | mauritshuis | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| PASS | NetherlandsData Attraction.imageURL | hortusleiden | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | devalk | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | oudheden | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| FAIL | NetherlandsData Attraction.imageURL | domtoren | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| PASS | NetherlandsData Attraction.imageURL | oudegracht | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | speelklok | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | martinitoren | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | groningermuseum | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| FAIL | NetherlandsData Attraction.imageURL | valkhof_museum | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| PASS | NetherlandsData Attraction.imageURL | waalbrug | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | valkhof_park | Attraction/place image | 2400 | Unknown | URL width hint 2400px |
| PASS | NetherlandsData Attraction.imageURL | john_frost_bridge | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| FAIL | NetherlandsData Attraction.imageURL | hoge_veluwe | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| FAIL | NetherlandsData Attraction.imageURL | kroller_muller | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| PASS | NetherlandsData Attraction.imageURL | vrijthof | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | servatius | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | dominicanen | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | philipsmuseum | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | evoluon | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | vanabbe | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| FAIL | NetherlandsData Attraction.imageURL | nieuwe_kerk_delft | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| FAIL | NetherlandsData Attraction.imageURL | royal_delft | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| FAIL | NetherlandsData Attraction.imageURL | prinsenhof_delft | Attraction/place image | 960 | Unknown | URL width hint 960px below 1200px card target |
| PASS | NetherlandsData Attraction.imageURL | franshals | Attraction/place image | 1600 | Unknown | URL width hint 1600px |
| PASS | NetherlandsData Attraction.imageURL | teylers | Attraction/place image | 1280 | Unknown | URL width hint 1280px |
| PASS | NetherlandsData Attraction.imageURL | grotekerk | Attraction/place image | 1600 | Unknown | URL width hint 1600px |
| FAIL | CanonicalPlaceImageResolver | fallbackURLs | Fallback chain | N/A | N/A | Resolver currently returns empty fallbackURLs in city/province/media resolutions; static fallback chain is not encoded in resolved output |
| WARNING | ImageLoader / CityImageView | DirectImageLoader | Fallback traversal | N/A | N/A | CityImageView exposes fallbackURLStrings but DirectImageLoader loads one effective URL; runtime verification needed for all failure modes |

## Static Fit Caveat

This audit cannot prove runtime crop quality, landmark framing, or overlay readability. Those require screenshot/device verification for Home, Cities, Provinces, History, Guides, Journeys, Help, Map, and AI.
