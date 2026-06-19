# CONTENT TAGGING SYSTEM
## YouNew - Persona-Enforced Content Metadata

Version: 4.0
Date: 2026-06-16
Owner: Content Architecture / Search / AI / Recommendations
Status: Canonical

---

## 1. Mission

Every article, guide, checklist, service, map item, deadline, search result, AI source, and recommendation must declare who it is for.

Persona tags are enforcement, not decoration.

An untagged content item must not appear in:

- Home
- Default search
- AI answers
- Recommendations
- Deadlines
- Saved suggestions
- Notifications

---

## 2. Required Tags

Every content item must contain persona tags from this controlled set:

- Student
- Worker
- Refugee
- Family
- Tourist
- Entrepreneur
- LGBT
- EU
- Non-EU
- Highly Skilled Migrant
- Retired Person
- Universal

`Universal` is allowed only when content applies almost identically to all users, such as 112 emergency help. Do not use it to avoid a decision.

---

## 3. Required Metadata

```swift
struct ContentItem {
    let id: String
    let title: LocalizedString
    let summary: LocalizedString
    let body: LocalizedString?

    let canonicalPersona: PersonaTag
    let personaTags: Set<PersonaTag>
    let excludedPersonaTags: Set<PersonaTag>
    let secondaryPersonaAllowed: Bool

    let topicTags: Set<TopicTag>
    let city: String?
    let province: String?
    let country: String

    let sourceType: SourceType
    let officialSources: [OfficialSource]
    let officialSourceRequired: Bool
    let lastReviewed: Date
    let safetyLevel: SafetyLevel

    let visibilityPolicy: VisibilityPolicy
    let recommendedWhen: [RecommendationRule]
    let hiddenWhen: [VisibilityRule]
    let relatedContentIDs: [String]

    let aiContextSummary: String
    let aiAllowedForPersonas: Set<PersonaTag>
    let aiBlockedForPersonas: Set<PersonaTag>
}
```

---

## 4. Visibility Policies

```swift
enum VisibilityPolicy {
    case activePersonaOnly
    case activePersonaAndUniversal
    case secondaryPersonaModuleOnly
    case explicitSearchOnly
    case outsidePathWithWarning
    case officialDependency
    case emergencyUniversal
    case blocked
}
```

### Policy Rules

| Policy | Behavior |
|---|---|
| activePersonaOnly | Shows only when active persona matches |
| activePersonaAndUniversal | Shows for active persona plus true universal items |
| secondaryPersonaModuleOnly | Shows only in labeled secondary module |
| explicitSearchOnly | Hidden from Home/recommendations; can appear after direct search |
| outsidePathWithWarning | Appears with "usually for another persona" warning |
| officialDependency | Can cross personas only because the step is legally required |
| emergencyUniversal | Always available |
| blocked | Never show for the current persona |

---

## 5. Canonical Ownership

Each content item has one canonical persona. If the same topic needs different instructions for different people, create separate variants.

| Topic | Canonical Persona | Required Variants |
|---|---|---|
| DUO student finance | Student | None |
| Student housing | Student | None |
| Part-time student job | Student | Worker relation may be referenced |
| Employment contract | Worker | HSM variant if sponsored employment |
| UWV | Worker | Refugee work-permission references only |
| IND asylum/protection | Refugee | None |
| IND knowledge migrant | Highly Skilled Migrant | Non-EU worker context |
| KVK | Entrepreneur | None |
| SVB child benefits | Family | Worker+Family, Refugee+Family variants |
| Tourist attractions | Tourist | Student free-time variant only |
| BSN | Universal process with persona variants | Student, Worker, Refugee, HSM, Family, EU |
| DigiD | Universal process with persona variants | Student, Worker, Refugee, Family, EU |
| 112 emergency | Universal | All |
| LGBT rights/support | LGBT | Additive module for all personas |
| AOW/pension | Retired Person | Worker pension-awareness variant |

---

## 6. Persona Tag Examples

| Content | Tags | Excluded Tags | Policy |
|---|---|---|---|
| DUO student finance guide | Student | Worker, Refugee, Tourist, Entrepreneur | activePersonaOnly |
| University enrollment guide | Student | Worker, Refugee, Tourist | activePersonaOnly |
| Employment contract checklist | Worker | Student, Tourist | activePersonaOnly |
| Worker salary and tax guide | Worker | Student, Tourist, Refugee | activePersonaOnly |
| IND asylum status guide | Refugee, Non-EU | Student, Tourist, Entrepreneur | activePersonaOnly |
| Refugee housing support | Refugee | Tourist, Student, Entrepreneur | activePersonaOnly |
| Schools and childcare | Family | Tourist, Student unless secondary Family | activePersonaOnly |
| Tourist museums in Amsterdam | Tourist | Worker, Refugee, Entrepreneur | activePersonaOnly |
| KVK registration | Entrepreneur | Student, Refugee, Tourist | activePersonaOnly |
| 30% ruling | Highly Skilled Migrant, Worker, Non-EU | Tourist, Refugee | activePersonaOnly |
| LGBT discrimination help | LGBT | None | secondaryPersonaModuleOnly or activePersonaOnly |
| 112 emergency numbers | Universal | None | emergencyUniversal |

---

## 7. Search Ranking

Search must rank results in this order:

1. Active persona exact match
2. Active persona plus query/topic match
3. Current city match
4. Current province match
5. Official-source-backed content
6. Universal emergency or setup content
7. Secondary persona match
8. Explicit outside-path match with warning
9. Other-persona-only content excluded from default results
10. Untagged content excluded always

### Scoring Model

```swift
score =
    personaExactMatch * 1000
  + activePersonaTopicMatch * 500
  + cityMatch * 250
  + provinceMatch * 150
  + officialSourceBoost * 100
  + universalBoost * 50
  + secondaryPersonaBoost * 25
  - outsidePathPenalty * 300
  - excludedPersonaPenalty * 9999
  - untaggedPenalty * 9999
```

---

## 8. Recommendation Rules

Recommendations must be generated from:

- Active persona
- City
- Province
- Language
- Progress
- Recently searched topics
- Saved content
- Current screen

Recommendations must not be generated from raw popularity alone.

Example:

Student searches "housing" in Rotterdam:

1. Student housing in Rotterdam
2. University accommodation offices
3. Room.nl / DUWO / SSH where relevant
4. Municipality registration after moving
5. General rental rights only as supporting content

Worker housing must not outrank student housing.

---

## 9. Content QA Rules

Before release, every content item must pass:

- Has at least one persona tag
- Has canonical persona
- Has excluded personas where needed
- Has city/province scope
- Has source metadata
- Has official source if legal, tax, immigration, health, benefits, work rights, or emergency
- Has last reviewed date
- Has AI eligibility rules
- Does not appear in unrelated persona home

Failing content is quarantined from Home, AI, recommendations, and default search.
