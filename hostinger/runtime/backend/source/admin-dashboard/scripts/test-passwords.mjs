import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { scryptSync } from 'node:crypto';
import test from 'node:test';
import { compare } from 'bcryptjs';
import { verifyPassword } from '../src/lib/r4/passwords.ts';

const { vectors } = JSON.parse(await readFile(new URL('./fixtures/password-vectors.json', import.meta.url), 'utf8'));
const scryptRecord = value => {
  const salt = '1'.repeat(32);
  const digest = scryptSync(value, salt, 64, { N: 32768, r: 8, p: 1, maxmem: 64 * 1024 * 1024 });
  return `scrypt32768$${salt}$${digest.toString('hex')}`;
};
const dummy = scryptRecord('Synthetic dummy input, never an account');

for (const [index, vector] of vectors.entries()) {
  test(`independent PHP bcrypt fixture ${index + 1} works with compatible 2a/2b/2y records`, async () => {
    for (const prefix of ['$2a$', '$2b$', '$2y$']) {
      const stored = prefix + vector.encoded.slice(4);
      assert.equal(await verifyPassword(vector.input, stored, dummy), true);
      assert.equal(await verifyPassword('Wrong synthetic input', stored, dummy), false);
    }
  });
}

test('modern scrypt records retain exact full-password verification', async () => {
  const value = 'Synthetic 🌷 modern password ' + 'z'.repeat(100);
  const stored = scryptRecord(value);
  assert.equal(await verifyPassword(value, stored, dummy), true);
  assert.equal(await verifyPassword(value + 'x', stored, dummy), false);
});

test('unknown account never authenticates even when its input matches the dummy', async () => {
  assert.equal(await verifyPassword('Synthetic dummy input, never an account', undefined, dummy), false);
  assert.equal(await verifyPassword(vectors[0].input, undefined, dummy), false);
});

test('legacy verification refuses ignored suffixes beyond 72 UTF-8 bytes', async () => {
  const vector = vectors.find(x => x.input === 'A'.repeat(72));
  for (const suffix of ['B', '🌷']) {
    const input = vector.input + suffix;
    assert.equal(await compare(input, vector.encoded), true, 'exercise actual bcrypt truncation');
    assert.equal(await verifyPassword(input, vector.encoded, dummy), false);
  }
});

test('unreviewed costs, malformed hashes and damaged dummy config fail closed', async () => {
  for (const stored of ['', vectors[0].encoded.replace('$10$', '$31$'), vectors[0].encoded.slice(0, -1),
    'scrypt32768$short$' + '0'.repeat(128), 'scrypt32768$' + '0'.repeat(32) + '$' + 'z'.repeat(128)]) {
    await assert.rejects(verifyPassword('synthetic', stored, dummy), /Invalid credential record/);
  }
  await assert.rejects(verifyPassword('synthetic', undefined, ''), /Invalid dummy credential configuration/);
  assert.equal(await verifyPassword('x'.repeat(257), undefined, dummy), false);
});
