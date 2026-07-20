# YouNew privacy notes

Last reviewed: 2026-07-20

Scope: the repository and Build Week demonstration build, not a legal privacy
certification or App Store privacy-label filing.

## Product position

YouNew is designed as a local-first newcomer guide. Its deterministic assistant,
bundled knowledge, saved state, checklists, and document metadata can operate on
device. The repository audit did not find analytics or advertising SDKs. Imported
documents are intended to remain in local app storage; privacy export contains
document metadata rather than document contents.

Conversation history is stored locally so the assistant can preserve continuity.
The pre-remediation audit found that raw text could be persisted before all safety
checks. The current working tree evaluates the safety/privacy decision before
appending a user message and persists only a standalone warning when input is
blocked; final full-suite and clean-clone verification of that remediation is still
pending. Clearing the visible conversation now also clears structured responses,
workflow state, the in-memory answer cache, and its persisted cache entry. Users
should still not enter passport numbers, BSNs, bank details, medical records, exact
addresses, credentials, or other sensitive data; broader release verification of
all local data controls remains required.

## Optional live AI path

When a separately configured backend is available, the named Build Week newcomer
scenario may send a bounded request to that backend. The intended payload is limited
to the question, language, scenario/context identifiers, and the identifiers needed
to select pre-approved YouNew knowledge records. The client
must not send an OpenAI API key, documents, precise location, full profile, or
unbounded conversation history.

The backend is responsible for protecting its OpenAI credential, enforcing limits,
avoiding logs of question/answer bodies or sensitive data, returning a request ID
and the model actually used, and rejecting malformed output. No deployed backend,
live request, retention setting, hosting region, data-processing agreement, or
runtime GPT-5.6 call is proven in this repository as of this review.

If the backend is missing, times out, returns an error, or fails validation, YouNew
uses the existing deterministic guide and labels the response as local guide mode.
Fallback output must not be presented as OpenAI-generated.

## Other network features

Some product surfaces can open official websites or request public information such
as weather, places, or event data. Those services have their own privacy practices
and network metadata. The user should see the destination before leaving the app.
No claim is made here that every external service has completed a legal or privacy
review.

## User control

The app includes local privacy/data-control surfaces for export and deletion. Final
release verification must confirm that deletion covers assistant history, caches,
saved state, imported documents, and any new live-AI identifiers. Removing the app
may also remove local data according to iOS behavior; backend deletion cannot be
claimed until a deployed backend policy is documented and tested.

## Before public distribution

The owner must review the shipping binary and backend, publish correct support and
privacy-policy URLs, complete App Store privacy disclosures, confirm applicable
GDPR roles and retention, and obtain legal review for the final data flows. The
existing `PRIVACY_POLICY.md` is historical product copy and does not replace that
release-specific review.
