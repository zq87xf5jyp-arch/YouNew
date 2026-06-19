# PERSONALIZED HOME SYSTEM
## YouNew - Persona-Specific Dashboard Architecture

Version: 4.0
Date: 2026-06-16
Owner: Product Architecture / UX Architecture / Service Design
Status: Canonical

---

## 1. Mission

Home is not a content library.

Home is the user's personal life dashboard.

There is no generic Home. YouNew has persona homes:

- Student Home
- Worker Home
- Refugee Home
- EU Citizen Home
- Highly Skilled Migrant Home
- Entrepreneur Home
- Family Home
- Tourist Home
- LGBT Newcomer Home
- Retired Person Home

Each home has different widgets, actions, recommendations, deadlines, search prompts, map shortcuts, and AI starter prompts.

---

## 2. Home Rule

Home shows only what matters to the active persona right now.

Home must not show:

- Generic category grids
- Mixed-persona recommendation feeds
- Long article dumps
- Another persona's deadlines
- Another persona's bureaucracy
- Untagged content
- Cross-persona content without a clear label

---

## 3. Common Home Structure

Each persona home follows the same structural pattern but uses different content.

```text
Persona Header
Top Next Actions
Important Documents
Official Source Shortcuts
Upcoming Deadlines
Persona Widgets
Local Services in {city}
Saved Items
AI Prompt
Secondary Persona Module, if selected
Switch Persona
```

---

## 4. Widget Schema

```swift
struct HomeWidgetSpec {
    let id: String
    let title: LocalizedString
    let subtitle: LocalizedString?
    let personaTags: Set<PersonaTag>
    let excludedPersonaTags: Set<PersonaTag>
    let destination: AppDestination
    let iconName: String
    let priority: Int
    let cityRelevance: CityRelevance
    let progressRule: ProgressRule
    let officialSourceRequired: Bool
    let hideWhenCompleted: Bool
    let aiStarterPrompt: String?
}
```

---

## 5. Student Home

Purpose: study, registration, finance, student housing, and student life.

### Widgets

1. Municipality Registration
2. BSN
3. DigiD
4. Universities
5. HBO
6. MBO
7. Research Universities
8. DUO
9. Student Finance
10. Scholarships
11. Student Housing
12. Student Insurance
13. Dutch Courses
14. Libraries
15. Study Spaces
16. Part-Time Jobs
17. Student Discounts
18. Student Communities
19. Student Events
20. Free Time
21. Sports
22. Culture
23. Nightlife
24. Student Transport

### Hidden

- UWV reintegration
- Worker benefits
- Entrepreneur taxes
- Refugee procedures

### AI Starters

- Help me find student housing in {city}.
- What do I need before my studies start?
- How do I apply for DUO student finance?

---

## 6. Worker Home

Purpose: legal work setup, employment confidence, tax, rights, insurance, housing, and career.

### Widgets

1. BSN
2. DigiD
3. Employment Contracts
4. Salary
5. Taxes
6. UWV
7. Health Insurance
8. Housing
9. Transport
10. Pension
11. Labor Rights
12. Training
13. Career Development

### Hidden

- Student finance
- University guides
- Student communities
- Refugee asylum procedure

### AI Starters

- Can you check what I should look for in my employment contract?
- What taxes should I understand as a worker?
- What should I arrange before my first workday?

---

## 7. Refugee Home

Purpose: legal stability, municipality support, housing, benefits, healthcare, language, integration, work permissions, and trusted help.

### Widgets

1. IND
2. Municipality
3. Housing
4. Benefits
5. Integration
6. Healthcare
7. Language
8. Education Access
9. Work Permissions
10. Support Organizations
11. Legal Help

### Hidden

- Tourist attractions
- Worker tax optimization
- Student nightlife
- Entrepreneur taxes

### AI Starters

- What is my next step with IND?
- Where can I get refugee support in {city}?
- Can I work while my procedure is ongoing?

---

## 8. Family Home

Purpose: household settlement, schools, childcare, child benefits, healthcare, housing, and activities.

### Widgets

1. Municipality Services
2. Schools
3. Childcare
4. Kinderopvang
5. SVB
6. Child Benefits
7. Healthcare
8. Family Housing
9. Activities

### Hidden

- Student finance
- Tourist hotel feeds
- Solo worker career content unless Worker is secondary
- Entrepreneur-only tax workflows

### AI Starters

- How do I find a school for my child in {city}?
- How does kinderopvang work?
- What child benefits can families apply for?

---

## 9. Tourist Home

Purpose: visiting, moving around, finding places, enjoying culture, and staying safe.

### Widgets

1. Cities
2. Attractions
3. Transport
4. Hotels
5. Events
6. Museums
7. Food
8. Safety
9. Emergency Numbers

### Hidden

- BSN setup
- DigiD setup
- DUO
- UWV
- SVB
- IND residence procedures
- Long-term housing
- Tax registration

### AI Starters

- What should I do in {city} today?
- How do I use public transport as a tourist?
- What emergency numbers should I know?

---

## 10. EU Citizen Home

Purpose: register, live, work, arrange documents, insurance, housing, and tax.

Widgets: Registration, BSN, DigiD, Health Insurance, Work Rights, Housing, Taxes, Transport, Municipality Services.

---

## 11. Highly Skilled Migrant Home

Purpose: sponsor-based relocation, IND, salary threshold, 30% ruling, housing, insurance, family setup.

Widgets: Recognized Sponsor, IND Permit, Salary Threshold, Employment Contract, BSN, DigiD, 30% Ruling, Housing, Health Insurance, Family Relocation.

---

## 12. Entrepreneur Home

Purpose: start and operate a business.

Widgets: KVK, Business Structure, VAT/BTW, Income Tax, Permits, Banking, Insurance, Hiring Basics, Municipality Rules, Workspace, Networking.

---

## 13. LGBT Newcomer Home

Purpose: safety, rights, trusted support, healthcare, community, and reporting discrimination.

Widgets: Safety, LGBT Rights, COC/Support Organizations, Discrimination Reporting, Safe Healthcare, Mental Health, Community, Legal Help, Safe Housing.

When LGBT is secondary, this becomes a compact module inside the active primary home.

---

## 14. Retired Person Home

Purpose: healthcare, pension, housing, local services, transport, social activities, and support.

Widgets: Registration, BSN/DigiD, Health Insurance, GP/Pharmacy, Pension/AOW, Tax Basics, Housing, Transport, Municipality Services, Social Activities, Emergency Help.

---

## 15. Recommendation Rules

Home recommendations rank:

1. Persona relevance
2. Progress urgency
3. City relevance
4. Province relevance
5. Official-source importance
6. Saved/recent-search continuity
7. General usefulness

Home recommendations must never rank another persona's content above active persona content.

---

## 16. Home Acceptance Criteria

The home system passes when:

- Student Home feels built for students.
- Worker Home feels built for workers.
- Refugee Home feels built for refugees.
- Family Home feels built for families.
- Tourist Home feels built for tourists.
- Every widget has persona tags.
- Every recommendation is persona scoped.
- AI starter prompts inherit persona and city.
- Irrelevant content is hidden by default.
