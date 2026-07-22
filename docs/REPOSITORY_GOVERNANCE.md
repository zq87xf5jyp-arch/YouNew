# Repository governance

This document defines the version-control, security, backup, and release-history
contract for YouNew.

## Branches and pull requests

`main` is the only long-lived branch and represents the latest reviewed source
candidate. Never push feature work directly to it. Start each change from current
`main`, use one focused short-lived branch, and delete that branch after merge.

Use these prefixes:

- `feature/` for user-facing capability;
- `fix/` for a defect or regression;
- `chore/` for maintenance and dependency work;
- `docs/` for documentation-only work;
- `release/` for release preparation; and
- `agent/` for an isolated automation-agent change.

Every merge to `main` goes through a pull request. The protected branch must block
force pushes, deletion, and direct pushes; require the branch to be current; and
require these checks:

- `iOS build and unit tests`;
- `Public site validation`;
- `Backend security contract tests`;
- `Offline publication gates`; and
- `Secret scan`.

This is currently a single-maintainer repository, so the pull-request rule does
not require an approval that the author cannot provide. Review is still requested
when another trusted maintainer is available. All conversations must be resolved
before merge, and squash merge is the default so `main` keeps a linear history.
Merge queue is not enabled; add the `merge_group` trigger to every required-check
workflow before enabling it.

## Continuous integration and secrets

Product CI runs on every pull request. It executes repository static QA, builds
and unit-tests the iOS app, validates the public site, and runs backend security
contract tests. DATA PROJECT offline publication gates also run on every pull
request. Push workflows run only for `main`, avoiding duplicate feature-branch
and pull-request runs.

`Secret Scan` uses a full-history checkout and an immutable Gitleaks Action commit
on pull requests, pushes to `main`, a weekly schedule, and manual dispatch. It does
not publish a SARIF artifact or PR comment that could repeat a detected value.
GitHub native secret scanning and push protection should also remain enabled.

Seven historical `generic-api-key` findings were individually reviewed as local
storage identifiers, documentation, ordinary prose, or historical patch copies.
Only their exact fingerprints are recorded in `.gitleaksignore`; broad rule- or
path-level allowlists are prohibited. Any baseline addition requires the same
value-suppressed review and an explicit update to repository governance QA.

If a credential is detected, revoke or rotate it before attempting history
cleanup. Never paste the value into a pull request, issue, log, or screenshot.

## Repository backup and restore

`Repository Backup` runs weekly and on manual dispatch. It performs `git fsck`,
creates a full Git bundle from all fetched refs, verifies that bundle, records the
refs and head commit, and uploads a SHA-256 manifest with 14-day retention. A
full bundle is currently about 195 MB, so this keeps two recent recovery points
without consuming roughly 2.5 GB for a 90-day weekly history.

An Actions artifact protects against an accidental branch or tag deletion, but it
is not an independent off-platform disaster-recovery copy. At least monthly,
download the newest successful artifact and store it in an encrypted location
outside the GitHub account. Issues, pull requests, repository settings, Actions
secrets, App Store records, and uncommitted local files are not contained in a Git
bundle and require separate provider exports or records.

To create the same verified bundle locally from a clean worktree:

```sh
scripts/create-repository-backup.sh /secure/output/directory
```

To verify and restore a downloaded bundle:

```sh
shasum -a 256 -c SHA256SUMS
git bundle verify younew-repository-<timestamp>.bundle
git clone younew-repository-<timestamp>.bundle YouNew-restored
```

After restoration, inspect `refs.txt`, add the intended remote, and push only
after confirming ownership and repository identity.

## Release journal

`CHANGELOG.md` is the human-maintained release journal. Notable product,
governance, privacy, security, and data-contract changes belong under
`[Unreleased]` in the pull request that introduces them.

A release is created only from an annotated `vMAJOR.MINOR.PATCH` tag whose commit
is reachable from `main`. Before tagging:

1. verify all required checks on the release commit;
2. set the Xcode `MARKETING_VERSION`;
3. move the relevant entries from `[Unreleased]` to a dated version section;
4. create an annotated tag (signed when signing is configured); and
5. push that tag.

`Release Journal` verifies the tag, project version, changelog section, and main
ancestry, then creates an idempotent GitHub Release from that section. Publishing
to TestFlight or the App Store remains a separate, owner-controlled release step.

For an urgent regression, branch `fix/` from the latest released commit, use the
normal pull request and checks, increment the patch version, and record both the
fix and rollback impact in the changelog.
