# Route / Action Sanity Report

Last prepared: 2026-06-01

This report freezes the visible navigation surface for local iOS runtime QA. Every item below is expected to open a real destination. If runtime QA finds any item opening a dead route, `Content not found`, or no action, mark runtime QA as failed and fix before TestFlight.

## Bottom Tab Items

| Visible label | Route/action | Destination exists |
|---|---|---|
| Home | `.home` | yes |
| Search | `.searchList` | yes |
| Map / Help nearby | `.map` / map focus routes | yes |
| Saved | `.saved` | yes |
| More | opens right-side menu | yes |

## Right-Side Menu Items

| Visible label | Route/action | Destination exists |
|---|---|---|
| Home | `.home` | yes |
| Search | `.searchList` | yes |
| Map / Help nearby | `.map` | yes |
| Saved | `.saved` | yes |
| Cities | `.cityList` | yes |
| Provinces | `.provinceList` | yes |
| Information Hub | `.informationHub` | yes |
| First Steps | `.firstSteps` | yes |
| KNM | `.knm` | yes |
| Dutch A1-A2 | `.dutchA1A2` | yes |
| Municipality registration | `.practicalGuide(.municipalityRegistration)` | yes |
| DigiD safety | `.practicalGuide(.digidSafety)` | yes |
| Healthcare basics | `.practicalGuide(.healthcareBasics)` | yes |
| Transport | `.practicalGuide(.transportBasics)` / transport guide | yes |
| Housing | `.practicalGuide(.housingBasics)` | yes |
| Official Sources | `.officialSources` | yes |
| Culture & Attractions | `.cultureAttractions` | yes |
| History of the Netherlands | `.netherlandsHistory` | yes |
| Settings / Language | settings/language route | yes |
| About | about route | yes |

## Quick Route Chips

| Visible label | Route/action | Destination exists |
|---|---|---|
| Open map | `.mapFocus(...)` | yes |
| Official sources | `.officialSources` | yes |
| Learn words | `.dutchA1A2Module(...)` | yes |
| Source open button | external official/source URL | yes |

## Information Hub Cards

| Visible label | Route/action | Destination exists |
|---|---|---|
| First steps in the Netherlands | `.firstSteps` | yes |
| KNM | `.knm` | yes |
| Dutch A1-A2 | `.dutchA1A2` | yes |
| Search knowledge | `.searchList` | yes |
| New in the Netherlands | `.firstSteps` | yes |
| Moving to a new city | `.practicalGuide(.municipalityRegistration)` | yes |
| Need healthcare | `.practicalGuide(.healthcareBasics)` | yes |
| Need transport | `.practicalGuide(.transportBasics)` | yes |
| Municipality registration | `.practicalGuide(.municipalityRegistration)` | yes |
| DigiD safety | `.practicalGuide(.digidSafety)` | yes |
| Health insurance basics | `.practicalGuide(.healthInsuranceBasics)` | yes |
| Finding a huisarts | `.practicalGuide(.findingHuisarts)` | yes |
| Transport basics | `.practicalGuide(.transportBasics)` | yes |
| Housing basics | `.practicalGuide(.housingBasics)` | yes |
| Official sources checklist | `.practicalGuide(.officialSourcesChecklist)` | yes |
| Cities | `.cityList` | yes |
| Provinces | `.provinceList` | yes |
| Culture & Attractions | `.cultureAttractions` | yes |
| History of the Netherlands | `.netherlandsHistory` | yes |
| Official sources | `.officialSources` | yes |

## Search Result Types

| Visible result type | Route/action | Destination exists |
|---|---|---|
| Practical guide answer | `.practicalGuide(...)` or `.searchAnswer(...)` | yes |
| City result | `.cityInfo(...)` / `.cityDetail(...)` | yes |
| Province result | `.provinceDetail(...)` | yes |
| KNM main result | `.knm` | yes |
| KNM module result | `.knmModule(...)` | yes |
| Dutch A1-A2 main result | `.dutchA1A2` | yes |
| Dutch A1-A2 module result | `.dutchA1A2Module(...)` | yes |
| Transport result | `.practicalGuide(.transportBasics)` / transport guide | yes |
| Official source result | `.officialSources` or source sheet/open URL | yes |
| Culture article result | `.cultureAttractions` / article detail | yes |
| History result | `.netherlandsHistory` | yes |

## Practical Guide Cards

| Visible label | Route/action | Destination exists |
|---|---|---|
| First steps in the Netherlands | `.firstSteps` / `.practicalGuide(.firstStepsNetherlands)` | yes |
| Municipality registration | `.practicalGuide(.municipalityRegistration)` | yes |
| Healthcare basics | `.practicalGuide(.healthcareBasics)` | yes |
| Finding a huisarts | `.practicalGuide(.findingHuisarts)` | yes |
| Health insurance basics | `.practicalGuide(.healthInsuranceBasics)` | yes |
| DigiD safety | `.practicalGuide(.digidSafety)` | yes |
| Transport basics | `.practicalGuide(.transportBasics)` | yes |
| Housing basics | `.practicalGuide(.housingBasics)` | yes |
| Official sources checklist | `.practicalGuide(.officialSourcesChecklist)` | yes |
| Banking basics | `.practicalGuide(.bankingBasics)` | yes |

## KNM Module Routes

| Visible label | Route/action | Destination exists |
|---|---|---|
| Housing / Wonen / Жильё | `.knmModule("housing")` | yes |
| Work and income / Werk en inkomen / Работа и доход | `.knmModule("work-income")` | yes |
| Health / Gezondheid / Здоровье | `.knmModule("health")` | yes |
| Education and upbringing / Onderwijs en opvoeding / Образование и дети | `.knmModule("education-upbringing")` | yes |
| Government and institutions / Instanties en overheid / Государство и организации | `.knmModule("government-institutions")` | yes |
| Norms, values, and society / Normen, waarden en samenleving / Нормы, ценности и общество | `.knmModule("norms-values")` | yes |
| Transport / Vervoer / Транспорт | `.knmModule("transport")` | yes |
| Safety / Veiligheid / Безопасность | `.knmModule("safety")` | yes |
| Free time, culture, and participation / Vrije tijd, cultuur en participatie / Досуг, культура и участие | `.knmModule("free-time")` | yes |
| Money matters / Geldzaken / Деньги и платежи | `.knmModule("money")` | yes |

## Dutch A1-A2 Module Routes

| Visible label | Route/action | Destination exists |
|---|---|---|
| Start / Basics / Start en basis / Старт и основы | `.dutchA1A2Module("basics")` | yes |
| Personal information / Persoonlijke gegevens / Личная информация | `.dutchA1A2Module("personal-info")` | yes |
| City and municipality / Stad en gemeente / Город и муниципалитет | `.dutchA1A2Module("municipality")` | yes |
| Housing / Wonen / Жильё | `.dutchA1A2Module("housing")` | yes |
| Transport / Vervoer / Транспорт | `.dutchA1A2Module("transport")` | yes |
| Healthcare / Gezondheid / Здоровье | `.dutchA1A2Module("healthcare")` | yes |
| Work and income / Werk en inkomen / Работа и доход | `.dutchA1A2Module("work-income")` | yes |
| Shopping and services / Winkels en diensten / Магазины и услуги | `.dutchA1A2Module("shopping-services")` | yes |
| Time and appointments / Tijd en afspraken / Время и встречи | `.dutchA1A2Module("time-appointments")` | yes |
| A1-A2 grammar / A1-A2 grammatica / Грамматика A1-A2 | `.dutchA1A2Module("grammar")` | yes |

## Static Rule

Static QA must fail if this report is missing or contains:

- a negative destination-exists marker,
- unfinished implementation markers,
- prototype availability text.
