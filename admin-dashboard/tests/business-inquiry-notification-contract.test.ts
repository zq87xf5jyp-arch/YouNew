import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

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
  assert.match(page, /fetchRowsResult<BusinessInquiryNotificationRow>\("business_inquiry_notifications"/);
  assert.match(page, /BusinessInquiryNotificationInbox/);
  assert.match(actions, /export async function updateBusinessInquiryNotification/);
  assert.match(actions, /\.from\("business_inquiry_notifications"\)/);
  assert.match(actions, /\.update\(\{ status \}\)/);
  assert.doesNotMatch(page, /notification\.(?:company_name|contact_person|email|message|utm_)/);
});
