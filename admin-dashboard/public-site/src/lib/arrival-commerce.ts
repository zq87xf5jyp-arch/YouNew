import { createClient, type SupabaseClient } from "@supabase/supabase-js";

export const ARRIVAL_PRODUCT = "arrival_planner_v1";
export const ACCOUNT_PATH = "/arrival-planner/account/";
export type CheckoutReturn = "complete" | "cancelled" | null;

// A checkout query is display context only. It never establishes a paid order or access.
export function accountReturn(search: string): { checkout: CheckoutReturn; path: string } {
  const values = new URLSearchParams(search).getAll("checkout");
  const checkout = values.length === 1 && (values[0] === "complete" || values[0] === "cancelled") ? values[0] : null;
  return { checkout, path: `${ACCOUNT_PATH}${checkout ? `?checkout=${checkout}` : ""}` };
}

export type CommerceConfig = { mode: "sandbox"; api: string; supabaseUrl: string; publicKey: string; checkoutEnabled: boolean };
export type ArrivalOrder = { id: string; productId: string; status: "creating" | "pending" | "paid" | "refunded" | "expired"; amountMinor: number; currency: string; paidAt: number | null; downloadAvailable: boolean; renewal: "none" };
export type ArrivalNotice = { id: string; orderId: string; kind: "purchase_ready" | "purchase_refunded"; createdAt: number };
export type ArrivalProduct = { id: string; title: string; amountMinor: number; currency: string; version: string; renewal: "none" };
export type CheckoutAttempt = { key: string; orderId?: string };
export const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const record = (v: unknown): v is Record<string, unknown> => v !== null && typeof v === "object" && !Array.isArray(v);
const string = (v: unknown): v is string => typeof v === "string" && v.length > 0 && v.length < 500;
const timestamp = (v: unknown): v is number => typeof v === "number" && Number.isSafeInteger(v) && v >= 0 && v <= 8_640_000_000_000_000;
const orderStatus = (v: unknown): v is ArrivalOrder["status"] => typeof v === "string" && ["creating", "pending", "paid", "refunded", "expired"].includes(v);

// Build-time public configuration only. No caller-supplied URL or secret key.
export function commerceConfig(): CommerceConfig | null {
  // This release candidate has only been accepted for sandbox use. Live needs a separate release.
  if (process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_ENABLED !== "true" || process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_MODE !== "sandbox") return null;
  try {
    const api = new URL(process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_API_URL ?? "");
    const supabase = new URL(process.env.NEXT_PUBLIC_SUPABASE_URL ?? "");
    const publicKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "";
    if ([api, supabase].some(u => u.protocol !== "https:" || u.username || u.password || u.search || u.hash || u.port)) return null;
    if (!supabase.hostname.endsWith(".supabase.co") || supabase.pathname !== "/") return null;
    if (!publicKey.startsWith("sb_publishable_")) {
      const encoded = publicKey.split(".")[1];
      if (!encoded || JSON.parse(atob(encoded.replace(/-/g, "+").replace(/_/g, "/"))).role !== "anon") return null;
    }
    return { mode: "sandbox", api: api.href.replace(/\/$/, ""), supabaseUrl: supabase.origin, publicKey, checkoutEnabled: process.env.NEXT_PUBLIC_ARRIVAL_CHECKOUT_ENABLED === "true" };
  } catch { return null; }
}

let authClient: SupabaseClient | null = null;
export function arrivalAuth(config: CommerceConfig): SupabaseClient {
  if (!authClient) authClient = createClient(config.supabaseUrl, config.publicKey, {
    auth: { flowType: "pkce", detectSessionInUrl: true, persistSession: true, autoRefreshToken: true, storageKey: "younew-arrival-auth-v1" },
  });
  return authClient;
}

export class CommerceError extends Error {
  readonly status: number;
  constructor(status: number) { super("The purchase service could not complete this request."); this.status = status; }
}

async function request(config: CommerceConfig, path: string, token?: string, body?: unknown): Promise<Response> {
  if (config.mode !== "sandbox") throw new CommerceError(403);
  const response = await fetch(`${config.api}${path}`, {
    method: body === undefined ? "GET" : "POST", cache: "no-store", credentials: "omit", redirect: "error", referrerPolicy: "no-referrer",
    headers: { Accept: "application/json", ...(token ? { Authorization: `Bearer ${token}` } : {}), ...(body === undefined ? {} : { "Content-Type": "application/json" }) },
    body: body === undefined ? undefined : JSON.stringify(body), signal: AbortSignal.timeout(20000),
  });
  if (!response.ok) throw new CommerceError(response.status);
  return response;
}

export async function readAccount(config: CommerceConfig, token: string): Promise<{ orders: ArrivalOrder[]; notifications: ArrivalNotice[]; product: ArrivalProduct }> {
  const [ordersData, noticesData, catalogData]: unknown[] = await Promise.all([
    request(config, "/me/orders", token).then(r => r.json()), request(config, "/me/notifications", token).then(r => r.json()), request(config, "/catalog").then(r => r.json()),
  ]);
  if (!record(ordersData) || !Array.isArray(ordersData.orders) || !record(noticesData) || !Array.isArray(noticesData.notifications) || !record(catalogData) || !Array.isArray(catalogData.products)) throw new CommerceError(502);
  // The frozen sandbox catalog has no mode field. Never reinterpret a future live catalog as a test.
  if ("livemode" in catalogData && catalogData.livemode !== false) throw new CommerceError(502);
  const orders: ArrivalOrder[] = ordersData.orders.map((v: unknown) => {
    if (!record(v) || !string(v.id) || !uuid.test(v.id) || v.productId !== ARRIVAL_PRODUCT || !orderStatus(v.status) || !Number.isSafeInteger(v.amountMinor) || Number(v.amountMinor) < 0 || v.currency !== "eur" || !(v.paidAt === null || timestamp(v.paidAt)) || typeof v.downloadAvailable !== "boolean" || v.renewal !== "none") throw new CommerceError(502);
    return v as ArrivalOrder;
  });
  const notifications: ArrivalNotice[] = noticesData.notifications.map((v: unknown) => {
    if (!record(v) || !string(v.id) || !string(v.orderId) || !uuid.test(v.orderId) || !["purchase_ready", "purchase_refunded"].includes(String(v.kind)) || !timestamp(v.createdAt)) throw new CommerceError(502);
    return v as ArrivalNotice;
  });
  const product = catalogData.products.find((v: unknown) => record(v) && v.id === ARRIVAL_PRODUCT);
  if (!record(product) || product.amountMinor !== 1499 || product.currency !== "eur" || product.renewal !== "none" || !string(product.title) || !string(product.version)) throw new CommerceError(502);
  if ("livemode" in product && product.livemode !== false) throw new CommerceError(502);
  return { orders, notifications, product: product as ArrivalProduct };
}

export function checkoutDestination(value: unknown): string | null {
  if (value === null) return null;
  if (typeof value !== "string") throw new CommerceError(502);
  const url = new URL(value);
  // Stripe's hosted session URL can include its own opaque fragment. Preserve it.
  if (url.protocol !== "https:" || url.hostname !== "checkout.stripe.com" || url.username || url.password || url.port || !/^\/c\/pay\/cs_test_[A-Za-z0-9]+$/.test(url.pathname)) throw new CommerceError(502);
  return url.href;
}

export async function startCheckout(config: CommerceConfig, token: string, attempt: CheckoutAttempt): Promise<{ orderId: string; status: string; checkoutUrl: string | null }> {
  if (!config.checkoutEnabled || !uuid.test(attempt.key)) throw new CommerceError(403);
  const data: unknown = await (await request(config, "/checkout", token, { productId: ARRIVAL_PRODUCT, idempotencyKey: attempt.key })).json();
  if (!record(data) || !string(data.orderId) || !uuid.test(data.orderId) || !orderStatus(data.status)) throw new CommerceError(502);
  return { orderId: data.orderId, status: data.status, checkoutUrl: checkoutDestination(data.checkoutUrl) };
}

export async function downloadOrder(config: CommerceConfig, token: string, id: string): Promise<Blob> {
  if (!uuid.test(id)) throw new CommerceError(400);
  const response = await request(config, `/me/orders/${id}/download`, token);
  if (!/^text\/html(?:;|$)/i.test(response.headers.get("content-type") ?? "") || !/^attachment(?:;|$)/i.test(response.headers.get("content-disposition") ?? "")) throw new CommerceError(502);
  const result = await response.blob();
  if (!result.size || result.size > 5_000_000) throw new CommerceError(502);
  return result;
}

export function savedAttempt(userId: string): CheckoutAttempt {
  if (!uuid.test(userId)) throw new CommerceError(401);
  const key = `younew-arrival-checkout-v1:${userId}`;
  const raw = localStorage.getItem(key);
  if (raw) {
    const value: unknown = JSON.parse(raw);
    if (!record(value) || !string(value.key) || !uuid.test(value.key) || !(value.orderId === undefined || (string(value.orderId) && uuid.test(value.orderId)))) throw new CommerceError(409);
    return value as CheckoutAttempt;
  }
  const attempt = { key: crypto.randomUUID() };
  localStorage.setItem(key, JSON.stringify(attempt)); // Persist before any checkout request; storage failure stops the request.
  return attempt;
}

export function saveAttempt(userId: string, attempt: CheckoutAttempt): void {
  localStorage.setItem(`younew-arrival-checkout-v1:${userId}`, JSON.stringify(attempt));
}
