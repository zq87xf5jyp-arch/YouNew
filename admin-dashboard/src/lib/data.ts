import { createSupabaseServerClient } from "@/lib/supabase/server";

export type Status = "draft" | "review" | "published" | "archived";

export const defaultCategories = [
  { title: "Правила и штрафы", slug: "rules-fines", color: "#f97316", icon: "TriangleAlert", status: "published", priority: 1 },
  { title: "Документы и сервисы", slug: "documents-services", color: "#38bdf8", icon: "ClipboardList", status: "published", priority: 2 },
  { title: "Транспорт", slug: "transport", color: "#14b8a6", icon: "Train", status: "published", priority: 3 },
  { title: "Работа и налоги", slug: "work-taxes", color: "#8b5cf6", icon: "BriefcaseBusiness", status: "published", priority: 4 },
  { title: "Жилье", slug: "housing", color: "#3b82f6", icon: "House", status: "published", priority: 5 },
  { title: "Здравоохранение", slug: "healthcare", color: "#ef4444", icon: "HeartPulse", status: "published", priority: 6 },
  { title: "Государство", slug: "government", color: "#22c55e", icon: "Landmark", status: "published", priority: 7 },
  { title: "Образование", slug: "education", color: "#eab308", icon: "GraduationCap", status: "published", priority: 8 },
  { title: "Экстренная помощь", slug: "emergency", color: "#dc2626", icon: "Siren", status: "published", priority: 9 },
  { title: "Библиотека", slug: "reference-library", color: "#06b6d4", icon: "Library", status: "published", priority: 10 },
  { title: "Гид по Нидерландам", slug: "netherlands-guide", color: "#0ea5e9", icon: "Map", status: "published", priority: 11 },
  { title: "AI-ассистент", slug: "ai-assistant", color: "#a855f7", icon: "Sparkles", status: "published", priority: 12 }
];

export const defaultCities = [
  { name: "Amsterdam", slug: "amsterdam", province: "Noord-Holland", lat: 52.3676, lng: 4.9041, status: "published" },
  { name: "Rotterdam", slug: "rotterdam", province: "Zuid-Holland", lat: 51.9244, lng: 4.4777, status: "published" },
  { name: "The Hague", slug: "the-hague", province: "Zuid-Holland", lat: 52.0705, lng: 4.3007, status: "published" },
  { name: "Utrecht", slug: "utrecht", province: "Utrecht", lat: 52.0907, lng: 5.1214, status: "published" },
  { name: "Leiden", slug: "leiden", province: "Zuid-Holland", lat: 52.1601, lng: 4.497, status: "published" },
  { name: "Eindhoven", slug: "eindhoven", province: "Noord-Brabant", lat: 51.4416, lng: 5.4697, status: "published" },
  { name: "Groningen", slug: "groningen", province: "Groningen", lat: 53.2194, lng: 6.5665, status: "published" },
  { name: "Maastricht", slug: "maastricht", province: "Limburg", lat: 50.8514, lng: 5.6909, status: "published" }
];

export const sampleArticles = [
  { title: "Регистрация в муниципалитете", slug: "municipality-registration", status: "published", category: "Документы и сервисы", language: "ru", priority: 1 },
  { title: "OVpay и общественный транспорт", slug: "ovpay-public-transport", status: "review", category: "Транспорт", language: "ru", priority: 2 },
  { title: "Что делать с голландскими штрафами", slug: "dutch-fines", status: "draft", category: "Правила и штрафы", language: "ru", priority: 3 }
];

export const sampleBugs = [
  { title: "Текст карточки транспорта не помещается на маленьких iPhone", severity: "high", priority: "high", status: "open", platform: "iOS", app_screen: "Транспорт" },
  { title: "У подписи маркера карты низкий контраст", severity: "medium", priority: "medium", status: "in progress", platform: "iOS", app_screen: "Карта" },
  { title: "В русской локализации нет предупреждения AI", severity: "low", priority: "medium", status: "verified", platform: "iOS", app_screen: "AI-ассистент" }
];

export type DataSource = "supabase" | "demo" | "unavailable";

export type FetchRowsResult<T> = {
  rows: T[];
  source: DataSource;
  error?: "configuration" | "query";
};

function isExplicitLocalDemoEnabled() {
  return process.env.NODE_ENV !== "production" && process.env.YOUNEW_ADMIN_DEMO_MODE === "true";
}

export async function fetchRowsResult<T>(
  table: string,
  fallback: T[],
  limit = 50,
  orderBy: "updated_at" | "created_at" | "occurred_at" | "started_at" = "updated_at"
): Promise<FetchRowsResult<T>> {
  const supabase = await createSupabaseServerClient();
  if (!supabase) {
    return isExplicitLocalDemoEnabled()
      ? { rows: fallback, source: "demo" }
      : { rows: [], source: "unavailable", error: "configuration" };
  }

  const { data, error } = await supabase
    .from(table)
    .select("*")
    .order(orderBy, { ascending: false })
    .limit(limit);

  if (error || !data) {
    return isExplicitLocalDemoEnabled()
      ? { rows: fallback, source: "demo", error: "query" }
      : { rows: [], source: "unavailable", error: "query" };
  }

  return { rows: data as T[], source: "supabase" };
}

export async function fetchRows<T>(
  table: string,
  fallback: T[],
  limit = 50,
  orderBy: "updated_at" | "created_at" | "occurred_at" | "started_at" = "updated_at"
): Promise<T[]> {
  return (await fetchRowsResult(table, fallback, limit, orderBy)).rows;
}

export async function fetchPublishedRows<T>(table: string, limit = 100): Promise<T[]> {
  const supabase = await createSupabaseServerClient();
  if (!supabase) {
    throw new Error("Supabase is not configured.");
  }

  const { data, error } = await supabase
    .from(table)
    .select("*")
    .eq("status", "published")
    .order("updated_at", { ascending: false })
    .limit(limit);

  if (error || !data) {
    throw new Error(`Supabase query failed for ${table}.`);
  }
  return data as T[];
}
