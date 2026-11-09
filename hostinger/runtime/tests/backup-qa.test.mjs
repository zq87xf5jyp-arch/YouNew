import assert from 'node:assert/strict';
import test from 'node:test';
import { spawnSync } from 'node:child_process';
import * as fs from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { assertQaTarget, writeLogicalDump } from '../../deployment/backup-qa.mjs';

const env = { R4_DB_NAME: 'u246392949_younq1', R4_DB_USER: 'u246392949_younq1', R4_DB_HOST: '127.0.0.1', R4_LOCAL: 'false', R4_DB_PASSWORD: 'synthetic-only' };
const args = ['--approved-qa', '--no-schema-changes'];
test('backup refuses production, alternate hosts/users and missing operator guards', () => {
  assert.doesNotThrow(() => assertQaTarget(env, args));
  for (const change of [{ R4_DB_NAME: 'production' }, { R4_DB_USER: 'root' }, { R4_DB_HOST: 'localhost' }, { R4_LOCAL: 'true' }, { R4_DB_PASSWORD: '' }]) {
    assert.throws(() => assertQaTarget({ ...env, ...change }, args));
  }
  for (const flags of [[], args.slice(0, 1), ['--approved-qa', '--approved-qa'], [...args, '--force']]) {
    assert.throws(() => assertQaTarget(env, flags));
  }
});

test('CLI rejects an unsafe target before loading a driver or connecting', () => {
  const result = spawnSync(process.execPath, ['hostinger/deployment/backup-qa.mjs', ...args], {
    cwd: new URL('../../../', import.meta.url), env: { PATH: process.env.PATH, ...env, R4_DB_NAME: 'production' }, encoding: 'utf8',
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /QA backup stopped/);
  assert.equal(result.stdout, '');
  assert.ok(!result.stderr.includes(env.R4_DB_PASSWORD));
});

test('failed dump removes temporary credentials, retains private partial evidence, and cannot overwrite it', async () => {
  const root = await fs.mkdtemp(join(tmpdir(), 'younew-backup-test-'));
  const directory = root + '/backup';
  const request = { executable: root + '/missing-client', directory, database: env.R4_DB_NAME,
    options: { host: '127.0.0.1', port: 3306, user: env.R4_DB_USER, password: env.R4_DB_PASSWORD } };
  try {
    await assert.rejects(writeLogicalDump(request), /Cannot start dump client/);
    await assert.rejects(fs.access(directory + '/client.cnf'), { code: 'ENOENT' });
    for (const file of ['database.sql', 'dump.stderr.private']) assert.equal((await fs.stat(directory + '/' + file)).mode & 0o777, 0o600);
    assert.equal((await fs.stat(directory)).mode & 0o777, 0o700);
    await assert.rejects(writeLogicalDump(request), { code: 'EEXIST' });
    await assert.rejects(fs.access(directory + '/manifest.private.json'), { code: 'ENOENT' });
  } finally { await fs.rm(root, { recursive: true, force: true }); }
});
