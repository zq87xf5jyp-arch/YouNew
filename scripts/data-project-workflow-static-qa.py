#!/usr/bin/env python3
"""Protect the nightly DATA PROJECT health automation contract."""

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "data-project-health.yml"
README = ROOT / "DataProject" / "README.md"


def fail(message: str) -> None:
    print(f"DATA PROJECT workflow static QA failed: {message}")
    raise SystemExit(1)


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


workflow = WORKFLOW.read_text(encoding="utf-8")
readme = README.read_text(encoding="utf-8")

required_workflow_fragments = (
    'cron: "17 2 * * *"',
    "workflow_dispatch:",
    "permissions:\n  contents: read",
    "publication-gates:",
    "nightly-source-health:",
    "python3 scripts/data-project-qa.py",
    "python3 scripts/generate-data-dashboard.py",
    "python3 scripts/data-dashboard-static-qa.py",
    "python3 scripts/generate-data-observability.py",
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
require(workflow.count('"scripts/generate-data-observability.py"') == 2, "observability generator edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-observability-static-qa.py"') == 2, "observability QA edits must trigger push and pull-request QA")
require(workflow.count('"scripts/generate-data-operations.py"') == 2, "operations generator edits must trigger push and pull-request QA")
require(workflow.count('"scripts/data-operations-static-qa.py"') == 2, "operations QA edits must trigger push and pull-request QA")
require("timeout-minutes: 30" in workflow, "nightly network job must have a bounded timeout")
require("cancel-in-progress: true" in workflow, "duplicate health runs must be cancelled")

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
print("- Nightly schedule, health gate, evidence retention and no-auto-publish policy verified")
