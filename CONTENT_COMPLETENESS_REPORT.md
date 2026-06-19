# Content Completeness Report

Date: 2026-06-11

Scope: Home, Cities, Provinces, Housing, Work, Integration, Healthcare, Transport, Government Services, Emergency, AI Assistant, Dutch History, Monarchy, Parliament, LGBTQ+, Education, Taxes, Documents.

## Fixes Applied

| Issue | Root Cause | Fix | Verification |
| --- | --- | --- | --- |
| Onboarding cards could reference missing `landmark_*` assets | `landmarkAsset(for:)` returned asset names not present in `Assets.xcassets` | Replaced with existing bundled category assets in `YouNew/Views/OnboardingQuestionnaireView.swift:534` | Extended asset scan passed |
| AI prompt cards could reference missing `landmark_*` assets | `promptLandmark(for:)` returned non-existent landmark assets | Replaced with existing bundled category assets in `YouNew/Views/AIAssistantView.swift:815` | Extended asset scan passed |
| Documents hero referenced a missing category asset | `category_documents_hero` was not bundled | Switched to `premium_home_documents` in `YouNew/Views/DocumentOrganizerView.swift:101` | Extended asset scan passed |
| More hub documents hero referenced a missing category asset | `category_documents_hero` was not bundled | Switched to existing bundled hero in `YouNew/Views/MoreHubView.swift` | Extended asset scan passed |
| Fines and LGBTQ hero screens referenced missing category assets | Missing `category_fines_hero` and `category_lgbtq_hero` | Removed bad explicit asset names so generated/category fallback is used intentionally | Extended asset scan passed |

## Section Scores

| Section | Score | Result |
| --- | ---: | --- |
| Home | 9/10 | Complete static content surface; runtime text fit not measured |
| Cities | 9/10 | Priority city data and media QA pass |
| Provinces | 9/10 | Province directory data, city cards, and media QA pass |
| Housing | 8/10 | Reachable from Help & Life; practical guide present |
| Work | 8/10 | Reachable via institutions/work paths; should be device-tested |
| Integration | 9/10 | KNM and first-step paths present; KNM QA pass |
| Healthcare | 8/10 | Reachable via Help & Life and resources; device QA still needed |
| Transport | 9/10 | Transport guide and media present; course references pass |
| Government Services | 9/10 | Official institutions and source links present |
| Emergency | 9/10 | 112, police, huisarts, GGD content present with official sources |
| AI Assistant | 8/10 | Visible assistant has safety/source guidance; prompt imagery fixed |
| Dutch History | 9/10 | History media QA pass |
| Monarchy | 8/10 | Covered in history/KNM surface |
| Parliament | 8/10 | Covered in government/history surfaces |
| LGBTQ+ | 8/10 | Support view present; bad missing hero asset fixed |
| Education | 9/10 | DUO, Dutch A1/A2, KNM, student content present |
| Taxes | 8/10 | Belastingdienst paths present |
| Documents | 9/10 | Document actions made reachable; camera privacy key added |

## Static QA Results

Passed:
- `content-static-qa.py`
- `user-visible-completeness-static-qa.py`
- `static-qa.py`
- `knm-static-qa.py`
- `dutch-course-static-qa.py`

## Remaining Risk

Runtime text fit, scroll feel, and tap behavior still require device verification. The local Xcode environment cannot complete build/runtime because CoreSimulator/asset catalog compilation reports no available simulator runtimes.
