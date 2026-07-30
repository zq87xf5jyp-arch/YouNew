"use client";

import { useState } from "react";
import { Download, Trash2 } from "lucide-react";
import { localContentRepository } from "@/lib/storage/local-content";

export function LocalDataControls() {
  const [result, setResult] = useState<{ message: string; failed: boolean } | null>(null);

  function clearData() {
    if (!window.confirm("Clear saved items, recently viewed pages, journey progress, search history and your selected profile from this browser?")) return;
    setResult(null);
    localContentRepository.clearAll();
    try {
      const remainingKeys = Object.values(localContentRepository.keys).filter((key) => window.localStorage.getItem(key) !== null);
      if (remainingKeys.length > 0) {
        setResult({ message: "Some local YouNew web data could not be cleared. Check your browser storage settings and try again.", failed: true });
        return;
      }
      setResult({ message: "Local YouNew web data was cleared from this browser.", failed: false });
    } catch {
      setResult({ message: "YouNew could not confirm that local web data was cleared. Check your browser storage settings and try again.", failed: true });
    }
  }

  function exportData() {
    setResult(null);
    try {
      const snapshot = localContentRepository.snapshot();
      const blob = new Blob([`${JSON.stringify(snapshot, null, 2)}\n`], { type: "application/json" });
      const url = URL.createObjectURL(blob);
      const anchor = document.createElement("a");
      anchor.href = url;
      anchor.download = `younew-local-data-${snapshot.exportedAt.slice(0, 10)}.json`;
      anchor.click();
      URL.revokeObjectURL(url);
      setResult({ message: "A copy of your local YouNew data was prepared for download.", failed: false });
    } catch {
      setResult({ message: "YouNew could not prepare the local data download in this browser.", failed: true });
    }
  }

  return (
    <section className="local-data-controls" aria-labelledby="local-data-title">
      <div>
        <h2 id="local-data-title">Local web data</h2>
        <p>Saved items, recent pages, journey progress, optional search history and your selected profile stay in this browser. They are not synced to an account.</p>
      </div>
      <div className="local-data-actions">
        <button className="button button-outline" type="button" onClick={exportData}><Download aria-hidden /> Export local data</button>
        <button className="button button-outline" type="button" onClick={clearData}><Trash2 aria-hidden /> Clear local web data</button>
      </div>
      {result ? <p className="local-data-cleared" role={result.failed ? "alert" : "status"}>{result.message}</p> : null}
    </section>
  );
}
