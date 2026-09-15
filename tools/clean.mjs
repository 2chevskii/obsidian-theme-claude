import { rm } from "node:fs/promises";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const outputs = ["dist"];

await Promise.all(outputs.map((directory) => rm(resolve(root, directory), { recursive: true, force: true })));

console.log(`Removed build artifacts: ${outputs.join(", ")}.`);
