# YouNew Brand Runtime QA

Run this outside the coding sandbox, from Xcode or Terminal with CoreSimulator access. This visual pass is required before accepting the brand/icon/button work.

Runtime visual QA must be completed on:
- iOS Simulator, or
- physical iPhone.

macOS runtime is not accepted as a replacement for this pass. A macOS build/test run may catch compiler issues, but it does not validate iPhone navigation, tab bar layout, safe areas, touch targets, app icon rendering, or localized mobile UI. Do not mark this QA complete from macOS screenshots or macOS test results.

## Preflight
```bash
cd "/Users/ivan/Library/Mobile Documents/com~apple~CloudDocs/Desktop/app/YouNew"

xcode-select -p
xcrun simctl list devices available
xcrun simctl list runtimes
xcodebuild -showdestinations -project YouNew.xcodeproj -scheme YouNew

mkdir -p ./.derivedData
xcodebuild -project YouNew.xcodeproj \
  -scheme YouNew \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath ./.derivedData \
  build
```

If `iPhone 17 Pro` is not installed, replace it with the exact large iPhone name from `simctl`. If no concrete iOS simulator devices are listed, open Xcode > Settings > Platforms and install an iOS simulator runtime.

## Devices
- iPhone 17 Pro, or the closest available large iPhone simulator.
- Smallest supported iPhone simulator, preferably iPhone SE.

## Locales
- English
- Russian
- Dutch

Launch arguments for each locale:
```text
-uiTesting -launchLanguage en
-uiTesting -launchLanguage ru
-uiTesting -launchLanguage nl
```

## Required Screenshots
Save screenshots under `QA/Screenshots/brand/` with this naming pattern:
- `iphone17pro-en-home.png`
- `iphone17pro-en-history.png`
- `iphone17pro-en-history-expanded.png`
- `iphone17pro-en-sources.png`
- `iphone17pro-ru-home.png`
- `iphone17pro-ru-history.png`
- `iphone17pro-ru-history-expanded.png`
- `iphone17pro-ru-sources.png`
- `iphone17pro-nl-home.png`
- `iphone17pro-nl-history.png`
- `iphone17pro-nl-history-expanded.png`
- `iphone17pro-nl-sources.png`
- repeat the same set with `iphonese-...`

## Screens To Check
- Home
- Search
- Map
- Saved
- Assistant/Help
- More
- About YouNew
- History of the Netherlands
- History source details sheet
- A city page with official flag and coat of arms, including Leiden if available

## Brand/Icon Checks
- App launches with the new YouNew icon.
- Home header uses the YouNew logo mark/wordmark and does not clip.
- More/About uses the YouNew logo in a restrained way.
- No old placeholder logo appears.
- No blurry or low-resolution logo appears.
- Bottom navigation icons use one consistent outline/active style.
- Bottom navigation labels fit in English, Russian, and Dutch.
- Tab touch targets are at least 44x44 pt.
- Active tab state is visible by shape/treatment, not color alone.
- Active tab icon does not jump or resize the bar.

## Button Checks
- Primary, secondary, ghost, icon, card, accordion, and source buttons show pressed states.
- Disabled buttons, if visible, remain readable.
- Icon-only buttons have meaningful VoiceOver labels.
- Back navigation works from History and City pages.

## Content/Layout Checks
- History page timeline icons use the shared badge style.
- Expanded history timeline cards grow vertically and do not clip.
- Source details sheet opens and closes.
- No content is hidden by the floating bottom navigation.
- No horizontal overflow appears on Home, History, City, Map, Search, Saved, More/About.
- Russian tab labels are exactly: `Главная`, `Поиск`, `Карта`, `Сохран.`, `Помощь`, `Ещё`.
- Dutch and English tab labels fit without clipping.

## Official Symbol Regression Checks
- Official city flags/coats of arms remain official media assets, not app UI icons.
- Leiden flag and coat of arms are unchanged.
- App logo is not used as a city/province symbol.
- UI icons are not used as municipal flags/coats of arms.

## Accessibility Checks
- VoiceOver reads icon-only controls with meaningful labels.
- Bottom tab buttons announce their labels.
- Selected bottom tab is identifiable.
- Text remains readable in dark mode.

## Pass/Fail
Fail the pass if any of these occur:
- Core navigation breaks.
- Any required screenshot cannot be captured because of layout or navigation failure.
- The pass was performed only on macOS instead of iOS Simulator or physical iPhone.
- A tab label clips horizontally.
- The bottom nav covers content.
- A city/province official symbol is replaced by a UI icon or logo.
- The app icon appears as a low-resolution raster or with unwanted alpha/background artifacts.
