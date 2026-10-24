import { readFile, writeFile, lstat } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { isAbsolute, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

export const AGGREGATE_QUERY = "select jsonb_build_object('schemaVersion',1,'project','pgdzdxsiagfjioxwuqxf','observedAt',clock_timestamp(),'contentReview',(select jsonb_build_object('denominator',denominator,'verified',verified,'reviewDueSoon',review_due_soon,'overdue',overdue,'sourceUnavailable',source_unavailable,'reviewQueue',review_queue,'reviewSlaBreaches',review_sla_breaches,'computedAt',generated_at) from public.content_governance_health_summary),'feedback',jsonb_build_object('openCount',(select count(*) from public.feedback where status in ('new','reviewed','planned'))),'contentSync',jsonb_build_object('running',(select count(*) from public.sync_jobs where type='content_artifact_candidate' and status='running'),'failed',(select count(*) from public.sync_jobs where type='content_artifact_candidate' and status='failed'),'lastManualCandidateSucceededAt',(select max(completed_at) from public.sync_jobs where type='content_artifact_candidate' and status='succeeded')),'boundary','read-only aggregate snapshot; not scheduled execution, content verification, delivery or financial synchronization') as snapshot";
const sha256 = value => createHash('sha256').update(value).digest('hex');
const object = value => value !== null && typeof value === 'object' && !Array.isArray(value);
const requireValue = (ok, code) => { if (!ok) throw new Error(code); };
function date(value, ceiling) {
  requireValue(typeof value === 'string' && /^\d{4}-\d\d-\d\dT.*(?:Z|[+-]\d\d:\d\d)$/.test(value) &&
    Number.isFinite(Date.parse(value)) && Date.parse(value) <= ceiling, 'aggregate_timestamp_invalid');
  return value;
}
function count(value) { requireValue(Number.isSafeInteger(value) && value >= 0, 'aggregate_count_invalid'); return value; }

// The trusted MCP execution is performed by the existing owner task, never by this adapter.
// Hashes pin the observed bytes; they do not authenticate a provider or prove task execution.
export function aggregateEnvelope({ raw, evidencePath, evidenceSha256, now = new Date() }) {
  requireValue(isAbsolute(evidencePath) && /^[a-f0-9]{64}$/.test(evidenceSha256), 'aggregate_evidence_invalid');
  requireValue(object(raw) && raw.project === 'pgdzdxsiagfjioxwuqxf' && raw.mutations === false &&
    raw.newCredentials === false && raw.query === AGGREGATE_QUERY && Array.isArray(raw.rows) &&
    raw.rows.length === 1, 'aggregate_provenance_invalid');
  const s = raw.rows[0]?.snapshot;
  requireValue(object(s) && s.schemaVersion === 1 && s.project === raw.project, 'aggregate_schema_invalid');
  const observed = date(s.observedAt, now.getTime());
  const h = s.contentReview, f = s.feedback, c = s.contentSync;
  requireValue(object(h) && object(f) && object(c), 'aggregate_sections_missing');
  date(h.computedAt, Date.parse(observed));
  const denominator = count(h.denominator), verified = count(h.verified);
  const due = count(h.reviewDueSoon), overdue = count(h.overdue), unavailable = count(h.sourceUnavailable);
  const queued = count(h.reviewQueue), sla = count(h.reviewSlaBreaches);
  requireValue(verified + due + overdue + unavailable <= denominator && sla <= queued, 'aggregate_counts_inconsistent');
  const open = count(f.openCount), failed = count(c.failed), running = count(c.running);
  const success = c.lastManualCandidateSucceededAt === null ? null : date(c.lastManualCandidateSucceededAt, Date.parse(observed));
  const common = { schemaVersion: 1, evidenceAt: observed, lastAttemptAt: null, lastSuccessAt: null,
    scheduleEvidenceAt: null, sourceRunId: null, sourceRunAttempt: null,
    sourceEvidence: { path: evidencePath, sha256: evidenceSha256 } };
  return { schemaVersion: 1, sources: {
    aging_content_queue: { ...common, taskKey: 'aging_content_queue', sourceId: 'supabase:pgdzdxsiagfjioxwuqxf:content_review_aggregate',
      result: 'partial', counters: { denominator, verified, unverified: denominator - verified, due, overdue, sourceUnavailable: unavailable, slaBreaches: sla, open: queued } },
    feedback_intake: { ...common, taskKey: 'feedback_intake', sourceId: 'supabase:pgdzdxsiagfjioxwuqxf:feedback_aggregate',
      result: 'partial', counters: { open } },
    website_app_sync: { ...common, taskKey: 'website_app_sync', sourceId: 'supabase:pgdzdxsiagfjioxwuqxf:manual_content_candidate',
      result: 'candidate_only', lastSuccessAt: success, counters: { open: running, errors: failed } }
  } };
}
export async function prepareAggregateInput(evidencePath, outputPath) {
  requireValue(isAbsolute(evidencePath) && isAbsolute(outputPath), 'absolute_path_required');
  const file = await lstat(evidencePath);
  requireValue(file.isFile() && !file.isSymbolicLink() && file.size <= 65536, 'aggregate_file_invalid');
  const bytes = await readFile(evidencePath);
  const envelope = aggregateEnvelope({ raw: JSON.parse(bytes.toString('utf8')), evidencePath, evidenceSha256: sha256(bytes) });
  // Never overwrite prior evidence or the original tool receipt.
  await writeFile(outputPath, JSON.stringify(envelope, null, 2) + '\n', { mode: 0o600, flag: 'wx' });
  return { status: 'aggregate_input_prepared', sourceEvidenceAt: envelope.sources.aging_content_queue.evidenceAt,
    sources: Object.keys(envelope.sources), outputPath, scheduledExecutionConfirmed: false };
}
if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const args = process.argv.slice(2);
    if (args.length === 1 && args[0] === '--print-query') process.stdout.write(AGGREGATE_QUERY + '\n');
    else {
      requireValue(args.length === 4 && args[0] === '--evidence' && args[2] === '--output', 'usage_invalid');
      console.log(JSON.stringify(await prepareAggregateInput(args[1], args[3])));
    }
  } catch (error) {
    const safe = new Set(['aggregate_timestamp_invalid','aggregate_count_invalid','aggregate_evidence_invalid',
      'aggregate_provenance_invalid','aggregate_schema_invalid','aggregate_sections_missing','aggregate_counts_inconsistent',
      'absolute_path_required','aggregate_file_invalid','usage_invalid']);
    console.error(JSON.stringify({ status: 'aggregate_input_unavailable', code: safe.has(error.message) ? error.message : 'local_input_unavailable' }));
    process.exitCode = 1;
  }
}
