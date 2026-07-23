export const rolePermissions = {
  owner: ["all"],
  admin: ["all"],
  editor: ["content", "categories", "cities", "map", "links", "ai-knowledge"],
  qa: ["visual-qa", "bugs", "releases"],
  viewer: ["read"]
} as const;

export type AdminRole = keyof typeof rolePermissions;

export const roleLabels: Record<AdminRole, string> = {
  owner: "Admin",
  admin: "Admin",
  editor: "Editor",
  qa: "QA",
  viewer: "Read Only"
};

const routeRoles: Array<{ prefix: string; roles: readonly AdminRole[] }> = [
  { prefix: "/settings", roles: ["owner", "admin"] },
  { prefix: "/sync", roles: ["owner", "admin"] },
  { prefix: "/analytics", roles: ["owner", "admin"] },
  { prefix: "/audit-log", roles: ["owner", "admin"] },
];

export function canAccessPath(role: AdminRole, pathname: string) {
  const rule = routeRoles.find(({ prefix }) => pathname === prefix || pathname.startsWith(`${prefix}/`));
  return rule ? rule.roles.includes(role) : true;
}

export function canEditContent(role: AdminRole) {
  return role === "owner" || role === "admin" || role === "editor";
}
