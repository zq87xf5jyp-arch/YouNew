import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import * as fs from 'node:fs/promises';
import { resolve } from 'node:path';

const execute = promisify(execFile);
const owned = new Set();
async function git(repository, args) {
  return (await execute('git', ['-C', repository, ...args], { maxBuffer: 1024 * 1024 })).stdout.trim();
}

export async function createSourceWorktree(repository, commit, destination) {
  if (!/^[a-f0-9]{40}$/.test(commit)) throw new Error('Exact source commit required');
  const source = resolve(destination);
  try { await fs.lstat(source); throw new Error('New source directory required'); }
  catch (error) { if (error.code !== 'ENOENT') throw error; }
  if (await git(repository, ['rev-parse', '--verify', commit + '^{commit}']) !== commit) throw new Error('Source commit mismatch');
  await git(repository, ['worktree', 'add', '--detach', '--', source, commit]);
  const token = { repository: resolve(repository), source, commit };
  owned.add(token);
  try {
    if (await git(source, ['rev-parse', 'HEAD']) !== commit || await git(source, ['status', '--porcelain'])) throw new Error('Clean committed source required');
    return token;
  } catch (error) {
    await removeSourceWorktree(token);
    throw error;
  }
}

export async function removeSourceWorktree(token) {
  if (!owned.has(token)) throw new Error('Only this process\'s new worktree may be removed');
  if (await fs.realpath(await git(token.source, ['rev-parse', '--show-toplevel'])) !== await fs.realpath(token.source)) throw new Error('Source root changed');
  await git(token.repository, ['worktree', 'remove', '--force', '--', token.source]);
  owned.delete(token);
}
