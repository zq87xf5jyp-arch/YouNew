import path from "node:path";
import fs from "node:fs/promises";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const sharp = require("sharp");

const root = path.resolve("YouNew/BuildWeekFinal");
const sourceDir = path.join(root, "screenshots");
const outputDir = path.join(root, "devpost-media");

const frames = [
  ["01-home.png", "01-home-devpost.jpg", "New to the Netherlands?", "Know what to do next."],
  ["02-ai-assistant.png", "02-ai-assistant-devpost.jpg", "One answer.|The right order.", "BSN → DigiD → health insurance"],
  ["03-newcomer-flow.png", "03-first-steps-devpost.jpg", "Your first steps,|clearly mapped.", "A personal journey from arrival to settled"],
  ["04-guide.png", "04-guide-devpost.jpg", "A practical guide|for everyday life.", "Rules, services, documents, and more"],
  ["06-map.png", "05-map-devpost.jpg", "Explore what’s around you.", "Places, services, and local essentials"],
  ["08-city-detail.png", "06-city-devpost.jpg", "Feel at home|in your city.", "Local guidance for Leiden and beyond"],
  ["07-search.png", "07-search-devpost.jpg", "Find the right|answer fast.", "Search across guides and official services"],
  ["05-official-source.png", "08-official-source-devpost.jpg", "Trusted answers.|Official sources.", "Verified guidance from Rijksoverheid"],
];

const escapeXml = (value) => value.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");

await fs.mkdir(outputDir, { recursive: true });

for (const [inputName, outputName, title, subtitle] of frames) {
  const input = path.join(sourceDir, inputName);
  const output = path.join(outputDir, outputName);
  const phone = await sharp(input)
    .resize({ height: 860, fit: "inside", withoutEnlargement: true })
    .png()
    .toBuffer();
  const meta = await sharp(phone).metadata();
  const phoneX = 1050 - Math.round(meta.width / 2);
  const phoneY = 70;
  const titleLines = title.split("|");
  const titleMarkup = titleLines.map((line, index) =>
    `<tspan x="105" dy="${index === 0 ? 0 : 68}">${escapeXml(line)}</tspan>`
  ).join("");
  const subtitleY = titleLines.length > 1 ? 475 : 420;

  const background = Buffer.from(`
    <svg width="1500" height="1000" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stop-color="#05070b"/>
          <stop offset="0.52" stop-color="#0b1322"/>
          <stop offset="1" stop-color="#071a24"/>
        </linearGradient>
        <radialGradient id="glow" cx="75%" cy="45%" r="60%">
          <stop offset="0" stop-color="#197b92" stop-opacity="0.32"/>
          <stop offset="1" stop-color="#071a24" stop-opacity="0"/>
        </radialGradient>
        <filter id="shadow"><feDropShadow dx="0" dy="20" stdDeviation="24" flood-color="#000" flood-opacity="0.68"/></filter>
      </defs>
      <rect width="1500" height="1000" fill="url(#bg)"/>
      <rect width="1500" height="1000" fill="url(#glow)"/>
      <circle cx="1325" cy="115" r="180" fill="#ff641f" opacity="0.09"/>
      <circle cx="180" cy="905" r="230" fill="#2bb7d4" opacity="0.08"/>
      <g font-family="Arial, Helvetica, sans-serif">
        <text x="105" y="126" fill="#ffffff" font-size="48" font-weight="800">You<tspan fill="#ff641f">New</tspan></text>
        <rect x="105" y="170" width="62" height="6" rx="3" fill="#ff641f"/>
        <text x="105" y="315" fill="#ffffff" font-size="56" font-weight="800">${titleMarkup}</text>
        <text x="105" y="${subtitleY}" fill="#b8c7db" font-size="29" font-weight="500">${escapeXml(subtitle)}</text>
        <text x="105" y="830" fill="#dbe6f5" font-size="24" font-weight="600">Your Netherlands guide</text>
        <text x="105" y="872" fill="#71839c" font-size="20">Clear next steps · trusted sources · local context</text>
      </g>
      <rect x="${phoneX - 16}" y="${phoneY - 16}" width="${meta.width + 32}" height="${meta.height + 32}" rx="58" fill="#111827" stroke="#334155" stroke-width="2" filter="url(#shadow)"/>
    </svg>`);

  await sharp(background)
    .composite([{ input: phone, left: phoneX, top: phoneY }])
    .jpeg({ quality: 92, chromaSubsampling: "4:4:4" })
    .toFile(output);
}

console.log(`Created ${frames.length} Devpost images in ${outputDir}`);
