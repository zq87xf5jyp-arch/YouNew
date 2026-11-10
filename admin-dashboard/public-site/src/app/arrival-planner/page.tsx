import Link from "next/link";
import { ArrowRight, CalendarDays, Download, FileText, ShieldCheck } from "lucide-react";
import { PageShell } from "@/components/page-shell";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Arrival Planner — a plan you can take with you", "An editable offline planner for your own tasks, dates and notes. One household, one payment, no subscription.", "/arrival-planner");

export default function ArrivalPlannerPage() {
  const sandboxOpen = process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_MODE === "sandbox" && process.env.NEXT_PUBLIC_ARRIVAL_COMMERCE_ENABLED === "true" && process.env.NEXT_PUBLIC_ARRIVAL_CHECKOUT_ENABLED === "true";
  return <PageShell className="business-page pilot-offer-page">
    <section className="pilot-hero pilot-detail-hero section-shell">
      <div className="pilot-hero-copy">
        <Breadcrumbs items={[{ label: "Arrival Planner" }]} />
        <p className="section-label orange">Arrival Planner · Household Edition</p>
        <h1>Your next steps. In a plan you control.</h1>
        <p className="pilot-lead">Download a ready-made HTML planner with five starting prompts, then edit your own tasks, notes and dates. Save a copy, print your plan or add the dates you choose to your calendar.</p>
        <div className="pilot-price-line"><strong>€14.99 test amount · no real charge</strong><span>Real sales are not open. The final sales price and tax treatment are not set. The planned product is a one-time purchase with no subscription or automatic renewal.</span></div>
        {sandboxOpen ? <p className="business-truth-note" role="status">Sandbox preview only. Checkout uses test payments; no real purchase or charge is made.</p> : null}
        <div className="hero-actions">{sandboxOpen ? <Link className="button button-primary" href="/arrival-planner/account/">Open test account<ArrowRight aria-hidden /></Link> : <a className="button button-primary" href={`mailto:support@younew.nl?subject=${encodeURIComponent("Arrival Planner feedback — €14.99 test amount")}`}>Tell us if this would help<ArrowRight aria-hidden /></a>}<a className="button button-outline" href="#planner-included">See what is included</a></div>
        {!sandboxOpen ? <p className="mt-4 text-sm">Feedback is optional and opens your email app. It does not place an order. <Link className="underline" href="/arrival-planner/account/">View purchase status</Link>.</p> : null}
      </div>
      <aside className="pilot-process-card"><span>A portable planning tool</span><ol>
        <li><b>1</b><div><strong>Edit the template</strong><p>Choose tasks and write your own notes and dates.</p></div></li>
        <li><b>2</b><div><strong>Keep a copy</strong><p>Download the HTML tool and save your plan as JSON.</p></div></li>
        <li><b>3</b><div><strong>Use your plan</strong><p>Restore a saved plan, print it or export calendar events.</p></div></li>
      </ol></aside>
    </section>
    <section className="business-section section-shell" aria-labelledby="planner-preview-title">
      <div className="section-intro"><p className="section-label cyan">A look inside</p><h2 id="planner-preview-title">A starting point you can change.</h2><p>Three of the five starting prompts in the downloadable HTML file. This is a static preview; you edit the downloaded tool yourself. Dates and notes start empty.</p></div>
      <div className="mt-8 grid gap-4" aria-label="Example planning tasks">
        {[
          { title: "Choose my registration steps", href: "/search/?q=BSN%20documents", guide: "Registration and documents" },
          { title: "Plan my housing search", href: "/search/?q=housing", guide: "Housing" },
          { title: "Research my healthcare next steps", href: "/search/?q=healthcare%20GP", guide: "Healthcare" },
        ].map(task => <article className="pilot-scope-panel grid gap-5 md:grid-cols-3" key={task.title}><div><p className="text-sm">My task</p><h3 className="text-lg font-semibold">{task.title}</h3><Link className="mt-2 inline-block underline" href={task.href}>Free guide: {task.guide}</Link></div><div><p className="text-sm">My chosen date</p><p className="mt-2">Not set · choose your own date</p></div><div><p className="text-sm">My notes</p><p className="mt-2">Empty · add what matters to you</p></div></article>)}
      </div>
    </section>
    <section className="business-section section-shell" id="planner-included" aria-labelledby="planner-included-title">
      <div className="section-intro"><p className="section-label cyan">Included</p><h2 id="planner-included-title">One tool for your household</h2></div>
      <div className="business-card-grid pilot-card-grid">
        <article><FileText aria-hidden /><h3>Editable tasks and notes</h3><p>Add, change and complete your own tasks. Example tasks help you begin; they do not decide what applies to you.</p></article>
        <article><Download aria-hidden /><h3>Offline copy and restore</h3><p>Edit the downloaded HTML tool offline without a YouNew cloud account. Save and restore your work with a JSON file you keep. Guide links need an internet connection.</p></article>
        <article><CalendarDays aria-hidden /><h3>Your dates, your calendar</h3><p>Export unfinished tasks with dates as all-day events in an .ics file, with an optional reminder one day before. You choose the dates; they are not official deadlines. Your calendar app controls alerts.</p></article>
        <article><FileText aria-hidden /><h3>Print or save a PDF</h3><p>Use your browser’s print controls to keep a readable paper or PDF version. No separate PDF subscription.</p></article>
      </div>
      <aside className="business-truth-note"><ShieldCheck aria-hidden /><div><strong>The information stays free</strong><p>You pay for the editable planning and export tool. Free guidance, emergency information, official links and existing free app features remain available. The tool does not provide individual legal, medical, tax or immigration advice.</p></div></aside>
    </section>
    <section className="business-section section-shell pilot-scope-grid" aria-label="Purchase details">
      <article className="pilot-scope-panel"><h2>Personal use, no recurring charge</h2><p>Proposed licence: personal, non-commercial use by one household, including copies on your own devices and backups. You may share your own exported plan. The toolkit itself is not for resale or public redistribution.</p><p>Open the HTML tool in a modern desktop browser. Email previews and native iOS file viewers are not supported tool environments.</p><p>No custom work, cloud sync, new-feature subscription or continuously updated advice is included. Final terms and tested browser support must be available before purchase. Your statutory consumer rights are unaffected.</p></article>
      <article className="pilot-scope-panel"><h2>Purchase and help</h2><p>When sales open, a confirmed payment will make the download available in your account. Returning from checkout alone is not payment confirmation. Your account will show purchase and refund notices.</p><p>For an existing purchase, sign in to check its status and download the original HTML file again. Restore your own edits from your saved JSON backup. Refund requests are reviewed against the applicable purchase terms and consumer rights; no blanket “non-refundable” promise applies.</p><p><a href="mailto:support@younew.nl">Contact support@younew.nl</a>. Do not send passwords, payment-card details or identity documents.</p></article>
    </section>
    <section className="business-section section-shell pilot-final-cta"><div><p className="section-label cyan">Keep exploring</p><h2>Useful guidance comes first.</h2><p>Use YouNew’s free routes and optional iPhone app whether or not you buy a planner.</p></div><Link className="button button-outline" href="/app/">Explore the free app <ArrowRight aria-hidden /></Link></section>
  </PageShell>;
}
