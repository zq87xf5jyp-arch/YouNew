# AI Rendering Audit

Date: 2026-06-16

## Message Identity

Before:
- User and assistant messages were separate append-only records.
- The renderer used `ForEach(visibleMessages)` over every message, so any duplicate assistant append rendered another answer card.

After:
- `AIMessage` includes `replyToMessageID`.
- Assistant replies are explicitly linked to the user question they answer.
- The view still renders messages with stable `Identifiable` IDs, but the model now prevents multiple assistant replies for the same user message.

## State Updates

Before:
- Workflow, local composer, cache, and service response branches each called response append logic independently.
- Structured response cache was keyed by assistant message ID only.

After:
- All response branches call `applyAIResponse(... replyingTo:)`.
- `appendAssistantMessage` removes any existing assistant reply for the same user message before appending the replacement.
- Removed structured response entries are cleared when duplicate replies are removed.

## Streaming / Retry / Cache

Current behavior:
- Streaming is represented as request loading state, not incremental text chunks.
- Cancel clears active request ownership.
- Retry removes the last user message and sends a fresh owned request.
- Cache responses write through the same answer upsert path as fresh responses.

## Rendering Pass Criteria

- Duplicate answer cards: fixed at model/write path.
- Duplicate message rendering: prevented for assistant replies by ownership upsert.
- Reused answer state: stale structured response entries are removed with duplicate replies.

