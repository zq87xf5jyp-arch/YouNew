"use client";

import { useState } from "react";
import { Trash2 } from "lucide-react";
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

  return (
    <section className="local-data-controls" aria-labelledby="local-data-title">
      <div>
        <h2 id="local-data-title">Local web data</h2>
        <p>Saved items, recent pages, journey progress, optional search history and your selected profile stay in this browser. They are not synced to an account.</p>
      </div>
      <button className="button button-outline" type="button" onClick={clearData}><Trash2 aria-hidden /> Clear local web data</button>
      {result ? <p className="local-data-cleared" role={result.failed ? "alert" : "status"}>{result.message}</p> : null}
    </section>
  );
}
