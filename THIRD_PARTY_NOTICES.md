# YouNew third-party notices

This file is an engineering inventory, not a legal opinion. The authoritative license text remains the license distributed by each dependency. A release-specific CycloneDX inventory is generated with:

```bash
node scripts/generate-sbom.mjs --output-dir <restricted-output-directory>
```

## iOS Swift packages

| Package | Pinned version | License family | Upstream |
|---|---:|---|---|
| swift-algorithms | 1.2.1 | Apache-2.0 | https://github.com/apple/swift-algorithms |
| swift-async-algorithms | 1.1.5 | Apache-2.0 | https://github.com/apple/swift-async-algorithms |
| swift-collections | 1.6.0 | Apache-2.0 | https://github.com/apple/swift-collections |
| swift-numerics | 1.1.1 | Apache-2.0 | https://github.com/apple/swift-numerics |

Preserve the applicable Apache-2.0 license and NOTICE material when redistributing these packages or their source.

## Web applications

Production dependency licenses are inventoried from the lockfile for every sale-readiness release:

```bash
cd admin-dashboard && pnpm licenses list --prod --json
cd admin-dashboard/public-site && pnpm licenses list --prod --json
```

The direct Leaflet dependency is BSD-2-Clause. Apache, BSD, MIT, ISC, 0BSD and CC-BY attribution obligations must remain represented in the release evidence. LGPL-linked build tooling must be reviewed against the exact distributed artifact and target platform. Unknown, unlicensed or non-standard production dependencies block external-ready status.
