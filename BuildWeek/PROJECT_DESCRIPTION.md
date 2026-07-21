# YouNew — Project Description

## One-line description

YouNew is a local-first SwiftUI guide that turns practical newcomer questions
about life in the Netherlands into structured journeys, navigable content, and
official-source actions.

## Short description

YouNew helps people moving to or recently settled in the Netherlands understand
what to do next. The native iOS app combines structured guides, search, saved
items, checklists, local discovery, an interactive Netherlands map, and a
deterministic local guided assistant. The Build Week demo follows one newcomer
from an address-based question through BSN → DigiD → health insurance → huisarts,
then connects that route to a detailed guide, a stored official source, and a
short view of the wider product.

## Full description

Starting life in the Netherlands involves a chain of connected tasks: municipal
registration, BSN, DigiD, health insurance, finding a huisarts, housing,
transport, work, and local services. Information is distributed across different
institutions, and the hardest part is often understanding the order of actions and
which requirement unlocks the next step.

YouNew organizes that complexity into one native SwiftUI experience. Its Home and
Guide surfaces present structured newcomer content; Search, Saved, checklists, and
local discovery help users return to practical tasks; and a custom interactive map
supports province and city exploration. Typed routing connects these surfaces so a
guide, assistant response, city, or source action can lead to a concrete next step.

The documented Build Week experience uses a deterministic local fallback. It
selects a bounded workflow, advances through explicit states, searches indexed
YouNew knowledge, and composes structured sections, warnings, next steps, in-app
destinations, and official-source actions. The supported demo prompt starts from
a newcomer who already has an address and asks what comes first across BSN,
DigiD, health insurance, and finding a huisarts. The response orders those needs,
then continues into the BSN guide and a named Government.nl/Rijksoverheid source.
It works without a provider credential or deployed backend.

After that human journey is clear, a 30-second montage briefly shows Map, Search,
Cities, and Categories. The story closes with the creator journey: ChatGPT helped
the owner shape the product and its writing, while Codex helped implement,
stabilize, and prepare the iOS application. Those collaboration roles do not
imply that either tool powers the demonstrated in-app assistant.

Behind the interface, YouNew includes a governed content and import platform with
versioned records, lifecycle state, stable identifiers, migrations, validation
gates, and a deterministic bundled runtime payload. The `cities-v0.1.0` release
brings Amsterdam, Rotterdam, Den Haag, Utrecht, and Eindhoven into the same
canonical data path used by app consumers.

YouNew is a Build Week demonstration candidate, not a production-ready government
or advice service. It does not claim verified live OpenAI or GPT-5.6 inference,
complete content coverage, universal link health, or App Store readiness. Its
value is the product experience that can be demonstrated honestly today: turning
a broad newcomer problem into an understandable, repeatable next action.

## Audience

The primary audience is a recent or prospective resident of the Netherlands who
needs practical orientation. The current content can also support international
students, workers, partners and families, entrepreneurs, refugees, and people
moving between municipalities, while recognizing that rules and eligibility vary
by situation.

## Positioning

YouNew is independent from government institutions. Its content is educational
and must not replace legal, medical, immigration, tax, or other professional
advice. Consequential decisions should always be verified with the relevant
official authority.
