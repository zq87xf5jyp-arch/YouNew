import Link from "next/link";
import { Bell, LogOut, UserCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { RouteLauncher } from "@/components/admin/route-launcher";
import { canManageBusinessInquiries, roleLabels, type AdminRole } from "@/lib/authorization";
import { signOut } from "@/app/(auth)/login/actions";

export function Topbar({ role, name, unreadNotifications }: { role: AdminRole; name: string; unreadNotifications: number | null }) {
  return (
    <header className="sticky top-0 z-10 border-b border-border/70 bg-background/82 px-4 py-3 backdrop-blur md:px-6">
      <div className="flex min-w-0 items-center gap-2 sm:gap-3">
        <RouteLauncher role={role} />
        <Badge variant="info" className="hidden lg:inline-flex">
          {roleLabels[role]}
        </Badge>
        {canManageBusinessInquiries(role) ? (
          <Button asChild variant="outline" size="icon">
            <Link href="/business-inquiries#notifications" aria-label={unreadNotifications === null ? "Уведомления: счётчик недоступен" : `Непрочитанные уведомления: ${unreadNotifications}`} className="relative">
              <Bell data-icon="inline-start" />
              {unreadNotifications !== null && unreadNotifications > 0 ? (
                <span className="absolute -right-1.5 -top-1.5 min-w-5 rounded-full bg-destructive px-1 text-center text-[10px] font-bold leading-5 text-destructive-foreground">
                  {unreadNotifications > 99 ? "99+" : unreadNotifications}
                </span>
              ) : unreadNotifications === null ? (
                <span
                  className="absolute -right-1.5 -top-1.5 min-w-5 rounded-full bg-amber-400 px-1 text-center text-[10px] font-bold leading-5 text-slate-950"
                  role="status"
                  title="Счётчик уведомлений недоступен"
                >!</span>
              ) : null}
            </Link>
          </Button>
        ) : null}
        <form action={signOut}>
          <Button className="px-3 sm:px-4" variant="outline" type="submit" aria-label="Выйти">
            <LogOut className="size-4 sm:hidden" />
            <span className="hidden sm:inline">Выйти</span>
          </Button>
        </form>
        <div className="hidden items-center gap-2 xl:flex">
          <UserCircle className="size-8 text-muted-foreground" />
          <div className="leading-tight">
            <p className="text-sm font-semibold">{name}</p>
            <p className="text-xs text-muted-foreground">Рабочее место администратора</p>
          </div>
        </div>
      </div>
    </header>
  );
}
