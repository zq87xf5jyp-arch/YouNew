#!/usr/bin/env python3
"""Start only this candidate. Ctrl+C stops its children, retaining local data."""
from pathlib import Path
import subprocess,os,json,time,signal,socket,shutil
R=Path(__file__).resolve().parents[1];B=R/'backend';private=B/'private'
(R/'www').mkdir(exist_ok=True)
if not (private/'runtime.json').exists():raise SystemExit('First use backend/tools/accept-local.py in a fresh extracted kit.')
for port in (4404,4408):
 with socket.socket() as s:
  if s.connect_ex(('127.0.0.1',port))==0:raise SystemExit('Port occupied: '+str(port)+'; no process stopped')
env=dict(os.environ);env.update(json.loads((private/'env.json').read_text()));env.update(NEXT_TELEMETRY_DISABLED='1',NEXT_PUBLIC_YOUNEW_LOCAL_REHEARSAL='true',YOUNEW_LOCAL_REHEARSAL='true')
rt=json.loads((private/'runtime.json').read_text());assert rt['datadir']==str(private/'database') and rt['socket']==str(private/'db.sock')
node=os.environ.get('NODE_BINARY') or shutil.which('node');php=os.environ.get('R4_PHP_BIN','/opt/homebrew/opt/php@8.3/bin/php');processes=[]
def launch(name,args,cwd=R):
 with (private/(name+'.log')).open('a') as log:p=subprocess.Popen(args,cwd=cwd,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
 processes.append(p);return p
try:
 if not Path(rt['socket']).exists():
  db=launch('database',[rt['prefix']+'/bin/mariadbd','--no-defaults','--basedir='+rt['prefix'],'--datadir='+rt['datadir'],'--socket='+rt['socket'],'--skip-networking','--pid-file='+str(private/'db.pid'),'--skip-log-bin','--event-scheduler=OFF','--local-infile=0','--innodb-buffer-pool-size=64M','--innodb-log-file-size=16M','--max-connections=15','--sql-mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION','--character-set-server=utf8mb4','--collation-server=utf8mb4_unicode_ci'])
  rt['pid']=db.pid;(private/'runtime.json').write_text(json.dumps(rt))
  for _ in range(100):
   if Path(rt['socket']).exists():break
   time.sleep(.1)
  else:raise RuntimeError('Local DB not ready')
 launch('admin',[node,'node_modules/next/dist/bin/next','start','-H','127.0.0.1','-p','4404'],B/'source/admin-dashboard')
 launch('web-php',[php,'-n','-d','disable_functions=mail','-S','127.0.0.1:4408','-t',str(R/'www'),str(R/'tools/integration-router.php')])
 print('Local Admin http://127.0.0.1:4404/content ; web/PHP http://127.0.0.1:4408/ ; no automatic worker or cron',flush=True)
 while all(p.poll() is None for p in processes):time.sleep(1)
except KeyboardInterrupt:pass
finally:
 for p in reversed(processes):
  if p.poll() is None:os.killpg(p.pid,signal.SIGTERM)
