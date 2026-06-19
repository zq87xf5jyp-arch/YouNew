# BUNDLE_ID_REPORT

Date: 2026-06-11  
Scope: final pre-TestFlight blocker pass.

## Result

The app target has a syntactically valid bundle identifier, but App Store Connect ownership cannot be verified from the local project alone.

## Target Inventory

| Target name | Product type | Bundle Identifier | Version | Build | Team | Code signing |
| --- | --- | --- | --- | --- | --- | --- |
| YouNew | iOS app | `com.company.younew` | `1.0` | `1` | `9CXDJ2YMUZ` | Automatic |
| YouNewTests | Unit tests | `com.company.younew.tests` | `1.0` | `1` | `9CXDJ2YMUZ` | Automatic |
| YouNewUITests | UI tests | `com.company.younew.uitests` | `1.0` | `1` | `9CXDJ2YMUZ` | Automatic |

Source: `YouNew.xcodeproj/project.pbxproj`

## App Store Connect Compatibility

Local compatibility:

- Bundle ID format is valid reverse-DNS syntax.
- App target and test targets use distinct identifiers.
- Automatic signing is enabled.
- Development team is configured as `9CXDJ2YMUZ`.
- App minimum iOS target is `17.6`.

Manual App Store Connect compatibility still required:

- Confirm an App Store Connect app record exists for exact bundle ID `com.company.younew`.
- Confirm bundle ID `com.company.younew` belongs to team `9CXDJ2YMUZ`.
- Confirm provisioning/signing profiles are valid for that app record.
- If `com.company.younew` is a placeholder, replace it with the registered production bundle ID before upload.

## Blocker Status

Resolved in repo:

- Bundle identifier is present and valid.
- Test targets are separated from the app bundle ID.

Requires manual action:

- App Store Connect app record cannot be verified locally.
- Current identifier uses a generic `com.company` namespace. Treat it as acceptable only if it is already registered for YouNew.nl under the configured Apple team.

Release blocking:

- None from local bundle ID syntax.
- App Store Connect upload will fail if the exact bundle ID is not registered under the configured team.
