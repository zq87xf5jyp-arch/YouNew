# Changelog

Notable repository and product changes are recorded here. Dates use ISO 8601 and
versions follow semantic versioning.

## [Unreleased]

- Validate dynamic freshness exclusions against canonical deadlines, honor each
  project's pinned package manager in dependency audits, and verify the completed
  disposable legacy-sync assertion before checking fixture cleanup.

- Make Hostinger anonymous authentication independent of database configuration; add HTTP coverage and CI for the Hostinger Admin candidate. Synchronize the approved runtime website fields and fail-closed export smoke checks.


### Added

- Update the Hostinger Admin MySQL driver to 3.23.1 to address authentication
  downgrade and compressed-protocol decompression vulnerabilities.

- Preserve the Hostinger PHP forms, MariaDB Admin candidate, and 71 unapproved
  editorial drafts in the canonical repository, with private backup tooling.
- Recalculate public freshness exclusions at build time and support empty static
  catalog sections without publishing placeholder records.
- Product CI for repository static checks, iOS unit tests, public-site validation,
  backend security contracts, failed-test diagnostics, and unsigned Release builds.
- GitHub contribution, support, conduct, ownership, issue, pull-request, and
  dependency-update metadata.
- Repository-wide Gitleaks checks on pull requests, `main`, weekly history scans,
  and manual runs.
- A verified weekly Git bundle backup, restore instructions, and 14-day Actions
  artifact retention.
- Tag-driven GitHub Releases sourced from this changelog.
- A documented short-lived branch and protected-`main` pull-request policy.

### Changed

- Restored governed source health with corrected official URLs and a zero
  `governed_broken_links` gate result.
- Hardened GitHub Actions with immutable action SHAs, scoped credentials,
  reproducible runner images, and always-present pull-request checks.
- Made event health tests independent of the calendar date while retaining
  explicit coverage for seeded events and active-event counters.
- Made public-site validation safe for a clean clone.
- Closed the shipped app-media rights gate with deterministic evidence.

## [1.0.0] - 2026-06-24

### Added

- Initial public App Store release for iPhone and iPad.
- Local-first newcomer guidance for Dutch cities, government services,
  healthcare, housing, transport, education, and daily life.
- English, Dutch, and Russian localization.
