import {requireAdmin} from '@/lib/auth';
import {notFound} from 'next/navigation';
import {canManageBusinessInquiries} from '@/lib/authorization';
import {PageHeader} from '@/components/admin/page-header';
import {BusinessInquiryList} from '@/components/admin/business-inquiry-list';
import {BusinessInquiryNotificationInbox} from '@/components/admin/business-inquiry-notification-inbox';
import {listInquiries,notifications} from '@/lib/r4/repository';
import {adaptInquiryList,CURRENT_INQUIRY_SCHEMA} from '@/lib/business-inquiry-compatibility';
export default async function Page(){if(!canManageBusinessInquiries((await requireAdmin()).role))notFound();const checked=adaptInquiryList(await listInquiries(),CURRENT_INQUIRY_SCHEMA);if(checked.issues.length)throw new Error('Data integrity');return <><PageHeader title="Бизнес-заявки" description="Обращения с сайта и сохранённая история. Смена статуса не отправляет письмо заявителю."/><BusinessInquiryNotificationInbox notifications={await notifications()} available={true}/><BusinessInquiryList schema={CURRENT_INQUIRY_SCHEMA} rows={checked.rows} available={true} integrityIssues={[]}/></>;}
