import editorialRoutes from "../../generated/editorial-routes.json" with {type:"json"};
/** Carry only the public add/claim intent; never copy contact or search fields. */
export function businessLanguageHref(href: string, pathname: string, action: string | null): string {
  const isApplication = /^\/(?:for-business\/local\/apply|nl\/voor-bedrijven\/aanmelden)\/?$/.test(pathname);
  return isApplication && (action === "add" || action === "claim") ? `${href}?action=${action}` : href;
}

export function localizedCounterpart(path: string): { en: string; nl: string } | null {
  const normalized = path === "/" ? "/" : `/${path.replace(/^\/+|\/+$/g, "")}`;
  const editorial=editorialRoutes.find(pair=>pair.en===normalized || pair.nl===normalized);
  if(editorial)return editorial;
  const pairs: Array<[RegExp, (match: RegExpMatchArray) => string, (match: RegExpMatchArray) => string]> = [
    [/^\/$/, () => "/", () => "/nl"],
    [/^\/nl$/, () => "/", () => "/nl"],
    [/^\/(?:nl\/)?leiden$/, () => "/leiden", () => "/nl/leiden"],
    [/^\/categories(?:\/(.+))?$/, (match) => `/categories${match[1] ? `/${match[1]}` : ""}`, (match) => `/nl/categorieen${match[1] ? `/${match[1]}` : ""}`],
    [/^\/organizations(?:\/(.+))?$/, (match) => `/organizations${match[1] ? `/${match[1]}` : ""}`, (match) => `/nl/organisaties${match[1] ? `/${match[1]}` : ""}`],
    [/^\/search$/, () => "/search", () => "/nl/zoeken"],
    [/^\/for-business$/, () => "/for-business", () => "/nl/voor-bedrijven"],
    [/^\/for-business\/local$/, () => "/for-business/local", () => "/nl/voor-bedrijven/lokaal"],
    [/^\/for-business\/local\/apply$/, () => "/for-business/local/apply", () => "/nl/voor-bedrijven/aanmelden"],
    [/^\/city-guides\/(.+)$/, (match) => `/city-guides/${match[1]}`, (match) => `/nl/stadsgidsen/${match[1]}`],
    [/^\/nl\/categorieen(?:\/(.+))?$/, (match) => `/categories${match[1] ? `/${match[1]}` : ""}`, (match) => `/nl/categorieen${match[1] ? `/${match[1]}` : ""}`],
    [/^\/nl\/organisaties(?:\/(.+))?$/, (match) => `/organizations${match[1] ? `/${match[1]}` : ""}`, (match) => `/nl/organisaties${match[1] ? `/${match[1]}` : ""}`],
    [/^\/nl\/zoeken$/, () => "/search", () => "/nl/zoeken"],
    [/^\/nl\/voor-bedrijven$/, () => "/for-business", () => "/nl/voor-bedrijven"],
    [/^\/nl\/voor-bedrijven\/lokaal$/, () => "/for-business/local", () => "/nl/voor-bedrijven/lokaal"],
    [/^\/nl\/voor-bedrijven\/aanmelden$/, () => "/for-business/local/apply", () => "/nl/voor-bedrijven/aanmelden"],
    [/^\/nl\/stadsgidsen\/(.+)$/, (match) => `/city-guides/${match[1]}`, (match) => `/nl/stadsgidsen/${match[1]}`]
  ];
  for (const [pattern, english, dutch] of pairs) {
    const match = normalized.match(pattern);
    if (match) return { en: english(match), nl: dutch(match) };
  }
  return null;
}
