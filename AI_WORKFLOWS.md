# AI Workflows

## Purpose

Workflows turn the assistant from an answer generator into a guided decision system. A workflow is required when the correct route depends on facts not yet known from `AIContext`.

## Current Engine

Current implementation:

- file: `YouNew/Services/AIWorkflowEngine.swift`
- model: `YouNew/Models/AIWorkflow.swift`
- state holder: `AIViewModel.activeWorkflow`

Current supported workflow starts:

- health insurance
- DigiD
- BSN registration
- fine or government letter
- housing
- what next

## Workflow Contract

Each workflow must define:

- trigger query patterns
- required context fields
- questions
- answer choices
- state transitions
- final retrieval query
- final destination candidates
- official source requirements
- safe fallback

Required shape:

```swift
struct WorkflowDefinition {
    let kind: AIWorkflowKind
    let triggers: [String]
    let requiredFacts: [WorkflowFact]
    let steps: [WorkflowStepDefinition]
    let finalRetrievalQuery: (AIWorkflow, AIContext) -> String
    let fallbackDestination: AppDestination
}
```

## Current High-Value Workflows

### Health Insurance

Trigger examples:

- health insurance
- zorgverzekering
- insurance
- huisarts insurance

Current flow:

1. Ask: Do you work in the Netherlands?
2. Ask: Are you registered at a municipality and do you have BSN?
3. Retrieve: health insurance, huisarts, zorgtoeslag, or municipality registration depending on answers.

Required final actions:

- Open Health Insurance Guide
- Open Healthcare Guide
- Open Official Source
- Open City
- Open Province
- Save
- Share

### BSN Registration

Trigger examples:

- BSN
- get BSN
- municipality registration
- register at gemeente

Current flow:

1. Ask: Do you already have a fixed address in the Netherlands?
2. Ask: Do you want to set up DigiD after BSN?
3. Retrieve: BSN, municipality registration, documents, DigiD as needed.

Required final actions:

- Open Government Hub
- Open Documents
- Open BSN Guide
- Open Official Source
- Related Topic: DigiD
- Save
- Share

### DigiD

Trigger examples:

- DigiD
- government login
- official login

Current flow:

1. Ask: Do you already have a BSN?
2. If yes, retrieve DigiD safety and official source.
3. If no, retrieve BSN and municipality registration first.

Required final actions:

- Open DigiD/official source
- Open Government Hub
- Open BSN guide when BSN missing
- Save
- Share

### Fine Or Government Letter

Trigger examples:

- CJIB
- fine letter
- tax letter
- unknown sender
- government letter

Current flow:

1. Ask: What type of letter did you receive?
2. Choices:
   - Fine or CJIB
   - Tax letter
   - Unknown sender
3. Retrieve relevant official letter, fine, deadline, scam warning, and official source content.

Required final actions:

- Open Letters
- Open Fines
- Open Official Source
- Related Topic: scam warning
- Save
- Share

### Housing

Trigger examples:

- housing
- rent
- rental problem
- registration issue
- deposit

Current flow:

1. Ask: Which housing situation fits you?
2. Choices:
   - Looking for housing
   - Rental problem
   - Registration issue
3. Retrieve housing, rent, registration, deposit, legal help, and municipality content.

Required final actions:

- Open Housing Guide
- Open City
- Open Province
- Open Official Source
- Related Topic: rental rights
- Save
- Share

### What Next

Trigger examples:

- what should I do next
- next safest step
- guide me

Current flow:

1. Use context, checklist progress, completed guides, saved items, selected city/province, and recent routes.
2. Recommend the next safe app action.

Required final actions:

- Open recommended screen
- Open current city/province if relevant
- Save
- Share
- Related Topic

## Required New Workflows

### Municipality Registration

Questions:

1. Do you have an address where registration is allowed?
2. Are you staying longer than four months?
3. Do you already have an appointment with the gemeente?

Final retrieval:

- municipality registration
- BRP
- BSN
- documents
- selected city municipality

### Healthcare Navigation

Questions:

1. Is it an emergency?
2. Are you registered with a huisarts?
3. Do you have health insurance?

Final retrieval:

- emergency
- huisarts
- health insurance
- urgent care
- selected city healthcare places

### Benefits And Allowances

Questions:

1. Are you registered and do you have BSN/DigiD?
2. Which benefit: healthcare allowance, rent allowance, childcare, unemployment?
3. Do you want official source only?

Final retrieval:

- toeslagen
- Belastingdienst
- UWV
- official source

### Taxes

Questions:

1. Did you receive a tax letter?
2. Are you employed, self-employed, or student?
3. Is there a deadline on the letter?

Final retrieval:

- tax letter
- Belastingdienst
- deadlines
- official sources

### Transport Fine

Questions:

1. Was it train, tram, metro, bus, car, bicycle, or parking?
2. Did you receive a letter or on-the-spot fine?
3. Is there an objection deadline?

Final retrieval:

- transport
- fines
- CJIB
- rules
- official source

## Workflow UI Requirements

Workflow questions must render as action chips/buttons, not only text.

Button requirements:

- visible choice label
- stable query payload
- localized label
- no sensitive data requested
- no free text required for yes/no steps

Workflow answers must preserve:

- active workflow kind
- current step
- collected facts
- context snapshot
- user language

## Safety Rules

- Do not request BSN, passport number, address, payment codes, or document numbers.
- For legal, medical, immigration, benefits, tax, fines, or emergency topics, always show official source action.
- For emergencies, prioritize emergency route and 112 guidance before normal workflows.
- For missing verified content, stop and use unverified fallback.

## Workflow Completion Criteria

A workflow is complete when:

- all required facts are collected or safely defaulted
- final retrieval query returns verified results
- final answer includes sections and quick actions
- destination ID resolves
- official sources exist for sensitive flows
- workflow state is cleared from `AIViewModel`

## Tests

Required tests:

- workflow starts for trigger phrases in English, Dutch, and Russian where supported
- yes/no answers advance the correct state
- invalid answers do not corrupt workflow state
- final response has destination ID
- final response has quick actions
- sensitive workflows have official source
- workflow persistence survives app restart
- stale workflow can be cancelled or replaced by a new explicit query
