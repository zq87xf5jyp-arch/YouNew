export type CuratedSummaryFact = Readonly<{
  id: "who" | "bring" | "timing" | "cost";
  label: string;
  value: string;
  detail: string;
}>;

export type CuratedSummaryStep = Readonly<{ id: string; title: string; body: string }>;
export type CuratedSummarySection = Readonly<{ id: string; title: string; body: string }>;

export type CuratedSummaryGuide = Readonly<{
  title: string;
  context: string;
  answer: string;
  checkedAt: string;
  sourcePublisher: string;
  sourceTitle: string;
  sourceUrl: string;
  primaryActionLabel: string;
  facts: readonly CuratedSummaryFact[];
  steps: readonly CuratedSummaryStep[];
  otherSituations: readonly CuratedSummarySection[];
  faq: readonly CuratedSummarySection[];
}>;

const summaries: Readonly<Record<string, CuratedSummaryGuide>> = Object.freeze({
  "government_service.driving-licence-amsterdam": {
    title: "Driving licence in Amsterdam",
    context: "Amsterdam · Government service",
    answer: "Apply for or renew a Dutch driving licence through the City of Amsterdam. You must be registered in Amsterdam and have lived in the Netherlands for at least 185 days.",
    checkedAt: "2026-08-01",
    sourcePublisher: "City of Amsterdam",
    sourceTitle: "Apply for a Dutch driving licence",
    sourceUrl: "https://www.amsterdam.nl/en/civil-affairs/applying-dutch-driving-licence/",
    primaryActionLabel: "Apply or renew on Amsterdam.nl",
    facts: [
      {
        id: "who",
        label: "Who",
        value: "Amsterdam residents",
        detail: "You must be registered as an Amsterdam resident and have been registered in the Netherlands for at least 185 days."
      },
      {
        id: "bring",
        label: "Bring",
        value: "Photo + current licence",
        detail: "Bring a compliant passport photo and your current Dutch driving licence. Some applicants also need a valid residence permit or a Certificate of Fitness."
      },
      {
        id: "timing",
        label: "Timing",
        value: "Collect after 1 week",
        detail: "The standard collection time is one week. An urgent application submitted before 14:00 can normally be collected after 10:00 on the next working day."
      },
      {
        id: "cost",
        label: "Cost",
        value: "€53.65",
        detail: "The municipal fee is €53.65. An urgent application costs €93.30. These amounts were checked on 1 August 2026 and can change."
      }
    ],
    steps: [
      {
        id: "choose-route",
        title: "Choose the right application route",
        body: "Apply in person for a first licence or most replacements. If you are renewing and meet the RDW conditions, you can renew online and collect the licence from a City Office."
      },
      {
        id: "prepare-documents",
        title: "Prepare your documents",
        body: "Take a compliant passport photo and your current licence. Check the official page for residence-permit and Certificate of Fitness requirements that may apply to you."
      },
      {
        id: "visit-office",
        title: "Visit a City Office or renew online",
        body: "You do not need an appointment at Amsterdam City Offices. In Weesp, an appointment is required. Pay the current fee when you apply."
      },
      {
        id: "collect-licence",
        title: "Collect your licence",
        body: "Collect the licence after the stated processing time. Check the City of Amsterdam page before travelling in case the process or opening arrangements changed."
      }
    ],
    otherSituations: [
      {
        id: "foreign-exchange",
        title: "Exchange a foreign driving licence",
        body: "Foreign-licence exchanges have separate eligibility, documents and processing rules. Use the dedicated City of Amsterdam exchange procedure."
      },
      {
        id: "lost-stolen",
        title: "Lost or stolen licence",
        body: "Report a lost or stolen Dutch driving licence through RDW or at a City Office before applying for a replacement."
      }
    ],
    faq: [
      { id: "appointment", title: "Do I need an appointment?", body: "Not at Amsterdam City Offices for this service. An appointment is required in Weesp." },
      { id: "online-renewal", title: "Can I renew online?", body: "Yes, when you meet RDW's online-renewal conditions. RDW will tell you when the new licence can be collected." }
    ]
  }
});

export function curatedSummaryGuideFor(entityId: string): CuratedSummaryGuide | null {
  return summaries[entityId] ?? null;
}
