import { readFile } from "node:fs/promises";
import { parseFinanceSnapshot } from "./report";

// Server only: the private snapshot is neither bundled nor served from public/.
// Deployment without an explicit mounted snapshot stays unavailable.
export async function loadFinanceSnapshot() {
  const path = process.env.YOUNEW_FINANCE_SNAPSHOT_PATH;
  if (!path) return { snapshot: null, error: "Источник финансов не подключён. Нужен проверенный снимок провайдеров и расходов." };
  try {
    const raw = await readFile(path, "utf8");
    if (raw.length > 10_000_000) throw new Error("Snapshot too large");
    return { snapshot: parseFinanceSnapshot(JSON.parse(raw)), error: null };
  } catch {
    return { snapshot: null, error: "Финансовый снимок недоступен или не прошёл проверку. Последние суммы не подменяются нулём." };
  }
}
