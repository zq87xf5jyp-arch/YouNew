#!/usr/bin/env python3
"""Render an honest weekly report from approved aggregates; missing values stay N/A."""
import argparse,datetime,json
from pathlib import Path
from zoneinfo import ZoneInfo
p=argparse.ArgumentParser();p.add_argument('--input',required=True);p.add_argument('--output',required=True);a=p.parse_args()
d=json.loads(Path(a.input).read_text());lines=['# YouNew weekly SEO report','',f"Prepared: {datetime.datetime.now(ZoneInfo('Europe/Amsterdam')).isoformat(timespec='minutes')}",f"Period end: {d['period_end']}",'','| Metric | Measured value |','|---|---|']
small_sample=d.get('guide_sessions') is None or d['guide_sessions']<100
for key,value in d['metrics'].items():
 if small_sample and key in {'official_action_percent','median_active_seconds','return_7_30d_percent'}:
  rendered='N/A — fewer than 100 suitable sessions or sample unavailable'
 else:
  rendered='N/A — unavailable' if value is None else value
 lines.append(f"| {key} | {rendered} |")
lines+=['','## Absolute guide counts','','| Count | Measured value |','|---|---|']
for key,value in d.get('guide_counts',{}).items():lines.append(f"| {key} | {'N/A — unavailable' if value is None else value} |")
lines+=['', 'Targets are hypotheses, not forecasts. Tabs, people, clicks and installs are different units.']
if d.get('guide_sessions') is None or d['guide_sessions']<100:lines+=['Guide sample below 100 or unavailable: report absolute counts; do not interpret rates as stable.']
for title,key in [('Source changes','source_changes'),('Link issues','link_issues')]:lines+=['',f'## {title}','',*(d.get(key) or ['N/A — not entered'])]
lines+=['','## Decision','',d.get('content_decision') or 'N/A — pending review','',d.get('next_week_action') or 'N/A — pending decision','','Source timezones: '+json.dumps(d['source_timezones'],ensure_ascii=False)]
Path(a.output).write_text('\n'.join(lines)+'\n');print(a.output)
