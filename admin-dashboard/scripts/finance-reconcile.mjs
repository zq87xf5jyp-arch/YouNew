import { run } from './finance/run.mjs';

const [config, output, weekEnding] = process.argv.slice(2);
if (!config || !output) {
  process.stderr.write('Usage: node scripts/finance-reconcile.mjs private-config.json private-output [YYYY-MM-DD-week-ending]\n');
  process.exitCode = 2;
} else {
  try {
    const result = await run(config, output, { weekEnding });
    process.stdout.write(JSON.stringify(result) + '\n');
    if (result.status === 'partial') process.exitCode = 2;
  } catch {
    process.stderr.write('Financial reconciliation failed closed. Inspect the private exception log; prior reports were preserved.\n');
    process.exitCode = 2;
  }
}
