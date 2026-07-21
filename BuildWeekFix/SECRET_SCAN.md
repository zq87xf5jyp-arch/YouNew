# Secret and sensitive-data scan

Date: 2026-07-21 (Europe/Amsterdam)

Branch: `build-week-readiness`

Baseline commit: `b15a2f2913911763c989f9880f8ce376f903fc6e`

Verdict: **no high-confidence secret confirmed; public publication remains blocked**

No secret value is reproduced in this report. Results record counts and paths only.

## Scope and method

The current-tree scan covered repository text, including owner-modified and
untracked paths, while excluding `.git`, dependency caches, generated web output,
`TestArtifacts`, raw image workspaces, and build products. Targeted signatures
included private-key headers, OpenAI-style keys, GitHub tokens, AWS access-key IDs,
Slack tokens, direct iOS OpenAI endpoints, and bearer-token patterns. Reachable Git
history and sensitive filenames were checked separately. Candidate values were
never printed.

These are bounded pattern scans, not a security certification. No command printed a
candidate credential value.

## Results

| Check | Result | Review |
|---|---:|---|
| High-confidence current-tree secrets | 0 paths | No confirmed credential or private-key block. |
| Private-key signature files, current tree | 0 | PASS in scanned scope. |
| Private-key signature paths, reachable Git history | 0 | PASS in targeted history scope. |
| OpenAI-style signature candidates | 1 path | `YouNew/Data/MockScamWarningsData.swift`; reviewed as ordinary mock warning text, not a credential. |
| GitHub token candidates | 0 | PASS in scanned scope. |
| AWS access-key ID candidates | 0 | PASS in scanned scope. |
| Slack token candidates | 0 | PASS in scanned scope. |
| Certificate/key/profile filenames | 0 | No `.p12`, `.pfx`, `.pem`, `.key`, `.mobileprovision`, `.provisionprofile`, `.cer`, `.crt`, or `.der` file found outside excluded dependency paths. |
| Checked-in OpenAI key in iOS source | 0 confirmed | The client is designed to use a backend endpoint, not a provider credential. |
| Direct `api.openai.com` / bearer implementation in iOS source | 0 paths | Provider access remains backend-only. |

An earlier 308-path source-snapshot staged check found no private-key header, GitHub
token, AWS access-key ID, Slack token, certificate, provisioning profile, build
product, dependency cache, hosting metadata, or machine-local absolute path. It is
historical evidence only. A fresh exact-path scan is required after the final
documentation paths are staged; its result is recorded in the final section below.

## Metadata and privacy review

- Git history contains two distinct author-name values and two distinct author-email
  values. Values are intentionally omitted; the owner must decide whether that
  metadata is acceptable for a public remote.
- `YouNew.xcodeproj/project.pbxproj` contains eight `DEVELOPMENT_TEAM` key
  occurrences. The team value is not a secret, but it can identify an organization
  and requires owner review before publication.
- The three current-tree absolute temporary paths previously found in
  `APPSTORE_CERTIFICATION.md`, `DEVICE_RUNTIME_REPORT.md`, and
  `TESTFLIGHT_CERTIFICATION.md` were replaced by `<TEMP_DIR>`. A follow-up current
  public-document scan found no absolute local path in the intended public
  documentation scope. Reachable history still contains local-path matches in eight
  paths, including historical versions of those files; history was not rewritten
  automatically. Keep the repository private or use an owner-approved sanitized
  snapshot/history plan before public visibility.
- `TestArtifacts/` is excluded because result bundles, logs, screenshots, and device
  diagnostics can contain identifiers or user data even when source scans are clean.
- A local public-site hosting metadata directory was found and is excluded as
  `admin-dashboard/public-site/.openai/`. Its project identifier is not reproduced
  here and is not required to build or test the iOS app.
- The tracked source inventory contains 25 mock/fixture-named files: 24 `Mock*.swift` data
  files under `YouNew/Data` and `YouNew/Services/MockAIService.swift`. They contain demonstration and
  institutional content; no claim is made that every literal has been proven
  synthetic or public.
- A filename scan found 35 legal, health, privacy, terms, or document-related tracked
  source
  and data paths in the curated app/DataProject/documentation scope. Key review
  targets include `YouNew/Data/MockLegalInfoData.swift`,
  `YouNew/Models/DocumentItem.swift`, `YouNew/ViewModels/DocumentStore.swift`,
  `YouNew/Views/DocumentOrganizerView.swift`, the four `WP-03` healthcare batches,
  `PRIVACY_POLICY.md`, and `TERMS_OF_USE.md`. This inventory is not substantive
  legal or medical review.
- Pattern-only current-tree PII triage found 29 paths containing email-shaped
  literals, ten containing Netherlands-postcode-shaped literals, seven containing
  Netherlands-phone-shaped literals, and none containing a Netherlands-IBAN-shaped
  literal. Values were suppressed; many are expected public institutional contacts
  or sample data, but every path requires owner review before publication.
- The commit already tracks 39 raster captures outside the asset catalog: 13 IA
  Audit files (41,411,859 B), five QA Baseline files (8,214,510 B), and 21 Runtime
  files (41,407,839 B), totalling 91,034,208 B. Ignore rules do not keep tracked
  files out of a remote; OCR, EXIF, privacy, and rights review is incomplete. Seven
  additional untracked public-site images/icons are excluded only by exact staging:
  a current `.gitignore` modification no longer protects their `public/` directory.
- Screenshots, imported documents, local databases, test fixtures, and legal/medical
  content still need human review for real names, addresses, identifiers, health
  information, and copyrighted material. No blanket PII-clear claim is made.

## Repository protections added

`.gitignore` excludes local `.env`/Worker variable files, Worker local state,
certificates, keys, provisioning profiles, archives, result bundles, logs,
dependency output, local hosting metadata, raw media workspaces, and generated
DataProject staging/report caches. It explicitly leaves `.env.example`, `BuildWeekAudit/**`, and
`BuildWeekFix/**` visible so required reproducibility evidence is not hidden by
broad patterns.

## Limitations and remaining actions

- Dedicated scanners such as `gitleaks`, `detect-secrets`, and `trufflehog` were not
  available in the audited environment.
- OCR and EXIF review of images was not performed, and binary `.xcresult` contents
  were not comprehensively inspected.
- The history scan was targeted; a final curated commit should receive a fresh full
  history and staged-diff scan before push.
- No deployed backend or hosting secret store was accessible, so external secret
  configuration could not be audited.
- The owner must review Git authorship metadata, signing-team metadata, screenshots,
  fixtures, and public documents; rotate any credential if later discovered.

**Safe claim:** Targeted current-tree and history checks found no confirmed secret,
but the repository is not cleared for public publication until the remaining human
and dedicated-tool reviews are complete.

## Final evidence-stage scan

**PENDING:** record the exact staged-path count, path-only high-confidence signature
result, public-document absolute-path result, and JSON validation immediately before
the local evidence commit. This check does not clear reachable history, binaries,
OCR/EXIF, personal data, legal/medical content, or external secret stores.
