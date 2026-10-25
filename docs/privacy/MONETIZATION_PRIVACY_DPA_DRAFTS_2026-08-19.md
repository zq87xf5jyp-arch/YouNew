# YouNew monetization privacy and DPA drafts

Date: 2026-08-19  
Owner: Ivan Chernikov  
Status: **DRAFT — NOT SIGNED — NOT LEGAL ADVICE — OWNER/COUNSEL REVIEW REQUIRED**

This packet documents the proposed 90-day employee-onboarding pilot. It does
not certify GDPR compliance, accept a provider DPA, amend a customer contract,
or authorize production processing. The technical implementation remains
undeployed.

The role analysis follows the European Commission distinction: the controller
decides why and how processing occurs, while a processor acts on documented
instructions; Article 28 terms must be contractual. The controller remains
accountable for the GDPR principles, including purpose limitation,
minimisation, storage limitation and security.

Official reference set:

- [European Commission — controller and processor roles](https://commission.europa.eu/law/law-topic/data-protection/information-business-and-organisations/application-gdpr_en)
- [European Commission — GDPR processing principles](https://commission.europa.eu/law/law-topic/data-protection/rules-business-and-organisations/principles-gdpr_fr)
- [European Commission — lawful grounds](https://commission.europa.eu/law/law-topic/data-protection/information-business-and-organisations/legal-grounds-processing-data_en)
- [European Commission — data-subject requests](https://commission.europa.eu/law/law-topic/data-protection/information-business-and-organisations/dealing-requests-individuals_en)
- [European Commission — personal-data breaches](https://commission.europa.eu/law/law-topic/data-protection/information-business-and-organisations/obligations/what-data-breach-and-what-do-we-have-do-case-data-breach_en)
- [EUR-Lex — Regulation (EU) 2016/679](https://eur-lex.europa.eu/legal-content/EN/ALL/?uri=celex%3A32016R0679)
- [Dutch DPA — breach preparedness](https://autoriteitpersoonsgegevens.nl/en/themes/security/data-breaches/preventing-a-data-breach-and-being-prepared)

## 1. Data-processing map

| Flow | Data subjects and fields | Purpose | Proposed role allocation | Destination and retention |
|---|---|---|---|---|
| Public page delivery | Visitor IP and request metadata exist in delivery infrastructure; YouNew application content contains no account | Deliver the public guide and protect availability | YouNew controller; current site platform/hosting provider processor where its applicable DPA says so | Provider technical logs: proposed 30 days and no intentional PII in application logs; exact provider setting must be verified |
| Optional first-party web analytics | Random event/client IDs, random tab session/instance ID, event type, path without query, site version, language, coarse selected city, timestamp, consent/schema/environment and bounded allowlisted properties; no stored raw IP | Product reliability and aggregate feature usage | YouNew controller; Supabase processor | EU Supabase project; raw events/sessions 90 days; consent required by product gate |
| Pilot request | Company, organization type, contact name/role, work email, optional phone, website, optional/required KvK, city/province, pilot goal, recurring-question description, offer/type constants, source path, bounded UTM fields, consent/authority confirmation and timestamps | Assess fit, respond, prepare a scoped proposal, secure the intake path | YouNew controller; Supabase processor; hosting provider processor for transit; email provider only if the submitter chooses the explicit mail fallback | Active while the request is handled; unfinished 30 days, unconfirmed/spam 90 days, lost/archived 12 months; won/contract/accounting records excluded from automated cleanup |
| Abuse prevention and duplicate handling | Salted one-way rate fingerprint/window, safe receipt, timing and result state; no stored raw IP or PII dedupe fingerprint | Security, rate limiting, reliable retry | YouNew controller; Supabase processor | Rate/operational state only for its bounded window; related non-PII technical logs proposed 30 days |
| Admin lead pipeline | Pilot-request fields plus stage, controlled lost reason/detail, won-evidence type/date, audit timestamps, internal notes, safe notification reference/status | Qualify and administer the requested pilot | YouNew controller; Supabase and Admin host processors | Lifecycle-specific retention above; admin notifications 90 days; legal hold overrides deletion |
| Pilot employee usage | Internal client-scope UUID, SHA-256 pseudonymous subject token, one of four events (`route_opened`, `step_completed`, `official_source_opened`, `search_used`), event time, consent version/granted flag, sample flag | Provide the client only a privacy-safe aggregate pilot report | Customer normally controller for its employee context; YouNew processor on documented instructions. If YouNew independently changes purpose/means, it may become controller for that processing and must re-review the role | EU Supabase project; raw events 90 days; no email/name/phone/IP/user ID/free text/timeline/sponsor field accepted |
| B2B aggregate report | Date, bounded event name, event count and participant count only for cohorts with both values at least 5; sample marker; suppressed-segment total | Summary and final pilot reporting | Customer controller; YouNew processor until the report is delivered. A genuinely anonymous result may fall outside personal-data scope, but this must not be assumed while re-identification remains reasonably possible | One client scope per report; aggregate snapshot 24 months; raw/client-scope IDs never exported |
| Support email | Sender address, message and chosen attachments | Answer the sender's request | YouNew controller; mail provider processor | Case-based retention; do not accept identity, medical or financial documents; unresolved legal setting |
| Contracts, invoices and statutory accounting | Authorized customer contacts, contract terms, invoice and tax records | Contract performance and legal/accounting duties | YouNew controller; accounting/mail providers as separately assessed | **Outside** the automated monetization-retention job; use the separately established statutory period |
| Local iOS/web state | Saved items, recent pages/search setting, profile choice, app conversation and document state depending surface | User-requested local functionality | User device/local browser; YouNew does not receive these values unless a separate disclosed network flow applies | Device/browser controls; not part of the Supabase retention job |

Special-category data, BSN, passport data, employee names, health data,
immigration files, tax records, payment-card data and free-form employee messages
are outside the approved pilot telemetry. Forms and contract onboarding must say
not to provide them. If received unexpectedly, restrict access, assess the
incident, and delete or quarantine under the approved procedure.

## 2. Controller/processor decision record

| Processing | Proposed Article 6 basis / instruction | Decision status |
|---|---|---|
| Optional website analytics | Consent, recorded as a versioned affirmative choice and withdrawable for future events | **Proposed.** Confirm Dutch ePrivacy/cookie treatment and public notice before production |
| Requested pilot intake and response | Steps requested before a possible contract for the submitter, plus YouNew's legitimate interest in answering a professional B2B request and preventing abuse | **Proposed.** The required privacy checkbox records notice/choice but must not be treated as the only lawful basis without legal review |
| Pipeline administration and security audit | Legitimate interests in administering a requested business relationship, preventing abuse, and establishing/defending legal claims, subject to necessity and balancing | **Proposed.** Complete and approve a legitimate-interest assessment |
| Customer employee telemetry | Customer must document its own lawful basis and transparency duties; YouNew processes only on written instructions. The technical consent gate is a minimisation/control feature, not proof that employee consent is freely given in an employment relationship | **BLOCKED for live pilot** until customer role/basis, notice and opt-out/consent design are approved |
| Contract and invoice records | Contract performance and applicable legal/accounting duties | **Proposed.** Accountant/counsel must set the actual Dutch retention period |
| Direct marketing | None in this scope | **Not authorized.** A pilot request is not marketing consent |

No solely automated decision with legal or similarly significant effect is in
scope. Partner/sponsor status cannot affect factual guidance or report results.

## 3. Processor and subprocessor register

Provider roles are service- and contract-specific. “Processor” below is not a
claim that a DPA has already been executed.

| Provider | Current/conditional use | Expected role | Official contract evidence | Closure action |
|---|---|---|---|---|
| Supabase | Active production database/Auth/Storage/Edge; EU West project | Processor to YouNew; subprocessor when YouNew acts for a pilot customer | [Supabase DPA, version dated 1 June 2026](https://supabase.com/downloads/docs/Supabase%2BDPA%2B260601.pdf). Schedule 3 lists hosting, support, monitoring and other subprocessors | Record account acceptance/signature, contracting entity, region, transfer module/TIA, change-notice subscription, support access, backup/log retention and deletion assistance |
| OpenAI Sites | Repository evidence identifies the public origin; exact account terms unverified | YouNew is controller of Site end-user data; OpenAI processor where the applicable agreement/DPA provides | [Official Sites data-protection guidance](https://help.openai.com/en/articles/20001340) says the Site operator is controller and warns that residency is not supported at launch | Verify the actual production origin/account DPA and transfers. Keep forms, PHI and payment-card data outside Sites if the applicable terms prohibit them |
| Hostinger hosting and mail | Admin hosting and support/business email according to release documentation | Processor for hosted customer data and mail content; may also act independently for account/billing data | [Hostinger DPA](https://www.hostinger.com/nl/legal/dpa) identifies Hostinger as processor for covered services and lists AWS EMEA, Google Cloud EMEA, Cloudflare, MailChannels, Proofpoint and other subprocessors | Confirm covered products, contracting entity, data centre, log/mail retention, mailbox access, deletion, export, incident notice and subprocessor-change process |
| GitHub and GitHub Actions | Source, CI and synthetic artifacts; production PII is prohibited from repository/CI | Processor only if the applicable paid service/DPA covers the account; otherwise account-specific review required | [GitHub customer agreements](https://github.com/customer-terms) state the DPA applies to Enterprise Cloud/Unified, Teams and Copilot; [GitHub subprocessor list](https://docs.github.com/en/site-policy/privacy-policies/github-subprocessors) | Confirm plan/DPA applicability. Keep production dumps, PII and secrets out of source, logs and artifacts; retain disposable artifacts only for the approved short period |
| Cloudflare | A direct or downstream delivery/security provider depending the active hosting path | Processor/subprocessor depending contract | [Cloudflare DPA v6.4, 3 April 2026](https://cf-assets.www.cloudflare.com/slt3lc6tev37/1TTgT35GoUNlKZYGuKWBFy/4e7dfc8cf402419a9b1cf624291fc69f/cloudflare_customer_dpa-v6.4_april_3_2026.pdf) and [subprocessor list](https://www.cloudflare.com/gdpr/subprocessors/cloudflare-services/) | Determine whether YouNew has a direct Cloudflare account or Cloudflare is only downstream; record log settings and transfer terms |
| Apple WeatherKit/App Store | iOS weather/app distribution | Usually separate service/controller relationship, not assumed to be YouNew's processor | [WeatherKit privacy description](https://developer.apple.com/weatherkit/) says location is used for forecast delivery and not tracked between requests | Keep selected-city coordinates distinct from device location; verify final binary/privacy labels and Apple terms |
| Wikimedia Commons/Flickr and linked official sites | Public images and user-directed external links | Normally independent controllers for request metadata | Provider privacy terms, not a YouNew DPA | Maintain attribution and notice; do not send pilot/contact data in URLs |
| OpenAI API | Reference implementation only; no live inference authorized | Conditional future processor/subprocessor | [OpenAI DPA effective 1 January 2026](https://openai.com/en-GB/policies/data-processing-addendum/) and [subprocessor list updated 9 July 2026](https://openai.com/policies/sub-processor-list/) | Do not enable until data map, DPA, transfer/residency, retention, logs, DPIA/assessment and privacy notice are approved |
| External CRM, payments, outreach platforms | Not integrated | None | N/A | New provider requires separate owner approval and this register/DPA review |

### DPA checklist for every processor

- [ ] Exact legal entity, service, plan and acceptance/signature evidence.
- [ ] Article 28 subject matter, duration, nature, purpose, data types and data subjects.
- [ ] Processing only on documented instructions and confidentiality duties.
- [ ] Appropriate technical and organisational security measures; encryption,
      access control, MFA, logging, vulnerability and incident processes.
- [ ] Subprocessor list, general/specific authorization, change notice and
      objection route.
- [ ] EU/EEA processing location, international-transfer mechanism, SCC module,
      supplementary measures and current transfer-impact assessment.
- [ ] Breach notice fast enough for YouNew/customer to assess the GDPR 72-hour
      deadline; evidence and cooperation duties.
- [ ] Assistance with access, correction, restriction, deletion, portability,
      objection, DPIA and regulator consultation.
- [ ] Return/deletion after service termination, including backups and support copies.
- [ ] Audit/assurance reports and a documented way to demonstrate compliance.
- [ ] Retention/log settings mapped to YouNew defaults; no provider default silently
      exceeds the approved period.
- [ ] DPA/customer agreement precedence, liability, governing law and competent
      authority reviewed by counsel.

## 4. B2B pilot DPA template

**DRAFT — DO NOT SIGN WITHOUT OWNER/COUNSEL REVIEW**

### Parties and order of precedence

This Data Processing Addendum (“Pilot DPA”) forms part of the 90-Day Employee
Onboarding Pilot agreement between `[Customer legal name]` (“Customer”) and
`[YouNew legal entity/full address/registration]` (“YouNew”). For Pilot Employee
Data, Customer is Controller and YouNew is Processor. For YouNew's own business
contact, security, contract, invoice and statutory records, YouNew acts as an
independent Controller and its privacy notice applies.

### Processing details

- Subject: delivery, maintenance and measurement of one scoped onboarding hub.
- Duration: the 90-day pilot plus the deletion/return window below.
- Data subjects: Customer's participating international employees; authorized
  Customer contacts.
- Pilot Employee Data: pseudonymous subject token, internal client scope, one of
  four bounded events, event time, consent/version and sample flag.
- Excluded data: names, email, telephone, IP stored in the event, user/account ID,
  free text, individual timeline, precise location, special-category data,
  immigration/legal/medical/tax files and payment-card data.
- Purpose: operate the scoped hub and produce aggregate usage reports; never
  employment monitoring, performance scoring, advertising or individual decisions.
- Frequency: event-by-event only while the Customer's approved collection gate is on.
- Location/providers: EU-hosted Supabase project and the approved provider register.

### Customer instructions and duties

Customer instructs YouNew to process Pilot Employee Data only for the purposes
above. Customer will document its lawful basis, provide required notices, avoid
coercive employee consent, identify any works-council obligation, and not submit
excluded data. Customer will not ask YouNew to identify an individual or reduce
the minimum cohort. Customer remains responsible for the lawfulness and accuracy
of its instructions.

### YouNew processor duties

YouNew will:

1. process only documented lawful instructions and notify Customer if an
   instruction appears unlawful;
2. bind authorized personnel to confidentiality and least-privilege access;
3. maintain RLS, service-role boundaries, encryption in transit, controlled
   administration, audit timestamps, tested backup/restore and incident controls;
4. use only approved subprocessors under equivalent data-protection obligations;
5. assist Customer with rights requests, security, breach assessment, DPIAs and
   regulator consultation, taking account of the nature of processing;
6. notify Customer of a suspected Personal Data Breach **without undue delay and
   operationally target 24 hours** after confirmation, without representing that
   this replaces Customer's own legal assessment/deadline;
7. make compliance evidence available subject to reasonable confidentiality,
   scope, frequency and cost terms;
8. at Customer's choice, return an approved aggregate report and delete remaining
   Pilot Employee Data, unless law or an approved legal hold requires restriction.

### Aggregation and disclosure contract

- A segment is exportable only when event count **and** distinct participant count
  are each at least 5.
- Small cohorts are omitted; only the number of suppressed segments may be shown.
- Reports contain no email, phone, name, IP, user ID, subject hash, client-scope ID,
  free text or individual timeline.
- Data from different customers and sample/real data are never combined.
- Only consent-gated events enter the report.
- Partner/sponsor status cannot influence content or metrics.
- Demo outputs are visibly and machine-readably labelled `sample data`.

### Retention, deletion and legal hold

Raw pilot usage events: 90 days. Aggregate report snapshots: 24 months unless the
main agreement requires earlier deletion. Admin notifications: 90 days. Temporary
CSV outputs are streamed and should not be persisted; any authorized temporary
copy must be deleted within 30 days. Technical logs must contain no intentional
PII and use a 30-day setting. A documented litigation, regulatory, security,
data-subject-request or contractual hold pauses deletion only for affected records.
Deletion evidence records counts/policy/cutoff, not deleted identifiers or PII.

### Subprocessors and transfers

Approved subprocessors are listed in the provider register attached to the final
agreement. `[notice period]` advance notice and an objection/alternative/termination
process must be agreed. International transfers require the applicable adequacy
decision or SCC module and supplementary assessment.

### End of services

Within `[30]` days after termination, YouNew will return the approved aggregate
deliverable and delete remaining Pilot Employee Data from active systems, subject
to backup expiry and documented legal hold. Customer contact, contract, invoice
and statutory records follow YouNew's separate controller retention schedule.

Signatures: `[intentionally blank]`.

## 5. Data-subject request procedure

Owner: Ivan Chernikov. Technical executor: authorized YouNew administrator.

1. Receive at `support@younew.nl`; record request type/date and confirmation ID
   where available. Never request a passport/BSN copy by default.
2. Acknowledge promptly. Respond without undue delay and in principle within one
   month, as described by the European Commission; record any lawful extension.
3. Verify identity proportionately. For a business inquiry, match the request from
   the stored work address and safe confirmation ID; use a second channel only if
   necessary. Do not expose whether an unrelated person exists in the system.
4. Identify controller: YouNew handles its controller records. For pilot employee
   data, notify the Customer controller and act only on documented instructions,
   unless law requires otherwise.
5. Search by the minimum necessary key across business inquiry, feedback/support,
   notifications, audit references and—only when a lawful mapping exists—pilot
   pseudonymous data. Optional web analytics normally cannot be linked reliably to
   a person after the tab/session ends.
6. Place a `data_subject_request` legal hold while scope/identity is resolved.
7. Review access, rectification, erasure, restriction, portability or objection;
   check contracts, legal duties and legal claims before deletion.
8. Export only the requester's data through an encrypted/restricted channel;
   redact third-party data and internal security material.
9. Execute the approved correction/deletion/restriction. Remove the legal hold
   after completion. Record request, dates, decision and counts—not a copy of
   deleted PII.
10. Send the decision, reasons for any refusal/partial refusal, and complaint/
    judicial-remedy information. Have a second reviewer check high-risk responses.

Disposable rehearsal still required before production: create one synthetic lead
and linked notification, run access export, hold, deletion, count reconciliation
and proof that the deletion audit contains no PII.

## 6. Incident-response procedure

Incident owner and regulator decision owner: Ivan Chernikov. Codex/automation may
collect technical evidence only under the owner's authority; it cannot make the
legal notification decision.

1. **Detect and report immediately:** anyone who sees suspected confidentiality,
   integrity or availability loss reports it to the owner; preserve the first-known
   time and source.
2. **Contain safely:** revoke affected tokens/sessions, disable public intake or
   report export if necessary, preserve logs, and do not destroy evidence or weaken
   RLS. Production restore/migration needs separate approval.
3. **Classify:** affected systems, controller/processor role, categories, number of
   people/records, geography, special data, encryption, likely consequences and
   continuing exposure.
4. **Notify controllers:** if YouNew is processor, notify each affected Customer
   controller without undue delay and provide rolling updates.
5. **Legal assessment:** the controller assesses risk to rights/freedoms. Where
   reportable, GDPR notification is due without undue delay and, where feasible,
   within 72 hours of awareness. High-risk breaches may also require direct notice
   to affected people. Record the rationale even when no notification is made.
6. **Notify and communicate:** owner/counsel submits to the competent authority and
   approves user/customer communications. Do not speculate or include unnecessary PII.
7. **Recover:** fix forward, validate RLS/grants, restore only into disposable first,
   reconcile counts, rotate credentials and monitor recurrence.
8. **Close:** timeline, root cause, impact, decisions, notifications, corrective
   actions and owner sign-off; update tests/runbooks and provider review.

The Dutch DPA recommends a communicated internal breach workflow with a named
first contact, reporting period, responsibilities and internal register. This
draft supplies the workflow but is not evidence that staff training, an emergency
contact route or legal review has occurred.

## 7. Open privacy/DPA gaps

1. YouNew legal entity/address/registration and competent authority are not filled
   into the customer DPA.
2. No provider DPA acceptance/signature/account-plan evidence is stored here.
3. OpenAI Sites' no-residency-at-launch warning requires a transfer assessment for
   the actual public origin, or a hosting change before collecting form data there.
4. Hostinger product coverage, mail/log retention, region and subprocessor-change
   notice are unverified.
5. Customer employee lawful basis, works-council/transparency obligations and the
   employment-consent imbalance need Dutch legal review.
6. The public privacy page truthfully describes current production as manual
   retention; it must be updated only when the migration and schedule are actually
   deployed and approved.
7. A lead-specific DSR rehearsal is not yet included in this packet's runtime proof.
8. Provider backup expiry, support copies, infrastructure logs and deletion SLAs
   may exceed application defaults and must be reconciled.
9. No privacy notice/DPA should claim aggregate data is anonymous unless a qualified
   assessment confirms re-identification is not reasonably likely.

Final legal status: **PARTIAL / NO-GO for live employee usage processing until the
above gaps and owner/counsel review are closed.**
