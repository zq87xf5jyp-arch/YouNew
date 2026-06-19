# Localization Purge Report

Date: 2026-06-14

## Release Language

Release mode is English.

## Fixes Applied

| Area | File | Fix |
|---|---|---|
| App language selection | `YouNew/Models/LanguageManager.swift` | Release language is forced to English; runtime language changes store English unless DEBUG UI testing overrides it. |
| Preferred language | `YouNew/Models/AppLanguage.swift` | `preferredSupported` returns English. |
| Model-driven mistakes | `YouNew/Models/NewcomerMistake.swift` | Implicit title/body accessors now prefer English before Russian. |
| Model-driven checklist items | `YouNew/Models/ChecklistItem.swift` | Implicit title/description/timing accessors now prefer English before Russian. |
| More visible profile/account area | `YouNew/Views/MoreHubView.swift` | Main More path no longer exposes mixed/internal profile rows. |

## Intentional Proper Nouns

Official names remain unchanged where appropriate: IND, DUO, UWV, Belastingdienst, OV-chipkaart, DigiD.

## Remaining Risk

Russian and Dutch localization files remain in the project for future multilingual support. They are not selected by release runtime because the language manager forces English.

