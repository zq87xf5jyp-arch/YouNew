import { createReadStream } from "node:fs";
import { stat } from "node:fs/promises";
import { createServer } from "node:http";
import { extname, join, normalize } from "node:path";
import { createGzip } from "node:zlib";

const root = new URL("../out/", import.meta.url).pathname;
const port = Number(process.env.PORT ?? 4173);
const host = process.env.HOST ?? "127.0.0.1";
const types = { ".html": "text/html; charset=utf-8", ".js": "text/javascript; charset=utf-8", ".css": "text/css; charset=utf-8", ".json": "application/json; charset=utf-8", ".webmanifest": "application/manifest+json", ".xml": "application/xml; charset=utf-8", ".txt": "text/plain; charset=utf-8", ".pdf": "application/pdf", ".mp4": "video/mp4", ".png": "image/png", ".jpg": "image/jpeg", ".webp": "image/webp", ".svg": "image/svg+xml" };

function safePath(requestPath) {
  const decoded = decodeURIComponent(requestPath.split("?")[0]);
  const relative = normalize(decoded).replace(/^[/\\]+/, "");
  if (relative.includes("..")) return null;
  return join(root, relative);
}

createServer(async (request, response) => {
  const base = safePath(request.url ?? "/");
  if (!base) { response.writeHead(400).end("Bad request"); return; }
  const candidates = [base, join(base, "index.html"), base.endsWith("/") ? null : `${base}.html`].filter(Boolean);
  let file;
  for (const candidate of candidates) {
    try { if ((await stat(candidate)).isFile()) { file = candidate; break; } } catch { /* continue */ }
  }
  if (!file) { file = join(root, "404.html"); response.statusCode = 404; }
  const contentType = types[extname(file)] ?? "application/octet-stream";
  const fileSize = (await stat(file)).size;
  response.setHeader("Content-Type", contentType);
  response.setHeader("X-Content-Type-Options", "nosniff");
  const requestPath = request.url?.split("?")[0] ?? "/";
  if (requestPath === "/acquisition" || requestPath.startsWith("/acquisition/")) {
    response.setHeader("X-Robots-Tag", "noindex, nofollow, noarchive, nosnippet");
  }
  if (["/sw.js", "/data/status.json", "/data/site-config.json"].includes(requestPath)) {
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  } else if (requestPath.startsWith("/_next/static/")) {
    response.setHeader("Cache-Control", "public, max-age=31536000, immutable");
  } else if (/\.(?:png|webp|avif)$/.test(requestPath)) {
    response.setHeader("Cache-Control", "public, max-age=86400, must-revalidate");
  }

  if (contentType === "video/mp4" || contentType === "application/pdf") {
    response.setHeader("Accept-Ranges", "bytes");
    const range = request.headers.range;
    if (range) {
      const match = /^bytes=(\d*)-(\d*)$/.exec(range);
      let start;
      let end;
      if (match && (match[1] || match[2])) {
        if (!match[1]) {
          const suffixLength = Number(match[2]);
          if (Number.isSafeInteger(suffixLength) && suffixLength > 0) {
            start = Math.max(fileSize - suffixLength, 0);
            end = fileSize - 1;
          }
        } else {
          start = Number(match[1]);
          end = match[2] ? Number(match[2]) : fileSize - 1;
          if (Number.isSafeInteger(end)) end = Math.min(end, fileSize - 1);
        }
      }

      if (!Number.isSafeInteger(start) || !Number.isSafeInteger(end) || start < 0 || start > end || start >= fileSize) {
        response.statusCode = 416;
        response.setHeader("Content-Range", `bytes */${fileSize}`);
        response.setHeader("Content-Length", "0");
        response.end();
        return;
      }

      response.statusCode = 206;
      response.setHeader("Content-Range", `bytes ${start}-${end}/${fileSize}`);
      response.setHeader("Content-Length", String(end - start + 1));
      if (request.method === "HEAD") {
        response.end();
        return;
      }
      createReadStream(file, { start, end }).pipe(response);
      return;
    }
  }

  const compressible = /^(?:text\/|application\/(?:javascript|json|ld\+json|xml))/.test(contentType);
  if (compressible && request.headers["accept-encoding"]?.includes("gzip")) {
    response.setHeader("Content-Encoding", "gzip");
    response.setHeader("Vary", "Accept-Encoding");
    createReadStream(file).pipe(createGzip()).pipe(response);
    return;
  }
  response.setHeader("Content-Length", String(fileSize));
  if (request.method === "HEAD") {
    response.end();
    return;
  }
  createReadStream(file).pipe(response);
}).listen(port, host, () => console.log(`YouNew static preview: http://${host}:${port}`));
