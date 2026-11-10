// One-time operator script for the new, disconnected production database.
import assert from 'node:assert/strict';
import * as fs from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
import {execFileSync} from 'node:child_process';
const source='/home/u246392949/domains/qa-catalog.younew.nl/younew-private/launch-source';
const root='/home/u246392949/domains/younew.nl/younew-private/launch-production';
const commit='cf6ab6f74f65a4c9c45c62c5c209090ab8960665';
const sha=b=>createHash('sha256').update(b).digest('hex');
const e=process.env;
let c,phase='guard';
try {
  assert.deepEqual(process.argv.slice(2),['--approved-prelaunch','--no-app-traffic']);
  assert.equal(e.R4_DB_NAME,'u246392949_younp1');
  assert.equal(e.R4_DB_USER,e.R4_DB_NAME);
  assert.equal(e.R4_DB_HOST,'127.0.0.1');
  assert.equal(e.R4_LOCAL,'false');
  assert.ok(e.R4_DB_PASSWORD && !e.R4_INGEST_KEY && !e.R4_DUMMY_PASSWORD_HASH);
  assert.equal(execFileSync('git',['-C',source,'rev-parse','HEAD'],{encoding:'utf8'}).trim(),commit);
  assert.equal(sha(await fs.readFile(root+'/source-exports-20261110/legacy-complete.private.json')),'f8636c1651c3d5de483adba3e90d7f6f4c7935303fab69829be2523bce2d46e6');
  const mysql=createRequire(process.cwd()+'/package.json')('mysql2/promise');
  c=await mysql.createConnection({host:e.R4_DB_HOST,user:e.R4_DB_USER,password:e.R4_DB_PASSWORD,database:e.R4_DB_NAME,charset:'utf8mb4_unicode_ci',dateStrings:true,multipleStatements:false,connectTimeout:5000});
  const [[meta]]=await c.query('SELECT VERSION() AS version,DATABASE() AS db');
  assert.equal(meta.db,e.R4_DB_NAME);assert.ok(meta.version.startsWith('11.8.9-'));
  const [tables]=await c.query('SHOW TABLES');assert.equal(tables.length,0);
  const dir=source+'/hostinger/runtime/backend/db/migrations';
  const names=(await fs.readdir(dir)).filter(n=>/^\d+_.*\.sql$/.test(n)).sort();
  assert.deepEqual(names,['0001_core.sql','0002_catalog.sql','0003_legacy_preservation.sql','0004_legacy_assets.sql']);
  const migrations=await Promise.all(names.map(async version=>{const sql=await fs.readFile(dir+'/'+version,'utf8');return{version,sql,sha256:sha(sql)};}));
  await fs.writeFile(root+'/initialization-intent.private.json',JSON.stringify({at:new Date().toISOString(),commit,meta,originalTables:0,migrations:migrations.map(({version,sha256})=>({version,sha256})),seed:false},null,2)+'\n',{flag:'wx',mode:0o600});
  phase='schema';
  await c.query("SET SESSION sql_mode='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION',time_zone='+00:00'");
  for(const m of migrations){
    for(const statement of m.sql.split(';').map(s=>s.trim()).filter(Boolean))await c.query(statement);
    await c.execute('INSERT INTO schema_migrations(version,sha256) VALUES(?,?)',[m.version,m.sha256]);
  }
  const [applied]=await c.query('SELECT version,sha256 FROM schema_migrations ORDER BY version');
  assert.deepEqual(applied,migrations.map(({version,sha256})=>({version,sha256})));
  const [created]=await c.query('SHOW TABLES');assert.equal(created.length,16);
  const report={status:'SCHEMA_READY',commit,database:meta.db,migrations:applied.length,tables:created.length,seed:false,at:new Date().toISOString()};
  await fs.writeFile(root+'/initialization-result.json',JSON.stringify(report,null,2)+'\n',{flag:'wx',mode:0o600});
  console.log(JSON.stringify(report));
}catch(error){console.error(JSON.stringify({status:'STOPPED',phase,code:error.code??'GUARD_OR_VERIFICATION_FAILED'}));process.exitCode=1;}
finally{await c?.end();}
