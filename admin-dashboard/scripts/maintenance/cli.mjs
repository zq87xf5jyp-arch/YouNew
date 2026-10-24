import { lstat } from 'node:fs/promises';
import { isAbsolute, join } from 'node:path';
import { fileSourceAdapters, logicalContext, run, SourceFailure } from './maintenance.mjs';

const options = {};
try {
  const args = process.argv.slice(2);
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--collect-public') { if (options.collect) throw new SourceFailure('invalid_arguments'); options.collect = true; continue; }
    if (!['--automation-id', '--trigger', '--manual-key', '--native-run-id', '--output', '--sources'].includes(arg) || options[arg] !== undefined || !args[i + 1] || args[i + 1].startsWith('--')) throw new SourceFailure('invalid_arguments');
    options[arg] = args[++i];
  }
  if (!options.collect || !isAbsolute(options['--output'] ?? '')) throw new SourceFailure('explicit_collection_and_private_output_required');
  const context = logicalContext({ automationId: options['--automation-id'], trigger: options['--trigger'], manualKey: options['--manual-key'], nativeRunId: options['--native-run-id'] ?? null });
  let disabled = false;
  try { await lstat(join(options['--output'], 'DISABLED')); disabled = true; } catch (error) { if (error.code !== 'ENOENT') throw error; }
  // Missing/unusable optional inputs produce unknown sources; they never prevent public-only reads.
  let adapters = {}, optionalInputStatus = options['--sources'] ? 'configured' : 'not_configured';
  if (options['--sources'] && !disabled) {
    try { if (!isAbsolute(options['--sources'])) throw new SourceFailure('absolute_source_path_required'); adapters = await fileSourceAdapters(options['--sources']); }
    catch { optionalInputStatus = 'unavailable'; }
  }
  const result = await run({ output: options['--output'], ...context, enabled: !disabled, sourceAdapters: adapters });
  process.stdout.write(JSON.stringify({ ...result, optionalInputStatus, scheduledExecutionConfirmed: false }) + '\n');
  process.exitCode = result.status === 'partial' ? 2 : ['disabled', 'locked'].includes(result.status) ? 3 : 0;
} catch (error) {
  process.stderr.write(JSON.stringify({ status: 'failed_closed', code: error instanceof SourceFailure ? error.code : 'local_operation_unavailable', reportSent: false, scheduledExecutionConfirmed: false }) + '\n');
  process.exitCode = 1;
}
