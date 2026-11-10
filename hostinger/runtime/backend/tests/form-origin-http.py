#!/usr/bin/env python3
"""Actual PHP OPTIONS requests; no submission, contacts or external network."""
from pathlib import Path
import urllib.request, urllib.error, json, os
R=Path(__file__).resolve().parents[1];p=R/'php/private/forms/origins.php'
if p.exists():raise SystemExit('Refuse to overwrite an existing origin config')
checks=[]
def check(name,origin,expected):
 req=urllib.request.Request('http://127.0.0.1:4408/submit-business-inquiry.php',method='OPTIONS',headers={'Origin':origin})
 try:r=urllib.request.urlopen(req);code=r.status;h=r.headers
 except urllib.error.HTTPError as r:code=r.code;h=r.headers
 passed=code==expected and (expected!=204 or h.get('Access-Control-Allow-Origin')==origin)
 checks.append({'name':name,'status':code,'expected':expected,'pass':passed})
 assert passed,name
try:
 check('local-only allowlist', 'http://127.0.0.1:4408',204)
 check('production origin not inherited','https://younew.nl',403)
 p.write_text("<?php return ['https://r4-forms.younew.nl'];");p.chmod(0o600)
 check('private exact HTTPS origin accepted','https://r4-forms.younew.nl',204)
 check('wildcard/subdomain not accepted','https://evil.r4-forms.younew.nl',403)
 check('loopback excluded by explicit server config','http://127.0.0.1:4408',403)
 p.chmod(0o644);check('public-readable config fails closed','https://r4-forms.younew.nl',503)
 p.chmod(0o600);p.write_text("<?php return ['*'];")
 check('invalid config fails closed','https://r4-forms.younew.nl',503)
finally:
 if p.exists():p.unlink()
 (R/'evidence/form-origin-http.json').write_text(json.dumps({'status':'PASS' if len(checks)==7 and all(x['pass'] for x in checks) else 'FAIL','checks':checks},indent=2))
print('7 PHP origin checks passed; synthetic OPTIONS only')
