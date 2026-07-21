"use client";

import { useEffect, useRef, useState } from "react";
import { Copy } from "lucide-react";

export function CopyTextButton({ value, label = "Copy" }: { value: string; label?: string }) {
  const [status, setStatus] = useState<"idle" | "copied" | "failed">("idle");
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

  async function copy() {
    setStatus("idle");
    try {
      await navigator.clipboard.writeText(value);
      setStatus("copied");
    } catch {
      setStatus("failed");
    }
    resetLater();
  }

  const feedback = status === "copied" ? "Copied" : status === "failed" ? "Copy failed" : label;

  return (
    <button className="guide-copy-button" type="button" disabled={!interactive} onClick={copy}>
      <Copy aria-hidden /> <span>{label}</span>
      <span aria-live="polite">{status === "idle" ? "" : `— ${feedback}`}</span>
    </button>
  );
}
