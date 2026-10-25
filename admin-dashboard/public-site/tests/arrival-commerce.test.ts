import assert from "node:assert/strict";
import { afterEach, test } from "node:test";
import { ACCOUNT_PATH, accountReturn, commerceConfig, checkoutDestination, startCheckout, readAccount, CommerceError, type CommerceConfig } from "../src/lib/arrival-commerce.ts";

const config: CommerceConfig = { mode: "sandbox", api: "https://commerce.example.invalid", supabaseUrl: "https://fixture.supabase.co", publicKey: "sb_publishable_test_fixture", checkoutEnabled: true };
const envNames = ["NEXT_PUBLIC_ARRIVAL_COMMERCE_ENABLED", "NEXT_PUBLIC_ARRIVAL_CHECKOUT_ENABLED", "NEXT_PUBLIC_ARRIVAL_COMMERCE_MODE", "NEXT_PUBLIC_ARRIVAL_COMMERCE_API_URL", "NEXT_PUBLIC_SUPABASE_URL", "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY"];
const originalEnv = Object.fromEntries(envNames.map(name => [name, process.env[name]]));
const originalFetch = globalThis.fetch;
afterEach(() => {
  globalThis.fetch = originalFetch;
  for (const name of envNames) {
    if (originalEnv[name] === undefined) delete process.env[name];
    else process.env[name] = originalEnv[name];
  }
});

test("missing, unknown and live modes keep the sandbox candidate closed", () => {
  process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_ENABLED = "true";
  process.env.NEXT_PUBLIC_ARRIVAL_CHECKOUT_ENABLED = "true";
  process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_API_URL = config.api;
  process.env.NEXT_PUBLIC_SUPABASE_URL = config.supabaseUrl;
  process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY = config.publicKey;
  for (const mode of [undefined, "", "test", "live"]) {
    if (mode === undefined) delete process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_MODE;
    else process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_MODE = mode;
    assert.equal(commerceConfig(), null);
  }
  process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_MODE = "sandbox";
  assert.equal(commerceConfig()?.mode, "sandbox");
  assert.equal(commerceConfig()?.checkoutEnabled, true);
  process.env.NEXT_PUBLIC_ARRIVAL_CHECKOUT_ENABLED = "false";
  assert.equal(commerceConfig()?.checkoutEnabled, false);
  process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_ENABLED = "false";
  assert.equal(commerceConfig(), null);
});

test("live config and paused checkout are rejected before transport", async () => {
  let calls = 0;
  globalThis.fetch = async () => { calls++; return Response.json({}); };
  for (const invalid of [{ ...config, mode: "live" } as unknown as CommerceConfig, { ...config, checkoutEnabled: false }]) {
    await assert.rejects(startCheckout(invalid, "fixture-token", { key: "11111111-1111-4111-8111-111111111111" }), error => error instanceof CommerceError && error.status === 403);
  }
  assert.equal(calls, 0);
});

test("only test Stripe sessions are accepted; their opaque fragments survive", () => {
  const url = "https://checkout.stripe.com/c/pay/cs_test_a1RealisticSession42#fidkdWxOYHwn";
  assert.equal(checkoutDestination(url), url);
  assert.equal(checkoutDestination(null), null);
  for (const path of ["cs_live_a1RealisticSession42", "cs_other_42", "cs_test_", "cs_test_a1/extra", "cs_test_a1%2Fextra"]) {
    assert.throws(() => checkoutDestination(`https://checkout.stripe.com/c/pay/${path}`));
  }
});

test("the frozen catalog stays compatible, but explicit live or malformed mode is rejected", async () => {
  const product = { id: "arrival_planner_v1", title: "Arrival Planner", amountMinor: 1499, currency: "eur", version: "1.0.0", renewal: "none" };
  let catalog: unknown = { products: [product] };
  globalThis.fetch = async input => Response.json(String(input).endsWith("/catalog") ? catalog : String(input).endsWith("/notifications") ? { notifications: [] } : { orders: [] });
  assert.equal((await readAccount(config, "fixture-token")).product.id, product.id);
  for (const livemode of [true, "false", null]) {
    catalog = { livemode, products: [product] };
    await assert.rejects(readAccount(config, "fixture-token"));
    catalog = { products: [{ ...product, livemode }] };
    await assert.rejects(readAccount(config, "fixture-token"));
  }
  catalog = { livemode: false, products: [{ ...product, livemode: false }] };
  assert.equal((await readAccount(config, "fixture-token")).product.id, product.id);
});

test("success and cancel return URLs preserve only an unambiguous display hint across refresh", () => {
  for (const checkout of ["complete", "cancelled"] as const) {
    const result = accountReturn(`?checkout=${checkout}&paid=true&downloadAvailable=true&orderId=untrusted&code=secret&redirect=https://untrusted.invalid`);
    assert.deepEqual(result, { checkout, path: `${ACCOUNT_PATH}?checkout=${checkout}` });
    assert.deepEqual(accountReturn(new URL(result.path, "https://preview.invalid").search), result);
  }
  for (const query of ["", "?paid=true", "?checkout=paid", "?checkout=complete&checkout=cancelled", "?checkout=complete&checkout=complete", "?error=auth_error&code=secret"]) {
    assert.deepEqual(accountReturn(query), { checkout: null, path: ACCOUNT_PATH });
  }
});

test("a checkout-complete query cannot replace the server order or unlock a download", async () => {
  const order = { id: "22222222-2222-4222-8222-222222222222", productId: "arrival_planner_v1", status: "pending", amountMinor: 1499, currency: "eur", paidAt: null, downloadAvailable: false, renewal: "none" };
  const product = { id: order.productId, title: "Arrival Planner", amountMinor: 1499, currency: "eur", version: "1.0.0", renewal: "none" };
  const requests: string[] = [];
  globalThis.fetch = async (input, options) => {
    const url = String(input); requests.push(url);
    assert.equal(options?.method, "GET");
    return Response.json(url.endsWith("/catalog") ? { products: [product] } : url.endsWith("/notifications") ? { notifications: [] } : { orders: [order] });
  };
  assert.equal(accountReturn("?checkout=complete&status=paid&downloadAvailable=true").checkout, "complete");
  const account = await readAccount(config, "fixture-token");
  assert.equal(account.orders[0].status, "pending");
  assert.equal(account.orders[0].downloadAvailable, false);
  assert.equal(account.orders[0].paidAt, null);
  assert.deepEqual(requests.sort(), ["/catalog", "/me/notifications", "/me/orders"].map(path => config.api + path).sort());
});
