# Newcomer Places Data

Date: 2026-05-29

## Categories added

- municipality
- bsnRegistration
- languageLearning
- library
- healthcare
- hospital
- legalHelp
- transport
- police
- emergency
- community
- family
- student
- work
- uwv
- taxes
- lgbtq
- housing
- documents

## Priority city coverage

Amsterdam, Leiden, Rotterdam, Den Haag, Utrecht, Eindhoven, Groningen, and Maastricht receive rich reusable `NewcomerPlace` records. The Nearby Help screen is generated from the same records so city detail and map/help content stay aligned.

## Source status

Verified/linked records include official municipality websites when present, Government.nl, DigiD, UWV, Juridisch Loket, selected official transport/library domains, and discriminatie.nl.

Reference-only/general guide records include hospital landmark orientation and community/newcomer orientation. They avoid exact addresses, hours, and phone numbers.

## Remaining risks

- Some official website paths are top-level domains rather than deep appointment pages.
- Local support programs can change frequently and require manual verification before adding exact names, addresses, hours, or eligibility wording.
- Map cards use city-level reference queries, not calculated distance. The UI must not show fake distance for these records.
