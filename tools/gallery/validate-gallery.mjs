import { readFile, readdir, stat } from "node:fs/promises";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(fileURLToPath(new URL("../..", import.meta.url)));
const screenshots = resolve(root, process.argv[2] ?? "assets/screenshots");
const lock = JSON.parse(await readFile(resolve(root, "tools/gallery/renderer-lock.json")));
const markdown = await readFile(resolve(root, "assets/screenshots/README.md"), "utf8");
const expected = new Set(lock.scenarios.map((scenario) => `${scenario}.png`));
const entries = (await readdir(screenshots)).filter((entry) => entry.endsWith(".png"));

if (entries.length !== expected.size || entries.some((entry) => !expected.has(entry))) {
  throw new Error(`Expected exactly: ${[...expected].join(", ")}; got: ${entries.join(", ")}`);
}

for (const fileName of expected) {
  if (!markdown.includes(`(${fileName})`)) {
    throw new Error(`Gallery README does not reference ${fileName}`);
  }

  const path = resolve(screenshots, fileName);
  const contents = await readFile(path);
  const info = await stat(path);
  if (info.size === 0 || contents.subarray(0, 8).compare(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])) !== 0) {
    throw new Error(`${fileName} is not a PNG`);
  }

  const width = contents.readUInt32BE(16);
  const height = contents.readUInt32BE(20);
  const isThumbnail = fileName === "theme-thumbnail.png";
  const expectedWidth = isThumbnail ? 512 : lock.viewport.width;
  const expectedHeight = isThumbnail ? 288 : lock.viewport.height;
  if (width !== expectedWidth || height !== expectedHeight) {
    throw new Error(`${fileName} is ${width}x${height}, expected ${expectedWidth}x${expectedHeight}`);
  }
}
