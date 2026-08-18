import assert from "node:assert/strict";
import test from "node:test";
import { csvCell } from "../src/lib/business-inquiry-export.ts";

test("business inquiry CSV cells escape quotes and neutralize spreadsheet formulas", () => {
  assert.equal(csvCell("A \"quoted\" value"), '"A ""quoted"" value"');
  assert.equal(csvCell("=HYPERLINK(\"https://example.test\")"), '"\'=HYPERLINK(""https://example.test"")"');
  assert.equal(csvCell("+1+1"), '"\'+1+1"');
  assert.equal(csvCell("-1+1"), '"\'-1+1"');
  assert.equal(csvCell("@SUM(1,1)"), '"\'@SUM(1,1)"');
  assert.equal(csvCell("\t=SUM(1,1)"), '"\'\t=SUM(1,1)"');
  assert.equal(csvCell(null), '""');
});
