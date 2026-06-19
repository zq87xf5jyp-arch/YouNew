# Bug Fix Report

Date: 2026-06-13

## Fixed bugs

| Severity | Screen | Bug | Fix | Status |
| --- | --- | --- | --- | --- |
| High | Transport | Cards overlapped in the visual section | Replaced unstable adaptive image cards with fixed-height generated artwork cards | Fixed |
| High | Transport | White/gray remote image fallback could appear inside cards | Removed remote media dependency from transport visual cards | Fixed |
| High | History | Screen could read as an image archive rather than an educational journey | Limited main timeline to curated teaching images only | Fixed |
| Medium | Global image fallback | "Visual reference" appeared as visible production UI | Removed visible fallback text from AppContentImageView | Fixed |
| Medium | More | More screen did not provide enough useful user context | Added Personal Guide Dashboard using existing destinations | Fixed |
| Low | Information Hub | "Verified visuals" naming encouraged gallery interpretation | Renamed to "Media sources" | Fixed |

## Layout protections added

- Transport visual cards now have a fixed min/max height.
- Transport visual artwork is internal SwiftUI drawing, so there are no image-loader layout shifts.
- History teaching images are embedded only within period cards and remain bounded.
- More dashboard cards use stable two-column grids with fixed minimum heights.

## Verification

Command run:

```text
xcodebuild -project YouNew.xcodeproj -scheme YouNew -configuration Debug -destination 'generic/platform=macOS' -derivedDataPath .DerivedDataCodexMac CODE_SIGNING_ALLOWED=NO build
```

Result:

```text
BUILD SUCCEEDED
```

Known environment limitation:

- iOS simulator runtime is unavailable in this Codex environment, so post-fix physical-device screenshots were not captured here.

