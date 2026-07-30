const securityHeaders = Object.freeze({
  "Content-Security-Policy":
    "default-src 'self'; base-uri 'self'; form-action 'self' mailto:; frame-ancestors 'none'; object-src 'none'; img-src 'self' data: https://commons.wikimedia.org https://live.staticflickr.com; font-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; connect-src 'self' https://pgdzdxsiagfjioxwuqxf.supabase.co; upgrade-insecure-requests",
  "Cross-Origin-Opener-Policy": "same-origin",
  "Permissions-Policy": "camera=(), microphone=(), geolocation=(), payment=()",
  "Referrer-Policy": "strict-origin-when-cross-origin",
  "Strict-Transport-Security": "max-age=31536000",
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY"
});

function withSecurityHeaders(response) {
  const headers = new Headers(response.headers);
  for (const [name, value] of Object.entries(securityHeaders)) {
    headers.set(name, value);
  }
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers
  });
}

function isBlockedDeploymentArtifact(pathname) {
  let decodedPathname;
  try {
    decodedPathname = decodeURIComponent(pathname);
  } catch {
    return true;
  }

  const segments = decodedPathname.split("/").filter(Boolean);
  return segments.some((segment, index) => {
    if (index === 0 && segment === ".well-known") return false;
    return segment.startsWith(".") || segment === "_headers";
  });
}

function htmlPayloadPath(pathname) {
  if (pathname === "/") return "/__site_payloads/index.html.payload";
  if (pathname.endsWith(".html")) {
    return `/__site_payloads${pathname}.payload`;
  }
  if (pathname.endsWith("/")) {
    return `/__site_payloads${pathname}index.html.payload`;
  }

  const finalSegment = pathname.split("/").at(-1) ?? "";
  if (!finalSegment.includes(".")) {
    return `/__site_payloads${pathname}/index.html.payload`;
  }
  return null;
}

async function fetchAssetWithDirectoryFallback(request, assets) {
  const response = await assets.fetch(request);
  if (
    response.status !== 404 ||
    (request.method !== "GET" && request.method !== "HEAD")
  ) {
    return response;
  }

  const url = new URL(request.url);
  const payloadPath = htmlPayloadPath(url.pathname);
  if (!payloadPath) return response;

  url.pathname = payloadPath;
  const payloadResponse = await assets.fetch(new Request(url, request));
  if (payloadResponse.status === 404) return response;

  const headers = new Headers(payloadResponse.headers);
  headers.set("Content-Type", "text/html; charset=utf-8");
  return new Response(payloadResponse.body, {
    status: payloadResponse.status,
    statusText: payloadResponse.statusText,
    headers
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (isBlockedDeploymentArtifact(url.pathname)) {
      return withSecurityHeaders(new Response(null, { status: 404 }));
    }

    const response = await fetchAssetWithDirectoryFallback(request, env.ASSETS);
    return withSecurityHeaders(response);
  }
};
