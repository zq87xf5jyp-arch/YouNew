"use client";

import type { AnchorHTMLAttributes, ReactNode } from "react";
import { track } from "@/lib/analytics/client";

type TrackedAppStoreLinkProps = Omit<
  AnchorHTMLAttributes<HTMLAnchorElement>,
  "href" | "onClick"
> & {
  href: string;
  location: string;
  children: ReactNode;
};

export function TrackedAppStoreLink({
  href,
  location,
  children,
  ...props
}: TrackedAppStoreLinkProps) {
  return (
    <a
      {...props}
      href={href}
      data-analytics-app-store-location={location}
      onClick={() => track({ name: "app_cta_click", location })}
    >
      {children}
    </a>
  );
}
