// Operator-only logical backup. Never invoked by app startup or a public endpoint.
// Keep schema changes paused for the entire operation; restore separately.
import { createRequire } from 'node:module';
import { createHash, randomUUID } from 'node:crypto';
import { createReadStream } from 'node:fs';
import * as fs from 'node:fs/promises';
import { spawn } from 'node:child_process';
import { pathToFileURL } from 'node:url';

export const QA_DATABASE = 'u246392949_younq1';
const PRIVATE_ROOT = '/home/u246392949/domains/qa-catalog.younew.nl/younew-private/hp1';

export function assertQaTarget(env, args) {
  if (args.length !== 2 || !args.includes('--approved-qa') || !args.includes('--no-schema-changes') ||
      env.R4_DB_NAME !== QA_DATABASE || env.R4_DB_USER !== QA_DATABASE ||
      env.R4_DB_HOST !== '127.0.0.1' || env.R4_LOCAL !== 'false' || !env.R4_DB_PASSWORD) {
    throw new Error('Explicit isolated QA target and schema-change freeze required');
  }
}

// MariaDB option-file quoting, not shell quoting. The password never enters argv.
export function optionValue(value) {
  if (typeof value !== 'string' || value.includes('\0')) throw new Error('Invalid option value');
  return '"' + value.replaceAll('\\', '\\\\').replaceAll('"', '\\"')
    .replaceAll('\n', '\\n').replaceAll('\r', '\\r').replaceAll('\t', '\\t').replaceAll('\b', '\\b') + '"';
}

export function clientOptions({ host, port, user, password, socketPath }) {
  const lines = ['[client]', `user=${optionValue(user)}`, `password=${optionValue(password)}`];
  if (socketPath) lines.push('protocol=socket', `socket=${optionValue(socketPath)}`);
  else lines.push('protocol=tcp', `host=${optionValue(host)}`, `port=${Number(port)}`);
  return lines.join('\n') + '\n';
}

export async function schemaInventory(connection, database) {
  const [tables] = await connection.execute(
    'SELECT TABLE_NAME, TABLE_TYPE, ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=? ORDER BY TABLE_NAME', [database]);
  if (tables.some(t => t.TABLE_TYPE === 'BASE TABLE' && t.ENGINE !== 'InnoDB')) {
    throw new Error('Consistent snapshot requires InnoDB tables');
  }
  const definitions = [];
  for (const table of tables) {
    const name = '`' + table.TABLE_NAME.replaceAll('`', '``') + '`';
    const [[definition]] = await connection.query(`SHOW CREATE TABLE ${name}`);
    definitions.push(definition);
  }
  const [routines] = await connection.execute('SELECT ROUTINE_NAME, ROUTINE_TYPE FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA=?', [database]);
  const [events] = await connection.execute('SELECT EVENT_NAME FROM information_schema.EVENTS WHERE EVENT_SCHEMA=?', [database]);
  const [triggers] = await connection.execute('SELECT TRIGGER_NAME FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA=?', [database]);
  // Current QA schema has none. Do not silently under-verify a future schema.
  if (routines.length || events.length || triggers.length) throw new Error('Review backup verification for stored programs before proceeding');
  return { tables, definitions };
}

export async function writeLogicalDump({ executable = 'mariadb-dump', directory, database, options }) {
  if (!/^[a-zA-Z0-9_]+$/.test(database)) throw new Error('Invalid database identifier');
  await fs.mkdir(directory, { mode: 0o700 }); // Must be new; never overwrite a backup.
  const defaults = directory + '/client.cnf';
  const dumpPath = directory + '/database.sql';
  const logPath = directory + '/dump.stderr.private';
  await fs.writeFile(defaults, clientOptions(options), { mode: 0o600, flag: 'wx' });
  let dump, log;
  try {
    dump = await fs.open(dumpPath, 'wx', 0o600);
    log = await fs.open(logPath, 'wx', 0o600);
    const args = [`--defaults-file=${defaults}`, '--single-transaction', '--quick', '--skip-lock-tables',
      '--skip-add-locks', '--skip-add-drop-table', '--no-tablespaces', '--routines', '--events',
      '--triggers', '--hex-blob', '--default-character-set=utf8mb4', database];
    await new Promise((resolve, reject) => {
      const child = spawn(executable, args, {
        env: { PATH: process.env.PATH, LANG: 'C', LC_ALL: 'C' },
        stdio: ['ignore', dump.fd, log.fd], shell: false,
      });
      child.once('error', () => reject(new Error('Cannot start dump client; private backup directory retained')));
      child.once('close', code => code === 0 ? resolve() : reject(new Error('Dump failed; inspect private stderr, never restore this partial file')));
    });
    await dump.sync();
  } finally {
    await Promise.all([dump?.close(), log?.close()]);
    await fs.unlink(defaults); // Only this operation's temporary credential file.
  }
  const stat = await fs.stat(dumpPath);
  if (!stat.size) throw new Error('Empty dump output');
  const hash = createHash('sha256');
  for await (const chunk of createReadStream(dumpPath)) hash.update(chunk);
  return { file: 'database.sql', bytes: stat.size, sha256: hash.digest('hex') };
}

async function main() {
  assertQaTarget(process.env, process.argv.slice(2));
  const mysql = createRequire(process.cwd() + '/package.json')('mysql2/promise');
  const options = { host: '127.0.0.1', port: 3306, user: process.env.R4_DB_USER, password: process.env.R4_DB_PASSWORD };
  const connection = await mysql.createConnection({ ...options, database: QA_DATABASE, connectTimeout: 5000 });
  try {
    const [[meta]] = await connection.query('SELECT VERSION() AS version, DATABASE() AS db');
    if (!meta.version.startsWith('11.8.9-') || meta.db !== QA_DATABASE) throw new Error('Recheck server version and database identity');
    const before = await schemaInventory(connection, QA_DATABASE);
    const backupRoot = PRIVATE_ROOT + '/backups';
    await fs.mkdir(backupRoot, { recursive: true, mode: 0o700 });
    const directory = backupRoot + '/' + new Date().toISOString().replaceAll(/[:.]/g, '-') + '-' + randomUUID();
    const dump = await writeLogicalDump({ directory, database: QA_DATABASE, options });
    const after = await schemaInventory(connection, QA_DATABASE);
    if (JSON.stringify(before) !== JSON.stringify(after)) throw new Error('Schema changed during backup; backup not accepted');
    const report = { status: 'BACKUP_WRITTEN_RESTORE_PENDING', createdAt: new Date().toISOString(),
      server: meta, dump, schema: before, noSchemaChangesConfirmed: true, restoreVerified: false };
    await fs.writeFile(directory + '/manifest.private.json', JSON.stringify(report, null, 2) + '\n', { mode: 0o600, flag: 'wx' });
    console.log(JSON.stringify({ directory, status: report.status, dump, tables: before.tables.length, restoreVerified: false }));
  } finally { await connection.end(); }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch(() => { console.error('QA backup stopped; do not migrate until backup and isolated restore are verified.'); process.exitCode = 1; });
}
