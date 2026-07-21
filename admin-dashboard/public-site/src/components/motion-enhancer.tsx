"use client";

import { useEffect } from "react";

export function MotionEnhancer() {
  useEffect(() => {
    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
    if (reducedMotion.matches || !("IntersectionObserver" in window)) return;

    const elements = Array.from(document.querySelectorAll<HTMLElement>("[data-reveal]"));
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          const element = entry.target as HTMLElement;
          element.classList.remove("reveal-pending");
          element.classList.add("is-revealed");
          observer.unobserve(element);
        });
      },
      { rootMargin: "0px 0px -8% 0px", threshold: 0.08 }
    );

    elements.forEach((element) => {
      if (element.getBoundingClientRect().top <= window.innerHeight * 0.92) {
        element.classList.add("is-revealed");
        return;
      }
      element.classList.add("reveal-pending");
      observer.observe(element);
    });

    return () => observer.disconnect();
  }, []);

  return null;
}
