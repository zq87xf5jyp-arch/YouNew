export const rolePermissions = {
  owner: ["all"],
  admin: ["all"],
  editor: ["content", "categories", "cities", "map", "links", "ai-knowledge"],
  qa: ["visual-qa", "bugs", "releases"],
  viewer: ["read"]
} as const;

export type AdminRole = keyof typeof rolePermissions;

type RoutePolicy = {
  prefix: string;
  roles: readonly AdminRole[];
  mutationRoles?: readonly AdminRole[];
  publishedContentRoles?: readonly AdminRole[];
  verificationRoles?: readonly AdminRole[];
  reviewQueueRoles?: readonly AdminRole[];
  governanceRoles?: readonly AdminRole[];
};

const allRoles = ["owner", "admin", "editor", "qa", "viewer"] as const;
const localDemoRoles = ["owner", "editor", "qa", "viewer"] as const;
const ownerAdminRoles = ["owner", "admin"] as const;
const editorialRoles = ["owner", "admin", "editor"] as const;
const reviewRoles = ["owner", "admin", "editor", "qa"] as const;
const verificationRoles = ["owner", "admin", "qa"] as const;
const editorArticleStatuses = ["draft", "review", "qa"] as const;

/**
 * One route/capability registry shared by middleware, navigation and server actions.
 * Route access is read access; mutation capabilities remain explicit and narrower.
 */
export const routePolicies: readonly RoutePolicy[] = [
  { prefix: "/dashboard", roles: allRoles },
  { prefix: "/analytics", roles: ownerAdminRoles },
  { prefix: "/finance", roles: ["owner"] },
  { prefix: "/sync", roles: ownerAdminRoles, mutationRoles: ownerAdminRoles },
  {
    prefix: "/trust",
    roles: allRoles,
    publishedContentRoles: ownerAdminRoles,
    verificationRoles,
    reviewQueueRoles: reviewRoles,
    governanceRoles: ownerAdminRoles
  },
  {
    prefix: "/content",
    roles: allRoles,
    mutationRoles: editorialRoles,
    publishedContentRoles: ownerAdminRoles
  },
  { prefix: "/business-inquiries", roles: ownerAdminRoles, mutationRoles: ownerAdminRoles },
  { prefix: "/categories", roles: allRoles },
  { prefix: "/cities", roles: allRoles },
  { prefix: "/map", roles: allRoles },
  { prefix: "/visual-qa", roles: ["owner", "admin", "qa"] },
  { prefix: "/bugs", roles: ["owner", "admin", "qa"] },
  { prefix: "/releases", roles: ["owner", "admin", "qa"] },
  { prefix: "/links", roles: editorialRoles },
  { prefix: "/ai-knowledge", roles: editorialRoles },
  { prefix: "/feedback", roles: ["owner", "admin", "qa"] },
  { prefix: "/settings", roles: ownerAdminRoles, mutationRoles: ownerAdminRoles },
  { prefix: "/audit-log", roles: ownerAdminRoles }
];

export const roleLabels: Record<AdminRole, string> = {
  owner: "Admin",
  admin: "Admin",
  editor: "Editor",
  qa: "QA",
  viewer: "Read Only"
};

function policyFor(prefix: string) {
  const policy = routePolicies.find((candidate) => candidate.prefix === prefix);
  if (!policy) throw new Error(`Missing route policy for ${prefix}.`);
  return policy;
}

function allows(roles: readonly AdminRole[] | undefined, role: AdminRole) {
  return roles?.includes(role) ?? false;
}

export function canAccessPath(role: AdminRole, pathname: string) {
  const rule = routePolicies.find(({ prefix }) => pathname === prefix || pathname.startsWith(`${prefix}/`));
  return rule ? allows(rule.roles, role) : false;
}

export function resolveLocalDemoAdminRole(value: string | undefined): AdminRole {
  return (localDemoRoles as readonly string[]).includes(value ?? "")
    ? value as (typeof localDemoRoles)[number]
    : "owner";
}

export function canEditContent(role: AdminRole) {
  return allows(policyFor("/content").mutationRoles, role);
}

export function canPublishContent(role: AdminRole) {
  return allows(policyFor("/content").publishedContentRoles, role);
}

export function canRequestSync(role: AdminRole) {
  return allows(policyFor("/sync").mutationRoles, role);
}

export function canApproveTrustPublication(role: AdminRole) {
  return allows(policyFor("/trust").publishedContentRoles, role);
}

export function canEditorManageArticleStatus(status: string) {
  return (editorArticleStatuses as readonly string[]).includes(status);
}

export function canEditArticle(role: AdminRole, currentStatus: string, nextStatus = currentStatus) {
  if (!canEditContent(role)) return false;
  if (canPublishContent(role)) return true;
  return canEditorManageArticleStatus(currentStatus) && canEditorManageArticleStatus(nextStatus);
}

export function canManageBusinessInquiries(role: AdminRole) {
  return allows(policyFor("/business-inquiries").mutationRoles, role);
}

export function canVerifyContent(role: AdminRole) {
  return allows(policyFor("/trust").verificationRoles, role);
}

export function canWorkReviewQueue(role: AdminRole) {
  return allows(policyFor("/trust").reviewQueueRoles, role);
}

export function canManageGovernancePolicy(role: AdminRole) {
  return allows(policyFor("/trust").governanceRoles, role);
}

export function canManageSettings(role: AdminRole) {
  return allows(policyFor("/settings").mutationRoles, role);
}
