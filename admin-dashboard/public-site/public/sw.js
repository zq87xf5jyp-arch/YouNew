const CACHE_VERSION = "younew-web-ce14191a5cab";
const SHELL_CACHE = `${CACHE_VERSION}-shell`;
const GUIDE_CACHE = `${CACHE_VERSION}-guides`;
const ASSET_CACHE = `${CACHE_VERSION}-assets`;
const OFFLINE_URL = "/offline/";
const SHELL_URLS = ["/", OFFLINE_URL, "/guides/", "/journeys/", "/manifest.webmanifest", "/static-shell.js", "/icons/apple-touch-icon.png", "/icons/icon-192.png", "/icons/icon-512.png"];

const isEmergencyRequest = (url) => url.pathname === "/emergency" || url.pathname.startsWith("/emergency/");
const isMutableConfiguration = (url) =>
  url.pathname === "/data/status.json" || url.pathname === "/data/site-config.json";
const isGuidePage = (url) => url.pathname === "/guides" || url.pathname.startsWith("/guides/");

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(SHELL_CACHE).then(async (cache) => {
      await Promise.all(SHELL_URLS.map((url) => cache.add(url)));
    })
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter((key) => key.startsWith("younew-web-") && ![SHELL_CACHE, GUIDE_CACHE, ASSET_CACHE].includes(key))
            .map((key) => caches.delete(key))
        )
      )
      .then(() => self.clients.claim())
  );
});

self.addEventListener("message", (event) => {
  if (event.data?.type === "SKIP_WAITING") self.skipWaiting();
});

const networkFirstNavigation = async (request, url) => {
  try {
    const response = await fetch(request);
    if (response.ok && isGuidePage(url)) {
      const cache = await caches.open(GUIDE_CACHE);
      await cache.put(request, response.clone());
    }
    return response;
  } catch {
    if (isGuidePage(url)) {
      const cachedGuide = await caches.match(request);
      if (cachedGuide) return cachedGuide;
    }
    return (await caches.match(OFFLINE_URL)) || Response.error();
  }
};

const staleWhileRevalidateAsset = async (request) => {
  const cache = await caches.open(ASSET_CACHE);
  const cached = await cache.match(request);
  const network = fetch(request)
    .then((response) => {
      if (response.ok) void cache.put(request, response.clone());
      return response;
    })
    .catch(() => undefined);
  return cached || (await network) || Response.error();
};

self.addEventListener("fetch", (event) => {
  const { request } = event;
  if (request.method !== "GET") return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin || isMutableConfiguration(url)) return;

  if (isEmergencyRequest(url)) {
    event.respondWith(fetch(request).catch(() => caches.match(OFFLINE_URL).then((response) => response || Response.error())));
    return;
  }

  if (request.mode === "navigate") {
    event.respondWith(networkFirstNavigation(request, url));
    return;
  }

  if (["style", "script", "image", "font"].includes(request.destination)) {
    event.respondWith(staleWhileRevalidateAsset(request));
  }
});
