"""Synthetic-only Hostinger QA acceptance. Does not invoke any build worker."""
from pathlib import Path
import base64, datetime, hashlib, http.cookiejar, json, os, sys, urllib.error, urllib.request, uuid

ROOT = Path('/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1')
API = 'https://qa-runtime.younew.nl'
WEB = 'https://qa-catalog.younew.nl'
os.umask(0o077)
phase = sys.argv[1]
fixture_path = ROOT / 'logs/catalog-publication-fixture.private.json'
evidence_path = ROOT / ('logs/catalog-http-' + phase + '.private.json')
checks = []
users = json.loads((ROOT / 'synthetic-users.json').read_text())['users']
gate = json.loads((ROOT / 'qa-http.private.json').read_text())
basic = 'Basic ' + base64.b64encode((gate['user'] + ':' + gate['password']).encode()).decode()
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()

def client():
    return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))

def request(c, url, method='GET', body=None, protected=False):
    headers = {'Origin': API, 'Content-Type': 'application/json'}
    if protected: headers['Authorization'] = basic
    q = urllib.request.Request(url, method=method, headers=headers,
                               data=None if body is None else json.dumps(body).encode())
    try: response = c.open(q, timeout=30)
    except urllib.error.HTTPError as error: response = error
    return response.status, response.read().decode(), response.headers

def check(name, passed):
    checks.append({'name': name, 'status': 'PASS' if passed else 'FAIL'})
    if not passed: raise AssertionError(name)

def api(c, path, method='GET', body=None):
    status, text, headers = request(c, API + '/api/r4/' + path, method, body)
    return status, json.loads(text)

def login(role):
    c = client()
    status, _ = api(c, 'login', 'POST', {k: users[role][k] for k in ['email', 'password']})
    check(role + '_login', status == 200)
    return c

report = {'phase': phase, 'startedAt': now(), 'schedulerInvokedByProbe': False, 'checks': checks}
try:
    anon = client()
    owner = login('owner')
    if phase == 'approve':
        if fixture_path.exists(): raise RuntimeError('Fixture already exists; inspect before retrying')
        editor, other, viewer = login('editor'), login('other'), login('viewer')
        place = {'title': '[SYNTHETIC] Hostinger scheduled catalog acceptance',
                 'summary': 'Synthetic QA fixture; not a real place or recommendation.',
                 'kind': 'park', 'category': 'outdoor', 'cityId': 'leiden',
                 'coordinate': {'latitude': 52.16, 'longitude': 4.49,
                                'sourceUrl': 'https://example.invalid/synthetic', 'checkedAt': '2026-11-09'},
                 'address': None, 'website': None, 'email': None, 'phone': None}
        body = {'requestKey': str(uuid.uuid4()), 'place': place}
        check('viewer_create_denied', api(viewer, 'catalog', 'POST', body)[0] == 403)
        status, row = api(owner, 'catalog', 'POST', body)
        check('synthetic_draft_created', status == 200 and row['state'] == 'draft' and row['synthetic'])
        fixture = {'row': row, 'requestKey': body['requestKey'], 'createdAt': now()}
        with fixture_path.open('x') as f: json.dump(fixture, f, indent=2)
        status, duplicate = api(owner, 'catalog', 'POST', body)
        check('idempotent_create', status == 200 and duplicate['id'] == row['id'])
        changed = json.loads(json.dumps(body)); changed['place']['summary'] = 'Changed synthetic body'
        check('request_key_conflict', api(owner, 'catalog', 'POST', changed)[0] == 409)
        repeated = {**body, 'requestKey': str(uuid.uuid4())}
        check('duplicate_place_conflict', api(owner, 'catalog', 'POST', repeated)[0] == 409)
        path = 'catalog/' + row['id']
        check('foreign_workspace_hidden', api(other, path)[0] == 404)
        check('anonymous_approval_export_denied', api(anon, 'editorial/approved')[0] == 401)
        check('anonymous_status_denied', api(anon, 'catalog/publication-status')[0] == 401)
        slug = row['publicId'].removeprefix('place.')
        check('draft_page_absent', request(anon, WEB + '/places/' + slug + '/', protected=True)[0] == 404)
        status, row = api(editor, path + '/transition', 'POST', {'action': 'submit', 'revision': row['revision']})
        check('editor_submit', status == 200 and row['state'] == 'review')
        check('editor_cannot_approve', api(editor, path + '/transition', 'POST', {'action': 'approve', 'revision': row['revision']})[0] == 403)
        status, row = api(owner, path + '/transition', 'POST', {'action': 'approve', 'revision': row['revision']})
        check('owner_approve', status == 200 and row['state'] == 'published')
        fixture.update(row=row, approvedAt=now())
        fixture_path.write_text(json.dumps(fixture, indent=2))
    elif phase in ['observe-approved', 'observe-withdrawn']:
        fixture = json.loads(fixture_path.read_text()); row = fixture['row']
        public_id = row['publicId']; slug = public_id.removeprefix('place.')
        present = phase == 'observe-approved'
        status, state = api(owner, 'catalog/publication-status')
        check('observed_active_status', status == 200 and state.get('available') is True)
        check('status_matches_editorial_state', any(x['publicId'] == public_id for x in state['revisions']) == present)
        check('detail_status', request(anon, WEB + '/places/' + slug + '/', protected=True)[0] == (200 if present else 404))
        for route in ['/api/catalog.json', '/data/search-index.json', '/map/', '/sitemap.xml', '/data/younew-runtime-data.json']:
            status, text, headers = request(anon, WEB + route, protected=True)
            check('surface:' + route, status == 200 and (slug in text or public_id in text) == present)
            check('no_store:' + route, 'no-store' in headers.get('Cache-Control', ''))
        status, public = api(anon, 'public/catalog')
        check('backend_reads_active_catalog', status == 200 and (public_id in json.dumps(public)) == present)
        check('anonymous_gate_closed', request(anon, WEB + '/')[0] == 401)
        for route in ['/younew-private/launch.env', '/publication/current.json', '/backend/private/env.json', '/.git/config', '/publication/releases/' + state['releaseId'] + '/out/index.html']:
            check('private_path:' + route, request(anon, WEB + route, protected=True)[0] in [403, 404])
        check('network_only_service_worker', 'caches.' not in request(anon, WEB + '/sw.js', protected=True)[1])
        current = json.loads((ROOT / 'publication/current.json').read_text())
        report['release'] = current
        start = fixture['approvedAt'] if present else fixture['withdrawnAt']
        report['activationDelaySeconds'] = (datetime.datetime.fromisoformat(current['activatedAt'].replace('Z', '+00:00')) - datetime.datetime.fromisoformat(start)).total_seconds()
        report['observedAt'] = now()
        if present:
            fixture['approvedRelease'] = current
            fixture['approvedPointerSha256'] = hashlib.sha256((ROOT / 'publication/current.json').read_bytes()).hexdigest()
            fixture_path.write_text(json.dumps(fixture, indent=2))
        else:
            out = ROOT / 'publication/releases' / current['releaseId'] / 'out'
            leaks = []
            drafts = json.loads((ROOT / 'catalog-builders/current/backend/db/catalog-drafts.json').read_text())['entities']
            for path in out.rglob('*'):
                if path.is_file() and path.suffix in ['.html', '.js', '.json', '.xml', '.txt']:
                    text = path.read_text()
                    if slug in text or public_id in text or any(d['id'] in text for d in drafts): leaks.append(str(path.relative_to(out)))
            check('withdrawn_and_real_drafts_absent_from_all_output', not leaks)
            report['realDraftsExcluded'] = len(drafts)
    elif phase == 'withdraw':
        fixture = json.loads(fixture_path.read_text()); row = fixture['row']
        check('approved_release_was_observed', 'approvedRelease' in fixture)
        status, row = api(owner, 'catalog/' + row['id'] + '/transition', 'POST', {'action': 'withdraw', 'revision': row['revision']})
        check('owner_withdraw', status == 200 and row['state'] == 'draft')
        fixture.update(row=row, withdrawnAt=now())
        fixture_path.write_text(json.dumps(fixture, indent=2))
    else: raise ValueError('Unknown phase')
    report['status'] = 'PASS'
except Exception as error:
    report.update(status='FAIL', error=str(error))
    raise
finally:
    report['finishedAt'] = now()
    evidence_path.write_text(json.dumps(report, indent=2))
    print(json.dumps({'phase': phase, 'status': report.get('status'), 'checks': len(checks), 'error': report.get('error'), 'evidence': str(evidence_path)}))
