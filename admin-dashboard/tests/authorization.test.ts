import assert from "node:assert/strict";
import test from "node:test";

import {
  canAccessPath,
  canEditContent,
  canManageBusinessInquiries,
  canPublishContent
} from "../src/lib/authorization.ts";

test("only owners and admins may publish or manage business inquiries", () => {
  for (const role of ["owner", "admin"] as const) {
    assert.equal(canPublishContent(role), true);
    assert.equal(canManageBusinessInquiries(role), true);
    assert.equal(canAccessPath(role, "/business-inquiries/example"), true);
  }
  for (const role of ["editor", "qa", "viewer"] as const) {
    assert.equal(canPublishContent(role), false);
    assert.equal(canManageBusinessInquiries(role), false);
    assert.equal(canAccessPath(role, "/business-inquiries/example"), false);
  }
  assert.equal(canEditContent("editor"), true);
  assert.equal(canEditContent("viewer"), false);
});
