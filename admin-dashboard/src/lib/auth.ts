import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { canEditContent, type AdminRole } from "@/lib/authorization";
export { roleLabels, rolePermissions, canAccessPath, canEditContent } from "@/lib/authorization";
export type { AdminRole } from "@/lib/authorization";

export function isLocalDemoAdminEnabled() {
  return process.env.NODE_ENV !== "production" && process.env.YOUNEW_ADMIN_DEMO_MODE === "true";
}

export async function requireAdmin() {
  const supabase = await createSupabaseServerClient();

  if (!supabase) {
    if (!isLocalDemoAdminEnabled()) {
      redirect("/login?error=configuration");
    }
    return {
      id: "demo-admin",
      email: "demo@younew.nl",
      role: "owner" as AdminRole,
      full_name: "Демо-владелец"
    };
  }

  const {
    data: { user }
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("id,email,full_name,role,is_approved")
    .eq("id", user.id)
    .maybeSingle();

  if (!profile?.is_approved) {
    redirect("/login?error=not-approved");
  }

  return {
    id: user.id,
    email: profile.email ?? user.email ?? "",
    role: (profile.role ?? "viewer") as AdminRole,
    full_name: profile.full_name ?? user.email ?? "Администратор"
  };
}

export async function requireContentEditor() {
  const admin = await requireAdmin();
  if (!canEditContent(admin.role)) {
    throw new Error("Недостаточно прав: требуется роль Admin или Editor.");
  }
  return admin;
}
