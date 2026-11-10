# Amsterdam data release `amsterdam-v0.1.9`

Status: **approval required**. This packet does not accept or publish the release.

## Scope

Ten Amsterdam railway-station records were reverified at field level on 24 October 2026 against the official NS station pages and exact OpenStreetMap objects. Live departures, disruptions, opening hours, availability and prices were deliberately excluded.

The release overlay SHA-256 is:

`ef56dc29c01ba4962b5d29b3540254bad0549bb0315b458e6275667b047416c5`

The ten entity IDs and full evidence mapping are stored in the adjacent JSON packet, `DataProject/research/phase5-station-confirmations.json`, and the Phase 6.1 repeat-check receipt `DataProject/research/phase6-1-station-reverification.json`. The repeat check found 10/10 exact field matches and required no overlay change.

## Safety boundary

- Current production exclusions remain **170**.
- No acceptance lock for `amsterdam-v0.1.9` exists.
- No public runtime change is authorised.
- Data-release acceptance does not authorise production deployment, database migration, DNS changes or outreach.
- Promotion must update the release head, freshness exclusions and public provenance atomically and then repeat the full content/sitemap audit.

## Separate owner decision

To accept only this data release, the owner must provide the exact statement:

`ACCEPT DATA RELEASE amsterdam-v0.1.9 ef56dc29c01ba4962b5d29b3540254bad0549bb0315b458e6275667b047416c5`

After that decision, an immutable acceptance lock may be created and a new public candidate may be generated. Publication still requires a separate production deployment authorisation for that new artifact SHA-256.
