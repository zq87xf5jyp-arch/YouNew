#!/usr/bin/env python3
from pathlib import Path
import os,json,subprocess,sys
r=Path(__file__).resolve().parents[1]
env=os.environ.copy();env.update(json.loads((r/'private/env.json').read_text()));env['PATH']='/Users/ivan/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin:'+env['PATH'];env['NEXT_TELEMETRY_DISABLED']='1'
if len(sys.argv)<2:raise SystemExit('Provide command; values are never printed')
p=subprocess.run(sys.argv[1:],env=env,cwd=r/'source/admin-dashboard');sys.exit(p.returncode)
