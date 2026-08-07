import lifeDomainTaxonomy from "../../data/life-domain-taxonomy.json" with { type: "json" };

export type SearchLanguage = "en" | "nl" | "ru";

export type LifeDomain = {
  slug: string;
  title: string;
  summary: string;
  aliases: Record<SearchLanguage, string[]>;
  intents: Array<{ id: string; terms: string[] }>;
  profiles: string[];
  startHere: string[];
  officialSources: Array<{ name: string; url: string }>;
};

export const lifeDomains = lifeDomainTaxonomy as LifeDomain[];

export function getLifeDomain(slug: string): LifeDomain | undefined {
  return lifeDomains.find((domain) => domain.slug === slug);
}

export interface SearchTaxonomyTopic {
  readonly id: string;
  readonly title: string;
  readonly aliases: Readonly<Record<SearchLanguage, readonly string[]>>;
  readonly relatedIntents: readonly string[];
}

export interface SearchIntentMatch {
  readonly intent: string;
  readonly alias: string;
  readonly exact: boolean;
  readonly specificity: number;
}

// One governed vocabulary is shared by indexing, ranking, Admin validation and QA.
// Aliases are deliberately factual search language only; they do not introduce
// prices, eligibility rules or services that are absent from published content.
export const SEARCH_TAXONOMY: readonly SearchTaxonomyTopic[] = [
  {
    id: "housing",
    title: "Housing",
    aliases: {
      en: ["housing", "rent", "rental", "renting", "home", "apartment", "room", "house", "accommodation", "social housing", "private rental", "temporary housing", "tenant rights", "rental contract", "deposit", "housing scam", "rent benefit"],
      nl: ["huur", "huren", "woning", "woonruimte", "appartement", "kamer", "sociale huur", "particuliere huur", "huurcontract", "borg", "huurtoeslag", "huurrecht"],
      ru: ["жилье", "жильё", "аренда", "снять жилье", "снять жильё", "квартира", "комната", "дом", "договор аренды", "депозит", "права арендатора", "пособие на жилье", "пособие на жильё", "zhile", "arenda"]
    },
    relatedIntents: ["benefits", "government", "legal-help", "utilities"]
  },
  {
    id: "work",
    title: "Work",
    aliases: {
      en: ["work", "job", "jobs", "employment", "vacancy", "vacancies", "career", "contract", "salary", "work contract", "employment contract", "employer", "minimum wage", "payslip", "holiday allowance", "sick leave", "dismissal", "uwv"],
      nl: ["werk", "baan", "banen", "vacature", "vacatures", "arbeid", "salaris", "arbeidscontract", "werkgever", "minimumloon", "loonstrook", "vakantiegeld", "ziekteverlof", "ontslag"],
      ru: ["работа", "вакансия", "вакансии", "зарплата", "трудовой договор", "работодатель", "минимальная зарплата", "больничный", "увольнение", "rabota", "vakansiya"]
    },
    relatedIntents: ["taxes", "legal-help", "business"]
  },
  {
    id: "documents",
    title: "Documents",
    aliases: {
      en: ["documents", "document", "bsn", "digid", "residence permit", "residence card", "registration", "municipality registration", "address registration", "change address", "brp", "citizen service number"],
      nl: ["documenten", "document", "burgerservicenummer", "verblijfsvergunning", "verblijfsdocument", "inschrijving", "gemeente inschrijving", "adresregistratie", "verhuizing", "basisregistratie personen"],
      ru: ["документы", "документ", "регистрация", "вид на жительство", "внж", "регистрация адреса", "муниципалитет", "номер bsn", "dokumenty", "registratsiya"]
    },
    relatedIntents: ["government", "integration", "legal-help"]
  },
  {
    id: "healthcare",
    title: "Healthcare",
    aliases: {
      en: ["healthcare", "health", "doctor", "gp", "general practitioner", "hospital", "specialist", "dentist", "pharmacy", "health insurance", "mental health", "emergency care"],
      nl: ["zorg", "gezondheid", "huisarts", "huisartsenpost", "ziekenhuis", "specialist", "tandarts", "apotheek", "zorgverzekering", "geestelijke gezondheidszorg", "spoedzorg"],
      ru: ["здоровье", "врач", "терапевт", "больница", "специалист", "стоматолог", "аптека", "медицинская страховка", "страховка", "психологическая помощь", "vrach"]
    },
    relatedIntents: ["insurance", "emergency", "family"]
  },
  {
    id: "education",
    title: "Education and language learning",
    aliases: {
      en: ["education", "school", "study", "university", "college", "course", "dutch course", "dutch school", "dutch lessons", "language school", "language course", "mbo", "hbo", "adult education", "diploma recognition"],
      nl: ["onderwijs", "school", "studie", "universiteit", "opleiding", "cursus", "nederlandse les", "nederlandse cursus", "taalschool", "taalhuis", "inburgering", "volwassenenonderwijs", "diplomawaardering"],
      ru: ["образование", "школа", "учеба", "учёба", "университет", "курсы", "голландский язык", "курсы голландского", "языковая школа", "признание диплома", "shkola", "ucheba"]
    },
    relatedIntents: ["language-learning", "integration", "documents"]
  },
  {
    id: "telecom",
    title: "SIM, phone and internet",
    aliases: {
      en: ["sim", "sim card", "prepaid", "phone contract", "mobile", "mobile phone", "esim", "telecom", "internet", "broadband"],
      nl: ["sim", "simkaart", "prepaid", "telefoonabonnement", "mobiel", "esim", "telecom", "internet", "breedband"],
      ru: ["сим", "сим карта", "сим-карта", "предоплата", "мобильная связь", "телефонный контракт", "интернет", "sim karta"]
    },
    relatedIntents: ["daily-life", "utilities", "shopping"]
  },
  {
    id: "rules-fines",
    title: "Rules and fines",
    aliases: {
      en: ["rules", "fine", "fines", "parking fine", "traffic fine", "traffic rules", "bicycle rules", "waste fine", "municipal rules", "noise rules", "pet rules"],
      nl: ["regels", "boete", "boetes", "parkeerboete", "verkeersboete", "verkeersregels", "fietsregels", "afvalboete", "gemeentelijke regels", "geluidsoverlast"],
      ru: ["правила", "штраф", "штрафы", "штраф за парковку", "дорожный штраф", "правила движения", "правила для велосипедов", "штраф за мусор", "shtraf"]
    },
    relatedIntents: ["transport", "government", "legal-help", "pets"]
  },
  {
    id: "government",
    title: "Government and municipal services",
    aliases: {
      en: ["government", "municipality", "municipal services", "city hall", "appointment", "gemeente"],
      nl: ["overheid", "gemeente", "gemeentelijke diensten", "stadhuis", "afspraak"],
      ru: ["государство", "муниципалитет", "мэрия", "государственные услуги", "запись в муниципалитет"]
    },
    relatedIntents: ["documents", "taxes", "benefits"]
  },
  {
    id: "transport",
    title: "Transport",
    aliases: {
      en: ["transport", "public transport", "train", "bus", "tram", "metro", "ov card", "ov chipkaart", "station", "bicycle"],
      nl: ["vervoer", "openbaar vervoer", "trein", "bus", "tram", "metro", "ov-chipkaart", "station", "fiets"],
      ru: ["транспорт", "общественный транспорт", "поезд", "автобус", "трамвай", "метро", "велосипед"]
    },
    relatedIntents: ["rules-fines", "daily-life"]
  },
  {
    id: "emergency",
    title: "Emergency",
    aliases: {
      en: ["emergency", "urgent help", "police", "ambulance", "fire", "112"],
      nl: ["noodgeval", "spoed", "politie", "ambulance", "brandweer", "112"],
      ru: ["экстренная помощь", "срочная помощь", "полиция", "скорая", "пожарные", "112"]
    },
    relatedIntents: ["healthcare", "safety"]
  },
  {
    id: "finance",
    title: "Banking and money",
    aliases: { en: ["bank", "banking", "bank account", "money", "payment"], nl: ["bank", "bankrekening", "geld", "betaling"], ru: ["банк", "банковский счет", "банковский счёт", "деньги", "платеж"] },
    relatedIntents: ["taxes", "benefits", "business"]
  },
  {
    id: "taxes",
    title: "Taxes",
    aliases: { en: ["tax", "taxes", "tax return", "income tax"], nl: ["belasting", "belastingen", "belastingaangifte", "inkomstenbelasting"], ru: ["налог", "налоги", "налоговая декларация"] },
    relatedIntents: ["finance", "benefits", "work"]
  },
  {
    id: "benefits",
    title: "Benefits and allowances",
    aliases: {
      en: ["benefit", "benefits", "allowance", "allowances", "toeslag", "healthcare benefit", "rent benefit", "childcare benefit", "supplementary child benefit"],
      nl: ["uitkering", "uitkeringen", "toeslag", "toeslagen", "zorgtoeslag", "huurtoeslag", "kinderopvangtoeslag", "kindgebonden budget"],
      ru: ["пособие", "пособия", "выплаты", "льготы", "пособие на страховку", "пособие на аренду", "пособие на детский сад", "детское пособие"]
    },
    relatedIntents: ["housing", "finance", "healthcare"]
  },
  {
    id: "business",
    title: "Starting a business",
    aliases: { en: ["business", "start a business", "company", "self employed", "freelance", "kvk"], nl: ["bedrijf", "ondernemen", "zzp", "zelfstandig", "kvk"], ru: ["бизнес", "открыть бизнес", "компания", "предприниматель", "фриланс"] },
    relatedIntents: ["work", "taxes", "finance"]
  },
  {
    id: "immigration",
    title: "Immigration and residence",
    aliases: {
      en: ["immigration", "visa", "mvv", "residence permit", "work visa", "study visa", "family reunification", "permanent residence", "citizenship"],
      nl: ["immigratie", "visum", "mvv", "verblijfsvergunning", "werkvisum", "studievisum", "gezinshereniging", "permanent verblijf", "nationaliteit"],
      ru: ["иммиграция", "виза", "mvv", "вид на жительство", "рабочая виза", "студенческая виза", "воссоединение семьи", "постоянный вид на жительство", "гражданство"]
    },
    relatedIntents: ["documents", "integration", "government", "legal-help"]
  },
  {
    id: "integration",
    title: "Integration",
    aliases: { en: ["integration", "civic integration", "inburgering"], nl: ["integratie", "inburgering", "inburgeren"], ru: ["интеграция", "гражданская интеграция", "инбургеринг"] },
    relatedIntents: ["education", "language-learning", "documents"]
  },
  {
    id: "language-learning",
    title: "Language learning",
    aliases: { en: ["language", "learn dutch", "dutch language", "nt2", "b1", "b2"], nl: ["taal", "nederlands leren", "nt2", "b1", "b2"], ru: ["язык", "учить голландский", "нидерландский язык", "nt2", "b1", "b2"] },
    relatedIntents: ["education", "integration"]
  },
  ...[
    ["utilities", "Utilities", ["utilities", "electricity", "gas", "water"], ["nutsvoorzieningen", "elektriciteit", "gas", "water"], ["коммунальные услуги", "электричество", "газ", "вода"]],
    ["legal-help", "Legal help", ["legal help", "lawyer", "legal advice"], ["juridische hulp", "advocaat", "juridisch advies"], ["юридическая помощь", "юрист", "адвокат"]],
    ["family", "Family and children", ["family", "children", "childcare"], ["gezin", "kinderen", "kinderopvang"], ["семья", "дети", "детский сад"]],
    ["safety", "Safety", ["safety", "police help"], ["veiligheid", "politiehulp"], ["безопасность", "помощь полиции"]],
    ["shopping", "Shopping", ["shopping", "supermarket", "shop"], ["winkelen", "supermarkt", "winkel"], ["покупки", "супермаркет", "магазин"]],
    ["daily-life", "Daily life", ["daily life", "living in the netherlands"], ["dagelijks leven", "leven in nederland"], ["повседневная жизнь", "жизнь в нидерландах"]],
    ["pets", "Pets", ["pet", "pets", "pet registration", "dog", "cat"], ["huisdier", "huisdieren", "huisdier registreren", "hond", "kat"], ["питомец", "питомца", "регистрация питомца", "домашние животные", "собака", "кошка"]],
    ["municipal-services", "Municipal services", ["municipal services", "local government"], ["gemeentelijke diensten", "lokale overheid"], ["муниципальные услуги", "местные органы власти"]],
    ["internet", "Internet", ["internet", "broadband", "wifi"], ["internet", "breedband", "wifi"], ["интернет", "вайфай"]],
    ["insurance", "Insurance", ["insurance", "insured"], ["verzekering", "verzekerd"], ["страхование", "страховка"]]
  ].map(([id, title, en, nl, ru]) => ({
    id: id as string,
    title: title as string,
    aliases: { en: en as string[], nl: nl as string[], ru: ru as string[] },
    relatedIntents: [] as string[]
  }))
];

export function taxonomyTopic(id: string): SearchTaxonomyTopic | undefined {
  return SEARCH_TAXONOMY.find((topic) => topic.id === id);
}

function containsPhrase(query: string, phrase: string): boolean {
  return ` ${query} `.includes(` ${phrase} `);
}

export function matchSearchIntents(
  normalizedQuery: string,
  normalize: (value: string) => string
): SearchIntentMatch[] {
  if (!normalizedQuery) return [];
  const matches = new Map<string, SearchIntentMatch>();
  for (const topic of SEARCH_TAXONOMY) {
    for (const aliasValue of Object.values(topic.aliases).flat()) {
      const alias = normalize(aliasValue);
      if (!alias || (!containsPhrase(normalizedQuery, alias) && normalizedQuery !== alias)) continue;
      const candidate = {
        intent: topic.id,
        alias,
        exact: normalizedQuery === alias,
        specificity: alias.split(" ").length * 100 + alias.length
      };
      const existing = matches.get(topic.id);
      if (!existing || candidate.exact || candidate.specificity > existing.specificity) {
        matches.set(topic.id, candidate);
      }
    }
  }
  return [...matches.values()].sort((left, right) =>
    Number(right.exact) - Number(left.exact) || right.specificity - left.specificity || left.intent.localeCompare(right.intent)
  );
}

export const SEARCH_TAXONOMY_IDS = new Set(SEARCH_TAXONOMY.map((topic) => topic.id));

function normalizePrivacyTerm(value: string): string {
  return value
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[’`´]/g, "'")
    .toLocaleLowerCase("en")
    .replace(/[^\p{L}\p{N}]+/gu, " ")
    .trim();
}

const controlledPrivacyTerms = new Set(
  [
    ...SEARCH_TAXONOMY.flatMap((topic) => [
      topic.id,
      topic.title,
      ...Object.values(topic.aliases).flat()
    ]),
    ...lifeDomains.flatMap((domain) => [
      domain.slug,
      domain.title,
      ...Object.values(domain.aliases).flat(),
      ...domain.intents.flatMap((intent) => [intent.id, ...intent.terms])
    ])
  ].flatMap((value) => normalizePrivacyTerm(value).split(/\s+/u).filter(Boolean))
);

export function privacySafeSearchQuery(query: string): string {
  const normalized = normalizePrivacyTerm(query);
  if (!normalized) return "";
  const queryTokens = normalized.split(/\s+/u);
  const containsDirectIdentifier = /@|https?:|\b\d{5,}\b|\b\+?\d[\d\s().-]{7,}\d\b/u.test(query);
  if (containsDirectIdentifier || queryTokens.length > 8 || normalized.length > 80) return "[redacted]";
  return queryTokens.every((token) => controlledPrivacyTerms.has(token))
    ? normalized
    : "[unmapped]";
}
