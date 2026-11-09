#!/usr/bin/env python3
"""Create exact local upload manifests (default) or archives (--archive). Never contacts a host."""
from pathlib import Path
import json,hashlib,tarfile,sys
R=Path(__file__).resolve().parents[2];K=R/'hostinger/runtime';D=R/'hostinger/deployment'
skip={'node_modules','.next','out','dist','.git','private','publication','DerivedData','evidence','__pycache__'}
def tree(base):
 return [p for p in base.rglob('*') if p.is_file() and not p.is_symlink() and not any(x in skip for x in p.relative_to(base).parts) and p.name not in ['.DS_Store','tsconfig.tsbuildinfo'] and not p.name.startswith('.env')]
node=[]
for p in tree(K/'backend/source/admin-dashboard'):node.append((p,str(p.relative_to(K/'backend/source/admin-dashboard'))))
for p in tree(R):
 if p.relative_to(R).parts[0] not in {'hostinger','docs'}:
  node.append((p,'catalog-builder/source/'+str(p.relative_to(R))))
for p in [K/'tools/publish-catalog.mjs',K/'tools/export-approved.mjs'] :node.append((p,'catalog-builder/tools/'+p.name))
node.append((K/'backend/db/catalog-drafts.json','catalog-builder/backend/db/catalog-drafts.json'))
for name in ['host-preflight.mjs','init-qa.mjs']:node.append((D/name,'ops/'+name))
for p in (K/'backend/db/migrations').glob('*.sql'):node.append((p,'ops/migrations/'+p.name))
php=[]
for rel in ['public/submit-business-inquiry.php','public/api/submit-business-inquiry.php','public/private-files.php','private/forms/service.php','private/forms/sync.php']:php.append((K/'backend/php'/rel,'younew-private/hp1/kit/backend/php/'+rel))
php.append((K/'tools/integration-router.php','younew-private/hp1/kit/tools/integration-router.php'))
for name in ['cron-business.sh','cron-catalog.sh','cron-initialize.sh','php-preflight.php','sync-config.php.example','origins.php.example']:php.append((D/name,'younew-private/hp1/deployment/'+name))
php.extend([(D/'index.php','public_html/index.php'),(D/'htaccess.template','public_html/.htaccess')])
for label,items in [('node-app',node),('php-site',php)]:
 manifest=[{'source':str(p.relative_to(R)),'destination':dest,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size} for p,dest in sorted(items,key=lambda x:x[1])]
 (D/(label+'-files.json')).write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
 if '--archive' in sys.argv:
  dest=D/(label+'.tar.gz')
  if dest.exists():raise SystemExit('Archive exists; do not overwrite')
  with tarfile.open(dest,'w:gz') as tar:
   for p,name in items:tar.add(p,arcname=name,recursive=False)
 print(label,len(items),'files; no runtime secrets, queues or databases')
