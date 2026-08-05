import { Bell, LogOut, Search, UserCircle } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { roleLabels, type AdminRole } from "@/lib/authorization";
import { signOut } from "@/app/(auth)/login/actions";

export function Topbar({ role, name }: { role: AdminRole; name: string }) {
  return (
    <header className="sticky top-0 z-10 border-b border-border/70 bg-background/82 px-4 py-3 backdrop-blur md:px-6">
      <div className="flex min-w-0 items-center gap-2 sm:gap-3">
        <div className="relative min-w-0 max-w-xl flex-1">
          <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input className="pl-9" placeholder="Поиск по контенту, скриншотам, ошибкам, релизам..." />
        </div>
        <Badge variant="info" className="hidden lg:inline-flex">
          {roleLabels[role]}
        </Badge>
        <Button variant="outline" size="icon" aria-label="Notifications">
          <Bell data-icon="inline-start" />
        </Button>
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
