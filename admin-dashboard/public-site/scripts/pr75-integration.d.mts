import type {PlaceRevision,PlaceManifest} from './place-review.mjs';
export const integrationBatch:string;
export const integrationPath:string;
export const selections:readonly [string,string][];
export function digest(value:unknown):string;
export function integrationInputs(root:string):Promise<{records:PlaceRevision[];mergedHashes:Record<string,string>;additions:string[];collections:{collections:Array<{key:string;entityIds:string[]}>}}>;
export function verifyIntegration(root:string,manifest:PlaceManifest,records:PlaceRevision[]):Promise<unknown>;
