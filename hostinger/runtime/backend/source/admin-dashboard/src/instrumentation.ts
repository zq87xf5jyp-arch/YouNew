export async function register() {
  if (process.env.NEXT_RUNTIME === 'nodejs' && process.env.YOUNEW_RUNTIME_ENV_FILE) {
    const {loadRuntimeEnvironment} = await import('./lib/runtime-environment');
    await loadRuntimeEnvironment(process.env.YOUNEW_RUNTIME_ENV_FILE);
  }
}
