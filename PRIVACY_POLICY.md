# YouNew Privacy Policy

Status: **owner/legal-review draft; not a verified hosted policy**.

Draft date: 2026-07-20

YouNew is a local-first informational app for newcomers in the Netherlands.

## Data Stored On Device

YouNew may store profile choices, selected city, checklist progress, saved items, recent searches, translator history, assistant conversation history, imported document files, and document metadata locally on the user's device.

Imported document files remain in app-managed local storage. Privacy export includes document metadata, not document file contents.

## AI Assistance

For the named Build Week newcomer scenario only, YouNew may use a separately
configured backend. The bounded client request contains the question, app locale,
scenario/context version, and a fixed set of knowledge-record identifiers. It does
not contain an OpenAI credential, documents, precise location, full user profile,
saved items, or conversation history. No deployed backend, live GPT-5.6 request,
hosting region, or provider retention behavior is proven by this repository.

When the backend is unavailable or its response fails validation, the app uses a
deterministic local guide and labels it as local guide mode. Safety/privacy checks
run before the original user text is appended to local conversation history.

Users should not enter BSN numbers, passport numbers, medical records, financial account numbers, or other sensitive personal data into the assistant.

AI-generated informational assistance may contain inaccuracies. Always verify important information with official institutions.

## Location

If the user grants permission, YouNew uses approximate current location to show nearby support points. Location is not used for tracking and is not stored as a long-term profile record by the app.

## Tracking And Analytics

YouNew does not include advertising SDKs, tracking SDKs, or analytics SDKs in the current release build.

## User Controls

The Privacy & Data Control screen lets users export a local JSON dossier and delete app-managed personal data.

## Third-Party Websites

YouNew links to official institutions and trusted external websites. External websites have their own privacy policies.

## Contact

Candidate support email: support@younew.nl

Candidate public URL: https://younew.nl/privacy/

The owner must verify both before distribution and reconcile this draft with the
final binary, backend, retention, GDPR roles, and App Store disclosures.
