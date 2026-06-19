# Menu Redesign Report

Date: 2026-06-13

## Goal

Transform the More / side-menu experience from a plain navigation list into a useful Personal Guide Dashboard.

## Dashboard now includes

- Current city
- Weather prompt
- Emergency contact entry
- Saved items
- Documents
- Language learning
- Transport
- AI Assistant
- Recent activity
- Important deadlines
- Upcoming tasks

## Design changes

| Area | Before | After |
| --- | --- | --- |
| Hero | Generic guide/support entry | Still present, but followed by actionable dashboard |
| Navigation | Long list first | Context and urgent actions first |
| Emergency | Buried in list | Visible dashboard action |
| Documents | List-only | Dashboard action plus existing category entry |
| AI | Help row | Dashboard action and existing row |
| Deadlines/tasks | Not surfaced as a dashboard | Visible guidance panel |

## Files changed

- YouNew/Views/MoreHubView.swift

## Verification

- macOS generic build passed after menu changes.
- Runtime screenshot verification still needs to be done on the user's iPhone or simulator with available iOS runtime.

