"use client";

import { useState } from "react";
import { AlertTriangle, Lightbulb, MessageSquarePlus, ThumbsDown, ThumbsUp } from "lucide-react";
import { PublicFeedbackForm } from "@/components/public-feedback-form";
import type { PublicFeedbackType } from "@/lib/feedback/submission";

const options = [
  { id: "helpful", label: "Helpful", icon: ThumbsUp, type: "suggestion", message: "This guide was helpful for completing my task." },
  { id: "not-helpful", label: "Not helpful", icon: ThumbsDown, type: "suggestion", message: "This guide did not help me complete my task because: " },
  { id: "outdated", label: "Report outdated", icon: AlertTriangle, type: "incorrect-information", message: "This guide may contain outdated information. The part to review is: " },
  { id: "missing", label: "Missing information", icon: MessageSquarePlus, type: "suggestion", message: "This guide is missing information about: " },
  { id: "suggestion", label: "Suggest improvement", icon: Lightbulb, type: "suggestion", message: "My suggested improvement for this guide is: " }
] as const satisfies readonly { id: string; label: string; icon: typeof ThumbsUp; type: PublicFeedbackType; message: string }[];

export function GuideFeedbackLoop({ pageReference, title = "Did this guide help you take the next step?" }: { pageReference: string; title?: string }) {
  const [selected, setSelected] = useState<(typeof options)[number] | null>(null);

  return (
    <section className="guide-feedback-loop" aria-labelledby="guide-feedback-loop-title">
      <p className="section-label">Feedback loop</p>
      <h2 id="guide-feedback-loop-title">{title}</h2>
      <p>Your report goes to editorial review and never changes published guidance automatically.</p>
      <div className="guide-feedback-options" role="group" aria-label="Choose feedback type">
        {options.map((option) => {
          const Icon = option.icon;
          return <button className={selected?.id === option.id ? "is-selected" : ""} type="button" aria-pressed={selected?.id === option.id} onClick={() => setSelected(option)} key={option.id}><Icon aria-hidden />{option.label}</button>;
        })}
      </div>
      {selected ? (
        <div className="guide-feedback-form-wrap">
          <PublicFeedbackForm
            compact
            defaultPageReference={pageReference}
            initialFeedbackType={selected.type}
            initialMessage={selected.message}
            key={selected.id}
          />
        </div>
      ) : null}
    </section>
  );
}
