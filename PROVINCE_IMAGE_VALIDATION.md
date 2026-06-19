# Province Image Validation

All 12 provinces were checked for canonical hero ownership, legacy province image risk, and bundled province flag presence.

## Province Findings

| Province | Current Image | Expected Province Identity | Flag Present | Unique Across Owners | Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Drenthe | Hunebed_D27_in_Borger_flickr.jpg | Hunebedden, Drentsche Aa, Assen, forest/heathland | YES | YES | FAIL | Flag asset: YouNew/Assets.xcassets/drenthe_flag.imageset/drenthe_flag.svg, ratio 1.60:1; Legacy province URL is 960px, below card/hero target |
| Flevoland | Oostvaardersplassen._Nieuwe_natuur_op_de_bodem_van_de_voormalige_Zuiderzee_09.jpg | Almere/Lelystad/polders/reclaimed land | YES | YES | FAIL | Flag asset: YouNew/Assets.xcassets/flevoland_flag.imageset/flevoland_flag.svg, ratio 1.60:1; Legacy province URL is 960px, below card/hero target |
| Friesland | Wierum_(Noardeast-Fryslân),_10-07-2023._(d.j.b)_01.jpg | Leeuwarden, Frisian lakes, Wadden, or Elfstedentocht identity | YES | YES | FAIL | Flag asset: YouNew/Assets.xcassets/friesland_flag.imageset/friesland_flag.svg, ratio 1.60:1; Legacy province URL is 960px, below card/hero target |
| Gelderland | Arnhem,_de_John_Frostbrug_RM529907_IMG_3795_2024-07-15_13.06.jpg | Veluwe, Arnhem/Nijmegen context, rivers, or province landscape | YES | NO | FAIL | Province image overlaps another owner: CuratedPlaceHeroMediaRegistry nl-city-gelderland-arnhem (arnhem); NetherlandsData Attraction.imageURL john_frost_bridge (John Fr... |
| Groningen | Hoge der Aa2.jpg | Groningen city, Hoge der Aa, Martinitoren, or northern landscape | YES | YES | FAIL | Flag asset: YouNew/Assets.xcassets/groningen_flag.imageset/groningen_flag.svg, ratio 1.60:1; Legacy province URL is 960px, below card/hero target |
| Limburg | 2022_Magisch_Maastricht_(01).jpg | Maastricht, Sint Servaasbrug, hills, or Limburg landscape | YES | NO | FAIL | Province image overlaps another owner: CuratedPlaceHeroMediaRegistry nl-city-limburg-maastricht (maastricht); NetherlandsData NLCity.imageURL maastricht (maastricht); ... |
| Noord Brabant | St._Jans_cathedral_'s-Hertogenbosch.jpg | Eindhoven/Den Bosch/Breda/Brabant identity without city hero duplication | YES | NO | FAIL | Province image overlaps another owner: CuratedPlaceHeroMediaRegistry nl-city-noord_brabant-den_bosch (s_hertogenbosch); CuratedPlaceHeroMediaRegistry nl-city-noord_bra... |
| Noord Holland | Zaanse_Schans_2019.jpg | Amsterdam/Haarlem/coast/tulip/Zaans identity without duplicating city hero | YES | NO | FAIL | Province image overlaps another owner: CuratedPlaceHeroMediaRegistry nl-city-noord_holland-zaanstad (zaanstad); Flag asset: YouNew/Assets.xcassets/noord_holland_flag.i... |
| Overijssel | Giethoorn_Netherlands_Channels-and-houses-of-Giethoorn-05.jpg | Zwolle/Giethoorn/Salland/Twente identity | YES | YES | FAIL | Flag asset: YouNew/Assets.xcassets/overijssel_flag.imageset/overijssel_flag.svg, ratio 1.60:1; Legacy province URL is 960px, below card/hero target |
| Utrecht | Dom_Tower_Utrecht,_Netherlands.jpg | Dom Tower, Oudegracht, Utrechtse Heuvelrug, or central rail identity | YES | YES | FAIL | Flag asset: YouNew/Assets.xcassets/utrecht_flag.imageset/utrecht_flag.svg, ratio 1.60:1; Legacy province URL is 960px, below card/hero target |
| Zeeland | Vrouwenpolder_(NL),_Oosterscheldekering_--_2022_--_5016.jpg | Delta Works, coast, Middelburg, or maritime landscape | YES | YES | FAIL | Flag asset: YouNew/Assets.xcassets/zeeland_flag.imageset/zeeland_flag.svg, ratio 1.60:1; Legacy province URL is 960px, below card/hero target |
| Zuid Holland | South Holland by Sentinel-2, 2018-06-30.jpg | Rotterdam/Den Haag/Delft/Kinderdijk identity without city hero duplication | YES | YES | FAIL | Flag asset: YouNew/Assets.xcassets/zuid_holland_flag.imageset/zuid_holland_flag.svg, ratio 1.60:1; Legacy province URL is 960px, below card/hero target |

## Province Flag Notes

All 12 province flag assets are present in `Assets.xcassets`. The audit verifies presence and static aspect ratio; official color/geometry validation still requires a visual/spec comparison pass.
