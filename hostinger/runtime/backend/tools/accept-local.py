#!/usr/bin/env python3
"""Fresh isolated acceptance. Requires installed MariaDB, Node24, pnpm, PHP8.3; installs no services."""
from pathlib import Path
import os,sys,subprocess,time,json,signal,shutil,socket
R=Path(__file__).resolve().parents[1];os.umask(0o077)
if (R/'private/runtime.json').exists():raise SystemExit('Use a fresh extracted kit; existing data is never reset')
for port in [4408,4404]:
 with socket.socket() as s:
  if s.connect_ex(('127.0.0.1',port))==0:raise SystemExit('Required loopback port is already in use: '+str(port))
for d in ['private','evidence']:(R/d).mkdir(exist_ok=True)
(R/'private').chmod(0o700)
processes=[];steps=[];php=os.environ.get('R4_PHP_BIN','/opt/homebrew/opt/php@8.3/bin/php')
nodeDir='/Users/ivan/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin'
env=os.environ.copy();env['PATH']=(nodeDir+':' if Path(nodeDir).exists() else '')+env['PATH'];env['NEXT_TELEMETRY_DISABLED']='1';env['R4_PHP_BIN']=php;env['YOUNEW_LOCAL_NO_BUILD_CACHE']='1';env['NEXT_PUBLIC_YOUNEW_LOCAL_REHEARSAL']='true'
node=shutil.which('node',path=env['PATH']);pnpm=shutil.which('pnpm',path=env['PATH'])
if not node or not pnpm or not subprocess.check_output([node,'--version'],env=env,text=True).startswith('v24.'):raise SystemExit('Node24 + pnpm required')
def run(name,args,cwd=R,extra=None):
 log=R/'evidence'/(name+'.log');t=time.time()
 with log.open('w') as f:p=subprocess.run(args,cwd=cwd,env=extra or env,stdout=f,stderr=subprocess.STDOUT)
 steps.append({'step':name,'exit':p.returncode,'seconds':round(time.time()-t,2)});print(name,p.returncode,flush=True)
 if p.returncode:raise RuntimeError(name+' failed; see '+str(log))
def launch(name,args,cwd,env):
 log=(R/'private'/(name+'.log')).open('w');p=subprocess.Popen(args,cwd=cwd,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True);log.close();processes.append(p);return p
result={}
try:
 run('01-bootstrap',[sys.executable,str(R/'tools/local-bootstrap.py')]);
 runtimeEnv=env.copy();runtimeEnv.update(json.loads((R/'private/env.json').read_text()));a=R/'source/admin-dashboard'
 run('02-installed-dependencies',[node,'-e',"console.log(require('next/package.json').version);require('mysql2/promise');require('zod')"],a)
 run('03-synthetic-users',[node,'scripts/r4-seed.mjs'],a,runtimeEnv)
 runtimeEnv.update(json.loads((R/'private/env.json').read_text()))
 run('04-synthetic-objects',[node,'scripts/r4-seed-objects.mjs'],a,runtimeEnv)
 run('04a-catalog-drafts',[node,'scripts/integration-seed.mjs'],a,runtimeEnv)
 run('05-minimal-grants',[sys.executable,str(R/'tools/restrict-local.py')])
 run('06-migration-repeat',[node,'scripts/r4-migrate.mjs'],a,runtimeEnv)
 run('07-production-build',[node,'node_modules/next/dist/bin/next','build'],a,runtimeEnv)
 phpEnv=env.copy();phpEnv['YOUNEW_LOCAL_REHEARSAL']='true'
 launch('php',[php,'-n','-d','disable_functions=mail','-S','127.0.0.1:4408','-t',str(R/'php/public'),str(R/'php/router.php')],R,phpEnv)
 launch('admin',[node,'node_modules/next/dist/bin/next','start','-H','127.0.0.1','-p','4404'],a,runtimeEnv)
 for _ in range(100):
  with socket.socket() as s:
   if s.connect_ex(('127.0.0.1',4404))==0:break
  time.sleep(.1)
 else:raise RuntimeError('Admin did not listen')
 run('08-security-http',[sys.executable,str(R/'tests/security-http.py')])
 run('08a-form-origins',[sys.executable,str(R/'tests/form-origin-http.py')])
 run('09-server-actions',[sys.executable,str(R/'tests/server-actions-http.py')])
 run('10-transaction-delivery',[sys.executable,str(R/'tests/delivery-http.py')])
 run('11-catalog-http',[sys.executable,str(R/'tests/catalog-http.py')])
 result={'status':'PASS','steps':steps,'scope':'Fresh isolated install/build and API/Server Actions/PHP/MariaDB tests; Hostinger cron NOT_RUN'}
except Exception as e:result={'status':'FAIL','steps':steps,'error':str(e)};raise
finally:
 for p in processes:
  if p.poll() is None:
   os.killpg(p.pid,signal.SIGTERM)
   try:p.wait(timeout=10)
   except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL)
 if (R/'private/runtime.json').exists():
  rt=json.loads((R/'private/runtime.json').read_text());cmd=subprocess.run(['ps','-p',str(rt['pid']),'-o','command='],capture_output=True,text=True).stdout
  if rt['datadir'] in cmd and 'mariadbd' in cmd:
   os.kill(rt['pid'],signal.SIGTERM)
 result['local_servers_stop_requested']=True
 (R/'evidence/fresh-acceptance.json').write_text(json.dumps(result,indent=2))
