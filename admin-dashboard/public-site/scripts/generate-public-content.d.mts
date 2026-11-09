import type {ContentEntity} from "../src/lib/content/types";
export function buildPublicDataset(runtime: unknown, options?: {verifyChecksum?: boolean}): {content: {entities: ContentEntity[]}};
