// Explicit local acceptance exercise. Own socket-only DB + loopback HTTP app.
// Never imports real accounts, reads deployment secrets or contacts Hostinger.
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { randomBytes, randomUUID, scryptSync, createHash } from 'node:crypto';
import { createServer } from 'node:net';
import * as fs from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import mysql from 'mysql2/promise';

if (process.argv[2] !== '--local-disposable') throw new Error('Explicit local disposable test required');
const cwd = fileURLToPath(new URL('../', import.meta.url));
await fs.access(cwd + '.next/BUILD_ID');
const port = 4404, base = 'http://127.0.0.1:4404';
const probe = createServer();
await new Promise((resolve, reject) => { probe.once('error', reject); probe.listen(port, '127.0.0.1', resolve); });
await new Promise(resolve => probe.close(resolve));
const root = await fs.mkdtemp(join(tmpdir(), 'yn-auth-'));
await fs.chmod(root, 0o700);
const socketPath = root + '/db.sock';
const cliEnv = { PATH: process.env.PATH, LANG: 'C', LC_ALL: 'C' };
let database, app, connection, dbLog, appLog;
const checks = [];
const check = (name, actual, expected) => { assert.deepEqual(actual, expected, name); checks.push(name); };
const pause = ms => new Promise(resolve => setTimeout(resolve, ms));
async function stop(child) {
  if (!child || child.exitCode !== null || child.signalCode !== null) return;
  const closed = new Promise(resolve => child.once('close', resolve));
  child.kill('SIGTERM');
  await closed;
}
try {
  const setup = spawnSync('mariadb-install-db', ['--no-defaults', `--datadir=${root}/data`, '--auth-root-authentication-method=normal', '--skip-test-db'], { env: cliEnv, encoding: 'utf8' });
  await fs.writeFile(root + '/setup.log', setup.stdout + setup.stderr, { mode: 0o600 });
  assert.equal(setup.status, 0, 'bootstrap local fixture');
  dbLog = await fs.open(root + '/db.log', 'wx', 0o600);
  database = spawn('mariadbd', ['--no-defaults', `--datadir=${root}/data`, `--socket=${socketPath}`, `--pid-file=${root}/db.pid`,
    '--skip-networking', '--skip-log-bin', '--innodb-buffer-pool-size=32M', '--innodb-log-file-size=16M', '--max-connections=10'], { env: cliEnv, stdio: ['ignore', dbLog.fd, dbLog.fd] });
  let dbError;
  database.once('error', error => { dbError = error; });
  for (let attempt = 0; attempt < 100 && !connection; attempt++) {
    if (dbError || database.exitCode !== null) throw new Error('Local database exited');
    try { connection = await mysql.createConnection({ socketPath, user: 'root' }); }
    catch { await pause(100); }
  }
  assert.ok(connection);
  const [[metadata]] = await connection.query('SELECT VERSION() AS version,@@skip_networking AS network_disabled');
  check('database_network_disabled', Number(metadata.network_disabled), 1);
  await connection.query('CREATE DATABASE r4_auth_fixture CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
  await connection.query('USE r4_auth_fixture');
  const fixtureDbPassword = randomBytes(24).toString('hex');
  await connection.query("CREATE USER 'r4_fixture'@'localhost' IDENTIFIED BY ?", [fixtureDbPassword]);
  await connection.query("GRANT ALL PRIVILEGES ON r4_auth_fixture.* TO 'r4_fixture'@'localhost'");
  const migrations = fileURLToPath(new URL('../../../db/migrations/', import.meta.url));
  for (const file of (await fs.readdir(migrations)).filter(x => x.endsWith('.sql')).sort()) {
    const sql = await fs.readFile(join(migrations, file), 'utf8');
    for (const statement of sql.split(';').map(x => x.trim()).filter(Boolean)) await connection.query(statement);
    await connection.execute('INSERT INTO schema_migrations(version,sha256) VALUES(?,?)', [file, createHash('sha256').update(sql).digest('hex')]);
  }
  const encode = value => {
    const salt = randomBytes(16).toString('hex');
    return 'scrypt32768$' + salt + '$' + scryptSync(value, salt, 64, { N: 32768, r: 8, p: 1, maxmem: 64 * 1024 * 1024 }).toString('hex');
  };
  const { vectors } = JSON.parse(await fs.readFile(new URL('./fixtures/password-vectors.json', import.meta.url), 'utf8'));
  const modernInput = 'Synthetic modern fixture';
  const dummyInput = 'Synthetic unknown-account dummy';
  const dummyHash = encode(dummyInput);
  const workspace = randomUUID();
  await connection.execute('INSERT INTO workspaces VALUES(?,?)', [workspace, 'Synthetic auth fixture']);
  const accounts = [
    { name: 'legacy', role: 'owner', approved: 1, blocked: 0, encoded: vectors[0].encoded, input: vectors[0].input },
    { name: 'pending', role: 'viewer', approved: 0, blocked: 0, encoded: vectors[0].encoded, input: vectors[0].input },
    { name: 'blocked', role: 'owner', approved: 1, blocked: 1, encoded: vectors[0].encoded, input: vectors[0].input },
    { name: 'viewer', role: 'viewer', approved: 1, blocked: 0, encoded: vectors[1].encoded, input: vectors[1].input },
    { name: 'modern', role: 'admin', approved: 1, blocked: 0, encoded: encode(modernInput), input: modernInput },
  ];
  for (const account of accounts) {
    account.id = randomUUID();
    await connection.execute('INSERT INTO profiles VALUES(?,?,?,?,?,?,?,?)', [account.id, workspace, account.name + '@example.invalid',
      'Synthetic ' + account.name, account.encoded, account.role, account.approved, account.blocked]);
  }
  const appEnv = { ...process.env };
  for (const key of Object.keys(appEnv)) if (key.startsWith('R4_') || key === 'YOUNEW_RUNTIME_ENV_FILE') delete appEnv[key];
  Object.assign(appEnv, { NODE_ENV: 'production', NEXT_TELEMETRY_DISABLED: '1', R4_LOCAL: 'true', R4_ORIGIN: base,
    R4_DB_SOCKET: socketPath, R4_DB_USER: 'r4_fixture', R4_DB_PASSWORD: fixtureDbPassword,
    R4_DB_NAME: 'r4_auth_fixture', R4_DUMMY_PASSWORD_HASH: dummyHash });
  appLog = await fs.open(root + '/app.log', 'wx', 0o600);
  async function startApp() {
    app = spawn(process.execPath, ['node_modules/next/dist/bin/next', 'start', '-H', '127.0.0.1', '-p', String(port)], { cwd, env: appEnv, stdio: ['ignore', appLog.fd, appLog.fd] });
    for (let attempt = 0; attempt < 100; attempt++) {
      if (app.exitCode !== null) throw new Error('Local app exited');
      try { if ((await fetch(base + '/login')).status === 200) return; } catch {}
      await pause(100);
    }
    throw new Error('Local app readiness timeout');
  }
  await startApp();
  async function login(name, password, origin = base) {
    return fetch(base + '/api/r4/login', { method: 'POST', headers: { 'Content-Type': 'application/json', origin },
      body: JSON.stringify({ email: name + '@example.invalid', password }) });
  }
  const legacy = accounts[0];
  for (const name of ['legacy', 'viewer', 'modern']) {
    const account = accounts.find(x => x.name === name);
    const result = await login(name, account.input);
    check(name + '_login', result.status, 200);
    const cookie = result.headers.get('set-cookie');
    assert.match(cookie, /HttpOnly/i);
    assert.match(cookie, /SameSite=strict/i);
    account.cookie = cookie.split(';')[0];
    const me = await fetch(base + '/api/r4/me', { headers: { cookie: account.cookie } });
    check(name + '_role_retained', (await me.json()).role, account.role);
    const crm = await fetch(base + '/api/r4/inquiries', { headers: { cookie: account.cookie } });
    check(name + '_crm_permission', crm.status, name === 'viewer' ? 403 : 200);
    assert.match(crm.headers.get('cache-control'), /no-store/);
  }
  for (const name of ['pending', 'blocked']) {
    const result = await login(name, legacy.input);
    check(name + '_denied', result.status, 403);
    check(name + '_no_session_cookie', result.headers.get('set-cookie'), null);
  }
  check('wrong_password_denied', (await login('legacy', 'Wrong synthetic input')).status, 401);
  check('unknown_matching_dummy_denied', (await login('unknown', dummyInput)).status, 401);
  check('cross_origin_denied', (await login('legacy', legacy.input, 'https://example.invalid')).status, 403);
  const [stored] = await connection.query('SELECT id,password_hash,role,is_approved,is_blocked FROM profiles');
  for (const account of accounts) {
    const current = stored.find(x => x.id === account.id);
    assert.deepEqual(current, { id: account.id, password_hash: account.encoded, role: account.role, is_approved: account.approved, is_blocked: account.blocked });
  }
  checks.push('credentials_roles_and_approvals_unchanged');
  await stop(app);
  await startApp();
  check('session_persists_after_app_restart', (await fetch(base + '/api/r4/me', { headers: { cookie: legacy.cookie } })).status, 200);
  await connection.execute('UPDATE profiles SET is_blocked=1 WHERE id=?', [legacy.id]);
  check('blocked_account_existing_session_denied', (await fetch(base + '/api/r4/me', { headers: { cookie: legacy.cookie } })).status, 403);
  const modern = accounts.find(x => x.name === 'modern');
  check('logout_succeeds', (await fetch(base + '/api/r4/logout', { method: 'POST', headers: { origin: base, cookie: modern.cookie } })).status, 200);
  check('logout_revokes_session', (await fetch(base + '/api/r4/me', { headers: { cookie: modern.cookie } })).status, 401);
  const report = { status: 'PASS', scope: 'local synthetic HTTP acceptance, not Hostinger or real account migration', database: metadata,
    checks, evidenceDirectory: root, realAccountsImported: false };
  await fs.writeFile(root + '/report.json', JSON.stringify(report, null, 2) + '\n', { mode: 0o600, flag: 'wx' });
  console.log(JSON.stringify(report, null, 2));
} catch (error) {
  console.error('Local login exercise failed; private evidence:', root, error.message);
  process.exitCode = 1;
} finally {
  await stop(app);
  await connection?.end();
  await stop(database);
  await appLog?.close();
  await dbLog?.close();
}
