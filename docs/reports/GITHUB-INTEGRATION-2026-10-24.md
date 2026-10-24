# GitHub integration review — 24 October 2026

Integration branch starts at remote main dd03f4f, cherry-picks 879f95b and 174c3c6 with conflict resolution, then imports the selected current YouNew worktree. No merge commit is created. The original worktree is untouched.

## Reconciliation

- Retain acquisition page and every asset byte-for-byte from main, including PDF/MP4 range support and noindex headers.
- Combine legacy business redirects with acquisition handling in preview and worker.
- Regenerate service-worker cache fingerprint from integrated sources.
- Preserve remote future-review-date guard in KnowledgeDataGovernance; reconcile deterministic iOS fixture helpers with latest local tests.
- Regenerate trust snapshots from current local source inputs; production remains unapproved.
- Remove the imported Admin CI step referencing absent standalone services/digital-commerce sources, which are outside this synchronization.
- Select 267 untracked YouNew source/data/documentation companion files. Exclude 712 paths including separate Studio projects, duplicate exports, database/CI dumps, .temp, generated HTML/notebooks and old release packages. Normalize selected CSV line endings only.
- Include Supabase SQL/functions as source files for review only. No database, CLI environment, migration, backup or remote service operation was executed.

## Local validation

Node 24.19.0; existing pinned dependency installations reused through local ignored symlinks; no credentials or environment files copied.

- Public unit/contract tests: 203/203.
- Admin unit/contract tests: 162/162.
- Search QA: 2608/2608.
- Public and Admin builds, TypeScript and ESLint: passed.
- Static internal links/assets: 37,846 references across 494 HTML files, zero broken.
- Smoke/security package checks: passed; 456 indexable URLs.
- Indexable-content audit: 456 PASS, 0 REVIEW, 0 FAIL.
- Local preview HTTP checks: acquisition 200/noindex, MP4 Range 206, legacy 308 redirect preserving query.
- Full-directory secret scan: six findings, all in files unchanged from origin/main; no newly introduced finding in that scan.

Full iOS test suite, browser role/viewport E2E, database tests and live staging checks were not rerun. This PR is for review, not launch approval. GitHub Actions were skipped via the head commit message. Subsequent review found that Xcode Cloud independently ran on the PR and failed its pre-build script; the marker does not suppress this integration. Further pushes require verified exclusion of this branch or temporary workflow deactivation; no paid runs are authorized. Do not merge or enable auto-merge as part of this task.

## Release archive

Original Phase 6.1 archive was verified unchanged at SHA-256 `68c87fcd29901473a6852adc5dbd8ddbac8ac60c8bc7ee970915d328e917d3f2`. That hash is obsolete for the integrated build, while still correct for the original archive.

New local integration archive SHA-256: `463c85df36dc9ae091eb8e429b0c6c6035ed492b46353c326d7c566e4cc6f7fe`.

The accompanying JSON records scope and validation. Archive is retained locally, not uploaded to the public repository. Deployment authorization remains false. Earlier Phase reports describe historical evidence and do not certify this integration.


## PR 53 local review corrections

- Removed 27 unreferenced standalone fulfillment, maintenance and provider-reconciliation files from this PR's final diff. Their original local copies are preserved. The app's owner-only finance report remains; its route is now covered by the existing role/viewport E2E matrix.
- Retained all 11 acquisition files byte-for-byte from main, including the PDF and video. Local browser tests cover the carousel, noindex, Range 206 and private homepage search at 1440x900 and 390x844.
- Fixed stale static QA assumptions after privacy and freshness work: debounce line reference, renamed privacy test, rejection of persisted search history, and reviewed source-date receipts.
- Replaced exact public/iOS ID equality with a strict partition: each canonical record must be public or explicitly excluded by the reviewed disposition. Duplicate, unexplained, foreign and re-published excluded records fail. Five regression tests are wired into local and Admin CI checks.
- Public freshness-safe gate passes. Strict full-dataset freshness gates remain blocked; no dates, release acceptance, publication state or QA catalog were changed to bypass them.
- Review corrections remain local until automatic Xcode Cloud execution is excluded. GitHub PR head must not be represented as containing these corrections before push.
