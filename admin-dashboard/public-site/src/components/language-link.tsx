"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { stageSearchLanguageHandoff } from "@/lib/search/language-handoff";
import { localizedCounterpart } from "@/lib/i18n/routes";

export function LanguageLink({ locale, expanded = false }: { locale: "en" | "nl"; expanded?: boolean }) {
  const pathname = usePathname();
  const target = locale === "nl" ? "en" : "nl";
  const pair = localizedCounterpart(pathname);
  const path = pair?.[target] ?? (target === "nl" ? "/nl" : "/");
  const href = path === "/" ? path : `${path}/`;
  return <Link prefetch={false} onClick={(event) => { if (!event.metaKey && !event.ctrlKey && !event.shiftKey && !event.altKey && /^\/(search|nl\/zoeken)\/?$/.test(pathname)) stageSearchLanguageHandoff(); }} href={href} hrefLang={target} lang={target} aria-label={target === "nl" ? "Lees in het Nederlands" : "Read in English"}>
    {expanded ? (target === "nl" ? "Nederlands" : "English") : target.toUpperCase()}
  </Link>;
}
