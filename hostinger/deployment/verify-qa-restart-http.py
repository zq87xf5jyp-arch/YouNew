"""Preserve a synthetic authenticated session across a managed Hostinger restart."""
from pathlib import Path
import datetime, hashlib, http.cookiejar, json, os, sys, urllib.error, urllib.request

ROOT = Path('/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1')
API = 'https://qa-runtime.younew.nl'
os.umask(0o077)
phase = sys.argv[1]
cookie_path = ROOT / 'logs/restart-cookie.private.txt'
state_path = ROOT / 'logs/restart-before.private.json'
jar = http.cookiejar.LWPCookieJar(str(cookie_path))
client = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))

def request(path, body=None):
    q = urllib.request.Request(API + '/api/r4/' + path, method='GET' if body is None else 'POST',
        headers={'Origin': API, 'Content-Type': 'application/json'},
        data=None if body is None else json.dumps(body).encode())
    try: r = client.open(q, timeout=30)
    except urllib.error.HTTPError as e: r = e
    return r.status, r.read(), r.headers

def capture(file_id):
    result = {}
    for name, path in [('identity', 'me'), ('inquiries', 'inquiries'), ('file', 'files/' + file_id)]:
        status, body, headers = request(path)
        assert status == 200, name + ' HTTP ' + str(status)
        assert 'no-store' in headers.get('Cache-Control', ''), name + ' cache'
        if name != 'file': body = json.dumps(json.loads(body), sort_keys=True).encode()
        result[name] = {'sha256': hashlib.sha256(body).hexdigest(), 'bytes': len(body)}
    return result

if phase == 'before':
    assert not state_path.exists(), 'Before evidence already exists'
    user = json.loads((ROOT / 'synthetic-users.json').read_text())['users']['owner']
    assert request('login', {k: user[k] for k in ['email', 'password']})[0] == 200
    file_id = json.loads((ROOT / 'logs/files-qa-result.private.json').read_text())['artifact']['id']
    report = {'at': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'fileId': file_id, 'objects': capture(file_id)}
    jar.save(ignore_discard=True, ignore_expires=True)
    state_path.write_text(json.dumps(report, indent=2))
    print(json.dumps({'status': 'PREPARED', 'objects': len(report['objects']), 'sessionRetainedPrivately': True}))
elif phase == 'after':
    jar.load(ignore_discard=True, ignore_expires=True)
    before = json.loads(state_path.read_text())
    observed = capture(before['fileId'])
    assert observed == before['objects'], 'Persisted content differs'
    assert request('logout', {})[0] == 200
    assert request('me')[0] == 401
    report = {'status': 'PASS', 'at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'sessionSurvived': True, 'objectsByteIdentical': list(observed),
              'logoutRevoked': True, 'reloginUsedForCheck': False}
    (ROOT / 'logs/restart-after.private.json').write_text(json.dumps(report, indent=2))
    print(json.dumps(report))
else:
    raise ValueError('Unknown phase')
