import test from 'node:test';
import assert from 'node:assert/strict';
import * as fs from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { execFileSync } from 'node:child_process';
import { createSourceWorktree, removeSourceWorktree } from '../tools/source-worktree.mjs';

test('build source has exact Git identity and cleanup preserves the canonical checkout', async () => {
  const root = await fs.mkdtemp(join(tmpdir(), 'younew-source-'));
  try {
    const repo = join(root, 'repo'), source = join(root, 'stage');
    await fs.mkdir(repo);
    const git = (...args) => execFileSync('git', ['-C', repo, ...args], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
    git('init', '-q');
    await fs.writeFile(join(repo, 'example.txt'), 'committed content');
    git('add', '.');
    git('-c', 'user.name=Synthetic QA', '-c', 'user.email=qa@example.invalid', 'commit', '-qm', 'fixture');
    const commit = git('rev-parse', 'HEAD');
    await fs.writeFile(join(repo, 'example.txt'), 'owner uncommitted change');
    const token = await createSourceWorktree(repo, commit, source);
    assert.equal(await fs.readFile(join(source, 'example.txt'), 'utf8'), 'committed content');
    assert.equal(execFileSync('git', ['-C', source, 'rev-parse', 'HEAD'], { encoding: 'utf8' }).trim(), commit);
    await assert.rejects(createSourceWorktree(repo, commit, source), /New source directory/);
    await assert.rejects(removeSourceWorktree({ repository: repo, source: repo, commit }), /Only this process/);
    await fs.writeFile(join(source, 'generated.json'), '{}');
    await removeSourceWorktree(token);
    assert.equal(await fs.readFile(join(repo, 'example.txt'), 'utf8'), 'owner uncommitted change');
    assert.equal(git('worktree', 'list', '--porcelain').split('\n').filter(x => x.startsWith('worktree ')).length, 1);
    await assert.rejects(fs.access(source), { code: 'ENOENT' });
  } finally { await fs.rm(root, { recursive: true, force: true }); }
});
