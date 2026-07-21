"use client";

import { useEffect, useState } from "react";
import { Printer } from "lucide-react";

export function PrintButton() {
  const [interactive, setInteractive] = useState(false);
  useEffect(() => setInteractive(true), []);

  return (
    <button className="button button-outline print-button" type="button" disabled={!interactive} onClick={() => window.print()}>
      <Printer aria-hidden /> Print guide
    </button>
  );
}
