import {PageHeader} from '@/components/admin/page-header';
import {BusinessInquiryList} from '@/components/admin/business-inquiry-list';
import {BusinessInquiryNotificationInbox} from '@/components/admin/business-inquiry-notification-inbox';
import {listInquiries,notifications} from '@/lib/r4/repository';
import {adaptInquiryList,CURRENT_INQUIRY_SCHEMA} from '@/lib/business-inquiry-compatibility';
export default async function Page(){const checked=adaptInquiryList(await listInquiries(),CURRENT_INQUIRY_SCHEMA);if(checked.issues.length)throw new Error('Data integrity');return <><PageHeader title="Бизнес-заявки" description="Изолированный R4 · синтетические данные · MariaDB. Обработка не отправляет внешние уведомления."/><BusinessInquiryNotificationInbox notifications={await notifications()} available={true}/><BusinessInquiryList schema={CURRENT_INQUIRY_SCHEMA} rows={checked.rows} available={true} integrityIssues={[]}/></>;}
