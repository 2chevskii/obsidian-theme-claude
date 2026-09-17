import { createHash } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const lock = JSON.parse(await readFile(resolve(root, "tools/gallery/renderer-lock.json")));
const output = resolve(root, "tools/gallery/locked/obsidian-style-settings");

await mkdir(output, { recursive: true });

for (const [fileName, asset] of Object.entries(lock.styleSettings.assets)) {
  const response = await fetch(asset.url);
  if (!response.ok) {
    throw new Error(`Unable to download ${asset.url}: HTTP ${response.status}`);
  }

  const contents = Buffer.from(await response.arrayBuffer());
  const sha256 = createHash("sha256").update(contents).digest("hex");
  if (sha256 !== asset.sha256) {
    throw new Error(`Checksum mismatch for ${fileName}: ${sha256}`);
  }

  await writeFile(resolve(output, fileName), contents);
}
