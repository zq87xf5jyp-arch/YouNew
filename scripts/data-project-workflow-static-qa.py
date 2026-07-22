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
)
for fragment in required_workflow_fragments:
    require(fragment in workflow, f"missing workflow contract: {fragment}")

require(workflow.count("if: always()") >= 7, "health reports, coverage checks, gates and artifacts must survive earlier step failures")
require(workflow.count('"scripts/data-dashboard-static-qa.py"') == 2, "coverage-QA edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-health-gate.py"') == 2, "health-gate edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-project-workflow-static-qa.py"') == 2, "workflow-contract edits must trigger push and pull-request QA")
require(workflow.count('"scripts/effective_release.py"') == 2, "release-resolver edits must trigger push and pull-request QA")
require(workflow.count('"scripts/import-data-project.py"') == 2, "importer edits must trigger push and pull-request QA")
require(workflow.count('"scripts/tests/**"') == 2, "Data Project test edits must trigger push and pull-request QA")
require(workflow.count('"scripts/generate-data-observability.py"') == 2, "observability generator edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-project-import-static-qa.py"') == 2, "import-QA edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-observability-static-qa.py"') == 2, "observability QA edits must trigger push and pull-request QA")
require(workflow.count('"scripts/generate-data-operations.py"') == 2, "operations generator edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-operations-static-qa.py"') == 2, "operations QA edits must trigger push and pull-request QA")
require("timeout-minutes: 30" in workflow, "nightly network job must have a bounded timeout")
require("cancel-in-progress: true" in workflow, "duplicate health runs must be cancelled")

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
