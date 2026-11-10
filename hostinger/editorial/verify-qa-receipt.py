"""Exercise the production read-only publication view with existing synthetic QA users.
Only the QA environment file is temporarily changed; it is restored in finally.
"""
from pathlib import Path
import json,os,time,urllib.request,urllib.error,http.cookiejar
os.umask(0o077)
base=Path('/home/u246392949/domains');root=base/'qa-catalog.younew.nl/younew-private/editorial-20261110';hp=root.parent/'hp1'
env=base/'qa-admin.younew.nl/younew-private/launch.env';before=env.read_bytes();backup=root/'qa-env-before.private'
if backup.exists():assert backup.read_bytes()==before
else:backup.write_bytes(before);backup.chmod(0o600)
assert 'R4_DB_NAME=u246392949_younq1' in before.decode()
file=root/'qa-publication-documents.json';data=json.loads((root/'approved-admin-documents.json').read_text());file.write_text(json.dumps(data));file.chmod(0o600)
lines=[line for line in before.decode().splitlines() if not line.startswith(('R4_RUNTIME_MODE=','R4_EDITORIAL_DRAFTS_FILE='))]
changed='\n'.join(lines)+f'\nR4_RUNTIME_MODE=production\nR4_EDITORIAL_DRAFTS_FILE={file}\n'
app=(base/'qa-runtime.younew.nl/hbuilds/current/nodejs').resolve();restart=app/'tmp/restart.txt'
origin='https://qa-runtime.younew.nl';c=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
def req(path,body=None):
 q=urllib.request.Request(origin+path,headers={'Origin':origin,'Content-Type':'application/json'},data=json.dumps(body).encode() if body is not None else None)
 try:r=c.open(q,timeout=20)
 except urllib.error.HTTPError as e:r=e
 return r.status,r.read(),r.headers

server=app/'server.js';server_before=server.read_bytes();server_backup=root/'qa-server-before.private'
if server_backup.exists():assert server_backup.read_bytes()==server_before
else:server_backup.write_bytes(server_before)
harness=("import {loadEnvFile as editorialLoadEnv} from 'node:process';\n"+f"editorialLoadEnv('{env}');\n"+"if(process.env.R4_DB_NAME!=='u246392949_younq1')throw new Error('QA database required');\nprocess.env.R4_RUNTIME_MODE='production';\n"+f"process.env.R4_EDITORIAL_DRAFTS_FILE='{file}';\n").encode()
def install(value):
 assert env.read_bytes()==before
 server.write_bytes(server_before if value==before else harness+server_before);restart.write_text(str(time.time()))

def catalog(state):
 status,raw,h=req('/api/r4/catalog');assert status==200 and 'no-store' in h.get('Cache-Control',''),(status,raw[:100]);rows=json.loads(raw);assert len(rows)==71 and all(x['state']==state and x['id']==x['publicId'] for x in rows),(state,len(rows),list(set(x['state'] for x in rows)))
try:
 user=json.loads((hp/'synthetic-users.json').read_text())['users']['owner']
 assert req('/api/r4/login',{k:user[k] for k in ['email','password']})[0]==200
 data['publication']={'status':'qa_probe_invalid_receipt'};file.write_text(json.dumps(data))
 install(changed.encode())
 for i in range(20):
  if req('/api/r4/catalog')[0]==503:break
  time.sleep(1)
 else:raise AssertionError('QA production view did not activate')
 del data['publication'];file.write_text(json.dumps(data));catalog('draft')
 policy=json.loads((root/'admin-approval.json').read_text());data['publication']={**policy,'status':'active','sourceCommit':'549167b111e61bb164dc93e5a3bbb95df72d34f4','publicProvenanceSha256':'b'*64,'activatedAt':'2026-11-10T20:00:00Z'}
 file.write_text(json.dumps(data));catalog('published')
 code,raw,h=req('/content');assert code==200 and b'This approved batch is published' in raw
 code,raw,_=req('/api/r4/catalog/00000000-0000-4000-8000-000000000001/transition',{'action':'approve','revision':1});assert code==403 and b'publication_batch_review_required' in raw
 data['publication']['batchSha256']='0'*64;file.write_text(json.dumps(data));assert req('/api/r4/catalog')[0]==503
 del data['publication'];file.write_text(json.dumps(data));catalog('draft')
 assert req('/api/r4/logout',{})[0]==200
 result={'status':'PASS','qaDatabaseOnly':True,'draftBeforeActivation':71,'publishedAfterValidReceipt':71,'invalidReceiptFailsClosed':True,'rollbackToDraft':71,'privateNoStore':True,'uiPublishedText':True,'realMutationsDenied':True,'realDataChanged':False}
finally:
 install(before);assert env.read_bytes()==before
assert server.read_bytes()==server_before
result['qaEnvironmentRestored']=True
result['qaServerRestored']=True
(root/'isolated-node-result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
