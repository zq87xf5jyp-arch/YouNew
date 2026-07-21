import Image from "next/image";
import { ExternalLink } from "lucide-react";
import { isSponsoredPlacementEligible, SPONSORED_PLACEMENTS_ENABLED } from "@/lib/business/sponsored";
import type { SponsoredPlacementContext, SponsoredPlacementRecord } from "@/lib/business/types";

export function SponsoredPlacement({
  placement,
  context,
  enabled = SPONSORED_PLACEMENTS_ENABLED,
  now
}: {
  placement: SponsoredPlacementRecord;
  context: SponsoredPlacementContext;
  enabled?: boolean;
  now?: Date;
}) {
  if (!isSponsoredPlacementEligible(placement, context, { enabled, now })) return null;

  return (
    <aside className="sponsored-placement" aria-label={placement.accessibilityLabel} data-sponsored-placement={placement.id}>
      <div className="sponsored-placement-label">
        <span>Sponsored</span>
        <span>by {placement.advertiserName}</span>
      </div>
      {placement.media ? (
        <Image
          className="sponsored-placement-image"
          src={placement.media.src}
          alt={placement.media.alt}
          width={placement.media.width}
          height={placement.media.height}
          loading="lazy"
        />
      ) : null}
      <div className="sponsored-placement-copy">
        <h2>{placement.title}</h2>
        <p>{placement.shortDescription}</p>
        <a href={placement.cta.destinationUrl} rel="nofollow sponsored noreferrer" target="_blank">
          {placement.cta.label} <ExternalLink aria-hidden />
        </a>
      </div>
    </aside>
  );
}
