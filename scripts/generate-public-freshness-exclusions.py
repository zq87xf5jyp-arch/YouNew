#!/usr/bin/env python3
"""Withhold overdue published records at build time without changing source history."""
from datetime import date, datetime, timedelta, timezone
import json
from pathlib import Path

from effective_release import effective_release_heads, resolve_release

ROOT = Path(__file__).resolve().parents[1]


def exclusion(record, today):
    due = date.fromisoformat(record['last_checked']) + timedelta(days=record['review_frequency_days'])
    expired_event = False
    if record['entity_type'] == 'event':
        attributes = record.get('attributes') or {}
        expired_event = date.fromisoformat(attributes.get('end_date') or attributes['start_date']) < today
    if due >= today and not expired_event:
        return None
    return {'id': record['id'], 'classification': 'review_required',
            'reason': 'freshness_sla_expired', 'reviewDue': due.isoformat()}


def main():
    today = datetime.now(timezone.utc).date()
    records = []
    published_ids = set()
    withheld_ids = set()
    for release in effective_release_heads(ROOT / 'DataProject', {'published'}):
        for record in resolve_release(ROOT / 'DataProject', release).records:
            if record['lifecycle_status'] == 'published':
                published_ids.add(record['id'])
                entry = exclusion(record, today)
                if entry:
                    records.append(entry)
            elif record['lifecycle_status'] == 'retired':
                withheld_ids.add(record['id'])
    runtime = json.loads((ROOT / 'YouNew/Resources/Data/younew-runtime-data.json').read_text())
    if {record['id'] for record in runtime['entities']} != published_ids:
        raise RuntimeError('Canonical runtime is out of sync; regenerate release manifests and run import-data-project.py --all-approved before export')
    if not withheld_ids.issubset(runtime.get('withheldEntityIDs', [])):
        raise RuntimeError('Canonical runtime omits withdrawal tombstones')
    records.sort(key=lambda record: record['id'])
    assert len(records) == len({record['id'] for record in records})
    payload = {'schemaVersion': 1, 'asOf': today.isoformat(),
               'policy': 'fail_closed_until_field_level_reverification',
               'source': 'scripts/generate-public-freshness-exclusions.py',
               'count': len(records), 'records': records}
    path = ROOT / 'admin-dashboard/public-site/src/generated/public-freshness-exclusions.json'
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n')
    print(f'Withheld {len(records)} overdue records as of {today}; source facts and verification dates unchanged.')


if __name__ == '__main__':
    main()
