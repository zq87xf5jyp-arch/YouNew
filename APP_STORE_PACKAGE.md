# YouNew App Store Package

Status: **owner-review draft; not submitted and not approved release metadata**.

## App Identity

- App name: YouNew
- Bundle identifier: `nl.younew.app`
- Version: `1.1`
- Build: `7`
- Primary category: Reference
- Secondary category: Travel
- Age rating: owner must complete the current App Store Connect questionnaire;
  this repository does not certify a rating.

## Subtitle

Newcomer guide for the Netherlands

## Promotional Text

Source-first information and practical tools for Dutch paperwork, services, search, checklists, and everyday newcomer questions.

## Keywords

Netherlands, newcomer, Dutch, BSN, DigiD, gemeente, housing, taxes, healthcare, expat, immigration

## Description

YouNew helps newcomers in the Netherlands understand practical next steps around registration, BSN, DigiD, official letters, housing, healthcare, work, taxes, transport, fines, and official-source links.

The app is designed as a local-first guide with checklists, search, document organization, local reminders, official-source links, privacy controls, and optional AI-assisted informational explanations.

Calendar events are added through the iOS event editor when available; the app does not read or synchronize your calendar back into YouNew. Partner listings and local services are informational and should be checked directly with the business.

YouNew is not affiliated with the Dutch government and does not provide legal, immigration, tax, medical, financial, employment, housing, or emergency advice. The AI assistant provides guidance based on the app's knowledge base and official sources where available. AI-generated informational assistance may contain inaccuracies. Always verify important information with official institutions or qualified professionals.

## Privacy nutrition label review notes

The deterministic assistant and its history are local-first. The app also contains
features that can access external official sites and public weather/place/event
services. The owner must inspect the final binary and answer App Store Connect's
current questions; the bullets below are not a completed privacy label.

The current public App Store listing declares broad data categories as not linked
to the user and used for third-party advertising/developer marketing. That does
not match the candidate privacy manifest, which declares linked Device ID and
Other Diagnostic Data for app functionality with tracking disabled. Neither
declaration should be copied forward until final-binary runtime behavior is
measured and the discrepancy is resolved in App Store Connect.

- No advertising, tracking, or analytics SDK is identified in the current audit.
- Approximate location can be processed for nearby support after permission.
- User content/documents and assistant state are designed for local app storage.
- External services receive normal network metadata under their own policies.

If `YOUNEW_AI_BACKEND_URL` is configured for a deployed bounded backend:

- Review and declare the question and bounded request metadata according to the
  final hosting, retention, and data-processing behavior.
- Update Privacy Policy URL and App Store privacy labels before submission.

## Required URLs

- Candidate Privacy Policy URL: `https://younew.nl/privacy/`
- Candidate Support URL: `https://younew.nl/support/`
- Candidate Terms URL: `https://younew.nl/terms/`
- Candidate contact email: `support@younew.nl`

The three HTTPS endpoints returned HTTP 200 on 22 July 2026. Their hosted content
does not yet match this repository's 22 July release-candidate policy. The
connected Hostinger API confirms that `support@younew.nl` and its standard
mailbox folders are accessible; an explicit end-to-end inbound/outbound delivery
test remains **NOT VERIFIED**. The owner must publish the synchronized legal copy,
verify delivery, and complete legal review before submission.

## Copyright

Copyright remains with the applicable rights holders. See `LICENSE` and
`MEDIA_ATTRIBUTION.md`; unresolved media must not be included in a release package.
