import {requireAdmin} from '@/lib/auth';
export default async function Page(){await requireAdmin();return <><h1>Раздел пока не перенесён в R4</h1><p>Доступ к прежнему backend отключён. Этот раздел не входит в подтверждённые возможности кандидата.</p></>;}
