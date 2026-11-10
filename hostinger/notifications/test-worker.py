"""Isolated integration checks. Uses real SQLite/PHP and a non-sending transport."""
from pathlib import Path
import datetime, hashlib, json, os, sqlite3, subprocess, sys, tempfile

worker = Path(__file__).with_name('worker.php')
php = os.environ.get('PHP_BIN', 'php')
base = Path(tempfile.mkdtemp(prefix='younew-notifications-qa-'))/'younew-private'
base.mkdir(mode=0o700)
queue = base/'submissions.sqlite'
with sqlite3.connect(queue) as db:
    db.executescript('CREATE TABLE submissions(id TEXT PRIMARY KEY,kind TEXT,payload TEXT); CREATE TABLE delivery_receipts(submission_id TEXT PRIMARY KEY);')
    db.execute('INSERT INTO submissions VALUES(?,?,?)', ('old','business','PRIVATE_PERSON private@example.invalid'))
    db.execute('INSERT INTO delivery_receipts VALUES(?)', ('old',))
health = base/'health.json'
def set_health(status, age=0):
    at=datetime.datetime.now(datetime.timezone.utc)-datetime.timedelta(seconds=age)
    health.write_text(json.dumps({'status':status,'at':at.isoformat(),'checks':[{'name':'public','pass':status=='OK'}]}))
set_health('OK')
config = dict(environment='qa',transport='capture',recipient='support@younew.nl',sender='support@younew.nl',stateDirectory=str(base/'state'),queue=str(queue),health=str(health))
path = base/'config.json'
def save():
    path.write_text(json.dumps(config));path.chmod(0o600)
save()
count=0
def run(mode='run', expected=0):
    global count
    p=subprocess.run([php,str(worker),str(path),mode],text=True,capture_output=True)
    assert p.returncode==expected,(p.returncode,p.stdout,p.stderr)
    count+=1
    return json.loads(p.stdout or p.stderr)
def dbchange(sql):
    with sqlite3.connect(base/'state/notifications.sqlite') as db: db.executescript(sql)
def unlock(): dbchange('UPDATE batches SET created_at=created_at-61; UPDATE events SET next_at=0;')
def messages():
    p=base/'state/capture.jsonl'
    return [json.loads(x) for x in p.read_text().splitlines()] if p.exists() else []
assert run(expected=1)['status']=='notification_worker_error'
assert run('init')['status']=='initialized'
assert run('init')['status']=='already_initialized'
assert run()['status']=='idle' and not messages()
with sqlite3.connect(queue) as db:
    db.execute('INSERT INTO submissions VALUES(?,?,?)', ('new','business','SECRET inquiry contact@example.invalid'))
    db.execute('INSERT INTO delivery_receipts VALUES(?)', ('new',))
source_hash=hashlib.sha256(queue.read_bytes()).hexdigest()
assert run()['businessCount']==1
assert len(messages())==1 and 'SECRET' not in str(messages()) and '@example.invalid' not in str(messages())
unlock();assert run()['status']=='idle' and len(messages())==1
set_health('DEGRADED');assert run()['healthCount']==1
unlock();assert run()['status']=='idle'
set_health('OK');assert run()['healthCount']==1
unlock();set_health('OK',age=1800);assert run()['healthCount']==1
assert 'health_monitor' in messages()[-1]['body']
unlock();set_health('OK');config['transport']='reject';save()
assert run(expected=1)['status']=='retry_or_failed'
assert run()['status']=='rate_limited'
dbchange('UPDATE batches SET created_at=created_at-61;')
assert run()['status']=='idle'  # Backoff is respected.
unlock();config['transport']='capture';save();assert run()['status']=='accepted_by_local_mailer'
unlock();assert run('probe')['status']=='probe_queued';assert run()['probeCount']==1
unlock();assert run('probe')['status']=='probe_queued';assert run()['status']=='idle'  # Idempotent probe.
dbchange("INSERT INTO events(id,kind,detail,created_at,state) VALUES('interrupted','probe','',0,'sending');")
assert run()['status']=='idle'
with sqlite3.connect(base/'state/notifications.sqlite') as db:
    assert db.execute("SELECT state FROM events WHERE id='interrupted'").fetchone()[0]=='uncertain'
    db.executemany('INSERT INTO batches VALUES(?,?,?,?)',[(f'quota{i}',int(datetime.datetime.now().timestamp())-120,'accepted',0) for i in range(24)])
assert run()['status']=='daily_limit'
config['recipient']='attacker@example.invalid';save();assert run(expected=1)['status']=='notification_worker_error'
config['recipient']='support@younew.nl';save();path.chmod(0o644);assert run(expected=1)['status']=='notification_worker_error'
assert hashlib.sha256(queue.read_bytes()).hexdigest()==source_hash
print(json.dumps({'status':'PASS','workerInvocations':count,'noRealMailSent':True,'sourceQueueUnchanged':True,'qaDirectory':str(base)}))
