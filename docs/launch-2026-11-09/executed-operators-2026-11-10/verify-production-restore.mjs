// Rehearsal on the disconnected prelaunch DB; every original table is retained.
import assert from 'node:assert/strict';
import * as fs from 'node:fs/promises';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';
const source='/home/u246392949/domains/qa-catalog.younew.nl/younew-private/launch-source';
const root='/home/u246392949/domains/younew.nl/younew-private/launch-production';
const commit='cf6ab6f74f65a4c9c45c62c5c209090ab8960665';
const sha=b=>createHash('sha256').update(b).digest('hex');
const bundleSha='f8636c1651c3d5de483adba3e90d7f6f4c7935303fab69829be2523bce2d46e6';
const e=process.env;
let c,phase='guard',directory;
try {
  assert.deepEqual(process.argv.slice(2),['--approved-prelaunch','--no-app-traffic']);
  assert.equal(e.R4_DB_NAME,'u246392949_younp1');assert.equal(e.R4_DB_USER,e.R4_DB_NAME);
  assert.equal(e.R4_DB_HOST,'127.0.0.1');assert.equal(e.R4_LOCAL,'false');
  assert.ok(e.R4_DB_PASSWORD&&!e.R4_INGEST_KEY&&!e.R4_DUMMY_PASSWORD_HASH);
  assert.equal(execFileSync('git',['-C',source,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),commit);
  const {schemaInventory,writeLogicalDump}=await import(source+'/hostinger/deployment/backup-qa.mjs');
  const {fingerprintRows,restorePreservingTables}=await import(source+'/hostinger/deployment/restore-qa.mjs');
  const {importData,plan}=await import(source+'/hostinger/deployment/import-legacy.mjs');
  const bytes=await fs.readFile(root+'/source-exports-20261110/legacy-complete.private.json');assert.equal(sha(bytes),bundleSha);
  const bundle=JSON.parse(bytes),expected=plan(bundle);
  const mysql=createRequire(process.cwd()+'/package.json')('mysql2/promise');
  const options={host:e.R4_DB_HOST,port:3306,user:e.R4_DB_USER,password:e.R4_DB_PASSWORD};
  c=await mysql.createConnection({...options,database:e.R4_DB_NAME,charset:'utf8mb4_unicode_ci',dateStrings:true,multipleStatements:false,connectTimeout:5000});
  await c.query("SET time_zone='+00:00'");
  const [[meta]]=await c.query('SELECT VERSION() AS version,DATABASE() AS db');
  assert.equal(meta.db,e.R4_DB_NAME);assert.ok(meta.version.startsWith('11.8.9-'));
  const schema=await schemaInventory(c,e.R4_DB_NAME);assert.equal(schema.tables.length,16);
  const [migrations]=await c.query('SELECT version,sha256 FROM schema_migrations ORDER BY version');assert.equal(migrations.length,4);
  for(const migration of migrations)assert.equal(migration.sha256,sha(await fs.readFile(source+'/hostinger/runtime/backend/db/migrations/'+migration.version)));
  const [profiles]=await c.query('SELECT * FROM profiles');assert.equal(profiles.length,4);
  for(const p of expected.profiles){const row=profiles.find(r=>r.id===p.id);assert.ok(row);for(const [key,value]of Object.entries(p))assert.equal(typeof value==='boolean'?!!row[key]:row[key],value);}
  const beforeRows=await fingerprintRows(c,schema.tables.map(t=>t.TABLE_NAME));
  const expectedCounts={schema_migrations:4,workspaces:1,profiles:4,business_inquiries:3,legacy_imports:1,legacy_tables:90,legacy_rows:1396,legacy_assets:1};
  for(const row of beforeRows)assert.equal(row.count,expectedCounts[row.table]??0);
  assert.equal((await importData(c,bundle,bundleSha)).status,'VERIFIED_ALREADY_IMPORTED');
  phase='backup';
  directory='/home/u246392949/domains/younew.nl/younew-private/launch-backups/production-db-prelaunch-'+new Date().toISOString().replaceAll(/[:.]/g,'-');
  const dump=await writeLogicalDump({directory,database:e.R4_DB_NAME,options});
  assert.deepEqual(await schemaInventory(c,e.R4_DB_NAME),schema);
  assert.deepEqual(await fingerprintRows(c,schema.tables.map(t=>t.TABLE_NAME)),beforeRows);
  await fs.writeFile(directory+'/manifest.private.json',JSON.stringify({commit,meta,dump,schema,beforeRows,sourceBundle:bundleSha,appTraffic:false},null,2)+'\n',{flag:'wx',mode:0o600});
  assert.equal(sha(await fs.readFile(directory+'/database.sql')),dump.sha256);
  phase='restore';
  const restored=await restorePreservingTables({connection:c,database:e.R4_DB_NAME,options,dumpPath:directory+'/database.sql',schema,directory:directory+'/restore-preserved'});
  phase='post-restore';
  assert.equal((await importData(c,bundle,bundleSha)).status,'VERIFIED_ALREADY_IMPORTED');
  const [[sessions]]=await c.query('SELECT COUNT(*) AS total FROM sessions');assert.equal(sessions.total,0);
  const report={status:'PASS',at:new Date().toISOString(),commit,database:e.R4_DB_NAME,directory,dump,restoredTables:restored.restoredTables,restoredRows:restored.restoredRows,definitionsMatch:restored.definitionsMatch,restoredRowsMatch:restored.restoredRowsMatch,preservedRowsMatch:restored.preservedRowsMatch,originalTablesDeleted:false,legacyArchiveVerified:true,profilesPreserved:4,inquiriesPreserved:3,assetsPreserved:1,sessionsImported:0,scope:'disconnected prelaunch database only'};
  await fs.writeFile(root+'/backup-restore-result.json',JSON.stringify(report,null,2)+'\n',{flag:'wx',mode:0o600});
  await fs.writeFile(directory+'/verified-result.json',JSON.stringify(report,null,2)+'\n',{flag:'wx',mode:0o600});
  console.log(JSON.stringify(report));
}catch(error){console.error(JSON.stringify({status:'STOPPED',phase,directory,code:error.code??'GUARD_OR_VERIFICATION_FAILED',originalTablesDeleted:false}));process.exitCode=1;}
finally{await c?.end();}
