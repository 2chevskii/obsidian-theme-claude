import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";
import process from "node:process";
import { compile } from "sass";

const root = resolve(import.meta.dirname, "..");
const readJson = (path) => JSON.parse(readFileSync(resolve(root, path), "utf8"));
const failures = [];

const themeManifest = readJson("manifest.json");
const themeVersions = readJson("versions.json");
const rootPackage = readJson("package.json");
const themeCss = compile(resolve(root, "src/theme.scss"), {
  sourceMap: false,
  style: "expanded"
}).css;
const readme = readFileSync(resolve(root, "README.md"), "utf8");
const galleryReadme = readFileSync(resolve(root, "assets/screenshots/README.md"), "utf8");

const check = (condition, message) => {
  if (!condition) failures.push(message);
};

check(rootPackage.version === themeManifest.version, "Root package and theme versions differ.");
check(
  themeVersions[themeManifest.version] === themeManifest.minAppVersion,
  "versions.json does not map the current theme version to minAppVersion."
);
check(themeCss.includes("/* @settings"), "theme.css is missing Style Settings metadata.");
check(themeCss.includes("claude-light-palette-default"), "Default light palette setting is missing.");
check(themeCss.includes("claude-light-palette-warm"), "Warm light palette setting is missing.");
check(themeCss.includes("claude-auto-hide-status-bar"), "Status-bar behavior setting is missing.");
check(themeCss.includes("claude-hide-sync-status"), "Sync visibility setting is missing.");
check(!themeCss.includes("id: claude-font-interface"), "Interface font selector must not be exposed.");
check(!themeCss.includes("id: claude-font-text"), "Text font selector must not be exposed.");
check(!themeCss.includes("id: claude-font-headings"), "Heading font selector must not be exposed.");
check(!themeCss.includes("id: claude-font-code"), "Code font selector must not be exposed.");
for (const family of ["Claude Geist Sans", "Claude Lora", "Claude Literata", "Claude Source Code Pro"]) {
  check(themeCss.includes(family), `Fixed font family is missing: ${family}.`);
}

const fontReferences = [...themeCss.matchAll(/url\(["']assets\/fonts\/([^"')]+)["']\)/g)]
  .map((match) => match[1]);
check(fontReferences.length > 0, "theme.css does not reference bundled fonts.");
for (const file of new Set(fontReferences)) {
  check(existsSync(resolve(root, "assets/fonts", file)), `Missing font file: assets/fonts/${file}`);
}

for (const requiredScreenshot of [
  "overview-light.png",
  "overview-warm.png",
  "overview-dark.png",
  "live-preview-headings-light.png",
  "quick-switcher-light.png",
  "command-palette-dark.png",
  "style-settings-light.png",
  "status-bar-light.png",
  "theme-thumbnail.png"
]) {
  check(
    existsSync(resolve(root, "assets/screenshots", requiredScreenshot)),
    `Missing generated screenshot: assets/screenshots/${requiredScreenshot}`
  );
}
check(readme.includes("assets/screenshots/overview-light.png"), "README is missing the light overview image.");
check(readme.includes("assets/screenshots/overview-dark.png"), "README is missing the dark overview image.");
check(readme.includes("assets/screenshots/README.md"), "README is missing the full gallery link.");
for (const match of galleryReadme.matchAll(/!\[[^\]]*\]\(([^)]+\.png)\)/g)) {
  check(existsSync(resolve(root, "assets/screenshots", match[1])), `Broken gallery image link: ${match[1]}`);
}

for (const [name, version] of Object.entries(rootPackage.devDependencies ?? {})) {
  check(
    typeof version === "string" && /^\d+\.\d+\.\d+(?:[-+].+)?$/.test(version),
    `Root dependency ${name} must be pinned to an exact version, found ${version}.`
  );
}

if (failures.length > 0) {
  for (const failure of failures) console.error(`- ${failure}`);
  process.exitCode = 1;
} else {
  console.log("Metadata, versions, settings, fonts, and dependency pins are consistent.");
}
