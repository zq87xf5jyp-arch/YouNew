# City Image Validation

Each city must have a unique hero, landmark, identity photo, thumbnail, and card preview. This audit validates ownership from registry/model mappings; runtime screenshot review is still required for final crop and landmark visibility.

## City Findings

| City | Current Image | Expected Image Identity | Unique Across Owners | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| Alkmaar | Alkmaar_-_Waagplein_-_De_Waag_-_Cheese_Weighhouse_1583.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Almere | Centrum_Almere_Stad,_Almere,_Netherlands_-_panoramio.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Amersfoort | Amersfoort_Zuidsingel.JPG | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Amstelveen | Amstelveen_Laan_van_Deshima.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Amsterdam | Canal houses and Oude Kerk at blue hour with water reflection in Damrak Amsterdam Netherlands.jpg | Canals, Dam Square, Rijksmuseum, or Damrak/Oude Kerk | YES | PASS |  |
| Arnhem | Arnhem, de John Frostbrug RM529907 IMG 3795 2024-07-15 13.06.jpg | John Frost Bridge, Sonsbeek, or Arnhem center | NO | FAIL | Image source reused outside city owner: CuratedPlaceHeroMediaRegistry nl-province-gelderland (gelderland); NetherlandsData Attraction.imageURL john_frost_bridge (John ... |
| Assen | AssenMarkt.JPG | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Breda | 2010-05-21-breda-by-RalfR-06.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Delft | Delft_Blick_von_der_Nieuwe_Kerk_auf_die_Oude_Kerk_1.jpg | Nieuwe Kerk, Delft canals, Markt, or Delftware context | NO | FAIL | Image source reused outside city owner: NetherlandsData Attraction.imageURL prinsenhof_delft (Prinsenhof Museum); NetherlandsData Attraction.imageURL royal_delft (Roya... |
| The Hague | Friedenspalast_Den_Haag.jpg | Binnenhof, Peace Palace, Scheveningen, or Mauritshuis | YES | PASS |  |
| Eindhoven | Eindhoven-Witte Dame (5).jpg | Modern technology district, Strijp-S, or city center | YES | PASS |  |
| Groningen | 20100523 Grote Markt en Martinitoren Groningen NL.jpg | Martinitoren or historic center | YES | PASS |  |
| Haarlem | HaarlemGroteMarkt1.JPG | Grote Markt, St. Bavo Church, canals, or historic center | NO | FAIL | Image source reused outside city owner: NetherlandsData Attraction.imageURL grotekerk (Sint-Bavokerk) |
| Heerhugowaard | Station_Heerhugowaard_(2024)-11.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Hoorn | Hoorn_Harbor_Dawn_(28288594445).jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Leeuwarden | Nieuwestad-_Leeuwarden.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Leiden | Oude Vest canal, Leiden 6869.jpg | Historic canals, university buildings, Burcht, or Molen de Valk | YES | PASS |  |
| Lelystad | Lelystad,_reconstructie_van_de_Batavia_op_de_Bataviawerf_IMG_4212_2024-07-28_13.28.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Maastricht | 2022_Magisch_Maastricht_(01).jpg | Vrijthof or Sint Servaasbrug | NO | FAIL | Image source reused outside city owner: CuratedPlaceHeroMediaRegistry nl-province-limburg (limburg) |
| Middelburg | Middelburg_Stadhuis_01.JPG | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Nijmegen | Nijmegen Waalbrug R01.jpg | Waalbrug, Grote Markt, Stevenskerk, or old city center | NO | FAIL | Image source reused outside city owner: NetherlandsData Attraction.imageURL valkhof_museum (Museum Het Valkhof); NetherlandsData Attraction.imageURL waalbrug (Waalbrug) |
| Purmerend | Koemarkt_Purmerend_in_de_zomer.JPG | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Rotterdam | Erasmusbrug seen from Euromast.jpg | Erasmus Bridge, modern skyline, Markthal, or port | NO | FAIL | Image source reused outside city owner: NetherlandsData Attraction.imageURL erasmus (Erasmus Bridge) |
| 's-Hertogenbosch | St._Jans_cathedral_'s-Hertogenbosch.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | NO | FAIL | Image source reused outside city owner: CuratedPlaceHeroMediaRegistry nl-province-noord_brabant (noord_brabant) |
| Tilburg | De_heuvel_in_Tilburg.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Utrecht | Utrecht, de Domtoren (RM36075) vanaf de Oudegracht 230 ongeveer foto5 2015-11-01 08.56.jpg | Dom Tower or Oudegracht | YES | PASS |  |
| Venlo | Venlo_–_Parade_-_panoramio.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | YES | PASS |  |
| Zaanstad | Zaanse_Schans_2019.jpg | Unique city-specific hero, identity photo, thumbnail, and card preview | NO | FAIL | Image source reused outside city owner: CuratedPlaceHeroMediaRegistry nl-province-noord_holland (noord_holland); NetherlandsData NLProvince.imageURL noord_holland (noo... |
| Zwolle | Sassenstraat_1-15,_Zwolle.jpg | Sassenpoort, Grote Kerk, or historic center | YES | PASS |  |

## Critical City Findings

- Rotterdam, Nijmegen, Arnhem, Delft, and Haarlem have city hero/source imagery reused by attraction/place records.
- `content-home-amsterdam-canal-houses` is labeled like Amsterdam but points to Leiden canals/local asset `home_leiden_canals`.
- Legacy `NLCity.imageURL` values still exist beside the canonical registry; any UI path that bypasses the resolver can show older or lower-quality imagery.
