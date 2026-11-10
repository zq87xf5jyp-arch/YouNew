import Link from "next/link";
import { PageShell } from "@/components/page-shell";
import { NlEntityCard } from "@/components/nl-entity-card";
import { getContentEntities } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

const entities = getContentEntities("organization");
export const metadata = metadataForPage("Organisaties", "Bekijk gepubliceerde organisaties met zichtbare bron en controledatum.", "/nl/organisaties", { locale: "nl", noIndex: entities.length === 0, follow: true });
export default function Page() { return <PageShell locale="nl"><section className="app-hero section-shell compact-hero"><p className="section-label cyan">Lokale wegwijzer</p><h1>Organisaties die je verder helpen</h1><p>Zorg, onderwijs en lokale diensten met een zichtbare verantwoordelijke bron en controledatum.</p><div className="dataset-note"><strong>{entities.length}</strong> gepubliceerde organisaties</div></section><section className="section-shell app-content-block"><div className="entity-grid">{entities.map((entity) => <NlEntityCard entity={entity} key={entity.id} />)}</div>{entities.length === 0 ? <div className="empty-state"><h2>Momenteel geen actuele organisatieprofielen</h2><p>Profielen met een verlopen controledatum blijven verborgen totdat de gegevens per veld opnieuw zijn bevestigd. Gebruik intussen de landelijke informatie of meld je organisatie gratis aan.</p><nav className="content-index-tools" aria-label="Alternatieven"><Link className="button button-outline" href="/nl/zoeken/">Zoek actuele informatie</Link><Link className="text-link" href="/nl/categorieen/">Bekijk categorieën</Link><Link className="text-link" href="/nl/voor-bedrijven/aanmelden/">Organisatie aanmelden</Link></nav></div> : null}</section></PageShell>; }
