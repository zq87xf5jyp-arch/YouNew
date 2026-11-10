import type { PublicMediaAsset } from "@/lib/content";

export function MediaCredit({ asset }: { asset: PublicMediaAsset }) {
  if (!asset.attribution && !asset.license) return null;
  return <p className="entity-media-credit">
    {asset.attribution}
    {asset.license ? <> · {asset.licenseUrl ? <a href={asset.licenseUrl} target="_blank" rel="noreferrer">{asset.license}</a> : asset.license}</> : null}
    {asset.sourcePageUrl ? <> · <a href={asset.sourcePageUrl} target="_blank" rel="noreferrer">Source</a></> : null}
  </p>;
}
