# Repository and Security Audit

Audit window: 2026-07-19–2026-07-20 (Europe/Amsterdam); finalized 2026-07-20
Verdict: **NOT SAFE / NOT REPRODUCIBLE FOR JUDGES YET**

The performed scan did not find a real API key, token, password, private-key block, certificate, or provisioning profile. The blocking risks are instead repository identity/portability, untracked source and data, large device diagnostics, missing licensing, incomplete image-rights evidence, tracked local paths, and an insufficient judge README.

## Git and GitHub facts

| Fact | Status | Evidence |
|---|---|---|
| Local Git repository | VERIFIED | `.git/` exists and Git commands succeed. |
| Branch | VERIFIED | `fix/ui-regression`. |
| Remote | NOT IMPLEMENTED/configured | `git remote -v` is empty; `.git/config:1-7` contains only `[core]`. |
| GitHub repository | NOT VERIFIED | No GitHub/other remote URL exists locally. |
| Public/private | UNKNOWN | Cannot be inferred without a remote/hosting record. |
| Reachable commits | VERIFIED | 56. |
| First available commit | VERIFIED | 2026-05-21T14:06:29+02:00. |
| Latest available commit | VERIFIED | 2026-07-12T00:11:14+02:00. |
| Working tree | DIRTY | Pre-report baseline: 119 modified, 2 deleted, 323 untracked file paths (444 porcelain paths with `-uall`). Creating this audit adds the requested report paths. |

## Clean-clone verdict

**NOT VERIFIED; the current audited product cannot be reconstructed from `HEAD`.**

Essential current files are untracked, including:

- `YouNew/Services/HomePlaceSyncService.swift`
- `YouNew/Services/HomeBusinessSyncService.swift`
- `YouNew/Services/HomeWeatherService.swift`
- `YouNew/Services/VisitLeidenCalendarService.swift`
- `YouNew/Services/DataProjectRuntimeLoader.swift`
- `YouNew/Data/LicensedPartnerMediaRegistry.swift`
- `YouNew/Data/PremiumKnowledgeSeedData.swift`
- `YouNew/Data/VerifiedLeidenVenueData.swift`
- `YouNew/Resources/Data/younew-runtime-data.json`
- `DataProject/`
- `.github/workflows/data-project-health.yml`

Modified tracked code references these untracked types:

- `YouNew/Views/RootHomeView.swift:15` → `HomeWeatherModel`.
- `YouNew/Data/MockLocalPartnersData.swift:240,261,281,321,436,684` → `LicensedPartnerMediaRegistry`.
- `YouNew/Data/NetherlandsData.swift:1593-1594` → `PremiumKnowledgeSeedData` and `VerifiedLeidenVenueData`.
- `YouNew/Data/NetherlandsData.swift:1605` → `DataProjectRuntimeLoader`.

The app target uses a filesystem-synchronized group (`YouNew.xcodeproj/project.pbxproj:38-53,119-125`), so file presence directly affects compilation. A clean `HEAD` snapshot can at best reproduce the older committed product, not the current audited state.

## README, license, CI/CD

| Item | Status | Evidence/impact |
|---|---|---|
| README | PARTIAL | Tracked `README.md:32-37` has minimal Xcode setup; `:59-72` honestly calls content mock/static and assistant mock/local. It lacks tested Xcode/runtime, current identity/version, architecture, package resolution, backend modes, full commands, judge scenario, licensing, and clean-clone proof. |
| LICENSE/COPYING/NOTICE | NOT IMPLEMENTED | No repository license or third-party notice was found. Judges cannot infer redistribution rights. |
| `.gitignore` | PARTIAL | `.gitignore:1-41` ignores common build/cache/admin/image staging but not `TestArtifacts/`, `*.xcresult`, `.env*`, archives, certificates, or profiles. Broad `*_AUDIT.md`/`*_REPORT.md` rules also hide two requested output files. It is itself modified. |
| CI | PARTIAL/uncommitted | `.github/workflows/data-project-health.yml` exists locally but is untracked; it validates DataProject only. |
| iOS CI/CD | NOT IMPLEMENTED | No committed iOS build/test/archive/upload workflow, Fastlane, Codemagic, Bitrise, Jenkins, or export configuration. |

## Dependency and environment requirements

### iOS

- Xcode project: `YouNew.xcodeproj`.
- App minimum iOS: 17.6 (`YouNew.xcodeproj/project.pbxproj:442,494`).
- Current test targets require iOS 26.5 (`YouNew.xcodeproj/project.pbxproj:524,551,577,603`).
- SwiftPM resolution requires GitHub access or an existing cache.
- Resolved packages: swift-algorithms 1.2.1, swift-async-algorithms 1.1.5, swift-collections 1.6.0, swift-numerics 1.1.1 (`YouNew.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved:3-39`). Only Algorithms is linked directly (`YouNew.xcodeproj/project.pbxproj:123-125,689-694`).

Default local/mock demonstration needs no secret. Optional/live modes require configuration that is not in a judge setup:

- `YOUNEW_AI_PROXY_URL` plus deployed proxy.
- Server-side `OPENAI_API_KEY`; optional `OPENAI_MODEL` and rate-limit KV binding.
- `YOUNEW_API_BASE_URL` for optional place/business summaries.
- Admin/Supabase: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `NEXT_PUBLIC_APP_URL`.

Variable names are included; values are intentionally not shown.

### Judge data package boundary

For the **current local demo**, the bundled/sample data are required, not an optional fixture. The app compiles its `YouNew/Data/Mock*Data.swift` sources into the target and the assistant/index/search path reads those local records through `KnowledgeIndex`, `AppSearchEngine`, and related repositories. The current product also references untracked `PremiumKnowledgeSeedData`, `VerifiedLeidenVenueData`, `LicensedPartnerMediaRegistry`, `DataProjectRuntimeLoader`, and `YouNew/Resources/Data/younew-runtime-data.json` as listed in the clean-clone section. A judge package that omits any source/resource referenced by the filesystem-synchronized app target may fail to compile or demonstrate a materially older/incomplete product.

Therefore:

- **required for the current no-backend judge build/demo:** the complete intended `YouNew/` source/resource tree, including the local/mock datasets and the intended canonical runtime JSON;
- **required only to reproduce content governance/release evidence:** the intended `DataProject/` manifests, batches and validators;
- **optional for the current local assistant demo:** `YOUNEW_AI_PROXY_URL`, `YOUNEW_API_BASE_URL`, Worker deployment and admin/Supabase components;
- **not safe to substitute silently:** an older committed `HEAD` dataset, because it does not reproduce the audited current product.

No separate sanitized sample-data package or judge seed command currently exists. Creating and documenting one is required only if the owner does not want to redistribute the full intended local content dataset.

### Backend/admin status

- Worker is an example, not a verified deployment: `BackendExamples/cloudflare-worker-ai-proxy.js:1-5`.
- No Worker/Vercel/Docker deployment config or endpoint record was found.
- `admin-dashboard/package.json` declares private Next.js/React/Supabase dependencies, but most of `admin-dashboard/` is ignored/untracked.
- `admin-dashboard/README.md:113-122` retains backend/iOS integration TODOs.

Future-deployment security risk, **not a current production-vulnerability claim:** the Worker example has no app/user authentication or attestation, allows CORS `*` (`BackendExamples/cloudflare-worker-ai-proxy.js:12-16`), trusts a client-supplied system prompt (`:57-59,78-84`), and rate-limits only when the optional KV binding is configured (`:28-48`). It must not be deployed unchanged as proof of a secure backend.

A separate judge setup is mandatory until README and Git state are fixed.

## Secret scan

### Method

1. Current filename scan for `.env*`, private keys, certificates, provisioning profiles, and common credential files.
2. Current text scan with ignore rules disabled, while explicitly excluding `.git`, dependency/build caches, large test/device bundles, bulk image staging and this generated audit, for OpenAI/GitHub/AWS/Google/Slack token signatures, JWT-like strings, private-key headers, and secret identifiers.
3. Reachable Git history scan over every commit using `git rev-list --all` plus binary-safe `git grep -I -l` strong token/private-key patterns.
4. History filename scan and separate location-only scans for emails, phones, and absolute paths.
5. Candidate results were reviewed without printing values.

### Results

| Finding | Status | Required action |
|---|---|---|
| Real API keys/tokens/passwords/private keys | NOT FOUND by performed patterns | Rerun a dedicated scanner on final commit/history before publication. |
| `OPENAI_API_KEY` | SAFE IDENTIFIER ONLY | Appears in Worker example at `BackendExamples/cloudflare-worker-ai-proxy.js:2,89`; no value. |
| `.env` | NOT FOUND | Only ignored `admin-dashboard/.env.example` with placeholder variable names. |
| False `sk-...` match | REVIEWED FALSE POSITIVE | Route slug in `YouNew/Data/MockScamWarningsData.swift:339`, not a credential. |
| Certificates/profiles | NOT FOUND in repo | Local Xcode provisioning warnings are machine state, not repository files. |

Limitations: no `gitleaks`, `trufflehog`, or `detect-secrets` binary was installed; this was a targeted pattern/history scan, not an entropy scanner. Compressed/binary `.xcresult` contents, screenshot OCR, and EXIF metadata were not exhaustively scanned. `exiftool` was unavailable.

## PII and internal information

| Finding | Status | Evidence/action |
|---|---|---|
| Absolute machine-local paths | VERIFIED tracked | `CITY_IMAGE_AUDIT_REPORT.md:11-14`, `DEVICE_RUNTIME_REPORT.md:18,54`, `QA/BrandRuntimeQA.md:13`, `REAL_DEVICE_QA_REPORT.md:17`. Replace with portable placeholders. |
| Git author identities/emails | VERIFIED metadata | Review history privacy before public release; values are not reproduced here. |
| Project-domain contact emails | VERIFIED intentional strings | Present in `YouNew/Core/AppPublicLinks.swift`, `PRIVACY_POLICY.md`, `TERMS_OF_USE.md`, `APP_STORE_PACKAGE.md`, `YouNew/NetworkConfig.swift`, and `scripts/amsterdam-data-production.py`. Values are intentionally omitted; verify mailbox ownership and that each address is intended to be public. |
| Public business contacts | VERIFIED | `YouNew/Data/MockLocalPartnersData.swift:4-24` and records contain business names, addresses, coordinates, phone/email. Confirm accuracy and redistribution basis. |
| Personal-looking admin demo identities | PARTIAL/synthetic status not proven | Ignored/untracked fixtures at `admin-dashboard/src/app/(admin)/feedback/page.tsx:5-7`, `admin-dashboard/src/lib/auth.ts:20-22`, login/seed fixtures, and `YouNew/Views/BusinessPortalViews.swift:227,273` contain names/email/phone-shaped demo strings or inputs. Values are intentionally omitted; confirm they are synthetic or remove them from judge scope. |
| Internal/development URLs | VERIFIED development-only examples | Localhost URLs appear in `admin-dashboard/.env.example:4`, `admin-dashboard/README.md:54,64`, and `admin-dashboard/docs/mobile-sync-ios.md`. No concrete private production backend URL was found; document or remove dev-only examples before publication. |
| User medical/legal documents | NOT FOUND | Product legal/medical content is not evidence of personal records. |
| Runtime document organizer | VERIFIED local-only implementation | Protected copying/storage at `YouNew/ViewModels/DocumentStore.swift:95-109,128-139,161-178`; no user document files found in repo. |

## Large files and artifacts

- Tracked worktree: approximately 142.4 MiB across 924 files.
- Local `.git`: approximately 2.0 GiB; pack approximately 1.88 GiB.
- No `.gitattributes` or Git LFS configuration.
- Largest reachable historical blob is approximately 4.3 MiB; no committed single blob above GitHub's 100 MiB limit was detected.
- `TestArtifacts/` is untracked, not ignored, and approximately 357–361 MiB. It contains a roughly 212–222 MiB result payload and a roughly 142–149 MiB device/UI-session log plus diagnostics.
- Untracked `DataProject/staging/amsterdam-01-cache.json` is approximately 16 MiB. It is below GitHub's single-file limit but contains generated source/media staging metadata and should be regenerated, minimized or excluded deliberately rather than published by accident.
- Ignored local `admin-dashboard/` is approximately 825 MiB (dependencies/build output included).
- Ignored local `netherlands_app_images/` is approximately 554 MiB.

Do not publish `TestArtifacts/` until device/runtime identifiers, screenshots, logs, attachments, and possible secrets have been reviewed. The historical result bundles examined in this audit include device metadata; those values are intentionally omitted from public facts.

## Image and content licensing

Status: **PARTIAL; safe redistribution is not proven.**

- 177 raster/vector files are under `YouNew/Assets.xcassets`.
- `ASSET_CREDITS.md:16` says third-party city hero photos are not credited there.
- `IMAGE_LICENSE_REPORT.md:13-15,36-39,102-110,143-168` records incomplete license metadata and a non-final verdict.
- Some remote hero calls omit source/license fields: `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:70-102`; helper defaults are nil at `:505-511`.
- Role visuals can use a generic license label and nil source: `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:515-535`.
- An ignored local metadata manifest exists under `netherlands_app_images/metadata/`; it would not be in a clean clone.

No specific image is declared infringing by this audit. The supported conclusion is that complete redistribution rights are **NOT VERIFIED**.

## Judge-sharing decision

Positive evidence:

- no true secret was found by current/history pattern scans;
- privacy manifest exists and lints;
- app bundle ID/version are non-placeholder;
- README states important mock/local limitations.

Blocking conditions:

1. No remote; GitHub/public/private status unknown.
2. Current product depends on essential untracked files.
3. No clean-clone proof for the current product.
4. No license/third-party notice.
5. Image rights/credits incomplete.
6. Tracked local paths and Git identity metadata need review.
7. Large, unignored device/result artifacts risk accidental publication.
8. README lacks judge setup.
9. CI is untracked and does not build/test iOS.
10. Current unit/static/UI gates are red; the closed UI run is 80/86 with six failures.
11. `git check-ignore -v BuildWeekAudit/*` shows that `.gitignore:40` hides `BuildWeekAudit/TECHNICAL_AUDIT.md` and `BuildWeekAudit/REPOSITORY_SECURITY_AUDIT.md`; they will not be portable unless the final repository explicitly includes them.

**Decision: do not expose this working tree to judges yet.**
