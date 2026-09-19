import { createPrivateKey, sign } from "node:crypto";
import { boundedFetch, parseTsv, units, syncStateUpdates, SyncSourceError } from "./app-store-sync-safety.mjs";

const sourceDeadline = Date.now() + 120_000;
const request = (url, init) => boundedFetch(url, init, { deadline: sourceDeadline });

const requiredEnvironment = [
  "APP_STORE_CONNECT_ISSUER_ID",
  "APP_STORE_CONNECT_KEY_ID",
  "APP_STORE_CONNECT_PRIVATE_KEY",
  "APP_STORE_CONNECT_VENDOR_NUMBER",
  "APP_STORE_CONNECT_APP_ID",
  "SUPABASE_URL",
  "SUPABASE_SERVICE_ROLE_KEY"
];

const missing = requiredEnvironment.filter((name) => !(process.env[name] ?? "").trim());
if (missing.length > 0) {
  throw new Error(`App Store analytics sync is not configured: ${missing.join(", ")}`);
}

const configuration = {
  issuerId: process.env.APP_STORE_CONNECT_ISSUER_ID.trim(),
  keyId: process.env.APP_STORE_CONNECT_KEY_ID.trim(),
  privateKey: process.env.APP_STORE_CONNECT_PRIVATE_KEY.replaceAll("\\n", "\n").trim(),
  vendorNumber: process.env.APP_STORE_CONNECT_VENDOR_NUMBER.trim(),
  appId: process.env.APP_STORE_CONNECT_APP_ID.trim(),
  supabaseUrl: new URL(process.env.SUPABASE_URL.trim()),
  supabaseServiceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY.trim(),
  days: Math.min(90, Math.max(1, Number(process.env.APP_STORE_SYNC_DAYS ?? "14") || 14))
};

if (configuration.supabaseUrl.protocol !== "https:"
  || !configuration.supabaseUrl.hostname.endsWith(".supabase.co")
  || configuration.supabaseUrl.username || configuration.supabaseUrl.password
  || (configuration.supabaseUrl.port && configuration.supabaseUrl.port !== "443")) {
  throw new Error("SUPABASE_URL must be an HTTPS Supabase project URL.");
}

const downloadProductTypes = new Set(["1", "1F", "1T", "1E", "1EP", "1EU"]);
const redownloadProductTypes = new Set(["3", "3F"]);
const updateProductTypes = new Set(["7", "7F", "7T"]);

function base64url(value) {
  return Buffer.from(value).toString("base64url");
}

function appStoreToken() {
  const issuedAt = Math.floor(Date.now() / 1_000);
  const header = base64url(JSON.stringify({ alg: "ES256", kid: configuration.keyId, typ: "JWT" }));
  const payload = base64url(JSON.stringify({
    iss: configuration.issuerId,
    iat: issuedAt,
    exp: issuedAt + 15 * 60,
    aud: "appstoreconnect-v1"
  }));
  const signingInput = `${header}.${payload}`;
  const signature = sign("sha256", Buffer.from(signingInput), {
    key: createPrivateKey(configuration.privateKey),
    dsaEncoding: "ieee-p1363"
  });
  return `${signingInput}.${signature.toString("base64url")}`;
}

function isoDate(date) {
  return date.toISOString().slice(0, 10);
}

function reportDates() {
  const dates = [];
  const cursor = new Date();
  cursor.setUTCHours(0, 0, 0, 0);
  cursor.setUTCDate(cursor.getUTCDate() - 1);
  for (let offset = 0; offset < configuration.days; offset += 1) {
    dates.push(isoDate(cursor));
    cursor.setUTCDate(cursor.getUTCDate() - 1);
  }
  return dates;
}

async function downloadSalesReport(reportDate) {
  const url = new URL("https://api.appstoreconnect.apple.com/v1/salesReports");
  url.searchParams.set("filter[frequency]", "DAILY");
  url.searchParams.set("filter[reportDate]", reportDate);
  url.searchParams.set("filter[reportSubType]", "SUMMARY");
  url.searchParams.set("filter[reportType]", "SALES");
  url.searchParams.set("filter[vendorNumber]", configuration.vendorNumber);
  url.searchParams.set("filter[version]", "1_0");
  const response = await request(url, {
    headers: { Authorization: `Bearer ${appStoreToken()}`, Accept: "application/a-gzip" },
    redirect: "error"
  });
  if (response.status === 404) return { available: false, rows: [] };
  if (!response.ok) {
    throw new SyncSourceError(`app_store_http_${response.status}`);
  }
  return {
    available: true,
    rows: parseTsv(Buffer.from(await response.arrayBuffer()), reportDate)
  };
}

function aggregateReport(reportDate, rows) {
  const byTerritory = new Map();
  for (const row of rows) {
    if (String(row["Apple Identifier"] ?? "") !== configuration.appId) continue;
    const territory = String(row["Country Code"] ?? "").trim().toUpperCase();
    if (!/^[A-Z]{2}$/.test(territory)) continue;
    const productType = String(row["Product Type Identifier"] ?? "").trim();
    if (!downloadProductTypes.has(productType) && !redownloadProductTypes.has(productType) && !updateProductTypes.has(productType)) continue;
    const amount = units(row.Units);
    const aggregate = byTerritory.get(territory) ?? {
      metric_date: reportDate,
      territory,
      first_time_downloads: 0,
      redownloads: 0,
      updates: 0,
      impressions: null,
      product_page_views: null,
      installations: null,
      app_sessions: null,
      crashes: null,
      source: "app_store_connect_sales_trends",
      source_report_version: "sales_summary_1_0",
      synced_at: new Date().toISOString()
    };
    if (downloadProductTypes.has(productType)) aggregate.first_time_downloads += amount;
    else if (redownloadProductTypes.has(productType)) aggregate.redownloads += amount;
    else if (updateProductTypes.has(productType)) aggregate.updates += amount;
    byTerritory.set(territory, aggregate);
  }
  return [...byTerritory.values()].map((row) => {
    for (const field of ["first_time_downloads", "redownloads", "updates"]) {
      if (!Number.isSafeInteger(row[field]) || row[field] < 0 || row[field] > 2147483647) throw new SyncSourceError("aggregate_units_require_review");
    }
    return row;
  });
}

async function supabaseUpsert(table, rows, conflict) {
  if (rows.length === 0) return;
  const url = new URL(`/rest/v1/${table}`, configuration.supabaseUrl);
  url.searchParams.set("on_conflict", conflict);
  const response = await request(url, {
    method: "POST",
    headers: {
      apikey: configuration.supabaseServiceRoleKey,
      Authorization: `Bearer ${configuration.supabaseServiceRoleKey}`,
      "Content-Type": "application/json",
      Prefer: "resolution=merge-duplicates,return=minimal"
    },
    body: JSON.stringify(rows),
    redirect: "error"
  });
  if (!response.ok) {
    throw new SyncSourceError(`supabase_upsert_http_${response.status}`);
  }
}

async function recordSyncState(status, detail, latestDataAt = null) {
  const current = syncStateUpdates(status, detail, new Date(), latestDataAt);
  const base = new URL("/rest/v1/analytics_source_sync_state", configuration.supabaseUrl);
  const headers = { apikey: configuration.supabaseServiceRoleKey, Authorization: `Bearer ${configuration.supabaseServiceRoleKey}`, "Content-Type": "application/json" };
  const insert = new URL(base); insert.searchParams.set("on_conflict", "source");
  // Ensure a missing row exists; DO NOTHING never resets prior successful data.
  const initialized = await request(insert, { method: "POST", headers: { ...headers, Prefer: "resolution=ignore-duplicates,return=minimal" }, body: JSON.stringify([{ source: "app_store_connect", ...current }]), redirect: "error" });
  if (!initialized.ok) throw new SyncSourceError(`supabase_state_initialize_http_${initialized.status}`);
  const patch = new URL(base); patch.searchParams.set("source", "eq.app_store_connect");
  const updated = await request(patch, { method: "PATCH", headers, body: JSON.stringify(current), redirect: "error" });
  if (!updated.ok) throw new SyncSourceError(`supabase_state_update_http_${updated.status}`);
  if (status === "success") {
    // Older lookback imports must not move latest_data_at backwards.
    patch.searchParams.set("or", `(latest_data_at.is.null,latest_data_at.lt.${latestDataAt})`);
    const freshness = await request(patch, { method: "PATCH", headers, body: JSON.stringify({ latest_data_at: latestDataAt }), redirect: "error" });
    if (!freshness.ok) throw new SyncSourceError(`supabase_freshness_update_http_${freshness.status}`);
  }
}

async function main() {
  const records = [];
  let availableReports = 0;
  for (const date of reportDates()) {
    const report = await downloadSalesReport(date);
    if (!report.available) continue;
    availableReports += 1;
    records.push(...aggregateReport(date, report.rows));
  }
  await supabaseUpsert("app_store_metrics_daily", records, "metric_date,territory");
  const latestDataAt = records.length > 0
    ? `${records.map((record) => record.metric_date).sort().at(-1)}T23:59:59Z`
    : null;
  const status = records.length > 0 ? "success" : "empty";
  await recordSyncState(
    status,
    `${availableReports} reports available; ${records.length} app territory-day aggregates stored.`,
    latestDataAt
  );
  process.stdout.write(JSON.stringify({
    status,
    checkedDays: configuration.days,
    availableReports,
    storedRows: records.length,
    latestDataAt
  }, null, 2) + "\n");
}

main().catch(async (error) => {
  const message = error instanceof SyncSourceError ? error.message : "source_sync_failed";
  try {
    await recordSyncState("error", message);
  } catch {
    // Preserve the original source failure; never print credentials or request headers.
  }
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
});
