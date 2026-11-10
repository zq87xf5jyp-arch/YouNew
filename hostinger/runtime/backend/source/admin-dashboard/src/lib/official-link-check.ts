import { lookup } from "node:dns/promises";
import { request } from "node:https";
import { BlockList, isIP } from "node:net";
import type { OfficialLinkCheck } from "@/lib/official-link-workflow";

const blocked = new BlockList();
for (const [address, prefix] of [
  ["0.0.0.0", 8], ["10.0.0.0", 8], ["100.64.0.0", 10], ["127.0.0.0", 8],
  ["169.254.0.0", 16], ["172.16.0.0", 12], ["192.0.0.0", 24], ["192.0.2.0", 24],
  ["192.88.99.0", 24], ["192.168.0.0", 16], ["198.18.0.0", 15], ["198.51.100.0", 24],
  ["203.0.113.0", 24], ["224.0.0.0", 4], ["240.0.0.0", 4]
] as const) blocked.addSubnet(address, prefix, "ipv4");
for (const [address, prefix] of [["2001::", 23], ["2001:db8::", 32], ["2002::", 16], ["3fff::", 20]] as const) {
  blocked.addSubnet(address, prefix, "ipv6");
}
const globalIPv6 = new BlockList();
globalIPv6.addSubnet("2000::", 3, "ipv6");

export function isPublicLinkAddress(address: string) {
  const family = isIP(address);
  if (family === 4) return !blocked.check(address, "ipv4");
  // This also rejects mapped IPv4, ULA, loopback, link-local and translation ranges.
  return family === 6 && globalIPv6.check(address, "ipv6") && !blocked.check(address, "ipv6");
}

function publicURL(input: string) {
  if (input.length > 2048) throw new Error("unsafe_url");
  const url = new URL(input);
  const host = url.hostname.replace(/^\[|\]$/g, "");
  if (url.protocol !== "https:" || (url.port && url.port !== "443") || url.username || url.password
    || (!isIP(host) && (!host.includes(".") || /(?:^|\.)(?:localhost|local|internal|home)$/i.test(host)))) {
    throw new Error("unsafe_url");
  }
  if (isIP(host) && !isPublicLinkAddress(host)) throw new Error("blocked_address");
  url.hash = "";
  return url;
}

function evidenceURL(url: URL) {
  const safe = new URL(url);
  safe.search = ""; // Do not persist anonymous redirect/session query values.
  safe.hash = "";
  return safe.href;
}

async function resolvePublic(url: URL, signal: AbortSignal) {
  const host = url.hostname.replace(/^\[|\]$/g, "");
  if (signal.aborted) throw new Error("timeout");
  const family = isIP(host);
  const addresses = family ? [{ address: host, family }] : await new Promise<Array<{ address: string; family: number }>>((resolve, reject) => {
    const abort = () => reject(new Error("timeout"));
    signal.addEventListener("abort", abort, { once: true });
    lookup(host, { all: true, verbatim: true }).then(resolve, reject).finally(() => signal.removeEventListener("abort", abort));
  });
  if (signal.aborted) throw new Error("timeout");
  if (!addresses.length || addresses.some(({ address }) => !isPublicLinkAddress(address))) throw new Error("blocked_address");
  return addresses[0];
}

async function requestHeaders(url: URL, method: "HEAD" | "GET", signal: AbortSignal) {
  const pinned = await resolvePublic(url, signal);
  const hostname = url.hostname.replace(/^\[|\]$/g, "");
  return new Promise<{ status: number; location?: string }>((resolve, reject) => {
    const req = request(url, {
      method, signal, agent: false, family: pinned.family,
      rejectUnauthorized: true,
      servername: isIP(hostname) ? undefined : hostname,
      maxHeaderSize: 16384,
      headers: { "User-Agent": "YouNew-Admin-LinkCheck/1.0", Accept: "*/*" },
      // Bind this connection to the validated IP: no second DNS resolution.
      lookup: (_hostname, _options, callback) => callback(null, pinned.address, pinned.family)
    }, (response) => {
      const result = { status: response.statusCode ?? 0, location: response.headers.location };
      response.destroy(); // Header observation only; never download an arbitrary body.
      resolve(result);
    });
    req.on("error", reject);
    req.end();
  });
}

export async function checkStoredOfficialLink(input: string): Promise<OfficialLinkCheck> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 8000);
  let attempts = 0;
  let httpStatus: number | null = null;
  let finalURL: string | null = null;
  const finish = (outcome: OfficialLinkCheck["outcome"], errorCode: string | null = null): OfficialLinkCheck => ({
    outcome, httpStatus, finalURL, checkedAt: new Date().toISOString(), attempts, errorCode
  });
  try {
    let url = publicURL(input);
    let method: "HEAD" | "GET" = "HEAD";
    let redirects = 0;
    while (attempts < 4) {
      attempts += 1;
      const response = await requestHeaders(url, method, controller.signal);
      httpStatus = response.status;
      finalURL = evidenceURL(url);
      if (response.status >= 300 && response.status < 400) {
        if (!response.location || redirects >= 3) return finish("unknown", "redirect_limit_or_missing_location");
        redirects += 1;
        url = publicURL(new URL(response.location, url).href);
        continue;
      }
      if (method === "HEAD" && ((response.status >= 400 && response.status < 500) || response.status === 501)) {
        method = "GET";
        continue;
      }
      if (response.status >= 200 && response.status < 300) return finish("reachable");
      if (method === "GET" && [404, 410].includes(response.status)) return finish("broken");
      return finish("unknown", "inconclusive_http_status");
    }
    return finish("unknown", "request_limit");
  } catch (error) {
    const reason = error instanceof Error ? error.message : "";
    return finish("unknown", controller.signal.aborted ? "timeout"
      : ["unsafe_url", "blocked_address"].includes(reason) ? reason : "network_or_tls_error");
  } finally {
    clearTimeout(timer);
  }
}
