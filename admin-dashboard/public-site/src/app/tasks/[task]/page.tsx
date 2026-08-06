import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import type { LucideIcon } from "lucide-react";
import {
  ArrowRight,
  BriefcaseBusiness,
  CheckCircle2,
  ExternalLink,
  FileText,
  GraduationCap,
  HeartHandshake,
  HeartPulse,
  Home,
  LifeBuoy,
  MapPin,
  PawPrint,
  Search,
  ShieldCheck,
  ShoppingBasket,
  Sparkles,
  Users
} from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import {
  getYouNewTask,
  type ProductValue,
  type TaskIconName,
  youNewTasks
} from "@/lib/product/task-taxonomy";
import { metadataForPage } from "@/lib/seo/metadata";

export const dynamicParams = false;

const icons: Record<TaskIconName, LucideIcon> = {
  home: Home,
  work: BriefcaseBusiness,
  healthcare: HeartPulse,
  documents: FileText,
  study: GraduationCap,
  "daily-life": ShoppingBasket,
  emergency: LifeBuoy,
  lgbtiq: HeartHandshake,
  pets: PawPrint,
  family: Users
};

const valueLabels: Record<ProductValue, string> = {
  answer: "Clear answer",
  checklist: "Checklist",
  decision: "Decision support",
  "official-source": "Official source",
  "saved-item": "Saveable result"
};

const localCities = ["Amsterdam", "Rotterdam", "The Hague", "Utrecht", "Groningen"] as const;

export function generateStaticParams() {
  return youNewTasks.filter((task) => task.id !== "emergency").map((task) => ({ task: task.id }));
}

export async function generateMetadata({ params }: { params: Promise<{ task: string }> }): Promise<Metadata> {
  const task = getYouNewTask((await params).task);
  return task ? metadataForPage(`${task.label} in the Netherlands`, task.description, `/tasks/${task.id}`) : {};
}

export default async function TaskHubPage({ params }: { params: Promise<{ task: string }> }) {
  const task = getYouNewTask((await params).task);
  if (!task || task.urgent) notFound();
  const Icon = icons[task.icon];

  return (
    <PageShell className="task-hub-page">
      <article className="task-hub" aria-labelledby="task-hub-title">
        <header className="task-hub-hero">
          <div className="section-shell">
            <Breadcrumbs items={[{ label: "Tasks", href: "/#needs-title" }, { label: task.label }]} />
            <div className="task-hub-heading">
              <span className="task-hub-icon"><Icon aria-hidden /></span>
              <div>
                <p className="task-hub-kicker">Choose one situation</p>
                <h1 id="task-hub-title">{task.label} in the Netherlands</h1>
                <p>{task.description}</p>
              </div>
            </div>
            <aside className="task-value-contract" aria-label="What this route gives you">
              <strong>You leave this route with</strong>
              <ul>{task.value.map((value) => <li key={value}><CheckCircle2 aria-hidden />{valueLabels[value]}</li>)}</ul>
              <p>{task.outcome}</p>
            </aside>
          </div>
        </header>

        <section className="section-shell task-clarification" aria-labelledby="clarification-title">
          <div className="task-section-heading">
            <p>Clarification</p>
            <h2 id="clarification-title">What are you trying to do?</h2>
            <span>Choose the closest option. The next page gives one verified national route instead of another catalogue.</span>
          </div>
          <div className="task-choice-grid">
            {task.clarifications.map((choice, index) => (
              <Link href={choice.href} className="task-choice" key={choice.id}>
                <span className="task-choice-number">{String(index + 1).padStart(2, "0")}</span>
                <div><h3>{choice.label}</h3><p>{choice.description}</p><strong>{choice.result}</strong></div>
                <ArrowRight aria-hidden />
              </Link>
            ))}
          </div>
        </section>

        <section className="task-local-band" aria-labelledby="local-title">
          <div className="section-shell task-local-grid">
            <div>
              <p className="task-hub-kicker"><MapPin aria-hidden /> Optional local context</p>
              <h2 id="local-title">Add your city after choosing the national route</h2>
              <p>YouNew keeps the national answer visible. Local results are added only when published evidence is available.</p>
            </div>
            <nav aria-label={`Local ${task.label} search shortcuts`}>
              {localCities.map((city) => (
                <Link href={`/search/?q=${encodeURIComponent(`${task.label} ${city}`)}`} key={city}>{city}<Search aria-hidden /></Link>
              ))}
              <Link href={`/search/?q=${encodeURIComponent(task.label)}`}>Another city<Search aria-hidden /></Link>
            </nav>
          </div>
        </section>

        <section className="section-shell task-help-grid" aria-label="Help choosing and trust boundaries">
          <article className="task-naruto-help">
            <Sparkles aria-hidden />
            <div><p className="task-hub-kicker">Not sure which option fits?</p><h2>Ask Naruto to clarify your situation</h2><p>Naruto asks a short follow-up question, then sends you to a published route. It does not replace official responsibility.</p><Link href={`/naruto/?q=${encodeURIComponent(`I need help with ${task.label.toLowerCase()}`)}`}>Start clarification <ArrowRight aria-hidden /></Link></div>
          </article>
          <article className="task-trust-boundary">
            <ShieldCheck aria-hidden />
            <div><p className="task-hub-kicker">Trust boundary</p><h2>National first, local when verified</h2><p>Important requirements must be confirmed on the responsible authority’s website. YouNew does not invent local providers, eligibility, prices or deadlines.</p><Link href="/status/">How verification works <ExternalLink aria-hidden /></Link></div>
          </article>
        </section>
      </article>
    </PageShell>
  );
}
