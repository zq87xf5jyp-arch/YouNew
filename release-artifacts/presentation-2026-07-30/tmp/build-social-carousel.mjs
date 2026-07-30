import fs from "node:fs/promises";
import path from "node:path";
import { Presentation, PresentationFile } from "@oai/artifact-tool";

const OUT_DIR = "/Users/ivan/Desktop/Developer:YouNew/YouNew/release-artifacts/social-post-2026-07-30";
const ASSET_DIR = "/Users/ivan/Desktop/Developer:YouNew/YouNew/release-artifacts/presentation-2026-07-30/assets";
const W = 1080;
const H = 1350;
const FONT = "Aptos";

const C = {
  bg: "#080B16",
  bg2: "#0D1222",
  surface: "#141C2F",
  surface2: "#1A253C",
  line: "#2A3651",
  white: "#F7F8FC",
  muted: "#AAB4C8",
  orange: "#F47A24",
  cyan: "#62C9D8",
  green: "#3FD58B",
  yellow: "#F4B860",
};

const files = [
  "YouNew_Social_Carousel_01_Cover.png",
  "YouNew_Social_Carousel_02_Connected_Product.png",
  "YouNew_Social_Carousel_03_Verified_Evidence.png",
  "YouNew_Social_Carousel_04_Architecture.png",
  "YouNew_Social_Carousel_05_Release_Candidate.png",
];

async function bytes(file) {
  const b = await fs.readFile(path.join(ASSET_DIR, file));
  return b.buffer.slice(b.byteOffset, b.byteOffset + b.byteLength);
}

function box(slide, name, position, fill = C.surface, line = C.line, radius = 28) {
  return slide.shapes.add({
    geometry: "roundRect",
    name,
    position,
    fill,
    line: { style: "solid", fill: line, width: 2 },
    borderRadius: radius,
  });
}

function text(slide, name, value, position, style = {}) {
  const shape = slide.shapes.add({
    geometry: "textbox",
    name,
    position,
    fill: "none",
    line: { style: "solid", fill: "none", width: 0 },
  });
  shape.text = value;
  shape.text.style = {
    typeface: FONT,
    fontSize: style.fontSize ?? 34,
    bold: style.bold ?? false,
    color: style.color ?? C.white,
    alignment: style.alignment ?? "left",
    verticalAlignment: style.verticalAlignment ?? "top",
    autoFit: "shrinkText",
    insets: { top: 0, right: 0, bottom: 0, left: 0 },
  };
  return shape;
}

function eyebrow(slide, value) {
  text(slide, `eyebrow-${value}`, value.toUpperCase(), {
    left: 72, top: 62, width: 680, height: 34,
  }, { fontSize: 22, bold: true, color: C.cyan });
}

function footer(slide, page) {
  slide.shapes.add({
    geometry: "rect",
    name: `footer-rule-${page}`,
    position: { left: 72, top: 1260, width: 936, height: 2 },
    fill: C.line,
    line: { style: "solid", fill: C.line, width: 0 },
  });
  text(slide, `footer-brand-${page}`, "YouNew · Product ecosystem", {
    left: 72, top: 1280, width: 600, height: 28,
  }, { fontSize: 18, color: "#7F8BA3" });
  text(slide, `footer-page-${page}`, `${String(page).padStart(2, "0")} / 05`, {
    left: 850, top: 1280, width: 158, height: 28,
  }, { fontSize: 18, bold: true, color: "#7F8BA3", alignment: "right" });
}

async function image(slide, name, file, position, options = {}) {
  return slide.images.add({
    blob: await bytes(file),
    contentType: "image/png",
    alt: options.alt ?? name,
    fit: options.fit ?? "cover",
    geometry: options.geometry ?? "roundRect",
    borderRadius: options.borderRadius ?? 28,
    position,
  });
}

async function framedImage(slide, name, file, position, options = {}) {
  box(slide, `${name}-frame`, {
    left: position.left - 6,
    top: position.top - 6,
    width: position.width + 12,
    height: position.height + 12,
  }, C.surface2, options.line ?? C.line, 32);
  return image(slide, name, file, position, options);
}

function metric(slide, name, value, label, left, top, accent) {
  text(slide, `${name}-value`, value, { left, top, width: 210, height: 96 }, {
    fontSize: 76, bold: true,
  });
  slide.shapes.add({
    geometry: "rect",
    name: `${name}-rule`,
    position: { left, top: top + 100, width: 68, height: 6 },
    fill: accent,
    line: { style: "solid", fill: accent, width: 0 },
  });
  text(slide, `${name}-label`, label, { left, top: top + 126, width: 210, height: 76 }, {
    fontSize: 25, color: C.muted,
  });
}

function note(slide, sources) {
  slide.speakerNotes.textFrame.setText([
    "[Sources]",
    ...sources.map((s) => `- ${s}`),
  ].join("\n"));
}

const deck = Presentation.create({ slideSize: { width: W, height: H } });

// 01 — Cover
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  await image(slide, "image-primer", "app-home-nl.png", {
    left: 1079, top: 1349, width: 1, height: 1,
  }, { geometry: "rect", borderRadius: 0 });

  eyebrow(slide, "Product showcase · Release candidate");
  text(slide, "cover-brand", "YouNew", { left: 72, top: 126, width: 360, height: 64 }, {
    fontSize: 46, bold: true, color: C.orange,
  });
  text(slide, "cover-title", "A working ecosystem\nfor a clearer start.", {
    left: 72, top: 230, width: 900, height: 280,
  }, { fontSize: 86, bold: true });
  text(slide, "cover-subtitle", "iOS · Web · Admin · Supabase · AI · Workspace", {
    left: 76, top: 540, width: 900, height: 64,
  }, { fontSize: 31, color: C.muted });
  await framedImage(slide, "cover-web", "web-home.png", {
    left: 76, top: 660, width: 928, height: 510,
  }, { alt: "Live YouNew public web product" });
  box(slide, "cover-proof", { left: 112, top: 1110, width: 690, height: 74 }, "#111A2D", C.cyan, 22);
  text(slide, "cover-proof-text", "LIVE WEB · PUBLIC APP · AUTHENTICATED ADMIN", {
    left: 142, top: 1134, width: 630, height: 32,
  }, { fontSize: 21, bold: true, color: C.cyan, alignment: "center" });
  footer(slide, 1);
  note(slide, [
    "https://younew.nl/ — live screenshot captured 2026-07-30.",
    `${ASSET_DIR}/web-home.png`,
  ]);
}

// 02 — Connected product
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg2;
  eyebrow(slide, "One connected product");
  text(slide, "surfaces-title", "Every surface serves\nthe same system.", {
    left: 72, top: 122, width: 900, height: 180,
  }, { fontSize: 72, bold: true });
  await framedImage(slide, "surface-ios", "app-home-nl.png", {
    left: 72, top: 350, width: 248, height: 540,
  }, { alt: "Published YouNew iPhone home screen" });
  await framedImage(slide, "surface-web", "web-home.png", {
    left: 354, top: 350, width: 654, height: 310,
  }, { alt: "Live public web product" });
  await framedImage(slide, "surface-admin", "admin-dashboard.png", {
    left: 354, top: 706, width: 314, height: 314,
  }, { alt: "Authenticated Admin dashboard" });
  await framedImage(slide, "surface-workspace", "workspace-overview.png", {
    left: 694, top: 706, width: 314, height: 314,
  }, { alt: "YouNew operational Workspace" });
  text(slide, "surface-ios-label", "iOS", { left: 72, top: 930, width: 248, height: 42 }, {
    fontSize: 30, bold: true, color: C.orange, alignment: "center",
  });
  text(slide, "surface-bottom", "One identity · one governed data model · one release path", {
    left: 82, top: 1090, width: 916, height: 76,
  }, { fontSize: 31, bold: true, color: C.cyan, alignment: "center" });
  footer(slide, 2);
  note(slide, [
    `${ASSET_DIR}/app-home-nl.png`,
    `${ASSET_DIR}/web-home.png`,
    `${ASSET_DIR}/admin-dashboard.png`,
    `${ASSET_DIR}/workspace-overview.png`,
  ]);
}

// 03 — Evidence
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  eyebrow(slide, "Live product · verified evidence");
  text(slide, "evidence-title", "Quality is visible\nin the numbers.", {
    left: 72, top: 122, width: 900, height: 180,
  }, { fontSize: 74, bold: true });
  await framedImage(slide, "evidence-web", "web-home.png", {
    left: 72, top: 340, width: 936, height: 470,
  }, { alt: "Live YouNew home page" });
  metric(slide, "metric-routes", "585", "static routes", 72, 866, C.orange);
  metric(slide, "metric-index", "575", "indexable URLs", 314, 866, C.cyan);
  metric(slide, "metric-published", "186", "published records", 556, 866, C.green);
  metric(slide, "metric-tests", "106", "passing web / admin / AI tests", 798, 866, C.yellow);
  box(slide, "evidence-pass", { left: 72, top: 1138, width: 936, height: 82 }, C.surface2, C.green, 22);
  text(slide, "evidence-pass-text", "LIVE SMOKE TEST: PASS · PREDEPLOY: PASS", {
    left: 110, top: 1165, width: 860, height: 34,
  }, { fontSize: 25, bold: true, color: C.green, alignment: "center" });
  footer(slide, 3);
  note(slide, [
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/release-artifacts/sale-readiness-2026-07-30/verification-summary.json",
    "106 = 83 public web tests + 10 Admin tests + 13 backend AI proxy tests.",
  ]);
}

// 04 — Architecture
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg2;
  eyebrow(slide, "System architecture");
  text(slide, "architecture-title", "How YouNew works —\nend to end.", {
    left: 72, top: 122, width: 900, height: 180,
  }, { fontSize: 74, bold: true });

  const arrows = [
    { name: "flow-1", top: 438, color: C.orange },
    { name: "flow-2", top: 650, color: C.cyan },
    { name: "flow-3", top: 862, color: C.green },
  ];
  for (const arrow of arrows) {
    slide.shapes.add({
      geometry: "downArrow",
      name: arrow.name,
      position: { left: 512, top: arrow.top, width: 56, height: 74 },
      fill: arrow.color,
      line: { style: "solid", fill: arrow.color, width: 0 },
    });
  }

  box(slide, "architecture-source", { left: 270, top: 330, width: 540, height: 108 }, "#172036", C.line, 26);
  text(slide, "architecture-source-text", "GitHub + CI · YouNew Workspace", {
    left: 304, top: 366, width: 472, height: 42,
  }, { fontSize: 31, bold: true, color: C.orange, alignment: "center" });

  box(slide, "architecture-admin", { left: 270, top: 512, width: 540, height: 138 }, C.surface2, C.cyan, 26);
  text(slide, "architecture-admin-title", "Admin", { left: 320, top: 536, width: 440, height: 44 }, {
    fontSize: 38, bold: true, color: C.cyan, alignment: "center",
  });
  text(slide, "architecture-admin-copy", "content · quality · review · release", {
    left: 320, top: 592, width: 440, height: 34,
  }, { fontSize: 25, color: C.muted, alignment: "center" });

  box(slide, "architecture-data", { left: 270, top: 724, width: 540, height: 138 }, C.surface2, C.green, 26);
  text(slide, "architecture-data-title", "Supabase", { left: 320, top: 748, width: 440, height: 44 }, {
    fontSize: 38, bold: true, color: C.green, alignment: "center",
  });
  text(slide, "architecture-data-copy", "Postgres · RLS · Edge Functions · AI context", {
    left: 320, top: 804, width: 440, height: 34,
  }, { fontSize: 24, color: C.muted, alignment: "center" });

  box(slide, "architecture-product", { left: 180, top: 936, width: 720, height: 158 }, C.surface2, C.orange, 28);
  text(slide, "architecture-product-title", "Public Web + iOS", {
    left: 240, top: 966, width: 600, height: 48,
  }, { fontSize: 42, bold: true, color: C.orange, alignment: "center" });
  text(slide, "architecture-product-copy", "discover · guides · map · search · save · source verification", {
    left: 240, top: 1030, width: 600, height: 36,
  }, { fontSize: 24, color: C.muted, alignment: "center" });

  box(slide, "architecture-feedback", { left: 204, top: 1130, width: 672, height: 84 }, "#172036", C.cyan, 22);
  text(slide, "architecture-feedback-text", "Privacy-safe analytics + feedback return to Admin", {
    left: 238, top: 1157, width: 604, height: 32,
  }, { fontSize: 23, bold: true, color: C.cyan, alignment: "center" });
  footer(slide, 4);
  note(slide, [
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/docs/SYSTEM_MAP.md",
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/docs/COMPLIANCE_CONTROL_MATRIX.md",
  ]);
}

// 05 — Release posture
{
  const slide = deck.slides.add();
  slide.background.fill = C.bg;
  eyebrow(slide, "Release posture");
  text(slide, "release-title", "Operational today.\nEvidence before claims.", {
    left: 72, top: 122, width: 900, height: 186,
  }, { fontSize: 72, bold: true });
  text(slide, "release-score", "7.8", { left: 72, top: 342, width: 330, height: 160 }, {
    fontSize: 124, bold: true, color: C.orange,
  });
  text(slide, "release-score-label", "technical readiness\nout of 10", {
    left: 84, top: 508, width: 300, height: 84,
  }, { fontSize: 29, bold: true, color: C.muted });
  text(slide, "release-proven-title", "Already proven", {
    left: 422, top: 356, width: 500, height: 54,
  }, { fontSize: 42, bold: true, color: C.green });
  text(slide, "release-proven-copy", "✓ Live public web\n✓ Public App Store listing\n✓ Authenticated Admin\n✓ Healthy Supabase runtime\n✓ Successful unsigned Release build", {
    left: 422, top: 430, width: 560, height: 246,
  }, { fontSize: 29, color: C.white });
  box(slide, "release-gates-box", { left: 72, top: 720, width: 936, height: 390 }, C.surface2, C.yellow, 28);
  text(slide, "release-gates-title", "Final release gates", {
    left: 112, top: 758, width: 820, height: 54,
  }, { fontSize: 42, bold: true, color: C.yellow });
  text(slide, "release-gates-copy", "• Clean source SHA + green CI\n• Signed archive + runnable iOS tests\n• Encrypted backup + isolated restore\n• Authenticated Admin E2E\n• Flagship guides production-ready", {
    left: 112, top: 838, width: 820, height: 224,
  }, { fontSize: 29, color: C.white });
  text(slide, "release-next", "Next milestone: flagship practical guides + clean release identity", {
    left: 92, top: 1162, width: 896, height: 60,
  }, { fontSize: 28, bold: true, color: C.cyan, alignment: "center" });
  footer(slide, 5);
  note(slide, [
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/release-artifacts/sale-readiness-2026-07-30/verification-summary.json",
    "/Users/ivan/Desktop/Developer:YouNew/YouNew/RELEASE_READINESS_2026-07-30.md",
  ]);
}

await fs.mkdir(OUT_DIR, { recursive: true });
for (const [index, slide] of deck.slides.items.entries()) {
  const png = await deck.export({ slide, format: "png", scale: 1 });
  await fs.writeFile(path.join(OUT_DIR, files[index]), new Uint8Array(await png.arrayBuffer()));
}

const pptx = await PresentationFile.exportPptx(deck);
await pptx.save(path.join(OUT_DIR, "YouNew_Social_Carousel_Source.pptx"));

await fs.writeFile(path.join(OUT_DIR, "manifest.json"), JSON.stringify({
  title: "YouNew social carousel",
  date: "2026-07-30",
  dimensions: { width: 1080, height: 1350, aspectRatio: "4:5" },
  positioning: "Working ecosystem · Release candidate",
  files,
  claims: {
    staticRoutes: 585,
    indexableUrls: 575,
    publishedRecords: 186,
    passingWebAdminAiTests: 106,
    technicalReadiness: 7.8,
  },
  releaseBoundary: "Controlled release-candidate handoff; not unconditional public release authority.",
}, null, 2));

await fs.writeFile(path.join(OUT_DIR, "YouNew_Social_Post_Caption_RU.md"), `# Текст поста

YouNew — это уже не отдельное приложение или сайт. Это связанная продуктовая экосистема:

— iOS-приложение;
— публичный веб-продукт;
— административная панель;
— Supabase и Edge Functions;
— AI-функции;
— операционная рабочая поверхность и инженерный контур.

Сегодня подтверждены 585 статических маршрутов, 575 индексируемых URL, 186 опубликованных записей и 106 проходящих web/admin/AI-тестов. Публичный сайт работает, приложение представлено в App Store, Admin доступен с авторизацией, Supabase находится в здоровом состоянии.

Текущая техническая готовность: 7,8/10.

YouNew готов к контролируемой передаче как release candidate. До безусловного публичного релиза остаются конкретные проверяемые gates: чистый release SHA и green CI, подписанный iOS archive с исполняемыми тестами, проверка backup/restore, Admin E2E и production-ready практические гайды.

Мы показываем не обещание, а работающую систему и измеримые доказательства.

#YouNew #ProductDevelopment #iOS #WebDevelopment #Supabase #AI #Startup #Netherlands #ReleaseCandidate
`);

await fs.writeFile(path.join(OUT_DIR, "PROVENANCE.md"), `# Provenance

- Real product screenshots were captured on 2026-07-30 from YouNew public web, App Store/current published iPhone UI, authenticated Admin, YouNew Workspace and local Xcode.
- Exact technical figures come from release-artifacts/sale-readiness-2026-07-30/verification-summary.json.
- No generative alteration was applied to product screenshots or exact claims.
- Final exports are deterministic 1080×1350 PNG assets.
`);

console.log(OUT_DIR);
