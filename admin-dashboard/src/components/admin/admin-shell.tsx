"use client";

import { usePathname } from "next/navigation";
import { AdminMobileNav, AdminSidebar } from "@/components/admin/nav";
import { Topbar } from "@/components/admin/topbar";
import type { AdminRole } from "@/lib/auth";

export function AdminShell({
  children,
  role,
  name
}: {
  children: React.ReactNode;
  role: AdminRole;
  name: string;
}) {
  const pathname = usePathname();

  return (
    <div className="min-h-screen lg:flex">
      <AdminSidebar pathname={pathname} role={role} />
      <div className="min-w-0 flex-1">
        <Topbar role={role} name={name} />
        <AdminMobileNav pathname={pathname} role={role} />
        <main className="px-4 py-6 md:px-6 lg:px-8">{children}</main>
      </div>
    </div>
  );
}
