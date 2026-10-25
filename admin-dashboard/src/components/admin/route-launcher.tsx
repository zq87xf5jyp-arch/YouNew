"use client";

import { useMemo, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { canAccessPath, type AdminRole } from "@/lib/authorization";

const destinations = [
  ["/dashboard", "Панель"],
  ["/analytics", "Аналитика"],
  ["/finance", "Финансы"],
  ["/sync", "Синхронизация"],
  ["/trust", "Trust & Review"],
  ["/content", "Контент"],
  ["/business-inquiries", "Бизнес-заявки"],
  ["/categories", "Категории"],
  ["/cities", "Города"],
  ["/map", "Карта"],
  ["/visual-qa", "Проверка UI"],
  ["/bugs", "Ошибки"],
  ["/releases", "Релизы"],
  ["/links", "Ссылки"],
  ["/ai-knowledge", "Знания AI"],
  ["/feedback", "Отзывы"],
  ["/settings", "Настройки"],
  ["/audit-log", "Журнал"]
] as const;

function normalize(value: string) {
  return value.trim().toLocaleLowerCase("ru-RU");
}

export function RouteLauncher({ role }: { role: AdminRole }) {
  const router = useRouter();
  const [query, setQuery] = useState("");
  const available = useMemo(
    () => destinations.filter(([href]) => canAccessPath(role, href)),
    [role]
  );

  function launch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const search = normalize(query);
    if (!search) return;
    const destination = available.find(([href, label]) => (
      normalize(href) === search
      || normalize(label) === search
      || normalize(label).includes(search)
    ));
    if (destination) {
      setQuery("");
      router.push(destination[0]);
    }
  }

  return (
    <form className="relative min-w-0 max-w-xl flex-1" onSubmit={launch} role="search">
      <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
      <Input
        aria-label="Открыть раздел админки"
        className="pl-9"
        list="admin-route-destinations"
        onChange={(event) => setQuery(event.target.value)}
        placeholder="Открыть раздел…"
        value={query}
      />
      <datalist id="admin-route-destinations">
        {available.map(([href, label]) => <option key={href} value={label}>{href}</option>)}
      </datalist>
    </form>
  );
}
