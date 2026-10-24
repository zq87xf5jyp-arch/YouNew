const spreadsheetFormulaPattern = /^[\s\u0000-\u001f]*[=+\-@]/;

export function csvCell(value: unknown) {
  const raw = String(value ?? "");
  const neutralized = (spreadsheetFormulaPattern.test(raw) || /^[\t\r\n]/.test(raw)) ? `'${raw}` : raw;
  return `"${neutralized.replaceAll("\"", "\"\"")}"`;
}
