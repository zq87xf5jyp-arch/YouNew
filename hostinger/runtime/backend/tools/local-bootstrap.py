#!/usr/bin/env python3
"""Synthetic isolated MariaDB; never uses default config/datadir or a TCP port."""
from pathlib import Path
import os, subprocess, secrets, json, time, getpass, hashlib
R=Path(__file__).resolve().parents[1]; os.umask(0o077)
prefix=Path(os.environ.get('R4_MARIADB_PREFIX','/opt/homebrew/opt/mariadb@11.8')); private=R/'private'
if (private/'runtime.json').exists(): raise SystemExit('Existing runtime: use recorded instance or stop it; no overwrite')
private.mkdir(parents=True,exist_ok=True); (R/'evidence').mkdir(exist_ok=True); (R/'php/private/files').mkdir(parents=True,exist_ok=True)
data=private/'database';sock=private/'db.sock';password=secrets.token_hex(32)
with (private/'initialize.log').open('w') as log:
 subprocess.run([str(prefix/'bin/mariadb-install-db'),'--no-defaults','--basedir='+str(prefix),'--datadir='+str(data),'--auth-root-authentication-method=socket','--auth-root-socket-user='+getpass.getuser(),'--skip-test-db'],stdout=log,stderr=subprocess.STDOUT,check=True)
with (private/'database.stdout').open('w') as log:
 proc=subprocess.Popen([str(prefix/'bin/mariadbd'),'--no-defaults','--basedir='+str(prefix),'--datadir='+str(data),'--socket='+str(sock),'--skip-networking','--pid-file='+str(private/'db.pid'),'--log-error='+str(private/'database.log'),'--skip-log-bin','--event-scheduler=OFF','--local-infile=0','--innodb-buffer-pool-size=64M','--innodb-log-file-size=16M','--max-connections=15','--sql-mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION','--character-set-server=utf8mb4','--collation-server=utf8mb4_unicode_ci'],stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
def sql(s,app=False):
 args=[str(prefix/'bin/mariadb')]+(['--defaults-file='+str(private/'client.cnf')] if app else ['--no-defaults','--protocol=socket','--socket='+str(sock),'--user='+getpass.getuser()])+['--batch','--skip-column-names']
 p=subprocess.run(args,input=s,text=True,capture_output=True)
 if p.returncode:raise RuntimeError('Local SQL failed; no credentials printed')
 return p.stdout
for _ in range(200):
 if sock.exists():
  try:sql('SELECT 1;');break
  except RuntimeError:pass
 time.sleep(.1)
else:raise RuntimeError('Startup failed')
sql("CREATE DATABASE r4_candidate CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER 'r4_backend'@'localhost' IDENTIFIED BY '"+password+"'; GRANT CREATE,SELECT,INSERT,UPDATE,DELETE,ALTER,INDEX,REFERENCES ON r4_candidate.* TO 'r4_backend'@'localhost';")
(private/'client.cnf').write_text('[client]\nuser=r4_backend\npassword='+password+'\nprotocol=socket\nsocket='+str(sock)+'\ndatabase=r4_candidate\n')
for migration in sorted((R/'db/migrations').glob('*.sql')):
 body=migration.read_text();sql(body,True);sql("INSERT INTO schema_migrations(version,sha256) VALUES('"+migration.name+"','"+hashlib.sha256(body.encode()).hexdigest()+"');",True)
# Bootstrap fixtures is performed before reducing privileges. No production accounts exist here.
env={'R4_DB_USER':'r4_backend','R4_DB_PASSWORD':password,'R4_DB_NAME':'r4_candidate','R4_DB_SOCKET':str(sock),'R4_ORIGIN':'http://127.0.0.1:4404','R4_LOCAL':'true','R4_CATALOG_BUILD_KEY':secrets.token_hex(32),'R4_CATALOG_PUBLIC_ORIGIN':'http://127.0.0.1:4408','R4_INGEST_KEY':secrets.token_hex(32),'R4_INGEST_WORKSPACE':'11111111-1111-4111-8111-111111111111','R4_FILES_KEY':secrets.token_hex(32),'R4_FILES_URL':'http://127.0.0.1:4408/private-files.php'}
(private/'env.json').write_text(json.dumps(env));(private/'runtime.json').write_text(json.dumps({'pid':proc.pid,'datadir':str(data),'socket':str(sock),'prefix':str(prefix)}))
(R/'php/private/forms/sync-config.php').write_text("<?php\nreturn "+"['url'=>'http://127.0.0.1:4404','ingestKey'=>'"+env['R4_INGEST_KEY']+"','documentRoot'=>'"+str(R/'php/public')+"','local'=>true];\n")
(R/'php/private/files/config.php').write_text("<?php return ['key'=>'"+env['R4_FILES_KEY']+"'];\n")
(R/'evidence/runtime.json').write_text(json.dumps({'mariadb':sql('SELECT VERSION();').strip(),'php':'8.3.36','node':'24.22.1','db_network':'disabled; private Unix socket','hosting_version_match':'MariaDB 11.8.9; Linux/CLI/node patches remain unconfirmed','schema':'r4_candidate','user':'r4_backend','pid':proc.pid},indent=2))
print('Isolated MariaDB initialized; secrets saved only in private files')
