# Research privacy contract v1 draft

## Purpose limitation

Data is collected only to measure predefined newcomer journey outcomes. It is
not a general analytics stream, advertising profile, personalization dataset or
AI training corpus.

## Data minimization

Allowed fields are the structured observation fields in
`RESEARCH_PROTOCOL.md`. Direct identifiers and free text are prohibited.
Session UUIDs must be randomly generated and must not be derived from a user,
device, IP, email or Supabase account.

## Consent and withdrawal

Consent is separate from product terms. The consent record stores only a random
session UUID, protocol version and timestamps. Withdrawal prevents future use
and triggers deletion according to the approved operational procedure.

## Retention

Observation expiry is set at creation and cannot exceed 90 days. A purge
function exists, but no production schedule is enabled by this change.
Operational proof of the purge is required before research ingestion may be
enabled.

## Prohibited data

- BSN or other government identifiers;
- health condition, diagnosis or form responses;
- DigiD or other credentials;
- name, email, phone, address or contact details;
- copied form text or screenshots containing participant data;
- IP address or user-agent;
- audio/video recording unless a new protocol, consent and privacy review
  explicitly authorize it.

## Access and security

Only approved Owner/Admin/QA researchers may read observations. Direct client
inserts are denied; an authenticated RPC validates active consent and the
feature flag. Audit evidence and incident handling follow the repository
security runbook.

## Unresolved decisions

The lawful basis, controller/processor record, DPIA need, participant
recruitment handling and withdrawal identity procedure require a real human
privacy decision. Until these are resolved:

- `research_ingestion = false`;
- no production observation collection;
- User Outcome Gate remains not evaluated.
