import { cp, mkdir, readdir, rm } from "node:fs/promises";
import { spawn } from "node:child_process";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const staged = resolve(root, ".gallery-staged");
const output = resolve(root, "assets/screenshots");

function run(command, args) {
  return new Promise((resolveRun, reject) => {
    const child = spawn(command, args, { cwd: root, stdio: "inherit" });
    child.on("error", reject);
    child.on("exit", (code) => code === 0 ? resolveRun() : reject(new Error(`${command} exited with ${code}`)));
  });
}

await rm(staged, { force: true, recursive: true });
await mkdir(staged, { recursive: true });
await run("docker", ["build", "--platform", "linux/amd64", "--tag", "claudemd-gallery-renderer", "--file", "tools/gallery/Dockerfile", "."]);
await run("docker", [
  "run", "--rm", "--platform", "linux/amd64",
  "--mount", `type=bind,src=${resolve(root, "dist")},dst=/workspace/dist,readonly`,
  "--mount", `type=bind,src=${staged},dst=/gallery/staged`,
  "claudemd-gallery-renderer"
]);
await run(process.execPath, ["tools/gallery/validate-gallery.mjs", staged]);

for (const fileName of await readdir(staged)) {
  if (fileName.endsWith(".png")) await cp(resolve(staged, fileName), resolve(output, fileName));
}

await rm(staged, { force: true, recursive: true });
