import { createPrivateKey, sign } from "node:crypto";
import { gunzipSync } from "node:zlib";

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
  || !configuration.supabaseUrl.hostname.endsWith(".supabase.co")) {
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

function parseTsv(buffer) {
  const decompressed = buffer[0] === 0x1f && buffer[1] === 0x8b ? gunzipSync(buffer) : buffer;
  const text = decompressed.toString("utf8").replace(/^\uFEFF/, "").trim();
  if (!text) return [];
  const lines = text.split(/\r?\n/);
  const headers = lines.shift().split("\t").map((header) => header.trim());
  return lines.filter(Boolean).map((line) => {
    const values = line.split("\t");
    return Object.fromEntries(headers.map((header, index) => [header, values[index] ?? ""]));
  });
}

function units(value) {
  const parsed = Number.parseInt(value || "0", 10);
  return Number.isFinite(parsed) ? parsed : 0;
}

async function downloadSalesReport(reportDate) {
  const url = new URL("https://api.appstoreconnect.apple.com/v1/salesReports");
  url.searchParams.set("filter[frequency]", "DAILY");
  url.searchParams.set("filter[reportDate]", reportDate);
  url.searchParams.set("filter[reportSubType]", "SUMMARY");
  url.searchParams.set("filter[reportType]", "SALES");
  url.searchParams.set("filter[vendorNumber]", configuration.vendorNumber);
  url.searchParams.set("filter[version]", "1_0");
  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${appStoreToken()}`, Accept: "application/a-gzip" },
    redirect: "error"
  });
  if (response.status === 404) return { available: false, rows: [] };
  if (!response.ok) {
    const detail = (await response.text()).slice(0, 300);
    throw new Error(`App Store Connect ${response.status}: ${detail || response.statusText}`);
  }
  return {
    available: true,
    rows: parseTsv(Buffer.from(await response.arrayBuffer()))
  };
}

function aggregateReport(reportDate, rows) {
  const byTerritory = new Map();
  for (const row of rows) {
    if (String(row["Apple Identifier"] ?? "") !== configuration.appId) continue;
    const territory = String(row["Country Code"] ?? "").trim().toUpperCase();
    if (!/^[A-Z]{2}$/.test(territory)) continue;
    const productType = String(row["Product Type Identifier"] ?? "").trim();
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
  return [...byTerritory.values()].map((row) => ({
    ...row,
    first_time_downloads: Math.max(0, row.first_time_downloads),
    redownloads: Math.max(0, row.redownloads),
    updates: Math.max(0, row.updates)
  }));
}

async function supabaseUpsert(table, rows, conflict) {
  if (rows.length === 0) return;
  const url = new URL(`/rest/v1/${table}`, configuration.supabaseUrl);
  url.searchParams.set("on_conflict", conflict);
  const response = await fetch(url, {
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
    const detail = (await response.text()).slice(0, 300);
    throw new Error(`Supabase ${table} upsert ${response.status}: ${detail || response.statusText}`);
  }
}

async function recordSyncState(status, detail, latestDataAt = null) {
  await supabaseUpsert("analytics_source_sync_state", [{
    source: "app_store_connect",
    status,
    last_attempt_at: new Date().toISOString(),
    last_success_at: status === "error" ? null : new Date().toISOString(),
    latest_data_at: latestDataAt,
    detail: detail.slice(0, 500)
  }], "source");
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
  const message = error instanceof Error ? error.message : String(error);
  try {
    await recordSyncState("error", message);
  } catch {
    // Preserve the original source failure; never print credentials or request headers.
  }
  process.stderr.write(`${message}\n`);
  process.exitCode = 1;
});
