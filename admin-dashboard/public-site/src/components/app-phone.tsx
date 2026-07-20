import Image from "next/image";
import { Bot, ChevronRight, Chrome as ChromeIcon, FileText, HeartPulse, Home, Landmark, Map, Search, Train } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import type { ScreenshotMode } from "@/lib/site-data";

const categoryRows = [
  { label: "Documents", icon: FileText, tone: "text-orange-brand" },
  { label: "Transport", icon: Train, tone: "text-cyan-brand" },
  { label: "Healthcare", icon: HeartPulse, tone: "text-emerald-300" },
  { label: "Housing", icon: Home, tone: "text-orange-soft" }
];

export function AppPhone({
  mode = "home",
  compact = false,
  label = "YouNew.nl app preview"
}: {
  mode?: ScreenshotMode | "hero";
  compact?: boolean;
  label?: string;
}) {
  return (
    <div className={`phone-shell ${compact ? "w-[214px]" : "w-[290px] sm:w-[330px]"} mx-auto`} aria-label={label}>
      <div className={`phone-screen ${compact ? "min-h-[410px]" : "min-h-[610px]"} relative`}>
        <div className="absolute left-1/2 top-3 z-10 h-5 w-24 -translate-x-1/2 rounded-full bg-black/70" />
        <div className="relative z-[1] p-5 pt-11">
          <PhoneHeader mode={mode} />
          {mode === "map" ? <MapScreen /> : mode === "ai" ? <AiScreen /> : mode === "transport" ? <TransportScreen /> : <DefaultScreen mode={mode} />}
        </div>
      </div>
    </div>
  );
}

function PhoneHeader({ mode }: { mode: ScreenshotMode | "hero" }) {
  const titles: Record<string, string> = {
    hero: "Netherlands Guide",
    home: "Netherlands Guide",
    categories: "Smart Categories",
    dashboard: "Today",
    map: "Interactive Map",
    transport: "Transport Guide",
    library: "Reference Library",
    guide: "First Steps",
    ai: "AI Assistant"
  };

  return (
    <div className="mb-5 flex items-center justify-between">
      <div>
        <p className="text-xs font-semibold text-cyan-brand">YouNew.nl</p>
        <h3 className="mt-1 text-xl font-black leading-tight text-white">{titles[mode]}</h3>
      </div>
      <div className="grid size-10 place-items-center rounded-2xl border border-white/10 bg-white/8">
        <Search className="size-4 text-white" aria-hidden />
      </div>
    </div>
  );
}

function DefaultScreen({ mode }: { mode: ScreenshotMode | "hero" }) {
  const showImage = mode === "home" || mode === "hero" || mode === "guide";
  return (
    <div className="space-y-4">
      {showImage ? (
        <div className="relative h-36 overflow-hidden rounded-[24px] border border-white/10">
          <Image src="/images/home-leiden-canals.jpg" alt="Leiden canals in the YouNew.nl Netherlands guide home visual" fill sizes="300px" className="object-cover" priority />
          <div className="absolute inset-0 bg-gradient-to-t from-[#020713] via-transparent to-transparent" />
          <div className="absolute bottom-4 left-4 right-4">
            <p className="text-xs font-semibold text-cyan-brand">Living, working, discovering</p>
            <p className="mt-1 text-lg font-black leading-tight text-white">Understand the Netherlands faster</p>
          </div>
        </div>
      ) : null}

      <div className="rounded-[24px] border border-white/10 bg-white/[0.07] p-4">
        <div className="mb-3 flex items-center justify-between">
          <p className="text-sm font-bold text-white">{mode === "library" ? "Verified resources" : "Start here"}</p>
          <span className="rounded-full bg-orange-brand/15 px-3 py-1 text-[11px] font-bold text-orange-soft">Smart</span>
        </div>
        <div className="space-y-2.5">
          {categoryRows.map((row) => (
            <div key={row.label} className="flex items-center gap-3 rounded-2xl bg-white/[0.055] p-3">
              <row.icon className={`size-4 ${row.tone}`} aria-hidden />
              <span className="flex-1 text-sm font-semibold text-white">{row.label}</span>
              <ChevronRight className="size-4 text-white/45" aria-hidden />
            </div>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <MiniTile title="Official links" icon={Landmark} tone="text-cyan-brand" />
        <MiniTile title="City guides" icon={Map} tone="text-orange-soft" />
      </div>
    </div>
  );
}

function MapScreen() {
  return (
    <div className="space-y-4">
      <div className="relative grid h-64 place-items-center overflow-hidden rounded-[26px] border border-white/10 bg-[#061b2f]">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src="/images/netherlands-map-provinces.svg" alt="Netherlands province map in the YouNew.nl app" className="h-[220px] w-auto opacity-90 drop-shadow-[0_0_30px_rgba(0,214,230,0.28)]" />
        <span className="absolute right-10 top-20 size-3 rounded-full bg-orange-brand shadow-orange" />
        <span className="absolute bottom-24 left-16 size-3 rounded-full bg-cyan-brand shadow-glow" />
      </div>
      <MiniTile title="Amsterdam" icon={Map} tone="text-orange-soft" wide />
      <MiniTile title="Rotterdam" icon={Map} tone="text-cyan-brand" wide />
      <MiniTile title="Utrecht" icon={Map} tone="text-emerald-300" wide />
    </div>
  );
}

function TransportScreen() {
  return (
    <div className="space-y-4">
      <div className="rounded-[26px] border border-white/10 bg-white/[0.07] p-4">
        <div className="flex items-center gap-3">
          <div className="grid size-12 place-items-center rounded-2xl bg-orange-brand/18">
            <Train className="size-6 text-orange-soft" aria-hidden />
          </div>
          <div>
            <p className="text-sm font-black text-white">NS, OVpay, 9292</p>
            <p className="text-xs text-text-muted">Clear basics for every trip</p>
          </div>
        </div>
      </div>
      {["Check in and out", "Plan with 9292", "Understand stations", "Metro, bus and tram"].map((item) => (
        <div key={item} className="rounded-2xl border border-white/10 bg-white/[0.055] p-4 text-sm font-semibold text-white">
          {item}
        </div>
      ))}
    </div>
  );
}

function AiScreen() {
  const toolGroups: Array<{ label: string; tools: Array<{ label: string; icon: LucideIcon; tone: string }> }> = [
    {
      label: "Create",
      tools: [{ label: "Template Creator", icon: FileText, tone: "text-orange-soft" }]
    },
    {
      label: "Browse",
      tools: [
        { label: "Chrome", icon: ChromeIcon, tone: "text-orange-brand" },
        { label: "Browser", icon: Search, tone: "text-cyan-brand" },
        { label: "Computer Use", icon: Bot, tone: "text-emerald-300" }
      ]
    },
    {
      label: "Build",
      tools: [{ label: "Build iOS Apps", icon: Train, tone: "text-orange-brand" }]
    }
  ];

  return (
    <div className="space-y-4">
      <div className="rounded-[26px] border border-cyan-brand/25 bg-cyan-brand/10 p-4">
        <div className="mb-4 flex items-center gap-3">
          <Bot className="size-6 text-cyan-brand" aria-hidden />
          <p className="font-black text-white">Ask in simple language</p>
        </div>
        <p className="rounded-2xl bg-white/[0.07] p-3 text-sm text-white">How do I get a BSN after arriving?</p>
      </div>
      <div className="rounded-[26px] border border-white/10 bg-white/[0.07] p-4">
        <p className="text-sm leading-6 text-text-muted">
          Start with municipality registration. Bring identity documents and verify requirements with your gemeente.
        </p>
      </div>
      <div className="space-y-2.5">
        {toolGroups.map((group) => (
          <div key={group.label} className="space-y-1.5">
            <p className="text-[10px] font-black uppercase tracking-[0.14em] text-text-muted">{group.label}</p>
            <div className="grid grid-cols-2 gap-2">
              {group.tools.map((row) => (
                <div key={row.label} className="flex min-h-14 items-center gap-2 rounded-2xl border border-white/10 bg-white/[0.055] p-3">
                  <row.icon className={`size-4 shrink-0 ${row.tone}`} aria-hidden />
                  <span className="text-[11px] font-bold leading-tight text-white">{row.label}</span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function MiniTile({ title, icon: Icon, tone, wide = false }: { title: string; icon: LucideIcon; tone: string; wide?: boolean }) {
  return (
    <div className={`flex items-center gap-3 rounded-2xl border border-white/10 bg-white/[0.06] p-3 ${wide ? "w-full" : ""}`}>
      <Icon className={`size-4 ${tone}`} aria-hidden />
      <span className="text-sm font-semibold text-white">{title}</span>
    </div>
  );
}
