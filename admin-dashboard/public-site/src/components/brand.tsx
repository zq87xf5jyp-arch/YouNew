import Link from "next/link";

export function Brand({ compact = false }: { compact?: boolean }) {
  return (
    <Link href="/" className="flex items-center gap-3" aria-label="YouNew.nl home">
      <span className="relative grid size-10 shrink-0 place-items-center rounded-[14px] bg-[#061a2d] shadow-orange">
        <span className="absolute inset-0 rounded-[14px] border border-white/15" />
        <span className="h-5 w-5 rounded-full border-[5px] border-cyan-brand border-r-orange-brand" />
      </span>
      {!compact && (
        <span>
          <span className="block text-base font-extrabold leading-tight text-white">YouNew.nl</span>
          <span className="block text-xs font-medium leading-tight text-text-muted">Premium Netherlands Guide</span>
        </span>
      )}
    </Link>
  );
}
