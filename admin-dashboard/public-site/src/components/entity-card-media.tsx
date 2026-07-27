import Image from "next/image";
import type { CardMedia } from "@/lib/content/card-media";

export function EntityCardMedia({ media }: { media: CardMedia }) {
  return (
    <figure className="entity-card-media">
      <Image
        src={media.src}
        alt={media.alt}
        fill
        sizes="(max-width: 760px) calc(100vw - 32px), (max-width: 1000px) calc((100vw - 66px) / 2), 380px"
      />
      <figcaption>
        <a href={media.sourceUrl} rel="noreferrer" target="_blank">Photo: {media.credit}</a>
        <a href={media.licenseUrl} rel="noreferrer" target="_blank">{media.license}</a>
      </figcaption>
    </figure>
  );
}
