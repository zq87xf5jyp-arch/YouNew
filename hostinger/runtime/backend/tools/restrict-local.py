from pathlib import Path
import json,subprocess,getpass
r=Path(__file__).resolve().parents[1];runtime=json.loads((r/'private/runtime.json').read_text());
s="REVOKE ALL PRIVILEGES ON r4_candidate.* FROM 'r4_backend'@'localhost';\n"
rights={'catalog_places':'SELECT,INSERT,UPDATE','schema_migrations':'SELECT','workspaces':'SELECT','profiles':'SELECT','sessions':'SELECT,INSERT,UPDATE,DELETE','auth_attempts':'SELECT,INSERT,UPDATE,DELETE','business_inquiries':'SELECT,INSERT,UPDATE','ingest_receipts':'SELECT,INSERT','ingest_nonces':'SELECT,INSERT,DELETE','business_inquiry_notifications':'SELECT,INSERT,UPDATE','audit_events':'SELECT,INSERT','private_files':'SELECT,INSERT'}
for table,grants in rights.items():s+=f"GRANT {grants} ON r4_candidate.{table} TO 'r4_backend'@'localhost';\n"
a=[runtime['prefix']+'/bin/mariadb','--no-defaults','--protocol=socket','--socket='+runtime['socket'],'--user='+getpass.getuser()]
p=subprocess.run(a,input=s,text=True,capture_output=True);assert p.returncode==0,'Local restriction failed'
(r/'evidence/local-runtime-grants.json').write_text(json.dumps({'user':'r4_backend','grants':rights,'hostinger_actual_grants':'NOT_CONFIRMED','ddl_at_runtime':False},indent=2));print('Runtime restricted to table-scoped DML; no DDL or grant authority')
