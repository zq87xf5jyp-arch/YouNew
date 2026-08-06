(() => {
  const themeStorageKey = "younew.theme.v1";
  const themeButton = document.querySelector(".theme-toggle");

  const currentTheme = () => document.documentElement.dataset.theme === "light"
    ? "light"
    : "dark";

  const syncThemeControl = () => {
    if (!(themeButton instanceof HTMLButtonElement)) return;
    const theme = currentTheme();
    const nextTheme = theme === "light" ? "dark" : "light";
    themeButton.setAttribute("aria-label", `Switch to ${nextTheme} mode`);
    themeButton.setAttribute("aria-pressed", String(theme === "light"));
    themeButton.title = `Switch to ${nextTheme} mode`;
    const state = themeButton.querySelector(".visually-hidden");
    if (state) state.textContent = `${theme} mode active`;
  };

  const applyTheme = (theme) => {
    const normalizedTheme = theme === "light" ? "light" : "dark";
    document.documentElement.dataset.theme = normalizedTheme;
    document.documentElement.style.colorScheme = normalizedTheme;
    document.querySelector('meta[name="theme-color"]')?.setAttribute(
      "content",
      normalizedTheme === "dark" ? "#050c1b" : "#eef3f8"
    );
    syncThemeControl();
  };

  syncThemeControl();
  themeButton?.addEventListener("click", () => {
    const nextTheme = currentTheme() === "dark" ? "light" : "dark";
    applyTheme(nextTheme);
    try { localStorage.setItem(themeStorageKey, nextTheme); } catch { /* preference remains active for this page */ }
  });

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
        }
      });
      window.matchMedia("(min-width: 1281px)").addEventListener("change", (event) => {
        if (event.matches) closeMenu();
      });
    }
  }

  const analyticsConsentKey = "younew.analytics-consent.2026-07-28";
  const analyticsAppInstanceKey = "younew.analytics-app-instance";
  const analyticsSessionKey = "younew.analytics-session";
  const analyticsEndpointPath = "/functions/v1/analytics-ingest";
  let analyticsProvider;

  const safeAnalyticsProperty = (value) => String(value)
    .replace(/[^A-Za-z0-9_./: -]/g, "-")
    .slice(0, 160);

  const analyticsEnvironment = (hostname) => {
    const normalized = hostname.trim().toLowerCase();
    return normalized === "localhost"
      || normalized === "127.0.0.1"
      || normalized === "::1"
      || normalized.endsWith(".localhost")
      ? "staging"
      : "production";
  };

  const readAnalyticsConsent = () => {
    try {
      const value = localStorage.getItem(analyticsConsentKey);
      return value === "accepted" || value === "declined" ? value : null;
    } catch {
      return null;
    }
  };

  const saveAnalyticsConsent = (choice) => {
    try { localStorage.setItem(analyticsConsentKey, choice); } catch { /* current-page choice still applies */ }
  };

  const browserPrivacySignalEnabled = () => (
    navigator.globalPrivacyControl === true
    || navigator.doNotTrack === "1"
    || window.doNotTrack === "1"
  );

  const randomUUIDv4 = () => {
    const source = globalThis.crypto;
    if (typeof source?.randomUUID === "function") return source.randomUUID();
    if (typeof source?.getRandomValues !== "function") {
      throw new Error("Secure random values are unavailable.");
    }

    const bytes = source.getRandomValues(new Uint8Array(16));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    const hexadecimal = Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0"));
    return [
      hexadecimal.slice(0, 4).join(""),
      hexadecimal.slice(4, 6).join(""),
      hexadecimal.slice(6, 8).join(""),
      hexadecimal.slice(8, 10).join(""),
      hexadecimal.slice(10, 16).join("")
    ].join("-");
  };

  const sessionIdentifier = (key) => {
    try {
      const existing = sessionStorage.getItem(key);
      if (existing) return existing;
      const created = randomUUIDv4();
      sessionStorage.setItem(key, created);
      return created;
    } catch {
      return randomUUIDv4();
    }
  };

  const clearAnalyticsSession = () => {
    try {
      sessionStorage.removeItem(analyticsAppInstanceKey);
      sessionStorage.removeItem(analyticsSessionKey);
    } catch { /* no identifier exists when storage is blocked */ }
  };

  const validAnalyticsConfiguration = (configuration) => {
    try {
      const endpoint = new URL(configuration?.endpoint);
      return configuration?.enabled === true
        && endpoint.protocol === "https:"
        && endpoint.hostname.endsWith(".supabase.co")
        && endpoint.pathname === analyticsEndpointPath
        && configuration.publishableKey?.startsWith("sb_publishable_")
        && configuration.consentVersion?.length > 0
        && configuration.schemaVersion === 1;
    } catch {
      return false;
    }
  };

  const createHomepageAnalytics = (configuration) => {
    if (!validAnalyticsConfiguration(configuration)) return undefined;
    const appInstanceId = sessionIdentifier(analyticsAppInstanceKey);
    const sessionId = sessionIdentifier(analyticsSessionKey);
    let queue = [];
    let timer;
    let disposed = false;
    let inFlight;

    const flush = async () => {
      if (disposed || queue.length === 0) return;
      if (inFlight) {
        await inFlight;
        if (queue.length > 0) await flush();
        return;
      }
      if (timer !== undefined) {
        clearTimeout(timer);
        timer = undefined;
      }
      const events = queue.splice(0, 20);
      inFlight = fetch(configuration.endpoint, {
        method: "POST",
        headers: {
          Accept: "application/json",
          apikey: configuration.publishableKey,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ events }),
        credentials: "omit",
        keepalive: true,
        referrerPolicy: "no-referrer"
      }).catch(() => undefined).finally(() => {
        inFlight = undefined;
      });
      await inFlight;
    };

    return {
      track(eventName, properties = {}) {
        if (disposed) return;
        queue.push({
          client_event_id: randomUUIDv4(),
          app_instance_id: appInstanceId,
          session_id: sessionId,
          event_name: eventName,
          screen: location.pathname.slice(0, 160) || "/",
          platform: "Web",
          app_version: configuration.appVersion,
          language: (document.documentElement.lang || "en").slice(0, 12),
          properties: eventName === "official_source_click"
            ? { content_id: safeAnalyticsProperty(properties.content_id ?? "") }
            : {},
          occurred_at: new Date().toISOString(),
          consent_version: configuration.consentVersion,
          schema_version: configuration.schemaVersion,
          environment: analyticsEnvironment(location.hostname)
        });
        if (queue.length >= 20) void flush();
        else if (timer === undefined) timer = setTimeout(() => {
          timer = undefined;
          void flush();
        }, 1_000);
      },
      flush,
      dispose() {
        if (timer !== undefined) clearTimeout(timer);
        timer = undefined;
        disposed = true;
        queue = [];
      }
    };
  };

  const analyticsConfiguration = fetch("/data/site-config.json", {
    cache: "no-store",
    credentials: "same-origin",
    headers: { Accept: "application/json" }
  }).then((response) => response.ok ? response.json() : undefined)
    .then((config) => config?.analytics)
    .catch(() => undefined);

  const startHomepageAnalytics = async (includeConsentEvent = false) => {
    const configuration = await analyticsConfiguration;
    analyticsProvider?.dispose();
    analyticsProvider = createHomepageAnalytics(configuration);
    if (!analyticsProvider) return;
    window.__YOUNEW_ANALYTICS__ = analyticsProvider;
    if (includeConsentEvent) analyticsProvider.track("analytics_consent_granted");
    analyticsProvider.track("page_view");
  };

  const createConsentButton = (label, className, action) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = className;
    button.textContent = label;
    button.addEventListener("click", action);
    return button;
  };

  let previouslyFocused;
  let declineButton;
  const openConsent = () => {
    previouslyFocused = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    consentTrigger.hidden = true;
    consentDialog.hidden = false;
    requestAnimationFrame(() => declineButton?.focus());
  };
  const closeConsent = () => {
    consentDialog.hidden = true;
    consentTrigger.hidden = false;
    requestAnimationFrame(() => (consentTrigger ?? previouslyFocused)?.focus());
  };
  const consentTrigger = createConsentButton("Privacy choices", "analytics-settings-trigger", openConsent);
  consentTrigger.setAttribute("aria-label", "Open analytics privacy choices");
  consentTrigger.textContent = "";
  const consentTriggerIcon = document.createElement("span");
  consentTriggerIcon.setAttribute("aria-hidden", "true");
  consentTriggerIcon.textContent = "✓";
  consentTrigger.append(consentTriggerIcon);

  const consentDialog = document.createElement("section");
  consentDialog.className = "analytics-consent";
  consentDialog.role = "dialog";
  consentDialog.setAttribute("aria-modal", "true");
  consentDialog.setAttribute("aria-labelledby", "analytics-consent-title");

  const consentCopy = document.createElement("div");
  const consentEyebrow = document.createElement("p");
  consentEyebrow.className = "analytics-consent-eyebrow";
  consentEyebrow.textContent = "Your privacy choice";
  const consentTitle = document.createElement("h2");
  consentTitle.id = "analytics-consent-title";
  consentTitle.tabIndex = -1;
  consentTitle.textContent = "Help improve YouNew?";
  const consentDescription = document.createElement("p");
  consentDescription.textContent = "With your permission, YouNew counts page visits and bounded product actions. We do not send search text, profile details, precise location, advertising IDs or cross-site identifiers. The identifier lasts only for this browser tab.";
  const consentPolicy = document.createElement("p");
  consentPolicy.append("Data is stored in the EU for up to 90 days. You can change this choice at any time. Read the ");
  const consentPolicyLink = document.createElement("a");
  consentPolicyLink.href = "/privacy/";
  consentPolicyLink.textContent = "Privacy Policy";
  consentPolicy.append(consentPolicyLink, ".");
  consentCopy.append(consentEyebrow, consentTitle, consentDescription, consentPolicy);

  const consentActions = document.createElement("div");
  consentActions.className = "analytics-consent-actions";
  const declineAnalytics = () => {
    analyticsProvider?.dispose();
    analyticsProvider = undefined;
    delete window.__YOUNEW_ANALYTICS__;
    saveAnalyticsConsent("declined");
    clearAnalyticsSession();
    closeConsent();
  };
  const acceptAnalytics = () => {
    saveAnalyticsConsent("accepted");
    closeConsent();
    void startHomepageAnalytics(true);
  };
  declineButton = createConsentButton("Decline analytics", "button-secondary", declineAnalytics);
  const allowButton = createConsentButton("Allow anonymous analytics", "button-primary", acceptAnalytics);
  consentActions.append(
    declineButton,
    allowButton
  );
  consentDialog.append(consentCopy, consentActions);
  consentDialog.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      event.preventDefault();
      closeConsent();
      return;
    }
    if (event.key !== "Tab") return;
    const items = [...consentDialog.querySelectorAll('a[href],button:not([disabled])')];
    const first = items[0];
    const last = items[items.length - 1];
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last?.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first?.focus();
    }
  });
  document.body.append(consentTrigger, consentDialog);

  const storedAnalyticsChoice = readAnalyticsConsent();
  if (storedAnalyticsChoice === "accepted") {
    consentDialog.hidden = true;
    void startHomepageAnalytics();
  } else if (storedAnalyticsChoice === "declined" || browserPrivacySignalEnabled()) {
    consentDialog.hidden = true;
  } else {
    consentTrigger.hidden = true;
    requestAnimationFrame(() => declineButton.focus());
  }

  window.addEventListener("pagehide", () => {
    void analyticsProvider?.flush();
  });

  document.addEventListener("click", (event) => {
    const target = event.target instanceof Element
      ? event.target.closest("[data-analytics-official-source-id]")
      : null;
    const contentId = target?.getAttribute("data-analytics-official-source-id");
    if (contentId) {
      analyticsProvider?.track("official_source_click", { content_id: contentId });
    }
  });

  const homeProfileButtons = [...document.querySelectorAll("[data-home-profile]")];
  const homeProfileResult = document.querySelector("[data-home-profile-result]");
  const homeProfileCopy = document.querySelector("[data-home-profile-copy]");
  const homeProfileTitle = document.querySelector("[data-home-profile-title]");
  const homeProfileLinks = document.querySelector("[data-home-profile-links]");
  const homeProfileClear = document.querySelector("[data-home-profile-clear]");
  const homeProfileEmpty = document.querySelector("[data-home-profile-empty]");
  const homeMunicipality = document.querySelector("[data-home-municipality]");
  const homeProfileStorageKey = "younew.web.profile.v1";
  const homeProfiles = {
    tourist: {
      label: "Tourist",
      plannerProfile: "tourist",
      tasks: [["Plan transport", "transport"], ["Know consumer rights", "consumer-legal"], ["Prepare urgent help", "urgent-help"]]
    },
    student: {
      label: "Student",
      plannerProfile: "student",
      tasks: [["Start studying", "study"], ["Find housing", "housing"], ["Find health support", "health-wellbeing"]]
    },
    expat: {
      label: "Expat",
      plannerProfile: "expat",
      tasks: [["Start registration", "registration"], ["Arrange utilities", "utilities-moving"], ["Start work", "work"]]
    },
    refugee: {
      label: "Refugee",
      plannerProfile: "refugee",
      tasks: [["Check registration", "registration"], ["Find rights support", "consumer-legal"], ["Open urgent help", "urgent-help"]]
    },
    worker: {
      label: "Worker",
      plannerProfile: "worker",
      tasks: [["Start work", "work"], ["Check taxes & benefits", "taxes-benefits"], ["Start a business", "business"]]
    },
    resident: {
      label: "Resident",
      plannerProfile: "resident",
      tasks: [["Arrange healthcare", "health-insurance"], ["Manage utilities", "utilities-moving"], ["Review housing", "housing"]]
    }
  };

  const readHomeProfile = () => {
    try {
      const stored = JSON.parse(localStorage.getItem(homeProfileStorageKey));
      return stored?.version === 1 && Object.hasOwn(homeProfiles, stored.value) ? stored.value : null;
    } catch {
      return null;
    }
  };
  const writeHomeProfile = (profile) => {
    try {
      if (profile) localStorage.setItem(homeProfileStorageKey, JSON.stringify({ version: 1, value: profile }));
      else localStorage.removeItem(homeProfileStorageKey);
    } catch { /* current-page preference still works */ }
  };
  const renderHomeProfile = (profile) => {
    homeProfileButtons.forEach((button) => {
      const selected = button.getAttribute("data-home-profile") === profile;
      button.classList.toggle("is-selected", selected);
      button.setAttribute("aria-pressed", String(selected));
    });
    if (!homeProfileResult) return;
    const current = profile ? homeProfiles[profile] : undefined;
    if (!current) {
      if (homeProfileCopy) homeProfileCopy.hidden = true;
      if (homeProfileLinks) homeProfileLinks.hidden = true;
      if (homeProfileClear) homeProfileClear.hidden = true;
      if (homeProfileEmpty) homeProfileEmpty.hidden = false;
      return;
    }
    if (homeProfileCopy) homeProfileCopy.hidden = false;
    if (homeProfileTitle) homeProfileTitle.textContent = `Starting points for ${current.label.toLowerCase()}s`;
    if (homeProfileClear) homeProfileClear.hidden = false;
    if (homeProfileEmpty) homeProfileEmpty.hidden = true;
    if (homeProfileLinks) {
      homeProfileLinks.hidden = false;
      homeProfileLinks.replaceChildren();
      const area = homeMunicipality?.value || "national";
      const areaName = homeMunicipality?.selectedOptions[0]?.textContent || "National guidance";
      homeProfileLinks.setAttribute("aria-label", `${current.label} suggestions for ${areaName}`);
      current.tasks.forEach(([label, task]) => {
        const params = new URLSearchParams({ task, profile: current.plannerProfile, area });
        const link = document.createElement("a");
        link.href = `/start/?${params.toString()}`;
        link.textContent = `${label} →`;
        homeProfileLinks.append(link);
      });
    }
  };

  homeProfileClear?.addEventListener("click", () => {
    writeHomeProfile(null);
    renderHomeProfile(null);
    homeProfileButtons[0]?.focus();
  });
  homeMunicipality?.addEventListener("change", () => renderHomeProfile(readHomeProfile()));

  homeProfileButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const profile = button.getAttribute("data-home-profile");
      if (!profile || !Object.hasOwn(homeProfiles, profile)) return;
      writeHomeProfile(profile);
      renderHomeProfile(profile);
      analyticsProvider?.track("profile_selected");
    });
  });
  renderHomeProfile(readHomeProfile());

})();
