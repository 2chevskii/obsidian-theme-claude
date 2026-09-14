import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { basename, resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const outputDirectory = resolve(root, "dist/theme/Claude");
const sourceCss = await readFile(resolve(root, "theme.css"), "utf8");
const manifest = await readFile(resolve(root, "manifest.json"), "utf8");

const references = [...sourceCss.matchAll(/url\(["']fonts\/([^"')]+)["']\)/g)];
let distributableCss = sourceCss;

for (const match of references) {
  const relativeReference = match[0];
  const fileName = match[1];
  const font = await readFile(resolve(root, "fonts", fileName));
  const dataUrl = `url("data:font/woff2;base64,${font.toString("base64")}")`;
  distributableCss = distributableCss.replaceAll(relativeReference, dataUrl);
}

if (/url\(["']fonts\//.test(distributableCss)) {
  throw new Error("Not all local font references were embedded in distributable theme.css.");
}

await rm(outputDirectory, { recursive: true, force: true });
await mkdir(outputDirectory, { recursive: true });
await writeFile(resolve(outputDirectory, "manifest.json"), manifest);
await writeFile(
  resolve(outputDirectory, "theme.css"),
  `/* Generated from ${basename(resolve(root, "theme.css"))}; bundled fonts are embedded for Obsidian Releases. */\n${distributableCss}`
);

console.log(`Built distributable theme at ${outputDirectory}`);
