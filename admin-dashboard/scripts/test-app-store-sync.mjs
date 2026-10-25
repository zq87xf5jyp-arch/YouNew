import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { gzipSync } from 'node:zlib';
import { units, parseTsv, boundedFetch, syncStateUpdates } from './app-store-sync-safety.mjs';

const headers = 'Apple Identifier\tCountry Code\tProduct Type Identifier\tUnits\tBegin Date\tEnd Date';
const body = `${headers}\n6782617312\tNL\t1\t3\t09/18/2026\t09/18/2026\n`;
test('malformed units cannot turn into measured zero; legitimate signed units remain signed', () => {
  for (const value of ['', 'n/a', '1.5', '2extra', '1e2', '2147483648', undefined]) assert.throws(() => units(value));
  assert.equal(units('0'), 0); assert.equal(units('-3'), -3); assert.equal(units('10'), 10);
});
test('TSV validates headers, row shape, daily date, identity and bounded gzip', () => {
  assert.equal(parseTsv(gzipSync(Buffer.from(body)), '2026-09-18')[0].Units, '3');
  for (const broken of ['', '<html>upstream error</html>', body.replace('Units', 'Other'), body.replace('\t3\t', '\tbad\t'), body.replace('\tNL\t', '\t?\t'), body.replace('End Date', 'Begin Date'), body.replace('\t3\t', '\t3\textra\t')]) {
    assert.throws(() => parseTsv(Buffer.from(broken), '2026-09-18'));
  }
  assert.throws(() => parseTsv(Buffer.from(body), '2026-09-17'), /date_mismatch/);
});
test('empty/error state patches omit successful-history fields', () => {
  for (const status of ['empty', 'error']) {
    const update = syncStateUpdates(status, 'safe code', new Date('2026-09-19T12:00:00Z'), null);
    assert.ok(!Object.hasOwn(update, 'last_success_at')); assert.ok(!Object.hasOwn(update, 'latest_data_at'));
  }
});
test('transport timeout/retry/defer policies are bounded and avoid provider body', async () => {
  let calls = 0;
  const response = await boundedFetch(new URL('https://example.invalid'), {}, { wait: async () => {}, fetcher: async (url, init) => {
    calls++; assert.ok(init.signal instanceof AbortSignal); return new Response('private', { status: 503 });
  } });
  assert.equal(calls, 3); assert.equal(response.status, 503);
  await assert.rejects(boundedFetch(new URL('https://example.invalid'), {}, { deadline: 0 }), /deadline/);
  await assert.rejects(boundedFetch(new URL('https://example.invalid'), {}, { fetcher: async () => new Response('private', { status: 429, headers: { 'retry-after': '60' } }) }), /deferred/);
});

// Full canonical CLI in a fresh process. Every fetch is intercepted; an unknown
// URL fails the fixture. Only synthetic signing material is constructed in it.
function scenario(mode) {
  const script = `
    import { generateKeyPairSync } from 'node:crypto';
    const { privateKey } = generateKeyPairSync('ec', { namedCurve: 'prime256v1' });
    process.env.APP_STORE_CONNECT_PRIVATE_KEY = privateKey.export({ type:'pkcs8', format:'pem' });
    const mode = process.env.TEST_CASE;
    const prior = { source:'app_store_connect', status:'success', last_success_at:'2026-09-10T12:00:00Z', latest_data_at: mode==='older' ? '2099-01-01T00:00:00Z' : '2026-09-10T23:59:59Z' };
    let state = {...prior}; const calls=[]; let metrics=[];
    globalThis.fetch = async (input, init) => {
      const url = new URL(input); const payload = init.body ? JSON.parse(init.body) : null;
      calls.push({host:url.hostname,path:url.pathname,method:init.method??'GET',payload,prefer:init.headers?.Prefer});
      if(url.hostname === 'api.appstoreconnect.apple.com') {
        if(mode==='error') return new Response('PRIVATE_PROVIDER_BODY_MUST_NOT_APPEAR', {status:503});
        if(mode==='empty') return new Response('',{status:404});
        const date=url.searchParams.get('filter[reportDate]'); const dateText=date.slice(5,7)+'/'+date.slice(8,10)+'/'+date.slice(0,4);
        const amount=mode==='malformed'?'bad':mode==='negative'?'-1':'5';
        return new Response(${JSON.stringify(headers)}+'\\n6782617312\\tNL\\t1\\t'+amount+'\\t'+dateText+'\\t'+dateText+'\\n',{status:200});
      }
      if(url.hostname !== 'fixture.supabase.co') throw new Error('unexpected network');
      if(url.pathname.endsWith('/app_store_metrics_daily')) { metrics=payload; return new Response(null,{status:204}); }
      if(!url.pathname.endsWith('/analytics_source_sync_state')) throw new Error('unexpected table');
      if(init.method==='POST') {
        if(init.headers.Prefer!=='resolution=ignore-duplicates,return=minimal') throw new Error('must ignore previous state');
      } else if(init.method==='PATCH') {
        if(payload.latest_data_at) { if(!state.latest_data_at||state.latest_data_at<payload.latest_data_at) state={...state,...payload}; }
        else state={...state,...payload};
      } else throw new Error('unexpected mutation');
      return new Response(null,{status:204});
    };
    process.on('exit',()=>process.stderr.write('HARNESS:'+JSON.stringify({prior,state,metrics,calls})+'\\n'));
    await import(${JSON.stringify(new URL('./sync-app-store-analytics.mjs', import.meta.url).href)});
  `;
  const result = spawnSync(process.execPath, ['--input-type=module', '--eval', script], {
    encoding: 'utf8', timeout: 10000,
    env: { PATH: process.env.PATH, TEST_CASE: mode, APP_STORE_CONNECT_ISSUER_ID: 'fixture', APP_STORE_CONNECT_KEY_ID: 'fixture',
      APP_STORE_CONNECT_VENDOR_NUMBER: '12345', APP_STORE_CONNECT_APP_ID: '6782617312', SUPABASE_URL: 'https://fixture.supabase.co', SUPABASE_SERVICE_ROLE_KEY: 'SYNTHETIC_ONLY', APP_STORE_SYNC_DAYS: '1' }
  });
  assert.ok(!result.error, result.error?.message);
  assert.ok(!result.stdout.includes('PRIVATE_PROVIDER_BODY_MUST_NOT_APPEAR'));
  assert.ok(!result.stderr.includes('PRIVATE_PROVIDER_BODY_MUST_NOT_APPEAR'));
  const matched = result.stderr.match(/HARNESS:(.*)/); assert.ok(matched, result.stderr);
  return { ...JSON.parse(matched[1]), exit: result.status, output: result.stdout, stderr: result.stderr };
}
for (const mode of ['empty', 'error', 'malformed', 'negative']) test(`actual CLI ${mode} preserves previous successful timestamps and rejects false counts`, () => {
  const result = scenario(mode);
  assert.equal(result.exit, mode === 'empty' ? 0 : 1);
  assert.equal(result.state.last_success_at, result.prior.last_success_at);
  assert.equal(result.state.latest_data_at, result.prior.latest_data_at);
  assert.equal(result.state.status, mode === 'empty' ? 'empty' : 'error');
  assert.deepEqual(result.metrics, []);
});
test('actual successful CLI upserts daily metrics and updates success/freshness explicitly', () => {
  const result = scenario('success'); assert.equal(result.exit, 0);
  assert.equal(result.metrics[0].first_time_downloads, 5);
  assert.notEqual(result.state.last_success_at, result.prior.last_success_at);
  assert.ok(result.state.latest_data_at > result.prior.latest_data_at);
});
test('older successful imports do not move latest_data_at backward', () => {
  const result = scenario('older'); assert.equal(result.exit, 0);
  assert.equal(result.state.latest_data_at, result.prior.latest_data_at);
  assert.notEqual(result.state.last_success_at, result.prior.last_success_at);
});
