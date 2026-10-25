export const cityGuideSlugs = ["amsterdam", "rotterdam", "den-haag", "utrecht", "eindhoven"] as const;
export type CityGuideSlug = (typeof cityGuideSlugs)[number];

type LocalizedCopy = Readonly<{ en: string; nl: string }>;

export type CityGuide = Readonly<{
  slug: CityGuideSlug;
  cityEntityId: string;
  title: LocalizedCopy;
  description: LocalizedCopy;
  registration: LocalizedCopy;
  municipalityName: string;
  sourceTitle: string;
  sourceUrl: string;
  verifiedAt: "2026-10-23";
  preparation: readonly LocalizedCopy[];
  localSearches: readonly Readonly<{ label: LocalizedCopy; query: LocalizedCopy }>[];
}>;

export const cityGuides: readonly CityGuide[] = [
  {
    slug: "amsterdam",
    cityEntityId: "city.amsterdam",
    title: { en: "Starting your life in Amsterdam", nl: "Je eerste stappen in Amsterdam" },
    description: { en: "A source-checked route from municipal registration to everyday services in Amsterdam.", nl: "Een gecontroleerde route van inschrijving bij de gemeente naar praktische voorzieningen in Amsterdam." },
    registration: { en: "The City of Amsterdam says residents must keep their address registration in the Personal Records Database (BRP) correct. Use the official Civil Affairs page to choose the current service route.", nl: "De gemeente Amsterdam geeft aan dat inwoners hun adresregistratie in de Basisregistratie Personen (BRP) correct moeten houden. Kies via de officiële pagina Burgerzaken de actuele procedure." },
    municipalityName: "Gemeente Amsterdam",
    sourceTitle: "Correct registration with the City",
    sourceUrl: "https://www.amsterdam.nl/en/civil-affairs/correct-registration/",
    verifiedAt: "2026-10-23",
    preparation: [
      { en: "Open the Amsterdam Civil Affairs route immediately before you act.", nl: "Open de Amsterdamse route Burgerzaken vlak voordat je iets regelt." },
      { en: "Use the municipality's current document and appointment instructions, not a copied checklist.", nl: "Volg de actuele gemeentelijke instructies voor documenten en afspraken, niet een gekopieerde checklist." },
      { en: "Keep your BRP address details correct and report a change through the official route.", nl: "Houd je adresgegevens in de BRP correct en geef een wijziging via de officiële route door." }
    ],
    localSearches: [
      { label: { en: "Healthcare in Amsterdam", nl: "Zorg in Amsterdam" }, query: { en: "Amsterdam healthcare", nl: "Amsterdam zorg" } },
      { label: { en: "Transport in Amsterdam", nl: "Vervoer in Amsterdam" }, query: { en: "Amsterdam transport", nl: "Amsterdam vervoer" } },
      { label: { en: "Housing in Amsterdam", nl: "Wonen in Amsterdam" }, query: { en: "Amsterdam housing", nl: "Amsterdam wonen" } }
    ]
  },
  {
    slug: "rotterdam",
    cityEntityId: "city.rotterdam",
    title: { en: "Starting your life in Rotterdam", nl: "Je eerste stappen in Rotterdam" },
    description: { en: "A source-checked route from BRP registration to everyday services in Rotterdam.", nl: "Een gecontroleerde route van BRP-inschrijving naar praktische voorzieningen in Rotterdam." },
    registration: { en: "Rotterdam explains that personal details are recorded in the BRP and that people staying in the Netherlands for more than four months must register. Check the municipality page for the current route.", nl: "Rotterdam legt uit dat persoonsgegevens in de BRP staan en dat mensen die langer dan vier maanden in Nederland verblijven zich moeten inschrijven. Controleer de actuele procedure op de gemeentepagina." },
    municipalityName: "Gemeente Rotterdam",
    sourceTitle: "Basisregistratie personen",
    sourceUrl: "https://www.rotterdam.nl/basisregistratie-personen",
    verifiedAt: "2026-10-23",
    preparation: [
      { en: "Use Rotterdam's BRP page to choose the route for your length of stay.", nl: "Gebruik de Rotterdamse BRP-pagina om de route voor jouw verblijfsduur te kiezen." },
      { en: "Check the municipality's current document and appointment requirements before visiting.", nl: "Controleer vóór je bezoek de actuele eisen voor documenten en afspraken bij de gemeente." },
      { en: "Treat YouNew as orientation; the municipality page decides the current procedure.", nl: "Gebruik YouNew als wegwijzer; de gemeentepagina bepaalt de actuele procedure." }
    ],
    localSearches: [
      { label: { en: "Healthcare in Rotterdam", nl: "Zorg in Rotterdam" }, query: { en: "Rotterdam healthcare", nl: "Rotterdam zorg" } },
      { label: { en: "Transport in Rotterdam", nl: "Vervoer in Rotterdam" }, query: { en: "Rotterdam transport", nl: "Rotterdam vervoer" } },
      { label: { en: "Housing in Rotterdam", nl: "Wonen in Rotterdam" }, query: { en: "Rotterdam housing", nl: "Rotterdam wonen" } }
    ]
  },
  {
    slug: "den-haag",
    cityEntityId: "city.den-haag",
    title: { en: "Starting your life in The Hague", nl: "Je eerste stappen in Den Haag" },
    description: { en: "A source-checked route through moving, registration and newcomer services in The Hague.", nl: "Een gecontroleerde route langs verhuizen, inschrijven en voorzieningen voor nieuwkomers in Den Haag." },
    registration: { en: "The Hague groups its current routes for moving, BRP and RNI registration, foreign documents and newcomer support on its official moving and immigration page.", nl: "Den Haag bundelt de actuele routes voor verhuizen, BRP- en RNI-inschrijving, buitenlandse documenten en ondersteuning voor nieuwkomers op de officiële pagina Verhuizen en immigratie." },
    municipalityName: "Gemeente Den Haag",
    sourceTitle: "Moving and immigration",
    sourceUrl: "https://www.denhaag.nl/en/moving-and-immigration/",
    verifiedAt: "2026-10-23",
    preparation: [
      { en: "Start at The Hague's moving and immigration overview and select your exact situation.", nl: "Begin bij het Haagse overzicht Verhuizen en immigratie en kies jouw precieze situatie." },
      { en: "Check whether the official route points you to BRP, RNI or another service.", nl: "Controleer of de officiële route naar BRP, RNI of een andere dienst verwijst." },
      { en: "Use only the document instructions shown for that route.", nl: "Gebruik alleen de documentinstructies die bij die route staan." }
    ],
    localSearches: [
      { label: { en: "Healthcare in The Hague", nl: "Zorg in Den Haag" }, query: { en: "The Hague healthcare", nl: "Den Haag zorg" } },
      { label: { en: "Transport in The Hague", nl: "Vervoer in Den Haag" }, query: { en: "The Hague transport", nl: "Den Haag vervoer" } },
      { label: { en: "Housing in The Hague", nl: "Wonen in Den Haag" }, query: { en: "The Hague housing", nl: "Den Haag wonen" } }
    ]
  },
  {
    slug: "utrecht",
    cityEntityId: "city.utrecht",
    title: { en: "Starting your life in Utrecht", nl: "Je eerste stappen in Utrecht" },
    description: { en: "A source-checked route through BRP or RNI registration and everyday services in Utrecht.", nl: "Een gecontroleerde route langs BRP- of RNI-inschrijving en praktische voorzieningen in Utrecht." },
    registration: { en: "Utrecht distinguishes registration in the RNI for a shorter stay from BRP registration for a stay longer than four months. Use the official registration page to confirm which route applies.", nl: "Utrecht maakt onderscheid tussen RNI-inschrijving voor een korter verblijf en BRP-inschrijving voor een verblijf van langer dan vier maanden. Controleer via de officiële inschrijfpagina welke route geldt." },
    municipalityName: "Gemeente Utrecht",
    sourceTitle: "Registration",
    sourceUrl: "https://www.utrecht.nl/city-of-utrecht/registration",
    verifiedAt: "2026-10-23",
    preparation: [
      { en: "Use Utrecht's registration page to distinguish a shorter stay from a stay longer than four months.", nl: "Gebruik de Utrechtse inschrijfpagina om een korter verblijf te onderscheiden van een verblijf langer dan vier maanden." },
      { en: "Follow the current RNI or BRP route shown for your situation.", nl: "Volg de actuele RNI- of BRP-route die bij jouw situatie staat." },
      { en: "Recheck appointment and document instructions before you travel to the municipality.", nl: "Controleer de afspraak- en documentinstructies opnieuw voordat je naar de gemeente gaat." }
    ],
    localSearches: [
      { label: { en: "Healthcare in Utrecht", nl: "Zorg in Utrecht" }, query: { en: "Utrecht healthcare", nl: "Utrecht zorg" } },
      { label: { en: "Transport in Utrecht", nl: "Vervoer in Utrecht" }, query: { en: "Utrecht transport", nl: "Utrecht vervoer" } },
      { label: { en: "Housing in Utrecht", nl: "Wonen in Utrecht" }, query: { en: "Utrecht housing", nl: "Utrecht wonen" } }
    ]
  },
  {
    slug: "eindhoven",
    cityEntityId: "city.eindhoven",
    title: { en: "Starting your life in Eindhoven", nl: "Je eerste stappen in Eindhoven" },
    description: { en: "A source-checked route through moving and registration services in Eindhoven.", nl: "Een gecontroleerde route langs verhuis- en inschrijfvoorzieningen in Eindhoven." },
    registration: { en: "Eindhoven provides official routes for moves within the Netherlands and registration after arriving from abroad. Open the municipality page before starting because the route depends on the move.", nl: "Eindhoven biedt officiële routes voor verhuizingen binnen Nederland en inschrijving na aankomst uit het buitenland. Open eerst de gemeentepagina, omdat de procedure afhangt van je verhuissituatie." },
    municipalityName: "Gemeente Eindhoven",
    sourceTitle: "Moving house",
    sourceUrl: "https://english.eindhoven.nl/en/list-of-municipal-products/moving-house",
    verifiedAt: "2026-10-23",
    preparation: [
      { en: "Select the Eindhoven route that matches a move within the Netherlands or arrival from abroad.", nl: "Kies de Eindhovense route die past bij een verhuizing binnen Nederland of aankomst uit het buitenland." },
      { en: "Use the municipality's current document and appointment instructions for that route.", nl: "Gebruik de actuele gemeentelijke instructies voor documenten en afspraken bij die route." },
      { en: "Return to the official page if your moving situation changes.", nl: "Ga terug naar de officiële pagina als je verhuissituatie verandert." }
    ],
    localSearches: [
      { label: { en: "Healthcare in Eindhoven", nl: "Zorg in Eindhoven" }, query: { en: "Eindhoven healthcare", nl: "Eindhoven zorg" } },
      { label: { en: "Transport in Eindhoven", nl: "Vervoer in Eindhoven" }, query: { en: "Eindhoven transport", nl: "Eindhoven vervoer" } },
      { label: { en: "Housing in Eindhoven", nl: "Wonen in Eindhoven" }, query: { en: "Eindhoven housing", nl: "Eindhoven wonen" } }
    ]
  }
];

export function getCityGuide(slug: string) {
  return cityGuides.find((guide) => guide.slug === slug) ?? null;
}
