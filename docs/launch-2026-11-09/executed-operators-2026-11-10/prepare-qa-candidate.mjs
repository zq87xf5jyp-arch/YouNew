import assert from 'node:assert/strict';
import * as fs from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
const source='/home/u246392949/domains/qa-catalog.younew.nl/younew-private/launch-source';
const qa='/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1';
const e=process.env,sha=b=>createHash('sha256').update(b).digest('hex');
let c,phase='guard';
try {
  assert.equal(e.R4_DB_NAME,'u246392949_younq1');assert.equal(e.R4_DB_USER,e.R4_DB_NAME);
  assert.equal(e.R4_DB_HOST,'127.0.0.1');assert.equal(e.R4_LOCAL,'false');
  await fs.access(qa+'/QA_PAUSED');
  const {schemaInventory,writeLogicalDump}=await import(source+'/hostinger/deployment/backup-qa.mjs');
  const {fingerprintRows}=await import(source+'/hostinger/deployment/restore-qa.mjs');
  const mysql=createRequire(process.cwd()+'/package.json')('mysql2/promise');
  const options={host:e.R4_DB_HOST,port:3306,user:e.R4_DB_USER,password:e.R4_DB_PASSWORD};
  c=await mysql.createConnection({...options,database:e.R4_DB_NAME,charset:'utf8mb4_unicode_ci',dateStrings:true,connectTimeout:5000});
  const [prior]=await c.query('SELECT version,sha256 FROM schema_migrations ORDER BY version');
  assert.deepEqual(prior.map(r=>r.version),['0001_core.sql','0002_catalog.sql']);
  const dir=source+'/hostinger/runtime/backend/db/migrations';
  for(const m of prior)assert.equal(m.sha256,sha(await fs.readFile(dir+'/'+m.version)));
  const schema=await schemaInventory(c,e.R4_DB_NAME);
  const fingerprints=await fingerprintRows(c,schema.tables.map(t=>t.TABLE_NAME));
  const directory=qa+'/backups/pre-cf6ab6f-'+new Date().toISOString().replaceAll(/[:.]/g,'-');
  phase='backup';
  const dump=await writeLogicalDump({directory,database:e.R4_DB_NAME,options});
  assert.deepEqual(await schemaInventory(c,e.R4_DB_NAME),schema);
  assert.deepEqual(await fingerprintRows(c,schema.tables.map(t=>t.TABLE_NAME)),fingerprints);
  const configFiles=[];
  async function preserve(path,name){const data=await fs.readFile(path);await fs.writeFile(directory+'/'+name,data,{flag:'wx',mode:0o600});assert.equal(sha(await fs.readFile(directory+'/'+name)),sha(data));configFiles.push({source:path,copy:name,sha256:sha(data),bytes:data.length});}
  await preserve('/home/u246392949/domains/qa-admin.younew.nl/younew-private/launch.env','qa-launch.env.private');
  const config='/home/u246392949/domains/qa-runtime.younew.nl/hbuilds/config';
  for(const n of await fs.readdir(config)){const st=await fs.lstat(config+'/'+n);assert.ok(st.isFile()&&!st.isSymbolicLink()&&st.size<1048576);await preserve(config+'/'+n,'hbuilds-'+n+'.private');}
  await fs.writeFile(directory+'/manifest.private.json',JSON.stringify({at:new Date().toISOString(),schema,fingerprints,dump,configFiles,qaCronPaused:true},null,2)+'\n',{flag:'wx',mode:0o600});
  phase='additive-migrations';
  for(const version of ['0003_legacy_preservation.sql','0004_legacy_assets.sql']){
    const sql=await fs.readFile(dir+'/'+version,'utf8');
    for(const statement of sql.split(';').map(s=>s.trim()).filter(Boolean))await c.query(statement);
    await c.execute('INSERT INTO schema_migrations(version,sha256) VALUES(?,?)',[version,sha(sql)]);
  }
  const report={status:'QA_SCHEMA_READY',directory,dump,configFiles:configFiles.length,originalTableCount:schema.tables.length,migrationsApplied:2,originalRowsDeleted:0,qaCronPaused:true};
  await fs.writeFile(directory+'/result.json',JSON.stringify(report,null,2)+'\n',{flag:'wx',mode:0o600});
  console.log(JSON.stringify(report));
}catch(error){console.error(JSON.stringify({status:'STOPPED',phase,code:error.code??'GUARD_OR_VERIFICATION_FAILED'}));process.exitCode=1;}
finally{await c?.end();}
