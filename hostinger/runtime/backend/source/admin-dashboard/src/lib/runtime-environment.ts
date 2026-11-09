import 'server-only';
import {lstat, realpath} from 'node:fs/promises';
import {loadEnvFile} from 'node:process';

// The hPanel variable holds a path only. Runtime credentials stay outside docroot,
// outside source archives, and outside the build environment.
export async function loadRuntimeEnvironment(path: string) {
  if (!/^\/home\/u[0-9]+\/domains\/[a-z0-9.-]+\/younew-private\/launch\.env$/.test(path)) {
    throw new Error('Invalid private runtime configuration path');
  }
  const metadata = await lstat(path);
  if (!metadata.isFile() || metadata.isSymbolicLink() || (metadata.mode & 0o077) !== 0 || await realpath(path) !== path) {
    throw new Error('Private runtime configuration must be an owner-only regular file');
  }
  loadEnvFile(path);
}
