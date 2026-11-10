import Link from "next/link";
import { BellRing } from "lucide-react";
import { updateBusinessInquiryNotification } from "@/app/(admin)/business-inquiries/actions";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export type BusinessInquiryNotificationStatus = "unread" | "read" | "archived";

export type BusinessInquiryNotificationRow = {
  id: string;
  inquiry_id: string;
  reference_code: string;
  notification_kind: "business_inquiry_created";
  status: BusinessInquiryNotificationStatus;
  created_at: string;
  read_at: string | null;
  read_by: string | null;
};

const statusLabels: Record<BusinessInquiryNotificationStatus, string> = {
  unread: "Новое",
  read: "Прочитано",
  archived: "В архиве"
};

export function BusinessInquiryNotificationInbox({
  notifications,
  available
}: {
  notifications: BusinessInquiryNotificationRow[];
  available: boolean;
}) {
  const visible = notifications.filter((notification) => notification.status !== "archived");
  const unread = visible.filter((notification) => notification.status === "unread").length;

  return (
    <Card className="mb-6 scroll-mt-24" id="notifications">
      <CardHeader>
        <div className="flex flex-wrap items-start gap-3">
          <BellRing className="mt-1 size-5 text-cyan-200" aria-hidden="true" />
          <div>
            <CardTitle>Внутренние уведомления</CardTitle>
            <CardDescription>
              {available
                ? `Среди последних ${notifications.length} уведомлений: ${unread} непрочитанных · время Амстердама · только безопасный номер заявки и время, без контактных данных или сообщения.`
                : "Inbox ещё не доступен в подключённом Supabase; внешние email/webhook не отправляются."}
            </CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        {visible.length > 0 ? (
          <ul className="divide-y divide-border" aria-label="Новые бизнес-заявки">
            {visible.map((notification) => (
              <li className="flex flex-wrap items-center gap-3 py-3" key={notification.id}>
                <Badge variant={notification.status === "unread" ? "warning" : "secondary"}>
                  {statusLabels[notification.status]}
                </Badge>
                <Link className="font-mono text-sm text-cyan-200 hover:underline" href={`/business-inquiries/${notification.inquiry_id}`}>
                  {notification.reference_code}
                </Link>
                <time className="text-xs text-muted-foreground" dateTime={notification.created_at}>
                  {new Intl.DateTimeFormat("nl-NL", { dateStyle: "medium", timeStyle: "short", timeZone: "Europe/Amsterdam" }).format(new Date(notification.created_at))}
                </time>
                <form action={updateBusinessInquiryNotification} className="ml-auto">
                  <input name="id" type="hidden" value={notification.id} />
                  <input name="status" type="hidden" value={notification.status === "unread" ? "read" : "archived"} />
                  <Button size="sm" type="submit" variant="outline">
                    {notification.status === "unread" ? "Отметить прочитанным" : "Архивировать"}
                  </Button>
                </form>
              </li>
            ))}
          </ul>
        ) : (
          <p className="text-sm text-muted-foreground">
            {available ? "Новых внутренних уведомлений нет." : "После применения проверенной миграции новые заявки появятся здесь."}
          </p>
        )}
      </CardContent>
    </Card>
  );
}
