import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(fileURLToPath(new URL("../..", import.meta.url)));
const lock = JSON.parse(await readFile(resolve(root, "tools/gallery/renderer-lock.json")));
const appPath = resolve("/tmp/obsidian-cache", lock.obsidian.app.cacheFile);
const sha256 = createHash("sha256").update(await readFile(appPath)).digest("hex");

if (sha256 !== lock.obsidian.app.sha256) {
  throw new Error(`Obsidian app checksum mismatch: ${sha256}`);
}
