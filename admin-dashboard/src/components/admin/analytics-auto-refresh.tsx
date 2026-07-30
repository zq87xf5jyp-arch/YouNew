"use client";

import { useEffect, useState, useTransition } from "react";
import { RefreshCw } from "lucide-react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";

const refreshIntervalSeconds = 60;

export function AnalyticsAutoRefresh() {
  const router = useRouter();
  const [secondsRemaining, setSecondsRemaining] = useState(refreshIntervalSeconds);
  const [isPending, startTransition] = useTransition();

  useEffect(() => {
    const timer = window.setInterval(() => {
      if (document.visibilityState !== "visible") return;
      setSecondsRemaining((current) => {
        if (current > 1) return current - 1;
        startTransition(() => router.refresh());
        return refreshIntervalSeconds;
      });
    }, 1_000);
    return () => window.clearInterval(timer);
  }, [router]);

  const refresh = () => {
    setSecondsRemaining(refreshIntervalSeconds);
    startTransition(() => router.refresh());
  };

  return (
    <div className="flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
      <span aria-live="polite">
        {isPending ? "Обновление…" : `Автообновление через ${secondsRemaining} с`}
      </span>
      <Button type="button" variant="outline" size="sm" onClick={refresh} disabled={isPending}>
        <RefreshCw className={`mr-2 size-3.5 ${isPending ? "animate-spin" : ""}`} />
        Обновить
      </Button>
    </div>
  );
}
