(() => {
  const banner = document.querySelector(".status-banner");
  const liveRegion = document.querySelector("[data-status-banner-live]");

  const applyBanner = (config) => {
    if (!banner || !config || typeof config.enabled !== "boolean" || typeof config.id !== "string") return;
    let dismissed = false;
    try { dismissed = sessionStorage.getItem(`younew-banner:${config.id}`) === "dismissed"; } catch { /* storage is optional */ }
    banner.hidden = !config.enabled || dismissed;
    banner.classList.toggle("status-banner-warning", config.tone === "warning");
    const message = banner.querySelector(".status-banner-message");
    if (message && typeof config.message === "string") message.textContent = config.message;
    const action = banner.querySelector(".status-banner-link");
    if (action instanceof HTMLAnchorElement) {
      const href = typeof config.action?.href === "string" && config.action.href.startsWith("/") ? config.action.href : "/status/";
      action.href = href;
      action.textContent = typeof config.action?.label === "string" ? config.action.label : "View status";
      action.hidden = !config.action;
    }
    banner.dataset.bannerId = config.id;
    if (!banner.hidden && liveRegion && typeof config.message === "string") liveRegion.textContent = config.message;
  };

  if (banner) {
    const fallbackId = "ios-public-distribution-unconfirmed-2026-07";
    banner.dataset.bannerId = fallbackId;
    try { if (sessionStorage.getItem(`younew-banner:${fallbackId}`) === "dismissed") banner.hidden = true; } catch { /* storage is optional */ }
    const dismissButton = banner.querySelector(".status-banner-dismiss");
    if (dismissButton instanceof HTMLButtonElement) dismissButton.disabled = false;
    dismissButton?.addEventListener("click", () => {
      try { sessionStorage.setItem(`younew-banner:${banner.dataset.bannerId}`, "dismissed"); } catch { /* dismiss still works */ }
      banner.hidden = true;
      if (liveRegion) liveRegion.textContent = "Application availability update dismissed.";
    });
    fetch("/data/site-config.json", { cache: "no-store", headers: { Accept: "application/json" } })
      .then((response) => response.ok ? response.json() : Promise.reject(new Error("configuration unavailable")))
      .then((config) => applyBanner(config?.statusBanner))
      .catch(() => { /* the truthful server-rendered fallback remains visible */ });
  }

  const header = document.querySelector("[data-site-header]");
  if (header) {
    const normalisePath = (value) => value === "/" ? value : value.replace(/\/+$/, "");
    const currentPath = normalisePath(window.location.pathname);
    header.querySelectorAll("[data-nav-href]").forEach((link) => {
      const destination = normalisePath(new URL(link.href, window.location.href).pathname);
      const current = currentPath === destination || (destination !== "/" && currentPath.startsWith(`${destination}/`));
      if (current) link.setAttribute("aria-current", "page");
    });

    let scrollFrame = 0;
    const syncScrollState = () => {
      scrollFrame = 0;
      const scrolled = window.scrollY > 12;
      header.classList.toggle("is-scrolled", scrolled);
      header.toggleAttribute("data-scrolled", scrolled);
    };
    const scheduleScrollState = () => {
      if (!scrollFrame) scrollFrame = window.requestAnimationFrame(syncScrollState);
    };
    syncScrollState();
    window.addEventListener("scroll", scheduleScrollState, { passive: true });

    const menu = header.querySelector("[data-mobile-menu]");
    const summary = menu?.querySelector("summary");
    if (menu instanceof HTMLDetailsElement && summary instanceof HTMLElement) {
      const closeMenu = (restoreFocus = false) => {
        if (!menu.open) return;
        menu.open = false;
        if (restoreFocus) summary.focus();
      };
      menu.addEventListener("toggle", () => {
        if (menu.open) window.requestAnimationFrame(() => menu.querySelector("nav a[href]")?.focus());
      });
      menu.addEventListener("click", (event) => {
        if (event.target instanceof Element && event.target.closest("a[href]")) closeMenu();
      });
      menu.addEventListener("keydown", (event) => {
        if (!menu.open) return;
        if (event.key === "Escape") {
          event.preventDefault();
          closeMenu(true);
          return;
        }
        if (event.key !== "Tab") return;
        const items = [summary, ...menu.querySelectorAll("nav a[href]")];
        const first = items[0];
        const last = items[items.length - 1];
        if (event.shiftKey && document.activeElement === first) {
          event.preventDefault();
          last.focus();
        } else if (!event.shiftKey && document.activeElement === last) {
          event.preventDefault();
          first.focus();
        }
      });
      window.matchMedia("(min-width: 1001px)").addEventListener("change", (event) => {
        if (event.matches) closeMenu();
      });
    }
  }

  if ("IntersectionObserver" in window && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.remove("reveal-pending");
        entry.target.classList.add("is-revealed");
        observer.unobserve(entry.target);
      });
    }, { rootMargin: "0px 0px -8% 0px", threshold: .08 });
    document.querySelectorAll("[data-reveal]").forEach((element) => {
      if (element.getBoundingClientRect().top <= window.innerHeight * .92) element.classList.add("is-revealed");
      else {
        element.classList.add("reveal-pending");
        observer.observe(element);
      }
    });
  }

  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("/sw.js", { scope: "/", updateViaCache: "none" }).catch(() => { /* offline support is progressive */ });
  }
})();
