#!/usr/bin/env python3
"""Protect the nightly DATA PROJECT health automation contract."""

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "data-project-health.yml"
README = ROOT / "DataProject" / "README.md"
AGGREGATE_QA = ROOT / "scripts" / "run-static-qa.sh"
LINK_CHECKER = ROOT / "scripts" / "check-external-links.py"
DASHBOARD_GENERATOR = ROOT / "scripts" / "generate-data-dashboard.py"
IMPORT_QA = ROOT / "scripts" / "data-project-import-static-qa.py"
PUBLIC_SITE_PREDEPLOY = ROOT / "admin-dashboard" / "public-site" / "scripts" / "pre-deploy.sh"


def fail(message: str) -> None:
    print(f"DATA PROJECT workflow static QA failed: {message}")
    raise SystemExit(1)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


workflow = WORKFLOW.read_text(encoding="utf-8")
readme = README.read_text(encoding="utf-8")
aggregate_qa = AGGREGATE_QA.read_text(encoding="utf-8")
link_checker = LINK_CHECKER.read_text(encoding="utf-8")
dashboard_generator = DASHBOARD_GENERATOR.read_text(encoding="utf-8")
import_qa = IMPORT_QA.read_text(encoding="utf-8")
public_site_predeploy = PUBLIC_SITE_PREDEPLOY.read_text(encoding="utf-8")

required_workflow_fragments = (
    'cron: "17 2 * * *"',
    "workflow_dispatch:",
    "permissions:\n  contents: read",
    "publication-gates:",
    "nightly-source-health:",
    "python3 scripts/data-project-qa.py",
    "python3 scripts/data-project-workflow-static-qa.py",
    "python3 -m unittest discover -s scripts/tests -p 'test_*.py'",
    "python3 scripts/generate-data-dashboard.py",
    "python3 scripts/data-dashboard-static-qa.py",
    "python3 scripts/generate-data-observability.py",
    "python3 scripts/data-project-import-static-qa.py",
    "python3 scripts/data-observability-static-qa.py",
    "python3 scripts/generate-data-operations.py",
    "python3 scripts/data-operations-static-qa.py",
    "python3 scripts/data-health-gate.py",
    "python3 scripts/check-external-links.py",
    "python3 scripts/data-health-gate.py --require-network",
    "if: always() && (github.event_name == 'schedule' || github.event_name == 'workflow_dispatch')",
    "DataProject/reports/",
    "knowledge_data_health.json",
    "broken_links.csv",
    "retention-days: 30",
    "data-project-health-${{ github.event_name }}-${{ github.ref }}",
)
for fragment in required_workflow_fragments:
    require(fragment in workflow, f"missing workflow contract: {fragment}")

require(workflow.count("if: always()") >= 7, "health reports, coverage checks, gates and artifacts must survive earlier step failures")
require(workflow.count('"scripts/data-dashboard-static-qa.py"') == 2, "coverage-QA edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-health-gate.py"') == 2, "health-gate edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-project-workflow-static-qa.py"') == 2, "workflow-contract edits must trigger push and pull-request QA")
require(workflow.count('"scripts/effective_release.py"') == 2, "release-resolver edits must trigger push and pull-request QA")
require(workflow.count('"scripts/import-data-project.py"') == 2, "importer edits must trigger push and pull-request QA")
require(workflow.count('"scripts/run-static-qa.sh"') == 2, "aggregate-QA edits must trigger push and pull-request QA")
require(workflow.count('"scripts/tests/**"') == 2, "Data Project test edits must trigger push and pull-request QA")
require(workflow.count('"scripts/generate-data-observability.py"') == 2, "observability generator edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-project-import-static-qa.py"') == 2, "import-QA edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-observability-static-qa.py"') == 2, "observability QA edits must trigger push and pull-request QA")
require(workflow.count('"scripts/generate-data-operations.py"') == 2, "operations generator edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-operations-static-qa.py"') == 2, "operations QA edits must trigger push and pull-request QA")
require(workflow.count('"YouNew/**"') == 2, "app source and runtime edits must trigger push and pull-request QA")
require(workflow.count('"source_registry.json"') == 2, "source-registry edits must trigger push and pull-request QA")
for published_artifact in (
    '"admin-dashboard/public-site/src/generated/public-content.json"',
    '"admin-dashboard/public-site/public/data/search-index.json"',
    '"admin-dashboard/public-site/public/data/content-provenance.json"',
):
    require(workflow.count(published_artifact) == 2, f"published artifact edits must trigger QA: {published_artifact}")
require("timeout-minutes: 30" in workflow, "nightly network job must have a bounded timeout")
require("cancel-in-progress: true" in workflow, "duplicate health runs must be cancelled")
require(workflow.count("runs-on: ubuntu-24.04") == 2, "health jobs must use the reviewed Ubuntu image")
require(workflow.count("persist-credentials: false") == 2, "checkout credentials must not persist")
require(workflow.count("if-no-files-found: error") == 2, "missing health evidence must fail artifact upload")
for action, expected_count in (
    ("actions/checkout", 2),
    ("actions/setup-python", 2),
    ("actions/upload-artifact", 2),
):
    immutable_uses = re.findall(rf"uses:\s+{re.escape(action)}@([0-9a-f]{{40}})\b", workflow)
    require(
        len(immutable_uses) == expected_count,
        f"{action} must be used {expected_count} time(s) with an immutable 40-character SHA",
    )

require(
    "effective_release_heads(PROJECT)" in link_checker,
    "nightly link scope must resolve every governed effective release head",
)
require(
    "if release_id and path == GENERATED_RUNTIME" in link_checker,
    "nightly production mode must keep the shipped runtime in link scope",
)
for required_scope in ("SOURCE_REGISTRY", "PUBLISHED_WEB_ARTIFACTS", "public-content.json", "search-index.json", "content-provenance.json"):
    require(required_scope in link_checker, f"nightly link checker is missing production scope: {required_scope}")
require("400 <= error.code < 500" in link_checker, "every HEAD client error must receive a GET verification")
require("is_confirmed_failure" in link_checker, "non-restricted client errors must fail closed")
require("effective_release_heads(PROJECT)" in dashboard_generator, "Data Health dashboard must resolve governed effective release heads")
require("captured[\"runtime\"]" in import_qa and "semantic_fields" in import_qa, "import QA must compare shipped data with a deterministic effective rebuild")

observability_generation = "python3 scripts/generate-data-observability.py"
import_validation = "python3 scripts/data-project-import-static-qa.py"
require(observability_generation in aggregate_qa, "aggregate QA must generate release manifests")
require(import_validation in aggregate_qa, "aggregate QA must validate the governed importer")
require(
    aggregate_qa.index(observability_generation) < aggregate_qa.index(import_validation),
    "aggregate QA must generate release manifests before importer validation",
)
public_dashboard_generation = "python3 ../../scripts/generate-data-dashboard.py"
public_observability_generation = "python3 ../../scripts/generate-data-observability.py"
public_import_validation = "python3 ../../scripts/data-project-import-static-qa.py"
public_health_gate = "python3 ../../scripts/data-health-gate.py"
require(public_dashboard_generation in public_site_predeploy, "public-site pre-deploy must generate current Data Health")
require(public_observability_generation in public_site_predeploy, "public-site pre-deploy must generate release manifests")
require(public_import_validation in public_site_predeploy, "public-site pre-deploy must validate the governed importer")
require(public_health_gate in public_site_predeploy, "public-site pre-deploy must enforce current Data Health")
require(
    public_site_predeploy.index(public_observability_generation) < public_site_predeploy.index(public_import_validation),
    "public-site pre-deploy must generate release manifests before importer validation",
)
require(
    public_site_predeploy.index(public_dashboard_generation) < public_site_predeploy.index(public_health_gate),
    "public-site pre-deploy must generate current Data Health before enforcing the gate",
)

for forbidden in (r"\bgit\s+push\b", r"\bgit\s+commit\b", r"\bgh\s+release\b", r"publication_status.*published"):
    require(re.search(forbidden, workflow, flags=re.IGNORECASE) is None, f"workflow must not publish data automatically: {forbidden}")

required_readme_fragments = (
    "every night at 02:17 UTC",
    "data-health-gate.py --require-network",
    "never auto-publishes a batch",
    "Coverage counts all governed DATA PROJECT records",
)
for fragment in required_readme_fragments:
    require(fragment in readme, f"README is missing the operational contract: {fragment}")

print("DATA PROJECT workflow static QA passed")
print("- Nightly schedule, clean-clone manifest ordering, evidence retention and no-auto-publish policy verified")
