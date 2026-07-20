import {
  Ambulance,
  BookOpenCheck,
  Bot,
  Building2,
  CircleHelp,
  Files,
  HeartPulse,
  Home,
  Landmark,
  LibraryBig,
  Map,
  MapPin,
  Navigation,
  Route,
  Search,
  ShieldCheck,
  Sparkles,
  Train,
  UsersRound
} from "lucide-react";

export const links = {
  appStore: "/support",
  googlePlay: "/support",
  testFlight: "/support",
  telegram: "/support",
  contactEmail: "support@younew.nl"
};

export const navItems = [
  { href: "/#features", label: "Features" },
  { href: "/#how-it-works", label: "How it works" },
  { href: "/#screenshots", label: "Screenshots" },
  { href: "/#for-users", label: "For users" },
  { href: "/#faq", label: "FAQ" },
  { href: "/support", label: "Support" }
];

export const badges = ["Official-source links", "Smart categories", "AI guidance", "Interactive map"];

export const problemCards = [
  { title: "Too many scattered websites", icon: Search },
  { title: "Hard to understand official documents", icon: Files },
  { title: "Transport systems can be confusing", icon: Train },
  { title: "Local information is difficult to find", icon: MapPin },
  { title: "Rules, fines and services are often unclear", icon: CircleHelp }
];

export const solutionCards = [
  { title: "Categories", icon: LibraryBig },
  { title: "City guides", icon: Building2 },
  { title: "Transport guide", icon: Train },
  { title: "Interactive map", icon: Map },
  { title: "Reference library", icon: BookOpenCheck },
  { title: "AI assistant", icon: Bot },
  { title: "Official links", icon: Landmark },
  { title: "Emergency help", icon: Ambulance }
];

export const features = [
  {
    title: "Smart Categories",
    description: "Browse essential topics like documents, services, transport, housing, healthcare, work, taxes, rules and fines.",
    icon: Sparkles,
    accent: "orange"
  },
  {
    title: "City Guides",
    description: "Explore practical information for Amsterdam, Rotterdam, The Hague, Utrecht, Leiden, Eindhoven, Groningen, Maastricht and more.",
    icon: Building2,
    accent: "cyan"
  },
  {
    title: "Interactive Map",
    description: "Find cities, provinces, useful places and local information through an interactive Netherlands map.",
    icon: Map,
    accent: "cyan"
  },
  {
    title: "Transport Guide",
    description: "Understand NS trains, OVpay, 9292, metro, bus, stations and local transport basics.",
    icon: Train,
    accent: "orange"
  },
  {
    title: "Reference Library",
    description: "Access official links, beginner guides, Dutch terms, fines, letters and source-labeled resources.",
    icon: LibraryBig,
    accent: "cyan"
  },
  {
    title: "AI Assistant",
    description: "Ask plain-language questions and get guidance based on app knowledge and official sources where available.",
    icon: Bot,
    accent: "orange"
  },
  {
    title: "Documents & Services",
    description: "Find information about BSN, DigiD, municipalities, letters, forms and government services.",
    icon: Files,
    accent: "cyan"
  },
  {
    title: "Housing, Healthcare, Work & Taxes",
    description: "Learn practical basics about living, working and taking care of essential responsibilities in the Netherlands.",
    icon: Home,
    accent: "orange"
  }
];

export const steps = [
  {
    title: "Choose your topic",
    description: "Open categories like transport, housing, healthcare, documents or rules."
  },
  {
    title: "Select your city",
    description: "Find local information for your current city or province."
  },
  {
    title: "Read clear explanations",
    description: "Understand practical steps, official links and useful resources."
  },
  {
    title: "Use map or AI assistant",
    description: "Explore nearby information or ask a question in simple language."
  },
  {
    title: "Save what matters",
    description: "Keep useful pages, documents and guides for later."
  }
];

export const screenshotCards = [
  {
    title: "Home screen",
    description: "A guided overview of important Netherlands topics.",
    mode: "home"
  },
  {
    title: "Categories",
    description: "Documents, transport, housing, healthcare and practical life.",
    mode: "categories"
  },
  {
    title: "Smart dashboard",
    description: "Start with the next helpful action for your situation.",
    mode: "dashboard"
  },
  {
    title: "Interactive map",
    description: "Explore cities, provinces and local information visually.",
    mode: "map"
  },
  {
    title: "Transport guide",
    description: "Understand trains, OVpay, 9292 and local movement.",
    mode: "transport"
  },
  {
    title: "Reference library",
    description: "Official links, Dutch terms, fines, letters and guides.",
    mode: "library"
  },
  {
    title: "Netherlands guide",
    description: "Clear practical explanations for life in the Netherlands.",
    mode: "guide"
  },
  {
    title: "AI assistant",
    description: "Ask plain-language questions and get structured answers.",
    mode: "ai"
  }
] as const;

export const userGroups = [
  "Newcomers",
  "Expats",
  "Students",
  "Workers",
  "Residents",
  "Visitors",
  "Families",
  "People relocating to the Netherlands"
];

export const trustCards = [
  { title: "Official source links", icon: ShieldCheck },
  { title: "Clear explanations", icon: BookOpenCheck },
  { title: "Beginner-friendly language", icon: UsersRound },
  { title: "Source-labeled content", icon: Navigation },
  { title: "No unnecessary complexity", icon: Sparkles },
  { title: "Practical Netherlands-focused guidance", icon: Route }
];

export const faqs = [
  {
    question: "What is YouNew.nl?",
    answer: "YouNew.nl is a practical guide for life in the Netherlands. It organizes useful topics, city information, maps, official-source links and simple explanations in one app."
  },
  {
    question: "Who is the app for?",
    answer: "It is built for newcomers, residents, expats, students, workers, visitors, families and people relocating to the Netherlands."
  },
  {
    question: "Is the information official?",
    answer: "The app is an informational guide and points users toward official sources where possible. Important decisions should always be verified with the official organization."
  },
  {
    question: "Can I use it for city information?",
    answer: "Yes. YouNew.nl includes practical city guides and local information for major Dutch cities and provinces."
  },
  {
    question: "Does the app help with transport?",
    answer: "Yes. It explains transport basics such as NS trains, OVpay, 9292, metro, buses, stations and route planning."
  },
  {
    question: "Does the AI assistant replace official advice?",
    answer: "No. The AI assistant provides guidance based on the app's knowledge base and official sources where available. It does not replace legal, medical or financial professionals."
  },
  {
    question: "Is YouNew.nl available on iPhone and Android?",
    answer: "Release channels are being prepared. Follow updates or contact support to hear when iPhone, Android and beta access become available."
  },
  {
    question: "How can I report incorrect information?",
    answer: "Send details to support@younew.nl so the content can be reviewed and improved."
  }
];

export type ScreenshotMode = (typeof screenshotCards)[number]["mode"];
