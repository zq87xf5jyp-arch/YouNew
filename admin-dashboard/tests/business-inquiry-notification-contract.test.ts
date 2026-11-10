import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { readFileSync } from "node:fs";
import { runInNewContext } from "node:vm";
import test from "node:test";
import ts from "typescript";

const migration = await readFile(
  new URL("../supabase/migrations/20260818194626_add_business_inquiry_notification_inbox.sql", import.meta.url),
  "utf8"
);
const sqlTest = await readFile(
  new URL("../supabase/tests/business_inquiry_notification_test.sql", import.meta.url),
  "utf8"
);
const page = await readFile(new URL("../src/app/(admin)/business-inquiries/page.tsx", import.meta.url), "utf8");
const actions = await readFile(new URL("../src/app/(admin)/business-inquiries/actions.ts", import.meta.url), "utf8");

test("a new inquiry creates one PII-minimised Admin inbox notification", () => {
  assert.match(migration, /create table public\.business_inquiry_notifications/);
  assert.match(migration, /after insert on public\.business_inquiries/);
  assert.match(migration, /unique \(inquiry_id\)/);
  assert.match(sqlTest, /an exact retry creates no second notification/);
  assert.match(sqlTest, /notification storage has no submitted PII columns/);
  assert.doesNotMatch(migration, /\bnet\.http|\bhttp_request\s*\(|\bsend_email\s*\(|\bsmtp\./i);
});

test("the notification table combines explicit grants with approved-Admin RLS", () => {
  assert.match(migration, /alter table public\.business_inquiry_notifications enable row level security/);
  assert.match(migration, /revoke all on table public\.business_inquiry_notifications from public, anon, authenticated/);
  assert.match(migration, /grant select on table public\.business_inquiry_notifications to authenticated/);
  assert.match(migration, /grant update \(status\) on table public\.business_inquiry_notifications to authenticated/);
  assert.match(migration, /private\.is_approved_admin\(\)/);
  assert.match(migration, /private\.current_admin_role\(\)[\s\S]*owner[\s\S]*admin/);
});

test("Admin exposes and acknowledges the inbox without copying inquiry PII", () => {
  assert.match(page, /from\("business_inquiry_notifications"\)\.select\("id,inquiry_id,reference_code,notification_kind,status,created_at,read_at,read_by"\)/);
  assert.match(page, /BusinessInquiryNotificationInbox/);
  assert.match(actions, /export async function updateBusinessInquiryNotification/);
  assert.match(actions, /\.from\("business_inquiry_notifications"\)/);
  assert.match(actions, /\.update\(\{ status \}\)/);
  assert.doesNotMatch(page, /notification\.(?:company_name|contact_person|email|message|utm_)/);
  assert.doesNotMatch(page, /from\("business_inquiry_notifications"\)\.select\("\*"\)/);
});

type RuntimeNode = { type: unknown; props: Record<string, unknown> };

function loadRuntime(file: string, overrides: Record<string, unknown> = {}) {
  const module = { exports: {} as Record<string, unknown> };
  const output = ts.transpileModule(readFileSync(new URL(`../${file}`, import.meta.url), "utf8"), {
    compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.CommonJS, jsx: ts.JsxEmit.ReactJSX, esModuleInterop: true }
  }).outputText;
  const jsx = (type: unknown, props: Record<string, unknown>): RuntimeNode => ({ type, props });
  runInNewContext(output, {
    module, exports: module.exports, Intl, Date, Number,
    require(name: string) {
      if (name === "react/jsx-runtime") return { jsx, jsxs: jsx };
      if (Object.hasOwn(overrides, name)) return overrides[name];
      throw new Error(`Unexpected runtime dependency: ${name}`);
    }
  });
  return module.exports;
}

function nodes(node: unknown): RuntimeNode[] {
  if (!node || typeof node !== "object" || !("props" in node)) return [];
  const current = node as RuntimeNode;
  return [current, ...[current.props.children].flat(Infinity).flatMap(nodes)];
}

test("actual protected layout keeps missing, invalid and failed exact counts unknown", async () => {
  const authorization = loadRuntime("src/lib/authorization.ts");
  for (const count of [null, undefined, -1, NaN, Infinity, 1.5, Number.MAX_SAFE_INTEGER + 1, "1", 0, 1, 100]) {
    for (const failed of [false, true]) {
      const layout = loadRuntime("src/app/(admin)/layout.tsx", {
        "@/components/admin/admin-shell": { AdminShell: "shell" },
        "@/lib/auth": { requireAdmin: async () => ({ role: "owner", full_name: "Synthetic owner" }) },
        "@/lib/authorization": authorization,
        "@/lib/supabase/server": { createSupabaseServerClient: async () => ({ from: (table: string) => {
          assert.equal(table, "business_inquiry_notifications");
          return { select: (columns: string, options: unknown) => {
            assert.equal(columns, "id");
            assert.equal(JSON.stringify(options), JSON.stringify({ count: "exact", head: true }));
            return { eq: async (key: string, value: string) => {
              assert.equal(key, "status"); assert.equal(value, "unread");
              return { count, error: failed ? { message: "Synthetic unavailable" } : null };
            } };
          } };
        } }) }
      }).default as (props: { children: null }) => Promise<RuntimeNode>;
      const tree = await layout({ children: null });
      const expected = !failed && typeof count === "number" && Number.isSafeInteger(count) && count >= 0 ? count : null;
      assert.equal(tree.props.unreadNotifications, expected);
    }
  }
});

test("actual protected layout does not request notifications for unauthorized roles", async () => {
  const authorization = loadRuntime("src/lib/authorization.ts");
  for (const role of ["viewer", "editor", "qa"]) {
    let clients = 0;
    const layout = loadRuntime("src/app/(admin)/layout.tsx", {
      "@/components/admin/admin-shell": { AdminShell: "shell" },
      "@/lib/auth": { requireAdmin: async () => ({ role, full_name: "Synthetic role" }) },
      "@/lib/authorization": authorization,
      "@/lib/supabase/server": { createSupabaseServerClient: async () => { clients++; return null; } }
    }).default as (props: { children: null }) => Promise<RuntimeNode>;
    assert.equal((await layout({ children: null })).props.unreadNotifications, null);
    assert.equal(clients, 0);
  }
});

test("actual inbox formats Amsterdam summer, winter and DST times independently of server timezone", () => {
  const inbox = loadRuntime("src/components/admin/business-inquiry-notification-inbox.tsx", {
    "next/link": "link", "lucide-react": { BellRing: "icon" },
    "@/app/(admin)/business-inquiries/actions": { updateBusinessInquiryNotification: () => undefined },
    "@/components/ui/badge": { Badge: "badge" }, "@/components/ui/button": { Button: "button" },
    "@/components/ui/card": Object.fromEntries(["Card", "CardContent", "CardDescription", "CardHeader", "CardTitle"].map(name => [name, name]))
  }).BusinessInquiryNotificationInbox as (props: { notifications: Record<string, unknown>[]; available: boolean }) => RuntimeNode;
  const original = process.env.TZ;
  try {
    for (const serverTimezone of ["UTC", "Europe/Amsterdam", "America/New_York"]) {
      process.env.TZ = serverTimezone;
      for (const [createdAt, expectedTime] of [["2026-09-19T12:00:00Z", "14:00"], ["2026-01-19T12:00:00Z", "13:00"], ["2026-03-29T00:30:00Z", "01:30"], ["2026-03-29T01:30:00Z", "03:30"]]) {
        const tree = inbox({ available: true, notifications: [{ id: "synthetic", inquiry_id: "synthetic", reference_code: "YN-SYNTHETIC", status: "unread", created_at: createdAt }] });
        const all = nodes(tree);
        const time = all.find(node => node.type === "time");
        assert.ok(time);
        assert.equal(time.props.dateTime, createdAt);
        assert.ok(String(time.props.children).endsWith(expectedTime), `${serverTimezone}: ${createdAt}`);
        assert.ok(all.some(node => String(node.props.children).includes("время Амстердама")));
      }
    }
  } finally {
    if (original === undefined) delete process.env.TZ; else process.env.TZ = original;
  }
});
