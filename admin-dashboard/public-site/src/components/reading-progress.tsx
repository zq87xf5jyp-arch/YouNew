"use client";

import { useEffect, useRef } from "react";

type ReadingProgressProps = {
  targetId: string;
  label?: string;
};

/**
 * Progressive enhancement for long-form pages. The indicator is hidden in the
 * server-rendered document, so a browser without JavaScript never sees a stale
 * percentage. Runtime updates write directly to the transform and ARIA value to
 * avoid a React render on every scroll event.
 */
export function ReadingProgress({ targetId, label = "Guide reading progress" }: ReadingProgressProps) {
  const rootRef = useRef<HTMLDivElement>(null);
  const barRef = useRef<HTMLSpanElement>(null);
  const valueRef = useRef<HTMLSpanElement>(null);

  useEffect(() => {
    const root = rootRef.current;
    const bar = barRef.current;
    const value = valueRef.current;
    const target = document.getElementById(targetId);

    if (!root || !bar || !value || !target) return;

    const progressRoot = root;
    const progressBar = bar;
    const progressValue = value;
    const progressTarget = target;

    progressRoot.hidden = false;
    let frame = 0;
    let previousValue = -1;

    function update() {
      frame = 0;
      const bounds = progressTarget.getBoundingClientRect();
      const readableDistance = Math.max(bounds.height - window.innerHeight, 1);
      const ratio = Math.min(1, Math.max(0, -bounds.top / readableDistance));
      const percent = Math.round(ratio * 100);

      progressBar.style.transform = `scaleX(${ratio})`;
      if (percent !== previousValue) {
        progressRoot.setAttribute("aria-valuenow", String(percent));
        progressRoot.setAttribute("aria-valuetext", `${percent}% read`);
        progressValue.textContent = `${percent}%`;
        previousValue = percent;
      }
    }

    function scheduleUpdate() {
      if (!frame) frame = window.requestAnimationFrame(update);
    }

    update();
    window.addEventListener("scroll", scheduleUpdate, { passive: true });
    window.addEventListener("resize", scheduleUpdate, { passive: true });
    const resizeObserver = typeof ResizeObserver === "undefined" ? null : new ResizeObserver(scheduleUpdate);
    resizeObserver?.observe(progressTarget);

    return () => {
      window.removeEventListener("scroll", scheduleUpdate);
      window.removeEventListener("resize", scheduleUpdate);
      resizeObserver?.disconnect();
      if (frame) window.cancelAnimationFrame(frame);
    };
  }, [targetId]);

  return (
    <div
      className="guide-reading-progress"
      hidden
      ref={rootRef}
      role="progressbar"
      aria-label={label}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-valuenow={0}
      aria-valuetext="0% read"
    >
      <span className="guide-reading-progress-track" aria-hidden="true">
        <span className="guide-reading-progress-value" ref={barRef} />
      </span>
      <span className="guide-reading-progress-label" ref={valueRef} aria-hidden="true">0%</span>
    </div>
  );
}
