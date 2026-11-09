// Initial synthetic QA only. Preserve all original tables; never DROP or overwrite.
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { createHash, randomBytes } from 'node:crypto';
import { createReadStream } from 'node:fs';
import * as fs from 'node:fs/promises';
import { spawn } from 'node:child_process';
import { resolve, dirname } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { QA_DATABASE, clientOptions, schemaInventory } from './backup-qa.mjs';

const PRIVATE_ROOT = '/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1';
const quote = value => '`' + value.replaceAll('`', '``') + '`';
const digest = value => createHash('sha256').update(JSON.stringify(value)).digest('hex');

export async function fingerprintRows(connection, names, prefix = '') {
  const rows = [];
  for (const table of names) {
    const [data] = await connection.query('SELECT * FROM ' + quote(prefix + table));
    rows.push({ table, count: data.length, sha256: digest(data.map(row => JSON.stringify(row)).sort()) });
  }
  return rows;
}

async function fileHash(path) {
  const hash = createHash('sha256');
  for await (const chunk of createReadStream(path)) hash.update(chunk);
  return hash.digest('hex');
}

// Caller must establish isolated scope, no writers and trusted dump before use.
export async function restorePreservingTables({ connection, database, options, dumpPath, schema, directory, executable = 'mariadb' }) {
  assert.match(database, /^[a-zA-Z0-9_]+$/);
  assert.ok(schema.tables.length > 0 && schema.tables.every(t => t.TABLE_TYPE === 'BASE TABLE' && t.ENGINE === 'InnoDB'));
  const names = schema.tables.map(t => t.TABLE_NAME);
  assert.ok(names.every(n => /^[a-z][a-z0-9_]{0,39}$/.test(n)), 'review unexpected table identifiers');
  assert.deepEqual(await schemaInventory(connection, database), schema, 'source definitions changed since dump');
  const beforeRows = await fingerprintRows(connection, names);
  const prefix = 'restore_hold_' + randomBytes(4).toString('hex') + '_';
  await fs.mkdir(directory, { mode: 0o700 }); // New attempt only.
  const originalTables = names.map(name => ({ original: name, preserved: prefix + name }));
  const intent = { database, startedAt: new Date().toISOString(), originalTables, beforeRows, originalTablesDeleted: false };
  await fs.writeFile(directory + '/intent.private.json', JSON.stringify(intent, null, 2) + '\n', { flag: 'wx', mode: 0o600 });
  const defaults = directory + '/client.cnf';
  await fs.writeFile(defaults, clientOptions(options), { flag: 'wx', mode: 0o600 });
  let log;
  try {
    log = await fs.open(directory + '/restore.stderr.private', 'wx', 0o600);
    // Atomic name switch. Foreign keys among the preserved tables follow the rename.
    await connection.query('RENAME TABLE ' + originalTables.map(t => quote(t.original) + ' TO ' + quote(t.preserved)).join(', '));
    await new Promise((accept, reject) => {
      const child = spawn(executable, [`--defaults-file=${defaults}`, '--default-character-set=utf8mb4', database], {
        env: { PATH: process.env.PATH, LANG: 'C', LC_ALL: 'C' }, stdio: ['pipe', 'ignore', log.fd], shell: false,
      });
      const input = createReadStream(dumpPath);
      input.once('error', reject);
      child.stdin.once('error', reject);
      child.once('error', reject);
      child.once('close', code => { input.destroy(); code === 0 ? accept() : reject(new Error('Restore client failed')); });
      input.pipe(child.stdin);
    });
    const after = await schemaInventory(connection, database);
    assert.deepEqual(after.tables.map(t => t.TABLE_NAME).sort(), [...names, ...names.map(n => prefix + n)].sort(), 'unexpected tables appeared');
    const restored = {
      tables: after.tables.filter(t => names.includes(t.TABLE_NAME)),
      definitions: after.definitions.filter(d => names.includes(d.Table)),
    };
    assert.deepEqual(restored, schema, 'restored definitions differ');
    assert.deepEqual(await fingerprintRows(connection, names), beforeRows, 'restored rows differ');
    assert.deepEqual(await fingerprintRows(connection, names, prefix), beforeRows, 'preserved original rows changed');
    const report = { ...intent, status: 'PASS', completedAt: new Date().toISOString(),
      restoredTables: names.length, restoredRows: beforeRows.reduce((n, t) => n + t.count, 0),
      definitionsMatch: true, restoredRowsMatch: true, preservedRowsMatch: true };
    await fs.writeFile(directory + '/report.private.json', JSON.stringify(report, null, 2) + '\n', { flag: 'wx', mode: 0o600 });
    return report;
  } finally {
    await log?.close();
    await fs.unlink(defaults);
    // Failed attempts, partial restored tables and originals are all retained.
  }
}

export function assertRestoreTarget(env, args) {
  if (args.length !== 3 || args[0] !== '--synthetic-qa-only' || args[1] !== '--no-app-traffic' ||
      env.R4_DB_NAME !== QA_DATABASE || env.R4_DB_USER !== QA_DATABASE || env.R4_DB_HOST !== '127.0.0.1' ||
      env.R4_LOCAL !== 'false' ||
      !env.R4_DB_PASSWORD ||
      env.R4_INGEST_KEY ||
      env.R4_DUMMY_PASSWORD_HASH) {
    throw new Error('Initial isolated synthetic QA with no application credentials required');
  }
}

async function main() {
  const args = process.argv.slice(2);
  assertRestoreTarget(process.env, args);
  const backupDirectory = await fs.realpath(args[2]);
  assert.equal(dirname(backupDirectory), PRIVATE_ROOT + '/backups');
  const manifest = JSON.parse(await fs.readFile(backupDirectory + '/manifest.private.json', 'utf8'));
  assert.equal(manifest.status, 'BACKUP_WRITTEN_RESTORE_PENDING');
  assert.equal(manifest.server.db, QA_DATABASE);
  assert.equal(manifest.dump.file, 'database.sql');
  const dumpPath = backupDirectory + '/database.sql';
  assert.equal(await fileHash(dumpPath), manifest.dump.sha256);
  const mysql = createRequire(process.cwd() + '/package.json')('mysql2/promise');
  const options = { host: '127.0.0.1', port: 3306, user: process.env.R4_DB_USER, password: process.env.R4_DB_PASSWORD };
  const connection = await mysql.createConnection({ ...options, database: QA_DATABASE, charset: 'utf8mb4_unicode_ci', dateStrings: true, connectTimeout: 5000 });
  try {
    const [[meta]] = await connection.query('SELECT VERSION() AS version, DATABASE() AS db');
    assert.ok(meta.version.startsWith('11.8.9-') && meta.db === QA_DATABASE);
    const schema = await schemaInventory(connection, QA_DATABASE);
    assert.deepEqual(schema, manifest.schema);
    const directory = dirname(fileURLToPath(import.meta.url));
    const migrationDirectory = await fs.stat(directory + '/migrations').then(() => directory + '/migrations').catch(error => {
      if (error.code !== 'ENOENT') throw error;
      return resolve(directory, '../runtime/backend/db/migrations');
    });
    const [migrations] = await connection.query('SELECT version,sha256 FROM schema_migrations ORDER BY version');
    const files = (await fs.readdir(migrationDirectory)).filter(f => /^\d+_.*\.sql$/.test(f)).sort();
    assert.deepEqual(migrations.map(m => m.version), files);
    for (const migration of migrations) assert.equal(migration.sha256, await fileHash(migrationDirectory + '/' + migration.version));
    const [spaces] = await connection.query('SELECT id,name FROM workspaces ORDER BY id');
    assert.deepEqual(spaces.map(s => [s.id,s.name]), [
      ['11111111-1111-4111-8111-111111111111','Synthetic Hostinger QA 0'],
      ['22222222-2222-4222-8222-222222222222','Synthetic Hostinger QA 1'],
    ]);
    const seed = JSON.parse(await fs.readFile(PRIVATE_ROOT + '/synthetic-users.json', 'utf8'));
    const [profiles] = await connection.query('SELECT id,email,full_name FROM profiles ORDER BY id');
    const expected = Object.entries(seed.users).map(([name, u]) => ({id:u.id,email:name+'@example.invalid',full_name:'Synthetic '+name})).sort((a,b) => a.id.localeCompare(b.id));
    assert.equal(expected.length, 8);
    assert.deepEqual(profiles, expected);
    const counts = await fingerprintRows(connection, schema.tables.map(t => t.TABLE_NAME));
    assert.equal(schema.tables.length, 12);
    assert.ok(counts.filter(t => !['schema_migrations','workspaces','profiles'].includes(t.table)).every(t => t.count === 0), 'QA traffic or unexpected data exists');
    const restoreDirectory = backupDirectory + '/restore-preserved';
    const report = await restorePreservingTables({ connection, database: QA_DATABASE, options, dumpPath, schema, directory: restoreDirectory });
    console.log(JSON.stringify({ status: report.status, directory: restoreDirectory, restoredTables: report.restoredTables,
      restoredRows: report.restoredRows, originalsPreserved: true, scope: 'initial synthetic Hostinger QA only' }));
  } finally { await connection.end(); }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch(() => { console.error('QA restore stopped; keep app traffic disabled. Original tables and private attempt evidence are retained.'); process.exitCode = 1; });
}
