# Full UI Redesign Report

Date: 2026-06-13

## Scope

Fixed the user-visible issues shown in the supplied runtime screenshots:

- History screen behaving like an image dump.
- Transport visual cards overlapping and leaking placeholder artwork.
- More / side menu feeling like a generic navigation list instead of a useful dashboard.
- Fallback image UI showing production-visible placeholder text.
- Information Hub using a gallery-like "Verified visuals" label.

## Screen-by-screen result

| Screen | Issue | Root cause | Fix |
| --- | --- | --- | --- |
| History | Oversized historical images and old gallery flow could dominate learning | History image registry was treated as broad media inventory | Main history flow now uses a curated teaching image set only |
| History | Narrative hierarchy weak | Timeline existed but old media pathways could still look archival | Kept period -> story -> facts -> figures -> optional image structure |
| Transport | OVpay/visual card overlap | Adaptive grid plus remote/fallback media made card sizing unstable | Replaced remote visual cards with fixed-size generated transport artwork |
| Transport | Gray/placeholder image blocks | Small cards depended on image loader fallback | Transport visual cards no longer use remote image fallback |
| Transport | Placeholder text visible | AppContentImageView fallback rendered "Visual reference" | Removed visible fallback text globally |
| More | Menu felt like a list | More screen lacked a personal dashboard layer | Added Personal Guide Dashboard with city, weather prompt, emergency, saved, documents, language, transport, AI, recent activity, deadlines, and tasks |
| Information Hub | "Verified visuals" sounded like another image gallery | Section title reinforced archive behavior | Renamed to "Media sources" and clarified purpose |

## Files changed

- YouNew/Views/NetherlandsHistoryView.swift
- YouNew/Data/HistoryMediaRegistry.swift
- YouNew/Views/TransportGuideView.swift
- YouNew/Components/AppContentImageView.swift
- YouNew/Views/MoreHubView.swift
- YouNew/Views/InformationHubView.swift

## Verification

- macOS generic build: PASS
- Swift compile errors after refactor: 0
- iOS simulator runtime verification: not performed in this environment because CoreSimulator runtimes are unavailable.

