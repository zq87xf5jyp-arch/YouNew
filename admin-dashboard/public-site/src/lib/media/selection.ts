import type {PublicMediaAsset} from '../content/types';

/** Archive-only images are never promoted into cards, maps or page heroes. */
export function preferredMedia(assets: readonly PublicMediaAsset[], roles: readonly PublicMediaAsset['role'][]) {
  const eligible=assets.filter(asset=>asset.placement!=='archive_gallery_only');
  for(const role of roles){const match=eligible.find(asset=>asset.role===role);if(match)return match;}
  return eligible[0]??null;
}
