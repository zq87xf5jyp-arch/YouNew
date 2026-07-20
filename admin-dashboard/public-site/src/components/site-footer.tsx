import { Brand } from "@/components/brand";
import { links } from "@/lib/site-data";

export function SiteFooter() {
  const updateLinks = [
    { label: "Support", href: "/support" },
    { label: "Email", href: `mailto:${links.contactEmail}` },
    { label: "Terms", href: "/terms" }
  ];

  return (
    <footer className="border-t border-white/10 bg-[#020713] py-12">
      <div className="section-shell grid gap-10 md:grid-cols-[1.3fr_1fr_1fr]">
        <div>
          <Brand />
          <p className="mt-5 max-w-md text-sm leading-6 text-text-muted">
            YouNew.nl is a premium Netherlands guide for practical life, cities, transport, official resources and clear everyday explanations.
          </p>
        </div>
        <div>
          <p className="font-bold text-white">Links</p>
          <div className="mt-4 grid gap-3 text-sm text-text-muted">
            <a href="/privacy" className="hover:text-white">Privacy Policy</a>
            <a href="/terms" className="hover:text-white">Terms</a>
            <a href="/support" className="hover:text-white">Support</a>
            <a href={`mailto:${links.contactEmail}`} className="hover:text-white">Contact</a>
          </div>
        </div>
        <div>
          <p className="font-bold text-white">Follow updates</p>
          <div className="mt-4 flex gap-3">
            {updateLinks.map((item) => (
              <a key={item.label} href={item.href} className="rounded-full border border-white/10 bg-white/[0.06] px-4 py-2 text-sm font-semibold text-text-muted hover:text-white">
                {item.label}
              </a>
            ))}
          </div>
          <p className="mt-8 text-sm text-text-muted">© 2026 YouNew.nl. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}
