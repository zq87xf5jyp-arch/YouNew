import { createServer } from "node:http";

const host = "127.0.0.1";
const port = Number(process.env.E2E_FAKE_SUPABASE_PORT ?? "54329");
const role = process.env.E2E_ISOLATED_ROLE ?? "owner";
const now = new Date();
const userID = "10000000-0000-4000-8000-000000000001";
const email = `e2e-${role}@example.invalid`;

function base64url(value) {
  return Buffer.from(JSON.stringify(value)).toString("base64url");
}

const accessToken = [
  base64url({ alg: "HS256", typ: "JWT" }),
  base64url({
    aud: "authenticated",
    email,
    exp: Math.floor(now.getTime() / 1000) + 86_400,
    iat: Math.floor(now.getTime() / 1000),
    role: "authenticated",
    sub: userID
  }),
  "isolated-e2e-signature"
].join(".");

const user = {
  id: userID,
  aud: "authenticated",
  role: "authenticated",
  email,
  email_confirmed_at: now.toISOString(),
  phone: "",
  confirmed_at: now.toISOString(),
  app_metadata: { provider: "email", providers: ["email"] },
  user_metadata: { synthetic_test: true },
  identities: [],
  created_at: now.toISOString(),
  updated_at: now.toISOString(),
  is_anonymous: false
};

const initialArticles = [
  {
    id: "20000000-0000-4000-8000-000000000001",
    title: "Регистрация в муниципалитете",
    slug: "municipality-registration",
    short_description: "Synthetic E2E published row.",
    full_content: "Synthetic content used only by isolated browser tests.",
    language: "ru",
    status: "published",
    priority: 1,
    source_url: "https://example.invalid/official-source",
    tags: ["registration"],
    images: [],
    verified_date: "2026-08-18",
    reviewer_id: userID,
    requires_media: false,
    updated_at: now.toISOString(),
    canonical_title: "Municipality registration",
    subcategory: "registration",
    search_intents: ["documents.registration"],
    search_synonyms: ["registration"],
    search_keywords: ["municipality"],
    supported_languages: ["en", "nl", "ru"],
    country_scope: "NL",
    scope_level: "national",
    province: null,
    municipality: null,
    city: null,
    national_fallback: true,
    applicable_profiles: ["expat"],
    source_urls: ["https://example.invalid/official-source"],
    content_quality_score: 90,
    search_indexed: true,
    categories: { slug: "documents-services" }
  },
  {
    id: "20000000-0000-4000-8000-000000000002",
    title: "OVpay и общественный транспорт",
    slug: "ovpay-public-transport",
    short_description: "Synthetic E2E review row.",
    full_content: "Synthetic content used only by isolated browser tests.",
    language: "ru",
    status: "review",
    priority: 2,
    source_url: "https://example.invalid/ovpay",
    tags: ["transport"],
    images: [],
    verified_date: null,
    reviewer_id: null,
    requires_media: false,
    updated_at: now.toISOString(),
    canonical_title: "OVpay and public transport",
    subcategory: "public-transport",
    search_intents: ["transport.ovpay"],
    search_synonyms: ["ovpay"],
    search_keywords: ["public transport"],
    supported_languages: ["en", "nl", "ru"],
    country_scope: "NL",
    scope_level: "national",
    province: null,
    municipality: null,
    city: null,
    national_fallback: true,
    applicable_profiles: ["expat"],
    source_urls: ["https://example.invalid/ovpay"],
    content_quality_score: 80,
    search_indexed: false,
    categories: { slug: "transport" }
  },
  {
    id: "20000000-0000-4000-8000-000000000003",
    title: "Что делать с голландскими штрафами",
    slug: "dutch-fines",
    short_description: "Synthetic E2E draft row.",
    full_content: "Synthetic content used only by isolated browser tests.",
    language: "ru",
    status: "draft",
    priority: 3,
    source_url: "https://example.invalid/fines",
    tags: ["fines"],
    images: [],
    verified_date: null,
    reviewer_id: null,
    requires_media: false,
    updated_at: now.toISOString(),
    canonical_title: "Dutch fines",
    subcategory: "fines",
    search_intents: ["rules.fines"],
    search_synonyms: ["fines"],
    search_keywords: ["fine"],
    supported_languages: ["en", "nl", "ru"],
    country_scope: "NL",
    scope_level: "national",
    province: null,
    municipality: null,
    city: null,
    national_fallback: true,
    applicable_profiles: ["resident"],
    source_urls: ["https://example.invalid/fines"],
    content_quality_score: 70,
    search_indexed: false,
    categories: { slug: "rules-fines" }
  }
];

let articles = structuredClone(initialArticles);

const bugs = [
  {
    id: "30000000-0000-4000-8000-000000000001",
    title: "Synthetic mobile overflow regression",
    severity: "high",
    priority: "high",
    status: "open",
    platform: "iOS",
    app_screen: "Synthetic E2E",
    updated_at: now.toISOString()
  }
];

function json(response, status, body, headers = {}) {
  response.writeHead(status, {
    "access-control-allow-headers": "authorization, apikey, content-type, x-client-info",
    "access-control-allow-origin": "http://127.0.0.1:4173",
    "content-type": "application/json; charset=utf-8",
    ...headers
  });
  if (response.req.method === "HEAD" || status === 204) {
    response.end();
    return;
  }
  response.end(JSON.stringify(body));
}

function authSession() {
  return {
    access_token: accessToken,
    token_type: "bearer",
    expires_in: 86_400,
    expires_at: Math.floor(now.getTime() / 1000) + 86_400,
    refresh_token: "isolated-e2e-refresh-token",
    user
  };
}

function resetSyntheticState() {
  articles = structuredClone(initialArticles);
}

async function readJsonBody(request) {
  const chunks = [];
  for await (const chunk of request) chunks.push(chunk);
  if (chunks.length === 0) return {};
  return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

function filterRows(rows, url) {
  return rows.filter((row) => {
    for (const [key, filter] of url.searchParams) {
      if (["select", "order", "limit", "offset"].includes(key)) continue;
      if (filter.startsWith("eq.") && String(row[key] ?? "") !== filter.slice(3)) return false;
    }
    return true;
  });
}

function postgrestBody(request, rows) {
  const singular = request.headers.accept?.includes("application/vnd.pgrst.object+json");
  return singular ? (rows[0] ?? null) : rows;
}

function tableRows(table) {
  if (table === "profiles") {
    return [{
      id: userID,
      email,
      full_name: `Synthetic ${role}`,
      role,
      is_approved: true
    }];
  }
  if (table === "articles") return articles;
  if (table === "bugs") return bugs;
  return [];
}

async function postgrestResponse(request, response, url) {
  const table = decodeURIComponent(url.pathname.slice("/rest/v1/".length));
  if (table === "business_inquiry_notifications" && request.method === "HEAD") {
    json(response, 400, {
      code: "PGRST205",
      details: null,
      hint: null,
      message: "Synthetic E2E intentionally exercises the unavailable notification-count state."
    });
    return;
  }
  if (table === "content_sync_state" || table === "sync_jobs") {
    json(response, 400, {
      code: "PGRST205",
      details: null,
      hint: null,
      message: "Synthetic E2E intentionally leaves operational sync unavailable."
    });
    return;
  }

  if (table === "articles" && request.method === "POST") {
    const payload = await readJsonBody(request);
    const created = {
      ...payload,
      id: "20000000-0000-4000-8000-000000000099",
      updated_at: new Date().toISOString(),
      categories: { slug: "documents-services" }
    };
    articles.unshift(created);
    json(response, 201, postgrestBody(request, [{ id: created.id, updated_at: created.updated_at }]));
    return;
  }

  if (table === "articles" && request.method === "PATCH") {
    const payload = await readJsonBody(request);
    const matching = new Set(filterRows(articles, url).map((row) => row.id));
    const updatedAt = new Date().toISOString();
    articles = articles.map((row) => matching.has(row.id)
      ? { ...row, ...payload, updated_at: updatedAt }
      : row);
    const result = articles
      .filter((row) => matching.has(row.id))
      .map((row) => ({ id: row.id, updated_at: row.updated_at }));
    json(response, 200, postgrestBody(request, result));
    return;
  }

  if (table === "articles" && request.method === "DELETE") {
    const deleted = filterRows(articles, url);
    const deletedIDs = new Set(deleted.map((row) => row.id));
    articles = articles.filter((row) => !deletedIDs.has(row.id));
    json(response, 200, postgrestBody(request, deleted.map((row) => ({ id: row.id }))));
    return;
  }

  const rows = filterRows(tableRows(table), url);
  const countHeader = request.headers.prefer?.includes("count=exact")
    ? { "content-range": rows.length ? `0-${rows.length - 1}/${rows.length}` : "*/0" }
    : {};
  json(response, 200, postgrestBody(request, rows), countHeader);
}

const server = createServer(async (request, response) => {
  const url = new URL(request.url ?? "/", `http://${host}:${port}`);

  if (request.method === "OPTIONS") {
    response.writeHead(204, {
      "access-control-allow-headers": "authorization, apikey, content-type, x-client-info",
      "access-control-allow-methods": "GET, HEAD, POST, PATCH, DELETE, OPTIONS",
      "access-control-allow-origin": "http://127.0.0.1:4173"
    });
    response.end();
    return;
  }
  if (url.pathname === "/health") {
    json(response, 200, { synthetic: true, role });
    return;
  }
  if (url.pathname === "/auth/v1/token" && request.method === "POST") {
    resetSyntheticState();
    json(response, 200, authSession());
    return;
  }
  if (url.pathname === "/auth/v1/user" && request.method === "GET") {
    json(response, 200, user);
    return;
  }
  if (url.pathname === "/auth/v1/logout" && request.method === "POST") {
    json(response, 204, null);
    return;
  }
  if (url.pathname.startsWith("/rest/v1/")) {
    await postgrestResponse(request, response, url);
    return;
  }

  json(response, 404, {
    code: "E2E_STUB_ROUTE_NOT_FOUND",
    message: `No synthetic handler for ${request.method} ${url.pathname}`
  });
});

server.listen(port, host, () => {
  process.stdout.write(`Synthetic Supabase E2E server listening on http://${host}:${port}\n`);
});

for (const signal of ["SIGINT", "SIGTERM"]) {
  process.on(signal, () => server.close(() => process.exit(0)));
}
