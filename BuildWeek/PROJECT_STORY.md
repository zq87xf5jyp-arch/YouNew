# YouNew: From “Where Do I Start?” to a Clear Next Step

Moving to a new country rarely creates one isolated question. Registering with a
municipality affects access to a BSN; a BSN unlocks DigiD; DigiD connects to more
services; healthcare, housing, transport, work, and local administration each add
their own dependencies. Useful information exists, but it is spread across
institutions, municipalities, and websites.

YouNew began with a simple product idea: newcomers need more than search results.
They need an understandable sequence, a safe next action, and a direct path to the
relevant source.

## A practical companion for life in the Netherlands

YouNew brings structured guides, local discovery, saved items, checklists, search,
official-source actions, and an interactive Netherlands map into one native iOS
experience. Its local-first design keeps the documented Build Week journey
available without an API key or deployed backend.

The clearest example begins with a person who has just received an address and
does not know what comes next. Using the supported newcomer prompt, YouNew orders
municipal registration and BSN, DigiD, health insurance, and finding a huisarts,
then continues into the BSN guide and a named official-source action. What starts
as an uncertain life moment becomes an understandable sequence.

This experience is intentionally described for what it is: a deterministic local
guided assistant backed by structured workflows and indexed YouNew knowledge. It
is not presented as live GPT-5.6 inference, a generative answer, official advice,
or a government service.

## Turning content into a product system

Newcomer information changes, overlaps, and often depends on personal
circumstances. YouNew therefore treats content as governed product data rather
than unstructured copy. Versioned records, stable identifiers, release states,
migrations, validation rules, and a deterministic runtime import connect the same
content to Guide, Search, the assistant, Home, Places, and Map.

The governed `cities-v0.1.0` release demonstrates that approach with Amsterdam,
Rotterdam, Den Haag, Utrecht, and Eindhoven. The map then makes those places
explorable through a custom SwiftUI surface with province geometry, labels, city
markers, selection, zoom, pan, and typed navigation.

## The Build Week decision: finish the experience that already works

The candidate preparation deliberately focuses on the existing product instead of
inventing a last-minute AI architecture. The submission story is the coherent
experience already present in the repository:

1. Start with the newcomer’s practical context on Home.
2. Show the already-submitted address-based question and the ordered BSN → DigiD
   → health insurance → huisarts route.
3. Continue into the BSN guide and a named Government.nl/Rijksoverheid source.
4. Show Map, Search, Cities, and Categories in one short breadth montage.
5. End with the creator story rather than another feature: ChatGPT as product and
   writing partner, Codex as engineering partner, and the owner as the source of
   the vision and decisions.

The owner did not begin as a professional software engineer. A simple idea became
a substantial native iOS application through sustained human direction and tool
collaboration: ChatGPT helped shape the product and its story, while Codex helped
implement, debug, stabilize, and prepare the project for Build Week. This is
separate from the app’s local deterministic assistant runtime. The owner remains
responsible for product direction, priorities, review, rights, distribution, and
the final submission decision.

## What YouNew represents

YouNew is not a claim that every newcomer question has been solved. It is a
working demonstration of a more useful pattern: organize complex public
information around a person’s next decision, connect guidance to navigable product
actions, and state uncertainty honestly.

For Build Week, that is the story: a substantial native product, narrowed to a
truthful and reproducible demo, ready to help a newcomer move from uncertainty to
the next practical step.

Evidence boundary: [Build Week candidate overview](../BuildWeekSubmission/README_BUILD_WEEK.md)
and [truthful assistant description](../BuildWeekSubmission/AI_ASSISTANT_TRUTHFUL_DESCRIPTION.md).
