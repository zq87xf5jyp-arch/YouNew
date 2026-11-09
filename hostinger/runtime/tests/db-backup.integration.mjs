// Explicit local integration exercise. Starts its own socket-only MariaDB;
// never reads application credentials or connects to a network database.
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { createRequire } from 'node:module';
import { createHash } from 'node:crypto';
import { createReadStream } from 'node:fs';
import * as fs from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { clientOptions, schemaInventory, writeLogicalDump } from '../../deployment/backup-qa.mjs';

if (process.argv[2] !== '--local-disposable') throw new Error('Explicit local disposable test required');
const mysql = createRequire(new URL('../backend/source/admin-dashboard/package.json', import.meta.url))('mysql2/promise');
const root = await fs.mkdtemp(join(tmpdir(), 'yn-db-'));
await fs.chmod(root, 0o700);
const socketPath = root + '/db.sock';
const dataDir = root + '/data';
let server, connection, log;
const checks = [];
const hash = data => createHash('sha256').update(JSON.stringify(data)).digest('hex');
const cliEnv = { PATH: process.env.PATH, LANG: 'C', LC_ALL: 'C' };
try {
  const setup = spawnSync('mariadb-install-db', ['--no-defaults', `--datadir=${dataDir}`, '--auth-root-authentication-method=normal', '--skip-test-db'], { env: cliEnv, encoding: 'utf8' });
  await fs.writeFile(root + '/setup.log', setup.stdout + setup.stderr, { mode: 0o600 });
  assert.equal(setup.status, 0, 'local database bootstrap');
  log = await fs.open(root + '/server.log', 'wx', 0o600);
  server = spawn('mariadbd', ['--no-defaults', `--datadir=${dataDir}`, `--socket=${socketPath}`,
    `--pid-file=${root}/db.pid`, '--skip-networking', '--skip-log-bin', '--innodb-buffer-pool-size=32M',
    '--innodb-log-file-size=16M', '--max-connections=10'], { env: cliEnv, stdio: ['ignore', log.fd, log.fd] });
  let startError;
  server.once('error', error => { startError = error; });
  for (let attempt = 0; attempt < 100 && !connection; attempt++) {
    if (startError || server.exitCode !== null) throw new Error('Local MariaDB did not stay running');
    try { connection = await mysql.createConnection({ socketPath, user: 'root', dateStrings: true, charset: 'utf8mb4_unicode_ci' }); }
    catch { await new Promise(resolve => setTimeout(resolve, 100)); }
  }
  assert.ok(connection, 'socket-only server became ready');
  const [[serverMeta]] = await connection.query('SELECT VERSION() AS version, @@skip_networking AS network_disabled');
  assert.equal(Number(serverMeta.network_disabled), 1);
  const trickyPassword = 'synthetic"\\line\nnext\r\t\b #;!';
  const optionsFile = root + '/quoted.cnf';
  await fs.writeFile(optionsFile, clientOptions({ socketPath, user: 'root', password: trickyPassword }), { mode: 0o600 });
  const defaults = spawnSync('my_print_defaults', [`--defaults-file=${optionsFile}`, 'client'], { env: cliEnv, encoding: 'utf8' });
  assert.equal(defaults.status, 0);
  assert.ok(defaults.stdout.includes('--password=' + trickyPassword + '\n'), 'native parser recovers exact password bytes');
  await fs.unlink(optionsFile);
  checks.push('native_option_file_password_roundtrip');

  await connection.query('CREATE DATABASE backup_source CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
  await connection.query('USE backup_source');
  const migrationDir = fileURLToPath(new URL('../backend/db/migrations/', import.meta.url));
  for (const file of (await fs.readdir(migrationDir)).filter(x => x.endsWith('.sql')).sort()) {
    const sql = await fs.readFile(join(migrationDir, file), 'utf8');
    for (const statement of sql.split(';').map(x => x.trim()).filter(Boolean)) await connection.query(statement);
    await connection.execute('INSERT INTO schema_migrations(version,sha256) VALUES(?,?)', [file, createHash('sha256').update(sql).digest('hex')]);
  }
  await connection.query('CREATE TABLE backup_encoding_fixture(id INT PRIMARY KEY, text_value LONGTEXT, bytes_value LONGBLOB, nullable_value TEXT) ENGINE=InnoDB');
  await connection.execute('INSERT INTO backup_encoding_fixture VALUES (?,?,?,?)', [1, 'Leiden — café 🌷\n"quotes" \\ slash', Buffer.from([0, 1, 10, 13, 255]), null]);
  const workspace = '11111111-1111-4111-8111-111111111111';
  const profile = '22222222-2222-4222-8222-222222222222';
  const inquiry = '33333333-3333-4333-8333-333333333333';
  await connection.execute('INSERT INTO workspaces VALUES (?,?)', [workspace, 'Synthetic restore workspace']);
  await connection.execute('INSERT INTO profiles VALUES (?,?,?,?,?,?,?,?)', [profile, workspace, 'restore@example.invalid', 'Synthetic owner', 'synthetic-not-an-authentication-credential', 'owner', 1, 0]);
  await connection.execute('INSERT INTO business_inquiries(id,workspace_id,receipt,payload,offer_interest,created_at,consent_at,status_changed_at,updated_at) VALUES (?,?,?,?,?,NOW(3),NOW(3),NOW(3),NOW(3))', [inquiry, workspace, 'SYNTHETIC-RESTORE-01', JSON.stringify({ name: 'Café 🌷', consent: true }), 'listing']);
  await connection.execute('INSERT INTO ingest_receipts VALUES(?,?,?,?,?,NOW(3))', ['SYNTHETIC-RESTORE-01', workspace, inquiry, '0'.repeat(64), 'synthetic-v1']);
  const beforeSchema = await schemaInventory(connection, 'backup_source');
  async function rowsFingerprint(schema) {
    const rows = [];
    for (const table of schema.tables) {
      const [data] = await connection.query('SELECT * FROM `' + table.TABLE_NAME.replaceAll('`', '``') + '`');
      rows.push({ table: table.TABLE_NAME, count: data.length, sha256: hash(data.map(row => JSON.stringify(row)).sort()) });
    }
    return rows;
  }
  const beforeRows = await rowsFingerprint(beforeSchema);
  const dump = await writeLogicalDump({ directory: root + '/backup', database: 'backup_source', options: { socketPath, user: 'root', password: '' } });
  await connection.query('CREATE DATABASE backup_restored CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
  await fs.writeFile(root + '/restore.cnf', clientOptions({ socketPath, user: 'root', password: '' }), { mode: 0o600 });
  await new Promise((resolve, reject) => {
    const child = spawn('mariadb', [`--defaults-file=${root}/restore.cnf`, '--default-character-set=utf8mb4', 'backup_restored'], { env: cliEnv, stdio: ['pipe', 'ignore', log.fd] });
    const stream = createReadStream(root + '/backup/database.sql');
    stream.on('error', reject);
    child.stdin.on('error', reject);
    child.once('error', reject);
    child.once('close', code => code === 0 ? resolve() : reject(new Error('Restore client failed')));
    stream.pipe(child.stdin);
  });
  await fs.unlink(root + '/restore.cnf');
  await connection.query('USE backup_restored');
  const afterSchema = await schemaInventory(connection, 'backup_restored');
  assert.deepEqual(afterSchema, beforeSchema, 'every restored definition and engine matches');
  assert.deepEqual(await rowsFingerprint(afterSchema), beforeRows, 'all rows match including binary, Unicode, JSON, NULL and timestamps');
  checks.push('all_migration_tables_and_definitions_restored', 'all_rows_exact_fingerprints', 'unicode_binary_json_null_timestamps_preserved');
  await connection.query('CREATE TABLE unsupported_engine(id INT) ENGINE=MyISAM');
  await assert.rejects(schemaInventory(connection, 'backup_restored'), /InnoDB/);
  checks.push('nontransactional_table_refused');
  const report = { status: 'PASS', scope: 'isolated local tool exercise; not Hostinger restore evidence', server: serverMeta,
    tables: beforeSchema.tables.length, rowCounts: beforeRows.map(({ table, count }) => ({ table, count })), dump, checks, evidenceDirectory: root };
  await fs.writeFile(root + '/report.json', JSON.stringify(report, null, 2) + '\n', { mode: 0o600, flag: 'wx' });
  console.log(JSON.stringify(report, null, 2));
} catch (error) {
  console.error('Local backup exercise failed; inspect private evidence:', root, error.message);
  process.exitCode = 1;
} finally {
  await connection?.end();
  if (server && server.exitCode === null) {
    const stopped = new Promise(resolve => server.once('close', resolve));
    server.kill('SIGTERM');
    await stopped;
  }
  await log?.close();
  // Preserve this newly created evidence for inspection; no user database is touched.
}
