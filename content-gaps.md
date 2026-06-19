# Content Gaps

Phase 2 did not add new factual production content. Empty or restricted areas are handled by hiding unavailable routes or showing a neutral empty state.

## Support Routes

### LGBTQ Support
- Current data source: `MockLGBTQSupportData.items`.
- Current gap: the route is persona-scoped to LGBT users.
- Required decision before changing content: confirm whether this screen should remain LGBT-only or become visible to more personas.
- Required source type for new content: verified official/community source already reviewed for production use.

### Emotional Support
- Current data source: inline `EmotionalSupportItem.items`.
- Current gap: support resources should be moved to structured data before expansion.
- Required source type for new content: verified official or service source. Do not add unverified crisis, medical, legal, or support contacts.

### Legal Help
- Current data source: inline `LegalHelpView` rows.
- Current gap: legal resources should be moved to structured data before expansion.
- Required source type for new content: verified legal/help source. Do not add unverified legal procedures, phone numbers, deadlines, or URLs.

## Image Assets

### Topic-specific visuals
- Current gap: several topics still share broad visual assets.
- Required source type for new images: existing bundled asset or verified `AppImageAsset` entry.
- Rule: do not use the Amsterdam canal photo as a generic fallback for unrelated topics.
