# Hang / Stutter / Freeze Audit

Date: 2026-06-14

## Findings

| Area | Risk | Cause | Fix |
|---|---|---|---|
| History timeline | Layout thrash and clipped horizontal content | Full-width card and timeline rail competed for horizontal space. | Timeline rail is now a fixed-width column; card content flexes inside the remaining width. |
| History teaching images | Horizontal layout expansion | Image view height was fixed, but width was not explicitly constrained to the card. | Teaching images now use `frame(maxWidth: .infinity)` inside the card. |
| Root bottom shell | Black slab / visual seam | Root background and floating tab background used independent bottom behavior. | Root background is full-screen; floating tab background no longer ignores bottom safe area. |
| AI Assistant bottom composer | Keyboard/bottom layout jump | Empty state used fixed bottom spacers and duplicated safety text while the composer floated above it. | Empty state now uses shared composer reserve and a single safety warning. |
| More screen | Perceived complexity and heavy administrative section | Main More path exposed profile/debug/control rows that looked internal. | More account area simplified; diagnostics removed from primary path. |

## Source-Level Performance Notes

- No synchronous image downloads were added.
- No new image stacks or heavy blur layers were added.
- The History fix reduces horizontal overflow and should reduce repeated layout invalidations while scrolling.
- The AI fix removes competing full-width bottom surfaces during keyboard transitions.

## Verification

- macOS Debug build: PASS.
- Device scroll FPS measurement: NOT PERFORMED in this environment.
- iOS runtime proof: NOT AVAILABLE due CoreSimulatorService/asset-catalog runtime failure.
