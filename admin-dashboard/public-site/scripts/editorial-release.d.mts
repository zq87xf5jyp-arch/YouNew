import type {EditorialContent} from '../src/lib/content/types';
export interface EditorialRelease {
  id:string; batchSha256:string; approvedAt:string;
  entities:Array<{id:string;coordinate:{latitude:number;longitude:number}|null;images:unknown[];editorial:EditorialContent;source:{isOfficial:boolean;status:string}}>;
}
export const approvalPath:string;
export function loadEditorialRelease(repositoryRoot?:string):Promise<EditorialRelease>;
export function projectEditorialRelease(approval:unknown,records:unknown[],reviewers:unknown,options?:{today:string}):EditorialRelease;
