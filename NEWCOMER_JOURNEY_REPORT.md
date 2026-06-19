# Newcomer Journey Report

Date: 2026-06-11

Goal: A newcomer can find Housing, Work, Healthcare, Emergency, Transport, and Documents within 3 taps from Home.

## Static Journey Map

| Need | Path From Home | Tap Count | Status |
| --- | --- | ---: | --- |
| Housing | Home -> Categories / Help & Life -> Housing | 2 | Pass static |
| Work | Home -> Categories / Help & Life -> Work | 2 | Pass static |
| Healthcare | Home -> Categories / Help & Life -> Health | 2 | Pass static |
| Emergency | Home -> Emergency or Categories -> Emergency | 1-2 | Pass static |
| Transport | Home -> Categories / Help & Life -> Transport | 2 | Pass static |
| Documents | Home -> Documents or Categories -> Documents | 1-2 | Pass static |

## Fixes Applied

| Journey | Problem | Fix |
| --- | --- | --- |
| Documents | Key actions did not move to relevant sections | Added scroll-to-section behavior |
| Saved follow-up journeys | Saved hub destinations could lose route after persistence | Added missing saved destination mappings |
| Onboarding to main product | Missing image asset references could degrade first-run screens | Replaced with bundled assets |

## Remaining Manual QA

Runtime must verify that Home visible ordering actually keeps these journeys within 3 taps on:
- new install,
- existing user with saved city,
- Russian, Dutch, and English language settings,
- iPhone SE.

Static result: pass. Runtime result: not available.
