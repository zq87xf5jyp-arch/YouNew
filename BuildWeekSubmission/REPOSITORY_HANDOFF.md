# Repository Handoff

Inventory cutoff: 21 July 2026, 10:14 CEST  
Scope: local Build Week candidate handoff; no remote, commit, push, release, or publication was performed

## Decision

The repository is usable as a local candidate workspace, but it is **not ready for a
blanket `git add -A` or public push**. The working tree contains the candidate fixes
and submission packet together with pre-existing documentation, website, content,
media, and generated evidence work. Those workstreams must be reviewed and staged
by exact path.

The safe default is:

1. keep build products and raw test bundles local;
2. stage the small reproducible source/documentation packet by exact path;
3. review content, website, screenshots, and media as separate optional batches;
4. run a redacted staged-secret and privacy review;
5. create a **private** GitHub repository only after separate owner confirmation.

## Verified Git snapshot

The following facts were rechecked read-only before this document was created:

| Item | Verified value |
|---|---|
| Repository root | local `YouNew` checkout |
| Branch | `build-week-readiness` |
| HEAD | `da8c3fe22e7a5d99b2187aab1141700b2d34f508` |
| HEAD subject | `fix: repair gallery UI test diagnostic` |
| Reachable commits | 65 |
| Configured remotes | none; `git remote -v` returned no entries |
| Tracked paths at HEAD | 1,093 |
| Unstaged tracked changes | 53 modified, 3 deleted |
| Staged changes | none |
| Untracked files | 197 actual files represented by 128 condensed `??` status entries |

Creating this document adds one more untracked file. Other agents may continue to
produce the requested final evidence, so the owner must regenerate the inventory
immediately before staging. The counts above are a timestamped snapshot, not a
claim about the eventual candidate commit.

The three unstaged deletions in the snapshot are:

- `IA_Audit_Screenshots/strict-reference-pass/02-refined-home.png`;
- `admin-dashboard/public-site/src/components/app-phone.tsx`;
- `admin-dashboard/public-site/src/components/section-heading.tsx`.

They are **not approved deletions** by this handoff. Do not stage them implicitly.

## Essential tracked repository content

These path groups already exist in HEAD and form the reproducible technical base.
Unchanged tracked files do not need to be added again:

| Path group | Why it is essential | Handoff rule |
|---|---|---|
| `YouNew.xcodeproj/` | Xcode project and target configuration | Keep. Review signing-team metadata before public visibility. |
| `YouNew/App/`, `YouNew/Core/`, `YouNew/Data/`, `YouNew/Models/`, `YouNew/Services/`, `YouNew/ViewModels/`, `YouNew/Views/` | Native SwiftUI application and supporting implementation | Keep. Stage only reviewed modifications. |
| `YouNew/*.lproj/`, `YouNew/PrivacyInfo.xcprivacy`, `YouNew/Assets.xcassets/` | Localizations, privacy manifest, and runtime assets | Keep, but do not infer media clearance from tracking status. |
| `YouNewTests/`, `YouNewUITests/` | Unit and UI verification | Keep. Never omit or weaken a test to make the candidate appear green. |
| `DataProject/batches/`, `DataProject/schema/`, `DataProject/releases/`, `DataProject/observability/`, `DataProject/operations/` | Governed content/import source and release metadata | Keep validated source records. Generated reports are a separate artifact class. |
| `scripts/` | Static QA, import, release, image, link, and content validation | Keep scripts used by the final report, with exact command/result provenance. |
| `BuildWeekAudit/`, reviewed `BuildWeekFix/` evidence | Historical and remediation evidence | Keep only truthful revisions; label historical numbers as historical. |
| `.github/workflows/data-project-health.yml`, `.env.example` | Reproducible automation and non-secret configuration example | Keep. `.env.example` must contain placeholders only. |
| `LICENSE`, `PRIVACY.md`, `SECURITY.md`, terms/attribution documents | Distribution and disclosure context | Keep after owner/legal/media review; tracking is not legal approval. |

### Modified tracked candidate files

The inventory found candidate-relevant changes in these groups:

- app fixes: `YouNew/App/AppTabView.swift`, `YouNew/Views/RootGuideView.swift`,
  `YouNew/Core/DesignSystem/Tokens/AppShadows.swift`, and
  `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift`;
- QA/import tooling: `scripts/check-external-links.py`,
  `scripts/data-dashboard-static-qa.py`, `scripts/generate-data-dashboard.py`,
  `scripts/import-data-project.py`, `scripts/run-static-qa.sh`, and
  `scripts/user-visible-completeness-static-qa.py`;
- governed data: `DataProject/README.md`,
  `DataProject/batches/WP-04/M1-transport-payment-002.json`, and
  `DataProject/schema/entity.schema.json`;
- judge-facing context: `README.md`, `PRIVACY.md`, `MEDIA_ATTRIBUTION.md`,
  `IMAGE_INVENTORY.md`, the Build Week evidence reports, and distribution-status
  documents.

Each diff must be reviewed against `FINAL_VALIDATION.md`. A file is essential to the
candidate commit only if the final build/test result used its current contents or a
submission claim directly cites it.

## Essential untracked candidate files

The following are intended candidate deliverables, subject to final content and
privacy review:

- the six required Markdown reports in `BuildWeekFinal/`;
- the Build Week submission documents and two machine-readable summaries in
  `BuildWeekSubmission/`;
- a sanitized, portable JSON summary of finalized test results;
- owner-reviewed final simulator screenshots named in
  `BuildWeekFinal/SCREENSHOT_MANIFEST.md`.

The raw `BuildWeekFinal/artifacts/UI_MAP_TAB_FAILURE_EVIDENCE/` directory is not part
of the default public packet. It currently includes an approximately 15 MB video,
opaque diagnostic attachments, hierarchy/event text, and a manifest. Preserve it
locally; publish only selected files after OCR, identifier, privacy, and media-rights
review. The ignored baseline `.log` files are also local diagnostics, not source.

### Conditional untracked workstreams

The snapshot contained 197 untracked files, led by:

| Group | File count | Default disposition |
|---|---:|---|
| `admin-dashboard/` | 120 | Hold as a separate website commit. Validate build, generated/public content, privacy, and media rights first. |
| `BuildWeekFinal/` | 14 | Stage reviewed Markdown and sanitized summaries; hold raw logs/video/opaque attachments. |
| `DataProject/` | 12 | Stage only reviewed governed source or editorial evidence that passes final import/content validation. |
| `BuildWeekSubmission/` | 8 before this file | Candidate documentation; stage after cross-link and claim verification. |
| `scripts/` | 4 | Stage only when the final QA report actually uses and verifies them. |
| `BuildWeekFix/` | 2 | Review as remediation evidence; do not let historical wording override final results. |
| root-level audit/CSV/JSON reports | 37 | Hold by default. Classify as source, generated output, historical evidence, or discard candidate before staging. |

The public-site work is deliberately separate. The current `.gitignore` change
would make `admin-dashboard/public-site/public/` visible, exposing 17 generated or
media files, including seven icons/images. Do not stage that ignore-rule change or
the public directory until the website workstream and every media file are approved.

## Exclude from the candidate commit

Keep these local or regenerate them; do not stage them:

- `DerivedData/`, `.DerivedData*`, `.derivedData*`;
- `*.xcresult`, `*.xcarchive`, `*.dSYM`, `*.dSYM.zip`, `*.ipa`;
- `TestArtifacts/`, `test.log`, `*.log`, `VISUAL_AUDIT_GALLERY.html`,
  `.visual-audit/`;
- `node_modules/`, `.pnpm-store/`, `.next/`, `out/`, `*.tsbuildinfo`;
- `.DS_Store`, `.AppleDouble`, `xcuserdata/`, `*.xcuserstate`;
- `.env`, `.env.*` except reviewed placeholder-only examples, `.dev.vars*`,
  `.wrangler/`, `.openai/`;
- `*.p12`, `*.pfx`, `*.pem`, `*.key`, `*.mobileprovision`,
  `*.provisionprofile`, `*.cer`, `*.crt`, `*.der`;
- raw media workspaces and archives: `netherlands_app_images/` and
  `netherlands_app_images_v*.zip`;
- generated `DataProject/reports/` and staging caches, except an explicitly
  governed source file that the final import validation requires;
- generated link outputs such as `knowledge_data_health.json` and
  `broken_links.csv`;
- accidental duplicate exports matching `* 2.md`;
- raw screenshots, recordings, result attachments, or audit captures until owner
  privacy/media approval.

## Local temporary inventory

Read-only disk inspection found:

- `TestArtifacts/`: approximately 360 MB, including six ignored `.xcresult`
  bundles;
- `admin-dashboard/node_modules/`: approximately 471 MB;
- `admin-dashboard/public-site/node_modules/`: approximately 444 MB;
- `admin-dashboard/public-site/.next/`: approximately 158 MB;
- `BuildWeekFinal/`: approximately 18 MB, mostly the 15 MB map-failure recording.

No in-repository `DerivedData` directory was found in this snapshot. Final Xcode
result bundles stored under a local temporary directory remain external artifacts.
Record their portable filename, SHA-256, size, test environment, and local retention
path in `FINAL_VALIDATION.md`; do not commit a full result bundle to ordinary Git.

This pass did not delete any temporary file. If the owner later wants to reclaim
space, remove only exact reviewed cache/artifact paths after copying required
evidence. Never use `git clean -fdx`, a broad recursive delete, or a reset as a
cleanup shortcut.

## Sensitive-data and publication gates

### Secrets

The current filename inventory found only the tracked `.env.example` in the
environment/key/certificate name class and no untracked key, certificate, or
provisioning-profile filename. This was a filename check, not a fresh full secret
scan. `BuildWeekFix/SECRET_SCAN.md` records an earlier bounded scan and explicitly
requires a new exact staged scan.

Before commit and again before push:

- run a redacted secret scanner against the staged tree and reachable history;
- inspect configuration examples for real endpoints, IDs, tokens, and copied
  credentials;
- verify that no provider key is embedded in iOS source;
- rotate any value if its secrecy is uncertain; deletion from the latest tree does
  not remove it from Git history.

### Local paths and machine identifiers

`BuildWeekFinal/UI_BASELINE.md` and
`BuildWeekFinal/artifacts/UI_PRIOR_FINALIZED_SUMMARY.json` contain local `/Users/...`
or `/private/tmp/...` evidence paths. Raw test logs, `.xcresult` attachments, and
recordings may contain simulator/device identifiers, account names, host paths, or
timestamps. Keep exact paths in private evidence if reproducibility needs them, but
use portable artifact names or `<LOCAL_ARTIFACT_PATH>` in a public packet.

Reachable history also contains historical local-path matches. A clean latest tree
does not sanitize history. Keep the new repository private unless the owner approves
a separate history-review or sanitized-snapshot strategy.

### Personal data

Review, without printing values:

- Git author names/emails and GitHub account metadata;
- Xcode `DEVELOPMENT_TEAM` identifiers;
- screenshots, videos, OCR text, EXIF, simulator/device names, and result-bundle
  diagnostics;
- public contact details and sample records in content fixtures;
- feedback, document-organizer, profile, and saved-item fixtures for real user data.

No blanket PII-clear claim is supported by this inventory.

### Certificates and signing

Certificate/profile extensions are ignored, and none appeared in the tracked or
untracked filename inventory. The Xcode project can still contain non-secret signing
team metadata. Do not commit exported signing identities, provisioning profiles,
private keys, keychain exports, or notarization credentials.

### Legal and medical material

The app and DataProject contain legal, privacy, emergency, healthcare, insurance,
and public-service information. Before public handoff:

- validate dates and exact official sources for the demo path;
- preserve informational/not-professional-advice wording;
- review licensed or third-party text for redistribution rights;
- ensure fixtures contain no patient, client, case, or document data;
- do not interpret passing schema/import tests as legal or medical approval.

### Media rights

Media clearance is partial. The current engineering inventory records 72
manifest-backed `nl_*` assets, 65 marked attribution-required, one manifest entry
with a missing license URL, and 98 asset-catalog imagesets outside that reviewed
manifest. The repository already tracks 39 raster audit/runtime captures outside
the asset catalog; ignore rules cannot prevent tracked files from reaching a remote.

Required owner action:

1. reconcile every source, creator, license, attribution, modification, and
   share-alike requirement;
2. review screenshots/video for third-party media and personal/device information;
3. replace or exclude any disputed asset;
4. approve the final demo-video and repository media lists separately.

`MEDIA_ATTRIBUTION.md` and `BuildWeekFix/MEDIA_RIGHTS.md` are inventories, not legal
clearance or legal advice.

## Safe cleanup and handoff plan

1. **Freeze the candidate.** Record branch, HEAD, `git status --short`, Xcode/
   simulator versions, and hashes of final external artifacts.
2. **Resolve concurrent work.** Wait for final validation and documentation to
   finish. Re-run the file inventory; do not rely on the snapshot counts above.
3. **Review each tracked diff.** Classify it as candidate source, evidence,
   independent website/content work, generated output, or owner deletion. Preserve
   all unrelated owner work.
4. **Sanitize the public packet.** Replace machine-local paths in public summaries,
   inspect JSON/Markdown for identifiers, and OCR/EXIF-review every selected image
   or recording.
5. **Keep binaries external.** Retain `.xcresult`, raw logs, and recordings in an
   owner-controlled evidence archive. Commit small redacted summaries and checksums.
6. **Stage by exact path.** Use the candidate batches below. Never use `git add -A`,
   `git add .`, or `git add -u` in this mixed working tree.
7. **Audit the index.** Verify staged names, deletions, size, whitespace, secrets,
   absolute paths, JSON syntax, broken references, and media list.
8. **Commit locally only after owner approval.** Tag the validation report with the
   resulting commit hash; rerun any check whose evidence depended on the pre-commit
   tree identity.
9. **Prove reproducibility.** Build and run the final targeted checks from a clean
   clone/worktree of the exact candidate commit before claiming clean-clone support.
10. **Create remote and push separately.** Default to private. Public visibility is
    blocked until history, rights, privacy, and distribution reviews close.

## Owner-confirmation commands — do not run automatically

These commands are a handoff template. They were **not executed**. Run them only
after all referenced final files exist and the owner has approved every path.

Placeholders use the literal prefix `REPLACE_WITH_`; replace them before running any
GitHub command.

### 1. Reconfirm the local boundary

```sh
git branch --show-current
git rev-parse HEAD
git rev-list --count HEAD
git remote -v
git status --short
git diff --check
```

Expected before owner-approved staging: branch `build-week-readiness`; no remote.
Stop if HEAD or the worktree differs from the final validation record.

### 2. Stage the reviewed app fixes

Run only if `FINAL_VALIDATION.md` identifies all four current diffs as part of the
validated candidate:

```sh
git add -- \
  YouNew/App/AppTabView.swift \
  YouNew/Views/RootGuideView.swift \
  YouNew/Core/DesignSystem/Tokens/AppShadows.swift \
  YouNew/Data/CuratedPlaceHeroMediaRegistry.swift
```

If a final fix touches another source or test file, add that **exact reviewed path**
in a separate owner-approved command; do not broaden this command to a directory.

### 3. Stage the judge packet by exact path

Do not add raw artifact directories or screenshots with this batch:

```sh
git add -- \
  README.md \
  BuildWeekFinal/UI_BASELINE.md \
  BuildWeekFinal/MAP_TAB_BLOCKER_FIX.md \
  BuildWeekFinal/REMAINING_FAILURES.md \
  BuildWeekFinal/DEMO_FLOW.md \
  BuildWeekFinal/SCREENSHOT_MANIFEST.md \
  BuildWeekFinal/PUBLIC_CLAIMS.md \
  BuildWeekSubmission/TECHNICAL_OVERVIEW.md \
  BuildWeekSubmission/HOW_CODEX_WAS_USED.md \
  BuildWeekSubmission/AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md \
  BuildWeekSubmission/TESTING_AND_QA.md \
  BuildWeekSubmission/CONTENT_PLATFORM.md \
  BuildWeekSubmission/DEMO_GUIDE.md \
  BuildWeekSubmission/KNOWN_LIMITATIONS.md \
  BuildWeekSubmission/JUDGE_SETUP.md \
  BuildWeekSubmission/README_BUILD_WEEK.md \
  BuildWeekSubmission/SUBMISSION_FACTS.json \
  BuildWeekSubmission/REPOSITORY_HANDOFF.md \
  BuildWeekSubmission/FINAL_VALIDATION.md \
  BuildWeekSubmission/FINAL_STATUS.json
```

Stage a sanitized result summary only after replacing private local paths:

```sh
git add -- BuildWeekFinal/artifacts/UI_PRIOR_FINALIZED_SUMMARY.json
```

### 4. Stage supporting evidence and QA only if final validation cites it

```sh
git add -- \
  APPSTORE_CERTIFICATION.md \
  TESTFLIGHT_CERTIFICATION.md \
  DEVICE_RUNTIME_REPORT.md \
  PRIVACY.md \
  MEDIA_ATTRIBUTION.md \
  IMAGE_INVENTORY.md \
  CITY_IMAGE_MAPPING.md \
  BuildWeekFix/DEMO_FLOW_EVIDENCE.md \
  BuildWeekFix/EVIDENCE_CITIES_RELEASE.md \
  BuildWeekFix/EVIDENCE_CONTENT_PLATFORM.md \
  BuildWeekFix/EVIDENCE_INTERACTIVE_MAP.md \
  BuildWeekFix/EVIDENCE_PREMIUM_IMAGE_PIPELINE.md \
  BuildWeekFix/EVIDENCE_QA_AUTOMATION.md \
  BuildWeekFix/FINAL_PUBLIC_FACTS.json \
  BuildWeekFix/FINAL_READINESS.md \
  BuildWeekFix/GITHUB_HANDOFF.md \
  BuildWeekFix/GPT56_INTEGRATION_EVIDENCE.md \
  BuildWeekFix/MEDIA_RIGHTS.md \
  BuildWeekFix/OWNER_MANUAL_ACTIONS.md \
  BuildWeekFix/SECRET_SCAN.md \
  BuildWeekFix/TEST_REMEDIATION.md \
  scripts/check-external-links.py \
  scripts/data-dashboard-static-qa.py \
  scripts/generate-data-dashboard.py \
  scripts/import-data-project.py \
  scripts/run-static-qa.sh \
  scripts/user-visible-completeness-static-qa.py \
  DataProject/README.md \
  DataProject/batches/WP-04/M1-transport-payment-002.json \
  DataProject/schema/entity.schema.json
```

Do not stage `.gitignore`, the website workstream, DataProject research/staging,
root-level audit exports, or the three deletions in this command. They require
separate owner decisions.

### 5. Optional reviewed screenshot paths

Replace every placeholder with one exact file from `SCREENSHOT_MANIFEST.md` after
OCR, EXIF, privacy, and media-rights approval. Do not pass a directory or wildcard.

```sh
git add -- \
  REPLACE_WITH_APPROVED_SCREENSHOT_PATH_1 \
  REPLACE_WITH_APPROVED_SCREENSHOT_PATH_2 \
  REPLACE_WITH_APPROVED_SCREENSHOT_PATH_3
```

### 6. Audit the staged boundary

```sh
git diff --cached --name-status
git diff --cached --stat
git diff --cached --check
git diff --cached --name-only | rg '(^|/)(DerivedData|TestArtifacts|node_modules|\.next)(/|$)|\.xcresult$|\.xcarchive$|\.ipa$|\.dSYM(\.zip)?$|(^|/)\.env($|\.)|\.(p12|pfx|pem|key|mobileprovision|provisionprofile|cer|crt|der)$'
git grep --cached -l -E '/Users/|/private/tmp/' --
```

The last two commands must print no path. A hit is a stop condition: unstage and
review that exact file. Also verify that `git diff --cached --name-status` contains
no unapproved deletion.

If `gitleaks` is available, run the redacted staged/history scan without printing
candidate values:

```sh
gitleaks git --staged --redact
gitleaks git --redact
```

Review the staged JSON separately with the repository's existing validators. A
zero-result pattern scan is not a security or privacy certification.

### 7. Owner-approved local commit

```sh
git commit -m "Prepare YouNew Build Week candidate"
```

After the commit, record `git rev-parse HEAD` in the final evidence and reproduce
the required build/tests from that exact commit. Do not amend or rewrite history
without another owner decision.

### 8. Owner-approved GitHub repository creation

Private is the safe default while media/history/privacy gates remain open:

```sh
BUILDWEEK_GH_OWNER='REPLACE_WITH_GITHUB_OWNER_OR_ORG'
BUILDWEEK_REPO='REPLACE_WITH_REPOSITORY_NAME'
gh repo create "$BUILDWEEK_GH_OWNER/$BUILDWEEK_REPO" --private --description "YouNew Build Week candidate"
```

Do not change `--private` to `--public` until the owner signs off the media,
personal-data, legal/content, secret-history, and screenshot/video reviews.

### 9. Owner-approved remote add

```sh
git remote add origin "git@github.com:$BUILDWEEK_GH_OWNER/$BUILDWEEK_REPO.git"
git remote -v
```

If `origin` exists at that time, stop and inspect it; do not overwrite it with
`git remote set-url` automatically.

### 10. Owner-approved push

```sh
git push --set-upstream origin build-week-readiness
```

No force push, tag push, release creation, deployment, App Store upload, or Devpost
submission is authorized by this handoff.

## Final owner checklist

- [ ] Exact staged paths match the final validated candidate.
- [ ] No `.xcresult`, DerivedData, logs, caches, credentials, signing material, or
      raw media workspace is staged.
- [ ] Every staged deletion is intentional.
- [ ] Public documents contain portable evidence references or owner-approved local
      detail only.
- [ ] Screenshots/video passed OCR, EXIF, PII, device-identifier, and media-rights
      review.
- [ ] Legal/medical/public-service content has current sources and clear disclaimer
      boundaries.
- [ ] The staged secret scan and broken-reference validation are recorded.
- [ ] Final test numbers come only from finalized current artifacts.
- [ ] A clean clone/worktree of the exact local commit reproduces the supported
      build and demo flow.
- [ ] Repository visibility, remote creation, commit, and push each received
      explicit owner confirmation.
