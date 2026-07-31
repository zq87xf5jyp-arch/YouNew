"use client";

import type { AnchorHTMLAttributes, ReactNode } from "react";
import { track } from "@/lib/analytics/client";

type TrackedOfficialSourceLinkProps = Omit<
  AnchorHTMLAttributes<HTMLAnchorElement>,
  "href" | "onClick"
> & {
  href: string;
  contentId: string;
  children: ReactNode;
};

export function TrackedOfficialSourceLink({
  contentId,
  children,
  ...props
}: TrackedOfficialSourceLinkProps) {
  return (
    <a
      {...props}
      data-analytics-official-source-id={contentId}
      onClick={() => track({ name: "official_source_click", contentId })}
    >
      {children}
    </a>
  );
}
