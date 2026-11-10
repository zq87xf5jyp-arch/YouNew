"""Read-only object checks plus login/logout of existing synthetic QA accounts."""
import datetime
import hashlib
import http.cookiejar
import json
import os
from pathlib import Path
import sys
import urllib.error
import urllib.request

ROOT = Path('/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1')
API = 'https://qa-runtime.younew.nl'
os.umask(0o077)
output = ROOT / ('logs/release-' + sys.argv[1] + '.json')
assert not output.exists()
checks = []


def check(name, condition):
    checks.append({'name': name, 'pass': bool(condition)})
    if not condition:
        raise AssertionError(name)


def client():
    return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))


def request(c, path, body=None):
    q = urllib.request.Request(API + '/api/r4/' + path,
        headers={'Origin': API, 'Content-Type': 'application/json'},
        data=None if body is None else json.dumps(body).encode())
    try:
        r = c.open(q, timeout=30)
    except urllib.error.HTTPError as e:
        r = e
    raw = r.read()
    return r.status, raw, r.headers


report = {'commit': sys.argv[1], 'at': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'checks': checks}
try:
    anon = client()
    for path in ['me', 'inquiries', 'notifications', 'audit', 'catalog']:
        code, _, headers = request(anon, path)
        check('anonymous_' + path, code == 401)
        check('no_store_' + path, 'no-store' in headers.get('Cache-Control', ''))
    users = json.loads((ROOT / 'synthetic-users.json').read_text())['users']
    for name, user in users.items():
        c = client()
        code, _, _ = request(c, 'login', {k: user[k] for k in ['email', 'password']})
        if name in ['pending', 'blocked']:
            check(name + '_denied', code == 403)
            continue
        check(name + '_login', code == 200)
        code, raw, _ = request(c, 'me')
        check(name + '_identity', code == 200 and json.loads(raw)['id'] == user['id'])
        code, _, _ = request(c, 'inquiries')
        check(name + '_crm', code == (200 if name in ['owner', 'admin', 'other'] else 403))
        if name == 'owner':
            f = json.loads((ROOT / 'logs/files-qa-result.private.json').read_text())['artifact']
            code, raw, headers = request(c, 'files/' + f['id'])
            check('private_file_retained', code == 200 and 'no-store' in headers.get('Cache-Control', '') and len(raw) > 0)
            report['retainedFileSha256'] = hashlib.sha256(raw).hexdigest()
        check(name + '_logout', request(c, 'logout', {})[0] == 200)
        check(name + '_revoked', request(c, 'me')[0] == 401)
    report['status'] = 'PASS'
finally:
    report.setdefault('status', 'FAIL')
    output.write_text(json.dumps(report, indent=2))
    print(json.dumps({'status': report['status'], 'checks': len(checks), 'evidence': str(output)}))
