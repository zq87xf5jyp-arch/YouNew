# Red-Marker Reproduction

Date: 2026-06-14

## Screenshot Findings

| Screenshot | Screen | Runtime-visible problem | Structural cause | Status |
|---|---|---|---|---|
| IMG_6802.PNG | History of the Netherlands | Dutch Revolt card is clipped horizontally; story, image caption, and Learn more extend off the right edge. | Timeline rail and full-width card competed for the same row width, so the card overflowed the screen. | Fixed in `YouNew/Views/NetherlandsHistoryView.swift`. |
| IMG_6803.PNG | History of the Netherlands | Golden Age card is clipped horizontally; long key-figure chip overflows. | Same timeline row width bug plus one-line capsule chips. | Fixed in `YouNew/Views/NetherlandsHistoryView.swift`. |
| IMG_6804.PNG | History of the Netherlands | Modern Netherlands card is clipped horizontally; supporting text and image are cut. | Same timeline row width bug. | Fixed in `YouNew/Views/NetherlandsHistoryView.swift`. |
| IMG_6805.jpg | AI Assistant | Bottom composer and safety text create a separate black slab over the floating tab bar. | Root shell/floating tab bar and the assistant empty state each created independent bottom surfaces/reserves. | Fixed in `YouNew/Views/RootTabView.swift` and `YouNew/Views/AIAssistantView.swift`. |
| IMG_6806.PNG | More | Dashboard is useful, but lower account/profile area still showed administrative/internal items elsewhere in the scroll. | More exposed too many profile/debug/control routes in the main path. | Fixed in `YouNew/Views/MoreHubView.swift`. |
| IMG_6807.jpg | More > Profile | Profile block exposes Privacy & Data Control, Knowledge diagnostics, Change Situation, and About the App as primary user rows. | Diagnostic and administrative routes were placed in the main More path instead of Settings/advanced or quick actions. | Fixed in `YouNew/Views/MoreHubView.swift`. |

## Verification

- macOS Debug build: PASS.
- Latest source pass also constrains History teaching images to card width and removes floating tab bar bottom-safe-area bleed.
- iOS build/runtime proof: NOT AVAILABLE in this environment. Asset compilation fails because CoreSimulatorService reports no available simulator runtimes.
