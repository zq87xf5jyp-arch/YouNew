# PERSONA SYSTEM
## YouNew - Persona-First Product Architecture

Version: 4.0
Date: 2026-06-16
Owner: Product Architecture / Information Architecture / Government Services Design
Status: Canonical

---

## 1. Mission

YouNew must behave like a personal life guide, not a document dump.

The app starts with one question:

**Who am I?**

It does not start with:

**What topic do I want?**

Persona is the primary organizing principle for onboarding, home, navigation, search, recommendations, AI answers, saved content, and progress. Topics are secondary filters inside a persona path.

---

## 2. Core Rule

Every user must have an active persona before seeing the main experience.

```
Launch -> Who am I? -> Where am I? -> Language -> Persona Home
```

No generic dashboard may be shown before persona selection.
No category library may be the first experience.
No mixed-persona recommendation list may appear by default.

---

## 3. Primary Personas

| Persona | Product Intent |
|---|---|
| Student | Study, register, finance, find student housing, build student life |
| Worker | Work legally, understand contract, salary, tax, rights, insurance, housing |
| Refugee | Stabilize status, municipality support, housing, benefits, healthcare, integration |
| EU Citizen | Register, work/live freely, arrange documents, insurance, tax, housing |
| Highly Skilled Migrant | Sponsor/IND process, 30% ruling, relocation, work, family setup |
| Entrepreneur | Start and operate a business, KVK, taxes, permits, banking, insurance |
| Family | Schools, childcare, SVB, benefits, healthcare, family housing, activities |
| Tourist | Visit safely, move around, find cities, attractions, hotels, food, emergency help |
| LGBT Newcomer | Safety, rights, community, healthcare, discrimination support, trusted spaces |
| Retired Person | Healthcare, pension, residence, housing, municipality services, daily life |

---

## 4. Persona Selection Model

### Required Onboarding Questions

1. Who am I?
2. Where am I or where am I going?
3. What language should YouNew use?
4. Do I have a secondary situation? Optional.

### Primary Persona

The primary persona controls:

- Home screen
- Default search ranking
- AI answer scope
- Recommendations
- Deadlines
- Progress checklist
- Saved content grouping
- Navigation shortcuts
- Notification eligibility

### Secondary Persona

A secondary persona is additive and must never override the primary dashboard.

Examples:

- Student + LGBT: student home with LGBT safety/community module
- Worker + Family: worker home with schools, childcare, SVB module
- Refugee + Family: refugee home with family settlement module
- Highly Skilled Migrant + Family: HSM home with partner/children relocation module

Secondary content appears in a clearly labeled module and may not flood the main feed.

---

## 5. Persona Boundaries

### Student

Show only:

- Universities
- HBO
- MBO
- Research Universities
- DUO
- Student Housing
- Student Finance
- Scholarships
- Student Insurance
- Dutch Courses
- Libraries
- Study Spaces
- Part-Time Jobs
- Student Discounts
- Student Communities
- Student Events
- Free Time
- Sports
- Culture
- Nightlife
- Municipality Registration
- BSN
- DigiD
- Student Transport

Hide by default:

- UWV reintegration
- Worker benefits
- Entrepreneur taxes
- Refugee procedures
- Pension/AOW
- Generic tourist itineraries
- Child benefits unless Family is secondary

### Worker

Show only:

- BSN
- DigiD
- Employment Contracts
- Taxes
- UWV
- Health Insurance
- Housing
- Salary
- Transport
- Pension
- Labor Rights
- Training
- Career Development

Hide by default:

- Student finance
- University guides
- Campus communities
- Refugee asylum procedures
- Tourist attraction feeds

### Refugee

Show only:

- IND
- Municipality
- Housing
- Benefits
- Integration
- Healthcare
- Language
- Education Access
- Work Permissions
- Support Organizations
- Legal Help

Hide by default:

- Tourist attractions
- Student nightlife
- Worker tax optimization
- Entrepreneur KVK/tax workflows
- Highly skilled migrant sponsor content

### Family

Show only:

- Schools
- Childcare
- Kinderopvang
- SVB
- Child Benefits
- Healthcare
- Family Housing
- Activities
- Municipality Services

Hide by default:

- Student finance
- Solo worker career feeds
- Tourist hotel feeds
- Entrepreneur-only tax workflows

### Tourist

Show only:

- Cities
- Attractions
- Transport
- Hotels
- Events
- Museums
- Food
- Safety
- Emergency Numbers

Hide by default:

- BSN setup unless explicitly searched
- DigiD setup unless explicitly searched
- DUO
- UWV
- SVB
- IND residence procedures
- Long-term housing
- Tax registration

### EU Citizen

Show only:

- Registration
- BSN
- DigiD
- Health Insurance
- Work Rights
- Housing
- Taxes
- Transport
- Municipality Services
- Family add-ons when relevant

### Highly Skilled Migrant

Show only:

- IND knowledge migrant route
- Recognized sponsor
- Residence permit
- BSN
- DigiD
- 30% ruling
- Employment contract
- Salary threshold
- Housing
- Health insurance
- Family relocation if applicable

### Entrepreneur

Show only:

- KVK
- Business structure
- VAT/BTW
- Income tax
- Permits
- Banking
- Insurance
- Hiring basics
- Municipality rules
- Workspace and networking

### LGBT Newcomer

LGBT is usually an additive persona layer. It may also be primary when safety/community is the user's main need.

Show only:

- LGBT rights
- COC and support organizations
- Discrimination reporting
- Safe healthcare
- Mental health support
- Community events
- Legal help
- Safe housing guidance

### Retired Person

Show only:

- Residence/registration
- Healthcare
- GP and pharmacy
- Pension/AOW
- Tax basics
- Housing
- Municipality services
- Transport
- Social activities
- Emergency support

---

## 6. Navigation Rules

Persona Home is the start of the app.

Global navigation may include:

- Home
- Search
- Map
- Saved
- AI
- More

The More/library area is allowed, but it must be filtered by persona first. A user can intentionally browse outside their persona only after selecting a visible "Show other life situations" control.

---

## 7. Cross-Persona Access

Cross-persona content is allowed only in these cases:

1. Official dependency: the user must complete the step even if it belongs to another domain.
2. Secondary persona: the user explicitly added another situation.
3. Explicit search: the user searches for a term outside their persona.
4. Emergency: safety-critical information applies to everyone.

When content is outside the active path, show a label:

`This is usually for workers, not students.`

---

## 8. Product Acceptance Criteria

The persona system passes when:

- A student immediately sees student setup, DUO, housing, study, and student life.
- A worker immediately sees BSN, DigiD, contract, salary, tax, UWV, insurance, housing, rights.
- A refugee immediately sees IND, municipality, housing, benefits, healthcare, language, integration, support.
- A family immediately sees schools, childcare, SVB, child benefits, healthcare, housing, activities.
- A tourist immediately sees travel, attractions, hotels, museums, food, safety, emergency numbers.
- No persona sees another persona's bureaucracy by default.
- AI, search, recommendations, saved items, and deadlines all respect active persona.
