# Data batches

Create one directory per package (`WP-01` through `WP-15`) only when its first real batch is ready. Do not commit empty or speculative records.

Naming convention:

`WP-01/M1-government-core-001.json`

Each batch belongs to one milestone and one target Data Release. It owns its records and QA state. It may reference stable entities from another package, but it must not redefine them. A published batch is immutable; corrections are delivered through a patch Data Release while preserving the entity ID.
