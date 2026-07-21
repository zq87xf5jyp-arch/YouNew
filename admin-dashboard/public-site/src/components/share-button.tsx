"use client";

import { useEffect, useRef, useState } from "react";
import { Check, Share2 } from "lucide-react";

export function ShareButton({ title, url }: { title: string; url?: string }) {
  const [status, setStatus] = useState<"idle" | "shared" | "copied" | "failed">("idle");
  const [interactive, setInteractive] = useState(false);
  const resetTimer = useRef<number | null>(null);

  useEffect(() => {
    setInteractive(true);
    return () => {
      if (resetTimer.current !== null) window.clearTimeout(resetTimer.current);
    };
  }, []);

  function resetLater() {
    if (resetTimer.current !== null) window.clearTimeout(resetTimer.current);
    resetTimer.current = window.setTimeout(() => setStatus("idle"), 2200);
  }

  async function share() {
    const target = url ?? window.location.href;
    setStatus("idle");
    try {
      if (navigator.share) {
        await navigator.share({ title, url: target });
        setStatus("shared");
      } else {
        await navigator.clipboard.writeText(target);
        setStatus("copied");
      }
      resetLater();
    } catch (error) {
      if ((error as DOMException).name !== "AbortError") {
        setStatus("failed");
        resetLater();
      }
    }
  }

  const feedback = status === "shared" ? "Shared" : status === "copied" ? "Link copied" : status === "failed" ? "Share failed" : "Share";

  return (
    <button className="share-button" type="button" disabled={!interactive} onClick={share}>
      {status === "copied" || status === "shared" ? <Check aria-hidden /> : <Share2 aria-hidden />}
      <span>Share</span>
      <span aria-live="polite">{status === "idle" ? "" : `— ${feedback}`}</span>
    </button>
  );
}
