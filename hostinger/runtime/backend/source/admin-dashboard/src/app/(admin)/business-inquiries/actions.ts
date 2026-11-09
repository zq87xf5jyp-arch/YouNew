'use server';
import {revalidatePath} from 'next/cache';
import {updateInquiry,updateNotification} from '@/lib/r4/repository';
import {safeError} from '@/lib/r4/security';
import type {InquiryActionResult} from '@/lib/business-inquiry-compatibility';
export async function updateBusinessInquiry(form:FormData):Promise<InquiryActionResult>{try{const row=await updateInquiry(form);revalidatePath('/business-inquiries');revalidatePath('/business-inquiries/'+row.id);return {ok:true,row};}catch(e){return {ok:false,message:'Сохранение не подтверждено: '+safeError(e).body.error};}}
export async function updateBusinessInquiryNotification(form:FormData){await updateNotification(form);revalidatePath('/business-inquiries');}
