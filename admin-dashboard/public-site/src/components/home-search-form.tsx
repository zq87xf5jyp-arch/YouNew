"use client";

import { useRef, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { Search } from "lucide-react";
import { localContentRepository } from "@/lib/storage/local-content";

export function HomeSearchForm() {
  const router = useRouter();
  const input = useRef<HTMLInputElement>(null);

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    localContentRepository.handoffSearch(input.current?.value ?? "");
    router.push("/search/");
  }

  return (
    <form action="/search/" method="get" onSubmit={submit} data-private-search-form="true">
      <label htmlFor="home-search">What do you need in the Netherlands?</label>
      <div>
        {/* No name: an unhydrated/native GET must never send the search phrase. */}
        <input id="home-search" ref={input} placeholder="For example: I need housing in Leiden" type="search" autoComplete="off" />
        <button aria-label="Search YouNew" type="submit"><Search aria-hidden /></button>
      </div>
      <noscript>Open the search page with this button, then enable JavaScript to search privately. Your text will not be sent in the link.</noscript>
    </form>
  );
}
