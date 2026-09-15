import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { compile } from "sass";

const root = resolve(import.meta.dirname, "..");
const outputDirectory = resolve(root, "dist/theme");
const sourceScss = resolve(root, "src/theme.scss");
const manifest = await readFile(resolve(root, "manifest.json"), "utf8");
const openFontLicenses = await readFile(resolve(root, "assets/fonts/OPEN_FONT_LICENSES.txt"), "utf8");
const sourceCss = compile(sourceScss, {
  sourceMap: false,
  style: "expanded"
}).css;

const references = [...sourceCss.matchAll(/url\(["']assets\/fonts\/([^"')]+)["']\)/g)];
let distributableCss = sourceCss;

for (const match of references) {
  const relativeReference = match[0];
  const fileName = match[1];
  const font = await readFile(resolve(root, "assets/fonts", fileName));
  const dataUrl = `url("data:font/woff2;base64,${font.toString("base64")}")`;
  distributableCss = distributableCss.replaceAll(relativeReference, dataUrl);
}

if (/url\(["']assets\/fonts\//.test(distributableCss)) {
  throw new Error("Not all local font references were embedded in distributable theme.css.");
}

await rm(outputDirectory, { recursive: true, force: true });
await mkdir(outputDirectory, { recursive: true });
await writeFile(resolve(outputDirectory, "manifest.json"), manifest);
await writeFile(
  resolve(outputDirectory, "theme.css"),
  [
    "/* Generated from src/theme.scss; bundled fonts are embedded for Obsidian Releases. */",
    `/*\n${openFontLicenses.replaceAll("*/", "* /")}*/`,
    distributableCss
  ].join("\n")
);

console.log(`Built distributable theme at ${outputDirectory}`);
