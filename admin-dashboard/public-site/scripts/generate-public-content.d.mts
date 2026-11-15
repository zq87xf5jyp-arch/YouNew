import type {ContentEntity} from "../src/lib/content/types";
export const paths:Readonly<Record<string,string>>;
export function buildPublicDataset(runtime: unknown, options?: {verifyChecksum?: boolean;editorialRelease?:unknown;privateReview?:boolean}): {content: {entities: ContentEntity[]}};
