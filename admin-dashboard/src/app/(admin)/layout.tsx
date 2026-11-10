import { AdminShell } from "@/components/admin/admin-shell";
import { requireAdmin } from "@/lib/auth";
import { canManageBusinessInquiries } from "@/lib/authorization";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export default async function ProtectedLayout({ children }: { children: React.ReactNode }) {
  const admin = await requireAdmin();
  let unreadNotifications: number | null = null;
  if (canManageBusinessInquiries(admin.role)) {
    const supabase = await createSupabaseServerClient();
    if (supabase) {
      const result = await supabase
        .from("business_inquiry_notifications")
        .select("id", { count: "exact", head: true })
        .eq("status", "unread");
      if (!result.error && typeof result.count === "number" && Number.isSafeInteger(result.count) && result.count >= 0) {
        unreadNotifications = result.count;
      }
    }
  }
  return (
    <AdminShell role={admin.role} name={admin.full_name} unreadNotifications={unreadNotifications}>
      {children}
    </AdminShell>
  );
}
