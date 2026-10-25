import Image from "next/image";
import Link from "next/link";

export function Brand({ href = "/", homeLabel = "YouNew home" }: { href?: string; homeLabel?: string }) {
  return (
    <Link href={href} className="brand" aria-label={homeLabel}>
      <span className="brand-mark" aria-hidden="true">
        <Image src="/icons/brand-64.png" alt="" width={40} height={40} sizes="40px" />
      </span>
      <span className="brand-wordmark">YouNew</span>
    </Link>
  );
}
