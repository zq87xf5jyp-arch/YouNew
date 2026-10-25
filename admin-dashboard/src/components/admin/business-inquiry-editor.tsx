"use client";
import { useState, useTransition, type FormEvent } from "react";
import { updateBusinessInquiry } from "@/app/(admin)/business-inquiries/actions";
import { inquiryLabels, type InquiryUpdate } from "@/lib/business-inquiry-compatibility";
import { BUSINESS_INQUIRY_LOST_REASON_LABELS, BUSINESS_INQUIRY_OFFER_LABELS, BUSINESS_INQUIRY_WON_EVIDENCE_LABELS } from "@/lib/business-inquiry-pipeline";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

function draftFrom(row: InquiryUpdate): Record<string, string> {
  return { status: row.status, internalNote: row.admin_notes ?? "", ...(row.schema === "pipeline-v2" ? {
    contactRole: row.contact_role ?? "", offerInterest: row.offer_interest,
    lostReason: row.lost_reason ?? "", lostReasonDetail: row.lost_reason_detail ?? "",
    wonEvidenceType: row.won_evidence_type ?? "", wonEvidenceDate: row.won_evidence_at?.slice(0, 10) ?? ""
  } : {}) };
}
export function BusinessInquiryEditor({ initial, maximumEvidenceDate }: { initial: InquiryUpdate; maximumEvidenceDate: string }) {
  const [saved, setSaved] = useState(initial);
  const [draft, setDraft] = useState(() => draftFrom(initial));
  const [notice, setNotice] = useState<{ ok: boolean; text: string } | null>(null);
  const [pending, startTransition] = useTransition();
  const labels = inquiryLabels(initial.schema);
  function change(name: string, value: string) { setDraft(current => ({ ...current, [name]: value })); setNotice(null); }
  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); const data = new FormData(event.currentTarget); setNotice(null);
    startTransition(async () => {
      try {
        const result = await updateBusinessInquiry(data);
        if (!result.ok) { setNotice({ ok: false, text: result.message }); return; }
        setSaved(result.row); setDraft(draftFrom(result.row)); setNotice({ ok: true, text: "Статус и поля заявки подтверждены источником." });
      } catch { setNotice({ ok: false, text: "Сохранение не подтверждено. Черновик оставлен в форме; проверьте вход и перечитайте заявку перед повторной попыткой." }); }
    });
  }
  function select(name: string, label: string, options: Readonly<Record<string, string>>, empty = false) {
    return <div className="space-y-2"><Label htmlFor={name}>{label}</Label><select id={name} name={name} value={draft[name]} disabled={pending} onChange={event => change(name, event.target.value)} className="h-10 w-full rounded-md border border-input bg-secondary/50 px-3 text-sm">{empty ? <option value="">Не выбрано</option> : null}{Object.entries(options).map(([value, title]) => <option key={value} value={value}>{title}</option>)}</select></div>;
  }
  return <form method="post" onSubmit={submit} className="space-y-4" aria-label="Обработка бизнес-заявки">
    <input type="hidden" name="schema" value={initial.schema} /><input type="hidden" name="id" value={initial.id} /><input type="hidden" name="updated_at" value={saved.updated_at} />
    {select("status", "Статус", labels)}
    {initial.schema === "pipeline-v2" ? <>
      <div className="space-y-2"><Label htmlFor="contactRole">Роль контакта</Label><Input id="contactRole" name="contactRole" minLength={2} maxLength={120} value={draft.contactRole} disabled={pending} onChange={event => change("contactRole", event.target.value)} /></div>
      {select("offerInterest", "Интерес к предложению", BUSINESS_INQUIRY_OFFER_LABELS)}
      {select("lostReason", "Причина отказа", BUSINESS_INQUIRY_LOST_REASON_LABELS, true)}
      <p className="text-xs text-muted-foreground">Обязательна для lost. Не выводите причину из молчания до завершения разрешённой серии контактов.</p>
      <div className="space-y-2"><Label htmlFor="lostReasonDetail">Пояснение отказа</Label><Textarea id="lostReasonDetail" name="lostReasonDetail" minLength={5} maxLength={500} value={draft.lostReasonDetail} disabled={pending} onChange={event => change("lostReasonDetail", event.target.value)} /><p className="text-xs text-muted-foreground">Обязательно для «другая причина»; не добавляйте лишние персональные данные.</p></div>
      {select("wonEvidenceType", "Доказательство won", BUSINESS_INQUIRY_WON_EVIDENCE_LABELS, true)}
      <div className="space-y-2"><Label htmlFor="wonEvidenceDate">Дата доказательства won</Label><Input id="wonEvidenceDate" name="wonEvidenceDate" type="date" max={maximumEvidenceDate} value={draft.wonEvidenceDate} disabled={pending} onChange={event => change("wonEvidenceDate", event.target.value)} /><p className="text-xs text-muted-foreground">Для won одновременно обязательны контролируемый тип и дата доказательства.</p></div>
    </> : <p className="text-xs text-muted-foreground">Действующие статусы обработки заявок. «Принята» не означает подтверждённую оплату.</p>}
    <div className="space-y-2"><Label htmlFor="internalNote">Внутренняя заметка</Label><Textarea id="internalNote" name="internalNote" maxLength={2000} value={draft.internalNote} disabled={pending} onChange={event => change("internalNote", event.target.value)} /></div>
    <p className="text-xs text-muted-foreground">Не добавляйте лишние персональные данные. Заметка остаётся в Admin. Перед обновлением страницы скопируйте несохранённый черновик.</p>
    {notice ? <p role={notice.ok ? "status" : "alert"} className={notice.ok ? "text-sm text-emerald-400" : "text-sm text-red-400"}>{notice.text}</p> : null}
    <Button type="submit" disabled={pending}>{pending ? "Сохранение…" : "Сохранить"}</Button>
    <p className="text-xs text-muted-foreground">Сохранённый статус: {labels[saved.status]}. Версия: {saved.updated_at}.</p>
  </form>;
}
