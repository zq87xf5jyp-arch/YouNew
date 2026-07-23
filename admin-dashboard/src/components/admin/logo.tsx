export function YouNewLogo() {
  return (
    <div className="flex items-center gap-3">
      <div className="grid size-11 place-items-center rounded-lg border border-cyan-400/25 bg-gradient-to-br from-[#0a3b7a] to-[#06152d] shadow-glow">
        <svg viewBox="0 0 48 48" className="size-7" aria-hidden="true">
          <path d="M9 34V18l8 5v11" fill="none" stroke="white" strokeWidth="3" strokeLinecap="round" />
          <path d="M21 34V10l7 5v19" fill="none" stroke="white" strokeWidth="3" strokeLinecap="round" />
          <path d="M32 34V21l7 4v9" fill="none" stroke="white" strokeWidth="3" strokeLinecap="round" />
          <path d="M6 38c8-7 28-7 36 0" fill="none" stroke="#f97316" strokeWidth="3" strokeLinecap="round" />
        </svg>
      </div>
      <div className="leading-tight">
        <p className="text-lg font-bold tracking-tight">YouNew.nl</p>
        <p className="text-xs text-muted-foreground">Премиум-гид по Нидерландам</p>
      </div>
    </div>
  );
}
