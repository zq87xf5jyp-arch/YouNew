import { gunzipSync } from 'node:zlib';

export class SyncSourceError extends Error {}
const need = (ok, code) => { if (!ok) throw new SyncSourceError(code); };

export function units(value) {
  need(typeof value === 'string' && /^-?(0|[1-9]\d*)$/.test(value.trim()), 'invalid_sales_units');
  const parsed = Number(value.trim());
  need(Number.isSafeInteger(parsed) && Math.abs(parsed) <= 2147483647, 'sales_units_out_of_range');
  return parsed;
}

export function parseTsv(buffer, reportDate) {
  need(buffer.length > 0 && buffer.length <= 20 * 1024 * 1024, 'invalid_sales_report_size');
  let decompressed;
  try { decompressed = buffer[0] === 0x1f && buffer[1] === 0x8b ? gunzipSync(buffer, { maxOutputLength: 20 * 1024 * 1024 }) : buffer; }
  catch { throw new SyncSourceError('invalid_sales_report_compression'); }
  const lines = decompressed.toString('utf8').replace(/^\uFEFF/, '').split(/\r?\n/);
  const headers = lines.shift().split('\t').map(header => header.trim());
  const required = ['Apple Identifier', 'Country Code', 'Product Type Identifier', 'Units', 'Begin Date', 'End Date'];
  need(new Set(headers).size === headers.length && required.every(name => headers.includes(name)), 'invalid_sales_report_columns');
  const expectedDate = `${reportDate.slice(5, 7)}/${reportDate.slice(8, 10)}/${reportDate.slice(0, 4)}`;
  return lines.filter(line => line !== '').map(line => {
    const values = line.split('\t');
    need(values.length === headers.length, 'invalid_sales_report_row_width');
    const row = Object.fromEntries(headers.map((header, index) => [header, values[index]]));
    need(row['Begin Date'] === expectedDate && row['End Date'] === expectedDate, 'sales_report_date_mismatch');
    need(/^\d+$/.test(row['Apple Identifier']) && /^[A-Z]{2}$/.test(row['Country Code']) && row['Product Type Identifier'].trim().length > 0, 'invalid_sales_report_row_identity');
    units(row.Units);
    return row;
  });
}

export async function boundedFetch(url, init, { fetcher = fetch, wait = ms => new Promise(resolve => setTimeout(resolve, ms)), timeoutMs = 10000, deadline = Date.now() + 120000 } = {}) {
  for (let attempt = 0; attempt < 3; attempt++) {
    need(Date.now() < deadline, 'source_sync_deadline_exceeded');
    try {
      const response = await fetcher(url, { ...init, signal: AbortSignal.timeout(Math.max(1, Math.min(timeoutMs, deadline - Date.now()))) });
      if ((response.status === 429 || response.status >= 500) && attempt < 2) {
        const retryAfter = response.headers.get('retry-after');
        const delay = retryAfter === null ? 250 * 2 ** attempt : /^\d+$/.test(retryAfter) ? Number(retryAfter) * 1000 : NaN;
        need(Number.isFinite(delay) && delay <= 1000 && Date.now() + delay < deadline, 'provider_retry_deferred');
        await wait(delay); continue;
      }
      return response;
    } catch (error) {
      if (error instanceof SyncSourceError) throw error;
      if (attempt === 2) throw new SyncSourceError('source_transport_failed');
      await wait(100 * 2 ** attempt);
    }
  }
  throw new SyncSourceError('source_retry_exhausted');
}

export function syncStateUpdates(status, detail, now, latestDataAt) {
  need(['success', 'empty', 'error'].includes(status), 'invalid_sync_status');
  const current = { status, last_attempt_at: now.toISOString(), detail: detail.slice(0, 500) };
  // Only an actual imported observation updates success/freshness fields.
  if (status === 'success') {
    need(typeof latestDataAt === 'string' && Number.isFinite(Date.parse(latestDataAt)) && new Date(latestDataAt) <= now, 'invalid_latest_data_date');
    current.last_success_at = now.toISOString();
  }
  return current;
}
