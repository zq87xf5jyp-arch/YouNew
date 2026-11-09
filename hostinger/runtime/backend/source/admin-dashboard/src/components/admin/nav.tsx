import Link from "next/link";
import {BookOpen,BriefcaseBusiness,LayoutDashboard,ShieldCheck,Archive} from "lucide-react";
import { cn } from "@/lib/utils";
import { YouNewLogo } from "@/components/admin/logo";
import { canAccessPath, type AdminRole } from "@/lib/authorization";

const items = [
  { href: "/dashboard", label: "Admin", icon: LayoutDashboard },
  { href: "/content", label: "Каталог", icon: BookOpen },
  { href: "/business-inquiries", label: "Заявки", icon: BriefcaseBusiness },
  { href: "/history", label: "История", icon: Archive },
  { href: "/audit-log", label: "Журнал", icon: ShieldCheck }
];

export function AdminSidebar({ pathname, role }: { pathname: string; role: AdminRole }) {
  return (
    <aside className="hidden h-screen w-72 shrink-0 border-r border-border/80 bg-[#031023]/95 p-5 lg:sticky lg:top-0 lg:block">
      <YouNewLogo />
      <nav className="mt-8 flex flex-col gap-1">
        {items.filter((item) => canAccessPath(role, item.href)).map((item) => {
          const active = pathname === item.href;
          const Icon = item.icon;
          return (
            <Link
              href={item.href}
              key={item.href}
              aria-current={active ? "page" : undefined}
              className={cn(
                "flex items-center gap-3 rounded-md px-3 py-2.5 text-sm font-medium text-muted-foreground transition hover:bg-secondary hover:text-foreground",
                active && "bg-primary/15 text-orange-100 ring-1 ring-primary/25"
              )}
            >
              <Icon className="size-4" />
              {item.label}
            </Link>
          );
        })}
      </nav>
      <div className="mt-4 rounded-lg border border-orange-400/20 bg-orange-400/10 p-4">
        <div className="flex items-center gap-2 text-orange-100">
          <ShieldCheck className="size-4" />
          <p className="text-sm font-semibold">Защита админки активна</p>
        </div>
        <p className="mt-2 text-xs text-muted-foreground">Доступ только для одобренных ролей. Права доступа проверяются сервером.</p>
      </div>
    </aside>
  );
}

export function AdminMobileNav({ pathname, role }: { pathname: string; role: AdminRole }) {
  return (
    <nav className="sticky top-[65px] z-10 flex w-full min-w-0 max-w-full gap-2 overflow-x-auto border-b border-border/70 bg-background/90 px-4 py-3 backdrop-blur lg:hidden">
      {items.filter((item) => canAccessPath(role, item.href)).map((item) => {
        const active = pathname === item.href;
        const Icon = item.icon;
        return (
          <Link
            href={item.href}
            key={item.href}
            aria-current={active ? "page" : undefined}
            className={cn(
              "inline-flex shrink-0 items-center gap-2 rounded-md border border-border bg-secondary/60 px-3 py-2 text-sm font-medium text-muted-foreground",
              active && "border-primary/40 bg-primary/15 text-orange-100"
            )}
          >
            <Icon className="size-4" />
            {item.label}
          </Link>
        );
      })}
    </nav>
  );
}
