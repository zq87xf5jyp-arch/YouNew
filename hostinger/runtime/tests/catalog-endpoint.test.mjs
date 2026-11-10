import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const publish = fileURLToPath(new URL('../tools/publish-catalog.mjs', import.meta.url));
function probe(endpoint) {
  const env = { ...process.env, YOUNEW_LOCAL_CATALOG_API: endpoint };
  delete env.R4_CATALOG_BUILD_KEY;
  return spawnSync(process.execPath, [publish], { env, encoding: 'utf8', timeout: 5000 });
}

test('the actual isolated Hostinger app reaches the credential gate before any build', () => {
  const result = probe('https://qa-runtime.younew.nl/api/r4/editorial/approved');
  assert.equal(result.status, 1);
  assert.match(result.stderr, /Server build key required/);
});

for (const endpoint of [
  'https://admin.younew.nl/api/r4/editorial/approved',
  'https://qa-admin.younew.nl/api/r4/editorial/approved',
  'https://qa-runtime.younew.nl.example.invalid/api/r4/editorial/approved',
  'https://qa-runtime.younew.nl/api/r4/editorial/approved?target=production',
]) {
  test(`catalog build refuses the non-allowlisted endpoint ${endpoint}`, () => {
    const result = probe(endpoint);
    assert.equal(result.status, 1);
    assert.match(result.stderr, /Unapproved catalog endpoint/);
  });
}
