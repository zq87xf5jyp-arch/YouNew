# YouNew Privacy Policy

Status: **release-candidate source; verify the hosted page matches before App Review**.

Effective date: 2026-07-22

YouNew is a local-first informational app for newcomers in the Netherlands.

## Data Stored On Device

YouNew may store profile choices, selected city, checklist progress, saved items, recent searches, translator history, assistant conversation history, imported document files, and document metadata locally on the user's device.

Imported document files remain in app-managed local storage. Privacy export includes document metadata, not document file contents.

## AI Assistance

The current App Store release has no remote AI backend configured and uses the
deterministic local guide. If a remote AI service is enabled in a future release,
the bounded request may contain the question, app locale, scenario/context version,
and a fixed set of knowledge-record identifiers. It does not contain an OpenAI
credential, documents, precise location, full user profile, saved items, or
conversation history. This policy and the App Store privacy information will be
updated before a remote AI service is enabled.

When the backend is unavailable or its response fails validation, the app uses a
deterministic local guide and labels it as local guide mode. Safety/privacy checks
run before the original user text is appended to local conversation history.

Users should not enter BSN numbers, passport numbers, medical records, financial account numbers, or other sensitive personal data into the assistant.

AI-generated informational assistance may contain inaccuracies. Always verify important information with official institutions.

## Location

If the user grants permission, YouNew uses approximate current location to show nearby support points. Location is not used for tracking and is not stored as a long-term profile record by the app.

## Tracking And Analytics

YouNew does not include advertising SDKs, tracking SDKs, or analytics SDKs in the current release build.

## Network Services And Technical Logs

The Home screen requests current weather from Open-Meteo using the coordinates of
the selected city from YouNew's public city catalogue. These are not the device's
current-location coordinates. Like other internet services, Open-Meteo receives
the connection IP address and requested URL. Its published terms state that
web-server logs used for maintenance, abuse prevention, and troubleshooting may
include IP addresses and requested coordinates and are deleted after 90 days.

YouNew also loads selected public information and images from Wikimedia Commons
and Flickr's public image delivery service. When an image is displayed, the
provider receives the IP address and requested URL needed to deliver it and may
keep technical server logs under its own policy.
YouNew uses this network information only to provide app functionality. It is not
used for advertising, marketing, analytics, or cross-app tracking. The App Store
privacy declaration conservatively identifies these technical logs as Device ID
and Other Diagnostic Data, linked to the device, not used for tracking.

## User Controls

The Privacy & Data Control screen lets users export a local JSON dossier and delete app-managed personal data.

## Third-Party Services And Websites

YouNew links to official institutions and trusted external websites. External websites have their own privacy policies.

## Contact

Support email: support@younew.nl

Public policy URL: https://younew.nl/privacy/

The hosted policy, final binary, privacy manifest, and App Store disclosures must
remain aligned before every release.
