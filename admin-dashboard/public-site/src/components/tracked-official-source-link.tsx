"use client";

import type { AnchorHTMLAttributes, ReactNode } from "react";
import { track } from "@/lib/analytics/client";

type TrackedOfficialSourceLinkProps = Omit<
  AnchorHTMLAttributes<HTMLAnchorElement>,
  "href" | "onClick"
> & {
  href: string;
  contentId: string;
  guideAction?: boolean;
  actionPanelCity?: string;
  children: ReactNode;
};

export function TrackedOfficialSourceLink({
  contentId,
  guideAction = false,
  actionPanelCity,
  children,
  ...props
}: TrackedOfficialSourceLinkProps) {
  return (
    <a
      {...props}
      data-analytics-official-source-id={contentId}
      onClick={() => {
        track({ name: "official_source_click", contentId });
        if (guideAction) track({ name: "guide_official_action", contentId });
        if (actionPanelCity) track({ name: "action_panel_cta_clicked", contentId, city: actionPanelCity });
      }}
    >
      {children}
    </a>
  );
}
