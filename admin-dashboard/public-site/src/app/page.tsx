"use client";

import { useState } from "react";

const releaseUpdatesUrl = "/support";

const situations = [
  {
    icon: "🚶",
    title: "First-time newcomer",
    desc: "Registration, DigiD, health insurance, housing - every step in the right order.",
    accent: "#22C55E",
    bg: "rgba(34,197,94,0.12)"
  },
  {
    icon: "🛡️",
    title: "Refugee & asylum seeker",
    desc: "Status, gemeente support, legal resources, and community organisations.",
    accent: "#3B82F6",
    bg: "rgba(59,130,246,0.12)"
  },
  {
    icon: "💼",
    title: "Expat & knowledge worker",
    desc: "Work, housing, banking and tax basics for highly skilled migrants.",
    accent: "#F59E0B",
    bg: "rgba(245,158,11,0.12)"
  },
  {
    icon: "🎓",
    title: "International student",
    desc: "Student visa, housing, OV-chipkaart, health coverage and university registration.",
    accent: "#8B5CF6",
    bg: "rgba(139,92,246,0.12)"
  }
];

const features = [
  {
    icon: "🗺️",
    title: "City Explorer",
    desc: "Guides for Amsterdam, Rotterdam, The Hague, Utrecht, Leiden and more - history, transport and services."
  },
  {
    icon: "📄",
    title: "Paperwork Guide",
    desc: "Understand BSN, DigiD, residence documents, municipalities and government services."
  },
  {
    icon: "✨",
    title: "AI Navigator",
    desc: "Ask practical questions about life in the Netherlands and get plain-language explanations."
  },
  {
    icon: "📚",
    title: "History & Culture",
    desc: "Learn Dutch society, daily systems, culture, official resources and useful local context."
  }
];

const cities = [
  { icon: "🏙️", name: "Amsterdam", tags: ["Capital", "Canals", "Art"], statA: "935K", labelA: "population", statB: "165", labelB: "nationalities", bg: "linear-gradient(135deg, #1e3a5f, #0e2040)" },
  { icon: "🚢", name: "Rotterdam", tags: ["Port", "Architecture"], statA: "660K", labelA: "population", statB: "#1", labelB: "EU port", bg: "linear-gradient(135deg, #1a3a2a, #0e2518)" },
  { icon: "⚖️", name: "Den Haag", tags: ["Government", "Diplomacy"], statA: "550K", labelA: "population", statB: "154", labelB: "embassies", bg: "linear-gradient(135deg, #2a1a3a, #1a0e2a)" },
  { icon: "🎓", name: "Leiden", tags: ["University", "Science"], statA: "30K", labelA: "students", statB: "16", labelB: "Nobel prizes", bg: "linear-gradient(135deg, #2a2a1a, #1a1a0e)" }
];

const categories = [
  ["💼", "Work", "Contracts, rights", "rgba(59,130,246,0.15)"],
  ["🎓", "Study", "Uni, courses", "rgba(34,197,94,0.15)"],
  ["🏠", "Housing", "Rent, buying", "rgba(139,92,246,0.15)"],
  ["📄", "Documents", "BSN, DigiD", "rgba(232,98,42,0.15)"],
  ["🩺", "Healthcare", "GP, insurance", "rgba(20,184,166,0.15)"],
  ["🚌", "Transport", "OV, bike", "rgba(245,158,11,0.15)"],
  ["🔒", "Legal & Safety", "Rights, police", "rgba(239,68,68,0.15)"],
  ["🌍", "Integration", "Language, culture", "rgba(14,165,233,0.15)"],
  ["🌈", "LGBTQ+", "Rights, resources", "rgba(168,85,247,0.15)"],
  ["👨‍👩‍👧", "Family", "Children, schools", "rgba(251,146,60,0.15)"]
];

const aiAnswers: Record<string, string> = {
  "How do I find a GP? 🏥": "Register with a huisarts (GP) near your home address. Search through official or insurer-supported directories, then verify availability directly with the practice.",
  "How do I register my address? 📍": "Visit your local gemeente for BRP registration with your passport and proof of address. Requirements differ by municipality, so verify the appointment checklist first.",
  "What is DigiD? 🔐": "DigiD is your digital identity for Dutch government services. You use it for tax, healthcare and official portals. Apply through the official DigiD website.",
  "What to do after arrival? 🛬": "Start with municipality registration for BSN, arrange health insurance if required, open practical services, apply for DigiD, and save official source links."
};

export default function HomePage() {
  const [question, setQuestion] = useState("How do I get my BSN number?");
  const [answer, setAnswer] = useState(
    "You register at your local gemeente (municipality) in person. Bring a valid passport and proof of address. You receive your BSN during or after registration, depending on the municipality."
  );

  function choosePrompt(prompt: string) {
    setQuestion(prompt.replace(/[🏥📍🔐🛬]/g, "").trim() + "?");
    setAnswer(aiAnswers[prompt] ?? "Open AI Navigator in the app for a full answer with official source links.");
  }

  return (
    <main className="yn-landing">
      <nav className="yn-nav">
        <a href="#top" className="nav-logo" aria-label="YouNew.nl home">
          <div className="nav-logo-icon">🏛️</div>
          <div>
            <div className="nav-logo-text">YouNew.nl</div>
            <div className="nav-logo-sub">Premium Netherlands Guide</div>
          </div>
        </a>
        <div className="nav-public-links" aria-label="Public information">
          <a href="/privacy">Privacy</a>
          <a href="/terms">Terms</a>
          <a href="/support">Support</a>
        </div>
        <a href={releaseUpdatesUrl} className="nav-cta">Release Updates →</a>
      </nav>

      <section className="hero" id="top">
        <div className="hero-glow" />
        <div className="hero-glow2" />
        <div className="hero-eyebrow"><span className="live-dot" /> Your practical guide to the Netherlands 🇳🇱</div>
        <h1 className="fade-up">Useful tools and trusted information<br />for <span>life in the Netherlands</span></h1>
        <p className="hero-sub fade-up-2">From BSN registration to finding a GP - YouNew organizes practical newcomer steps, source links, and local guidance in your language.</p>
        <div className="hero-btns fade-up-3">
          <a href="#download" className="btn-primary">→ Get Release Updates</a>
          <a href="#features" className="btn-secondary">See How It Works</a>
        </div>
        <PhoneMockup />
      </section>

      <section className="stats-section" aria-label="App highlights">
        <div className="stats-inner">
          <div className="stats-grid">
            <StatTile value="50+" label="Topic guides" />
            <StatTile value="12" label="Cities covered" />
            <StatTile value="Official" label="Source links" />
            <StatTile value="1 tap" label="To your path" />
          </div>
        </div>
      </section>

      <section className="section" id="features">
        <div className="section-label">Start by situation</div>
        <h2 className="section-title">Where are you in your journey?</h2>
        <p className="section-sub">YouNew knows your situation is not generic. Pick the path that fits you - the app adapts guidance to your needs.</p>
        <div className="situation-grid">
          {situations.map((item) => (
            <article className="sit-card" key={item.title} style={{ "--accent-color": item.accent, "--icon-bg": item.bg } as React.CSSProperties}>
              <div className="sit-card-icon">{item.icon}</div>
              <div className="sit-card-title">{item.title}</div>
              <div className="sit-card-desc">{item.desc}</div>
              <div className="sit-card-arrow">→</div>
            </article>
          ))}
        </div>
      </section>

      <section className="features-bg">
        <div className="features-inner">
          <div className="section-label">Built for life here</div>
          <h2 className="section-title">Everything in one app</h2>
          <div className="features-grid">
            {features.map((feature) => (
              <article className="feature-tile" key={feature.title}>
                <div className="feature-icon">{feature.icon}</div>
                <div className="feature-title">{feature.title}</div>
                <div className="feature-desc">{feature.desc}</div>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="ai-section">
        <div>
          <div className="section-label">AI Navigator</div>
          <h2 className="section-title">Ask anything about life in the Netherlands</h2>
          <p className="section-sub">The AI Navigator is built for newcomers. It answers in plain language - not bureaucratic Dutch - and should point you back to official sources.</p>
          <p className="ai-note">Information only. Always verify important decisions with official sources.</p>
        </div>
        <div className="ai-card">
          <div className="ai-header">
            <div className="ai-avatar">✨</div>
            <div>
              <div className="ai-name">AI Navigator</div>
              <div className="ai-tagline">Ask anything about life in the Netherlands</div>
            </div>
          </div>
          <div className="chat-bubble user">{question}</div>
          <div className="chat-bubble">{answer} <a href="#download">→ Official sources in the app</a></div>
          <div className="ai-prompts">
            {Object.keys(aiAnswers).map((prompt) => (
              <button className="ai-prompt" key={prompt} onClick={() => choosePrompt(prompt)}>{prompt}</button>
            ))}
          </div>
          <div className="ai-disclaimer"><span>🛡️</span><span>Information only. Always verify with official sources.</span></div>
        </div>
      </section>

      <section className="cities-bg">
        <div className="cities-inner">
          <div className="section-label">City Guides</div>
          <h2 className="section-title">Explore Dutch cities & provinces</h2>
          <p className="section-sub">Every major city has practical guidance - not just a map, but context for the place where you are building your life.</p>
          <div className="cities-grid">
            {cities.map((city) => (
              <article className="city-card" key={city.name}>
                <div className="city-thumb" style={{ background: city.bg }}>{city.icon}</div>
                <div className="city-body">
                  <div className="city-name">{city.name}</div>
                  <div className="city-tags">
                    {city.tags.map((tag) => <span className="city-tag" key={tag}>{tag}</span>)}
                  </div>
                  <div className="city-stats">
                    <div className="city-stat"><strong>{city.statA}</strong><span>{city.labelA}</span></div>
                    <div className="city-stat"><strong>{city.statB}</strong><span>{city.labelB}</span></div>
                  </div>
                </div>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="section">
        <div className="section-label">All Categories</div>
        <h2 className="section-title">Help & Life in the Netherlands</h2>
        <p className="section-sub">From your first week to years later - every practical part of Dutch life, organized.</p>
        <div className="cats-grid">
          {categories.map(([icon, name, sub, bg]) => (
            <article className="cat-card" key={name}>
              <div className="cat-card-icon" style={{ background: bg }}>{icon}</div>
              <div className="cat-card-name">{name}</div>
              <div className="cat-card-sub">{sub}</div>
            </article>
          ))}
        </div>
      </section>

      <section className="cta-section" id="download">
        <div className="cta-inner">
          <div className="cta-icon">🚀</div>
          <h2>Your journey starts here</h2>
          <p>Follow YouNew release updates and get notified when app store and beta access channels are ready.</p>
          <div className="store-btns">
            <a href={releaseUpdatesUrl} className="store-btn">
              <span className="store-icon"></span>
              <span><small>iPhone release</small><strong>Follow Updates</strong></span>
            </a>
            <a href={releaseUpdatesUrl} className="store-btn outline">
              <span className="store-icon">▶</span>
              <span><small>Android release</small><strong>Follow Updates</strong></span>
            </a>
            <a href={releaseUpdatesUrl} className="store-btn outline">
              <span className="store-icon">✈</span>
              <span><small>Beta access</small><strong>Contact Support</strong></span>
            </a>
          </div>
        </div>
      </section>

      <footer className="yn-footer">
        <div><strong>YouNew.nl</strong> - Premium Netherlands Guide 🇳🇱</div>
        <div>Your Guide to the Netherlands · Information only. Always verify with official sources.</div>
        <nav className="yn-footer-links" aria-label="Legal and support">
          <a href="/privacy">Privacy Policy</a>
          <a href="/terms">Terms of Use</a>
          <a href="/support">Support</a>
          <a href="mailto:support@younew.nl">support@younew.nl</a>
        </nav>
      </footer>
    </main>
  );
}

function StatTile({ value, label }: { value: string; label: string }) {
  return (
    <div className="stat-tile">
      <div className="stat-num">{value}</div>
      <div className="stat-lbl">{label}</div>
    </div>
  );
}

function PhoneMockup() {
  return (
    <div className="phone-wrap fade-up-3" aria-label="YouNew.nl app preview">
      <div className="phone">
        <div className="phone-screen-flat">
          <div className="phone-status"><span>9:41</span><span>●●●</span></div>
          <div className="phone-header">
            <div className="phone-logo">🏛️</div>
            <div>
              <div className="phone-logo-text">YouNew.nl</div>
              <div className="phone-logo-sub">Premium Netherlands Guide</div>
            </div>
          </div>
          <div className="phone-hero-banner">YouNew.nl: Your<br />Guide to the Netherlands 🇳🇱</div>
          <div className="phone-row-label"><span>Start by situation</span><span>The right path in 1 tap</span></div>
          <div className="phone-situations">
            <div className="phone-sit-card"><div className="sit-icon">🚶</div><div>First-time newcomer</div><div className="sit-desc">Registration, DigiD, care, housing</div></div>
            <div className="phone-sit-card"><div className="sit-icon">🛡️</div><div>Refugee</div><div className="sit-desc">Status, gemeente, support</div></div>
          </div>
          <div className="phone-help-label">What can YouNew help with?</div>
          <div className="phone-cats">
            {[
              ["💼", "Work", "rgba(59,130,246,0.2)"],
              ["🎓", "Study", "rgba(34,197,94,0.2)"],
              ["🏠", "Housing", "rgba(139,92,246,0.2)"],
              ["📄", "Docs", "rgba(232,98,42,0.2)"],
              ["🩺", "Health", "rgba(20,184,166,0.2)"]
            ].map(([icon, label, bg]) => (
              <div className="phone-cat" key={label}>
                <div className="cat-icon" style={{ background: bg }}>{icon}</div>
                <div className="cat-lbl">{label}</div>
              </div>
            ))}
          </div>
          <div className="phone-nav">
            <div className="nav-item active"><span>🏠</span>Home</div>
            <div className="nav-item"><span>🔍</span>Search</div>
            <div className="nav-item"><span>🗺️</span>Map</div>
            <div className="nav-item"><span>🔖</span>Saved</div>
            <div className="nav-item"><span>✨</span>AI</div>
          </div>
        </div>
      </div>
    </div>
  );
}
