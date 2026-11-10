import { readFile, writeFile } from "node:fs/promises";
import { financeReport, parseFinanceSnapshot } from "../src/lib/finance/report.ts";

// Local/read-only financial report. No provider calls, messages or payments.
const [input, output] = process.argv.slice(2);
if (!input || !output) throw new Error("Usage: node scripts/finance-report.ts private-input.json private-report.json");
const snapshot = parseFinanceSnapshot(JSON.parse(await readFile(input, "utf8")));
const reports = snapshot.months.flatMap((month) => (["EUR", "USD"] as const).map((currency) => financeReport(snapshot, month, currency)));
await writeFile(output, JSON.stringify({ checkedAt: snapshot.checkedAt, method: snapshot.method, reports, decisions: snapshot.decisions }, null, 2) + "\n", { mode: 0o600 });
console.log(JSON.stringify({ status: "prepared_not_sent", months: snapshot.months, reportCount: reports.length }));
