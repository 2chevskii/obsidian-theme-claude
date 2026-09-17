import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(fileURLToPath(new URL("../..", import.meta.url)));
const lock = await import("./renderer-lock.json", { with: { type: "json" } });

export const config = {
  runner: "local",
  framework: "mocha",
  specs: ["./specs/**/*.mjs"],
  maxInstances: 1,
  capabilities: [{
    browserName: "obsidian",
    browserVersion: lock.default.obsidian.appVersion,
    "wdio:obsidianOptions": {
      copy: true,
      installerVersion: lock.default.obsidian.installerVersion,
      plugins: [resolve(root, "tools/gallery/locked/obsidian-style-settings")],
      themes: [resolve(root, "dist")],
      vault: resolve(root, "tools/gallery/vault")
    },
    "goog:chromeOptions": {
      args: ["--window-size=1920,1080"]
    }
  }],
  services: ["obsidian"],
  reporters: ["obsidian"],
  cacheDir: "/tmp/obsidian-cache",
  logLevel: "warn",
  mochaOpts: {
    timeout: 120000,
    ui: "bdd"
  }
};
