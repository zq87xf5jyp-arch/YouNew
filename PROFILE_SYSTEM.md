# Persona Profile System

Date: 2026-06-16
Owner: Product / Engineering
Status: Target product and data model

## Purpose

The profile system controls what the user sees. It is not just onboarding decoration.

The active profile must drive:

- Home dashboard
- Checklist
- Search filtering
- AI context
- Recommendations
- Map service categories
- Official source priority
- Saved item organization
- Notifications and reminders

## Current Foundation

The app already has useful foundations:

- `UserStatus`: refugee, Ukrainian, student, worker, expat, family, tourist.
- `ProfileType`: worker, student, expat, refugee/status holder, temporary worker.
- `ProfileBlueprint`: priorities, documents, institutions, legal topics, warnings, onboarding flow, checklist filters.
- `UserProfile`: arrival status, municipality, work status, student status, priorities, BSN/DigiD/insurance/bank/address flags.

The target requires a clearer persona layer above these existing fields.

## Target Persona Model

```swift
enum Persona: String, Codable, CaseIterable, Identifiable {
    case student
    case worker
    case refugee
    case highlySkilledMigrant
    case euCitizen
    case family
    case tourist
    case entrepreneur
    case lgbtNewcomer
}
```

Recommended profile:

```swift
struct PersonaProfile: Codable, Equatable {
    var primaryPersona: Persona
    var secondaryPersonas: Set<Persona>
    var jurisdictionTags: Set<JurisdictionTag>
    var arrivalStatus: ArrivalStatus
    var timeInNL: TimeInNL
    var municipality: String?
    var preferredLanguage: AppLanguage
    var progress: PersonaProgress
    var privacyFlags: ProfilePrivacyFlags
}
```

Jurisdiction modifiers:

```swift
enum JurisdictionTag: String, Codable, CaseIterable, Hashable {
    case eu
    case nonEU
    case ukrainianTemporaryProtection
    case asylumSeeker
    case statusHolder
    case recognizedSponsor
    case unknown
}
```

Progress:

```swift
struct PersonaProgress: Codable, Equatable {
    var hasBSN: Bool
    var hasDigiD: Bool
    var hasRegisteredAddress: Bool
    var hasHealthInsuranceNL: Bool
    var hasBankAccountNL: Bool
    var completedChecklistItemIDs: Set<String>
    var completedGuideIDs: Set<String>
}
```

Privacy flags:

```swift
struct ProfilePrivacyFlags: Codable, Equatable {
    var hideLGBTContextOutsideSupport: Bool
    var allowAIProfileMemory: Bool
    var allowLocationPersonalization: Bool
}
```

## Migration From Current Statuses

| Current Field | Target Mapping |
|---|---|
| `UserStatus.student` | `Persona.student` |
| `UserStatus.worker` | `Persona.worker` |
| `UserStatus.refugee` | `Persona.refugee` plus jurisdiction tag `statusHolder` or `asylumSeeker` when known |
| `UserStatus.ukrainian` | `Persona.refugee` plus `ukrainianTemporaryProtection` |
| `UserStatus.expat` | Prefer `Persona.highlySkilledMigrant` when sponsor/employment context exists |
| `UserStatus.family` | `Persona.family` |
| `UserStatus.tourist` | `Persona.tourist` |
| Missing | Add `Persona.euCitizen` |
| Missing | Add `Persona.entrepreneur` |
| `LGBTQSupportView` only | Add `Persona.lgbtNewcomer` as primary or secondary persona |

## Profile Selection UX

First screen question:

Who am I?

Choices:

- Student
- Worker
- Refugee
- Highly Skilled Migrant
- EU Citizen
- Family
- Tourist
- Entrepreneur
- LGBT Newcomer

The screen must not start with topics like housing, healthcare, work, education, or documents.

## Context Questions By Persona

Student:

- Are you applying or enrolled?
- MBO, HBO, research university, exchange, or language course?
- Which city or school?
- EU or non-EU?

Worker:

- Employed, seeking work, or temporary worker?
- EU or non-EU?
- Do you already have BSN and DigiD?

Refugee:

- Asylum seeker, status holder, temporary protection, or unsure?
- Which municipality or reception location?
- Do you need urgent documents, housing, healthcare, or support?

Highly Skilled Migrant:

- Is your employer a recognized sponsor?
- Are you relocating with family?
- Do you need 30% ruling, housing, or registration first?

EU Citizen:

- Are you moving, already here, or visiting for a longer stay?
- Work, study, family, or housing first?
- Do you already have registration/BSN?

Family:

- Are children school age?
- Do you need school, childcare, benefits, healthcare, or housing first?
- Which municipality?

Tourist:

- Which city?
- How long are you staying?
- Emergency, transport, fines, healthcare, or lost documents?

Entrepreneur:

- Freelancer, ZZP, startup, company founder, or unsure?
- EU or non-EU?
- KvK, tax, permit, banking, or insurance first?

LGBT Newcomer:

- Safety, healthcare, community, legal support, or housing safety?
- Add this as a private secondary context?

## Dashboard Configuration

Each persona profile maps to a dashboard configuration:

```swift
struct PersonaDashboardConfig {
    let persona: Persona
    let title: String
    let primaryWidgets: [DashboardWidgetID]
    let quickActions: [AppDestination]
    let officialSourcePriority: [InstitutionType]
    let hiddenContentTags: Set<PersonaTag>
    let aiPromptSeeds: [String]
}
```

Widget rules:

- Student dashboard cannot include worker tax complexity or refugee bureaucracy.
- Worker dashboard cannot include DUO/student-life modules.
- Refugee dashboard cannot include unrelated student/worker/tourist modules.
- Family dashboard must prioritize children, benefits, healthcare, housing, and municipality.
- Tourist dashboard must avoid long-term resident setup by default.

## Search Behavior

Default:

```swift
results = allItems
    .filter { item.matches(activePersona) || item.isUniversalFor(activePersona) }
    .rank(query, context)
```

Explicit override:

```swift
results = allItems.rank(query, context)
showOutsidePathBadge = true
```

Ranking:

1. Exact persona match
2. Primary persona tag
3. Secondary persona match
4. Universal item relevant to query
5. Other persona item only after explicit override

## AI Behavior

AI receives:

- Primary persona
- Secondary personas
- Jurisdiction tags
- User progress
- Current screen
- Current route
- City/municipality
- Language
- Last searches
- Saved items
- Completed actions

AI must say when a topic is outside the current profile:

"This is outside your Student path. I can still show it, but it may not apply to you."

## Persistence

Persist:

- Primary persona
- Secondary personas
- Jurisdiction tags
- Municipality/city
- Progress flags
- Completed checklist and guide IDs
- Privacy flags

Do not persist without explicit consent:

- Sensitive free-text identity details
- Legal status descriptions beyond selected structured tags
- LGBT context outside the privacy rules
- Medical details
- Passport, BSN, residence card numbers, or similar identifiers

## Testing Requirements

Unit tests:

- Student content filter excludes worker/refugee-only items.
- Worker content filter excludes student-only items.
- Refugee content filter excludes tourist/student-only items.
- Family content filter prioritizes school/childcare/SVB.
- AI context contains active persona.
- Search results rank active-persona items first.
- Untagged content fails audit.

UI tests:

- First launch asks "Who am I?"
- Selecting Student opens Student Home.
- Selecting Worker opens Worker Home.
- Selecting Refugee opens Refugee Home.
- Switching profile changes Home widgets.
- AI prompt changes when profile changes.

## Acceptance Criteria

- User chooses identity before topic.
- Active persona is visible and changeable.
- Every persona has a distinct dashboard.
- Content, search, and AI share one profile model.
- Secondary personas support real-life complexity without collapsing the main path.
- Sensitive contexts are handled with privacy-aware defaults.
