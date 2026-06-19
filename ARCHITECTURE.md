# Architecture Overview

## App Structure

YouNew is a SwiftUI app organized around:

- `Views`: user-facing screens and navigation destinations.
- `Components`: reusable UI cards, banners, rows, and navigation elements.
- `ViewModels`: state and presentation logic.
- `Models`: domain entities and local persistence models.
- `Data`: static MVP/mock content.
- `Services`: local services and protocol abstractions.
- `Resources`: design tokens, localization, typography, spacing, colors, and animations.

## State

The app uses SwiftUI environment objects for shared state:

- `AppStateViewModel`: profile, checklist, selected city/status, map preferences, toast state, and privacy export payload.
- `LanguageManager`: app language through `@AppStorage`.
- `SavedItemsStore`: local saved resources and destinations.
- `DocumentStore`: local document metadata and app-managed document files.

## Privacy Architecture

The current architecture is local-first. There is no remote account, no analytics SDK, no advertising SDK, and no hidden sync. Personal data is controlled through `PrivacyDataControlView`.

## Security Architecture

Document storage uses app-managed Application Support storage, file protection on iOS where available, backup exclusion, and corrupted metadata quarantine. Export is explicit, temporary, protected where supported, and limited to metadata plus local profile state.

## Legal Architecture

Sensitive flows use disclaimer components and source reminders. `LegalDisclaimerView` centralizes legal safety language. Content should be reviewed before public launch and should never be positioned as legal advice.
