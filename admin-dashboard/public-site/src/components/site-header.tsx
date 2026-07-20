import { Brand } from "@/components/brand";
import { navItems } from "@/lib/site-data";

export function SiteHeader() {
  return (
    <header className="fixed inset-x-0 top-0 z-50 border-b border-white/10 bg-[#020713]/78 backdrop-blur-2xl">
      <div className="section-shell flex h-20 items-center justify-between gap-5">
        <Brand />
        <nav className="hidden items-center gap-7 lg:flex" aria-label="Primary navigation">
          {navItems.map((item) => (
            <a key={item.href} href={item.href} className="text-sm font-semibold text-text-muted transition hover:text-white">
              {item.label}
            </a>
          ))}
        </nav>
        <a href="/support" className="rounded-full bg-orange-brand px-5 py-3 text-sm font-extrabold text-white shadow-orange transition hover:bg-orange-soft">
          Get the App
        </a>
      </div>
    </header>
  );
}
