# Contributing to YouNew

Thank you for helping make YouNew clearer and more reliable for newcomers in the
Netherlands.

## Before you start

This repository is public for evaluation, review, and collaboration, but it is
not distributed under an open-source license. Read [LICENSE](LICENSE) before
using or contributing code. Opening or accepting a pull request does not replace
that license or grant repository-wide reuse rights.

For a substantial feature, schema change, or new content collection, open a
feature request first. Small bug fixes and corrections to an official source may
go directly to a focused pull request.

Because the repository does not grant an open-source license, an external code
or data contribution requires a separate written contributor agreement before
it can be merged. Issues, factual corrections, and review feedback remain
welcome without such an agreement.

## Safety and evidence rules

- Never commit a BSN, passport, residence permit, address, medical record,
  credential, API key, signing certificate, provisioning profile, or other
  personal or secret data.
- Do not add photographs, logos, maps, screenshots, or copied text unless their
  ownership, license, attribution, and redistribution status are documented.
- Prefer current official Dutch government, municipality, public-service, or
  institution sources for factual guidance.
- Do not hide a broken governed source through an allowlist, skip, warning, or a
  weaker gate. Correct the URL or replace the record with a verifiable official
  source.
- Keep product claims bounded. YouNew is an educational guide, not a government,
  legal, medical, immigration, or emergency service.

## Development checks

Run the checks relevant to your change before opening a pull request:

```sh
scripts/run-static-qa.sh
```

For the iOS app, build the shared `YouNew` scheme and run `YouNewTests` on an
available iPhone Simulator. For the public site:

```sh
cd admin-dashboard/public-site
corepack enable
pnpm install --frozen-lockfile
pnpm predeploy:check
```

Data changes should include the stable record or source ID, the official URL,
the date it was checked, and any required generated artifact updates.

## Pull requests

Keep each pull request narrow. Complete the repository pull-request template,
describe user-visible behavior, list the exact validation performed, and call
out generated files or rights-sensitive media. A maintainer may request evidence
or decline a contribution that cannot be safely licensed, validated, or kept
current.

For security vulnerabilities, follow [SECURITY.md](SECURITY.md) instead of
opening a public issue.
