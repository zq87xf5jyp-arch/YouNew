#!/usr/bin/env python3
"""Validate repository governance workflows without network access."""

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOWS = ROOT / ".github" / "workflows"


def fail(message: str) -> None:
    print(f"Repository governance static QA failed: {message}")
    raise SystemExit(1)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def read(relative_path: str) -> str:
    path = ROOT / relative_path
    require(path.is_file(), f"missing {relative_path}")
    return path.read_text(encoding="utf-8")


product = read(".github/workflows/product-ci.yml")
data_health = read(".github/workflows/data-project-health.yml")
secret_scan = read(".github/workflows/secret-scan.yml")
gitleaks_ignore = read(".gitleaksignore")
backup = read(".github/workflows/repository-backup.yml")
release = read(".github/workflows/release-journal.yml")
backup_script = read("scripts/create-repository-backup.sh")
governance = read("docs/REPOSITORY_GOVERNANCE.md")
contributing = read("CONTRIBUTING.md")

required_check_sources = product + "\n" + data_health + "\n" + secret_scan
required_checks = (
    "iOS build and unit tests",
    "Public site validation",
    "Backend security contract tests",
    "Offline publication gates",
    "Secret scan",
)
for check in required_checks:
    require(
        required_check_sources.count(f"name: {check}") == 1,
        f"required check must have one stable job name: {check}",
    )
    require(f"`{check}`" in governance, f"governance guide must list required check: {check}")

for workflow_name, workflow in (
    ("Product CI", product),
    ("DATA PROJECT Health", data_health),
    ("Secret Scan", secret_scan),
):
    require(
        "  pull_request:\n  push:" in workflow,
        f"{workflow_name} must run on every pull request so required checks cannot be skipped",
    )
    require(
        "  push:\n    branches:\n      - main\n" in workflow,
        f"{workflow_name} push runs must be limited to main",
    )

for forbidden in ("pull_request_target:", "persist-credentials: true"):
    for path in WORKFLOWS.glob("*.yml"):
        require(forbidden not in path.read_text(encoding="utf-8"), f"{path.name} contains forbidden {forbidden}")

for action, workflow, expected_count in (
    ("actions/checkout", secret_scan, 1),
    ("gitleaks/gitleaks-action", secret_scan, 1),
    ("actions/checkout", backup, 1),
    ("actions/upload-artifact", backup, 1),
    ("actions/checkout", release, 1),
):
    matches = re.findall(rf"uses:\s+{re.escape(action)}@([0-9a-f]{{40}})\b", workflow)
    require(len(matches) == expected_count, f"{action} must use immutable SHA refs")

for fragment in (
    "fetch-depth: 0",
    "GITLEAKS_ENABLE_COMMENTS: \"false\"",
    "GITLEAKS_ENABLE_UPLOAD_ARTIFACT: \"false\"",
    'cron: "31 3 * * 1"',
    "name: Secret scan",
):
    require(fragment in secret_scan, f"secret scan is missing {fragment}")

expected_gitleaks_fingerprints = {
    "7a1f6bc8fcffac84e5798338380bb97aca815b3d:BuildWeekFix/FINAL_PUBLIC_FACTS.json:generic-api-key:200",
    "7b6f359bbbfcbc89a202623097ff6899859259b4:YouNew/Core/Extensions/AppDataMigration.swift:generic-api-key:4",
    "65eabc495c1b572d9c91dbea96595d1fedcfee64:PRIVACY_REVIEW.md:generic-api-key:52",
    "65eabc495c1b572d9c91dbea96595d1fedcfee64:CURRENT_WORKTREE_DIFF.patch:generic-api-key:2820",
    "65eabc495c1b572d9c91dbea96595d1fedcfee64:CURRENT_WORKTREE_DIFF.patch:generic-api-key:5596",
    "65eabc495c1b572d9c91dbea96595d1fedcfee64:YouNew/ViewModels/TranslatorViewModel.swift:generic-api-key:16",
    "65eabc495c1b572d9c91dbea96595d1fedcfee64:YouNew/ViewModels/AIViewModel.swift:generic-api-key:69",
}
gitleaks_fingerprint_lines = [
    line.strip() for line in gitleaks_ignore.splitlines() if line.strip()
]
require(
    len(gitleaks_fingerprint_lines) == len(set(gitleaks_fingerprint_lines)),
    ".gitleaksignore must not contain duplicate fingerprints",
)
require(
    set(gitleaks_fingerprint_lines) == expected_gitleaks_fingerprints,
    ".gitleaksignore must contain only the reviewed exact-fingerprint baseline",
)

for fragment in (
    "git -C \"$ROOT\" fsck --full --strict",
    "bundle create",
    "bundle verify",
    "SHA256SUMS",
):
    require(fragment in backup_script, f"backup script is missing {fragment}")
require("retention-days: 14" in backup, "backup artifact retention must remain 14 days")
require("if-no-files-found: error" in backup, "missing backup output must fail the workflow")

for fragment in (
    "^v[0-9]+\\.[0-9]+\\.[0-9]+$",
    "MARKETING_VERSION",
    "PRODUCT_BUNDLE_IDENTIFIER = nl\\.younew\\.app;",
    "CHANGELOG.md",
    "git merge-base --is-ancestor",
    "gh release create",
):
    require(fragment in release, f"release journal is missing {fragment}")

for fragment in (
    "agent/",
    "pull request",
    "Secret scan",
    ".gitleaksignore",
    "Git bundle",
    "CHANGELOG.md",
):
    require(fragment.lower() in governance.lower(), f"governance guide is missing {fragment}")
require("Never commit directly to `main`" in contributing, "contribution guide must protect main")
require("Merge queue is not enabled" in governance, "merge-queue compatibility boundary must stay explicit")

print("Repository governance static QA passed")
print("- PR gates, secret scanning, verified backups and release journaling are structurally validated")
