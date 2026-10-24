import { createClient } from "@supabase/supabase-js";
import { createSyncHandler, type SyncClient } from "./handler.ts";

Deno.serve(async (request) => {
  const url = Deno.env.get("SUPABASE_URL"), anon = Deno.env.get("SUPABASE_ANON_KEY"), service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !anon || !service) return Response.json({ error: "service_unavailable" }, { status: 503, headers: { "Cache-Control": "no-store" } });
  const client = (key: string, signal: AbortSignal, authorization?: string) => createClient(url, key, {
    auth: { autoRefreshToken: false, persistSession: false },
    global: {
      ...(authorization ? { headers: { Authorization: authorization } } : {}),
      fetch: (input, init) => fetch(input, { ...init, signal: AbortSignal.any([signal, AbortSignal.timeout(5000), ...(init?.signal ? [init.signal] : [])]) }),
    },
  }) as unknown as SyncClient;
  return createSyncHandler({ userClient: (authorization, signal) => client(anon, signal, authorization), serviceClient: (signal) => client(service, signal) })(request);
});
