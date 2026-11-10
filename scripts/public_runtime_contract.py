"""Validate a public subset without silently dropping canonical runtime records."""
from datetime import date, datetime, timedelta, timezone
import json
import subprocess


def verified_editorial_release(public, root):
    if not any(item.get("editorial") for item in public["entities"]):
        return {"ids": [], "sha": None}
    script = "import {loadEditorialRelease} from './admin-dashboard/public-site/scripts/editorial-release.mjs'; const r=await loadEditorialRelease(); console.log(JSON.stringify({ids:r.entities.map(x=>x.id),sha:r.batchSha256}));"
    approved = json.loads(subprocess.check_output(["node", "--input-type=module", "-e", script], cwd=root, text=True))
    observed = {item["id"] for item in public["entities"] if item.get("editorial", {}).get("batchSha256") == approved["sha"]}
    if observed != set(approved["ids"]):
        raise ValueError("Approved editorial public projection differs from source batch")
    return approved


def validate_public_partition(runtime, public, exclusions, disposition, freshness_records=None, today=None, editorial_ids=()):
    errors = []
    runtime_ids = [item["id"] for item in runtime["entities"]]
    public_ids = [item["id"] for item in public["entities"]]
    records = exclusions.get("records", [])
    excluded_ids = [item.get("id") for item in records]
    approved_ids = {
        item["entity_id"] for item in disposition["records"]
        if item.get("disposition") == "temporarily_exclude_from_public_output"
    }
    for label, ids in [("runtime", runtime_ids), ("public", public_ids), ("excluded", excluded_ids)]:
        if len(ids) != len(set(ids)) or any(not item for item in ids):
            errors.append(f"{label} IDs must be unique and nonempty")
    if exclusions.get("policy") != "fail_closed_until_field_level_reverification":
        errors.append("public exclusion policy is not fail-closed")
    dynamic = exclusions.get("source") == "scripts/generate-public-freshness-exclusions.py"
    if dynamic:
        today = today or datetime.now(timezone.utc).date()
        if exclusions.get("asOf") != today.isoformat():
            errors.append("public freshness exclusions were not evaluated today")
        if freshness_records is None:
            errors.append("dynamic exclusions require canonical published freshness records")
        else:
            expected = {}
            canonical_ids = set()
            for item in freshness_records:
                if item.get("lifecycle_status") != "published":
                    continue
                canonical_ids.add(item["id"])
                due = date.fromisoformat(item["last_checked"]) + timedelta(days=item["review_frequency_days"])
                attrs = item.get("attributes") or {}
                expired_event = item["entity_type"] == "event" and date.fromisoformat(
                    attrs.get("end_date") or attrs["start_date"]
                ) < today
                if due < today or expired_event:
                    expected[item["id"]] = due.isoformat()
            if canonical_ids != set(runtime_ids):
                errors.append("runtime IDs differ from canonical published freshness records")
            if set(excluded_ids) != set(expected):
                errors.append("dynamic exclusions differ from canonical expired records")
            if any(item.get("reviewDue") != expected.get(item.get("id")) for item in records):
                errors.append("exclusion review deadline differs from canonical freshness metadata")
    elif exclusions.get("source") != "DataProject/quality/phase4-amsterdam-stale-disposition.json":
        errors.append("public exclusions reference an unexpected disposition source")
    if exclusions.get("count") != len(records):
        errors.append("public exclusion count is stale")
    if any(item.get("reason") != "freshness_sla_expired" for item in records):
        errors.append("public exclusion has an unsupported reason")
    if not dynamic and set(excluded_ids) != approved_ids:
        errors.append("public exclusions differ from the reviewed disposition")
    if set(public_ids) & set(excluded_ids):
        errors.append("excluded records remain in public content")
    if set(editorial_ids) & set(runtime_ids):
        errors.append("editorial IDs overlap canonical runtime")
    if set(public_ids) | set(excluded_ids) != set(runtime_ids) | set(editorial_ids):
        errors.append("public content and explicit exclusions do not partition the canonical runtime")
    return errors
