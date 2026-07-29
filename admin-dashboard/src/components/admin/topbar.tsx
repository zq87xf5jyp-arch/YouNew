import { Bell, Search, UserCircle } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { roleLabels, type AdminRole } from "@/lib/authorization";
import { signOut } from "@/app/(auth)/login/actions";

export function Topbar({ role, name }: { role: AdminRole; name: string }) {
  return (
    <header className="sticky top-0 z-10 border-b border-border/70 bg-background/82 px-4 py-3 backdrop-blur md:px-6">
      <div className="flex items-center gap-4">
        <div className="relative max-w-xl flex-1">
          <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input className="pl-9" placeholder="Поиск по контенту, скриншотам, ошибкам, релизам..." />
        </div>
        <Badge variant="info" className="hidden md:inline-flex">
          {roleLabels[role]}
        </Badge>
        <Button variant="outline" size="icon" aria-label="Notifications">
          <Bell data-icon="inline-start" />
        </Button>
        <form action={signOut}>
          <Button variant="outline" type="submit">Выйти</Button>
        </form>
        <div className="hidden items-center gap-2 md:flex">
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
