import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, cp, mkdir, readFile, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { applyApprovedCompletion, approvalPath } from '../approved-ios-completion.mjs';
import { loadEditorialRelease } from '../../admin-dashboard/public-site/scripts/editorial-release.mjs';
const root = fileURLToPath(new URL('../../', import.meta.url));
const entities = (await loadEditorialRelease()).entities;
async function fixture(change, pattern) {
  const temp = await mkdtemp(resolve(tmpdir(), 'younew-approved-completion-'));
  try {
    for (const directory of ['DataProject/editorial','DataProject/staging/content-20261109','DataProject/operations','docs/younew-upgrade']) {
      await mkdir(resolve(temp,directory), { recursive: true });
      await cp(resolve(root,directory), resolve(temp,directory), { recursive: true });
    }
    await change(temp);
    await assert.rejects(applyApprovedCompletion(entities,temp),pattern);
  } finally { await rm(temp, { recursive: true, force: true }); }
}
test('unapproved receipt cannot activate the selected fields', async () => {
  await fixture(async temp => {
    const path=resolve(temp,approvalPath); const receipt=JSON.parse(await readFile(path));
    receipt.status='needs_review'; await writeFile(path,JSON.stringify(receipt));
  }, /Explicit owner approval/);
});
test('changed selection and changed image bytes are rejected', async () => {
  await fixture(async temp => {
    const path=resolve(temp,'docs/younew-upgrade/LEIDEN_COMPLETION_SELECTION_2026-11-15.json');
    await writeFile(path,(await readFile(path,'utf8'))+' ');
  }, /Approved selection changed/);
  await fixture(async temp => {
    await writeFile(resolve(temp,'DataProject/editorial/leiden-nature-culture-20261115/media/wereldmuseum-1200.webp'),'not the approved image');
  }, /changed review image|Approved image changed/);
});
test('approval cannot widen the selected scope to whole batches', async () => {
  await fixture(async temp => {
    const path=resolve(temp,approvalPath); const receipt=JSON.parse(await readFile(path));
    receipt.scope.wholeBatchPublication=true; await writeFile(path,JSON.stringify(receipt));
  }, /Expected values/);
});
