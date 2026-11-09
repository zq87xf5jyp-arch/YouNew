"use client";



import { useRef, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { Search } from "lucide-react";
import { localContentRepository } from "@/lib/storage/local-content";

export function HomeSearchForm({ locale = "en" }: { locale?: "en" | "nl" }) {
  const nl = locale === "nl";
  const route = nl ? "/nl/zoeken/" : "/search/";
  const router = useRouter();
  const input = useRef<HTMLInputElement>(null);

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    localContentRepository.handoffSearch(input.current?.value ?? "");
    router.push(route);
  }

  return (
    <form action={route} method="get" onSubmit={submit} data-private-search-form="true">
      <label htmlFor="home-search">{nl ? "Zoek een stad, dienst of onderwerp" : "Search a city, service or topic"}</label>
      <div>
        {/* No name: an unhydrated/native GET must never send the search phrase. */}
        <input id="home-search" ref={input} placeholder={nl ? "Bijvoorbeeld: Amsterdam, huisarts of BSN" : "Try Amsterdam, healthcare or BSN"} type="search" enterKeyHint="search" autoComplete="off" />
        <button aria-label={nl ? "Zoeken op YouNew" : "Search YouNew"} type="submit"><Search aria-hidden /><span>{nl ? "Zoeken" : "Search"}</span></button>
      </div>
      <noscript>{nl ? "Open de zoekpagina en schakel JavaScript in om privé te zoeken. Je tekst wordt niet in de link verstuurd." : "Open the search page with this button, then enable JavaScript to search privately. Your text will not be sent in the link."}</noscript>
    </form>
  );
}
