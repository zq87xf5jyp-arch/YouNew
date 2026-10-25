"use client";

import Link from "next/link";
import { useEffect, useRef, useState, type FormEvent } from "react";
import type { Session } from "@supabase/supabase-js";
import { ACCOUNT_PATH, ARRIVAL_PRODUCT, CommerceError, accountReturn, arrivalAuth, commerceConfig, downloadOrder, readAccount, savedAttempt, saveAttempt, startCheckout, type ArrivalNotice, type ArrivalOrder, type ArrivalProduct, type CheckoutReturn } from "@/lib/arrival-commerce";

const config = commerceConfig();
const money = (amount: number, currency: string) => new Intl.NumberFormat("en-NL", { style: "currency", currency }).format(amount / 100);
const date = (value: number) => new Intl.DateTimeFormat("en-NL", { dateStyle: "medium", timeStyle: "short" }).format(new Date(value));
type AuthMode = "login" | "signup" | "recover";
const recoveryIntentKey = "younew-arrival-recovery-user-v1";

// A tab-local user ID marker carries no token. A different identity cannot inherit it.
function rememberRecovery(userId: string | null) {
  try {
    if (userId) sessionStorage.setItem(recoveryIntentKey, userId);
    else sessionStorage.removeItem(recoveryIntentKey);
  } catch { /* The signed-in Change password action remains available without storage. */ }
}

function recoveryFor(userId: string | null): boolean {
  try {
    const saved = sessionStorage.getItem(recoveryIntentKey);
    if (saved && saved !== userId) sessionStorage.removeItem(recoveryIntentKey);
    return userId !== null && saved === userId;
  } catch { return false; }
}

function errorMessage(error: unknown): string {
  if (error instanceof CommerceError) {
    if (error.status === 401) return "Your session could not be verified. Sign in again before checking a purchase.";
    if (error.status === 409) return "This attempt needs reconciliation. Refresh your purchases or contact support; do not start another payment.";
    if (error.status === 429) return "Too many requests. Please wait before trying again.";
    if (error.status === 404) return "This download is not currently available for your account. Refresh the purchase status.";
  }
  return "The result could not be confirmed. Refresh your purchases, or safely retry the same checkout attempt. Do not pay a second time while the first result is unknown.";
}

export function ArrivalPlannerAccount() {
  const [session, setSession] = useState<Session | null>(null);
  const [ready, setReady] = useState(false);
  const [mode, setMode] = useState<AuthMode>("login");
  const [passwordRecovery, setPasswordRecovery] = useState(false);
  const [orders, setOrders] = useState<ArrivalOrder[]>([]);
  const [notifications, setNotifications] = useState<ArrivalNotice[]>([]);
  const [product, setProduct] = useState<ArrivalProduct | null>(null);
  const [checkedAt, setCheckedAt] = useState<number | null>(null);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [returnState, setReturnState] = useState<CheckoutReturn>(null);
  const lock = useRef(false);
  const identity = useRef<string | null>(null);
  const refreshSequence = useRef(0);

  useEffect(() => {
    const returning = accountReturn(window.location.search);
    setReturnState(returning.checkout);
    const finish = () => {
      // Keep only the display hint. Enabled Auth must finish its PKCE exchange first.
      window.history.replaceState({}, "", returning.path);
      setReady(true);
    };
    if (!config) { finish(); return; }
    const auth = arrivalAuth(config);
    let active = true;
    const accept = (next: Session | null) => {
      if (!active) return;
      if (identity.current !== (next?.user.id ?? null)) {
        identity.current = next?.user.id ?? null;
        refreshSequence.current += 1;
        setOrders([]); setNotifications([]); setProduct(null); setCheckedAt(null);
      }
      setSession(next);
      setPasswordRecovery(recoveryFor(next?.user.id ?? null));
    };
    // The callback does not await other Auth methods (avoids SDK lock deadlocks).
    const { data: { subscription } } = auth.auth.onAuthStateChange((event, next) => {
      accept(next);
      if (active && event === "PASSWORD_RECOVERY" && next) { rememberRecovery(next.user.id); setPasswordRecovery(true); }
      if (active && event === "SIGNED_OUT") { rememberRecovery(null); setPasswordRecovery(false); }
    });
    auth.auth.getSession().then(({ data, error: authError }) => {
      if (!active) return;
      accept(authError ? null : data.session);
      if (authError) setError("The sign-in link could not be completed. Request a new link in this browser or sign in with your password.");
    }).catch(() => { if (active) setError("Sign-in is temporarily unavailable. Please try again later."); })
      .finally(() => { if (active) finish(); });
    return () => { active = false; subscription.unsubscribe(); };
  }, []);

  useEffect(() => {
    if (!config || !session) return;
    const currentConfig = config;
    const token = session.access_token;
    const userId = session.user.id;
    const sequence = ++refreshSequence.current;
    let active = true;
    readAccount(currentConfig, token).then(data => {
      if (!active || identity.current !== userId || sequence !== refreshSequence.current) return;
      setOrders(data.orders); setNotifications(data.notifications); setProduct(data.product); setCheckedAt(Date.now());
    }).catch(e => { if (active && identity.current === userId && sequence === refreshSequence.current) setError(errorMessage(e)); });
    return () => { active = false; };
  }, [session]);

  async function run(action: () => Promise<void>) {
    if (lock.current) return;
    lock.current = true; setBusy(true); setError(""); setMessage("");
    try { await action(); } catch (e) { setError(errorMessage(e)); }
    finally { lock.current = false; setBusy(false); }
  }

  async function currentSession(): Promise<Session> {
    if (!config) throw new CommerceError(503);
    const { data, error: authError } = await arrivalAuth(config).auth.getSession();
    if (authError || !data.session || data.session.user.id !== identity.current) throw new CommerceError(401);
    return data.session;
  }

  async function refresh() {
    if (!config) return;
    const next = await currentSession();
    const sequence = ++refreshSequence.current;
    const data = await readAccount(config, next.access_token);
    if (next.user.id !== identity.current || sequence !== refreshSequence.current) return;
    setOrders(data.orders); setNotifications(data.notifications); setProduct(data.product); setCheckedAt(Date.now());
    setMessage("Test purchase status refreshed from the service. Only a confirmed test payment unlocks this sandbox download.");
  }

  function submitAuth(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!config) return;
    const form = event.currentTarget;
    const values = new FormData(form);
    const email = String(values.get("email") ?? "").trim();
    const password = String(values.get("password") ?? "");
    void run(async () => {
      const auth = arrivalAuth(config!);
      const redirect = new URL(ACCOUNT_PATH, window.location.origin).href;
      if (passwordRecovery) {
        if (password !== values.get("confirmation")) { setError("The passwords do not match."); return; }
        await currentSession();
        const result = await auth.auth.updateUser({ password });
        if (result.error) { setError("The password could not be updated. Check the password requirements or request a new recovery link."); return; }
        rememberRecovery(null); setPasswordRecovery(false); form.reset(); setMessage("Your password has been updated.");
      } else if (mode === "recover") {
        const result = await auth.auth.resetPasswordForEmail(email, { redirectTo: redirect });
        if (result.error) { setError("A recovery request could not be completed. Please wait and try again."); return; }
        form.reset(); setMessage("If an eligible account exists, a recovery email will arrive. Open its link in this browser to complete the secure recovery flow.");
      } else if (mode === "signup") {
        const result = await auth.auth.signUp({ email, password, options: { emailRedirectTo: redirect } });
        if (result.error) { setError("Account creation could not be completed. Check your details or try signing in to an existing account."); return; }
        form.reset(); setMessage("Check your email for confirmation if required. Open the link in this browser, then return to your purchases. Signing up does not make a purchase.");
      } else {
        const result = await auth.auth.signInWithPassword({ email, password });
        if (result.error) { setError("Sign-in failed. Check your email and password, confirm your email if required, or request password recovery."); return; }
        form.reset(); setMessage("Signed in to the sandbox. Checking your test purchases.");
      }
    });
  }

  async function checkout() {
    if (!config?.checkoutEnabled || !product || product.id !== ARRIVAL_PRODUCT) throw new CommerceError(503);
    const next = await currentSession();
    const attempt = savedAttempt(next.user.id);
    const result = await startCheckout(config, next.access_token, attempt);
    if (next.user.id !== identity.current) return;
    saveAttempt(next.user.id, { key: attempt.key, orderId: result.orderId });
    if (result.checkoutUrl && result.status === "pending") window.location.assign(result.checkoutUrl);
    else { await refresh(); setMessage("The checkout request is recorded. Check the current order before attempting another payment."); }
  }

  async function download(id: string) {
    if (!config) return;
    const next = await currentSession();
    const blob = await downloadOrder(config, next.access_token, id);
    if (next.user.id !== identity.current) return;
    const href = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    anchor.href = href; anchor.download = "YouNew-Arrival-Planner.html"; anchor.rel = "noopener";
    document.body.append(anchor); anchor.click(); anchor.remove();
    window.setTimeout(() => URL.revokeObjectURL(href), 60000);
    setMessage("Download requested. Keep the HTML file and a JSON backup of your plan. Open the tool in a supported desktop browser.");
  }

  async function resetTerminalAttempt(id: string) {
    const next = await currentSession();
    if (!config) return;
    const latest = await readAccount(config, next.access_token);
    const order = latest.orders.find(o => o.id === id);
    if (identity.current !== next.user.id || !order || !["expired", "refunded"].includes(order.status) || latest.orders.some(o => ["creating", "pending", "paid"].includes(o.status))) throw new CommerceError(409);
    const previous = savedAttempt(next.user.id);
    if (previous.orderId && previous.orderId !== id) throw new CommerceError(409);
    saveAttempt(next.user.id, { key: crypto.randomUUID() });
    setOrders(latest.orders); setNotifications(latest.notifications); setProduct(latest.product);
    setMessage("The previous order is confirmed closed. A new checkout attempt is prepared; no payment has been made.");
  }

  const hasPurchase = orders.some(o => o.status === "paid" || o.downloadAvailable);
  const showAuthForm = !session || passwordRecovery;
  return <div className="space-y-4">
    <p><Link href="/arrival-planner/">← Arrival Planner</Link></p>
    <p className="section-label cyan">Arrival Planner preview</p><h1 className="text-4xl font-bold tracking-tight sm:text-5xl">Arrival Planner account</h1>
    {config ? <div className="business-truth-note" role="status"><div><strong>Sandbox · test payments only</strong><p>No real charge, purchase or refund is made here. Use only test payment details. Test orders and downloads do not establish a paid licence. Sales are not open yet.</p></div></div> : null}
    <p>This preview lets you check test orders, downloads and payment or refund notices. The proposed product has no subscription or automatic renewal.</p>
    {!config ? <div className="business-truth-note" role="status"><div><strong>The test account preview is closed. Sales are not open yet.</strong><p>No checkout, sign-up or recovery request can be sent from this preview. Existing free YouNew guidance remains available.</p></div></div> : !ready ? <p role="status">Checking your sign-in session…</p> : null}
    {returnState ? <p role="status">{returnState === "complete" ? "You returned from test checkout. This is not payment confirmation; check the test order below." : "Test checkout was closed. A browser cancellation does not establish the test payment status; refresh the order before trying again."}</p> : null}
    {error ? <p className="form-field-error" role="alert">{error}</p> : null}
    {message ? <p role="status" aria-live="polite">{message}</p> : null}
    {config && ready && showAuthForm ? <div className="pilot-scope-panel" style={{ maxWidth: 640, marginTop: 24 }}>
      <h2>{passwordRecovery ? "Choose a new password" : mode === "signup" ? "Create your account" : mode === "recover" ? "Recover your account" : "Sign in"}</h2>
      <form onSubmit={submitAuth}>
        {!passwordRecovery ? <div className="form-field"><label htmlFor="arrival-email">Email</label><input id="arrival-email" name="email" type="email" autoComplete="email" maxLength={254} required disabled={busy} /></div> : null}
        {mode !== "recover" || passwordRecovery ? <div className="form-field"><label htmlFor="arrival-password">{passwordRecovery ? "New password" : "Password"}</label><input id="arrival-password" name="password" type="password" autoComplete={mode === "login" && !passwordRecovery ? "current-password" : "new-password"} minLength={mode === "login" && !passwordRecovery ? 1 : 12} maxLength={128} required disabled={busy} />{mode !== "login" || passwordRecovery ? <p className="form-field-help">Use at least 12 characters. Additional account security requirements may apply.</p> : null}</div> : null}
        {passwordRecovery ? <div className="form-field"><label htmlFor="arrival-password-confirm">Confirm new password</label><input id="arrival-password-confirm" name="confirmation" type="password" autoComplete="new-password" minLength={12} maxLength={128} required disabled={busy} /></div> : null}
        <div className="hero-actions"><button className="button button-primary" disabled={busy} type="submit">{busy ? "Please wait…" : passwordRecovery ? "Update password" : mode === "signup" ? "Create account" : mode === "recover" ? "Request recovery email" : "Sign in"}</button></div>
      </form>
      {!passwordRecovery ? <div className="hero-actions">{(["login", "signup", "recover"] as const).filter(m => m !== mode).map(m => <button type="button" className="button button-outline" key={m} disabled={busy} onClick={() => { setMode(m); setError(""); setMessage(""); }}>{m === "login" ? "Sign in instead" : m === "signup" ? "Create an account" : "Forgot password?"}</button>)}</div> : null}
      {passwordRecovery && session ? <div className="hero-actions"><button type="button" className="button button-outline" disabled={busy} onClick={() => { rememberRecovery(null); setPasswordRecovery(false); setError(""); setMessage(""); }}>Back to purchases</button></div> : null}
      <p>Your account is used for purchases and recovery. It does not subscribe you to marketing updates. <Link href="/privacy/">Privacy information</Link>.</p>
    </div> : null}
    {config && ready && session && !passwordRecovery ? <>
      <p>Signed in as {session.user.email ?? "your account"}.</p>
      <div className="hero-actions"><button className="button button-outline" disabled={busy} onClick={() => void run(refresh)}>Refresh / restore purchases</button><button className="button button-outline" disabled={busy} onClick={() => { rememberRecovery(session.user.id); setPasswordRecovery(true); setError(""); setMessage(""); }}>Change password</button><button className="button button-outline" disabled={busy} onClick={() => void run(async () => { const result = await arrivalAuth(config).auth.signOut({ scope: "local" }); if (result.error) throw new CommerceError(503); rememberRecovery(null); setMessage("Signed out on this browser."); })}>Sign out</button></div>
      {checkedAt ? <p>Last confirmed account refresh: {date(checkedAt)}.</p> : <p role="status">Purchase status has not been confirmed yet.</p>}
      <section className="business-section space-y-4" style={{ paddingBlock: 32 }} aria-labelledby="arrival-orders"><h2 className="mb-5 text-2xl font-semibold" id="arrival-orders">Test orders and downloads</h2>
        {checkedAt && orders.length === 0 ? <p>No orders were returned for this account. A confirmation email or checkout redirect alone is not a paid order.</p> : null}
        {orders.map(order => <article className="pilot-scope-panel space-y-3" key={order.id} style={{ marginTop: 16 }}>
          <h3 className="text-xl font-semibold">Arrival Planner · Test amount {money(order.amountMinor, order.currency)}</h3><p>Status: <strong>{order.status}</strong> · Sandbox order</p><p style={{ overflowWrap: "anywhere" }}>Order {order.id}</p>
          {order.paidAt ? <p>Test payment recorded: {date(order.paidAt)}</p> : null}
          {order.downloadAvailable ? <button className="button button-primary" disabled={busy} onClick={() => void run(() => download(order.id))}>Download / restore test planner</button> : <p>{order.status === "refunded" ? "Test refund recorded. New downloads are unavailable. An already downloaded offline file cannot be removed remotely." : "Download is unavailable until the server confirms the required payment and access status."}</p>}
          {["expired", "refunded"].includes(order.status) && !orders.some(o => ["creating", "pending", "paid"].includes(o.status)) && config.checkoutEnabled ? <button className="button button-outline" disabled={busy} onClick={() => void run(() => resetTerminalAttempt(order.id))}>Prepare a new test after this closed order</button> : null}
        </article>)}
      </section>
      <section className="business-section space-y-4" style={{ paddingBlock: 32 }} aria-labelledby="arrival-buy"><h2 className="mb-5 text-2xl font-semibold" id="arrival-buy">{hasPurchase ? "Your sandbox access" : "Arrival Planner — test amount €14.99"}</h2><p>€14.99 is a test amount only. No real money is charged. The final sale price and tax treatment are not set. Personal use by one household, with no automatic renewal. Read the <Link href="/arrival-planner/">product scope and purchase details</Link> before continuing.</p>
        {!config.checkoutEnabled ? <p>New test checkouts are paused. Available existing test downloads can still be restored above.</p> : hasPurchase ? <p>A paid test order is already recorded for this account. You do not need another test checkout. If the download is temporarily unavailable, refresh its status or contact support.</p> : <><button className="button button-primary" disabled={busy || !product || !checkedAt} onClick={() => void run(checkout)}>Continue to test checkout · €14.99</button><p>Retrying uses the same saved attempt after a network error. Do not clear browser storage or switch accounts while a payment result is unknown.</p></>}
      </section>
      <section className="business-section space-y-4" style={{ paddingBlock: 32 }} aria-labelledby="arrival-notices"><h2 className="mb-5 text-2xl font-semibold" id="arrival-notices">Test purchase notifications</h2><p>These sandbox notices record test payment and refund changes. No real money moves.</p>{checkedAt && notifications.length === 0 ? <p>No purchase notifications yet.</p> : null}<ul className="space-y-4">{notifications.map(notice => <li key={notice.id}><strong>{notice.kind === "purchase_ready" ? "Test purchase ready for download" : "Test refund recorded"}</strong> — {date(notice.createdAt)}<p style={{ overflowWrap: "anywhere" }}>Order {notice.orderId}</p></li>)}</ul></section>
    </> : null}
    <section className="business-section space-y-4" style={{ paddingBlock: 32 }}><h2 className="mb-5 text-2xl font-semibold">Using the downloaded planner</h2><p>Open the HTML file in a supported modern desktop browser. Email previews and native iOS file viewers are not supported tool environments. Keep a JSON backup before moving browsers or clearing storage. Calendar imports depend on your calendar app; check the chosen dates and reminders after import.</p><p>Need help with payment, access or a refund? <a href="mailto:support@younew.nl">Contact support@younew.nl</a> with the order reference. Do not include your password, card details or identity documents. Refund handling follows the applicable purchase terms and consumer rights.</p></section>
  </div>;
}
