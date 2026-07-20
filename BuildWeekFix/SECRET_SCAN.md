# Secret and sensitive-data scan

Date: 2026-07-20 (Europe/Amsterdam)

Branch: `build-week-readiness`

Baseline commit: `b15a2f2913911763c989f9880f8ce376f903fc6e`

Verdict: **no high-confidence secret confirmed; publication review remains incomplete**

No secret value is reproduced in this report. Results record counts and paths only.

## Scope and method

The current-tree scan covered repository text while excluding `.git`, dependency
caches, generated web output, `TestArtifacts`, raw image workspaces, and build
products. Targeted signatures included private-key headers, OpenAI-style keys,
GitHub tokens, AWS access-key IDs, and Slack tokens. A Git-history check covered
private-key headers; the prior audit also performed targeted current/history token
checks. Sensitive filenames were checked for common certificate, provisioning,
private-key, and environment-file extensions.

These are bounded pattern scans, not a security certification. No command printed a
candidate credential value.

## Results

| Check | Result | Review |
|---|---:|---|
| High-confidence current-tree secrets | 0 | No confirmed credential or private-key block. |
| Private-key signature files, current tree | 0 | PASS in scanned scope. |
| Private-key signature paths, reachable Git history | 0 | PASS in targeted history scope. |
| OpenAI-style signature candidates | 1 path | `YouNew/Data/MockScamWarningsData.swift`; reviewed as ordinary mock warning text, not a credential. |
| GitHub token candidates | 0 | PASS in scanned scope. |
| AWS access-key ID candidates | 0 | PASS in scanned scope. |
| Slack token candidates | 0 | PASS in scanned scope. |
| Certificate/key/profile filenames | 0 | No `.p12`, `.pfx`, `.pem`, `.key`, `.mobileprovision`, `.provisionprofile`, `.cer`, `.crt`, or `.der` file found outside excluded dependency paths. |
| Checked-in OpenAI key in iOS source | 0 confirmed | The client is designed to use a backend endpoint, not a provider credential. |

Pre-commit staged-snapshot verification covered 308 paths. Path-only checks found
no private-key header, GitHub token, AWS access-key ID, Slack token, certificate,
provisioning profile, build product, dependency cache, hosting metadata, or
machine-local absolute path in the staged set. The single OpenAI-shaped candidate
path is the reviewed mock-warning false positive listed above; its value is not
reproduced here.

## Metadata and privacy review

- Git history contains two distinct author-name values and two distinct author-email
  values. Values are intentionally omitted; the owner must decide whether that
  metadata is acceptable for a public remote.
- `YouNew.xcodeproj/project.pbxproj` contains eight `DEVELOPMENT_TEAM` key
  occurrences. The team value is not a secret, but it can identify an organization
  and requires owner review before publication.
- The six text files previously flagged for absolute macOS user-home paths were
  sanitized. A follow-up scan of repository Markdown, JSON, and Python files found
  no common macOS user-home, temporary-directory, runtime-cache, or mounted-volume
  absolute-path prefix. This text scan does not clear ignored/binary artifacts or
  Git history.
- `TestArtifacts/` is excluded because result bundles, logs, screenshots, and device
  diagnostics can contain identifiers or user data even when source scans are clean.
- A local public-site hosting metadata directory was found and is excluded as
  `admin-dashboard/public-site/.openai/`. Its project identifier is not reproduced
  here and is not required to build or test the iOS app.
- The source inventory contains 25 mock/fixture-named files: 24 `Mock*.swift` data
  files under `YouNew/Data` and `YouNew/Services/MockAIService.swift`. They contain demonstration and
  institutional content; no claim is made that every literal has been proven
  synthetic or public.
- A filename scan found 33 legal, health, privacy, terms, or document-related source
  and data paths in the curated app/DataProject/documentation scope. Key review
  targets include `YouNew/Data/MockLegalInfoData.swift`,
  `YouNew/Models/DocumentItem.swift`, `YouNew/ViewModels/DocumentStore.swift`,
  `YouNew/Views/DocumentOrganizerView.swift`, the four `WP-03` healthcare batches,
  `PRIVACY_POLICY.md`, and `TERMS_OF_USE.md`. This inventory is not substantive
  legal or medical review.
- Pattern-only PII triage found 33 files containing email-shaped literals and 12
  files containing Netherlands-postcode-shaped literals. Values were suppressed;
  many are expected public institutional contacts or sample addresses, but every
  path requires owner review before publication.
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
