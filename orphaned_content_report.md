# Orphaned content report

## Result

**Useful materials left without a destination: 0.**

This is an architecture disposition, not permission to delete views. Legacy screens remain until content-level parity proves that every localized title, body, source, link and saved route has migrated to a canonical ID.

## Former orphan risks

| Existing item | Final destination | Disposition |
|---|---|---|
| LegalInfoView | Guide → Official services → Documents, letters and legal safety | Merge into canonical legal-help articles; preserve all sources |
| TranslatorView | Global AI/Search action; discoverable from Guide → Study → Dutch language | Retain as utility; store no second knowledge corpus |
| SurvivalGuideView | Guide → Getting started | Merge into SurvivalNavigator/first-step canonical records after parity check |
| MunicipalitySupportView | Guide → Official services; coordinate-bearing offices also Map | Convert to official-service records and city references |
| RisksView | Guide → Health and safety → Police, scams and personal safety | Merge every useful warning into canonical safety articles |
| MarketingPreviewView | Non-content development surface | Exclude from public IA; it contains no user guide material |
| MoreHub private LegalHelpView | Guide → Official services | Replace private copy with canonical references |

## Coverage rules

1. Every published `canonical_id` is included in Guide regardless of audience.
2. Every published `canonical_id` is included in global Search.
3. Every published record with valid coordinates is included in Map.
4. Records without coordinates may be linked from geographic entities but never receive invented coordinates.
5. Home, Saved, AI, category cards, map callouts and related-content modules store references only.
6. A legacy screen may be retired only when a migration test proves content and link parity in all supported languages.

## Required migration gate

- Source inventory count equals migrated canonical record count plus documented merges.
- Every merge lists all source IDs and produces no missing localized fields.
- No unresolved AppDestination, Saved ID or deep link points to a retired screen.
- Search coverage is 100% of published canonical IDs.
- Coordinate-bearing coverage is 100% in Map, with validation of city/province relationships.
- Audience matrix confirms identical accessible corpus for Newcomer, Student, Visitor, Worker, Family and Resident; only ordering differs.

