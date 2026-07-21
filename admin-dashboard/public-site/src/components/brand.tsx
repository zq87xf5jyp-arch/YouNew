import Image from "next/image";
import Link from "next/link";

export function Brand() {
  return (
    <Link href="/" className="brand" aria-label="YouNew home">
      <span className="brand-mark" aria-hidden="true">
        <Image src="/icons/apple-touch-icon.png" alt="" width={40} height={40} sizes="40px" />
      </span>
      <span className="brand-wordmark">YouNew</span>
    </Link>
  );
}
