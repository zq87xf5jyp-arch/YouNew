import {NextResponse} from 'next/server';
import {listInquiries} from '@/lib/r4/repository';
import {safeError} from '@/lib/r4/security';
import {csvCell} from '@/lib/business-inquiry-export';
import {CURRENT_INQUIRY_CONTRACT} from '@/lib/business-inquiry-compatibility';
export const dynamic='force-dynamic';
export async function GET(){try{const rows=await listInquiries(10001);if(rows.length>10000)return NextResponse.json({error:'export_too_large'},{status:413});const columns=CURRENT_INQUIRY_CONTRACT.exportColumns;return new Response([columns.join(','),...rows.map(r=>columns.map(k=>csvCell(r[k])).join(','))].join('\r\n'),{headers:{'Cache-Control':'no-store','Content-Type':'text/csv; charset=utf-8','Content-Disposition':'attachment; filename="younew-inquiries.csv"','X-YouNew-Export-Row-Count':String(rows.length),'X-YouNew-Export-Complete':'true'}});}catch(e){const r=safeError(e);return NextResponse.json(r.body,{status:r.status,headers:{'Cache-Control':'no-store'}});}}
