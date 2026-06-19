# Privacy and Security Notes

## Privacy Model

YouNew is designed as a local-first app. Personal profile state, checklist progress, saved items, recent searches, translator history, and imported document metadata are stored on device. The app does not include analytics SDKs, advertising SDKs, tracking domains, or background server synchronization.

## User Rights Implementation

- Export: `PrivacyDataControlView` creates a JSON dossier on explicit user action.
- Delete: `PrivacyDataControlView` clears profile state, checklist progress, saved items, recent topics, recent searches, translator history, and app-managed documents.
- Access: the Privacy & Data Control screen explains stored categories in plain language.
- Portability: export uses JSON and ISO-8601 dates.
- Minimization: document export includes metadata only, not file contents.

## Local Storage

- App preferences and saved items use app-only `UserDefaults`.
- Documents are copied into Application Support under app-managed storage.
- Document metadata is encoded as JSON.
- Document storage is marked excluded from backup.
- iOS file protection is applied where available.
- Corrupted document metadata is quarantined and the app falls back to an empty document list instead of crashing.

## App Store Privacy Manifest

`PrivacyInfo.xcprivacy` declares:

- No tracking.
- No tracking domains.
- No collected data types in the manifest, because the current app does not transmit user data off device.
- Required-reason API usage for app-only UserDefaults and app-container file metadata.

Before shipping, confirm this against the final binary, any added SDKs, and App Store Connect privacy nutrition labels.

## Clipboard

Clipboard writes happen only after explicit user actions, such as copying a translated result or official source URL.

## Legal Safety

The app must not be marketed as legal advice or an official government service. Fines, deadlines, procedures, and eligibility rules can change. All sensitive flows should remind users to verify with official institutions.

## Remaining Security Work Before Public Release

- Run device QA on real hardware.
- Review all imported document flows with the final entitlements and deployment target.
- Confirm privacy manifest values after dependency changes.
- Add a final external legal review of content and claims.
- Add signed release build verification and archive validation.
