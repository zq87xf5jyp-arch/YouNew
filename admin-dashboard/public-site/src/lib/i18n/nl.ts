import type { ContentEntity } from "@/lib/content";

const categoryLabels: Record<string, string> = {
  government: "Overheid en documenten",
  housing: "Wonen",
  healthcare: "Zorg",
  education: "Onderwijs",
  work: "Werk",
  transport: "Vervoer",
  culture: "Cultuur",
  outdoors: "Buiten en natuur",
  "food-drink": "Eten en drinken",
  shopping: "Winkelen",
  museums: "Musea",
  municipality: "Gemeente",
  "local-services": "Lokale diensten",
  daily: "Dagelijks leven",
  "daily-life": "Dagelijks leven",
  banking: "Bankzaken",
  benefits: "Toeslagen",
  business: "Ondernemen",
  children: "Kinderen",
  documents: "Documenten",
  emergency: "Noodgevallen",
  family: "Gezin",
  finance: "Financiën",
  fines: "Boetes",
  integration: "Inburgering",
  internet: "Internet",
  "language-learning": "Taal leren",
  "legal-help": "Juridische hulp",
  "municipal-services": "Gemeentelijke diensten",
  pets: "Huisdieren",
  rules: "Regels",
  safety: "Veiligheid",
  "sim-telecom": "Mobiel en telecom",
  taxes: "Belastingen",
  telecom: "Telecom",
  "things-to-do": "Activiteiten",
  utilities: "Energie en water"
};

export function dutchCategoryLabel(slug: string) {
  return categoryLabels[slug] ?? slug.replaceAll("-", " ").replace(/^./, (letter) => letter.toLocaleUpperCase("nl"));
}

export function dutchEntityTypeLabel(type: ContentEntity["type"]) {
  return { city: "Stad", guide: "Gids", organization: "Organisatie", place: "Locatie" }[type];
}

export function dutchEntityRoute(entity: Pick<ContentEntity, "type" | "slug" | "route">) {
  if (entity.type === "organization") return `/nl/organisaties/${entity.slug}`;
  if (entity.type === "city") return `/nl/stadsgidsen/${entity.slug}`;
  return entity.route;
}

export function dutchEntityDescription(entity: ContentEntity) {
  const category = entity.categorySlugs[0] ? dutchCategoryLabel(entity.categorySlugs[0]) : dutchEntityTypeLabel(entity.type);
  const location = entity.cityId ? ` in ${entity.cityId.replaceAll("-", " ")}` : " in Nederland";
  return `${category}${location}. Bekijk de gecontroleerde bron, controledatum en praktische vervolgstappen op het profiel.`;
}
