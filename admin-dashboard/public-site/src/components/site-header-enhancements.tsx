"use client";

import { useEffect } from "react";
import { usePathname } from "next/navigation";

const DESKTOP_MEDIA_QUERY = "(min-width: 1001px)";

function normalisePathname(pathname: string) {
  if (pathname === "/") return pathname;
  return pathname.replace(/\/+$/, "");
}

function isCurrentDestination(pathname: string, href: string) {
  const currentPath = normalisePathname(pathname);
  const destination = normalisePathname(href);
  return currentPath === destination || (destination !== "/" && currentPath.startsWith(`${destination}/`));
}

export function SiteHeaderEnhancements() {
  const pathname = usePathname();

  useEffect(() => {
    const header = document.querySelector<HTMLElement>("[data-site-header]");
    if (!header) return;

    const navigationLinks = header.querySelectorAll<HTMLAnchorElement>("[data-nav-href]");
    navigationLinks.forEach((link) => {
      const href = link.getAttribute("href");
      if (href && isCurrentDestination(pathname, href)) link.setAttribute("aria-current", "page");
      else link.removeAttribute("aria-current");
    });

    const mobileMenu = header.querySelector<HTMLDetailsElement>("[data-mobile-menu]");
    const menuSummary = mobileMenu?.querySelector<HTMLElement>("summary");
    const desktopMediaQuery = window.matchMedia(DESKTOP_MEDIA_QUERY);
    let scrollFrame = 0;

    const syncScrollState = () => {
      scrollFrame = 0;
      const isScrolled = window.scrollY > 12;
      header.classList.toggle("is-scrolled", isScrolled);
      header.toggleAttribute("data-scrolled", isScrolled);
    };

    const scheduleScrollState = () => {
      if (scrollFrame) return;
      scrollFrame = window.requestAnimationFrame(syncScrollState);
    };

    const closeMenu = (restoreFocus = false) => {
      if (!mobileMenu?.open) return;
      mobileMenu.open = false;
      if (restoreFocus) menuSummary?.focus();
    };

    const focusableMenuItems = () => {
      if (!mobileMenu || !menuSummary) return [];
      return [menuSummary, ...mobileMenu.querySelectorAll<HTMLAnchorElement>("nav a[href]")];
    };

    const handleMenuToggle = () => {
      if (!mobileMenu || !menuSummary) return;
      if (mobileMenu.open) {
        window.requestAnimationFrame(() => mobileMenu.querySelector<HTMLAnchorElement>("nav a[href]")?.focus());
      }
    };

    const handleMenuKeyDown = (event: KeyboardEvent) => {
      if (!mobileMenu?.open) return;
      if (event.key === "Escape") {
        event.preventDefault();
        closeMenu(true);
        return;
      }
      if (event.key !== "Tab") return;

      const focusableItems = focusableMenuItems();
      if (focusableItems.length === 0) return;
      const firstItem = focusableItems[0];
      const lastItem = focusableItems[focusableItems.length - 1];
      if (event.shiftKey && document.activeElement === firstItem) {
        event.preventDefault();
        lastItem.focus();
      } else if (!event.shiftKey && document.activeElement === lastItem) {
        event.preventDefault();
        firstItem.focus();
      }
    };

    const handleMenuClick = (event: MouseEvent) => {
      if ((event.target as Element).closest("a[href]")) closeMenu();
    };

    const handleViewportChange = (event: MediaQueryListEvent) => {
      if (event.matches) closeMenu();
    };

    syncScrollState();
    mobileMenu?.addEventListener("toggle", handleMenuToggle);
    mobileMenu?.addEventListener("keydown", handleMenuKeyDown);
    mobileMenu?.addEventListener("click", handleMenuClick);
    desktopMediaQuery.addEventListener("change", handleViewportChange);
    window.addEventListener("scroll", scheduleScrollState, { passive: true });

    return () => {
      if (scrollFrame) window.cancelAnimationFrame(scrollFrame);
      mobileMenu?.removeEventListener("toggle", handleMenuToggle);
      mobileMenu?.removeEventListener("keydown", handleMenuKeyDown);
      mobileMenu?.removeEventListener("click", handleMenuClick);
      desktopMediaQuery.removeEventListener("change", handleViewportChange);
      window.removeEventListener("scroll", scheduleScrollState);
    };
  }, [pathname]);

  return null;
}
