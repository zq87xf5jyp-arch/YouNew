import fs from "node:fs/promises";
import path from "node:path";
import { Presentation, PresentationFile } from "@oai/artifact-tool";

const OUT_DIR = "/Users/ivan/Desktop/Developer:YouNew/YouNew/release-artifacts/presentation-2026-07-30";
const ASSET_DIR = path.join(OUT_DIR, "assets");
const RENDER_DIR = path.join(OUT_DIR, "rendered");
const FINAL_PPTX = path.join(OUT_DIR, "YouNew_Product_Ecosystem_Release_2026-07-30.pptx");

const C = {
  bg: "#080B16",
  bg2: "#0D1222",
  surface: "#12192A",
  surface2: "#182238",
  line: "#2A3651",
  white: "#F7F8FC",
  muted: "#AAB4C8",
  orange: "#F47A24",
  orangeSoft: "#FFAD6D",
  cyan: "#62C9D8",
  green: "#3FD58B",
  yellow: "#F4B860",
  red: "#FF6470",
};

const FONT = "Aptos";
const W = 1280;
const H = 720;

async function bytes(file) {
  const b = await fs.readFile(path.join(ASSET_DIR, file));
  return b.buffer.slice(b.byteOffset, b.byteOffset + b.byteLength);
}

function addBox(slide, name, position, fill = C.surface, line = C.line, radius = 20) {
  return slide.shapes.add({
    geometry: "roundRect",
    name,
    position,
    fill,
    line: { style: "solid", fill: line, width: 1 },
    borderRadius: radius,
  });
}

function addText(slide, name, text, position, style = {}) {
  const shape = slide.shapes.add({
    geometry: "textbox",
    name,
    position,
    fill: "none",
    line: { style: "solid", fill: "none", width: 0 },
  });
  shape.text = text;
  shape.text.style = {
    typeface: FONT,
    fontSize: style.fontSize ?? 22,
    bold: style.bold ?? false,
    color: style.color ?? C.white,
    alignment: style.alignment ?? "left",
    verticalAlignment: style.verticalAlignment ?? "top",
    autoFit: style.autoFit ?? "shrinkText",
    insets: style.insets ?? { top: 0, right: 0, bottom: 0, left: 0 },
  };
  return shape;
}

function addEyebrow(slide, text, left = 64, top = 48, width = 440) {
  addText(slide, `eyebrow-${text}`, text.toUpperCase(), { left, top, width, height: 28 }, {
    fontSize: 17,
    bold: true,
    color: C.cyan,
  });
}

function addFooter(slide, page) {
  addText(slide, `footer-left-${page}`, "YouNew · Product ecosystem · 30 July 2026", {
    left: 64,
    top: 682,
    width: 520,
    height: 20,
  }, { fontSize: 14, color: "#74819A" });
  addText(slide, `footer-page-${page}`, String(page).padStart(2, "0"), {
    left: 1174,
    top: 682,
    width: 42,
    height: 20,
  }, { fontSize: 14, bold: true, color: "#74819A", alignment: "right" });
}

async function addImage(slide, name, file, position, options = {}) {
  return slide.images.add({
    blob: await bytes(file),
    contentType: options.contentType ?? "image/png",
    alt: options.alt ?? name,
    fit: options.fit ?? "cover",
    geometry: options.geometry ?? "roundRect",
    borderRadius: options.borderRadius ?? 18,
    crop: options.crop,
    position,
  });
}

async function addFramedImage(slide, name, file, position, options = {}) {
  addBox(slide, `${name}-frame`, {
    left: position.left - 5,
    top: position.top - 5,
    width: position.width + 10,
    height: position.height + 10,
  }, options.frameFill ?? C.surface2, options.frameLine ?? C.line, (options.borderRadius ?? 18) + 4);
  return addImage(slide, name, file, position, options);
}

function notes(slide, sourceLines, context = "") {
  const block = [
    context,
    "",
    "[Sources]",
    ...sourceLines.map((s) => `- ${s}`),
  ].filter((line, index, arr) => !(line === "" && arr[index - 1] === ""));
  slide.speakerNotes.textFrame.setText(block.join("\n"));
  slide.speakerNotes.setVisible(true);
}

function metric(slide, name, value, label, left, top, width, accent = C.orange) {
  addText(slide, `${name}-value`, value, { left, top, width, height: 78 }, {
    fontSize: 58,
    bold: true,
    color: C.white,
  });
  slide.shapes.add({
    geometry: "rect",
    name: `${name}-rule`,
    position: { left, top: top + 78, width: 64, height: 4 },
    fill: accent,
    line: { style: "solid", fill: accent, width: 0 },
  });
  addText(slide, `${name}-label`, label, { left, top: top + 94, width, height: 58 }, {
    fontSize: 20,
    color: C.muted,
  });
}

const deck = Presentation.create({ slideSize: { width: W, height: H } });

// Slide 1 — title
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  // Prime the first-image conversion pipeline behind the visible cover image.
  await addImage(slide, "cover-image-primer", "app-home-nl.png", {
    left: 1279,
    top: 719,
    width: 1,
    height: 1,
  }, { fit: "cover", geometry: "rect", borderRadius: 0, alt: "Image conversion primer" });
  await addImage(slide, "cover-web", "web-home.png", {
    left: 596,
    top: 0,
    width: 684,
    height: 720,
  }, { fit: "cover", geometry: "rect", borderRadius: 0, alt: "Live YouNew home page" });
  slide.shapes.add({
    geometry: "rect",
    name: "cover-left-panel",
    position: { left: 0, top: 0, width: 650, height: 720 },
    fill: C.bg,
    line: { style: "solid", fill: C.bg, width: 0 },
  });
  addText(slide, "cover-brand", "YouNew", { left: 72, top: 74, width: 280, height: 44 }, {
    fontSize: 30,
    bold: true,
    color: C.orange,
  });
  addText(slide, "cover-title", "A working\necosystem for a\nclearer start", {
    left: 72,
    top: 176,
    width: 500,
    height: 244,
  }, { fontSize: 58, bold: true, color: C.white });
  addText(slide, "cover-subtitle", "iOS · Web · Admin · Supabase · AI · Workspace", {
    left: 76,
    top: 430,
    width: 470,
    height: 60,
  }, { fontSize: 25, color: C.muted });
  slide.shapes.add({
    geometry: "rect",
    name: "cover-accent",
    position: { left: 76, top: 518, width: 160, height: 6 },
    fill: C.orange,
    line: { style: "solid", fill: C.orange, width: 0 },
  });
  addText(slide, "cover-posture", "Product showcase · Release candidate", {
    left: 76,
    top: 548,
    width: 470,
    height: 40,
  }, { fontSize: 21, bold: true, color: C.cyan });
  addText(slide, "cover-date", "30 July 2026 · Netherlands", {
    left: 76,
    top: 604,
    width: 360,
    height: 28,
  }, { fontSize: 18, color: "#78859C" });
  notes(slide, [
    "https://younew.nl/ — live page screenshot captured 2026-07-30.",
    `${OUT_DIR}/assets/web-home.png`,
  ], "Opening: YouNew is shown as a working multi-surface ecosystem and release candidate.");
}

// Slide 2 — surfaces
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  addEyebrow(slide, "One connected product");
  addText(slide, "s2-title", "Every surface serves the same product system", {
    left: 64,
    top: 78,
    width: 1120,
    height: 62,
  }, { fontSize: 50, bold: true });

  // Continuous connector line first.
  slide.shapes.add({
    geometry: "rect",
    name: "s2-system-line",
    position: { left: 110, top: 606, width: 1040, height: 4 },
    fill: C.orange,
    line: { style: "solid", fill: C.orange, width: 0 },
  });

  await addFramedImage(slide, "s2-app", "app-home-nl.png", {
    left: 74,
    top: 172,
    width: 190,
    height: 412,
  }, { fit: "cover", alt: "Published Dutch iPhone home screen" });
  await addFramedImage(slide, "s2-web", "web-home.png", {
    left: 296,
    top: 172,
    width: 410,
    height: 232,
  }, { alt: "Live public website" });
  await addFramedImage(slide, "s2-admin", "admin-dashboard.png", {
    left: 296,
    top: 434,
    width: 410,
    height: 150,
  }, { alt: "Authenticated Admin dashboard" });
  await addFramedImage(slide, "s2-workspace", "workspace-overview.png", {
    left: 738,
    top: 172,
    width: 236,
    height: 236,
  }, { fit: "cover", alt: "YouNew Workspace control surface" });
  await addFramedImage(slide, "s2-code", "xcode-project.png", {
    left: 738,
    top: 438,
    width: 430,
    height: 146,
  }, { fit: "cover", alt: "Xcode engineering workspace" });

  addText(slide, "s2-app-label", "iOS", { left: 74, top: 620, width: 190, height: 28 }, {
    fontSize: 19,
    bold: true,
    color: C.orange,
    alignment: "center",
  });
  addText(slide, "s2-web-label", "Public Web + Admin", { left: 296, top: 620, width: 410, height: 28 }, {
    fontSize: 19,
    bold: true,
    color: C.cyan,
    alignment: "center",
  });
  addText(slide, "s2-ops-label", "Workspace + Engineering", { left: 738, top: 620, width: 430, height: 28 }, {
    fontSize: 19,
    bold: true,
    color: C.green,
    alignment: "center",
  });
  addFooter(slide, 2);
  notes(slide, [
    "https://younew.nl/ — live public website capture.",
    "https://admin.younew.nl/dashboard — authenticated Admin capture.",
    "https://younew.nl/images/app-home-nl.webp — current published app UI asset.",
    "/Users/ivan/Applications/YouNew Workspace.app — local workspace capture.",
    "Xcode local workspace — local engineering surface capture.",
  ]);
}

// Slide 3 — public web
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg2;
  addEyebrow(slide, "Public product");
  addText(slide, "s3-title", "The web product is live, discoverable and usable", {
    left: 64,
    top: 78,
    width: 700,
    height: 66,
  }, { fontSize: 48, bold: true });
  await addFramedImage(slide, "s3-web-home", "web-home.png", {
    left: 520,
    top: 164,
    width: 696,
    height: 392,
  }, { alt: "Live YouNew website home page" });

  addText(slide, "s3-copy", "A source-backed companion for newcomers in the Netherlands — with search, profiles, guides, cities, organizations, maps, saved content and emergency routes.", {
    left: 64,
    top: 180,
    width: 398,
    height: 154,
  }, { fontSize: 25, color: C.muted });
  metric(slide, "s3-routes", "585", "static routes", 64, 368, 130, C.orange);
  metric(slide, "s3-index", "575", "indexable URLs", 214, 368, 160, C.cyan);
  metric(slide, "s3-published", "186", "published records", 392, 368, 120, C.green);
  addText(slide, "s3-proof", "Live smoke test: PASS · 83 web tests: PASS", {
    left: 64,
    top: 592,
    width: 560,
    height: 38,
  }, { fontSize: 21, bold: true, color: C.white });
  addFooter(slide, 3);
  notes(slide, [
    "https://younew.nl/ — captured 2026-07-30.",
    `${OUT_DIR}/assets/web-home.png`,
    `${OUT_DIR}/../sale-readiness-2026-07-30/verification-summary.json — 585 routes, 575 indexable URLs, 186 published records and 83 passing tests.`,
  ]);
}

// Slide 4 — app
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  addEyebrow(slide, "iPhone product");
  addText(slide, "s4-title", "A public App Store product with a coherent mobile experience", {
    left: 64,
    top: 78,
    width: 1120,
    height: 66,
  }, { fontSize: 44, bold: true });

  await addFramedImage(slide, "s4-store", "app-store-listing.png", {
    left: 64,
    top: 170,
    width: 690,
    height: 388,
  }, { alt: "Public YouNew App Store listing" });
  await addFramedImage(slide, "s4-home", "app-home-nl.png", {
    left: 812,
    top: 154,
    width: 168,
    height: 364,
  }, { alt: "Published YouNew iPhone home screen" });
  await addFramedImage(slide, "s4-map", "app-map-en.png", {
    left: 1020,
    top: 154,
    width: 168,
    height: 364,
  }, { alt: "Published YouNew iPhone map screen" });

  addText(slide, "s4-caption", "The public listing, navigation, city context, search, guide entry points and map experience already share one visual language.", {
    left: 64,
    top: 590,
    width: 690,
    height: 54,
  }, { fontSize: 23, color: C.muted });
  addText(slide, "s4-build", "Unsigned generic-device Release: BUILD SUCCEEDED", {
    left: 800,
    top: 588,
    width: 390,
    height: 44,
  }, { fontSize: 20, bold: true, color: C.green, alignment: "right" });
  addFooter(slide, 4);
  notes(slide, [
    "https://apps.apple.com/app/id6782617312 — public listing captured 2026-07-30.",
    "https://younew.nl/images/app-home-nl.webp — published current iPhone UI asset.",
    "https://younew.nl/images/app-map-en.webp — published current iPhone UI asset.",
    `${OUT_DIR}/../sale-readiness-2026-07-30/verification-summary.json — unsigned generic-device Release BUILD SUCCEEDED.`,
  ], "The two standalone app screens are current published UI assets, not screenshots from the blocked Simulator installation attempt.");
}

// Slide 5 — journey
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  addEyebrow(slide, "User journey");
  addText(slide, "s5-title", "From question to verified next step", {
    left: 64,
    top: 82,
    width: 1040,
    height: 56,
  }, { fontSize: 46, bold: true });
  await addFramedImage(slide, "s5-flow", "web-home-features.png", {
    left: 64,
    top: 164,
    width: 1152,
    height: 470,
  }, { fit: "cover", alt: "Live YouNew three-step guidance flow" });
  addFooter(slide, 5);
  notes(slide, [
    "https://younew.nl/ — live How it works section captured 2026-07-30.",
    `${OUT_DIR}/assets/web-home-features.png`,
  ]);
}

// Slide 6 — maps
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg2;
  addEyebrow(slide, "Location layer");
  addText(slide, "s6-title", "The same geography powers web discovery and iPhone context", {
    left: 64,
    top: 78,
    width: 1050,
    height: 64,
  }, { fontSize: 48, bold: true });

  await addFramedImage(slide, "s6-web-map", "web-map.png", {
    left: 64,
    top: 174,
    width: 770,
    height: 433,
  }, { alt: "Live YouNew web map" });
  await addFramedImage(slide, "s6-app-map", "app-map-en.png", {
    left: 900,
    top: 154,
    width: 270,
    height: 478,
  }, { alt: "Published YouNew iPhone map screen" });
  addText(slide, "s6-stat", "342 municipalities · 171 located published items · accessible list fallback", {
    left: 80,
    top: 618,
    width: 750,
    height: 34,
  }, { fontSize: 20, bold: true, color: C.cyan });
  addFooter(slide, 6);
  notes(slide, [
    "https://younew.nl/map/ — live map page captured 2026-07-30; visible page reports 342 municipalities and 171 located published items.",
    "https://younew.nl/images/app-map-en.webp — published iPhone map UI.",
  ]);
}

// Slide 7 — admin
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  addEyebrow(slide, "Control plane");
  addText(slide, "s7-title", "Admin turns content, quality and releases into operations", {
    left: 64,
    top: 78,
    width: 1020,
    height: 64,
  }, { fontSize: 48, bold: true });
  await addFramedImage(slide, "s7-admin", "admin-dashboard.png", {
    left: 64,
    top: 172,
    width: 830,
    height: 467,
  }, { alt: "Authenticated YouNew Admin dashboard" });

  addText(slide, "s7-a", "Content lifecycle", { left: 950, top: 190, width: 230, height: 36 }, {
    fontSize: 25,
    bold: true,
    color: C.orange,
  });
  addText(slide, "s7-a2", "Published, review, outdated and blocked states.", {
    left: 950,
    top: 234,
    width: 230,
    height: 70,
  }, { fontSize: 20, color: C.muted });
  addText(slide, "s7-b", "Governed data", { left: 950, top: 334, width: 230, height: 36 }, {
    fontSize: 25,
    bold: true,
    color: C.cyan,
  });
  addText(slide, "s7-b2", "Sources, media, links, coordinates and AI summaries.", {
    left: 950,
    top: 378,
    width: 230,
    height: 70,
  }, { fontSize: 20, color: C.muted });
  addText(slide, "s7-c", "Protected actions", { left: 950, top: 478, width: 230, height: 36 }, {
    fontSize: 25,
    bold: true,
    color: C.green,
  });
  addText(slide, "s7-c2", "Approved roles, audit log and explicit release surfaces.", {
    left: 950,
    top: 522,
    width: 230,
    height: 70,
  }, { fontSize: 20, color: C.muted });
  addFooter(slide, 7);
  notes(slide, [
    "https://admin.younew.nl/dashboard — authenticated live capture 2026-07-30.",
    `${OUT_DIR}/assets/admin-dashboard.png`,
    `${OUT_DIR}/../sale-readiness-2026-07-30/verification-summary.json — Admin lint, typecheck, 10 tests and production build passed.`,
  ]);
}

// Slide 8 — workspace
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg2;
  addEyebrow(slide, "Operational workspace");
  addText(slide, "s8-title", "One desktop surface links operations and engineering", {
    left: 64,
    top: 78,
    width: 1000,
    height: 64,
  }, { fontSize: 48, bold: true });

  await addFramedImage(slide, "s8-workspace", "workspace-overview.png", {
    left: 64,
    top: 164,
    width: 500,
    height: 500,
  }, { fit: "cover", alt: "YouNew Workspace Overview" });
  await addFramedImage(slide, "s8-xcode", "xcode-project.png", {
    left: 610,
    top: 164,
    width: 606,
    height: 370,
  }, { fit: "cover", alt: "Xcode engineering workspace with successful build" });
  addText(slide, "s8-copy", "Project health, external services, release artifacts, activity and source-level engineering stay visible without collapsing safety boundaries.", {
    left: 620,
    top: 568,
    width: 576,
    height: 78,
  }, { fontSize: 23, color: C.muted });
  addFooter(slide, 8);
  notes(slide, [
    "/Users/ivan/Applications/YouNew Workspace.app — Overview screen captured 2026-07-30.",
    "Xcode local workspace — real code and successful build surface captured 2026-07-30.",
    `${OUT_DIR}/assets/workspace-overview.png`,
    `${OUT_DIR}/assets/xcode-project.png`,
  ]);
}

// Slide 9 — architecture
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  addEyebrow(slide, "System architecture");
  addText(slide, "s9-title", "How YouNew works — end to end", {
    left: 64,
    top: 78,
    width: 860,
    height: 64,
  }, { fontSize: 50, bold: true });

  // Arrows first, behind nodes.
  const arrows = [
    { name: "a-work-admin", geometry: "rightArrow", left: 280, top: 262, width: 82, height: 34, fill: C.orange },
    { name: "a-admin-data", geometry: "rightArrow", left: 518, top: 262, width: 82, height: 34, fill: C.cyan },
    { name: "a-data-users", geometry: "rightArrow", left: 782, top: 262, width: 82, height: 34, fill: C.green },
    { name: "a-deploy-users", geometry: "downArrow", left: 994, top: 180, width: 34, height: 70, fill: C.orange },
    { name: "a-users-feedback", geometry: "downArrow", left: 1010, top: 374, width: 34, height: 72, fill: C.cyan },
    { name: "a-feedback-admin-horizontal", geometry: "leftArrow", left: 440, top: 500, width: 424, height: 30, fill: C.cyan },
    { name: "a-feedback-admin-vertical", geometry: "upArrow", left: 423, top: 374, width: 34, height: 134, fill: C.cyan },
    { name: "a-work-ci", geometry: "upArrow", left: 168, top: 180, width: 34, height: 70, fill: C.orange },
  ];
  for (const a of arrows) {
    slide.shapes.add({
      geometry: a.geometry,
      name: a.name,
      position: { left: a.left, top: a.top, width: a.width, height: a.height },
      fill: a.fill,
      line: { style: "solid", fill: a.fill, width: 0 },
    });
  }

  const nWork = addBox(slide, "node-workspace", { left: 64, top: 240, width: 216, height: 134 }, C.surface2, C.orange, 18);
  const nAdmin = addBox(slide, "node-admin", { left: 362, top: 240, width: 156, height: 134 }, C.surface2, C.cyan, 18);
  const nData = addBox(slide, "node-data", { left: 600, top: 220, width: 182, height: 174 }, C.surface2, C.green, 18);
  const nUsers = addBox(slide, "node-users", { left: 864, top: 220, width: 286, height: 174 }, C.surface2, C.orange, 18);
  const nCI = addBox(slide, "node-ci", { left: 64, top: 142, width: 216, height: 72 }, "#161D30", C.line, 16);
  const nDeploy = addBox(slide, "node-deploy", { left: 864, top: 142, width: 286, height: 72 }, "#161D30", C.line, 16);
  const nFeedback = addBox(slide, "node-feedback", { left: 864, top: 452, width: 286, height: 100 }, "#161D30", C.line, 16);
  void nWork; void nAdmin; void nData; void nUsers; void nCI; void nDeploy; void nFeedback;

  addText(slide, "node-ci-text", "GitHub + CI\nsource, checks, builds", { left: 84, top: 158, width: 176, height: 48 }, {
    fontSize: 19,
    bold: true,
    color: C.muted,
    alignment: "center",
  });
  addText(slide, "node-deploy-text", "App Store + web deploy\nsigned delivery", { left: 892, top: 158, width: 230, height: 48 }, {
    fontSize: 19,
    bold: true,
    color: C.muted,
    alignment: "center",
  });
  addText(slide, "node-work-title", "YouNew Workspace", { left: 86, top: 266, width: 172, height: 32 }, {
    fontSize: 24,
    bold: true,
    color: C.orange,
    alignment: "center",
  });
  addText(slide, "node-work-copy", "health · tools · releases\nsafe operational view", { left: 88, top: 312, width: 168, height: 46 }, {
    fontSize: 17,
    color: C.muted,
    alignment: "center",
  });
  addText(slide, "node-admin-title", "Admin", { left: 386, top: 270, width: 108, height: 32 }, {
    fontSize: 25,
    bold: true,
    color: C.cyan,
    alignment: "center",
  });
  addText(slide, "node-admin-copy", "content · quality\nreview · release", { left: 382, top: 314, width: 116, height: 46 }, {
    fontSize: 17,
    color: C.muted,
    alignment: "center",
  });
  addText(slide, "node-data-title", "Supabase", { left: 620, top: 246, width: 142, height: 32 }, {
    fontSize: 25,
    bold: true,
    color: C.green,
    alignment: "center",
  });
  addText(slide, "node-data-copy", "Postgres · RLS\nEdge Functions\nanalytics · AI context", { left: 618, top: 292, width: 146, height: 72 }, {
    fontSize: 17,
    color: C.muted,
    alignment: "center",
  });
  addText(slide, "node-users-title", "Public Web + iOS", { left: 892, top: 246, width: 230, height: 32 }, {
    fontSize: 25,
    bold: true,
    color: C.orange,
    alignment: "center",
  });
  addText(slide, "node-users-copy", "discover · guides · map\nsearch · save · share\nsource verification", { left: 900, top: 292, width: 214, height: 74 }, {
    fontSize: 17,
    color: C.muted,
    alignment: "center",
  });
  addText(slide, "node-feedback-text", "Privacy-safe analytics + feedback\nbounded signals return to Admin", {
    left: 892,
    top: 474,
    width: 230,
    height: 56,
  }, { fontSize: 18, bold: true, color: C.cyan, alignment: "center" });

  addText(slide, "s9-principle", "One governed data model · explicit trust boundaries · auditable release path", {
    left: 120,
    top: 606,
    width: 1040,
    height: 34,
  }, { fontSize: 24, bold: true, color: C.white, alignment: "center" });
  addFooter(slide, 9);
  notes(slide, [
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/docs/SYSTEM_MAP.md — component and data-flow source.",
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/docs/COUNTRY_PACK_CONTRACT.md — governed expansion contract.",
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/docs/COMPLIANCE_CONTROL_MATRIX.md — trust and release controls.",
  ], "Native PowerPoint shapes illustrate the verified system boundaries. The diagram is intentionally simplified for a product audience.");
}

// Slide 10 — evidence
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg2;
  addEyebrow(slide, "Verification evidence");
  addText(slide, "s10-title", "Quality is visible in the numbers and the gates", {
    left: 64,
    top: 78,
    width: 920,
    height: 64,
  }, { fontSize: 50, bold: true });

  const metrics = [
    ["450", "governed records", C.orange],
    ["186", "published records", C.cyan],
    ["97.8%", "freshness compliant", C.green],
    ["170", "assets rights-checked", C.yellow],
    ["106", "passing web/admin/AI tests", C.orangeSoft],
  ];
  const lefts = [64, 292, 520, 748, 976];
  for (let i = 0; i < metrics.length; i += 1) {
    metric(slide, `s10-m${i}`, metrics[i][0], metrics[i][1], lefts[i], 220, 190, metrics[i][2]);
  }

  slide.shapes.add({
    geometry: "rect",
    name: "s10-divider",
    position: { left: 64, top: 430, width: 1152, height: 1 },
    fill: C.line,
    line: { style: "solid", fill: C.line, width: 0 },
  });
  addText(slide, "s10-proof-a", "PUBLIC WEB", { left: 64, top: 470, width: 180, height: 28 }, {
    fontSize: 17,
    bold: true,
    color: C.cyan,
  });
  addText(slide, "s10-proof-a2", "Predeploy PASS · live routes reviewed", { left: 64, top: 512, width: 310, height: 52 }, {
    fontSize: 23,
    bold: true,
  });
  addText(slide, "s10-proof-b", "ADMIN + EDGE", { left: 452, top: 470, width: 200, height: 28 }, {
    fontSize: 17,
    bold: true,
    color: C.green,
  });
  addText(slide, "s10-proof-b2", "Build PASS · function typecheck PASS", { left: 452, top: 512, width: 340, height: 52 }, {
    fontSize: 23,
    bold: true,
  });
  addText(slide, "s10-proof-c", "iOS RELEASE", { left: 862, top: 470, width: 200, height: 28 }, {
    fontSize: 17,
    bold: true,
    color: C.orange,
  });
  addText(slide, "s10-proof-c2", "Unsigned device build: SUCCEEDED", { left: 862, top: 512, width: 330, height: 52 }, {
    fontSize: 23,
    bold: true,
  });
  addFooter(slide, 10);
  notes(slide, [
    `${OUT_DIR}/../sale-readiness-2026-07-30/verification-summary.json — 450 governed, 186 published, 97.8% freshness, 170 inventoried assets and passing tests.`,
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/RELEASE_READINESS_2026-07-30.md — release checks and bounded limitations.",
  ], "106 is the sum of 83 public web tests, 10 admin tests and 13 backend AI proxy tests; iOS tests are not included.");
}

// Slide 11 — release posture
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  addEyebrow(slide, "Release posture");
  addText(slide, "s11-title", "Ready for controlled release-candidate handoff", {
    left: 64,
    top: 78,
    width: 1040,
    height: 64,
  }, { fontSize: 50, bold: true });

  addText(slide, "s11-score", "7.8", { left: 64, top: 178, width: 210, height: 120 }, {
    fontSize: 92,
    bold: true,
    color: C.orange,
  });
  addText(slide, "s11-score-label", "technical readiness\nout of 10", { left: 72, top: 308, width: 210, height: 64 }, {
    fontSize: 22,
    bold: true,
    color: C.muted,
  });

  addText(slide, "s11-proven", "Already proven", { left: 352, top: 184, width: 340, height: 44 }, {
    fontSize: 31,
    bold: true,
    color: C.green,
  });
  addText(slide, "s11-proven-list", "• Live public web\n• Public App Store listing\n• Authenticated Admin\n• Healthy Supabase runtime\n• Successful unsigned Release build", {
    left: 352,
    top: 250,
    width: 360,
    height: 232,
  }, { fontSize: 24, color: C.white });

  addText(slide, "s11-gates", "Final release gates", { left: 790, top: 184, width: 360, height: 44 }, {
    fontSize: 31,
    bold: true,
    color: C.yellow,
  });
  addText(slide, "s11-gates-list", "• Clean source SHA + green CI\n• Signed archive + runnable iOS tests\n• Encrypted backup + isolated restore\n• Authenticated Admin E2E\n• Flagship guides production-ready", {
    left: 790,
    top: 250,
    width: 390,
    height: 250,
  }, { fontSize: 22, color: C.white });

  addBox(slide, "s11-bottom", { left: 64, top: 540, width: 1152, height: 90 }, C.surface2, C.line, 18);
  addText(slide, "s11-bottom-text", "Operational today. Final release authority remains tied to explicit, testable evidence.", {
    left: 96,
    top: 568,
    width: 1088,
    height: 36,
  }, { fontSize: 25, bold: true, color: C.cyan, alignment: "center" });
  addFooter(slide, 11);
  notes(slide, [
    `${OUT_DIR}/../sale-readiness-2026-07-30/verification-summary.json — decision and component evidence.`,
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/RELEASE_READINESS_2026-07-30.md — open release gates.",
  ], "This slide deliberately distinguishes working product readiness from unconditional release authority.");
}

// Slide 12 — close
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  await addImage(slide, "s12-web", "web-home.png", {
    left: 600,
    top: 0,
    width: 680,
    height: 720,
  }, { fit: "cover", geometry: "rect", borderRadius: 0, alt: "Live YouNew home page" });
  slide.shapes.add({
    geometry: "rect",
    name: "s12-panel",
    position: { left: 0, top: 0, width: 660, height: 720 },
    fill: C.bg,
    line: { style: "solid", fill: C.bg, width: 0 },
  });
  addText(slide, "s12-brand", "YouNew", { left: 72, top: 76, width: 220, height: 42 }, {
    fontSize: 30,
    bold: true,
    color: C.orange,
  });
  addText(slide, "s12-title", "A working ecosystem\nbuilt to scale", {
    left: 72,
    top: 190,
    width: 500,
    height: 170,
  }, { fontSize: 68, bold: true });
  addText(slide, "s12-copy", "Product experience, governed data, operational control and release evidence — connected in one system.", {
    left: 76,
    top: 400,
    width: 470,
    height: 112,
  }, { fontSize: 27, color: C.muted });
  addText(slide, "s12-next", "Next milestone: flagship practical guides + clean release identity", {
    left: 76,
    top: 568,
    width: 480,
    height: 66,
  }, { fontSize: 22, bold: true, color: C.cyan });
  notes(slide, [
    "https://younew.nl/ — live page screenshot captured 2026-07-30.",
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/docs/COUNTRY_PACK_CONTRACT.md — repeatable expansion boundary.",
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/RELEASE_READINESS_2026-07-30.md — highest-value remaining release actions.",
  ]);
}

await fs.mkdir(RENDER_DIR, { recursive: true });
for (const [index, slide] of deck.slides.items.entries()) {
  const png = await deck.export({ slide, format: "png", scale: 1 });
  await fs.writeFile(
    path.join(RENDER_DIR, `slide-${String(index + 1).padStart(2, "0")}.png`),
    new Uint8Array(await png.arrayBuffer()),
  );
  const layout = await slide.export({ format: "layout" });
  await fs.writeFile(
    path.join(RENDER_DIR, `slide-${String(index + 1).padStart(2, "0")}.layout.json`),
    await layout.text(),
  );
}

const montage = await deck.export({ format: "webp", montage: true, scale: 1 });
await fs.writeFile(
  path.join(OUT_DIR, "YouNew_Product_Ecosystem_montage.webp"),
  new Uint8Array(await montage.arrayBuffer()),
);

const pptx = await PresentationFile.exportPptx(deck);
await pptx.save(FINAL_PPTX);

console.log(FINAL_PPTX);
