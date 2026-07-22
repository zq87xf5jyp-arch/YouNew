# Changelog

Notable repository and product changes are recorded here. Dates use ISO 8601 and
versions follow semantic versioning.

## [Unreleased]

### Added

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
- Made public-site validation safe for a clean clone.
- Closed the shipped app-media rights gate with deterministic evidence.

## [1.0.0] - 2026-06-24

### Added

- Initial public App Store release for iPhone and iPad.
- Local-first newcomer guidance for Dutch cities, government services,
  healthcare, housing, transport, education, and daily life.
- English, Dutch, and Russian localization.
