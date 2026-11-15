import data from '@/generated/guide-review.json';
import type {PracticalGuideDraft} from './types';
export const guideReview = data as {schemaVersion:number;enabled:boolean;digest:string;guides:{code:string;blockers:string[];guide:PracticalGuideDraft}[]};
