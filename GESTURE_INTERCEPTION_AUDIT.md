# Gesture Interception Audit

Date: 2026-06-13

Scope: SwiftUI touch and scroll audit for sticky vertical scrolling on real device. This pass treats scroll sticking as gesture capture, not rendering performance.

## Summary

Status: FIXED STATICALLY

Primary root cause: non-scroll child views installed their own gesture recognizers over large surfaces inside vertical `ScrollView`s. The worst offender was the shared `pressable()` modifier, which attached a near-instant `LongPressGesture` to cards and chips. This can compete with the parent scroll recognizer and create the reported first-drag stickiness.

Runtime screenshot verification: NOT PERFORMED in this pass.

## Issues Fixed

| Severity | Screen | View | Touch Area | Root Cause | Fix | Status |
| --- | --- | --- | --- | --- | --- | --- |
| Critical | Home, City pages, Province modal, More menu, Guide cards | All views using `.pressable()` | Entire card/chip/button surface | `PressableModifier` used `LongPressGesture(minimumDuration: 0.01, maximumDistance: 12)` as a `simultaneousGesture`. On real devices this can delay or compete with parent vertical scroll, especially on image cards and accordion cards. | Removed the custom long-press recognizer from `PressableModifier`. Button press feedback now relies on SwiftUI `ButtonStyle` pressed state only. | Fixed |
| High | More > Great Dutch Figures | `HistoricalFigureCard` accordion rows | Portrait, title, subtitle, expanded body, route row, card edge | Accordion cards inherited the global `.pressable()` long-press recognizer while also being full-card buttons. Expanded content therefore had an extra child recognizer under the finger during scroll. | Fixed by removing the global long-press behavior from `.pressable()`. Accordion still taps to expand; vertical drags are no longer delayed by the custom long press. | Fixed |
| High | Home | Featured City card | Hero image, title, stats, CTA area, card edge | Full-card `NavigationLink` inherited `.pressable()` and the image debug long-press inspector, creating multiple recognizers over the card. | Removed global `.pressable()` gesture behavior and moved image debug from full-surface long press to a small DEBUG-only info affordance. | Fixed |
| High | City / Province hero images, figure portraits | `CityImageView`, `HistoricalFigurePortraitImage` | Entire image rectangle | DEBUG `runtimeImageDebugInspector` attached `.contentShape(Rectangle())` and `.onLongPressGesture(minimumDuration: 0.65)` to the full image surface. Physical debug builds therefore made every image a long-press hit area. | Replaced full-image long press with a small top-right DEBUG-only info icon. The image surface itself no longer owns a long-press recognizer. | Fixed |
| High | AI Assistant | Conversation scroll area | Whole scroll surface | The main content `VStack` had `.contentShape(Rectangle()).onTapGesture` only to dismiss the keyboard. That made the entire assistant scroll body a competing tap field. | Removed the full-surface tap handler. Kept `.scrollDismissesKeyboard(.interactively)` for native keyboard dismissal. Background is now `.allowsHitTesting(false)`. | Fixed |
| Medium | Home | Mini Netherlands map preview | Entire map preview GeometryReader, including blank/card areas | `HomeRealisticNetherlandsMapCard` used a full-rectangle `SpatialTapGesture` across the preview. Blank parts of the card could capture touches that should have started vertical scroll. | Replaced the full-rectangle spatial gesture with province-sized tap zones over the visible map artwork only. Decorative map canvas is `.allowsHitTesting(false)`. | Fixed |
| Low | Debug tooling | `TapHighlighter` | Any view it was applied to | Unused DEBUG utility could turn arbitrary views into simultaneous tap surfaces. | Made the utility inert so it cannot accidentally create hidden tap surfaces if reused during QA. | Fixed |

## Remaining Intentional Gesture Zones Reviewed

| Screen | View | Gesture | Reason Kept |
| --- | --- | --- | --- |
| Full Map | `NetherlandsInteractiveMapView` | Magnification + drag gesture | The map screen itself is intentionally pan/zoom interactive. It is not inside a vertical content scroll in the same way as Home/cards. |
| Nearby Map | Province chips | `simultaneousGesture(TapGesture)` | Updates selected province while navigating. Small chip targets, not large hidden overlays. |
| Province detail / City detail | Map action buttons | `simultaneousGesture(TapGesture)` | Sets pending map focus while activating the explicit map button. The gesture is limited to visible button bounds. |
| AI ask cards | `AIAskButton` | `simultaneousGesture(TapGesture)` | Stores AI context while activating the explicit navigation row. The gesture is limited to a visible row and does not add a long-press recognizer. |

## Stress-Test Matrix

Expected after fixes:

| Surface | Expected Result |
| --- | --- |
| Historical figure portrait | Vertical drag starts parent scroll immediately. |
| Historical figure title/subtitle | Vertical drag starts parent scroll immediately. |
| Expanded historical figure body | Vertical drag starts parent scroll immediately. |
| Featured City image | Vertical drag starts parent scroll immediately. |
| Featured City title/stats | Vertical drag starts parent scroll immediately. |
| Featured City CTA | Vertical drag should scroll if movement is vertical; tap still opens city. |
| Home mini map blank/card area | Vertical drag starts parent scroll immediately. |
| Home mini map province shape | Tap selects province; vertical drag should scroll once movement exceeds tap tolerance. |
| AI Assistant message area | Vertical drag starts assistant scroll immediately. |
| City attraction cards | Vertical drag starts parent scroll immediately. |
| Guide article cards | Vertical drag starts parent scroll immediately. |

## Files Changed

- `YouNew/Resources/DesignSystem.swift`
- `YouNew/Components/ImageLoader.swift`
- `YouNew/Views/AIAssistantView.swift`
- `YouNew/Views/HomeView.swift`
- `YouNew/Utilities/TapHighlighter.swift`

## Verification

- Swift type-check: PASS
- Scoped whitespace check: PASS
- Runtime physical-device drag verification: NOT PERFORMED

## Remaining Risk

The full-screen map intentionally owns drag and zoom gestures. If users report sticking only inside map mode, that should be handled as map gesture arbitration, not vertical content scrolling.
