const spreadsheetFormulaPattern = /^[\t\r\n ]*[=+\-@]/;

export function csvCell(value: unknown) {
  const raw = String(value ?? "");
  const neutralized = spreadsheetFormulaPattern.test(raw) ? `'${raw}` : raw;
  return `"${neutralized.replaceAll("\"", "\"\"")}"`;
}
