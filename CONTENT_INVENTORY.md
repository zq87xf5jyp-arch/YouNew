# YouNew Information Architecture Content Inventory

Audit date: 2026-06-13  
Scope: static code inventory plus targeted navigation fixes. Runtime device verification was not performed in this pass.

## Executive Status

Current IA status: PARTIAL PASS after routing fixes.

The app has strong content depth, but it has been growing as multiple parallel systems: Home tiles, side menu items, More hub rows, Help hub categories, Survival cards, Guide sections, practical guides, map focus screens, and source directories. The main release risk is not missing content; it is users being sent to a nearby-but-wrong section.

Fixed in this pass:

- More now has its own navigation stack instead of reusing Home: `YouNew/Views/RootTabView.swift:56`, `YouNew/Views/RootTabView.swift:593`, `YouNew/Views/RootTabView.swift:647`.
- Help > Work now opens the Work guide instead of Institutions: `YouNew/Views/HelpHubView.swift:28`.
- Help > Money & Taxes now opens Banking basics instead of Institutions: `YouNew/Views/HelpHubView.swift:31`.
- Help > Legal help now opens Official Sources instead of Survival: `YouNew/Views/HelpHubView.swift:33`.
- Help > Family now opens the Family status path instead of Emotional Support: `YouNew/Views/HelpHubView.swift:35`.
- Help > LGBTQ+ now opens a dedicated LGBTQ+ support destination: `YouNew/Models/AppDestination.swift:143`, `YouNew/Views/AppDestinationView.swift:108`, `YouNew/Views/HelpHubView.swift:36`.
- Survival guide routing now points to canonical guide sections for transport, documents, work, housing, healthcare, government, and emergency: `YouNew/ViewModels/AppStateViewModel.swift:87`.
- More category navigator now points to guide sections instead of unrelated libraries: `YouNew/Views/MoreHubView.swift:264`.
- Side menu language, LGBTQ, integration, social service, and places routes now point to their logical homes: `YouNew/Views/RootTabView.swift:1194`.

## Primary Navigation Inventory

| Screen | Purpose | Content Type | Owner Category | Status |
|---|---|---|---|---|
| HomeView | Dashboard, next steps, city/current context, featured content | dashboard, cards, shortcuts | HOME | WARNING: too much content density for a dashboard |
| SearchView | Find guides, cities, topics, answers | search/tool | SEARCH, cross-section utility | PASS |
| NetherlandsMapHubView / NearbyMapView | Nearby services, places, provinces, city map context | map/tool | PROVINCES, CITIES, EMERGENCIES, SERVICES | WARNING: map focus is a reference, not a canonical content owner |
| FavoritesView | Saved items | utility | SAVED | PASS |
| AIAssistantView | Explain, navigate, translate, summarize | assistant/tool | AI ASSISTANT | PASS with trust guardrails |
| MoreHubView | Full navigation library and account/support access | hub/navigation | SETTINGS + all secondary sections | FIXED: reachable as More stack |
| RightSideMenuOverlay | Quick global navigation | navigation overlay | GLOBAL NAVIGATION | WARNING: duplicates More hub links |
| OnboardingQuestionnaireView | First launch status selection | onboarding | HOME / FIRST LAUNCH | PASS |
| SettingsView | Preferences, legal, privacy, reset paths | settings | SETTINGS | PASS |

## Core Knowledge Inventory

| Screen / Data Source | Purpose | Content Type | Owner Category | Status |
|---|---|---|---|---|
| GuideContent.sections | Structured long-form articles | guide/articles | LIFE IN NETHERLANDS | PASS structurally |
| GuideContent.documentsSection | BSN, DigiD, BRP | articles | DOCUMENTS | WARNING: articles need 2026 source review |
| GuideContent.housingSection | Renting, huurtoeslag, tenant rights | articles | HOUSING | WARNING: allowance thresholds are date-sensitive |
| GuideContent.transportSection | OV-chipkaart, cycling, trains | articles | TRANSPORT | PASS, source review needed |
| GuideContent.healthcareSection | Insurance, huisarts, urgent care | articles | HEALTHCARE | WARNING: date-sensitive insurance facts |
| GuideContent.finesSection | Cycling fines, parking, CJIB | articles | GOVERNMENT / MONEY | WARNING: fine amounts must be source-locked |
| GuideContent.workSection | Permits, payslip, jobs | articles | WORK + MONEY | WARNING: tax rates stale risk |
| GuideContent.integrationSection | Dutch language, Dutch culture | articles | LANGUAGE + CULTURE | PASS structurally |
| GuideContent.emergencySection | 112, police, crisis contacts | articles | EMERGENCIES | PASS, requires official contacts freshness |
| FirstStepsView / PracticalGuideView | Task-based guides | guided tasks | LIFE IN NETHERLANDS | PASS but overlaps GuideContent |
| InformationHubView | Entry point for practical knowledge | hub | LIFE IN NETHERLANDS | PASS |
| GovernmentHubView | Government services | hub | GOVERNMENT | PASS |
| HelpHubView | Problem-oriented support | hub | LIFE IN NETHERLANDS | FIXED routing contradictions |
| EmergencyHubView | Emergency actions and contacts | hub | EMERGENCIES | PASS |
| OfficialSourceDirectoryView | Official and trusted sources | directory | GOVERNMENT / TRUST | PASS |
| LanguageHubView | Dutch learning | hub | LANGUAGE | PASS |
| DutchA1A2View | Language course | course | LANGUAGE | PASS |
| KNMGuideView | Knowledge of Dutch society | course | EDUCATION / HISTORY | PASS |
| HistoryKNMHubView | History and KNM gateway | hub | HISTORY | PASS |
| NetherlandsHistoryView | History timeline | educational timeline | HISTORY | PASS after recent redesign |
| CultureAttractionsView | Culture and attractions | guide | CULTURE | WARNING: content flow should remain topic-led |

## Geography Inventory

| Screen / Data Source | Purpose | Content Type | Owner Category | Status |
|---|---|---|---|---|
| NetherlandsOverviewView | Country overview | guide | COUNTRY | PASS |
| ProvinceDirectoryView | Province list, province cards, province detail | directory/detail | PROVINCES | PASS structurally |
| CitiesDirectoryView | City directory | directory | CITIES | PASS structurally |
| NetherlandsCityDetailView | City identity and practical city facts | detail | CITIES | PASS structurally |
| NLCity / NLProvince / NetherlandsData | City/province model layer | data | CITIES / PROVINCES | WARNING: must stay canonical for city facts |
| RelatedContentEngine | City related guides | recommendation | CITIES | PASS |
| CanonicalPlaceImageResolver | Image ownership and fallback | media resolver | CITIES / PROVINCES | PASS as media infrastructure |

## Support, Safety, and Tools Inventory

| Screen / Data Source | Purpose | Content Type | Owner Category | Status |
|---|---|---|---|---|
| LGBTQSupportView | LGBTQ+ support resources | support directory | LIFE IN NETHERLANDS / SUPPORT | FIXED route added |
| EmotionalSupportView | Mental health and emotional support | support directory | HEALTHCARE / SUPPORT | PASS |
| SurvivalNavigatorView | Profile-based survival guide | journey | LIFE IN NETHERLANDS | FIXED guide card routing |
| DocumentOrganizerView | User document checklist/organizer | tool | DOCUMENTS | PASS |
| FinesInfoView | Fines and rules | guide/tool | GOVERNMENT / MONEY | PASS |
| LettersView | Official letter examples | reference | DOCUMENTS | PASS but should be referenced from Documents |
| DutchTermsView | Dutch terms dictionary | reference | LANGUAGE | PASS |
| InstitutionsView | Institution directory | directory | GOVERNMENT | PASS, no longer used as Work/Money fallback |
| ResourcesView | General resources | directory | SUPPORT | WARNING: reachable through More main list only |
| MistakesLibraryView | Common newcomer mistakes | reference | LIFE IN NETHERLANDS | PASS as reference, not category owner |
| PrivacyDataControlView | Privacy controls | settings/legal | SETTINGS | PASS |
| LegalDisclaimerView | Legal disclaimer | legal | SETTINGS | PASS |
| AboutYouNewView | Product information | about | SETTINGS | PASS |
| SupportFeedbackView | Feedback assistant entry | support/tool | SETTINGS / SUPPORT | PASS |

## Orphan and Suspect Content

These screens exist but do not have a clear primary AppDestination or appear only as direct/private links:

| View | Evidence | Status | Recommendation |
|---|---|---|---|
| LegalInfoView | Defined in `YouNew/Views/LegalInfoView.swift:3`, no current route found | ORPHAN | Either expose under GOVERNMENT > Legal help or remove if replaced by Official Sources |
| TranslatorView | Defined in `YouNew/Views/TranslatorView.swift:3`, no current route found | ORPHAN | Move under AI ASSISTANT or LANGUAGE, not both |
| SurvivalGuideView | Defined in `YouNew/Views/SurvivalGuideView.swift:3`, no current route found | ORPHAN | Merge into SurvivalNavigatorView or remove |
| MunicipalitySupportView | Defined in `YouNew/Views/MunicipalitySupportView.swift:3`, no current route found | ORPHAN | Move under GOVERNMENT > Municipality if still needed |
| RisksView | Defined in `YouNew/Views/RisksView.swift:3`, no current route found | ORPHAN | Merge into Scam warnings / Safety |
| MarketingPreviewView | Defined in `YouNew/Views/MarketingPreviewView.swift:3`, no current route found | DEV-ONLY RISK | Remove from release target if not intentionally hidden |
| MoreHub direct LegalHelpView | Private inside `MoreHubView`, not AppDestination-owned | WARNING | Promote to a proper AppDestination if it remains a first-class support path |

## Duplicate Detection and Canonical Owners

| Topic | Current Duplicate Locations | Canonical Home | References Elsewhere |
|---|---|---|---|
| Housing | Home, Help, More, FirstSteps, GuideContent, Survival, Search | HOUSING: GuideContent.housingSection + PracticalGuide housing task modules | Home/Help/More should deep-link to HOUSING |
| Healthcare | Home, Help, More, FirstSteps, GuideContent, Map focus, Emotional support | HEALTHCARE: GuideContent.healthcareSection + PracticalGuide health task modules | Map only for nearby services |
| Transport | Home, Help, More, TransportGuide, GuideContent, Map focus | TRANSPORT: GuideContent.transportSection / TransportGuide | Map only for routes/nearby |
| Work | Side menu, Help, More, GuideContent.workSection, Institutions | WORK: GuideContent.workSection | Institutions only as source directory |
| Money and Taxes | Help, Home banking, Work salary/taxes, institutions | MONEY: Banking basics + work/tax articles | Government and Work may reference it |
| Documents | Home, Journey documents, Letters, GuideContent.documentsSection, Checklist | DOCUMENTS: GuideContent.documentsSection + DocumentOrganizer tool | Letters/checklists should be sub-tools |
| Government Services | GovernmentHub, Institutions, Official Sources, map government focus | GOVERNMENT: GovernmentHub | Official Sources as trust directory |
| Municipality | City pages, Government, FirstSteps, map city services | GOVERNMENT / CITIES | City pages should link to Government municipality guide |
| Emergency | Home, Help, EmergencyHub, GuideContent.emergency, map focus | EMERGENCIES: EmergencyHub | Guide article as learn-more |
| Dutch History | Home, HistoryKNMHub, NetherlandsHistoryView, Culture | HISTORY: NetherlandsHistoryView | KNM can reference |
| Culture/Attractions | Home, places menu, CultureAttractions, city places | CULTURE: CultureAttractionsView | City pages keep city-specific places |
| LGBTQ+ | Help, More, place category, emotional support fallback | SUPPORT: LGBTQSupportView | Emotional support can reference, not own |
| AI Assistant | Tab, contextual button, feedback assistant | AI ASSISTANT | Must point to official content, not replace it |

## Release IA Risks

1. Home remains a content-heavy surface. It should be a dashboard with next actions, not a full library.
2. App has two global navigation models: MoreHub and RightSideMenuOverlay. This is acceptable for TestFlight but should be consolidated before public release.
3. Several topic areas have both guide articles and practical guides. This can work only if guide articles are canonical knowledge and practical guides are task modules.
4. Some fact-heavy articles are Russian-first while release language cleanup has been requested elsewhere. This is not an IA blocker but is a trust/readability risk.
5. Orphan views should be removed from the release target or assigned an owner before App Store submission.

## Inventory Verdict

The structure is now less chaotic after route fixes, but it does not yet meet the final pass criterion of "no duplicates and every function has one home." It is suitable for an internal IA review build, not a final App Store information architecture gate.
