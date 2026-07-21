"use client";

import { useEffect } from "react";

export function ServiceWorkerRegister() {
  useEffect(() => {
    if (!("serviceWorker" in navigator)) return;

    let disposed = false;
    let registration: ServiceWorkerRegistration | undefined;

    const announceWaitingWorker = (nextRegistration: ServiceWorkerRegistration) => {
      if (!nextRegistration.waiting || disposed) return;
      window.dispatchEvent(
        new CustomEvent("younew:service-worker-update-available", {
          detail: { registration: nextRegistration }
        })
      );
    };

    navigator.serviceWorker
      .register("/sw.js", { scope: "/", updateViaCache: "none" })
      .then((nextRegistration) => {
        if (disposed) return;
        registration = nextRegistration;
        announceWaitingWorker(nextRegistration);

        nextRegistration.addEventListener("updatefound", () => {
          const installingWorker = nextRegistration.installing;
          if (!installingWorker) return;
          installingWorker.addEventListener("statechange", () => {
            if (installingWorker.state === "installed" && navigator.serviceWorker.controller) {
              announceWaitingWorker(nextRegistration);
            }
          });
        });
      })
      .catch(() => {
        // The site remains fully usable without service-worker support.
      });

    const checkForUpdates = () => {
      if (document.visibilityState === "visible") void registration?.update();
    };
    document.addEventListener("visibilitychange", checkForUpdates);

    return () => {
      disposed = true;
      document.removeEventListener("visibilitychange", checkForUpdates);
    };
  }, []);

  return null;
}
