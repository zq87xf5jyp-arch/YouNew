# Executed launch operators

These are the exact one-off operators executed on 2026-11-10, not an automatic deployment pipeline. Stage/activate/cleanup are bound to that launch state and must not be rerun on the active production. Prepare new paths, manifests and backups for a future release.

health-check.py is the deployed read-only monitor; pass its private JSON configuration as the first argument. verify-production-live.mjs observe reads the existing baseline; never rerun start. Credentials and personal payloads are not included.
