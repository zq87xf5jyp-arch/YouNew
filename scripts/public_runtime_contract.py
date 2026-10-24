"""Validate a public subset without silently dropping canonical runtime records."""


def validate_public_partition(runtime, public, exclusions, disposition):
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
    if exclusions.get("source") != "DataProject/quality/phase4-amsterdam-stale-disposition.json":
        errors.append("public exclusions reference an unexpected disposition source")
    if exclusions.get("count") != len(records):
        errors.append("public exclusion count is stale")
    if any(item.get("reason") != "freshness_sla_expired" for item in records):
        errors.append("public exclusion has an unsupported reason")
    if set(excluded_ids) != approved_ids:
        errors.append("public exclusions differ from the reviewed disposition")
    if set(public_ids) & set(excluded_ids):
        errors.append("excluded records remain in public content")
    if set(public_ids) | set(excluded_ids) != set(runtime_ids):
        errors.append("public content and explicit exclusions do not partition the canonical runtime")
    return errors
