import type { ReactNode } from "react";
import { PageShell } from "@/components/page-shell";

export function ContentPage({ title, description, children }: { title: string; description: string; children: ReactNode }) {
  return <PageShell className="content-page"><section className="section-shell content-hero"><h1>{title}</h1><p>{description}</p></section><article className="section-shell content-body">{children}</article></PageShell>;
}
