import { PageShell } from "@/components/page-shell";
import { ArrivalPlannerAccount } from "@/components/arrival-planner-account";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = { ...metadataForPage("Arrival Planner account", "Private local arrival-planner account settings.", "/arrival-planner/account", { noIndex: true, follow: false }), referrer: "no-referrer" as const };

export default function ArrivalPlannerAccountPage() {
  return <PageShell className="business-page"><section className="business-section section-shell"><ArrivalPlannerAccount /></section></PageShell>;
}
